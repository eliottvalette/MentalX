import SwiftUI

struct SuccessFlash: View {
    let color: Color
    @Binding var trigger: Int // Increment to trigger animation derived state
//    
//    // Internal state to handle animation reset
//    @State private var opacity: Double = 0
//    
    var body: some View {
        // Simple overlay that flashes
        // Implementation logic depends on how it's called.
        // For a binding trigger, we can use .onChange
        
        Color.clear
            .overlay(
                color
                    .ignoresSafeArea()
                    .opacity(trigger > 0 ? 0 : 0) // Placeholder logic, controlled by modifier usually
            )
            .modifier(FlashModifier(trigger: trigger, color: color))
    }
}

struct FlashModifier: ViewModifier {
    var trigger: Int
    var color: Color
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        ZStack {
            content
            color
                .ignoresSafeArea()
                .opacity(opacity)
                .allowsHitTesting(false)
        }
        .onChange(of: trigger) {
            guard trigger > 0 else { return }
            opacity = 0.3
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
            }
        }
    }
}
