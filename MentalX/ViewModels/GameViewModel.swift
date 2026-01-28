import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentQuestion: Question?
    @Published var input: String = ""
    @Published var timeRemaining: TimeInterval = 60.0
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var gameMode: GameMode
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private let maxTime: TimeInterval = 60.0
    
    // MARK: - Initialization
    init(mode: GameMode) {
        self.gameMode = mode
        startGame()
    }
    
    // MARK: - Game Logic
    func startGame() {
        score = 0
        input = ""
        isGameOver = false
        timeRemaining = (gameMode == .sprint) ? maxTime : 0
        nextQuestion()
        
        if gameMode == .sprint {
            startTimer()
        }
    }
    
    func submitInput(_ value: String) {
        input += value
        validateAnswer()
    }
    
    func deleteInput() {
        if !input.isEmpty {
            input.removeLast()
        }
    }
    
    private func validateAnswer() {
        guard let question = currentQuestion, let playerAnswer = Int(input) else { return }
        
        // Auto-validate if length matches (simple heuristic) or exact match
        // For strict checking, we wait for equality
        if playerAnswer == question.answer {
            handleCorrectAnswer()
        } else if String(playerAnswer).count >= String(question.answer).count {
            // If same length but wrong number
            handleWrongAnswer()
        }
    }
    
    private func handleCorrectAnswer() {
        score += 1
        input = ""
        
        // Add time bonus in sprint if needed
        nextQuestion()
    }
    
    private func handleWrongAnswer() {
        if gameMode == .marathon {
            endGame()
        } else {
            // Visual feedback (shake/red flash) would be triggered here
            input = "" // Reset input or punish
        }
    }
    
    private func nextQuestion() {
        // In training mode, use SRS generator
        if gameMode == .training {
            currentQuestion = QuestionGenerator.generateWeighted()
        } else {
            // Randomly mix types for now
            let randomType = OperationType.allCases.randomElement()!
            currentQuestion = QuestionGenerator.generate(type: randomType)
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
    }
    
    private func endGame() {
        isGameOver = true
        timer?.cancel()
        // Log final score to persistence layer here
    }
}
