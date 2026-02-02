import Foundation

class QuestionGenerator {
    static let shared = QuestionGenerator()
    
    private let multiplicationNumbers = [2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15]
    
    private let additionRanges = [
        AdditionRange(id: "1-9", label: "1-9", min: 1, max: 9),
        AdditionRange(id: "10-19", label: "10-19", min: 10, max: 19),
        AdditionRange(id: "20-29", label: "20-29", min: 20, max: 29),
        AdditionRange(id: "30-39", label: "30-39", min: 30, max: 39),
        AdditionRange(id: "40-49", label: "40-49", min: 40, max: 49),
        AdditionRange(id: "50-99", label: "50-99", min: 50, max: 99)
    ]
    
    func generate(type: OperationType) -> Question {
        switch type {
        case .addition:
            return generateAddition()
        case .multiplication:
            return generateMultiplication()
        }
    }
    
    private func generateMultiplication() -> Question {
        let n1 = multiplicationNumbers.randomElement()!
        let n2 = multiplicationNumbers.randomElement()!
        return Question(
            text: "\(n1) × \(n2)",
            answer: n1 * n2,
            operands: [n1, n2],
            type: .multiplication
        )
    }
    
    private func generateAddition() -> Question {
        let r1 = additionRanges.randomElement()!
        let r2 = additionRanges.randomElement()!
        
        let n1 = Int.random(in: r1.min...r1.max)
        let n2 = Int.random(in: r2.min...r2.max)
        
        return Question(
            text: "\(n1) + \(n2)",
            answer: n1 + n2,
            operands: [n1, n2],
            type: .addition
        )
    }
    
    // Generates a specific question from SRS item data
    func generateFromSRS(item: SRSItem) -> Question {
        let type = item.type == "addition" ? OperationType.addition : .multiplication
        let symbol = type.symbol
        let answer = type == .addition ? item.op1 + item.op2 : item.op1 * item.op2
        
        return Question(
            text: "\(item.op1) \(symbol) \(item.op2)",
            answer: answer,
            operands: [item.op1, item.op2],
            type: type
        )
    }
}
