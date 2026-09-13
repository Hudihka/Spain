//
//  LetterSlotView.swift
//  España
//

import Foundation
import SwiftUI

/// Пустая или заполненная ячейка под одну букву собираемого слова.
struct LetterSlotView: View {

    let character: Character?
    let backgroundColor: Color
    var action: (() -> Void)? = nil

    var body: some View {

        ZStack {

            if let character {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )

                Text(character == " " ? "␣" : String(character).uppercased())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.gray.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
            }
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}
