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

                    if vm.state == .revealed {
                        Text("Вот правильный ответ")
                            .font(.title2.bold())
                            .foregroundColor(.blue)
                    }

                    slotsRow

                    if vm.state == .success || vm.state == .revealed {
                        nextWordButton
                            .padding(.top, 16)
                    } else if !vm.assembledTiles.isEmpty && vm.state == .idle {
                        resetButton
                            .padding(.top, 16)
                    }

                    Spacer()

                    availableTilesArea
                        .frame(height: reservedTilesHeight, alignment: .top)
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
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            .transition(.scale)
    }

    private var slotsRow: some View {
        FlowLayout(spacing: 8, lineSpacing: 8) {
            ForEach(0..<vm.targetLength, id: \.self) { index in
                if index < vm.assembledTiles.count {
                    let tile = vm.assembledTiles[index]
                    LetterSlotView(character: tile.character, backgroundColor: assembledColor) {
                        vm.removeAssembled(tile)
                    }
                } else {
                    LetterSlotView(character: nil, backgroundColor: .white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(), value: vm.assembledTiles)
    }

    private var resetButton: some View {
        Button {
            vm.resetCurrentWord()
        } label: {
            Label("Начать заново", systemImage: "arrow.counterclockwise")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.orange)
                .clipShape(Capsule())
                .shadow(color: Color.orange.opacity(0.35), radius: 8, y: 4)
        }
    }

    private var availableTilesArea: some View {
        FlowLayout(spacing: 10, lineSpacing: 10) {
            ForEach(vm.availableTiles) { tile in
                LetterTileView(tile: tile, backgroundColor: .white) {
                    vm.selectAvailable(tile)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .animation(.spring(), value: vm.availableTiles)
    }

    private var nextWordButton: some View {
        Button {
            vm.proceedToNextWord()
        } label: {
            Label("Дальше", systemImage: "arrow.right.circle.fill")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(vm.state == .success ? Color.green : Color.blue)
                .clipShape(Capsule())
                .shadow(color: (vm.state == .success ? Color.green : Color.blue).opacity(0.35), radius: 8, y: 4)
        }
    }

    // Резервируем высоту под буквы исходя из длины ТЕКУЩЕГО слова, чтобы
    // блок не "съезжал" по мере того, как буквы разбираются на слоты.
    private var reservedTilesHeight: CGFloat {
        let itemSize: CGFloat = 44
        let spacing: CGFloat = 10
        let assumedRowWidth: CGFloat = 340

        let perRow = max(Int((assumedRowWidth + spacing) / (itemSize + spacing)), 1)
        let rows = max(Int(ceil(Double(vm.targetLength) / Double(perRow))), 1)

        return CGFloat(rows) * itemSize + CGFloat(max(rows - 1, 0)) * spacing
    }

    private var assembledColor: Color {
        switch vm.state {
        case .idle:
            return .white
        case .success:
            return Color.green.opacity(0.3)
        case .failure:
            return Color.red.opacity(0.3)
        case .revealed:
            return Color.blue.opacity(0.25)
        }
    }
}
