//
//  WorkoutSettingsView.swift
//  fitness-tracker
//
//  Created by Yukii on 9/9/25.
//

import SwiftUI

struct WorkoutSettingsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var currentView: AppView
    
    let durations = [5, 10, 15, 20, 30, 45, 60] // minutes
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New Workout")
                .font(.title2.bold())
            Picker("Type", selection: $workoutManager.currentWorkoutType) {
                ForEach(WorkoutType.allCases) { workoutType in
                    Text(workoutType.displayName).tag(workoutType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            HStack {
                Text("Duration:")
                Spacer()
                Text("\(Int(workoutManager.targetTime / 60)) min")
                    .foregroundColor(.secondary)
            }.padding(.horizontal, 20)
            
            Picker("Duration", selection: $workoutManager.targetTime) {
                ForEach(durations, id: \.self) { minute in
                    Text("\(minute) min").tag(TimeInterval(minute * 60))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 140)
            
            HStack(spacing: 12) {
                Button("Cancel") { currentView = .welcome }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
                Spacer()
                Button(action: {
                    workoutManager.startSession()
                    currentView = .workoutLog
                }) {
                    Text("Start")
                        .bold()
                        .frame(width: 120, height: 44)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
        .background(Theme.panelBackground)
        .cornerRadius(16)
        .padding()
    }
}
