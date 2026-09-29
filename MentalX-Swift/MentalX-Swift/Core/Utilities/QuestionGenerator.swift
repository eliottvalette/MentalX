import Foundation

final class QuestionGenerator {
    static let shared = QuestionGenerator()

    static let multiplicationOperands = 3...12
    static let arithmeticLeftOperands = 1...60
    static let arithmeticRightOperands = 1...15

    func generate(type: OperationType) -> Question {
        switch type {
        case .addition:
            return generateAddition()
        case .subtraction:
            return generateSubtraction()
        case .multiplication:
            return generateMultiplication()
        }
    }

    func allQuestions(for type: OperationType) -> [Question] {
        switch type {
        case .multiplication:
            return Self.multiplicationOperands.flatMap { left in
                Self.multiplicationOperands.map { right in
                    makeQuestion(left: left, right: right, type: type)
                }
            }
        case .addition, .subtraction:
            return Self.arithmeticLeftOperands.flatMap { left in
                Self.arithmeticRightOperands.map { right in
                    makeQuestion(left: left, right: right, type: type)
                }
            }
        }
    }

    func generateFromSRS(item: SRSItem) -> Question? {
        guard let type = OperationType(rawValue: item.type), supports(type: type, left: item.op1, right: item.op2) else {
            return nil
        }

        return makeQuestion(left: item.op1, right: item.op2, type: type)
    }

    private func generateMultiplication() -> Question {
        let left = Int.random(in: Self.multiplicationOperands)
        let right = Int.random(in: Self.multiplicationOperands)
        return makeQuestion(left: left, right: right, type: .multiplication)
    }

    private func generateAddition() -> Question {
        let left = Int.random(in: Self.arithmeticLeftOperands)
        let right = Int.random(in: Self.arithmeticRightOperands)
        return makeQuestion(left: left, right: right, type: .addition)
    }

    private func generateSubtraction() -> Question {
        let left = Int.random(in: Self.arithmeticLeftOperands)
        let right = Int.random(in: Self.arithmeticRightOperands)
        return makeQuestion(left: left, right: right, type: .subtraction)
    }

    private func supports(type: OperationType, left: Int, right: Int) -> Bool {
        switch type {
        case .multiplication:
            return Self.multiplicationOperands.contains(left) && Self.multiplicationOperands.contains(right)
        case .addition, .subtraction:
            return Self.arithmeticLeftOperands.contains(left) && Self.arithmeticRightOperands.contains(right)
        }
    }

    private func makeQuestion(left: Int, right: Int, type: OperationType) -> Question {
        let answer: Int
        switch type {
        case .addition:
            answer = left + right
        case .subtraction:
            answer = left - right
        case .multiplication:
            answer = left * right
        }

        return Question(
            text: "\(left) \(type.symbol) \(right)",
            answer: answer,
            operands: [left, right],
            type: type
        )
    }
}
