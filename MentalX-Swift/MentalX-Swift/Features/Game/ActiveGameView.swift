import SwiftUI
import SwiftData

struct ActiveGameView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: GameViewModel
    
    init(mode: GameMode) {
        _viewModel = State(initialValue: GameViewModel(mode: mode, modelContext: nil))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            // Feedback Overlays
            SuccessFlash(color: .neonGreen, trigger: $viewModel.successTrigger)
            SuccessFlash(color: .neonRed, trigger: $viewModel.errorTrigger)
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        viewModel.exitGame()
                        dismiss()
                    }) {
                        Text("Exit")
                            .font(.system(size: 14, weight: .semibold)) // FONTS.body
                            .foregroundStyle(Color.neonRed)
                    }
                    
                    Spacer()
                    
                    if viewModel.mode == .sprint {
                        Text("\(Int(ceil(viewModel.timeRemaining)))s")
                            .font(.system(size: 20, weight: .semibold)) // FONTS.title2
                            .foregroundStyle(viewModel.timeRemaining < 10 ? Color.neonRed : Color.neonGreen)
                    } else if viewModel.mode == .marathon {
                        HStack(spacing: 6) {
                            ForEach(0..<3) { i in
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(i < viewModel.lives ? Color.neonRed : Color.neonRed.opacity(0.3))
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.top, 40) // Matches RN paddingTop: 50 roughly
                
                Spacer()
                
                // Question Area
                VStack(spacing: 10) { // marginBottom: 10 in RN for text
                    if let question = viewModel.currentQuestion {
                        Text(question.text)
                            .font(.system(size: 42, weight: .light)) // FONTS.huge = 42, weight 300
                            .foregroundStyle(Color.textPrimary)
                            .monospacedDigit()
                    }
                    
                    // Input
                    Text(viewModel.input.isEmpty ? "_" : viewModel.input)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Color.neonGreen)
                        .frame(height: 40)
                    
                    Text("Score: \(viewModel.score)")
                        .font(.system(size: 16, weight: .semibold)) // FONTS.headline = 16
                        .foregroundStyle(Color.textSecondary)
                        .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Marathon Progress Bar
                if viewModel.mode == .marathon {
                    let progress = viewModel.timeRemaining / viewModel.totalTime
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                        
                        GeometryReader { geometry in
                            Capsule()
                                .fill(progress > 0.3 ? Color.neonGreen : Color.neonRed)
                                .frame(width: geometry.size.width * CGFloat(max(0, progress)), height: 6)
                                .animation(.linear(duration: 0.1), value: progress)
                        }
                        .frame(height: 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                
                // Keyboard
                NumberPad(
                    onTap: { num in viewModel.submitInput(num) },
                    onDelete: { viewModel.deleteInput() },
                    onToggleSign: { viewModel.toggleInputSign() }
                )
                .padding(.bottom, 30) // Safety padding
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startGame(modelContext: modelContext)
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                viewModel.startTimer()
            } else {
                viewModel.stopTimer()
            }
        }
        .onChange(of: viewModel.isGameOver) {
            if viewModel.isGameOver {
                dismiss() // Simple exit
            }
        }
    }
}
