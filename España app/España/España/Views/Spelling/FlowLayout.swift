//
//  FlowLayout.swift
//  España
//

import Foundation
import SwiftUI

/// Раскладка, которая переносит элементы на новую строку при нехватке ширины
/// и центрирует каждую строку по горизонтали.
struct FlowLayout: Layout {

    var spacing: CGFloat = 10
    var lineSpacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {

        let width = proposal.width ?? .infinity
        let rows = computeRows(maxWidth: width, subviews: subviews)

        let height = rows.reduce(0) { $0 + $1.maxHeight } + lineSpacing * CGFloat(max(rows.count - 1, 0))
        let usedWidth = rows.map { $0.width }.max() ?? 0

        return CGSize(width: min(usedWidth, width), height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {

        let rows = computeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY

        for row in rows {

            var x = bounds.minX + (bounds.width - row.width) / 2

            for item in row.items {

                item.subview.place(
                    at: CGPoint(x: x, y: y + (row.maxHeight - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )

                x += item.size.width + spacing
            }

            y += row.maxHeight + lineSpacing
        }
    }

    private struct Item {
        let subview: LayoutSubview
        let size: CGSize
    }

    private struct Row {
        var items: [Item] = []
        var width: CGFloat = 0
        var maxHeight: CGFloat = 0
    }

    private func computeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {

        var rows: [Row] = []
        var current = Row()

        for subview in subviews {

            let size = subview.sizeThatFits(.unspecified)

            if !current.items.isEmpty, current.width + spacing + size.width > maxWidth {
                rows.append(current)
                current = Row()
            }

            current.items.append(Item(subview: subview, size: size))
            current.width += (current.items.count > 1 ? spacing : 0) + size.width
            current.maxHeight = max(current.maxHeight, size.height)
        }

        if !current.items.isEmpty {
            rows.append(current)
        }

        return rows
    }
}
