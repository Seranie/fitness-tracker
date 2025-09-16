//
//  WorkoutDetailMapView.swift
//  fitness-tracker
//
//  Created by Yukii on 14/9/25.
//

import SwiftUI
import MapKit

struct WorkoutDetailMapView: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapPolylineView(workout: workout).ignoresSafeArea()
            
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill").font(.title)
                    .foregroundColor(.primary).padding(6).background(.ultraThinMaterial).clipShape(Circle())
            }.padding()
        }
    }
}

private struct MapPolylineView: UIViewRepresentable {
    let workout: Workout
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        let coords = workout.routeCoordinates
        let poly = MKPolyline(coordinates: coords, count: coords.count)
        map.addOverlay(poly)
        map.setVisibleMapRect(poly.boundingMapRect,
                              edgePadding: .init(top: 30, left: 30, bottom: 30, right: 30),
                              animated: false)
        return map
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let p = overlay as? MKPolyline {
                let r = MKPolylineRenderer(polyline: p)
                r.strokeColor = UIColor(Color.accentColor); r.lineWidth = 4; return r
            }
            return MKOverlayRenderer()
        }
    }
}
