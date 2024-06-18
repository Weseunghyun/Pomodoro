import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var sessionViewModel = SessionViewModel()

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ZStack {
                // Pomodoro Timer 텍스트와 이모지 추가
                HStack {
                    Image(systemName: "timer")
                        .font(.title)
                    Text("Pomodoro Timer")
                        .font(.title)
                        .fontWeight(.bold)
                    Image(systemName: "hourglass.bottomhalf.fill")
                        .font(.title)
                }
                .foregroundColor(.white)
                .padding(.top, 40)

                Circle()
                    .fill(Color.white)
                    .frame(width: 300, height: 300)
                    .offset(y: -140)

                Circle()
                    .trim(from: 0, to: 1 - viewModel.elapsedTime / (viewModel.isStudyMode ? viewModel.totalStudyTime : viewModel.totalRestTime))
                    .stroke(viewModel.isStudyMode ? Color(red: 0.8, green: 0.2, blue: 0.2) : Color(red: 0.2, green: 0.8, blue: 0.2), lineWidth: 20)
                    .frame(width: 320, height: 320)
                    .rotationEffect(.degrees(-90))
                    .offset(y: -130)

                VStack {
                    Spacer()

                    Text(viewModel.formattedTime)
                        .font(.system(size: 64, weight: .bold))
                        .padding(.top,40)
                    Spacer()

                    HStack {
                        Button(action: {
                            viewModel.startTimer()
                        }) {
                            Text(viewModel.isTimerRunning ? "일시정지" : "시작")
                                .padding()
                                .background(viewModel.isTimerRunning ? Color.blue : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            viewModel.resetTimer()
                        }) {
                            Text("중지")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                               viewModel.showSettingAlert()
                           }) {
                               Image(systemName: "gear")
                                   .font(.title)
                                   .padding()
                           }
                    }
                    .padding(.top, 70)

                    // 라운드 정보 표시
                    Text("Round \(viewModel.currentRound) / \(viewModel.totalRounds)")
                        .font(.title2)
                        .padding(.top, 70)

                    Spacer()
                }
                .padding(.top,40)
            }
            .tabItem {
                Image(systemName: "house")
                Text("메인")
            }
            .tag(0)

            SessionView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("세션")
                }
                .tag(1)

            StatisticView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("통계")
                }
                .tag(2)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
