//
//  TopicCardView.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI
import SwiftUI

struct TopicCardView: View {

    let topic: Topic

    @State private var isActive = false
    @StateObject private var store = ProgressStore()

    var body: some View {

        NavigationLink(destination: QuizView(topic: topic)) {

            VStack(alignment: .leading, spacing: 10) {

                HStack {

                    Text(topic.title)
                        .font(.headline)
                        .foregroundColor(.black) // 🔥 фикс: защита от invisible text

                    Spacer()

                    Text("\(topic.words.count) слов")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                HStack {

                    Text("Продолжить")
                        .font(.subheadline)
                        .foregroundColor(.blue)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white) // 🔥 фикс: стабильный background
            .clipShape(RoundedRectangle(cornerRadius: 18)) // 🔥 вместо cornerRadius
            .shadow(color: .black.opacity(0.08), radius: 8)
        }
        .buttonStyle(.plain)
        .onLongPressGesture {
            withAnimation {
                isActive.toggle()
            }
        }
    }
}
