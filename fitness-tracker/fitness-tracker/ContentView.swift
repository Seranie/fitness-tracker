//
//  ContentView.swift
//  fitness-tracker
//
//  Created by Yukii on 8/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentView: AppView = .welcome
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        ZStack {
            switch currentView {
            case .welcome:
                WelcomeView(currentView: $currentView)
            case .workoutSettings:
                WorkoutSettingsView(currentView: $currentView)
            case .workoutLog:
                WorkoutLogView(currentView: $currentView)
            case .summary:
                SummaryView(currentView: $currentView)

            }
        }
    }
}

enum AppView { case welcome, workoutSettings, workoutLog, summary, history }

#Preview {
    ContentView()
}
