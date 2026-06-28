//
//  UserProgressStorage.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation

final class UserProgressStorage {
    static let shared = UserProgressStorage()
    private let defaults = UserDefaults.standard
    private let key = "user_progress_storage"

    private init() {}

    func load() -> [String: LearningProgress] {
        guard let data = defaults.data(forKey: key) else {
            return [:]
        }

        do {
            let decoded = try JSONDecoder().decode([String: LearningProgress].self, from: data)
            return decoded
        } catch {
            print("❌ Progress decode error:", error)
            return [:]
        }
    }

    func save(_ progress: [String: LearningProgress]) {
        do {
            let data = try JSONEncoder().encode(progress)
            defaults.set(data, forKey: key)
        } catch {
            print("❌ Progress save error:", error)
        }
    }

    func reset() {
        defaults.removeObject(forKey: key)
    }
}
