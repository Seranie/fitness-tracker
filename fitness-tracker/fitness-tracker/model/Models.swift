//
//  Models.swift
//  fitness-tracker
//
//  Created by Yukii on 8/9/25.
//

import Foundation
import CoreLocation
import UIKit

enum WorkoutType: String, Codable, CaseIterable, Identifiable {
    case cycling, running, walking
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .cycling: return "Cycling"
        case .running: return "Running"
        case .walking: return "Walking"
        }
    }
}

struct Workout: Identifiable, Codable {
    var id: UUID = UUID()
    var type: WorkoutType
    var duration: TimeInterval // seconds
    var distanceMeters: Double
    var calories: Double
    var date: Date
    var score: Int
}
