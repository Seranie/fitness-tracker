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
    
    private var workoutSelector: some View {
        TabView(selection: $workoutManager.currentWorkoutType) {
            ForEach(WorkoutType.allCases) { type in
                VStack(spacing: 12) {
                    Image(systemName: type.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.top, 8)
                    
                    Text(type.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(type.backgroundColor.opacity(0.28))
                .cornerRadius(16)
                .padding(.horizontal, 28)
                .tag(type)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 250)
        .animation(.easeInOut, value: workoutManager.currentWorkoutType)
    }
    
    private var targetTimePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Time")
                .font(.headline)
            
            Picker("Duration", selection: $workoutManager.targetTime) {
                ForEach(Array(stride(from: 5, through: 180, by: 5)), id: \.self) { minute in
                    Text("\(minute) min").tag(TimeInterval(minute * 60))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 140)
        }
        .padding(.horizontal, 24)
    }
    
    
    var body: some View {
        ZStack {
            // Dynamic background based on currently-selected type
            workoutManager.currentWorkoutType.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text(workoutManager.currentWorkoutType.headerTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                workoutSelector
                
                targetTimePicker
                
                Spacer()
                
                // Start / Cancel buttons
                HStack(spacing: 12) {
                    // Cancel
                    Button(action: {
                        // simply go back to welcome
                        currentView = .welcome
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(.primary)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.08)))
                    }
                    
                    // Start
                    Button(action: {
                        // lock type and start session, then navigate
                        workoutManager.startSession()
                        currentView = .workoutLog
                    }) {
                        Text("Start")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
                    .disabled(workoutManager.isActive) // safety: cannot start if already active
                    .opacity(workoutManager.isActive ? 0.6 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            } // VStack
        } // ZStack
    }
}
