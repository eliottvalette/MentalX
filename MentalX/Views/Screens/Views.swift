import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {
    @State private var selectedMode: GameMode?
    @State private var isGameActive = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.cyberBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerView
                        
                        // Stats Card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.neonGreen)
                                Text("Neural Precision")
                                    .font(.headline)
                                    .foregroundColor(.textSecondary)
                                Spacer()
                                Text("94/100")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            ActivityChart()
                        }
                        .cyberCardStyle()
                        
                        // Game Modes Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            modeButton(title: "Sprint", icon: "stopwatch", mode: .sprint)
                            modeButton(title: "Marathon", icon: "flame", mode: .marathon)
                            modeButton(title: "Training", icon: "dumbbell", mode: .training)
                        }
                        
                        // Weakness List (SRS Preview)
                        VStack(alignment: .leading) {
                            Text("Algorithm Focus")
                                .font(.headline)
                                .foregroundColor(.textSecondary)
                                .padding(.bottom, 5)
                            
                            HStack {
                                Text("7 x 8")
                                    .font(.monospaced(.body)())
                                Spacer()
                                Text("1.4s avg")
                                    .foregroundColor(.neonRed)
                            }
                            Divider().background(Color.white.opacity(0.1))
                            HStack {
                                Text("12 + 89")
                                    .font(.monospaced(.body)())
                                Spacer()
                                Text("1.8s avg")
                                    .foregroundColor(.neonRed)
                            }
                        }
                        .cyberCardStyle()
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $isGameActive) {
                if let mode = selectedMode {
                    ActiveGameView(mode: mode, isPresented: $isGameActive)
                }
            }
        }
    }
    
    var headerView: some View {
        HStack {
            Text("MENTAL CORE")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.white)
        }
        .padding(.vertical)
    }
    
    func modeButton(title: String, icon: String, mode: GameMode) -> some View {
        Button {
            selectedMode = mode
            isGameActive = true
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cyberCardStyle()
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
