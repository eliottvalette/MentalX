import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // For keypad taps (crisp, short tick)
    func playKeypadTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // For valid answers or mode selection (heavier thud)
    func playSuccess() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // For wrong answers or game over (distinct double vibration)
    func playError() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // For high score or special event (long success vibration)
    func playVictory() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}
