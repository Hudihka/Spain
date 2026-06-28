//
//  AnswerButton.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI

struct AnswerButton: View {

    enum ButtonState {
        case normal
        case correct
        case incorrect
        case disabled
    }

    let title: String
    let state: ButtonState
    let action: () -> Void

    @State private var shake = false

    var body: some View {

        Button(action: {
            action()

            if state == .incorrect {
                shake = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    shake = false
                }
            }

        }) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 2)
                )
        }
        .disabled(state != .normal)
        .scaleEffect(state == .normal ? 1.0 : 1.02)
        .offset(x: shake ? -8 : 0)
        .animation(.easeInOut(duration: 0.15), value: shake)
    }

    private var backgroundColor: Color {

        switch state {

        case .normal:
            return .white

        case .correct:
            return Color.green.opacity(0.2)

        case .incorrect:
            return Color.red.opacity(0.2)

        case .disabled:
            return Color.gray.opacity(0.1)
        }
    }

    private var borderColor: Color {

        switch state {

        case .normal:
            return Color.gray.opacity(0.3)

        case .correct:
            return .green

        case .incorrect:
            return .red

        case .disabled:
            return Color.gray.opacity(0.2)
        }
    }

    private var foregroundColor: Color {
        .black
    }
}
