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
    @Published var progressView: Double = 0
    @Published var isFinished: Bool = false
    

    // MARK: - Private
    
    private var isLocked = false

    private let topic: Topic
    private let mode: QuizMode

    private var allWords: Set<Word>
    private var rightsWords: Set<Word> = []

    private var correctAnswers = 0
    private var allAnswers = 0
    private var wrongAnswers = 0

    var procent: Int {
        guard allAnswers != 0 else { return 0 }
        
        return Int(100 * Double(correctAnswers)/Double(allAnswers))
    }
    
    var countWords: Int {
        allWords.count
    }
    // MARK: - Init

    init(topic: Topic, mode: QuizMode = .spanishToRussian) {
        self.topic = topic
        self.allWords = Set(topic.words)
        self.mode = mode

        loadNextQuestion()
    }

    // MARK: - Setup

    // MARK: - Next question

    func loadNextQuestion() {

        let availableWords = getAvailableWords()

        guard let word = availableWords.randomElement() else {
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

        updateProgress()
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

    // вопросы на которые не ответили
    private func getAvailableWords() -> Set<Word> {
        allWords.subtracting(rightsWords)
    }

    private func selectNextWord(from list: [Word]) -> Word? {
        list.randomElement()
    }

    // MARK: - Options

    private func makeOptions(correct: String) -> [String] {
        var pool = allWords.map {
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

        let isCorrect = answer == question.correctAnswer

        if isCorrect {
            rightsWords.insert(question.word)
            correctAnswers += 1
            answerState = .correct

            HapticManager.shared.success()
            AudioManager.shared.success()
        } else {
            wrongAnswers += 1
            answerState = .incorrect(selected: answer)

            HapticManager.shared.error()
            AudioManager.shared.error()
        }
        
        allAnswers += 1

        updateProgress()

        let delay: Double = isCorrect ? 0.3 : 1.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.answerState = .idle
            self.loadNextQuestion()
            self.isLocked = false
        }
    }

    // MARK: - Stats

    private func updateProgress() {
        progressText = "Правильно \(correctAnswers) из \(allAnswers), \(procent)%"
        
        progressView = Double(correctAnswers)/Double(allWords.count)
    }

    // MARK: - Finish

    private func finish() {
        isFinished = true
    }
    
    func restart() {

        correctAnswers = 0
        allAnswers = 0
        wrongAnswers = 0
        isFinished = false
        answerState = .idle

        currentQuestion = nil
        progressText = ""

        loadNextQuestion()
    }
}
