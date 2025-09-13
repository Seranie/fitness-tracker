//
//  RouteManager.swift
//  fitness-tracker
//
//  Created by Yukii on 13/9/25.
//

import Foundation
import CoreLocation
import MapKit

final class RouteManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var routeCheckpoints: [CLLocationCoordinate2D] = []
    @Published var nextCheckpointInfo: String = "" // e.g., "Checkpoint #1: 50m ahead"
    @Published var routeDistance: Double = 0.0 // Total route distance in meters
    @Published var currentLocation: CLLocation? // Latest user location
    
    private let locationManager = CLLocationManager()
    var route: MKRoute?
    private var pendingCheckpointIndices: Set<Int> = []
    private let checkpointProximity: CLLocationDistance = 20.0 // Spawn when <20m
    private let requiredCheckpoints = 3
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5.0
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startRoute() {
        routeCheckpoints = []
        pendingCheckpointIndices = Set(1...requiredCheckpoints)
        routeDistance = 0.0
        currentLocation = nil
        locationManager.startUpdatingLocation()
        generateRoute()
    }
    
    func stopRoute() {
        locationManager.stopUpdatingLocation()
        route = nil
        routeCheckpoints = []
        pendingCheckpointIndices = []
        nextCheckpointInfo = ""
    }
    
    private func generateRoute() {
        guard let start = locationManager.location?.coordinate else { return }
        
        // Create a 3-point loop (~200m total)
        let segmentDistance: CLLocationDistance = 70.0
        let waypoints = [
            start,
            offsetCoordinate(start, bearing: 0.0, distance: segmentDistance), // North
            offsetCoordinate(start, bearing: 120.0 * .pi / 180, distance: segmentDistance), // SE
            offsetCoordinate(start, bearing: 240.0 * .pi / 180, distance: segmentDistance) // SW
        ]
        
        routeCheckpoints.append(start) // Start point
        var lastCoord = waypoints[0]
        
        func fetchRouteSegment(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: @escaping (MKRoute?) -> Void) {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
            request.transportType = .walking
            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                completion(response?.routes.first)
            }
        }
        
        // Chain segments: start -> 1 -> 2 -> 3
        for i in 1..<waypoints.count {
            fetchRouteSegment(from: lastCoord, to: waypoints[i]) { [weak self] route in
                guard let route = route else { return }
                DispatchQueue.main.async {
                    self?.routeCheckpoints.append(waypoints[i])
                    self?.route = route
                    self?.routeDistance += route.distance
                }
                lastCoord = waypoints[i]
            }
        }
    }
    
    private func offsetCoordinate(_ coord: CLLocationCoordinate2D, bearing: Double, distance: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6371000.0
        let lat = coord.latitude * .pi / 180
        let lon = coord.longitude * .pi / 180
        let delta = distance / earthRadius
        let newLat = asin(sin(lat) * cos(delta) + cos(lat) * sin(delta) * cos(bearing))
        let newLon = lon + atan2(sin(bearing) * sin(delta) * cos(lat), cos(delta) - sin(lat) * sin(newLat))
        return CLLocationCoordinate2D(latitude: newLat * 180 / .pi, longitude: newLon * 180 / .pi)
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        currentLocation = newLocation
        
        // Check proximity for spawning
        for (index, coord) in routeCheckpoints.enumerated() where pendingCheckpointIndices.contains(index) {
            let target = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = newLocation.distance(from: target)
            if distance < checkpointProximity {
                DispatchQueue.main.async {
                    self.nextCheckpointInfo = "Checkpoint #\(index): \(Int(distance))m ahead"
                    self.pendingCheckpointIndices.remove(index)
                    NotificationCenter.default.post(name: .spawnCheckpoint, object: index)
                }
                break // One at a time
            }
        }
    }
    
    // Helper for WorkoutManager
    func distanceSince(_ lastLocation: CLLocation?) -> Double {
        guard let newLocation = currentLocation, let last = lastLocation else { return 0.0 }
        return newLocation.distance(from: last)
    }
}
