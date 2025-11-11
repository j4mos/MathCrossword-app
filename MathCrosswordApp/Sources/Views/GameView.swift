import MathCrosswordEngine
import SwiftUI

struct GameView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        VStack(spacing: 16) {
            settingsBar
            if store.gridSize > 0 {
                BoardView(
                    gridSize: store.gridSize,
                    cells: store.cells,
                    textBinding: { store.binding(for: $0) },
                    isError: { store.isError(cell: $0) }
                )
                .animation(.easeInOut(duration: 0.2), value: store.errorCells)
                .padding(.vertical, 8)
            } else {
                ProgressView("Rätsel wird geladen …")
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Spielfeld")
    }

    private var settingsBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Schwierigkeit", selection: $store.difficulty) {
                Text("Einfach").tag(Difficulty.grade4_easy)
                Text("Standard").tag(Difficulty.grade4_std)
                Text("Knifflig").tag(Difficulty.grade4_hard)
            }
            .pickerStyle(.segmented)
            .accessibilityHint("Ändert die Parameter der nächsten Generierung.")

            HStack(spacing: 12) {
                Button {
                    store.generatePuzzle()
                } label: {
                    Label("Neues Rätsel", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)

                Button {
                    store.checkPuzzle()
                } label: {
                    Label("Überprüfen", systemImage: "checkmark.seal")
                }
                .buttonStyle(.borderedProminent)
            }
            .accessibilityElement(children: .contain)
        }
    }
}
