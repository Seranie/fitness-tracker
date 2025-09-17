//
//  Theme.swift
//  fitness-tracker
//
//  Created by Yukii on 8/9/25.
//

import SwiftUI

enum Theme {
    static var accent = Color("AccentColor")
    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var panelBackground: Color { Color(UIColor.secondarySystemBackground) }
}
