import SwiftUI

struct NumberBankView: View {
    let tiles: [GameViewModel.NumberTile]
    let shuffleAction: () -> Void
    let tileLabel: (GameViewModel.NumberTile) -> String

    private let columns = [
        GridItem(.flexible(minimum: 44), spacing: 8),
        GridItem(.flexible(minimum: 44), spacing: 8),
        GridItem(.flexible(minimum: 44), spacing: 8),
        GridItem(.flexible(minimum: 44), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(LocalizedStringKey("bank"))
                    .font(.headline)
                Spacer()
                Button(action: shuffleAction) {
                    Label(LocalizedStringKey("shuffle"), systemImage: "shuffle")
                }
                .disabled(tiles.count <= 1)
            }

            if tiles.isEmpty {
                Text(NSLocalizedString("bank_empty", comment: "Bank empty"))
                    .foregroundColor(.secondary)
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(tiles) { tile in
                        Text("\(tile.value)")
                            .font(.headline)
                            .frame(minHeight: 48)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.4), lineWidth: 1)
                            )
                            .draggable(tile)
                            .accessibilityLabel(tileLabel(tile))
                    }
                }
            }
        }
    }
}
