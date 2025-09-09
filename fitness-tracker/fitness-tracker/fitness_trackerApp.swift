//
//  fitness_trackerApp.swift
//  fitness-tracker
//
//  Created by Yukii on 8/9/25.
//

import SwiftUI

@main
struct fitness_trackerApp: App {
    @StateObject private var workoutManager = WorkoutManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
        }
    }
}
