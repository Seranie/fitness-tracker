//
//  WorkoutlogView.swift
//  fitness-tracker
//
//  Created by Yukii on 9/9/25.
//

import SwiftUI

struct WorkoutLogView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var currentView: AppView
       
    var body: some View {
        ZStack {
            // AR content
            ARWorkoutView()
                .edgesIgnoringSafeArea(.all)
                .environmentObject(workoutManager)
            
            // transparent overlay to capture SwiftUI gestures above the ARView
            Color.clear
                .contentShape(Rectangle())
                .gesture(doubleTapGesture)
                .gesture(longPressGesture)
            
            // UI overlay
            VStack {
                CheckpointOverlay()
                    .environmentObject(workoutManager)
                HStack {
                    Text(workoutManager.currentWorkoutType.displayName)
                        .font(.headline)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    Spacer()
                    // Pause indicator
                    Text(workoutManager.isPaused ? "Paused" : (workoutManager.isActive ? "Live" : "Idle"))
                        .foregroundColor(workoutManager.isPaused ? .yellow : .green)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
                
                ProgressRingView(progress: workoutManager.progress)
                    .frame(width: 160, height: 160)
                    .padding()
                    .overlay(
                        VStack {
                            Text(timeDisplay)
                                .font(.headline)
                            Text(String(format: "%.1f km • %.0f kcal", workoutManager.distanceMeters / 1000.0, workoutManager.calories))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
                
                HStack(spacing: 16) {
                    Button {
                        workoutManager.togglePause()
                    } label: {
                        VStack {
                            Image(systemName: workoutManager.isPaused ? "play.fill" : "pause.fill")
                            Text(workoutManager.isPaused ? "Resume" : "Pause")
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    
                    Button {
                        // manual finish - call manager and navigate
                        workoutManager.completeWorkout()
                        currentView = .summary
                    } label: {
                        VStack {
                            Image(systemName: "stop.fill")
                            Text("Finish")
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    
//                    Button {
//                        // let user capture a selfie after finishing optionally
//                        showCameraSheet = true
//                    } label: {
//                        VStack {
//                            Image(systemName: "camera")
//                            Text("Selfie")
//                        }
//                        .padding()
//                        .background(.ultraThinMaterial)
//                        .cornerRadius(12)
//                    }
                }
                .padding(.bottom, 28)
            } // VStack
            .padding(.vertical, 20)
        } // ZStack
        .onReceive(workoutManager.timer) { _ in
            workoutManager.updateProgressTick()
        }
        .onChange(of: workoutManager.didFinish) { newVal in
            if newVal {
                // navigate to summary
                currentView = .summary
                workoutManager.didFinish = false
            }
        }
//        .sheet(isPresented: $showCameraSheet) {
//            CameraView { image in
//                capturedSelfie = image
//                if let fname = PersistenceManager.shared.saveImageToDocuments(image) {
//                    // save selfie path into most recent workout if recently completed, else store for later
//                    // For demo: attach to last saved workout
//                    if var latest = PersistenceManager.shared.workouts.first {
//                        var updated = latest
//                        updated.selfieFilename = fname
//                        PersistenceManager.shared.workouts[0] = updated
//                        PersistenceManager.shared.persistAll()
//                    }
//                }
//                showCameraSheet = false
//            }
//        }
    }
    
    var timeDisplay: String {
        let minutes = Int(workoutManager.duration) / 60
        let seconds = Int(workoutManager.duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Gestures
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.6)
            .onEnded { _ in
                workoutManager.togglePause()
            }
    }
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                workoutManager.completeWorkout()
                // navigation will be triggered via didFinish observer
            }
    }
}

