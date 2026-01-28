import SwiftUI

// MARK: - Color Extensions
extension Color {
    // Main background (very dark grey, almost black)
    static let cyberBackground = Color(red: 0.04, green: 0.04, blue: 0.04)
    
    // Card background (slightly lighter)
    static let cyberCard = Color(red: 0.11, green: 0.11, blue: 0.12)
    
    // Accents
    static let neonGreen = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let neonRed = Color(red: 1.0, green: 0.23, blue: 0.19)
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
}

// MARK: - View Modifiers
struct CyberCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.cyberCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func cyberCardStyle() -> some View {
        self.modifier(CyberCardModifier())
    }
}
