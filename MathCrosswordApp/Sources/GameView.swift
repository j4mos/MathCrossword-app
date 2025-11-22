import SwiftUI
import MathCrosswordEngine

struct GameView: View {
    @StateObject private var viewModel: GameViewModel

    init(difficulty: DifficultyProfile) {
        _viewModel = StateObject(wrappedValue: GameViewModel(difficulty: difficulty))
    }

    @State private var gridScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(viewModel.level.difficulty.displayName)
                    .font(.headline)
                Spacer()
                HStack(spacing: 12) {
                    Text("Ready: \(viewModel.numberPoolState.reduce(0) { $0 + max($1.remainingUses, 0) })")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        Button(action: { withAnimation { gridScale = max(0.6, gridScale - 0.1) } }) {
                            Image(systemName: "minus.magnifyingglass")
                        }
                        Button(action: { withAnimation { gridScale = min(2.0, gridScale + 0.1) } }) {
                            Image(systemName: "plus.magnifyingglass")
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)

            ScrollView([.horizontal, .vertical]) {
                GridView(cells: viewModel.cells, equationStates: viewModel.equationStates, onClear: { position in
                    viewModel.clearNumber(at: position)
                }, onDropNumber: { value, position in
                    viewModel.placeNumber(value, at: position)
                })
                .scaleEffect(gridScale, anchor: .topLeading)
                .padding(.horizontal)
            }

            NumberPoolView(pool: viewModel.numberPoolState) { value in
                // Drop handler is implemented in GridCellView via onDrop; here we allow a fallback tap-to-place on first empty slot.
                if let empty = viewModel.cells.first(where: { $0.type == .emptyOperand && $0.currentValue == nil })?.position {
                    viewModel.placeNumber(value, at: empty)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .overlay(alignment: .center) {
            if viewModel.isLevelCompleted {
                LevelCompleteOverlay {
                    viewModel.restart()
                }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(difficulty: .class1)
    }
}
