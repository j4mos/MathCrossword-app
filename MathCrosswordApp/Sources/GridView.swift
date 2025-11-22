import SwiftUI
import MathCrosswordEngine
import UniformTypeIdentifiers

struct GridView: View {
    let cells: [GridCell]
    let equationStates: [UUID: EquationEvaluationState]
    let onClear: (GridPosition) -> Void
    let onDropNumber: (Int, GridPosition) -> Void

    private var rows: Int {
        (cells.map { $0.position.row }.max() ?? -1) + 1
    }

    private var columns: Int {
        (cells.map { $0.position.column }.max() ?? -1) + 1
    }

    var body: some View {
        let gridItems = Array(repeating: GridItem(.flexible(minimum: 56), spacing: 6), count: columns)
        LazyVGrid(columns: gridItems, spacing: 6) {
            ForEach(cells, id: \.id) { cell in
                GridCellView(cell: cell, equationStates: equationStates, onClear: onClear, onDropNumber: onDropNumber)
                    .frame(minHeight: 56)
            }
        }
    }
}

struct GridCellView: View {
    let cell: GridCell
    let equationStates: [UUID: EquationEvaluationState]
    let onClear: (GridPosition) -> Void
    let onDropNumber: (Int, GridPosition) -> Void
    @State private var isTargeted = false

    var body: some View {
        switch cell.type {
        case .block:
            Color.clear
        case .operatorSymbol:
            textCell(cell.operatorSymbol ?? "")
        case .equals:
            textCell("=")
        case .fixedOperand:
            textCell("\(cell.fixedValue ?? 0)")
        case .emptyOperand:
            operandCell
        }
    }

    @ViewBuilder
    private var operandCell: some View {
        let valueText = cell.currentValue.map { "\($0)" } ?? ""
        let bg = backgroundColor()

        let displayText = valueText.isEmpty ? " " : valueText

        let base = Text(displayText)
            .font(.system(size: 16, weight: .semibold, design: .monospaced))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(6)
            .background(bg)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isTargeted ? Color.blue.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .onTapGesture {
                if cell.currentValue != nil {
                    onClear(cell.position)
                }
            }
            .onDrop(of: [UTType.plainText, UTType.text], isTargeted: $isTargeted, perform: handleDrop(providers:))

        if let current = cell.currentValue {
            base.onDrag {
                onClear(cell.position)
                return NSItemProvider(object: "\(current)" as NSString)
            }
        } else {
            base
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard cell.currentValue == nil else { return false }
        guard let provider = providers.first else { return false }

        loadInt(from: provider) { number in
            guard let number else { return }
            Task { @MainActor in
                onDropNumber(number, cell.position)
            }
        }
        return true
    }

    private func loadInt(from provider: NSItemProvider, completion: @escaping (Int?) -> Void) {
        let identifiers = [UTType.plainText.identifier, UTType.text.identifier]
        guard let typeIdentifier = identifiers.first(where: { provider.hasItemConformingToTypeIdentifier($0) }) else {
            completion(nil)
            return
        }

        provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { item, _ in
            let intValue: Int?
            if let data = item as? Data, let string = String(data: data, encoding: .utf8) {
                intValue = Int(string)
            } else if let string = item as? String {
                intValue = Int(string)
            } else if let nsString = item as? NSString {
                intValue = Int(nsString as String)
            } else {
                intValue = nil
            }
            completion(intValue)
        }
    }

    private func textCell(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold, design: .monospaced))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(6)
            .background(Color(.systemGray6))
            .cornerRadius(6)
    }

    private func backgroundColor() -> Color {
        // If any equation involving this cell is incorrect, show red; if all are correct, green; else neutral.
        let participatingStates = equationStates.values
        if participatingStates.contains(.incorrect) {
            return Color.red.opacity(0.2)
        }
        if participatingStates.contains(.correct) {
            return Color.green.opacity(0.2)
        }
        return Color(.systemBackground)
    }
}
