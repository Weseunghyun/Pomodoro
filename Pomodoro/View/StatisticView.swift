// StatisticView.swift
import SwiftUI
import Charts
import Firebase

struct StatisticView: View {
    @StateObject private var viewModel = StatisticViewModel()
    @State private var selectedView = 0

    var body: some View {
        VStack {
            Picker("View", selection: $selectedView) {
                Text("Day").tag(0)
                Text("Week").tag(1)
                Text("Month").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle()) // 스타일 변경
            .padding()
            
            StatsView(viewType: selectedView, viewModel: viewModel)
        }
    }
}

struct StatsView: View {
    let viewType: Int
    let viewModel: StatisticViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                switch viewType {
                case 0:
                    if let dailyStats = viewModel.dailyStats {
                        StatsCard(
                            title: StatsHelper.dateFormatter.string(from: dailyStats.date),
                            studyTimes: dailyStats.hourlyStudyTimes,
                            restTime: dailyStats.totalRestTime,
                            labels: ["00-04", "04-08", "08-12", "12-16", "16-20", "20-24"],
                            patternAnalysis: dailyPatternAnalysis(studyTimes: dailyStats.hourlyStudyTimes)
                        )
                        .padding(.vertical, 16)
                        Text("그래프로 한눈에 확인해보세요!")
                                .font(.headline)
                                .padding(.top, 32)
                        BarChartView(data: dailyStats.hourlyStudyTimes, labels: ["00-04", "04-08", "08-12", "12-16", "16-20", "20-24"])
                            .frame(height: 200)
                            .padding(.top,8)
                    }
                case 1:
                    if let weeklyStats = viewModel.weeklyStats {
                        StatsCard(
                            title: StatsHelper.weeklyFormatter(start: weeklyStats.startDate, end: weeklyStats.startDate.addingTimeInterval(6*24*3600)),
                            studyTimes: weeklyStats.dailyStudyTimes,
                            restTime: weeklyStats.totalRestTime,
                            labels: ["월", "화", "수", "목", "금", "토", "일"],
                            patternAnalysis: weeklyPatternAnalysis(studyTimes: weeklyStats.dailyStudyTimes)
                        )
                        Text("그래프로 한눈에 확인해보세요!")
                                .font(.headline)
                                .padding(.top, 32)
                        BarChartView(data: weeklyStats.dailyStudyTimes, labels: ["월", "화", "수", "목", "금", "토", "일"])
                            .frame(height: 200)
                            .padding(.top,8)
                    }
                case 2:
                    if let monthlyStats = viewModel.monthlyStats {
                        StatsCard(
                            title: StatsHelper.monthFormatter(year: monthlyStats.year, month: monthlyStats.month),
                            studyTimes: monthlyStats.weeklyStudyTimes,
                            restTime: monthlyStats.totalRestTime,
                            labels: ["첫째주", "둘째주", "셋째주", "넷째주", "다섯째주"],
                            patternAnalysis: monthlyPatternAnalysis(studyTimes: monthlyStats.weeklyStudyTimes)
                        )
                        Text("그래프로 한눈에 확인해보세요!")
                                .font(.headline)
                                .padding(.top, 32)
                        BarChartView(data: monthlyStats.weeklyStudyTimes, labels: ["첫째주", "둘째주", "셋째주", "넷째주", "다섯째주"])
                            .frame(height: 200)
                            .padding(.top,8)
                    }
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func dailyPatternAnalysis(studyTimes: [TimeInterval]) -> String {
        var comment = ""
        if studyTimes[0] + studyTimes[1] > studyTimes[2] + studyTimes[3] + studyTimes[4] + studyTimes[5] {
            comment = "새벽 시간 대에 집중을 잘하시는 편이시네요! 🌙"
        } else if studyTimes[2] + studyTimes[3] > studyTimes[0] + studyTimes[1] + studyTimes[4] + studyTimes[5] {
            comment = "아침에 집중을 잘하는 편이시네요! ☀️"
        } else {
            comment = "저녁에 집중을 잘하시는 편이시네요! 🌆"
        }
        return comment
    }

    private func weeklyPatternAnalysis(studyTimes: [TimeInterval]) -> String {
        var comment = ""
        if studyTimes[0] + studyTimes[1] + studyTimes[2] > studyTimes[3] + studyTimes[4] {
            comment = "주 초에 공부를 많이했어요! 👍"
        } else if studyTimes[3] + studyTimes[4] > studyTimes[5] + studyTimes[6] {
            comment = "곧 다가오는 주말에는 푹 쉴 수 있겠어요! 🌴"
        } else {
            comment = "주말에도 열심히 공부하는 모습 멋져요! 👏"
        }
        return comment
    }

    private func monthlyPatternAnalysis(studyTimes: [TimeInterval]) -> String {
        var comment = ""
        if studyTimes[0] + studyTimes[1] > studyTimes[2] + studyTimes[3] + studyTimes[4] {
            comment = "이번 달 초반에 열심히 공부하셨네요! 👍"
        } else if studyTimes[2] + studyTimes[3] > studyTimes[0] + studyTimes[1] + studyTimes[4] {
            comment = "이번 달 중반에 공부에 집중하셨군요! 💪"
        } else {
            comment = "이번 달 후반에도 꾸준히 공부하셨어요! 👏"
        }
        return comment
    }
}

struct StatsCard: View {
    let title: String
    let studyTimes: [TimeInterval]
    let restTime: TimeInterval
    let labels: [String]
    let patternAnalysis: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(title) 공부 시간 종합")
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.horizontal)

            ForEach(0..<studyTimes.count, id: \.self) { index in
                HStack {
                    Text(labels[index])
                        .font(.body)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(StatsHelper.formatTimeInterval(studyTimes[index]))
                        .font(.subheadline)
                }
                .padding(.horizontal)
            }

            HStack {
                Text("총 휴식 시간")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(StatsHelper.formatTimeInterval(restTime))
                    .font(.subheadline)
            }
            .padding(.horizontal)

            Text(patternAnalysis)
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}


struct BarChartView: View {
    let data: [TimeInterval]
    let labels: [String]
    
    var body: some View {
        Chart {
            ForEach(data.indices, id: \.self) { index in
                BarMark(
                    x: .value("Label", labels[index]),
                    y: .value("Study Time", data[index])
                )
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel(value.as(String.self)!)
                    .font(.caption) // X 축 레이블 폰트 크기 조정
            }
        }
        .chartYAxis {
            AxisMarks(
                position: .trailing, // 시간 표시를 오른쪽에 배치
                values: calculateYAxisRange()
            ) { value in
                AxisGridLine()
                AxisValueLabel(formatTimeInterval(value.as(Double.self)!)) // 1시간 단위로 표시
            }
        }
        .padding()
    }
    
    private func calculateYAxisRange() -> [Double] {
        guard let maxTime = data.max() else { return [0, 7200] } // 기본 범위 설정은 2시간

        let maxSeconds = max(7200, ceil(maxTime / 3600.0) * 3600) // 최소 2시간까지 설정
        return stride(from: 0, to: maxSeconds + 1, by: 3600).map { $0 } // 1시간 단위
    }

    private func formatTimeInterval(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        return "\(hours)h"
    }
}



class StatsHelper {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter
    }()
    
    static func weeklyFormatter(start: Date, end: Date) -> String {
        let startStr = shortDateFormatter.string(from: start)
        let endStr = shortDateFormatter.string(from: end)
        return "\(startStr) - \(endStr)"
    }

    static func monthFormatter(year: Int, month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        return formatter.string(from: date)
    }

    static func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(interval.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d시간 %02d분 %02d초", hours, minutes, seconds)
    }
}
