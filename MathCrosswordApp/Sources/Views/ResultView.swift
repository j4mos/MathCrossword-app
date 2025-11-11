import SwiftUI

struct ResultView: View {
    @EnvironmentObject private var store: GameStore
    let state: GameStore.ResultState

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: state.isSuccess ? "checkmark.circle.fill" : "xmark.octagon.fill")
                .font(.system(size: 72))
                .foregroundStyle(state.isSuccess ? .green : .orange)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(state.title)
                    .font(.title2.bold())
                Text(state.message)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)

            VStack(spacing: 12) {
                if state.isSuccess {
                    Button {
                        store.generatePuzzle()
                    } label: {
                        Label("Nächstes Rätsel", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        store.dismissResult()
                    } label: {
                        Label("Zurück zum Brett", systemImage: "arrow.uturn.backward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button {
                    store.backToStart()
                } label: {
                    Label("Zur Startseite", systemImage: "house")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Ergebnis")
    }
}
