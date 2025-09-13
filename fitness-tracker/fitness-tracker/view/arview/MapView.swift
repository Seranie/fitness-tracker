//
//  MapView.swift
//  fitness-tracker
//
//  Created by Yukii on 13/9/25.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var routeManager: RouteManager
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        if let route = routeManager.route {
            uiView.addOverlay(route.polyline)
            let region = MKCoordinateRegion(
                center: routeManager.currentLocation?.coordinate ?? route.polyline.boundingMapRect.centerCoordinate,
                latitudinalMeters: 200,
                longitudinalMeters: 200
            )
            uiView.setRegion(region, animated: true)
        }
        
        uiView.removeAnnotations(uiView.annotations)
        let annotations = routeManager.routeCheckpoints.enumerated().map { (index, coord) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            annotation.title = "Checkpoint \(index)"
            return annotation
        }
        uiView.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3
            return renderer
        }
    }
}
