import SwiftUI
import UIKit  // For Haptics

struct NumberPad: View {
    var onTap: (String) -> Void
    var onDelete: () -> Void
    var onToggleSign: () -> Void

    // Optimized for latency: Persistent generator
    @State private var impactMed = UIImpactFeedbackGenerator(style: .medium)

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(1...9, id: \.self) { number in
                NumberButton(label: "\(number)") {
                    triggerHaptic()
                    onTap("\(number)")
                }
            }

            // Bottom Row
            NumberButton(label: "±") {
                triggerHaptic()
                onToggleSign()
            }

            NumberButton(label: "0") {
                triggerHaptic()
                onTap("0")
            }

            Button(action: {
                triggerHaptic()
                onDelete()
            }) {
                Image(systemName: "delete.left.fill")
                    .font(.title2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1.2, contentMode: .fit)
                    .foregroundStyle(Color.neonRed)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .onAppear {
            impactMed.prepare()
        }
    }

    private func triggerHaptic() {
        impactMed.impactOccurred()
        // Re-prepare for next tap (best practice for sequences)
        impactMed.prepare()
    }
}

struct NumberButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.cyberNumber)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1.2, contentMode: .fit)
                .foregroundStyle(Color.white)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

#Preview {
    ZStack {
        Color.black
        NumberPad(onTap: { _ in }, onDelete: {}, onToggleSign: {})
    }
}
