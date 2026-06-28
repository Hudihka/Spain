//
//  LearningProgress.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation

struct LearningProgress: Codable {
    let wordID: String
    var repetitions: Int
    var interval: Int
    var easeFactor: Double
    var mistakes: Int
    var successfulAnswers: Int
    var failedAnswers: Int
    var nextReviewDate: Date
    var lastReviewDate: Date?

    init(wordID: String) {
        self.wordID = wordID
        repetitions = 0
        interval = 1
        easeFactor = 2.5
        mistakes = 0
        successfulAnswers = 0
        failedAnswers = 0
        nextReviewDate = .now
        lastReviewDate = nil
    }

    var totalAnswers: Int {
        successfulAnswers + failedAnswers
    }

    var accuracy: Double {
        guard totalAnswers > 0 else {
            return 0
        }

        return Double(successfulAnswers) / Double(totalAnswers)
    }

}
