import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {
    @State private var selectedMode: GameMode?
    @StateObject private var persistence = PersistenceManager.shared
    
    var srsItems: [SRSItem] {
        persistence.calculateSRSItems()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cyberBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerView
                        
                        if !srsItems.isEmpty {
                            CognitiveLoadChart(items: srsItems)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("THREAT LOG")
                                    .font(.caption)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.textSecondary)
                                    .padding(.leading, 4)
                                
                                ForEach(srsItems.filter { $0.status == .critical || $0.status == .unstable }.prefix(4)) { item in
                                    SRSListRow(item: item)
                                }
                            }
                        }
                        
                        VStack(spacing: 12) {
                            modeButton(title: "Sprint", subtitle: "60s max score", icon: "stopwatch", mode: .sprint)
                            modeButton(title: "Marathon", subtitle: "Until first error", icon: "flame", mode: .marathon)
                            modeButton(title: "Training", subtitle: "SRS adaptive", icon: "dumbbell", mode: .training)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedMode) { mode in
                ActiveGameView(mode: mode, isPresented: Binding(
                    get: { selectedMode != nil },
                    set: { if !$0 { selectedMode = nil } }
                ))
            }
        }
    }
    
    var headerView: some View {
        HStack {
            Text("MENTAL CORE")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical)
    }
    
    func modeButton(title: String, subtitle: String, icon: String, mode: GameMode) -> some View {
        Button {
            selectedMode = mode
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.neonGreen)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.cyberCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

// MARK: - Active Game View
struct ActiveGameView: View {
    @StateObject var viewModel: GameViewModel
    @Binding var isPresented: Bool
    
    init(mode: GameMode, isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: GameViewModel(mode: mode))
        _isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            Color.cyberBackground.ignoresSafeArea()
            
            VStack {
                // Top Bar
                HStack {
                    Button("Exit") { isPresented = false }
                        .foregroundColor(.neonRed)
                    Spacer()
                    if viewModel.gameMode == .sprint {
                        Text(String(format: "%.0fs", viewModel.timeRemaining))
                            .font(.monospaced(.title2)())
                            .foregroundColor(viewModel.timeRemaining < 10 ? .neonRed : .neonGreen)
                    }
                }
                .padding()
                
                Spacer()
                
                // Question Display
                VStack(spacing: 10) {
                    if let question = viewModel.currentQuestion {
                        Text(question.text)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    // Input Display
                    Text(viewModel.input.isEmpty ? "_" : viewModel.input)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.neonGreen)
                        .frame(height: 40)
                }
                
                Spacer()
                
                // Score
                Text("Score: \(viewModel.score)")
                    .font(.headline)
                    .foregroundColor(.textSecondary)
                
                // Numpad
                NumberPadView(onTap: { num in
                    viewModel.submitInput(num)
                }, onDelete: {
                    viewModel.deleteInput()
                })
            }
            
            // Game Over Overlay
            if viewModel.isGameOver {
                Color.black.opacity(0.8).ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("SESSION ENDED")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                    
                    Text("Final Score: \(viewModel.score)")
                        .font(.title2)
                        .foregroundColor(.neonGreen)
                    
                    Button("Close") {
                        isPresented = false
                    }
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
            }
        }
    }
}
