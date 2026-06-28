//
//  ConfettiView.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI

struct ConfettiView: View {

    @State private var animate = false

    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple]

    var body: some View {

        ZStack {

            ForEach(0..<30, id: \.self) { i in

                Circle()
                    .fill(colors[i % colors.count])
                    .frame(width: 8, height: 8)
                    .offset(
                        x: animate ? CGFloat.random(in: -150...150) : 0,
                        y: animate ? CGFloat.random(in: -300...300) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.2)
                        .delay(Double(i) * 0.02),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}
