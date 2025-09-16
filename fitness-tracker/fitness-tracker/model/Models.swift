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
    var selfieFilename: String?
    
    private var coords: [Coord]
    var routeCoordinates: [CLLocationCoordinate2D] {
        coords.map { .init(latitude: $0.lat, longitude: $0.lon) }
    }
    
    init(type: WorkoutType, duration: TimeInterval, distanceMeters: Double,
         calories: Double, date: Date, score: Int, checkpointsCollected: Int,
         selfieFilename: String? = nil, routeCoordinates: [CLLocationCoordinate2D]) {
        self.type = type; self.duration = duration; self.distanceMeters = distanceMeters
        self.calories = calories; self.date = date; self.score = score
        self.checkpointsCollected = checkpointsCollected; self.selfieFilename = selfieFilename
        self.coords = routeCoordinates.map { Coord(lat: $0.latitude, lon: $0.longitude) }
    }
    
    struct Coord: Codable { var lat, lon: Double }
}
