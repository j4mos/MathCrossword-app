import SwiftUI

struct NumberPoolView: View {
    let pool: [NumberTileState]
    let onTap: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(pool) { tile in
                    if tile.remainingUses > 0 {
                        NumberTileView(tile: tile)
                            .onTapGesture {
                                onTap(tile.value)
                            }
                            .draggable("\(tile.value)")
                            .allowsHitTesting(true)
                    } else {
                        NumberTileView(tile: tile)
                            .opacity(0.4)
                            .allowsHitTesting(false)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct NumberTileView: View {
    let tile: NumberTileState

    var body: some View {
        VStack(spacing: 4) {
            Text("\(tile.value)")
                .font(.headline)
                .frame(minWidth: 36, minHeight: 36)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Text("x\(tile.remainingUses)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
