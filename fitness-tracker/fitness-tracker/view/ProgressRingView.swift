//
//  ProgressRingView.swift
//  fitness-tracker
//
//  Created by Yukii on 9/9/25.
//

import SwiftUI

struct ProgressRingView: View {
    var progress: Double // 0..1
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 16)
                .opacity(0.15)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 0.25), value: progress)
        }
        .foregroundStyle(AngularGradient(gradient: Gradient(colors: [Color.accentColor, Color.blue, Color.purple]), center: .center))
    }
}
