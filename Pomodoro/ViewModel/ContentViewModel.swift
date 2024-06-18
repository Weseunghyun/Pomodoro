import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ContentViewModel: ObservableObject {
    @Published var isLoginMode = true
    @Published var email = ""
    @Published var password = ""
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var showMainView = false
    
    func handleAuthenticationTapped() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showAlert = true
                self.alertMessage = "로그인 실패: ID 나 비밀번호를 확인하세요"
                return
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            self.showMainView = true // 로그인 성공 시 showMainView를 true로 설정
        }
    }
    
    private func createNewAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showAlert = true
                self.alertMessage = "회원가입 실패: \(error.localizedDescription)"
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(result?.user.uid ?? "").setData(["email": self.email]) { error in
                if let error = error {
                    self.showAlert = true
                    self.alertMessage = "사용자 데이터 저장 실패: \(error.localizedDescription)"
                    return
                }
                
                print("Successfully created user and saved to Firestore")
            }
        }
    }
}
