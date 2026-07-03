//
//  VocabularyDisplayMode.swift
//  España
//
//  Created by Konstantin I on 03.07.2026.
//

import Foundation
enum VocabularyDisplayMode: String, CaseIterable, Identifiable {
    case hidden
    case shown

    var id: String {
        rawValue
    }

    var title: String {
        switch self {

        case .hidden:
            return "Скрыть"

        case .shown:
            return "Показать"
        }
    }
}
