import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    case sprint = "Sprint"
    case marathon = "Marathon"
    case training = "Training"
    
    var id: String { rawValue }
}

enum OperationType: String, CaseIterable, Codable {
    case addition = "addition"
    case subtraction = "subtraction"
    case multiplication = "multiplication"
    
    var symbol: String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "−"
        case .multiplication: return "×"
        }
    }
}

struct Question: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let answer: Int
    let operands: [Int]
    let type: OperationType
}
