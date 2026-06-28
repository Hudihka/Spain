//
//  AudioManager.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import UIKit
import AudioToolbox

final class AudioManager {

    static let shared = AudioManager()

    private init() {}

    func success() {
        AudioServicesPlaySystemSound(1104)
    }

    func error() {
        AudioServicesPlaySystemSound(1053)
    }
}
