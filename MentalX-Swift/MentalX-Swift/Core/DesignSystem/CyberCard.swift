import SwiftUI

struct CyberCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                LinearGradient(
                    colors: [.cardGradientStart, .cardGradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        LinearGradient(
                            colors: [.borderHighlight, .borderSubtle],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            // Inner Highlight (Glassmorphism effect)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    .padding(1)
                    .mask(RoundedRectangle(cornerRadius: 8))
            )
    }
}

#Preview {
    ZStack {
        Color.cyberBackgroundStart
        CyberCard {
            Text("Cyber Component")
                .foregroundStyle(.white)
                .padding()
        }
        .padding()
    }
}
