//
//  SpellingView.swift
//  España
//

import Foundation
import SwiftUI

struct SpellingView: View {

    @StateObject private var vm: SpellingViewModel

    init(topic: Topic) {
        _vm = StateObject(wrappedValue: SpellingViewModel(topic: topic))
    }

    var body: some View {

        ZStack {

            background

            VStack(spacing: 20) {

                header

                if vm.countWords == 0 {
                    emptyState
                } else if vm.isFinished {
                    ResultView(
                        words: vm.countWords,
                        procent: vm.accuracyPercent,
                        onRestart: {
                            vm.restart()
                        }
                    )
                } else {
                    promptView
                    assembledRow
                    Spacer()
                    availableGrid
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Собери слово")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var background: some View {
        LinearGradient(
            colors: [Color.purple.opacity(0.14), Color.white],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {

        VStack(spacing: 10) {
            ProgressBar(value: vm.progressValue)

            Text(vm.progressText)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private var emptyState: some View {
        Text("Для этой темы пока нет слов, подходящих для этого режима")
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding()
    }

    private var promptView: some View {
        Text(vm.promptText)
            .font(.system(size: 30, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(.top, 10)
            .transition(.scale)
    }

    private var assembledRow: some View {
        LazyVGrid(columns: gridColumns, spacing: 10) {
            ForEach(vm.assembledTiles) { tile in
                LetterTileView(tile: tile, backgroundColor: assembledColor) {
                    vm.removeAssembled(tile)
                }
            }
        }
        .frame(minHeight: 56)
        .animation(.spring(), value: vm.assembledTiles)
    }

    private var availableGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 10) {
            ForEach(vm.availableTiles) { tile in
                LetterTileView(tile: tile, backgroundColor: .white) {
                    vm.selectAvailable(tile)
                }
            }
        }
        .animation(.spring(), value: vm.availableTiles)
    }

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 44), spacing: 10)]
    }

    private var assembledColor: Color {
        switch vm.state {
        case .idle:
            return .white
        case .success:
            return Color.green.opacity(0.3)
        case .failure:
            return Color.red.opacity(0.3)
        }
    }
}
