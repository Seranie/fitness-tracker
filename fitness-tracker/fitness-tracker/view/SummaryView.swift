//
//  SummaryView.swift
//  fitness-tracker
//
//  Created by Yukii on 9/9/25.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var persistence: PersistenceManager
    @Binding var currentView: AppView
    
    // show last workout summary
    var lastWorkout: Workout? {
        persistence.workouts.first
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Workout Summary")
                .font(.title2.bold())
            
            if let w = lastWorkout {
                VStack(spacing: 8) {
                    Text(w.type.displayName).font(.headline)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(timeString(from: w.duration))
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Distance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.2f km", w.distanceMeters / 1000))
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Calories")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.0f kcal", w.calories))
                        }
                    }
                    .padding(.vertical, 8)
                    
                    HStack {
                        Text("Score: \(w.score)")
                        Spacer()
                        Text("Checkpoints: \(w.checkpointsCollected)/3")
                    }
                }
                .padding()
                .background(Theme.panelBackground)
                .cornerRadius(12)
                
                if let fn = w.selfieFilename, let url = PersistenceManager.shared.imageURL(for: fn), let data = try? Data(contentsOf: url), let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .cornerRadius(12)
                }
                
                MapViewRepresentable(track: w.gpsTrack)
                    .frame(height: 200)
                    .cornerRadius(12)
            } else {
                Text("No workout data")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Button("Back Home") {
                    currentView = .welcome
                }.padding()
                Spacer()
                Button("View History") {
                    currentView = .history
                }.padding()
            }
        }
        .padding()
    }
    
    func timeString(from seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    SummaryView()
}
