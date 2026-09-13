//
//  StatisticsView.swift
//  España
//

import Foundation
import SwiftUI

struct StatisticsView: View {

    let topics: [Topic]

    @ObservedObject private var store = WordProgressStore.shared

    private var allWords: [Word] {
        topics.flatMap { $0.words }
    }

    private var totalWords: Int {
        allWords.count
    }

    private var mastered: Int {
        store.masteredCount(for: allWords)
    }

    private var newWords: Int {
        store.newCount(for: allWords)
    }

    private var learning: Int {
        max(totalWords - mastered - newWords, 0)
    }

    private var accuracy: Int {
        let correct = store.totalCorrect(for: allWords)
        let wrong = store.totalWrong(for: allWords)
        let total = correct + wrong

        guard total > 0 else { return 0 }

        return Int(100 * Double(correct) / Double(total))
    }

    private var hardestWords: [(word: Word, progress: WordProgress)] {
        store.hardestWords(from: allWords, limit: 10)
    }

    // Темы, по которым уже есть хоть какой-то прогресс — темы без единой
    // попытки в списке не показываем, чтобы не плодить пустые строки "0/N".
    private var startedTopics: [Topic] {
        topics.filter { topic in
            topic.words.contains { !store.progress(for: $0).isNew }
        }
    }

    var body: some View {

        ZStack {

            background

            ScrollView {

                VStack(spacing: 20) {
                    streakCard
                    summaryGrid

                    if !hardestWords.isEmpty {
                        hardestSection
                    }

                    if !startedTopics.isEmpty {
                        topicsSection
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Статистика")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var background: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.12), Color.white],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var streakCard: some View {

        HStack {

            VStack(alignment: .leading, spacing: 4) {
                Text("🔥 Серия дней")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("\(store.streakDays)")
                    .font(.system(size: 34, weight: .bold))
            }

            Spacer()
        }
        .padding()
        .background(.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.08), radius: 8)
    }

    private var summaryGrid: some View {

        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            statTile(title: "Всего слов", value: "\(totalWords)", color: .blue)
            statTile(title: "Новые", value: "\(newWords)", color: .gray)
            statTile(title: "В процессе", value: "\(learning)", color: .orange)
            statTile(title: "Выучено", value: "\(mastered)", color: .green)
            statTile(title: "Точность", value: "\(accuracy)%", color: .purple)
        }
    }

    private func statTile(title: String, value: String, color: Color) -> some View {

        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title.bold())
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6)
    }

    private var hardestSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text("Сложные слова")
                .font(.headline)

            ForEach(hardestWords, id: \.word.id) { entry in

                HStack {

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.word.spanish)
                            .font(.body.bold())

                        Text(entry.word.russian)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text("\(entry.progress.wrongCount) ошибок")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding()
                .background(.white)
                .cornerRadius(14)
            }
        }
    }

    private var topicsSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text("По темам")
                .font(.headline)

            ForEach(startedTopics) { topic in

                let topicMastered = store.masteredCount(for: topic.words)

                HStack {
                    Text(topic.title)
                        .font(.subheadline)

                    Spacer()

                    Text("\(topicMastered)/\(topic.words.count)")
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                }
                .padding()
                .background(.white)
                .cornerRadius(14)
            }
        }
    }
}
