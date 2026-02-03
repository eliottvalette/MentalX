import SwiftData
import SwiftUI

struct SRSHeatmap: View {
    @Query private var srsItems: [SRSItem]
    @State private var selectedTab: OperationType = .multiplication

    // RN: 1..15
    // RN: 1..15, excluding 10
    private let multiplicationNumbers = [2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15]
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
                AdditionGrid(items: srsItems)
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
    // ranges unused now, we implicitly do 10 blocks of 10

    // Grid Config
    let blockSize: CGFloat = 31  // 10x10 pixels + margins (~3px per pixel)
    let pixelSize: CGFloat = 2.4
    let blockSpacing: CGFloat = 2
    let pixelSpacing: CGFloat = 0.5

    // Cache map for efficient lookup
    // Key: "op1:op2"
    // Cache map for efficient lookup
    // Key: "op1:op2" where op1 <= op2 (Normalized)
    var itemMap: [String: SRSItem] {
        Dictionary(
            items.filter { $0.type == "addition" }.map { item in
                let minOp = min(item.op1, item.op2)
                let maxOp = max(item.op1, item.op2)
                return ("\(minOp):\(maxOp)", item)
            },
            uniquingKeysWith: { first, _ in first }
        )
    }

    var body: some View {
        VStack(spacing: 4) {
            // Legend / Info
            Text("100x100 Grid (10,000 Operations)")
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)

            Canvas { context, size in
                // 10x10 Blocks
                for blockRow in 0..<10 {  // 0..9 (representing 1-10, 11-20...)
                    for blockCol in 0..<10 {

                        let blockX = CGFloat(blockCol) * (blockSize + blockSpacing)
                        let blockY = CGFloat(blockRow) * (blockSize + blockSpacing)

                        // Within each block, 10x10 pixels
                        for row in 0..<10 {
                            for col in 0..<10 {
                                let pixelX = blockX + CGFloat(col) * (pixelSize + pixelSpacing)
                                let pixelY = blockY + CGFloat(row) * (pixelSize + pixelSpacing)

                                // Calculate actual numbers (1-indexed)
                                // Block 0 -> 1..10.
                                // Inside Block 0: row 0 -> 1.
                                let op1 = (blockRow * 10) + row + 1
                                let op2 = (blockCol * 10) + col + 1

                                // Lookup
                                // Commutativity check for coloring
                                let minOp = min(op1, op2)
                                let maxOp = max(op1, op2)
                                let key = "\(minOp):\(maxOp)"

                                var color: Color = Color(hex: "#1C1C1E")  // Default empty

                                if let item = itemMap[key] {
                                    // Use Manager color logic ideally, currently approximating based on interval as before
                                    let srsColor = SRSManager.shared.getColor(for: item)
                                    color = Color(hex: srsColor)
                                }

                                // Draw Pixel
                                let rect = CGRect(
                                    x: pixelX, y: pixelY, width: pixelSize, height: pixelSize)
                                context.fill(
                                    Path(roundedRect: rect, cornerRadius: 0.5), with: .color(color))
                            }
                        }
                    }
                }
            }
            .frame(width: (blockSize + blockSpacing) * 10, height: (blockSize + blockSpacing) * 10)
        }
        .padding(10)
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
