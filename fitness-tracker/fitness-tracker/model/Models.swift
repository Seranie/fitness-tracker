//
//  Models.swift
//  fitness-tracker
//
//  Created by Yukii on 8/9/25.
//

import Foundation
import CoreLocation
import UIKit
import SwiftUI


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
    
    var iconName: String {
        switch self {
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .walking: return "figure.walk"
        }
    }
    
    // Background colors per workout type
    var backgroundColor: Color {
        switch self {
        case .running: return .indigo.opacity(0.2)
        case .cycling: return .blue.opacity(0.2)
        case .walking: return .green.opacity(0.2)
        }
    }
    
    // Header text per workout type
    var headerTitle: String {
        "\(displayName) Settings"
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
    var checkpointsCollected: Int
}
