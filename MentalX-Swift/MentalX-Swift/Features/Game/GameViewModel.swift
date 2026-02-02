import SwiftData
import SwiftUI

@Observable
class GameViewModel {
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
    var timer: Timer?

    // Feedback Triggers
    var successTrigger: Int = 0
    var errorTrigger: Int = 0

    // SRS Context
    var modelContext: ModelContext?

    init(mode: GameMode, modelContext: ModelContext?) {
        self.mode = mode
        self.modelContext = modelContext
        setupGame()
    }

    func setupGame() {
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
                // Fallback if context missing
                let type: OperationType = Bool.random() ? .addition : .multiplication
                currentQuestion = QuestionGenerator.shared.generate(type: type)
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
                if let firstDue = dueItems.first {
                    currentQuestion = QuestionGenerator.shared.generateFromSRS(item: firstDue)
                    return
                }
                let type: OperationType = Bool.random() ? .addition : .multiplication
                currentQuestion = QuestionGenerator.shared.generate(type: type)

            } catch {
                print("SRS Fetch Error: \(error)")
                let type: OperationType = Bool.random() ? .addition : .multiplication
                currentQuestion = QuestionGenerator.shared.generate(type: type)
            }

        } else {
            // Random mix for other modes
            let type: OperationType = Bool.random() ? .addition : .multiplication
            currentQuestion = QuestionGenerator.shared.generate(type: type)
        }

        if mode == .marathon {
            timeRemaining = 10  // Reset per question
        }
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.tick()
        }
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
            loseLife()
            nextQuestion()  // Skip timeout question
        }
    }

    func endGame() {
        timer?.invalidate()
        isGameOver = true
    }

    func loseLife() {
        lives -= 1
        errorTrigger += 1
        if lives <= 0 {
            endGame()
        }
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

    func checkAnswer() {
        guard let question = currentQuestion, Int(input) != nil else { return }

        let answerStr = "\(question.answer)"

        if input == answerStr {
            // Correct
            score += 1
            successTrigger += 1
            input = ""

            // SRS Update if Training
            if mode == .training {
                updateSRS(correct: true)
            }

            nextQuestion()
        } else if input.count >= answerStr.count {
            // Wrong and full length
            if mode == .marathon {
                loseLife()
                input = ""
            } else {
                errorTrigger += 1
                input = ""

                // SRS Update if Training (Incorrect)
                if mode == .training {
                    updateSRS(correct: false)
                }
            }
        }
    }

    func updateSRS(correct: Bool) {
        guard let context = modelContext, let question = currentQuestion else { return }
        let typeStr = question.type.rawValue
        let op1 = question.operands[0]
        let op2 = question.operands[1]
        // Commutativity: Normalize ID lookup
        // We use the same logic as SRSItem init
        let minOp = min(op1, op2)
        let maxOp = max(op1, op2)
        let id = "\(typeStr):\(minOp):\(maxOp)"

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
}
