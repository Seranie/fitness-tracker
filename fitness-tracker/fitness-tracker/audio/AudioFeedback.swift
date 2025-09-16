//
//  AudioFeedback.swift
//  fitness-tracker
//
//  Created by Yukii on 14/9/25.
//

import AVFoundation

final class AudioFeedback {
    static let shared = AudioFeedback()
    private var players: [String: AVAudioPlayer] = [:]
    
    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func play(_ name: String, ext: String = "wav") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            players[name] = p; p.play()
        } catch {}
    }
}
