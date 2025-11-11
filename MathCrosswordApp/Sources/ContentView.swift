import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        NavigationStack {
            switch store.screen {
            case .start:
                StartView()
            case .game:
                GameView()
            case .result(let state):
                ResultView(state: state)
            }
        }
        .alert(item: $store.alert) { item in
            Alert(title: Text("Hinweis"), message: Text(item.message), dismissButton: .default(Text("OK")))
        }
    }
}
