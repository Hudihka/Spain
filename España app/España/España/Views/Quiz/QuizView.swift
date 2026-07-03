//
//  QuizView.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI

struct QuizView: View {

    private let topic: Topic
    @StateObject private var store = ProgressStore()
    @StateObject private var vm: QuizViewModel

    init(topic: Topic) {
        self.topic = topic
        _vm = StateObject(wrappedValue: QuizViewModel(topic: topic))
    }


    var body: some View {

        ZStack {

            background

            VStack(spacing: 20) {

                header

                if vm.isFinished {
                    ResultView(
                        words: vm.countWords,
                        procent: vm.procent,
                        onRestart: {
                            store.reset(topic: topic)
                            vm.restart()
                        }
                    )
                } else {
                    questionView
                    optionsView
                }

                Spacer()
            }
            .padding()
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.15), Color.white],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {

        VStack(spacing: 10) {

            ProgressBar(value: Double(vm.progressView))

            Text(vm.progressText)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private var questionView: some View {

        Text(vm.currentQuestion?.prompt ?? "")
            .font(.system(size: 34, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(.top, 20)
            .transition(.scale)
    }

    private var optionsView: some View {

        VStack(spacing: 12) {

            ForEach(vm.currentQuestion?.options ?? [], id: \.self) { option in

                AnswerButton(
                    title: option,
                    state: buttonState(for: option)
                ) {
                    vm.selectAnswer(option)
                }
            }
        }
        .animation(.spring(), value: vm.answerState)
    }

    private func buttonState(for option: String) -> AnswerButton.ButtonState {

        switch vm.answerState {

        case .idle:
            return .normal

        case .correct:
            if option == vm.currentQuestion?.correctAnswer {
                return .correct
            }
            return .disabled

        case .incorrect(let selected):

            if option == selected {
                return .incorrect
            }

            if option == vm.currentQuestion?.correctAnswer {
                return .correct
            }

            return .disabled
        }
    }
}
