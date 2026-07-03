//
//  TopicListView.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI
import Combine

struct TopicListView: View {
    
    @AppStorage("quizMode")
    private var quizModeRaw = QuizMode.spanishToRussian.rawValue

    private var quizMode: QuizMode {
        get { QuizMode(rawValue: quizModeRaw) ?? .spanishToRussian }
        set { quizModeRaw = newValue.rawValue }
    }

    private var vm = TopicListViewModel()

    var body: some View {

        NavigationStack {

            ZStack {

                background

                VStack(spacing: 16) {
                    header
                    Picker("", selection: $quizModeRaw) {
                        Text("🇪🇸 → 🇷🇺").tag(QuizMode.spanishToRussian.rawValue)
                        Text("🇷🇺 → 🇪🇸").tag(QuizMode.russianToSpanish.rawValue)
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 8)

                    ScrollView {

                        VStack(spacing: 14) {

                            ForEach(vm.topics) { topic in

                                TopicCardView(topic: topic, quizMode: quizMode)
                            }
                        }
                        .padding(.horizontal)
                    }

                }
                .padding(.top)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    private var background: some View {

        LinearGradient(
            colors: [
                Color.blue.opacity(0.12),
                Color.white
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {

        VStack(alignment: .leading, spacing: 6) {

            Text("🇪🇸 Лучше чем ваша платформа")
                .font(.largeTitle)
                .bold()

            Text("Учись испанский, что бы встречаться с латинкой")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}
