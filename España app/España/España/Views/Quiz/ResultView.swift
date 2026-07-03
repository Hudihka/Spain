//
//  ResultView.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI

struct ResultView: View {

    let words: Int
    let procent: Int

    var onRestart: (() -> Void)? = nil

    var body: some View {

        VStack(spacing: 20) {

            Text("🎉 Отлично!")
                .foregroundColor(.black)
                .font(.largeTitle)
                .bold()

            Text("Количество слов: \(words)")
                .foregroundColor(.black)
                .font(.title2)

            Text("Точность: \(procent)%")
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
