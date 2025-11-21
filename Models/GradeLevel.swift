import Foundation

enum GradeLevel: String, Codable, CaseIterable, Identifiable {
    case grade2
    case grade3
    case grade4
    case grade5
    case grade6

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .grade2: return "Grade 2"
        case .grade3: return "Grade 3"
        case .grade4: return "Grade 4"
        case .grade5: return "Grade 5"
        case .grade6: return "Grade 6"
        }
    }
}

struct GradeConfig {
    let level: GradeLevel
    let allowedOperators: [OperatorType]
    let minOperand: Int
    let maxOperand: Int
    let allowNegativeIntermediateResults: Bool
    let allowDivisionWithRemainder: Bool
    let maxGridWidth: Int
    let maxGridHeight: Int
    let maxEquations: Int

    static func config(for level: GradeLevel) -> GradeConfig {
        switch level {
        case .grade2:
            return GradeConfig(
                level: .grade2,
                allowedOperators: [.plus, .minus],
                minOperand: 0,
                maxOperand: 20,
                allowNegativeIntermediateResults: false,
                allowDivisionWithRemainder: false,
                maxGridWidth: 5,
                maxGridHeight: 5,
                maxEquations: 6
            )
        case .grade3:
            return GradeConfig(
                level: .grade3,
                allowedOperators: [.plus, .minus],
                minOperand: 0,
                maxOperand: 50,
                allowNegativeIntermediateResults: false,
                allowDivisionWithRemainder: false,
                maxGridWidth: 6,
                maxGridHeight: 6,
                maxEquations: 8
            )
        case .grade4:
            return GradeConfig(
                level: .grade4,
                allowedOperators: [.plus, .minus, .multiply],
                minOperand: 0,
                maxOperand: 100,
                allowNegativeIntermediateResults: true,
                allowDivisionWithRemainder: false,
                maxGridWidth: 7,
                maxGridHeight: 7,
                maxEquations: 10
            )
        case .grade5:
            return GradeConfig(
                level: .grade5,
                allowedOperators: [.plus, .minus, .multiply, .divide],
                minOperand: -50,
                maxOperand: 200,
                allowNegativeIntermediateResults: true,
                allowDivisionWithRemainder: false,
                maxGridWidth: 8,
                maxGridHeight: 8,
                maxEquations: 12
            )
        case .grade6:
            return GradeConfig(
                level: .grade6,
                allowedOperators: [.plus, .minus, .multiply, .divide],
                minOperand: -100,
                maxOperand: 500,
                allowNegativeIntermediateResults: true,
                allowDivisionWithRemainder: true,
                maxGridWidth: 9,
                maxGridHeight: 9,
                maxEquations: 14
            )
        }
    }
}
