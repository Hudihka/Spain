//
//  VocabularyLoader.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation

import Foundation

final class VocabularyLoader {

    static let shared = VocabularyLoader()

    private init() {}

    func loadTopics() -> [Topic] {
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json") else {
            print("❌ vocabulary.json not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let topics = try decoder.decode([Topic].self, from: data)
            return topics
        } catch {
            print("❌ Failed to decode vocabulary:", error)
            return []
        }
    }
}
