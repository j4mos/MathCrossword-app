import SwiftUI
import UniformTypeIdentifiers

struct GameView: View {
    let puzzle: Puzzle

    @State private var availableTiles: [NumberTile]
    @State private var placedTiles: [GridCoordinate: NumberTile]

    private let tileIdentifierPrefix = "mathcrossword-tile-"

    init(puzzle: Puzzle) {
        self.puzzle = puzzle
        _availableTiles = State(initialValue: puzzle.availableNumbers.map { NumberTile(value: $0) })
        _placedTiles = State(initialValue: [:])
    }

    private var validationResult: PuzzleValidationResult {
        PuzzleValidator.evaluate(puzzle: puzzle, placedTiles: placedTiles)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                BoardGridView(
                    puzzle: puzzle,
                    placedTiles: placedTiles,
                    incorrectCoordinates: validationResult.incorrectCoordinates,
                    dragPayloadProvider: dragPayload(for:),
                    onTileDropped: handleBoardDrop(_:coordinate:),
                    onClearPlacement: clearPlacement(at:)
                )

                validationBanner

                NumberBankView(
                    tiles: availableTiles,
                    dragPayloadProvider: dragPayload(for:),
                    onTileDropped: handleBankDrop(_:)
                )
            }
            .padding()
        }
        .navigationTitle(puzzle.gradeLevel.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func dragPayload(for tile: NumberTile) -> String {
        "\(tileIdentifierPrefix)\(tile.id.uuidString)"
    }

    private func handleBoardDrop(_ payload: String, coordinate: GridCoordinate) -> Bool {
        guard let tileID = decodeTileID(from: payload) else { return false }
        withAnimation {
            placeTile(tileID: tileID, at: coordinate)
        }
        return true
    }

    private func handleBankDrop(_ payload: String) -> Bool {
        guard let tileID = decodeTileID(from: payload) else { return false }
        withAnimation {
            returnTileToBank(tileID: tileID)
        }
        return true
    }

    private func clearPlacement(at coordinate: GridCoordinate) {
        guard let tile = placedTiles.removeValue(forKey: coordinate) else { return }
        insertTileIntoBank(tile)
    }

    private func placeTile(tileID: UUID, at coordinate: GridCoordinate) {
        guard let tile = takeTile(withId: tileID) else { return }
        if let displaced = placedTiles[coordinate] {
            insertTileIntoBank(displaced)
        }
        placedTiles[coordinate] = tile
    }

    private func returnTileToBank(tileID: UUID) {
        guard let tile = takeTile(withId: tileID) else { return }
        insertTileIntoBank(tile)
    }

    private func insertTileIntoBank(_ tile: NumberTile) {
        availableTiles.append(tile)
        availableTiles.sort { $0.value < $1.value }
    }

    @discardableResult
    private func takeTile(withId id: UUID) -> NumberTile? {
        if let index = availableTiles.firstIndex(where: { $0.id == id }) {
            return availableTiles.remove(at: index)
        }

        if let entry = placedTiles.first(where: { $0.value.id == id }) {
            return placedTiles.removeValue(forKey: entry.key)
        }

        return nil
    }

    private func decodeTileID(from string: String) -> UUID? {
        guard string.hasPrefix(tileIdentifierPrefix) else { return nil }
        let idString = String(string.dropFirst(tileIdentifierPrefix.count))
        return UUID(uuidString: idString)
    }

    @ViewBuilder
    private var validationBanner: some View {
        if validationResult.isSolved {
            ValidationMessageView(
                systemImage: "checkmark.seal.fill",
                text: "Great job! All equations are correct.",
                tint: .green
            )
        } else if validationResult.hasIncorrectPlacements {
            ValidationMessageView(
                systemImage: "exclamationmark.triangle.fill",
                text: "Some equations are incorrect. Adjust the highlighted tiles.",
                tint: .red
            )
        }
    }
}

private struct NumberBankView: View {
    let tiles: [NumberTile]
    let dragPayloadProvider: (NumberTile) -> String
    let onTileDropped: (String) -> Bool

    private let columns = [GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Number Bank")
                .font(.headline)
            if tiles.isEmpty {
                Text("All tiles placed — drag from the board to adjust.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(tiles) { tile in
                    TilePillView(title: "\(tile.value)")
                        .frame(height: 44)
                        .draggable(dragPayloadProvider(tile))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), style: StrokeStyle(lineWidth: 1, dash: [6]))
        )
        .dropDestination(for: String.self) { items, _ in
            guard let payload = items.first else { return false }
            return onTileDropped(payload)
        }
    }
}

private struct ValidationMessageView: View {
    let systemImage: String
    let text: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
            Text(text)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(tint.opacity(0.1))
        )
    }
}
