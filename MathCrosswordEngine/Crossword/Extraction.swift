import Foundation

public enum MCSentenceExtractionError: Error {
    case missingTarget(at: MCPos)
    case invalidPattern(at: MCPos)
}

public struct MCSentenceExtractor {
    public init() {}

    public func sentences(on board: MCBoard) throws -> [MCSentence] {
        var sentences: [MCSentence] = []
        for r in 0..<board.dim.rows {
            for c in 0..<board.dim.cols {
                let pos = MCPos(r: r, c: c)
                guard case .equals = board.at(pos) else { continue }
                if let sentence = try makeSentence(from: pos, orientation: .horizontal, board: board) {
                    sentences.append(sentence)
                }
                if let sentence = try makeSentence(from: pos, orientation: .vertical, board: board) {
                    sentences.append(sentence)
                }
            }
        }
        return sentences
    }

    private func makeSentence(
        from equalsPos: MCPos,
        orientation: MCSentenceOrientation,
        board: MCBoard
    ) throws -> MCSentence? {
        let delta = orientation == .horizontal ? (dr: 0, dc: 1) : (dr: 1, dc: 0)
        let targetPos = MCPos(r: equalsPos.r + delta.dr, c: equalsPos.c + delta.dc)
        guard board.isInside(targetPos) else { return nil }
        guard board.at(targetPos).isNumberSlot else { return nil }

        let backward = orientation == .horizontal
            ? (dr: 0, dc: -1)
            : (dr: -1, dc: 0)
        var cursor = MCPos(r: equalsPos.r + backward.dr, c: equalsPos.c + backward.dc)
        var collected: [MCPos] = []

        while board.isInside(cursor) {
            let cell = board.at(cursor)
            if case .wall = cell {
                break
            }
            collected.append(cursor)
            cursor = MCPos(r: cursor.r + backward.dr, c: cursor.c + backward.dc)
        }

        guard !collected.isEmpty else {
            throw MCSentenceExtractionError.invalidPattern(at: equalsPos)
        }

        let positions = Array(collected.reversed())
        guard isValidPattern(positions, board: board) else {
            throw MCSentenceExtractionError.invalidPattern(at: equalsPos)
        }

        return MCSentence(
            positions: positions,
            equalsPos: equalsPos,
            targetPos: targetPos,
            orientation: orientation
        )
    }

    private func isValidPattern(_ positions: [MCPos], board: MCBoard) -> Bool {
        guard positions.count % 2 == 1 else { return false }
        for (index, pos) in positions.enumerated() {
            let cell = board.at(pos)
            if index % 2 == 0 {
                if case .op = cell { return false }
                if case .equals = cell { return false }
                if case .wall = cell { return false }
            } else if case .op = cell {
                continue
            } else {
                return false
            }
        }
        return true
    }
}
