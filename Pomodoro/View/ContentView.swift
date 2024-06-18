import SwiftUI

///wskii@hansung.ac.kr, 111111
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    Image("Pomodoro") // 이미지 이름으로 변경
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100) // 이미지 크기 조정
                    
                    Text("뽀모도로")
                        .font(.title)
                        .foregroundColor(.blue)
        
                    
                    Group {
                        TextField("이메일", text: $viewModel.email)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        
                        SecureField("비밀번호", text: $viewModel.password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.handleAuthenticationTapped()
                    }) {
                        Text(viewModel.isLoginMode ? "로그인" : "회원가입")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button(action: {
                        viewModel.isLoginMode.toggle()
                    }) {
                        Text(viewModel.isLoginMode ? "계정 만들기" : "로그인으로 돌아가기")
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 100)
                    
                    Text("공부는 뽀모도로와 함께!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 50) // 화면 하단에 텍스트 배치
                    
                    NavigationLink(
                        destination: MainView(),
                        isActive: $viewModel.showMainView,
                        label: { EmptyView() }
                    )
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("오류"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("확인")))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
