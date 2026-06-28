//
//  TopicStatistics.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation

struct TopicStatistics: Codable {
    let topicID: UUID
    var completedTimes: Int
    var bestAccuracy: Double
    var lastAccuracy: Double
    var lastPlayed: Date?
    var totalAnswers: Int
    var correctAnswers: Int

    init(topicID: UUID) {
        self.topicID = topicID
        completedTimes = 0
        bestAccuracy = 0
        lastAccuracy = 0
        lastPlayed = nil
        totalAnswers = 0
        correctAnswers = 0
    }

    var accuracy: Double {
        guard totalAnswers > 0 else {
            return 0
        }

        return Double(correctAnswers) / Double(totalAnswers)
    }

}
