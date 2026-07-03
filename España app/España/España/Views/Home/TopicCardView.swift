//
//  TopicCardView.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI

struct TopicCardView: View {

    let topic: Topic
    let quizMode: QuizMode

    @AppStorage("quizMode")
    private var quizModeRaw = QuizMode.spanishToRussian.rawValue

    @State
    private var isActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(topic.title)
                    .foregroundColor(.black)
                    .font(.headline)
                Spacer()
                Text("\(topic.words.count) слов")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            HStack(spacing: 12) {
                NavigationLink {
                    QuizView(
                        topic: topic,
                        mode: quizMode
                    )
                } label: {
                    HStack {
                        Text("Продолжить")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.blue)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.08))
                    .cornerRadius(12)
                }

                NavigationLink {
                    VocabularyView(
                        topic: topic,
                        mode: quizMode
                    )
                } label: {
                    Image(systemName: "book.closed.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                        .frame(width: 48, height: 48)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 8)
        .onLongPressGesture {
            withAnimation {
                isActive.toggle()
            }
        }
    }
}
