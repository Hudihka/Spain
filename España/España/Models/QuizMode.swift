//
//  QuizMode.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation

enum QuizMode: String, Codable, CaseIterable, Identifiable {

    case spanishToRussian

    case russianToSpanish

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .spanishToRussian:
            return "Испанский → Русский"

        case .russianToSpanish:
            return "Русский → Испанский"
        }
    }
}
