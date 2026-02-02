import SwiftUI

extension Color {
    // Theme Colors from RN (constants/theme.ts)
    static let cyberBackgroundStart = Color(hex: "#373737")
    static let cyberBackgroundEnd = Color(hex: "#050505")
    
    static let cardGradientStart = Color(hex: "#141415").opacity(0.67) // #141415aa
    static let cardGradientEnd = Color(hex: "#070707").opacity(0.67)   // #070707aa
    
    static let neonGreen = Color(hex: "#28D966")
    static let neonRed = Color(hex: "#FF453A")
    static let orange = Color(hex: "#FF9F0A")
    
    static let textPrimary = Color(hex: "#F2F2F2")
    static let textSecondary = Color(hex: "#8F8F92")
    
    static let borderSubtle = Color.white.opacity(0.06)
    static let borderHighlight = Color.white.opacity(0.1)
    
    static let cyberCard = Color(hex: "#1C1C1E")
}

// Hex Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
