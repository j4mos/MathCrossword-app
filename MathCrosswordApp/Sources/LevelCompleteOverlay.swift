import SwiftUI

struct LevelCompleteOverlay: View {
    let onRetry: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 12) {
                Text("Super gemacht!")
                    .font(.title2)
                    .fontWeight(.bold)
                Button("Noch ein Puzzle") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}
