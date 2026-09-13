//
//  WordProgressStore.swift
//  España
//

import Foundation
import Combine

@MainActor
final class WordProgressStore: ObservableObject {

    static let shared = WordProgressStore()

    private let defaults = UserDefaults.standard
    private let progressKey = "wordProgress.v1"
    private let studyDaysKey = "wordProgress.studyDays.v1"

    @Published private(set) var progressByWordID: [String: WordProgress] = [:]
    @Published private(set) var studyDays: Set<String> = []

    private init() {
        load()
        markStudiedToday()
    }

    // MARK: - Persistence

    private func load() {

        if let data = defaults.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode([String: WordProgress].self, from: data) {
            progressByWordID = decoded
        }

        if let days = defaults.array(forKey: studyDaysKey) as? [String] {
            studyDays = Set(days)
        }
    }

    private func save() {

        if let data = try? JSONEncoder().encode(progressByWordID) {
            defaults.set(data, forKey: progressKey)
        }

        defaults.set(Array(studyDays), forKey: studyDaysKey)
    }

    private func markStudiedToday() {
        studyDays.insert(Self.dayKey(for: Date()))
        save()
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }

    // MARK: - Access

    func progress(for word: Word) -> WordProgress {
        progressByWordID[word.id] ?? WordProgress()
    }

    func recordAnswer(for word: Word, correct: Bool) {

        var progress = progress(for: word)

        if correct {
            progress.registerCorrect()
        } else {
            progress.registerWrong()
        }

        progressByWordID[word.id] = progress
        markStudiedToday()
    }

    // MARK: - Selection

    /// Взвешенный выбор следующего слова: чем труднее слово (больше ошибок,
    /// младше коробка Лейтнера, давно просрочено) — тем выше шанс, что оно
    /// попадётся снова. Старается не повторять только что показанное слово.
    func pickWord(from pool: [Word], avoiding lastWordID: String?) -> Word? {

        guard !pool.isEmpty else { return nil }

        if pool.count > 1, let lastWordID {
            let withoutLast = pool.filter { $0.id != lastWordID }
            if !withoutLast.isEmpty {
                return weightedPick(from: withoutLast)
            }
        }

        return weightedPick(from: pool)
    }

    private func weightedPick(from pool: [Word]) -> Word? {

        let weighted = pool.map { ($0, weight(for: $0)) }
        let total = weighted.reduce(0) { $0 + $1.1 }

        guard total > 0 else { return pool.randomElement() }

        var target = Double.random(in: 0..<total)

        for (word, weight) in weighted {
            if target < weight {
                return word
            }
            target -= weight
        }

        return weighted.last?.0
    }

    private func weight(for word: Word) -> Double {

        let progress = progress(for: word)

        // Новые и "слабые" (низкая коробка) слова весят больше.
        var value = Double(WordProgress.maxBox - progress.box) + 1

        // Слова, в которых чаще ошибались, получают дополнительный вес —
        // это и есть логика "сложные слова попадаются чаще".
        value += Double(progress.wrongCount) * 1.5

        // Просроченные по интервалу повторения слова тоже подталкиваются вверх.
        if progress.isDue {
            value += 2
        }

        return max(value, 0.2)
    }

    // MARK: - Statistics

    func totalCorrect(for words: [Word]) -> Int {
        words.reduce(0) { $0 + progress(for: $1).correctCount }
    }

    func totalWrong(for words: [Word]) -> Int {
        words.reduce(0) { $0 + progress(for: $1).wrongCount }
    }

    func masteredCount(for words: [Word]) -> Int {
        words.filter { progress(for: $0).isMastered }.count
    }

    func newCount(for words: [Word]) -> Int {
        words.filter { progress(for: $0).isNew }.count
    }

    func hardestWords(from words: [Word], limit: Int = 10) -> [(word: Word, progress: WordProgress)] {
        words
            .map { ($0, progress(for: $0)) }
            .filter { $0.1.wrongCount > 0 }
            .sorted { $0.1.wrongCount > $1.1.wrongCount }
            .prefix(limit)
            .map { ($0.0, $0.1) }
    }

    var streakDays: Int {

        var count = 0
        var date = Date()

        while studyDays.contains(Self.dayKey(for: date)) {
            count += 1
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }

        return count
    }
}
