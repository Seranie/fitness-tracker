//
//  Extensions.swift
//  fitness-tracker
//
//  Created by Yukii on 9/9/25.
//

import Foundation
import SceneKit
import CoreLocation
import MapKit

extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

extension WorkoutManager {
    func buildWorkoutFromSession() -> Workout {
        Workout(
            type: currentWorkoutType,
            duration: duration,
            distanceMeters: distanceMeters,
            calories: calories,
            date: Date(),
            score: score,
            checkpointsCollected: checkpointsCollected,
            selfieFilename: capturedSelfieFilename,
            routeCoordinates: liveTrack
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

extension Notification.Name {
    static let spawnCheckpoint = Notification.Name("spawnCheckpoint")
}

extension CLLocationCoordinate2D {
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        let lat2 = destination.latitude.degreesToRadians
        let lon2 = destination.longitude.degreesToRadians
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        return atan2(y, x)
    }
}

// MARK: - Helper for Degrees/Radians Conversion
extension CLLocationDegrees {
    var degreesToRadians: Double { self * .pi / 180.0 }
    var radiansToDegrees: Double { self * 180.0 / .pi }
}

extension MKMapRect {
    var centerCoordinate: CLLocationCoordinate2D {
        let point = MKMapPoint(x: midX, y: midY)
        return point.coordinate
    }
}
