//
//  QuizViewModel.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class QuizViewModel: ObservableObject {

    // MARK: - Public state

    @Published var currentQuestion: QuizQuestion?
    @Published var answerState: AnswerState = .idle
    @Published var progressText: String = ""
    @Published var accuracy: Int = 0
    @Published var isFinished: Bool = false
    @Published var xp: Int = 0
    

    // MARK: - Private
    
    private var isLocked = false

    private let topic: Topic
    private let mode: QuizMode

    private var words: [Word]
    private var progressMap: [String: LearningProgress]

    private let repetitionService = SpacedRepetitionService.shared
    private let storage = UserProgressStorage.shared   // ✅ ВОТ ОН, НЕ УБИРАЕМ

    private var correctAnswers = 0
    private var totalAnswers = 0

    private var queue: [Word]

    // MARK: - Init

    init(topic: Topic, mode: QuizMode = .spanishToRussian) {
        self.topic = topic
        self.words = topic.words
        self.mode = mode

        self.queue = topic.words.shuffled()

        self.progressMap = storage.load()

        setupMissingProgress()
        loadNextQuestion()
    }

    // MARK: - Setup

    private func setupMissingProgress() {
        for word in words {
            if progressMap[word.id] == nil {
                progressMap[word.id] = LearningProgress(wordID: word.id)
            }
        }
    }

    // MARK: - Next question

    func loadNextQuestion() {

        let availableWords = getAvailableWords()

        guard let word = selectNextWord(from: availableWords) else {
            finish()
            return
        }

        let (prompt, answer) = makeQA(for: word)
        let options = makeOptions(correct: answer)

        currentQuestion = QuizQuestion(
            word: word,
            prompt: prompt,
            correctAnswer: answer,
            options: options
        )

        updateProgressText()
    }

    // MARK: - QA

    private func makeQA(for word: Word) -> (String, String) {

        switch mode {
        case .spanishToRussian:
            return (word.spanish, word.russian)
        case .russianToSpanish:
            return (word.russian, word.spanish)
        }
    }

    // MARK: - Words selection

    private func getAvailableWords() -> [Word] {
        let filtered = words.filter { word in
            let progress = progressMap[word.id]

            return repetitionService.shouldShow(progress: progress)
        }

        return filtered.isEmpty ? words : filtered
    }

    private func selectNextWord(from list: [Word]) -> Word? {
        list.randomElement()
    }

    // MARK: - Options

    private func makeOptions(correct: String) -> [String] {

        var pool = words.map {
            mode == .spanishToRussian ? $0.russian : $0.spanish
        }

        pool.removeAll(where: { $0 == correct })

        let wrong = Array(Set(pool)).shuffled().prefix(3)

        return (Array(wrong) + [correct]).shuffled()
    }

    // MARK: - Answer

    func selectAnswer(_ answer: String) {

        guard !isLocked, let question = currentQuestion else { return }
        isLocked = true

        totalAnswers += 1

        let isCorrect = answer == question.correctAnswer

        if isCorrect {
            correctAnswers += 1
            xp += 10
            answerState = .correct

            HapticManager.shared.success()
            AudioManager.shared.success()
        } else {
            answerState = .incorrect(selected: answer)

            HapticManager.shared.error()
            AudioManager.shared.error()
        }

        updateLearning(for: question.word, correct: isCorrect)

        updateAccuracy()
        updateProgressText()

        storage.save(progressMap)   // ✅ ВАЖНО: сохраняем через store

        let delay: Double = isCorrect ? 0.3 : 1.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.answerState = .idle
            self.loadNextQuestion()
            self.isLocked = false
        }
    }

    // MARK: - Learning

    private func updateLearning(for word: Word, correct: Bool) {

        guard var progress = progressMap[word.id] else { return }

        repetitionService.update(progress: &progress, correct: correct)

        progressMap[word.id] = progress
    }

    // MARK: - Stats

    private func updateAccuracy() {

        guard totalAnswers > 0 else {
            accuracy = 0
            return
        }

        accuracy = Int(Double(correctAnswers) / Double(totalAnswers) * 100)
    }

    private func updateProgressText() {
        progressText = "XP: \(xp) • \(accuracy)%"
    }

    // MARK: - Finish

    private func finish() {
        isFinished = true
        storage.save(progressMap)   // ✅ сохраняем
    }
    
    func restart() {

        correctAnswers = 0
        totalAnswers = 0
        xp = 0
        accuracy = 0
        isFinished = false
        answerState = .idle

        currentQuestion = nil
        progressText = ""

        loadNextQuestion()
    }
}
