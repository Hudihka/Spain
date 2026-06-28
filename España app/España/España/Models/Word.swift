//
//  Models.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation

struct Word: Identifiable, Codable, Hashable {
    let id: String
    let spanish: String
    let russian: String

    init(
        id: String,
        spanish: String,
        russian: String
    ) {
        self.id = id
        self.spanish = spanish
        self.russian = russian
    }
}
