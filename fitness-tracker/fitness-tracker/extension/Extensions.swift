//
//  Extensions.swift
//  fitness-tracker
//
//  Created by Yukii on 9/9/25.
//

import Foundation
import SceneKit

extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

extension WorkoutManager {
    // returns a Workout struct built from the current session in memory
    var lastSessionInMemory: Workout {
        Workout(
            type: currentWorkoutType,
            duration: duration,
            distanceMeters: distanceMeters,
            calories: calories,
            date: Date(),
            score: score,
            checkpointsCollected: checkpointsCollected
        )
    }
}

extension SCNVector3 {
    static func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    var length: Float {
        sqrt(x*x + y*y + z*z)
    }
}
