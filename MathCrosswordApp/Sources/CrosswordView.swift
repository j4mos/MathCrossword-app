import MathCrosswordEngine
import SwiftUI

struct CrosswordView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        VStack(spacing: 24) {
            header
            boardSection
            NumberBankView(
                tiles: viewModel.availableTiles,
                shuffleAction: viewModel.shuffleBank,
                tileLabel: { viewModel.bankAnnouncement(for: $0) }
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .task {
            viewModel.startIfNeeded()
        }
        .alert(isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { isPresented in
                if !isPresented { viewModel.alertMessage = nil }
            }
        )) {
            Alert(
                title: Text("Hinweis"),
                message: Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey("timer"))
                    .font(.caption)
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
                Text(viewModel.timerText())
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.semibold)
                    .accessibilityLabel("\(NSLocalizedString("timer", comment: "Timer")) \(viewModel.timerText())")
            }

            Spacer()

            Button(action: viewModel.togglePause) {
                Label(
                    viewModel.isPaused ? NSLocalizedString("resume", comment: "Resume") : NSLocalizedString("pause", comment: "Pause"),
                    systemImage: viewModel.isPaused ? "play.fill" : "pause.fill"
                )
            }
            .disabled(viewModel.board == nil || viewModel.isLoading)

            Button(action: viewModel.restart) {
                Label(LocalizedStringKey("restart"), systemImage: "arrow.clockwise")
            }
            .disabled(viewModel.isLoading)
        }
    }

    private var boardSection: some View {
        ZStack {
            if let board = viewModel.board {
                boardGrid(board: board)
                    .padding(.top, 8)
                    .overlay(alignment: .topTrailing) {
                        if viewModel.isSolved {
                            Label(NSLocalizedString("solved", comment: "Solved"), systemImage: "checkmark.seal.fill")
                                .font(.headline)
                                .padding(8)
                                .background(Capsule().fill(Color.green.opacity(0.2)))
                                .padding(8)
                                .accessibilityAddTraits(.isStaticText)
                        }
                    }
            } else {
                ProgressView()
            }

            if viewModel.isLoading {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                ProgressView()
            }
        }
    }

    private func boardGrid(board: MCBoard) -> some View {
        let columns = Array(repeating: GridItem(.flexible(minimum: 28), spacing: 4), count: board.dim.cols)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<board.dim.rows, id: \.self) { row in
                ForEach(0..<board.dim.cols, id: \.self) { col in
                    let position = MCPos(r: row, c: col)
                    let cell = board.at(position)
                    CrosswordCellView(
                        cell: cell,
                        displayedValue: viewModel.displayValue(for: cell, at: position),
                        isConflict: viewModel.conflicts.contains(position),
                        placeAction: { tile in
                            viewModel.place(tile: tile, at: position)
                        },
                        removeAction: {
                            viewModel.removeValue(at: position)
                        },
                        accessibilityLabel: viewModel.accessibilityLabel(for: cell, at: position),
                        accessibilityHint: viewModel.accessibilityHint(for: cell)
                    )
                }
            }
        }
    }
}

private struct CrosswordCellView: View {
    let cell: MCCell
    let displayedValue: String?
    let isConflict: Bool
    let placeAction: (GameViewModel.NumberTile) -> Void
    let removeAction: () -> Void
    let accessibilityLabel: String
    let accessibilityHint: String?

    var body: some View {
        Group {
            switch cell {
            case .wall:
                Color.clear
            case .op(let op):
                Text(op.rawValue)
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5)))
                    .accessibilityLabel(accessibilityLabel)
            case .equals:
                Text("=")
                    .font(.title3.weight(.bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray4)))
                    .accessibilityLabel(accessibilityLabel)
            case .fixedNumber:
                Text(displayedValue ?? "")
                    .font(.headline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
                    .accessibilityLabel(accessibilityLabel)
            case .blankNumber:
                blankCell
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private var blankCell: some View {
        let borderColor = isConflict ? Color.red : Color(.separator)

        let base = Text(displayedValue ?? "")
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.yellow.opacity(0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: isConflict ? 3 : 1)
            )
            .accessibilityLabel(accessibilityLabel)
            .dropDestination(for: GameViewModel.NumberTile.self) { items, _ in
                guard let tile = items.first else { return false }
                placeAction(tile)
                return true
            }
            .onLongPressGesture {
                removeAction()
            }

        if let hint = accessibilityHint {
            base.accessibilityHint(hint)
        } else {
            base
        }
    }
}
