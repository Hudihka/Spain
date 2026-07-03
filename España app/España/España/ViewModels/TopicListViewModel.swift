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
    var topics: [Topic] = []
    
    init() {
        loadTopics()
    }

    private func loadTopics() {
        topics = VocabularyLoader.shared.loadTopics()
    }
}
