//
//  LetterTileView.swift
//  España
//

import Foundation
import SwiftUI

struct LetterTileView: View {

    let tile: LetterTile
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {

        Button(action: action) {
            Text(displayText)
                .font(.system(size: 20, weight: .bold))
                .frame(width: 44, height: 44)
                .background(backgroundColor)
                .foregroundColor(.black)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
        }
    }

    private var displayText: String {
        tile.character == " " ? "␣" : String(tile.character).uppercased()
    }
}
