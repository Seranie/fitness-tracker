//
//  SummaryView.swift
//  fitness-tracker
//
//  Created by Yukii on 9/9/25.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var currentView: AppView
    @State private var showCamera = false
    private var workout: Workout { workoutManager.lastSessionInMemory }
    
    var body: some View {
        // show last workout summary
        VStack(spacing: 16) {
            Text("Workout Summary")
                .font(.title2.bold())
                .padding()
            
            VStack(spacing: 8) {
                Text(workout.type.displayName).font(.headline)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(timeString(from: workout.duration))
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Distance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.2f km", workout.distanceMeters / 1000))
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f kcal", workout.calories))
                    }
                }
                .padding(.vertical, 8)
                
                Text("Score: \(workout.score)")
            }
            .padding()
            .background(Theme.panelBackground)
            .cornerRadius(12)
            
            // selfie thumbnail
            if let fname = workout.selfieFilename,
               let uiImage = PersistenceManager.shared.loadImage(fileName: fname) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                    .padding(.bottom, 8)
            }
            
            // camera button (only if missing)
            if workout.selfieFilename == nil {
                Button {
                    showCamera = true
                } label: {
                    Label("Add Selfie", systemImage: "camera")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            
            // existing back-home
            Button("Back Home") {
                currentView = .welcome
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                if let fname = PersistenceManager.shared.saveImageToDocuments(image) {
                    workoutManager.lastSessionInMemory.selfieFilename = fname
                    PersistenceManager.shared.saveWorkout(workoutManager.lastSessionInMemory)
                }
            }
        }
    }
}

func timeString(from seconds: TimeInterval) -> String {
    let m = Int(seconds) / 60
    let s = Int(seconds) % 60
    return String(format: "%02d:%02d", m, s)
}
