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

    @StateObject private var vm = TopicListViewModel()

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
                    .padding(.horizontal, 16)

                    ScrollView {

                        VStack(spacing: 14) {

                            allWordsCard

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

    private var allWordsCard: some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("🧠 Все слова")
                    .foregroundColor(.black)
                    .font(.headline)
                Spacer()
                Text("\(vm.allWordsTopic.words.count) слов")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            HStack(spacing: 12) {

                NavigationLink {
                    QuizView(topic: vm.allWordsTopic, mode: quizMode)
                } label: {
                    Label("Тест", systemImage: "questionmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }

                NavigationLink {
                    SpellingView(topic: vm.allWordsTopic)
                } label: {
                    Label("Буквы", systemImage: "textformat.abc")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
            }
            .foregroundColor(.white)
            .background(Color.white.opacity(0.18))
            .cornerRadius(12)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.12), radius: 8)
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

        HStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 6) {

                Text("🇪🇸 Лучше чем ваша платформа")
                    .font(.largeTitle)
                    .bold()

                Text("Учи испанский, что бы встречаться с латинкой")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink {
                StatisticsView(topics: vm.topics)
            } label: {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }
}
