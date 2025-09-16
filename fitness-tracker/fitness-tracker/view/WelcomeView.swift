//
//  WelcomeView.swift
//  fitness-tracker
//
//  Created by Yukii on 9/9/25.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var currentView: AppView
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "figure.walk")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 8)
                
                Text("Workout Log")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Track workouts & look at summaries")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 20)
                Button {
                    currentView = .history
                } label: {
                    Label("History", systemImage: "clock")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.7), lineWidth: 1))
                }
                .padding(.horizontal, 30)
                Button(action: { currentView = .workoutSettings }) {
                    Label("Start Workout", systemImage: "play.fill")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                        .shadow(radius: 6)
                }.padding(.horizontal, 30)
                
//                Button(action: { currentView = .history }) {
//                    Label("History", systemImage: "clock")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .foregroundColor(.white)
//                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.7), lineWidth: 1))
//                }
                Spacer()
            }
            .padding(.top, 80)
        }
    }
}
