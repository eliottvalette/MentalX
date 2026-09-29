import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query private var srsItems: [SRSItem]
    @Query private var gameResults: [GameResult]

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header: MENTAL CORE
                        HStack {
                            Text("MENTAL CORE")
                                .font(.system(size: 22, weight: .semibold))
                                .tracking(2)
                                .foregroundStyle(Color.textPrimary)
                            Spacer()
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 2)

                        // SRS Heatmap (No Cognitive Chart!)
                        CyberCard {
                            SRSHeatmap()
                        }

                        // Action Modes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SELECT PROTOCOL")
                                .font(.system(size: 10, weight: .semibold))
                                .tracking(1)
                                .foregroundStyle(Color.textSecondary)
                                .padding(.leading, 4)

                            GameModeButton(
                                mode: .sprint,
                                title: "Sprint",
                                subtitle: "60s Time Attack",
                                stat: highScore(for: .sprint),
                                icon: "bolt.fill",  // Zap equivalent
                                color: .textPrimary
                            )

                            GameModeButton(
                                mode: .marathon,
                                title: "Marathon",
                                subtitle: "3 Lives • 10s Limit",
                                stat: highScore(for: .marathon),
                                icon: "flame.fill",
                                color: .textPrimary
                            )

                            GameModeButton(
                                mode: .training,
                                title: "Training",
                                subtitle: "Adaptive Learning",
                                stat: "SRS",
                                icon: "brain.head.profile",
                                color: .textPrimary
                            )
                        }
                    }
                    .padding(16)
                    .padding(.top, 12)  // Reduced from 40
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func highScore(for mode: GameMode) -> String {
        let score = gameResults
            .filter { $0.mode == mode.rawValue }
            .map(\.score)
            .max() ?? 0
        return "\(score) pts"
    }
}

struct GameModeButton: View {
    let mode: GameMode
    let title: String
    let subtitle: String
    let stat: String
    let icon: String
    let color: Color

    var body: some View {
        NavigationLink(destination: ActiveGameView(mode: mode)) {
            HStack(spacing: 16) {
                // Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.textPrimary)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                // Stat Badge
                Text(stat)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.neonGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.neonGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.cardGradientStart, Color.cardGradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.borderSubtle, lineWidth: 1)
            )
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [SRSItem.self, GameResult.self], inMemory: true)
}
