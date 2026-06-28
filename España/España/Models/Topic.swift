//
//  Topic.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation

struct Topic: Identifiable, Codable {
    let id: String
    let title: String
    let words: [Word]

    init(
        id: String,
        title: String,
        words: [Word]
    ) {

        self.id = id
        self.title = title
        self.words = words
    }
}
