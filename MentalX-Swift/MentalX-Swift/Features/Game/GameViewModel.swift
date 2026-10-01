import SwiftData
import SwiftUI

@MainActor
@Observable
final class GameViewModel {
    // Mode & State
    var mode: GameMode
    var currentQuestion: Question?
    var input: String = ""
    var score: Int = 0
    var lives: Int = 3
    var isGameOver: Bool = false
    let trainingOperation: OperationType?

    // Timer
    var timeRemaining: Double = 0
    var totalTime: Double = 0
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var trainingQueue: [Question] = []
    @ObservationIgnored private let uptimeProvider: () -> TimeInterval
    @ObservationIgnored private var questionStartedAt: TimeInterval?
    @ObservationIgnored private var hadIncorrectAttempt = false
    @ObservationIgnored private var srsOutcomeRecorded = false

    // Feedback Triggers
    var successTrigger: Int = 0
    var errorTrigger: Int = 0

    // SRS Context
    var modelContext: ModelContext?

    init(
        mode: GameMode,
        modelContext: ModelContext?,
        trainingOperation: OperationType? = nil,
        uptimeProvider: @escaping () -> TimeInterval = {
            ProcessInfo.processInfo.systemUptime
        }
    ) {
        self.mode = mode
        self.modelContext = modelContext
        self.trainingOperation = trainingOperation
        self.uptimeProvider = uptimeProvider
    }

    deinit {
        timer?.invalidate()
    }

    func startGame(modelContext: ModelContext) {
        guard currentQuestion == nil, !isGameOver else {
            startTimer()
            return
        }

        self.modelContext = modelContext
        score = 0
        lives = 3
        isGameOver = false
        input = ""

        switch mode {
        case .sprint:
            timeRemaining = 60
            totalTime = 60
        case .marathon:
            timeRemaining = 10  // Per question
            totalTime = 10
        case .training:
            timeRemaining = 0  // No timer usually, or infinite
        }

        nextQuestion()
        startTimer()
    }

    func nextQuestion() {
        if mode == .training {
            guard let context = modelContext else {
                print("GameViewModel: Training requires a model context.")
                return
            }

            do {
                if trainingQueue.isEmpty {
                    try prepareTrainingQueue(in: context)
                }
                guard let question = trainingQueue.popLast() else {
                    print("Training queue is empty after loading the curriculum.")
                    currentQuestion = nil
                    return
                }
                presentQuestion(question)
            } catch {
                print("Training queue load failed: \(error)")
                currentQuestion = nil
                questionStartedAt = nil
            }

        } else {
            presentQuestion(makeRandomQuestion())
        }

        if mode == .marathon {
            timeRemaining = 10  // Reset per question
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = nil

        guard mode != .training, !isGameOver else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func exitGame() {
        stopTimer()
    }

    func tick() {
        if mode == .training { return }

        if timeRemaining > 0 {
            timeRemaining -= 0.1
        } else {
            handleTimeout()
        }
    }

    func handleTimeout() {
        if mode == .sprint {
            endGame()
        } else if mode == .marathon {
            if loseLife() {
                nextQuestion()
            }
        }
    }

    func endGame() {
        guard !isGameOver else { return }

        stopTimer()
        isGameOver = true

        // Save Score
        if let context = modelContext, mode == .sprint || mode == .marathon {
            let result = GameResult(mode: mode.rawValue, score: score)
            context.insert(result)
            do {
                try context.save()
                print("Score saved: \(score) for \(mode.rawValue)")
            } catch {
                print("Game result save failed: \(error)")
            }
        }
    }

    @discardableResult
    func loseLife() -> Bool {
        lives -= 1
        errorTrigger += 1
        if lives <= 0 {
            endGame()
            return false
        }
        return true
    }

    // Input Handling
    func submitInput(_ value: String) {
        if input.count < 6 {
            input += value
            checkAnswer()
        }
    }

    func deleteInput() {
        if !input.isEmpty {
            input.removeLast()
        }
    }

    func toggleInputSign() {
        if input.hasPrefix("-") {
            input.removeFirst()
        } else {
            input = "-" + input
        }
        checkAnswer()
    }

    func checkAnswer() {
        guard let question = currentQuestion, Int(input) != nil else { return }

        let answerStr = "\(question.answer)"

        if input == answerStr {
            if !srsOutcomeRecorded {
                guard let responseTime = currentResponseTime else {
                    print("SRS update failed: question start time is unavailable.")
                    return
                }
                let quality = SRSManager.shared.quality(
                    forResponseTime: responseTime,
                    hadIncorrectAttempt: hadIncorrectAttempt
                )
                updateSRS(quality: quality, responseTime: responseTime)
                srsOutcomeRecorded = true
            }

            // Correct
            score += 1
            successTrigger += 1
            input = ""

            nextQuestion()
        } else if input.count >= answerStr.count {
            // Wrong and full length
            hadIncorrectAttempt = true
            if !srsOutcomeRecorded {
                updateSRS(quality: 0, responseTime: currentResponseTime)
                srsOutcomeRecorded = true
            }

            if mode == .marathon {
                input = ""
                if loseLife() {
                    nextQuestion()
                }
            } else {
                errorTrigger += 1
                input = ""
            }
        }
    }

    func updateSRS(quality: Int, responseTime: TimeInterval?) {
        guard let context = modelContext else {
            print("SRS update failed: model context is unavailable.")
            return
        }
        guard let question = currentQuestion else {
            print("SRS update failed: current question is unavailable.")
            return
        }
        let typeStr = question.type.rawValue
        let op1 = question.operands[0]
        let op2 = question.operands[1]
        let id = SRSItem.identifier(type: typeStr, op1: op1, op2: op2)

        // Fetch existing
        let fetchDescriptor = FetchDescriptor<SRSItem>(predicate: #Predicate { $0.id == id })

        do {
            let results = try context.fetch(fetchDescriptor)
            let item: SRSItem

            if let existing = results.first {
                item = existing
            } else {
                item = SRSItem(type: typeStr, op1: op1, op2: op2)
                context.insert(item)
            }

            SRSManager.shared.updateItem(item, quality: quality)

            try context.save()
            let responseDescription = responseTime.map { String(format: "%.3fs", $0) } ?? "unavailable"
            print(
                "SRS Updated: \(item.id) -> Quality: \(quality), Response: \(responseDescription), Interval: \(item.interval)"
            )

        } catch {
            print("SRS Update Failed: \(error)")
        }
    }

    private func prepareTrainingQueue(in context: ModelContext) throws {
        guard let trainingOperation else {
            throw TrainingQueueError.missingOperation
        }

        let descriptor = FetchDescriptor<SRSItem>(sortBy: [SortDescriptor(\.dueDate)])
        let storedItems = try context.fetch(descriptor)
        let now = Date()

        let dueQuestions = storedItems.compactMap { item -> Question? in
            guard item.type == trainingOperation.rawValue else { return nil }
            guard item.dueDate <= now else { return nil }
            guard let question = QuestionGenerator.shared.generateFromSRS(item: item) else {
                print("Skipping unsupported SRS item: \(item.id)")
                return nil
            }
            return question
        }

        let knownQuestionIDs = Set(storedItems.map(\.id))
        let unseenQuestions = QuestionGenerator.shared
            .allQuestions(for: trainingOperation)
            .filter { !knownQuestionIDs.contains(questionIdentifier($0)) }
            .shuffled()

        var sessionQuestions = dueQuestions + unseenQuestions
        if sessionQuestions.isEmpty {
            print("No due or unseen questions remain; starting a general curriculum review.")
            sessionQuestions = QuestionGenerator.shared
                .allQuestions(for: trainingOperation)
                .shuffled()
        }

        trainingQueue = Array(sessionQuestions.reversed())
    }

    private func makeRandomQuestion() -> Question {
        let types = OperationType.allCases
        let type = types[Int.random(in: types.indices)]
        return QuestionGenerator.shared.generate(type: type)
    }

    private var currentResponseTime: TimeInterval? {
        guard let questionStartedAt else { return nil }
        return uptimeProvider() - questionStartedAt
    }

    private func presentQuestion(_ question: Question) {
        currentQuestion = question
        input = ""
        hadIncorrectAttempt = false
        srsOutcomeRecorded = false
        questionStartedAt = uptimeProvider()
    }

    private func questionIdentifier(_ question: Question) -> String {
        SRSItem.identifier(
            type: question.type.rawValue,
            op1: question.operands[0],
            op2: question.operands[1]
        )
    }
}

private enum TrainingQueueError: LocalizedError {
    case missingOperation

    var errorDescription: String? {
        switch self {
        case .missingOperation:
            return "Training requires an explicitly selected operation."
        }
    }
}
