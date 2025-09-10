//
//  Extensions.swift
//  fitness-tracker
//
//  Created by Yukii on 9/9/25.
//

import Foundation

extension FloatingPoint {
    func clamped(to range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
