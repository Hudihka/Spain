//
//  ResultView.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI

struct ResultView: View {

    let xp: Int
    let accuracy: Int

    var onRestart: (() -> Void)? = nil

    var body: some View {

        VStack(spacing: 20) {

            Text("🎉 Отлично!")
                .font(.largeTitle)
                .bold()

            Text("XP: \(xp)")
                .font(.title2)

            Text("Точность: \(accuracy)%")
                .foregroundColor(.gray)

            Button("Пройти заново") {
                onRestart?()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
    }
}
