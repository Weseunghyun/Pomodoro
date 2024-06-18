import SwiftUI
import Firebase

struct SessionView: View {
    @StateObject private var viewModel = SessionViewModel()

    var body: some View {
        VStack {
            List(viewModel.sessions) { session in
                SessionItemView(viewModel: viewModel, session: session)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            viewModel.fetchSessions()
        }
        .sheet(isPresented: $viewModel.showSessionDetails, onDismiss: {
            viewModel.selectedSession = nil
        }) {
            if let selectedSession = viewModel.selectedSession {
                SessionDetailsView(session: selectedSession)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray5)) 
    }
}

struct SessionItemView: View {
    @ObservedObject var viewModel: SessionViewModel
    let session: Session

    var body: some View {
        HStack {
            Image(systemName: "clock") // 시계 아이콘 추가
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.trailing, 8)
            Text(session.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary) // 세션 제목 색상 조정
                .padding(.vertical, 8)
                .onTapGesture {
                    viewModel.selectedSession = session
                    viewModel.showSessionDetails = true
                }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.title2)
                .foregroundColor(.secondary) // 화살표 아이콘 색상 조정
                .padding(.vertical, 8)
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 10) // 모서리 둥글리기
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // 그림자 효과 추가
        )
    }
}




struct SessionDetailsView: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // 제목
            Text(session.title + " 공부 분석")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 16)
            
            // 시작/종료 시간, 공부/휴식 시간
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("시작 시간 : \(formatDate(session.startTime))")
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: 2)
                        )
                }
                HStack {
                    Text("종료 시간 : \(formatDate(session.endTime))")
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: 2)
                        )
                }
            }
            .font(.body)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("공부 시간 : \(formatStudyTime(session.studyTime))")
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: 2)
                        )
                }
                HStack {
                    Text("휴식 시간 : \(formatRestTime(session.restTime))")
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: 2)
                        )
                }
            }
            .font(.body)
            .foregroundColor(Color(.blue))
            .padding(.bottom, 32)
            
            // 집중도 평가
            Text("집중도를 확인해보세요!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.vertical, 16)
            
            // 이모티콘과 코멘트
            VStack(alignment: .center, spacing: 32) {
                if focusPercentage >= 90 {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                    Text("정말 잘하셨어요! 앞으로도 파이팅!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                } else if focusPercentage >= 60 {
                    Image(systemName: "smiley")
                        .font(.title)
                        .foregroundColor(.green)
                    Text("다음엔 더 잘 할 수 있을 것 같아요!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "figure.run")
                        .font(.title)
                        .foregroundColor(.red)
                    Text("집중해서 공부하는 힘을 길러봐요!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 16)
            
            // 총 경과 시간
            VStack(alignment: .center, spacing: 8) {
                Text("총 경과 시간: \(formatDuration(totalDuration))")
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                            .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: 2)
                    )
            }
            
            VStack(alignment: .center, spacing: 8) {
                Text("집중도: \(focusPercentageString)")
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                            .shadow(color: Color(.systemGray4), radius: 4, x: 0, y: 2)
                    )
            }
        }
        .padding()
    }

    
    // 총 경과 시간 및 집중도 계산
    private var totalDuration: TimeInterval {
        session.endTime.timeIntervalSince(session.startTime)
    }
    
    private var focusedDuration: TimeInterval {
        session.studyTime + session.restTime
    }
    
    private var focusPercentage: Double {
        (focusedDuration / totalDuration) * 100
    }
    
    private var focusPercentageString: String {
        String(format: "%.2f%%", focusPercentage)
    }
    
    // 날짜/시간 포맷팅 함수
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
    
    private func formatStudyTime(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: seconds) ?? "0s"
    }
    
    private func formatRestTime(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        return formatter.string(from: seconds) ?? "0s"
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: seconds) ?? "0s"
    }
}
