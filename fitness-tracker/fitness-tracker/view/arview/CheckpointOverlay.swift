//
//  ARWorkoutViewWithOverlay.swift
//  fitness-tracker
//
//  Created by Yukii on 13/9/25.
//

import SwiftUI
import Foundation

struct CheckpointOverlay: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    // state to show the flash message
    @State private var showFlashMessage = false
    
    var body: some View {
        // Overlay UI over ARView
        VStack(spacing: 8) {
            Text("Checkpoints: \(workoutManager.checkpointsCollected)/\(workoutManager.requiredCheckpoints)")
                .font(.headline)
                .foregroundColor(.yellow)
                .shadow(radius: 2)
            
            // flash message when user collects checkpoint
            if showFlashMessage {
                Text("All checkpoints collected!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .shadow(radius: 2)
                    .transition(.opacity)
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        
        // Watch for checkpoint collection
        .onChange(of: workoutManager.checkpointsCollected) { newValue in
            if newValue >= workoutManager.requiredCheckpoints {
                flashMessage()
            }
        }
    }
    
    private func flashMessage() {
        withAnimation {
            showFlashMessage = true
        }
        // Hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showFlashMessage = false
            }
        }
    }
}
