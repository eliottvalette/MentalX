import SwiftUI
import Charts

// MARK: - Custom Keypad
struct NumberPadView: View {
    let onTap: (String) -> Void
    let onDelete: () -> Void
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(1...9, id: \.self) { num in
                Button {
                    HapticManager.shared.playKeypadTap()
                    onTap("\(num)")
                } label: {
                    Text("\(num)")
                        .font(.title)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color.cyberCard)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
            }
            
            // Empty placeholder
            Color.clear
            
            Button {
                HapticManager.shared.playKeypadTap()
                onTap("0")
            } label: {
                Text("0")
                    .font(.title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.cyberCard)
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
            
            Button {
                HapticManager.shared.playKeypadTap()
                onDelete()
            } label: {
                Image(systemName: "delete.left")
                    .font(.title2)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.cyberCard)
                    .cornerRadius(12)
                    .foregroundColor(.neonRed)
            }
        }
        .padding()
    }
}

// MARK: - Mini Chart View (For Dashboard)
struct ActivityChart: View {
    // Mock data for UI viz
    let data: [Double] = [40, 55, 30, 80, 45, 90, 60]
    
    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Day", index),
                    y: .value("Score", value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.neonGreen)
                
                AreaMark(
                    x: .value("Day", index),
                    y: .value("Score", value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.neonGreen.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 60)
    }
}
