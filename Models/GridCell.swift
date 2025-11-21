import Foundation

struct GridCell: Identifiable, Codable, Equatable {
    let id: UUID
    let coordinate: GridCoordinate
    var type: CellType

    init(id: UUID = UUID(), coordinate: GridCoordinate, type: CellType) {
        self.id = id
        self.coordinate = coordinate
        self.type = type
    }
}
