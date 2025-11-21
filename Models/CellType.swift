import Foundation

enum CellType: Codable, Equatable {
    case emptySlot
    case fixedNumber(Int)
    case `operator`(OperatorType)
    case equals
    case blocked

    private enum CodingKeys: String, CodingKey {
        case kind
        case value
    }

    private enum Kind: String, Codable {
        case emptySlot
        case fixedNumber
        case `operator`
        case equals
        case blocked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .emptySlot:
            self = .emptySlot
        case .fixedNumber:
            let value = try container.decode(Int.self, forKey: .value)
            self = .fixedNumber(value)
        case .operator:
            let op = try container.decode(OperatorType.self, forKey: .value)
            self = .operator(op)
        case .equals:
            self = .equals
        case .blocked:
            self = .blocked
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .emptySlot:
            try container.encode(Kind.emptySlot, forKey: .kind)
        case let .fixedNumber(number):
            try container.encode(Kind.fixedNumber, forKey: .kind)
            try container.encode(number, forKey: .value)
        case let .operator(operatorType):
            try container.encode(Kind.operator, forKey: .kind)
            try container.encode(operatorType, forKey: .value)
        case .equals:
            try container.encode(Kind.equals, forKey: .kind)
        case .blocked:
            try container.encode(Kind.blocked, forKey: .kind)
        }
    }
}
