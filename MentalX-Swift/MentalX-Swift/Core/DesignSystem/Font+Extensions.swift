import SwiftUI

extension Font {
    static let cyberLargeTitle = Font.system(size: 42, weight: .light, design: .default)
    static let cyberTitle = Font.system(size: 28, weight: .bold, design: .default)
    static let cyberBody = Font.system(size: 16, weight: .regular, design: .monospaced)
    static let cyberNumber = Font.system(size: 32, weight: .medium, design: .monospaced)
}

struct CyberTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.cyberTitle)
            .textCase(.uppercase)
            .kerning(1.2)
            .foregroundStyle(Color.textPrimary)
    }
}

extension View {
    func cyberTitle() -> some View {
        modifier(CyberTitleStyle())
    }
}
