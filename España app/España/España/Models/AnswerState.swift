//
//  AnswerState.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation

enum AnswerState: Equatable {
    case idle
    case correct
    case incorrect(selected: String)
}
