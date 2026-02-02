import SwiftData
import SwiftUI

struct SRSHeatmap: View {
    @Query private var srsItems: [SRSItem]
    @State private var selectedTab: OperationType = .multiplication

    // RN: 1..15
    private let multiplicationNumbers = Array(1...15)
    // 5x5 Ranges (Full)
    private let additionRanges = [
        "1-10", "11-20", "21-30", "31-40", "41-50",
        "51-60", "61-70", "71-80", "81-90", "91-99",
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Segmented Control (Custom)
            HStack {
                TabButton(title: "× Multiplication", isSelected: selectedTab == .multiplication) {
                    withAnimation { selectedTab = .multiplication }
                }
                TabButton(title: "+ Addition", isSelected: selectedTab == .addition) {
                    withAnimation { selectedTab = .addition }
                }
            }
            .padding(4)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Heatmap Content
            if selectedTab == .multiplication {
                MultiplicationGrid(items: srsItems, numbers: multiplicationNumbers)
            } else {
                AdditionGrid(items: srsItems, ranges: additionRanges)
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.neonGreen.opacity(0.2) : Color.clear)
                .foregroundStyle(isSelected ? Color.neonGreen : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            isSelected ? Color.neonGreen.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        }
    }
}

struct MultiplicationGrid: View {
    let items: [SRSItem]
    let numbers: [Int]

    // RN sizes: 18px cell + 1px margin/side -> 20px total width
    let cellSize: CGFloat = 18
    let headerSize: CGFloat = 8  // Font size

    var body: some View {
        VStack(spacing: 2) {
            // Header Row
            HStack(spacing: 2) {
                Color.clear.frame(width: cellSize, height: cellSize)  // Corner
                ForEach(numbers, id: \.self) { num in
                    Text("\(num)")
                        .font(.system(size: headerSize, weight: .bold, design: .monospaced))
                        .frame(width: cellSize, height: cellSize)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            // Rows
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 2) {
                    Text("\(row)")
                        .font(.system(size: headerSize, weight: .bold, design: .monospaced))
                        .frame(width: cellSize, height: cellSize)
                        .foregroundStyle(Color.textSecondary)

                    ForEach(numbers, id: \.self) { col in
                        // Commutativity: Check normalized ID
                        let minOp = min(row, col)
                        let maxOp = max(row, col)
                        let item = items.first { $0.id == "multiplication:\(minOp):\(maxOp)" }
                        CellView(color: Color(hex: SRSManager.shared.getColor(for: item)))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
}

struct AdditionGrid: View {
    let items: [SRSItem]
    let ranges: [String]

    // User styling: Compact!
    // Reduced from 35 to 30. (Fits "96-99" with small font)
    let cellWidth: CGFloat = 28
    let cellHeight: CGFloat = 28
    let headerSize: CGFloat = 7

    // Logic to find average mastery for a range and return color
    func getColorForRange(row: String, col: String) -> Color {
        let r1 = parseRange(row)
        let r2 = parseRange(col)

        // Optim: Pre-filtering or efficient map would be better but this works for MVVM
        let relevantItems = items.filter { item in
            item.type == "addition"
                && ((item.op1 >= r1.0 && item.op1 <= r1.1 && item.op2 >= r2.0 && item.op2 <= r2.1)
                    || (item.op2 >= r1.0 && item.op2 <= r1.1 && item.op1 >= r2.0
                        && item.op1 <= r2.1))
        }

        if relevantItems.isEmpty {
            return Color(hex: "#1C1C1E")  // Dark empty state
        }

        let avgMastery =
            relevantItems.reduce(0.0) { sum, item in
                // Mapping interval to mastery logic roughly
                // RN code used item.mastery directly.
                // We store interval. Let's approx:
                // 0 -> 0, 21+ -> 1.0
                let m = min(1.0, Double(item.interval) / 21.0)
                return sum + m
            } / Double(relevantItems.count)

        // Use srsAlgorithm color logic or simple threshold
        if avgMastery > 0.9 { return Color.neonGreen }
        if avgMastery > 0.7 { return Color.neonGreen.opacity(0.7) }
        if avgMastery > 0.4 { return Color.orange }
        return Color.neonRed
    }

    func parseRange(_ range: String) -> (Int, Int) {
        let parts = range.split(separator: "-")
        if parts.count == 2, let min = Int(parts[0]), let max = Int(parts[1]) {
            return (min, max)
        }
        return (0, 0)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 2) {
                // Header Row
                HStack(spacing: 2) {
                    Color.clear.frame(width: cellWidth, height: 20)
                    ForEach(ranges, id: \.self) { range in
                        Text(range)
                            .font(.system(size: headerSize, weight: .bold))
                            .frame(width: cellWidth, height: 20)
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                // Rows
                ForEach(ranges, id: \.self) { row in
                    HStack(spacing: 2) {
                        Text(row)
                            .font(.system(size: headerSize, weight: .bold))
                            .frame(width: cellWidth, height: 20)
                            .foregroundStyle(Color.textSecondary)

                        ForEach(ranges, id: \.self) { col in
                            // getColorForRange already handles bidirectional check
                            CellView(color: getColorForRange(row: row, col: col))
                                .frame(width: cellWidth, height: cellHeight)
                        }
                    }
                }
            }
            .padding(.trailing)  // Keep trailing
            .padding(.leading, 10)  // Reduced leading (was default ~16)
        }
    }
}

struct CellView: View {
    let color: Color

    var body: some View {
        Color.clear
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 3))
        // Frame is controlled by parent
    }
}
