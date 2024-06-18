//
//  PomodoroApp.swift
//  Pomodoro
//
//  Created by 위승현 on 6/14/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

@main
struct PomodoroApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

