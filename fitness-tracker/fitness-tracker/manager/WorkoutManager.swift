//
//  WorkoutManager.swift
//  fitness-tracker
//
//  Created by Yukii on 8/9/25.
//

import Foundation
import Combine
import CoreLocation
import MapKit

final class WorkoutManager: NSObject, ObservableObject, CLLocationManagerDelegate {
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
    @Published var nextCheckpointInfo: String = ""
    @Published var capturedSelfieFilename: String?
    @Published var lastSessionInMemory: Workout = Workout(
        type: .running,
        duration: 0,
        distanceMeters: 0,
        calories: 0,
        date: Date.distantPast,
        score: 0,
        checkpointsCollected: 0,
        selfieFilename: nil,
        routeCoordinates: []
    )
    
    var liveTrack: [CLLocationCoordinate2D] = []
    private var hasAnnouncedFinish = false
    let routeManager = RouteManager()
    private var lastLocation: CLLocation?
    var requiredCheckpoints: Int {
            routeManager.requiredCheckpoints
        }
    
    private let weightKg = 70.0 // for rough calorie estimate - consider making user-settable
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    override init() {
        super.init()
        // sync routeManager nextCheckpointInfo
        routeManager.$nextCheckpointInfo
            .assign(to: &$nextCheckpointInfo)
    }
    
    func prepareForNewSession() {
        progress = 0
        duration = 0
        distanceMeters = 0
        calories = 0
        score = 0
        checkpointsCollected = 0
        isPaused = false
        didFinish = false
        lastLocation = nil
        routeManager.stopRoute()
    }

    func startSession() {
        prepareForNewSession()
        isActive = true
        isPaused = false
        routeManager.startRoute()
        liveTrack.removeAll()
        hasAnnouncedFinish = false
        capturedSelfieFilename = nil
        // update distance from RouteManager
        routeManager.$currentLocation
            .compactMap { $0?.coordinate }
            .sink { [weak self] coord in
                self?.liveTrack.append(coord)
                self?.distanceMeters += self?.routeManager.distanceSince(self?.lastLocation) ?? 0
                self?.lastLocation = self?.routeManager.currentLocation
            }
            .store(in: &cancellables)
    }

    func stopSession() {
        isActive = false
        routeManager.stopRoute()
    }

    func togglePause() {
        guard isActive else { return }
        isPaused.toggle()
        if isPaused {
            routeManager.stopRoute()
        } else {
            routeManager.startRoute()
        }
    }

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

    func calculateScore() -> Int {
        // continuous scoring, closer to target yields baseline score, finishing earlier yields bonus (but not unlimited).
        let ratio = duration / max(targetTime, 1.0) // 1.0 = exact
        var delta = 0

        if ratio <= 1.0 {
            // early = more bonus, but clamp to avoid too large score
            let bonusDouble = (1.0 - ratio) * 200.0
            let bonus = Int(bonusDouble.clamped(to: 0...200))
            delta += 100 + bonus // baseline 100 plus bonus proportional to how early you finished
        } else {
            // late = penalty grows with overshoot
            let penaltyDouble = (ratio - 1.0) * 100.0
            let penalty = Int(penaltyDouble.clamped(to: 0...200))
            delta -= penalty
        }

        return delta
    }

    func completeWorkout() {
        guard isActive else { return }
        // finalize
        stopSession()
        isActive = false
        let finalScoreDelta = calculateScore()
        score = max(0, score + finalScoreDelta)

        // build workout model and persist
        let workout = buildWorkoutFromSession()
        PersistenceManager.shared.saveWorkout(workout)
        // signal UI to navigate to summary
        lastSessionInMemory = workout
        didFinish = true
        
        AudioFeedback.shared.play("success")
    }

    func collectCheckpoint(id: String? = nil) {
        guard isActive else { return }
        checkpointsCollected += 1
        score += 50 // immediate score reward
        AudioFeedback.shared.play("checkpoint")
    }
    
    private var cancellables = Set<AnyCancellable>()

}

enum SwipeDirection { case left, right }
