import Foundation
import SwiftData

@Model
final class SRSItem {
    @Attribute(.unique) var id: String  // Format: "type:op1:op2" (e.g., "mult:7:8")
    var type: String
    var op1: Int
    var op2: Int

    // SRS Stats
    var interval: Int  // Days
    var repetition: Int
    var easeFactor: Double
    var dueDate: Date

    init(type: String, op1: Int, op2: Int) {
        self.type = type
        self.op1 = op1
        self.op2 = op2
        self.id = Self.identifier(type: type, op1: op1, op2: op2)

        // Initial SM-2 values
        self.interval = 0
        self.repetition = 0
        self.easeFactor = 2.5
        self.dueDate = Date()
    }

    static func identifier(type: String, op1: Int, op2: Int) -> String {
        if type == OperationType.addition.rawValue || type == OperationType.multiplication.rawValue {
            return "\(type):\(min(op1, op2)):\(max(op1, op2))"
        }

        return "\(type):\(op1):\(op2)"
    }
}
