//
//  SpanishTrainerApp.swift
//  España
//
//  Created by Konstantin I on 28.06.2026.
//

import SwiftUI

@main
struct SpanishTrainerApp: App {
    @State private var isReady = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isReady {
                    TopicListView()
                } else {
                    SplashView()
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(1500))
                isReady = true
            }
        }
    }
}


struct SplashView: View {
    var body: some View {
        GeometryReader { geometry in
            Image("latin")
                .resizable()
                .scaledToFill()
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .clipped()
        }
        .ignoresSafeArea()
    }
}
