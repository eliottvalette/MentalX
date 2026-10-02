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
        var uptime: TimeInterval = 100
        let viewModel = GameViewModel(
            mode: .sprint,
            modelContext: context,
            uptimeProvider: { uptime }
        )
        viewModel.nextQuestion()
        let question = try #require(viewModel.currentQuestion)

        uptime += 0.25
        submit(answer: question.answer, to: viewModel)

        let items = try context.fetch(FetchDescriptor<SRSItem>())
        #expect(viewModel.score == 1)
        #expect(items.count == 1)
        #expect(
            items.first?.id == SRSItem.identifier(
                type: question.type.rawValue,
                op1: question.operands[0],
                op2: question.operands[1]
            )
        )
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

        let viewModel = GameViewModel(
            mode: .training,
            modelContext: context,
            trainingOperation: .addition
        )
        viewModel.nextQuestion()
        let answeredQuestionID = try #require(viewModel.currentQuestion?.id)
        #expect(viewModel.currentQuestion?.text == "10 + 3")

        viewModel.submitInput("1")
        viewModel.submitInput("3")

        #expect(viewModel.currentQuestion?.id != answeredQuestionID)
        #expect(dueItem.repetition == 1)
        #expect(dueItem.dueDate > Date())
    }

    @Test("Training only loads the selected operation")
    @MainActor
    func trainingFiltersSelectedOperation() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SRSItem.self, configurations: configuration)
        let context = ModelContext(container)
        context.insert(SRSItem(type: OperationType.addition.rawValue, op1: 10, op2: 3))
        context.insert(SRSItem(type: OperationType.multiplication.rawValue, op1: 3, op2: 4))
        try context.save()

        let viewModel = GameViewModel(
            mode: .training,
            modelContext: context,
            trainingOperation: .multiplication
        )

        for _ in 0..<25 {
            viewModel.nextQuestion()
            #expect(viewModel.currentQuestion?.type == .multiplication)
        }
    }

    @Test("Commutative operations share SRS identity")
    func commutativeSRSIdentity() {
        let multiplicationForward = SRSItem.identifier(
            type: OperationType.multiplication.rawValue,
            op1: 3,
            op2: 12
        )
        let multiplicationReverse = SRSItem.identifier(
            type: OperationType.multiplication.rawValue,
            op1: 12,
            op2: 3
        )
        let additionForward = SRSItem.identifier(
            type: OperationType.addition.rawValue,
            op1: 4,
            op2: 11
        )
        let additionReverse = SRSItem.identifier(
            type: OperationType.addition.rawValue,
            op1: 11,
            op2: 4
        )

        #expect(multiplicationForward == multiplicationReverse)
        #expect(additionForward == additionReverse)
    }

    @Test("SRS quality follows response-time thresholds")
    func responseTimeQualityThresholds() {
        let manager = SRSManager.shared

        #expect(manager.quality(forResponseTime: 1.249, hadIncorrectAttempt: false) == 5)
        #expect(manager.quality(forResponseTime: 1.25, hadIncorrectAttempt: false) == 4)
        #expect(manager.quality(forResponseTime: 2.499, hadIncorrectAttempt: false) == 4)
        #expect(manager.quality(forResponseTime: 2.5, hadIncorrectAttempt: false) == 3)
        #expect(manager.quality(forResponseTime: 10, hadIncorrectAttempt: false) == 3)
        #expect(manager.quality(forResponseTime: 0.1, hadIncorrectAttempt: true) == 0)
    }

    @Test("The scoring migration purges SRS progress exactly once and preserves game results")
    @MainActor
    func scoringMigrationPurgesOnlyOnce() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: SRSItem.self,
            GameResult.self,
            configurations: configuration
        )
        let context = ModelContext(container)
        context.insert(SRSItem(type: OperationType.multiplication.rawValue, op1: 3, op2: 4))
        context.insert(GameResult(mode: GameMode.sprint.rawValue, score: 12))
        try context.save()

        let suiteName = "MentalX-SwiftTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let didReset = try SRSManager.shared.resetOutdatedProgressIfNeeded(
            in: context,
            defaults: defaults
        )

        #expect(didReset)
        #expect(try context.fetchCount(FetchDescriptor<SRSItem>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<GameResult>()) == 1)

        context.insert(SRSItem(type: OperationType.multiplication.rawValue, op1: 5, op2: 6))
        try context.save()

        let didResetAgain = try SRSManager.shared.resetOutdatedProgressIfNeeded(
            in: context,
            defaults: defaults
        )

        #expect(!didResetAgain)
        #expect(try context.fetchCount(FetchDescriptor<SRSItem>()) == 1)
    }

    @Test("A wrong attempt records one zero even after a quick correction")
    @MainActor
    func wrongThenCorrectRemainsZero() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SRSItem.self, configurations: configuration)
        let context = ModelContext(container)
        let dueItem = SRSItem(type: OperationType.multiplication.rawValue, op1: 3, op2: 4)
        context.insert(dueItem)
        try context.save()
        var uptime: TimeInterval = 100
        let viewModel = GameViewModel(
            mode: .training,
            modelContext: context,
            trainingOperation: .multiplication,
            uptimeProvider: { uptime }
        )
        viewModel.nextQuestion()

        uptime += 0.2
        viewModel.submitInput("0")
        viewModel.submitInput("0")
        let easeFactorAfterError = dueItem.easeFactor

        uptime += 0.1
        viewModel.submitInput("1")
        viewModel.submitInput("2")

        #expect(dueItem.repetition == 0)
        #expect(dueItem.interval == 1)
        #expect(dueItem.easeFactor == easeFactorAfterError)
        #expect(dueItem.easeFactor < 2.5)
    }

    @MainActor
    private func submit(answer: Int, to viewModel: GameViewModel) {
        if answer < 0 {
            viewModel.toggleInputSign()
        }

        for digit in String(abs(answer)) {
            viewModel.submitInput(String(digit))
        }
    }
}
