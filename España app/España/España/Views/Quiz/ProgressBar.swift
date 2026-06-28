//
//  ProgressBar.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import Foundation
import SwiftUI

struct ProgressBar: View {

    let value: Double

    var body: some View {

        GeometryReader { geo in

            ZStack(alignment: .leading) {

                Rectangle()
                    .frame(height: 10)
                    .foregroundColor(Color.gray.opacity(0.2))

                Rectangle()
                    .frame(width: geo.size.width * value, height: 10)
                    .foregroundColor(.blue)
                    .animation(.spring(), value: value)
            }
            .cornerRadius(10)
        }
        .frame(height: 10)
    }
}
