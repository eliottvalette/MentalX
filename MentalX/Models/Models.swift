import Foundation

// MARK: - Enums
enum GameMode: String, Identifiable, CaseIterable {
    case sprint    // 60s max score
    case marathon  // Until first error
    case training  // SRS based
    
    var id: String { self.rawValue }
}

enum OperationType: String, CaseIterable {
    case addition
    case multiplication
    // can be extended with tripleAddition etc.
}

// MARK: - Question Model
struct Question: Identifiable {
    let id = UUID()
    let text: String
    let answer: Int
    let type: OperationType
}

// MARK: - Question Generator
class QuestionGenerator {
    
    // Generates a question based on constraints
    static func generate(type: OperationType) -> Question {
        switch type {
        case .addition:
            // a + b < 100_000
            let a = Int.random(in: 1...50000)
            let b = Int.random(in: 1...49999)
            return Question(text: "\(a) + \(b)", answer: a + b, type: .addition)
            
        case .multiplication:
            // a, b in [2, 100]
            let a = Int.random(in: 2...100)
            let b = Int.random(in: 2...100)
            return Question(text: "\(a) × \(b)", answer: a * b, type: .multiplication)
        }
    }
    
    // SRS Logic placeholder: Weighted random generation based on history
    static func generateWeighted() -> Question {
        // Implementation logic: fetch user weak spots, generate specific question
        // For MVP, returning random multiplication as default
        return generate(type: .multiplication)
    }
}
