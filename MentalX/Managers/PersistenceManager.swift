import Foundation
import SwiftUI
import Combine

struct GameResult: Codable, Identifiable {
    let id: UUID
    let mode: String
    let question: String
    let answer: Int
    let userAnswer: Int
    let isCorrect: Bool
    let responseTime: TimeInterval
    let timestamp: Date
    
    init(mode: GameMode, question: Question, userAnswer: Int, responseTime: TimeInterval) {
        self.id = UUID()
        self.mode = mode.rawValue
        self.question = question.text
        self.answer = question.answer
        self.userAnswer = userAnswer
        self.isCorrect = userAnswer == question.answer
        self.responseTime = responseTime
        self.timestamp = Date()
    }
}

class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()
    
    @Published var results: [GameResult] = []
    
    private let resultsKey = "gameResults"
    private let maxResults = 1000
    
    init() {
        loadResults()
    }
    
    func saveResult(_ result: GameResult) {
        results.insert(result, at: 0)
        if results.count > maxResults {
            results.removeLast()
        }
        persistResults()
    }
    
    func calculateSRSItems() -> [SRSItem] {
        let groupedByQuestion = Dictionary(grouping: results) { $0.question }
        
        return groupedByQuestion.compactMap { (question, attempts) -> SRSItem? in
            guard attempts.count >= 3 else { return nil }
            
            let avgTime = attempts.map { $0.responseTime }.reduce(0, +) / Double(attempts.count)
            let errorCount = attempts.filter { !$0.isCorrect }.count
            let errorRate = Double(errorCount) / Double(attempts.count)
            let correctCount = attempts.count - errorCount
            let mastery = max(0.0, min(1.0, Double(correctCount) / Double(attempts.count) * (1.0 - min(avgTime / 5.0, 0.5))))
            
            return SRSItem(
                operation: question,
                avgTime: avgTime,
                errorRate: errorRate,
                mastery: mastery,
                lastSeen: attempts.first?.timestamp ?? Date()
            )
        }.sorted { $0.mastery < $1.mastery }
    }
    
    private func loadResults() {
        guard let data = UserDefaults.standard.data(forKey: resultsKey),
              let decoded = try? JSONDecoder().decode([GameResult].self, from: data) else {
            return
        }
        results = decoded
    }
    
    private func persistResults() {
        if let encoded = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(encoded, forKey: resultsKey)
        }
    }
}
