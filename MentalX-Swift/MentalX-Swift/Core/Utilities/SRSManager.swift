import Foundation

class SRSManager {
    static let shared = SRSManager()

    // Quality: 0-5
    // 5 = Perfect response (fast)
    // 3-4 = Correct (slower)
    // 0-2 = Incorrect

    func updateItem(_ item: SRSItem, quality: Int) {
        if quality >= 3 {
            // Correct response
            if item.repetition == 0 {
                item.interval = 1
            } else if item.repetition == 1 {
                item.interval = 6
            } else {
                item.interval = Int(Double(item.interval) * item.easeFactor)
            }
            item.repetition += 1
        } else {
            // Incorrect response
            item.repetition = 0
            item.interval = 1
        }

        // Update Ease Factor (standard SM-2 formula)
        // EF' = EF + (0.1 - (5-q)*(0.08 + (5-q)*0.02))
        let q = Double(quality)
        var newEF = item.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        if newEF < 1.3 { newEF = 1.3 }  // Threshold

        item.easeFactor = newEF

        // Calculate new due date
        // For testing purposes, hours instead of days could be used, but standard is days.
        let nextDate =
            Calendar.current.date(byAdding: .day, value: item.interval, to: Date()) ?? Date()
        item.dueDate = nextDate
    }

    // Calculates heat color based on SRS status
    // Returns hex color string or Swift Color if needed (string for now for logic separation)
    func getColor(for item: SRSItem?) -> String {
        guard let item = item else { return "#1C1C1E" }  // Empty state matches RN CyberCard

        // Use Theme Colors for consistency
        if item.interval > 21 {
            return "#28D966"  // Theme Neon Green (Mastered)
        } else if item.interval > 7 {
            return "#28D966"  // Theme Neon Green (learning towards mastered, simplified)
            // Or Keep lighter green if needed, but user wanted palette consistency.
            // Let's use opacity in View or just distinct shades if we knew them.
            // For now, let's stick to the Theme Palette:
        } else if item.interval > 1 {
            return "#FF9F0A"  // Theme Orange (Learning)
        } else {
            return "#FF453A"  // Theme Neon Red (Unstable/New)
        }
    }
}
