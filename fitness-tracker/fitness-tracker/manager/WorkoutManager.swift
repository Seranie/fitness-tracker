//
//  WorkoutManager.swift
//  fitness-tracker
//
//  Created by Yukii on 8/9/25.
//

import Foundation
import Combine

final class WorkoutManager: NSObject, ObservableObject {
    // public state for UI binding
    @Published var currentWorkoutType: WorkoutType = .running
    @Published var targetTime: TimeInterval = 30 * 60 // default 30 minutes (user-settable)
    @Published var progress: Double = 0.0 // 0..1
    @Published var duration: TimeInterval = 0
    @Published var distanceMeters: Double = 0
    @Published var calories: Double = 0
    @Published var isPaused: Bool = false
    @Published var score: Int = 0
    @Published var isActive: Bool = false
    @Published var didFinish: Bool = false
    @Published var checkpointsCollected: Int = 0
    

    // internal
    private let weightKg = 70.0 // Used for rough calorie estimate - consider making user-configurable
    let requiredCheckpoints = 1
    
    // timer publisher (view should call .onReceive(workoutManager.timer) to drive updateProgress())
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    // MARK: - Session control
    func prepareForNewSession() {
        progress = 0
        duration = 0
        distanceMeters = 0
        calories = 0
        score = 0
        checkpointsCollected = 0
        isPaused = false
        didFinish = false
    }

    func startSession() {
        prepareForNewSession()
        isActive = true
        isPaused = false
    }

    func stopSession() {
        isActive = false
    }

    func togglePause() {
        guard isActive else { return }
        isPaused.toggle()
    }

    // call this from the view's .onReceive(timer)
    func updateProgressTick() {
        guard isActive, !isPaused else { return }
        duration += 1
        progress = min(duration / max(targetTime, 1.0), 1.0)

        // calories estimate using METs (very rough)
        let met: Double
        switch currentWorkoutType {
        case .running: met = 9.8
        case .cycling: met = 8.0
        case .walking: met = 3.8
        }
        calories = met * weightKg * (duration / 3600.0)

    }

    // MARK: - Scoring (continuous)
    func calculateScore() -> Int {
        // continuous scoring: closer to target (ratio -> 1.0) yields baseline; finishing earlier yields bonus (but not unlimited).
        let ratio = duration / max(targetTime, 1.0) // 1.0 = exact
        var delta = 0

        if ratio <= 1.0 {
            // early/within target: smaller ratio -> more bonus, but clamp to avoid runaway
            let bonusDouble = (1.0 - ratio) * 200.0
            let bonus = Int(bonusDouble.clamped(to: 0...200))
            delta += 100 + bonus // baseline 100 plus bonus proportional to how early you finished
        } else {
            // late -> penalty grows with overshoot
            let penaltyDouble = (ratio - 1.0) * 100.0
            let penalty = Int(penaltyDouble.clamped(to: 0...200))
            delta -= penalty
        }

        return delta
    }

    // MARK: - Completion
    func completeWorkout() {
        guard isActive else { return }
        // finalize
        stopSession()
        isActive = false
        let finalScoreDelta = calculateScore()
        score = max(0, score + finalScoreDelta)

        // build Workout model and persist
        let workout = Workout(
            type: currentWorkoutType,
            duration: duration,
            distanceMeters: distanceMeters,
            calories: calories,
            date: Date(),
            score: score,
            checkpointsCollected: checkpointsCollected
        )

        // signal UI to navigate to summary (caller/view should observe didFinish)
        didFinish = true
    }

    // MARK: - Checkpoints
    func collectCheckpoint(id: String? = nil) {
        guard isActive else { return }
        checkpointsCollected += 1
        score += 50 // immediate reward
    }
    
}


// Supporting
enum SwipeDirection { case left, right }
