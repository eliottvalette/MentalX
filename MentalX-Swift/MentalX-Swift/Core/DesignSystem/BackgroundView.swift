import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            // Gradient matching RN: locations [0, 0.2]
            LinearGradient(
                stops: [
                    .init(color: .cyberBackgroundStart, location: 0.0),
                    .init(color: .cyberBackgroundEnd, location: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Grid Overlay
            GridOverlay()
        }
    }
}

struct GridOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vertical Lines (6 lines from RN)
                HStack(spacing: 0) {
                    ForEach(0..<6) { _ in
                        Spacer()
                        Rectangle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 1)
                    }
                    Spacer()
                }
                
                // Horizontal Lines (10 lines from RN)
                VStack(spacing: 0) {
                    ForEach(0..<10) { _ in
                        Spacer()
                        Rectangle()
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 1)
                    }
                    Spacer()
                }
            }
            .opacity(0.3) // From RN styles.gridContainer opacity
        }
        .ignoresSafeArea()
    }
}
