import Foundation
import Firebase

struct Session: Identifiable {
    let id = UUID()
    var title: String
    let startTime: Date
    let endTime: Date
    let studyTime: Double
    let restTime: Double
}

class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var showSessionDetails = false
    @Published var selectedSession: Session?

    private let db = Firestore.firestore()

    init() {
        fetchSessions()
    }

    func fetchSessions() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User is not signed in.")
            return
        }

        let db = Firestore.firestore()
        let cyclesCollectionRef = db.collection("users").document(userId).collection("cycles")

        cyclesCollectionRef.order(by: "startTime", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching sessions: \(error)")
                    return
                }

                self.sessions = querySnapshot?.documents.compactMap { document in
                    guard let title = document.get("title") as? String,
                          let startTime = document.get("startTime") as? Timestamp,
                          let endTime = document.get("endTime") as? Timestamp,
                          let studyTime = document.get("studyTime") as? Double,
                          let restTime = document.get("restTime") as? Double else {
                        return nil
                    }
                    return Session(title: title, startTime: startTime.dateValue(), endTime: endTime.dateValue(), studyTime: studyTime, restTime: restTime)
                } ?? []
            }
    }

    func editSession(_ session: Session, newTitle: String) {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("Error: User is not signed in.")
                return
            }

            let cyclesCollectionRef = db.collection("users").document(userId).collection("cycles")
            let sessionDocRef = cyclesCollectionRef.document(session.id.uuidString);
        
            sessionDocRef.updateData(["title": newTitle]) { error in
                if let error = error {
                    print("Error updating session title: \(error)")
                } else {
                    // Update the session object in the sessions array
                    if let index = self.sessions.firstIndex(where: { $0.id == session.id }) {
                        self.sessions[index].title = newTitle
                    }
                }
            }
        }
}
