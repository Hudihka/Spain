//
//  HapticManager.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import UIKit

final class HapticManager {

    static let shared = HapticManager()

    private init() {}

    func success() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func error() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
