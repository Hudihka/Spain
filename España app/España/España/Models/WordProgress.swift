//
//  WordProgress.swift
//  España
//

import Foundation

struct WordProgress: Codable {

    static let maxBox = 4

    var box: Int = 0
    var correctCount: Int = 0
    var wrongCount: Int = 0
    var lastAnsweredAt: Date?
    var nextDueAt: Date = .distantPast

    var isMastered: Bool {
        box >= Self.maxBox
    }

    var isNew: Bool {
        correctCount == 0 && wrongCount == 0
    }

    var isDue: Bool {
        nextDueAt <= Date()
    }

    mutating func registerCorrect() {
        correctCount += 1
        box = min(box + 1, Self.maxBox)
        lastAnsweredAt = Date()
        nextDueAt = Date().addingTimeInterval(Self.interval(forBox: box))
    }

    mutating func registerWrong() {
        wrongCount += 1
        box = max(box - 1, 0)
        lastAnsweredAt = Date()
        nextDueAt = Date()
    }

    // Интервалы повторения по коробке Лейтнера: чем выше коробка, тем реже
    // слово должно попадаться, пока его снова не забудут.
    private static func interval(forBox box: Int) -> TimeInterval {
        switch box {
        case 0: return 0
        case 1: return 60 * 30
        case 2: return 60 * 60 * 6
        case 3: return 60 * 60 * 24
        default: return 60 * 60 * 24 * 4
        }
    }
}
