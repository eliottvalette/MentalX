import SwiftUI

@main
struct MentalXApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .preferredColorScheme(.dark) // Force dark mode
        }
    }
}
