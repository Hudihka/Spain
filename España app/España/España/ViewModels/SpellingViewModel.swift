//
//  SpellingViewModel.swift
//  España
//

import Foundation
import SwiftUI
import Combine

enum SpellingState: Equatable {
    case idle
    case success
    case failure
}

@MainActor
final class SpellingViewModel: ObservableObject {

    // MARK: - Public state

    @Published var promptText: String = ""
    @Published var availableTiles: [LetterTile] = []
    @Published var assembledTiles: [LetterTile] = []
    @Published var state: SpellingState = .idle
    @Published var progressText: String = ""
    @Published var progressValue: Double = 0
    @Published var isFinished: Bool = false

    // MARK: - Private

    private let allWords: [Word]
    private var currentWord: Word?
    private var solvedWordIDs: Set<String> = []
    private var lastWordID: String?
    private var isLocked = false

    private var correctCount = 0
    private var attemptsCount = 0

    var countWords: Int {
        allWords.count
    }

    var accuracyPercent: Int {
        guard attemptsCount != 0 else { return 0 }
        return Int(100 * Double(correctCount) / Double(attemptsCount))
    }

    // MARK: - Init

    init(topic: Topic) {
        self.allWords = topic.words.filter(Self.isSpellable)
        loadNextWord()
    }

    private static func isSpellable(_ word: Word) -> Bool {
        !word.spanish.contains("/") && !word.spanish.contains(",")
    }

    // MARK: - Next word

    private func availableWords() -> [Word] {
        allWords.filter { !solvedWordIDs.contains($0.id) }
    }

    func loadNextWord() {

        let pool = availableWords()

        guard let word = WordProgressStore.shared.pickWord(from: pool, avoiding: lastWordID) else {
            isFinished = true
            return
        }

        lastWordID = word.id
        currentWord = word
        promptText = word.russian

        let target = Self.normalizedLetters(from: word.spanish)
        availableTiles = Self.makeTiles(target: target)
        assembledTiles = []
        state = .idle

        updateProgress()
    }

    // MARK: - Letters

    private static func normalizedLetters(from spanish: String) -> [Character] {
        let trimmed = spanish
            .trimmingCharacters(in: CharacterSet(charactersIn: "¡¿?!"))
            .lowercased()
        return Array(trimmed)
    }

    private static func makeTiles(target: [Character]) -> [LetterTile] {

        let decoyPool: [Character] = Array("abcdefghijklmnopqrstuvwxyzñáéíóú")
        let extraCount = target.count <= 4 ? 2 : 3

        let decoys = decoyPool
            .filter { !target.contains($0) }
            .shuffled()
            .prefix(extraCount)

        let all = target + decoys
        return all.map { LetterTile(character: $0) }.shuffled()
    }

    // MARK: - Interaction

    func selectAvailable(_ tile: LetterTile) {

        guard !isLocked, state == .idle else { return }
        guard let index = availableTiles.firstIndex(of: tile) else { return }

        availableTiles.remove(at: index)
        assembledTiles.append(tile)

        checkIfNeeded()
    }

    func removeAssembled(_ tile: LetterTile) {

        guard !isLocked, state == .idle else { return }
        guard let index = assembledTiles.firstIndex(of: tile) else { return }

        assembledTiles.remove(at: index)
        availableTiles.append(tile)
    }

    private func checkIfNeeded() {

        guard let word = currentWord else { return }

        let target = Self.normalizedLetters(from: word.spanish)
        guard assembledTiles.count == target.count else { return }

        isLocked = true
        attemptsCount += 1

        let assembled = assembledTiles.map { $0.character }

        if assembled == target {
            handleSuccess(for: word)
        } else {
            handleFailure(for: word)
        }
    }

    private func handleSuccess(for word: Word) {

        correctCount += 1
        state = .success
        solvedWordIDs.insert(word.id)

        WordProgressStore.shared.recordAnswer(for: word, correct: true)
        HapticManager.shared.success()
        AudioManager.shared.success()

        updateProgress()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.isLocked = false
            self?.loadNextWord()
        }
    }

    private func handleFailure(for word: Word) {

        state = .failure

        WordProgressStore.shared.recordAnswer(for: word, correct: false)
        HapticManager.shared.error()
        AudioManager.shared.error()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            guard let self else { return }

            withAnimation {
                self.availableTiles.append(contentsOf: self.assembledTiles)
                self.assembledTiles.removeAll()
                self.state = .idle
            }

            self.isLocked = false
        }
    }

    // MARK: - Progress

    private func updateProgress() {
        progressText = "Собрано \(solvedWordIDs.count) из \(countWords), \(accuracyPercent)%"
        progressValue = countWords == 0 ? 0 : Double(solvedWordIDs.count) / Double(countWords)
    }

    // MARK: - Restart

    func restart() {
        solvedWordIDs.removeAll()
        correctCount = 0
        attemptsCount = 0
        isFinished = false
        state = .idle
        loadNextWord()
    }
}
