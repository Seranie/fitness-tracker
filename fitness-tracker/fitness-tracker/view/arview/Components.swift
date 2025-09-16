//
//  Components.swift
//  fitness-tracker
//
//  Created by Yukii on 13/9/25.
//

import RealityKit
import UIKit

struct RotationComponent: Component {
    var speed: Float // radians per second
}

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
        self.baseMaterial = SimpleMaterial(color: .orange, isMetallic: false)
        self.midMaterial = SimpleMaterial(color: .yellow, isMetallic: false)
        self.closeMaterial = SimpleMaterial(color: .green, isMetallic: false)
        self.currentMaterial = baseMaterial
    }
}
