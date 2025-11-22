import SwiftUI
import MathCrosswordEngine

struct DifficultySelectionView: View {
    var body: some View {
        NavigationStack {
            List {
                difficultyRow(profile: .class1)
                difficultyRow(profile: .class2)
                difficultyRow(profile: .class3)
                difficultyRow(profile: .class4)
            }
            .navigationTitle("MathCrossword")
        }
    }

    private func difficultyRow(profile: DifficultyProfile) -> some View {
        NavigationLink(profile.displayName) {
            GameView(difficulty: profile)
        }
    }
}

struct DifficultySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DifficultySelectionView()
    }
}
