//
//  ARWorkoutView.swift
//  fitness-tracker
//
//  Created by Yukii on 12/9/25.
//

import SwiftUI
import RealityKit
import ARKit

struct ARWorkoutView: UIViewRepresentable {
    @EnvironmentObject var workoutManager: WorkoutManager
        
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Set the session delegate to the coordinator for frame updates
        arView.session.delegate = context.coordinator
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
        context.coordinator.setupNotifications(in: arView)
        
        arView.addGestureRecognizer(
            UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        )
        
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        arView.addGestureRecognizer(doubleTap)
        
        let longPress = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        longPress.minimumPressDuration = 0.6
        arView.addGestureRecognizer(longPress)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(workoutManager: workoutManager)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var workoutManager: WorkoutManager
        var checkpoints: [ModelEntity] = []
        weak var arView: ARView?
        
        init(workoutManager: WorkoutManager) {
            self.workoutManager = workoutManager
        }
        
        private func makeCheckpointEntity(index: Int) -> ModelEntity {
            let checkpoint = ModelEntity(
                mesh: MeshResource.generateSphere(radius: 0.2),
                materials: []
            )
            
            checkpoint.name = "checkpoint_\(index)"
            let checkpointComp = CheckpointComponent()
            checkpoint.model?.materials = [checkpointComp.currentMaterial]
            checkpoint.components.set(checkpointComp)
            checkpoint.generateCollisionShapes(recursive: true)
            
            return checkpoint
        }
        
        func setupNotifications(in arView: ARView) {
            self.arView = arView

            NotificationCenter.default.addObserver(
                forName: .spawnCheckpoint,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                if let index = notification.object as? Int,
                   let arView = self?.arView,
                   let frame = arView.session.currentFrame {
                    self?.spawnCheckpoint(atIndex: index, in: arView, frame: frame)
                }
            }
        }
        
        private func spawnCheckpoint(atIndex index: Int, in arView: ARView, frame: ARFrame) {
            guard let currentLoc = workoutManager.routeManager.currentLocation,
                  index < workoutManager.routeManager.routeCheckpoints.count else { return }
            
            let targetCoord = workoutManager.routeManager.routeCheckpoints[index]
            let targetLoc = CLLocation(latitude: targetCoord.latitude, longitude: targetCoord.longitude)
            
            // Calculate relative position
            let distance = currentLoc.distance(from: targetLoc)
            let bearing = currentLoc.coordinate.bearing(to: targetCoord)
            
            // Convert to AR space
            let cameraTransform = frame.camera.transform
            let arDistance = Float(min(distance, 10.0)) // Cap distance for ARKit's visibility
            
            // Create transformation relative to camera position
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -arDistance // Place in front of camera
            
            // Convert geographic bearing to AR rotation
            // Will use device heading to adjust the bearing
            let deviceHeading = Float(frame.camera.eulerAngles.y) // Camera yaw in radians
            let relativeBearing = Float(bearing) - deviceHeading
            
            let rotation = simd_float4x4(SCNMatrix4MakeRotation(relativeBearing, 0, 1, 0))
            let orientedTransform = simd_mul(rotation, translation)
            let worldTransform = simd_mul(cameraTransform, orientedTransform)
            
            let anchor = AnchorEntity(world: worldTransform)
            let checkpoint = makeCheckpointEntity(index: index)
            anchor.addChild(checkpoint)
            arView.scene.addAnchor(anchor)
            checkpoints.append(checkpoint)
            
            // Spawn animation
            checkpoint.scale = SIMD3<Float>(0.001, 0.001, 0.001)
            checkpoint.move(to: Transform(scale: .one), relativeTo: checkpoint.parent, duration: 0.8, timingFunction: .easeOut)
            
        }
        
        // ARSessionDelegate method for frame updates
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Get camera position
            let camTransform = frame.camera.transform
            let camPos = SIMD3<Float>(camTransform.columns.3.x, camTransform.columns.3.y, camTransform.columns.3.z)
            
            for entity in checkpoints {
                // Skip if entity is removed
                if entity.parent == nil { continue }
                
                guard var checkpointComp = entity.components[CheckpointComponent.self],
                      var model = entity.model else { continue }
                
                let distance = simd_distance(camPos, entity.position(relativeTo: nil)) // World position
                
                // Adjust color based on proximity
                let newMaterial: SimpleMaterial
                if distance < checkpointComp.closeDistance {
                    newMaterial = checkpointComp.closeMaterial
                } else if distance < checkpointComp.mediumDistance {
                    newMaterial = checkpointComp.midMaterial
                } else {
                    newMaterial = checkpointComp.baseMaterial
                }
                
                checkpointComp.currentMaterial = newMaterial
                model.materials = [newMaterial]
                entity.model = model
                entity.components.set(checkpointComp)  // Update component with new currentMaterial
                
            }
        }
        
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = recognizer.view as? ARView,
                  let currentFrame = arView.session.currentFrame else { return }
            let location = recognizer.location(in: arView)
            
            guard let entity = arView.entity(at: location),
                  entity.name.starts(with: "checkpoint"),
                  let checkpointComp = entity.components[CheckpointComponent.self] else {
                let generator = UIImpactFeedbackGenerator(style: .light); generator.impactOccurred()
                return
            }
            // Get camera and entity world positions
            let camTransform = currentFrame.camera.transform
            let camPos = SIMD3<Float>(camTransform.columns.3.x, camTransform.columns.3.y, camTransform.columns.3.z)
            let entityPos = entity.position(relativeTo: nil)  // World position
            
            let distance = simd_distance(camPos, entityPos)
            
            // Only collect if within close distance
            guard distance < checkpointComp.closeDistance else {
                return
            }
            
            // Collect the checkpoint
            entity.scale = SIMD3<Float>(0.001, 0.001, 0.001)
            entity.removeFromParent()
            workoutManager.collectCheckpoint()
            
            // Vibration feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
        @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            workoutManager.completeWorkout()
        }
        
        @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
            guard recognizer.state == .began else { return }
            workoutManager.togglePause()
            
            // Vibration feedback
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
}
