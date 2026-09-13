//
//  TopicListViewModel.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class TopicListViewModel: ObservableObject {
    @Published var topics: [Topic] = []

    init() {
        loadTopics()
    }

    private func loadTopics() {
        topics = VocabularyLoader.shared.loadTopics()
    }

    var allWordsTopic: Topic {
        Topic(
            id: "all",
            title: "Все слова",
            words: topics.flatMap { $0.words }
        )
    }

    /// Темы, отсортированные по тому, насколько активно с ними занимались —
    /// сверху те, где больше всего попыток (правильных и неправильных ответов).
    var sortedTopics: [Topic] {
        let store = WordProgressStore.shared

        func interactions(in topic: Topic) -> Int {
            topic.words.reduce(0) { total, word in
                let progress = store.progress(for: word)
                return total + progress.correctCount + progress.wrongCount
            }
        }

        return topics
            .enumerated()
            .sorted { lhs, rhs in
                let lhsCount = interactions(in: lhs.element)
                let rhsCount = interactions(in: rhs.element)

                if lhsCount != rhsCount {
                    return lhsCount > rhsCount
                }

                // При равенстве — сохраняем исходный порядок тем.
                return lhs.offset < rhs.offset
            }
            .map { $0.element }
    }
}
