import SwiftUI

struct BoardView: View {
    let gridSize: Int
    let cells: [GameStore.CellMetadata]
    let textBinding: (GameStore.CellMetadata) -> Binding<String>
    let isError: (GameStore.CellMetadata) -> Bool

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: max(gridSize, 1))
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(cells) { cell in
                if cell.isFixed, let value = cell.fixedValue {
                    Text("\(value)")
                        .font(.title3)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .padding(6)
                        .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isError(cell) ? Color.red : Color.secondary.opacity(0.4), lineWidth: 2)
                        )
                        .accessibilityLabel(cell.accessibilityLabel(value: "\(value)", hasError: isError(cell)))
                } else {
                    TextField("?", text: textBinding(cell))
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.center)
                        .padding(6)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isError(cell) ? Color.red : Color.accentColor, lineWidth: 2)
                        )
                        .accessibilityLabel(cell.accessibilityLabel(value: textBinding(cell).wrappedValue, hasError: isError(cell)))
                        .accessibilityHint("Zahl eingeben")
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: cells)
    }
}
