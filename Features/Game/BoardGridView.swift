import SwiftUI
import UniformTypeIdentifiers

struct BoardGridView: View {
    let puzzle: Puzzle
    let placedTiles: [GridCoordinate: NumberTile]
    let incorrectCoordinates: Set<GridCoordinate>
    let dragPayloadProvider: (NumberTile) -> String
    let onTileDropped: (String, GridCoordinate) -> Bool
    let onClearPlacement: (GridCoordinate) -> Void

    private let cellSize: CGFloat = 44

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<puzzle.gridHeight, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<puzzle.gridWidth, id: \.self) { column in
                        let coordinate = GridCoordinate(row: row, column: column)
                        cellView(at: coordinate)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func cellView(at coordinate: GridCoordinate) -> some View {
        if let cell = puzzle.cell(at: coordinate) {
            let placedTile = placedTiles[coordinate]
            let allowsDrop = cell.type == .emptySlot

            BoardCellView(
                cell: cell,
                placedTile: placedTile,
                cellSize: cellSize,
                dragPayloadProvider: dragPayloadProvider,
                onClearPlacement: { onClearPlacement(coordinate) },
                isIncorrect: incorrectCoordinates.contains(coordinate)
            )
            .contentShape(Rectangle())
            .dropDestination(for: String.self) { items, _ in
                guard allowsDrop, let payload = items.first else { return false }
                return onTileDropped(payload, coordinate)
            }
        } else {
            Color.clear
                .frame(width: cellSize, height: cellSize)
        }
    }
}

private struct BoardCellView: View {
    let cell: GridCell
    let placedTile: NumberTile?
    let cellSize: CGFloat
    let dragPayloadProvider: (NumberTile) -> String
    let onClearPlacement: () -> Void
    let isIncorrect: Bool

    var body: some View {
        Group {
            switch cell.type {
            case .blocked:
                Color.clear
            case let .fixedNumber(value):
                cellBackground(text: "\(value)", textWeight: .bold)
            case let .operator(operatorType):
                cellBackground(text: operatorType.symbol)
            case .equals:
                cellBackground(text: "=")
            case .emptySlot:
                emptySlotContent
            }
        }
        .frame(width: cellSize, height: cellSize)
    }

    @ViewBuilder
    private var emptySlotContent: some View {
        if let placedTile {
            TilePillView(title: "\(placedTile.value)", tintColor: isIncorrect ? .red : .blue)
                .draggable(dragPayloadProvider(placedTile))
                .onTapGesture(perform: onClearPlacement)
        } else {
            cellBackground(text: "?", textColor: .secondary)
        }
    }

    private func cellBackground(text: String, textColor: Color = .primary, textWeight: Font.Weight = .semibold) -> some View {
        Text(text)
            .font(.title3.weight(textWeight))
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.separator), lineWidth: 1)
            )
    }
}

struct TilePillView: View {
    let title: String
    var tintColor: Color = .blue

    var body: some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .foregroundStyle(tintColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(tintColor, lineWidth: 2)
            )
    }
}
