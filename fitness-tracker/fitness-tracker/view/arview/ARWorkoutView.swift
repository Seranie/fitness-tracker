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
    
    var checkpointCount: Int = 3 // make dynamic? changeable in settings
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Set the session delegate to the coordinator for frame updates
        arView.session.delegate = context.coordinator
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
        // Place checkpoints
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            placeCheckpoints(in: arView, coordinator: context.coordinator)
        }
        
        arView.addGestureRecognizer(
            UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        )
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(workoutManager: workoutManager)
    }
    
    // MARK: - Checkpoint placement
    private func placeCheckpoints(in arView: ARView, coordinator: Coordinator) {
        guard let cameraTransform = arView.session.currentFrame?.camera.transform else { return }
        let angles = stride(from: 0.0, to: Double.pi*2, by: Double.pi*2 / Double(max(checkpointCount,1)))
        let baseDistance: Float = 5
        var idx = 0
        
        for angle in angles {
            let dx = cos(angle) * Double(baseDistance)
            let dz = sin(angle) * Double(baseDistance)
            var translation = matrix_identity_float4x4
            translation.columns.3.x = Float(dx)
            translation.columns.3.z = Float(dz)
            let transform = simd_mul(cameraTransform, translation)
            
            let anchor = AnchorEntity(world: transform)
            let checkpoint = makeCheckpointEntity(index: idx)
            anchor.addChild(checkpoint)
            arView.scene.addAnchor(anchor)
            // Store the checkpoint entity in the coordinator
            coordinator.checkpoints.append(checkpoint)
            idx += 1
        }
    }
    
    private func makeCheckpointEntity(index: Int) -> ModelEntity {
        let checkpoint = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.1),
            materials: []
        )
        
        checkpoint.name = "checkpoint_\(index)"
        let checkpointComp = CheckpointComponent()
        checkpoint.model?.materials = [checkpointComp.currentMaterial]
        checkpoint.components.set(checkpointComp)
        checkpoint.generateCollisionShapes(recursive: true)
        
        return checkpoint
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, ARSessionDelegate {
        var workoutManager: WorkoutManager
        var checkpoints: [ModelEntity] = []
        
        init(workoutManager: WorkoutManager) {
            self.workoutManager = workoutManager
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
                
                // Adjust color and rotation speed based on proximity
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
                // Optional: Visual/audio cue for "too far" (e.g., flash red or play sound)
                return
            }
            
            // Success: Collect the checkpoint
            entity.scale = SIMD3<Float>(0.001, 0.001, 0.001)
            entity.removeFromParent()
            workoutManager.collectCheckpoint()
            
            // Optional: Success feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}
