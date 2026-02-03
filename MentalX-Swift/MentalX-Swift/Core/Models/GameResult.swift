import Foundation
import SwiftData

@Model
class GameResult {
    var id: UUID
    var date: Date
    var mode: String  // "Sprint" or "Marathon"
    var score: Int

    init(date: Date = Date(), mode: String, score: Int) {
        self.id = UUID()
        self.date = date
        self.mode = mode
        self.score = score
    }
}
