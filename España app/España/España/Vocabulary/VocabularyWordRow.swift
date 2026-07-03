//
//  VocabularyWordRow.swift
//  España
//
//  Created by Konstantin I on 03.07.2026.
//

import Foundation
import SwiftUI

struct VocabularyWordRow: View {
    let word: Word
    let quizMode: QuizMode
    let displayMode: VocabularyDisplayMode

    @State private var isRevealed = false
    @State private var hideTask: DispatchWorkItem?

    private var firstText: String {
        switch quizMode {
        case .spanishToRussian:
            return word.spanish

        case .russianToSpanish:
            return word.russian
        }
    }

    private var secondText: String {
        switch quizMode {
        case .spanishToRussian:
            return word.russian

        case .russianToSpanish:
            return word.spanish
        }
    }

    private var shouldShowTranslation: Bool {
        displayMode == .shown || isRevealed
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text(firstText)
                .foregroundColor(.black)
                .font(.title3.bold())

            if shouldShowTranslation {

                Text(secondText)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)

            } else {

                Text("Нажмите, чтобы показать")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 8)
        .contentShape(Rectangle())
        .onTapGesture {

            guard displayMode == .hidden else {
                return
            }

            revealTemporarily()
        }
        .onDisappear {
            hideTask?.cancel()
        }
    }

    private func revealTemporarily() {

        hideTask?.cancel()

        withAnimation(.easeInOut(duration: 0.2)) {
            isRevealed = true
        }

        let task = DispatchWorkItem {

            withAnimation(.easeInOut(duration: 0.2)) {
                isRevealed = false
            }
        }

        hideTask = task

        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: task)
    }
}
