//
//  SpacedRepetitionService.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation

final class SpacedRepetitionService {
    static let shared = SpacedRepetitionService()

    private init() {}

    // MARK: - Update after answer

    func update(progress: inout LearningProgress, correct: Bool) {
        let now = Date()
        progress.lastReviewDate = now

        if correct {
            progress.successfulAnswers += 1
            progress.repetitions += 1

            // Ease factor (Anki-style)
            progress.easeFactor = max(1.3, progress.easeFactor + 0.05)

            // interval growth
            if progress.repetitions == 1 {
                progress.interval = 1
            } else if progress.repetitions == 2 {
                progress.interval = 3
            } else {
                progress.interval = Int(Double(progress.interval) * progress.easeFactor)
            }
        } else {
            progress.failedAnswers += 1
            progress.mistakes += 1
            progress.repetitions = 0
            progress.interval = 1
            progress.easeFactor = max(1.3, progress.easeFactor - 0.2)
        }

        progress.nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: progress.interval,
            to: now
        ) ?? now
    }

    // MARK: - Should show word

    func shouldShow(progress: LearningProgress?) -> Bool {
        guard let progress else {
            return true
        }

        return Date() >= progress.nextReviewDate
    }
}
