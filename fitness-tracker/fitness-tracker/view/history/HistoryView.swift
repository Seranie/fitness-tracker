//
//  HistoryView.swift
//  fitness-tracker
//
//  Created by Yukii on 14/9/25.
//

import SwiftUI
import MapKit

struct HistoryView: View {
    @Binding var currentView: AppView
    @State private var workouts: [Workout] = PersistenceManager.shared.workouts
    @State private var selectedWorkout: Workout?
    @State private var expandedSelfieID: UUID?
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    Button { currentView = .welcome } label: {
                        Image(systemName: "chevron.left").font(.title2.bold()).foregroundColor(.white)
                    }
                    Spacer()
                    Text("Workout History").font(.title2.bold()).foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.left").hidden()
                }.padding(.horizontal)
                
                if workouts.isEmpty {
                    Spacer(); Text("No workouts yet").foregroundColor(.white.opacity(0.8)); Spacer()
                } else {
                    List(workouts) { w in
                        row(for: w).listRowBackground(Color.white.opacity(0.1))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    delete(w)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                            .onTapGesture { selectedWorkout = w }
                    }.scrollContentBackground(.hidden)
                }
            }
        }
        .sheet(item: $selectedWorkout) { WorkoutDetailMapView(workout: $0) }
    }
    
    @ViewBuilder
    func row(for w: Workout) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: w.type.iconName)
                Text(w.type.displayName).font(.headline)
                Spacer()
                Text(w.date, style: .date).font(.caption)
            }.foregroundColor(.white)
            
            Text("⏱ \(timeString(from: w.duration))  📏 \(String(format:"%.2f km", w.distanceMeters/1000))  🔥 \(Int(w.calories)) kcal")
                .font(.caption).foregroundColor(.white.opacity(0.8))
            
            if w.selfieFilename != nil {
                Button(action: {
                    expandedSelfieID = (expandedSelfieID == w.id) ? nil : w.id   // toggle
                }) {
                    HStack {
                        Image(systemName: "camera.fill").foregroundColor(.accentColor)
                        Text("Selfie").font(.caption).foregroundColor(.accentColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            // Expand to show image when user clicks on the button
            if expandedSelfieID == w.id,
               let fname = w.selfieFilename,
               let uiImage = PersistenceManager.shared.loadImage(fileName: fname) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 6)
                    .transition(.scale.combined(with: .opacity))   // smooth
            }
        }
        .padding(.vertical, 4)
//        .animation(.easeInOut(duration: 0.25), value: expandedSelfieID)
    }
    
    private func delete(_ workout: Workout) {
        var all = PersistenceManager.shared.workouts
        all.removeAll { $0.id == workout.id }
        UserDefaults.standard.set(try? JSONEncoder().encode(all), forKey: PersistenceManager.workoutsKey)
        workouts = all        // refresh local list
    }
}
