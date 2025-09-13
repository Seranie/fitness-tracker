//
//  Components.swift
//  fitness-tracker
//
//  Created by Yukii on 13/9/25.
//

import RealityKit
import UIKit

// MARK: - Rotation Component
struct RotationComponent: Component {
    var speed: Float // radians per second
}

// MARK: - Checkpoint Component
struct CheckpointComponent: Component {
    let baseColor: UIColor = .orange
    let midColor: UIColor = .yellow
    var closeColor: UIColor = .green
    
    let baseMaterial: SimpleMaterial
    let midMaterial: SimpleMaterial
    let closeMaterial: SimpleMaterial
    var currentMaterial: SimpleMaterial  // Tracks the active one for quick swaps
    
    let closeDistance: Float = 2.0
    let mediumDistance: Float = 3.5
    
    init() {
        self.baseMaterial = SimpleMaterial(color: .orange, isMetallic: false)  // Or your base color
        self.midMaterial = SimpleMaterial(color: .yellow, isMetallic: false)  // e.g., mid-range color
        self.closeMaterial = SimpleMaterial(color: .green, isMetallic: false)  // e.g., close color
        self.currentMaterial = baseMaterial
    }
}
