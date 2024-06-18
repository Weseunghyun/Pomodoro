// StatisticViewModel.swift
import Foundation
import Firebase

struct DailyStats {
    let date: Date
    let hourlyStudyTimes: [TimeInterval] // 각 시간대별 공부 시간
    let totalRestTime: TimeInterval
}

struct WeeklyStats {
    let startDate: Date
    let dailyStudyTimes: [TimeInterval] // 각 요일별 공부 시간
    let totalRestTime: TimeInterval
}

struct MonthlyStats {
    let year: Int
    let month: Int
    let weeklyStudyTimes: [TimeInterval] // 각 주별 공부 시간
    let totalRestTime: TimeInterval
}

class StatisticViewModel: ObservableObject {
    @Published var dailyStats: DailyStats?
    @Published var weeklyStats: WeeklyStats?
    @Published var monthlyStats: MonthlyStats?
    
    private let db = Firestore.firestore()
    private let userId = Auth.auth().currentUser?.uid
    
    init() {
        fetchStats(period: .day)
        fetchStats(period: .week)
        fetchStats(period: .month)
    }
    
    enum Period {
        case day, week, month
    }
    
    func fetchStats(period: Period) {
        let (startDate, endDate): (Date, Date) = {
            let calendar = Calendar.current
            let today = Date()
            switch period {
            case .day:
                let startOfDay = calendar.startOfDay(for: today)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
                return (startOfDay, endOfDay)
            case .week:
                let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
                return (startOfWeek, endOfWeek)
            case .month:
                let components = calendar.dateComponents([.year, .month], from: today)
                let startOfMonth = calendar.date(from: components)!
                let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!.addingTimeInterval(-1)
                return (startOfMonth, endOfMonth)
            }
        }()
        
        db.collection("users").document(userId!).collection("cycles")
            .whereField("startTime", isGreaterThanOrEqualTo: startDate)
            .whereField("startTime", isLessThanOrEqualTo: endDate)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching \(period) stats: \(error)")
                    return
                }
                
                var totalRestTime: TimeInterval = 0
                var studyTimes: [TimeInterval] = []

                switch period {
                case .day:
                    studyTimes = Array(repeating: 0, count: 6)
                case .week:
                    studyTimes = Array(repeating: 0, count: 7)
                case .month:
                    studyTimes = Array(repeating: 0, count: 5)
                }

                for document in querySnapshot?.documents ?? [] {
                    let startTime = (document.get("startTime") as? Timestamp)?.dateValue() ?? Date()
                    let studyTime = document.get("studyTime") as? TimeInterval ?? 0
                    let restTime = document.get("restTime") as? TimeInterval ?? 0

                    totalRestTime += restTime

                    switch period {
                    case .day:
                        let hour = Calendar.current.component(.hour, from: startTime)
                        let index = hour / 4
                        studyTimes[index] += studyTime
                    case .week:
                        let weekday = Calendar.current.component(.weekday, from: startTime) - 1
                        studyTimes[weekday] += studyTime
                    case .month:
                        let weekOfMonth = Calendar.current.component(.weekOfMonth, from: startTime) - 1
                        studyTimes[weekOfMonth] += studyTime
                    }
                }
                
                self.addStats(period: period, startDate: startDate, endDate: endDate, studyTimes: studyTimes, totalRestTime: totalRestTime)
            }
    }
    
    private func addStats(period: Period, startDate: Date, endDate: Date, studyTimes: [TimeInterval], totalRestTime: TimeInterval) {
        switch period {
        case .day:
            let dailyStats = DailyStats(date: startDate, hourlyStudyTimes: studyTimes, totalRestTime: totalRestTime)
            self.dailyStats = dailyStats
        case .week:
            let weeklyStats = WeeklyStats(startDate: startDate, dailyStudyTimes: studyTimes, totalRestTime: totalRestTime)
            self.weeklyStats = weeklyStats
        case .month:
            let components = Calendar.current.dateComponents([.year, .month], from: startDate)
            let monthlyStats = MonthlyStats(year: components.year!, month: components.month!, weeklyStudyTimes: studyTimes, totalRestTime: totalRestTime)
            self.monthlyStats = monthlyStats
        }
    }
}
