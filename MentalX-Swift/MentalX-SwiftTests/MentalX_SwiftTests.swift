//
//  MentalX_SwiftTests.swift
//  MentalX-SwiftTests
//
//  Created by Eliott VALETTE on 02/02/2026.
//

import Foundation
import SwiftData
import Testing
@testable import MentalX_Swift

@Suite("Question curriculum")
struct MentalX_SwiftTests {
    private let generator = QuestionGenerator()

    @Test("Multiplication includes every ordered pair from 3 through 12")
    func multiplicationCurriculum() {
        let questions = generator.allQuestions(for: .multiplication)
        let pairs = Set(questions.map { "\($0.operands[0]):\($0.operands[1])" })

        #expect(questions.count == 100)
        #expect(pairs.count == 100)
        #expect(questions.allSatisfy { question in
            QuestionGenerator.multiplicationOperands.contains(question.operands[0])
                && QuestionGenerator.multiplicationOperands.contains(question.operands[1])
                && question.answer == question.operands[0] * question.operands[1]
        })
    }

    @Test("Addition uses a left operand from 1 through 60 and an offset from 1 through 15")
    func additionCurriculum() {
        let questions = generator.allQuestions(for: .addition)

        #expect(questions.count == 900)
        #expect(questions.allSatisfy { question in
            QuestionGenerator.arithmeticLeftOperands.contains(question.operands[0])
                && QuestionGenerator.arithmeticRightOperands.contains(question.operands[1])
                && question.answer == question.operands[0] + question.operands[1]
        })
    }

    @Test("Subtraction uses a left operand from 1 through 60 and an offset from 1 through 15")
    func subtractionCurriculum() {
        let questions = generator.allQuestions(for: .subtraction)

        #expect(questions.count == 900)
        #expect(questions.allSatisfy { question in
            QuestionGenerator.arithmeticLeftOperands.contains(question.operands[0])
                && QuestionGenerator.arithmeticRightOperands.contains(question.operands[1])
                && question.answer == question.operands[0] - question.operands[1]
        })
    }

    @Test("Subtraction SRS identities preserve operand order")
    func subtractionIdentity() {
        let forward = SRSItem.identifier(type: OperationType.subtraction.rawValue, op1: 3, op2: 12)
        let reverse = SRSItem.identifier(type: OperationType.subtraction.rawValue, op1: 12, op2: 3)

        #expect(forward != reverse)
    }

    @Test("Sprint answers contribute to cumulative SRS memory")
    @MainActor
    func sprintUpdatesSRS() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SRSItem.self, configurations: configuration)
        let context = ModelContext(container)
        let viewModel = GameViewModel(mode: .sprint, modelContext: context)
        viewModel.currentQuestion = Question(
            text: "3 × 4",
            answer: 12,
            operands: [3, 4],
            type: .multiplication
        )

        viewModel.submitInput("1")
        viewModel.submitInput("2")

        let items = try context.fetch(FetchDescriptor<SRSItem>())
        #expect(viewModel.score == 1)
        #expect(items.count == 1)
        #expect(items.first?.id == "multiplication:3:4")
    }

    @Test("Training does not immediately repeat a correctly answered due question")
    @MainActor
    func trainingAdvancesAfterCorrectAnswer() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SRSItem.self, configurations: configuration)
        let context = ModelContext(container)
        let dueItem = SRSItem(type: OperationType.addition.rawValue, op1: 10, op2: 3)
        context.insert(dueItem)
        try context.save()

        let viewModel = GameViewModel(mode: .training, modelContext: context)
        viewModel.nextQuestion()
        let answeredQuestionID = try #require(viewModel.currentQuestion?.id)
        #expect(viewModel.currentQuestion?.text == "10 + 3")

        viewModel.submitInput("1")
        viewModel.submitInput("3")

        #expect(viewModel.currentQuestion?.id != answeredQuestionID)
        #expect(dueItem.repetition == 1)
        #expect(dueItem.dueDate > Date())
    }

}
