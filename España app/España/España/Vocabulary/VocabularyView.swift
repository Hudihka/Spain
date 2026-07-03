//
//  VocabularyView.swift
//  España
//
//  Created by Konstantin I on 03.07.2026.
//

import Foundation
import SwiftUI

struct VocabularyView: View {

    let topic: Topic
    let mode: QuizMode

    @State private var displayMode: VocabularyDisplayMode = .hidden

    var body: some View {

        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.12),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {

                Text(topic.title)
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker("", selection: $displayMode) {

                    ForEach(VocabularyDisplayMode.allCases) { mode in

                        Text(mode.title)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                ScrollView {

                    LazyVStack(spacing: 12) {

                        ForEach(topic.words) { word in

                            VocabularyWordRow(
                                word: word,
                                quizMode: mode,
                                displayMode: displayMode
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
