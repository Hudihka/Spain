//
//  TopicListViewModel.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI
import Combine

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
}
