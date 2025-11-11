import MathCrosswordEngine
import SwiftUI

struct StartView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("MathCrossword")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                Text("Rechen-Kreuzworträtsel für Klasse 4. Wähle eine Schwierigkeit und starte das nächste Puzzle.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            Picker("Schwierigkeit", selection: $store.difficulty) {
                Label("Einfach", systemImage: "tortoise").tag(Difficulty.grade4_easy)
                Label("Standard", systemImage: "figure.walk").tag(Difficulty.grade4_std)
                Label("Knifflig", systemImage: "hare").tag(Difficulty.grade4_hard)
            }
            .pickerStyle(.segmented)
            .accessibilityHint("Bestimme den Zahlenraum und die Operatoren im Rätsel.")

            Button {
                store.generatePuzzle()
            } label: {
                Label("Neues Rätsel", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(store.isGenerating)

            Spacer()
        }
        .padding()
        .accessibilityElement(children: .contain)
    }
}
