import SwiftUI
import AudioToolbox
import Firebase

class MainViewModel: ObservableObject {
    @Published var totalStudyTime: TimeInterval = 25 * 60 // 25분
    @Published var totalRestTime: TimeInterval = 5 * 60 // 5분
    @Published var elapsedTime: TimeInterval = 25 * 60
    @Published var isTimerRunning = false
    @Published var isStudyMode = true
    @Published var timer: Timer?
    
    @Published var studyCycleTime: TimeInterval = 0
    @Published var restCycleTime: TimeInterval = 0
    @Published var startTime: Date? = nil
    @Published var endTime: Date? = nil
    
    @Published var totalRounds: Int = 5 // 총 라운드 수
    @Published var currentRound: Int = 1 // 현재 라운드
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    @Published var showSessionView = false

    func navigateToSessionView() {
        showSessionView.toggle()
    }
    
    func startTimer() {
        isTimerRunning.toggle()
        if isTimerRunning {
            if startTime == nil {
                startTime = Date()
            }
            if isStudyMode {
                elapsedTime = totalStudyTime
            } else {
                elapsedTime = totalRestTime
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.elapsedTime -= 1
                if self.elapsedTime <= 0 {
                    if self.isStudyMode {
                        self.isStudyMode.toggle()
                        self.elapsedTime = self.totalRestTime
                        self.studyCycleTime += self.totalStudyTime
                        self.playAlertSound()
                        self.recordStudyTime(duration: self.totalStudyTime)
                        self.showAlert(message: "공부 시간이 종료되었습니다. 휴식 시간입니다.")
                        
                    } else {
                        self.isStudyMode.toggle()
                        self.elapsedTime = self.totalStudyTime
                        self.restCycleTime += self.totalRestTime
                        self.playAlertSound()
                        self.recordRestTime(duration: self.totalRestTime)
                        
                        // 현재 라운드 증가
                        self.currentRound += 1
                        
                        // 모든 라운드가 끝났으면 타이머 중지
                        if self.currentRound > self.totalRounds {
                            self.resetTimer()
                            return
                        } else {
                            self.showAlert(message: "휴식 시간이 종료되었습니다. 공부 시간입니다.")
                        }
                    }
                }
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }

    func resetTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        
        if isStudyMode {
            elapsedTime = totalStudyTime
            recordStudyTime(duration: totalStudyTime - elapsedTime)
            studyCycleTime += totalStudyTime - elapsedTime
        } else {
            elapsedTime = totalRestTime
            recordRestTime(duration: totalRestTime - elapsedTime)
            restCycleTime += totalRestTime - elapsedTime
        }
        
        isStudyMode = true
        endTime = Date()
        
        showSessionTitleAlert()
        
        currentRound = 1
    }


    func showSessionTitleAlert() {
        let alert = UIAlertController(title: "공부는 여기까지!!", message: "이번 공부의 이름을 지어주세요!", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "세션 제목"
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "저장", style: .default) { [self] (_) in
            if let title = alert.textFields?.first?.text {
                self.recordCycleTime(title: title)
                self.elapsedTime = self.totalStudyTime
                self.studyCycleTime = 0
                self.restCycleTime = 0
                self.currentRound = 1 // 현재 라운드 초기화
                startTime = nil
                endTime = nil
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        windowScene?.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func showSettingAlert() {
        let alert = UIAlertController(title: "뽀모도로 설정", message: "공부 및 휴식 시간, 총 라운드 수를 설정해주세요.", preferredStyle: .alert)
        
        alert.addTextField { (studyTimeField) in
            studyTimeField.placeholder = "공부 시간 (분)"
            studyTimeField.keyboardType = .numberPad
        }
        
        alert.addTextField { (restTimeField) in
            restTimeField.placeholder = "휴식 시간 (분)"
            restTimeField.keyboardType = .numberPad
        }
        
        alert.addTextField { (roundsField) in
            roundsField.placeholder = "총 라운드 수"
            roundsField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "저장", style: .default) { [self] (_) in
            if let studyTimeText = alert.textFields?.first?.text,
               let restTimeText = alert.textFields?[1].text,
               let roundsText = alert.textFields?[2].text {
                
                if let newStudyTime = Int(studyTimeText),
                   let newRestTime = Int(restTimeText),
                   let newTotalRounds = Int(roundsText) {
                    self.totalStudyTime = TimeInterval(newStudyTime * 60)
                    self.totalRestTime = TimeInterval(newRestTime * 60)
                    self.totalRounds = newTotalRounds
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        windowScene?.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    
    func recordCycleTime(title: String) {
        guard let user = user, let startTime = startTime, let endTime = endTime else { print("nillll"); return }
        
        db.collection("users").document(user.uid).collection("cycles").addDocument(data: [
            "title": title,
            "startTime": startTime,
            "endTime": endTime,
            "studyTime": studyCycleTime,
            "restTime": restCycleTime,
            "totalRounds": totalRounds,
            "currentRound": currentRound
        ]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Cycle time recorded successfully")
            }
        }
    }

    func recordStudyTime(duration: TimeInterval) {
        guard let user = user else { return }
        
        let studyTime = Int(duration)
        db.collection("users").document(user.uid).updateData([
            "studyTime": FieldValue.increment(Int64(studyTime))
        ]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func recordRestTime(duration: TimeInterval) {
        guard let user = user else { return }
        
        let restTime = Int(duration)
        db.collection("users").document(user.uid).updateData([
            "restTime": FieldValue.increment(Int64(restTime))
        ]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func playAlertSound() {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        func showAlert(message: String) {
            let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(okAction)
            
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
}

