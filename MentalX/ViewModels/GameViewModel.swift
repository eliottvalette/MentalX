import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    
    @Published var currentQuestion: Question?
    @Published var input: String = ""
    @Published var timeRemaining: TimeInterval = 60.0
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var gameMode: GameMode
    
    private var timer: AnyCancellable?
    private let maxTime: TimeInterval = 60.0
    private var questionStartTime: Date?
    
    init(mode: GameMode) {
        self.gameMode = mode
        startGame()
    }
    
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
        
        if playerAnswer == question.answer {
            handleCorrectAnswer(playerAnswer: playerAnswer)
        } else if String(playerAnswer).count >= String(question.answer).count {
            handleWrongAnswer(playerAnswer: playerAnswer)
        }
    }
    
    private func handleCorrectAnswer(playerAnswer: Int) {
        HapticManager.shared.playSuccess()
        score += 1
        logResult(playerAnswer: playerAnswer)
        input = ""
        nextQuestion()
    }
    
    private func handleWrongAnswer(playerAnswer: Int) {
        HapticManager.shared.playError()
        logResult(playerAnswer: playerAnswer)
        input = ""
        
        if gameMode == .marathon {
            endGame()
        }
    }
    
    private func logResult(playerAnswer: Int) {
        guard let question = currentQuestion, let startTime = questionStartTime else { return }
        let responseTime = Date().timeIntervalSince(startTime)
        let result = GameResult(mode: gameMode, question: question, userAnswer: playerAnswer, responseTime: responseTime)
        PersistenceManager.shared.saveResult(result)
    }
    
    private func nextQuestion() {
        if gameMode == .training {
            currentQuestion = QuestionGenerator.generateWeighted()
        } else {
            let randomType = OperationType.allCases.randomElement()!
            currentQuestion = QuestionGenerator.generate(type: randomType)
        }
        questionStartTime = Date()
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
    }
}
