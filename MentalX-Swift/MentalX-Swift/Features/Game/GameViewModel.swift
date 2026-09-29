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

    // Timer
    var timeRemaining: Double = 0
    var totalTime: Double = 0
    @ObservationIgnored private var timer: Timer?

    // Feedback Triggers
    var successTrigger: Int = 0
    var errorTrigger: Int = 0

    // SRS Context
    var modelContext: ModelContext?

    init(mode: GameMode, modelContext: ModelContext?) {
        self.mode = mode
        self.modelContext = modelContext
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

            let now = Date()

            // 1. Fetch Due Items
            // Note: Predicate construction in SwiftData can be finicky.
            // We use a simple predicate comparing dueDate.
            let dueDescriptor = FetchDescriptor<SRSItem>(
                predicate: #Predicate { $0.dueDate <= now },
                sortBy: [SortDescriptor(\.dueDate)]
            )

            do {
                let dueItems = try context.fetch(dueDescriptor)
                for item in dueItems {
                    if let dueQuestion = QuestionGenerator.shared.generateFromSRS(item: item) {
                        currentQuestion = dueQuestion
                        return
                    }
                    print("Skipping unsupported SRS item: \(item.id)")
                }
                currentQuestion = makeRandomQuestion()

            } catch {
                print("SRS Fetch Error: \(error)")
                currentQuestion = makeRandomQuestion()
            }

        } else {
            currentQuestion = makeRandomQuestion()
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
            // Correct
            score += 1
            successTrigger += 1
            input = ""

            updateSRS(correct: true)

            nextQuestion()
        } else if input.count >= answerStr.count {
            // Wrong and full length
            if mode == .marathon {
                updateSRS(correct: false)
                input = ""
                if loseLife() {
                    nextQuestion()
                }
            } else {
                errorTrigger += 1
                input = ""
                updateSRS(correct: false)
            }
        }
    }

    func updateSRS(correct: Bool) {
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

            // Update via Manager
            // Quality mapping: Correct -> 4/5, Incorrect -> 0-2
            // Simplification for MVP: Correct = 5, Incorrect = 1
            let quality = correct ? 5 : 1
            SRSManager.shared.updateItem(item, quality: quality)

            try context.save()
            print("SRS Updated: \(item.id) -> Interval: \(item.interval)")

        } catch {
            print("SRS Update Failed: \(error)")
        }
    }

    private func makeRandomQuestion() -> Question {
        let types = OperationType.allCases
        let type = types[Int.random(in: types.indices)]
        return QuestionGenerator.shared.generate(type: type)
    }
}
