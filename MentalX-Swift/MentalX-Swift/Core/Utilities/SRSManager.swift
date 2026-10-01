import Foundation
import SwiftData

class SRSManager {
    static let shared = SRSManager()

    func quality(forResponseTime responseTime: TimeInterval, hadIncorrectAttempt: Bool) -> Int {
        precondition(responseTime >= 0, "Response time must be nonnegative.")

        if hadIncorrectAttempt { return 0 }
        if responseTime < 0.5 { return 5 }
        if responseTime < 1 { return 4 }
        if responseTime < 3 { return 2 }
        return 1
    }

    // Deduplication logic to clean corrupted DB
    func deduplicate(in context: SwiftData.ModelContext) {
        do {
            // Fetch all items
            // Ideally we'd use a more efficient query but for cleanup this is fine
            let descriptor = FetchDescriptor<SRSItem>()
            let items = try context.fetch(descriptor)

            // Group by ID
            let grouped = Dictionary(grouping: items, by: { $0.id })

            var deletedCount = 0

            for (id, duplicates) in grouped {
                if duplicates.count > 1 {
                    // Keep the one with highest progress (interval)
                    let sorted = duplicates.sorted { $0.interval > $1.interval }
                    let toKeep = sorted.first!
                    let toDelete = sorted.dropFirst()

                    for item in toDelete {
                        context.delete(item)
                        deletedCount += 1
                    }
                    print(
                        "Deduplicated \(id): Kept interval \(toKeep.interval), removed \(toDelete.count) copies."
                    )
                }
            }

            if deletedCount > 0 {
                try context.save()
                print("SRSManager: Cleaned up \(deletedCount) duplicate items.")
            }

        } catch {
            print("SRSManager Deduplication Failed: \(error)")
        }
    }

    func updateItem(_ item: SRSItem, quality: Int) {
        precondition((0...5).contains(quality), "SRS quality must be between 0 and 5.")

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
