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
    case revealed
}

@MainActor
final class SpellingViewModel: ObservableObject {

    private static let maxAttemptsBeforeReveal = 5

    // MARK: - Public state

    @Published var promptText: String = ""
    @Published var targetLength: Int = 0
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
    private var wrongAttemptsForCurrentWord = 0

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
        wrongAttemptsForCurrentWord = 0

        let target = Self.normalizedLetters(from: word.spanish)
        targetLength = target.count
        availableTiles = Self.makeTiles(target: target)
        assembledTiles = []
        state = .idle

        updateProgress()
    }

    // MARK: - Letters

    private static func normalizedLetters(from spanish: String) -> [Character] {
        Array(
            spanish
                .trimmingCharacters(in: CharacterSet(charactersIn: "¡¿?!"))
                .lowercased()
        )
    }

    // Без букв-обманок — только буквы самого слова, перемешанные.
    private static func makeTiles(target: [Character]) -> [LetterTile] {
        target.map { LetterTile(character: $0) }.shuffled()
    }

    // MARK: - Interaction

    func selectAvailable(_ tile: LetterTile) {

        guard !isLocked, state == .idle else { return }
        guard let index = availableTiles.firstIndex(of: tile) else { return }

        HapticManager.shared.selection()

        availableTiles.remove(at: index)
        assembledTiles.append(tile)

        checkIfNeeded()
    }

    func removeAssembled(_ tile: LetterTile) {

        guard !isLocked, state == .idle else { return }
        guard let index = assembledTiles.firstIndex(of: tile) else { return }

        HapticManager.shared.selection()

        assembledTiles.remove(at: index)
        availableTiles.append(tile)
    }

    /// Вернуть все набранные буквы назад и начать сборку текущего слова заново.
    func resetCurrentWord() {

        guard !isLocked, state == .idle, !assembledTiles.isEmpty else { return }

        HapticManager.shared.selection()

        withAnimation {
            availableTiles.append(contentsOf: assembledTiles)
            assembledTiles.removeAll()
            availableTiles.shuffle()
        }
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
            handleFailure(for: word, target: target)
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

    private func handleFailure(for word: Word, target: [Character]) {

        wrongAttemptsForCurrentWord += 1

        WordProgressStore.shared.recordAnswer(for: word, correct: false)
        HapticManager.shared.error()
        AudioManager.shared.error()

        if wrongAttemptsForCurrentWord >= Self.maxAttemptsBeforeReveal {
            revealAnswer(target: target)
        } else {
            state = .failure

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
    }

    private func revealAnswer(target: [Character]) {

        state = .revealed
        assembledTiles = target.map { LetterTile(character: $0) }
        availableTiles = []

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            self?.isLocked = false
            self?.loadNextWord()
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
