//
//  ProgressStore.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import Foundation
import Combine

@MainActor
final class ProgressStore: ObservableObject {

    @Published private(set) var correctAnswers: [String: Int] = [:]
    @Published private(set) var totalAnswers: [String: Int] = [:]

    private let key = "progress_store_v1"

    init() {
        load()
    }
    
    // ❗ RESET ОДНОЙ ТЕМЫ
    func reset(topic: Topic) {

        for word in topic.words {
            correctAnswers[word.id] = nil
            totalAnswers[word.id] = nil
        }

        save()
    }

    // ❗ RESET ВСЕГО (если нужно)
    func resetAll() {
        correctAnswers.removeAll()
        totalAnswers.removeAll()
        save()
    }

    func registerAnswer(wordId: String, isCorrect: Bool) {

        totalAnswers[wordId, default: 0] += 1

        if isCorrect {
            correctAnswers[wordId, default: 0] += 1
        }

        save()
    }

    func accuracy(for wordId: String) -> Double {

        let total = totalAnswers[wordId, default: 0]
        guard total > 0 else { return 0 }

        let correct = correctAnswers[wordId, default: 0]

        return Double(correct) / Double(total)
    }

    func topicProgress(words: [Word]) -> Double {

        guard !words.isEmpty else { return 0 }

        let learned = words.filter { accuracy(for: $0.id) > 0.7 }.count

        return Double(learned) / Double(words.count)
    }

    private func save() {
        let data: [String: Any] = [
            "correct": correctAnswers,
            "total": totalAnswers
        ]

        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {

        guard let data = UserDefaults.standard.dictionary(forKey: key),
              let correct = data["correct"] as? [String: Int],
              let total = data["total"] as? [String: Int]
        else { return }

        correctAnswers = correct
        totalAnswers = total
    }
}
