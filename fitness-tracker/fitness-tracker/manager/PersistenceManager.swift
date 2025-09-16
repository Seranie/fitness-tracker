//
//  PersistenceManager.swift
//  fitness-tracker
//
//  Created by Yukii on 14/9/25.
//

import Foundation
import UIKit

final class PersistenceManager {
    static let shared = PersistenceManager()
    private init() {}
    
    // MARK: - Workouts
    static let workoutsKey = "workouts_v2"

    var workouts: [Workout] {
        guard let data = UserDefaults.standard.data(forKey: PersistenceManager.workoutsKey),
              let decoded = try? JSONDecoder().decode([Workout].self, from: data)
        else { return [] }
        return decoded
    }
    
    func saveWorkout(_ w: Workout) {
        var all = workouts
        if let index = all.firstIndex(where: { $0.id == w.id }) {
            all[index] = w          // replace existing
        } else {
            all.insert(w, at: 0)    // new workout
        }
        UserDefaults.standard.set(try? JSONEncoder().encode(all), forKey: PersistenceManager.workoutsKey)
    }
    
    // MARK: - Images
    @discardableResult
    func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let fileName = UUID().uuidString + ".jpg"
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        do { try data.write(to: url); return fileName } catch { return nil }
    }
    
    func loadImage(fileName: String) -> UIImage? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }
}
