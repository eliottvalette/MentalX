import SwiftData
import SwiftUI

struct SRSHeatmap: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedOperation: OperationType
    @State private var colorsByID: [String: String] = [:]

    private let multiplicationNumbers = Array(QuestionGenerator.multiplicationOperands)

    var body: some View {
        VStack(spacing: 16) {
            // Segmented Control (Custom)
            HStack {
                TabButton(title: "×", isSelected: selectedOperation == .multiplication) {
                    withAnimation { selectedOperation = .multiplication }
                }
                TabButton(title: "+", isSelected: selectedOperation == .addition) {
                    withAnimation { selectedOperation = .addition }
                }
                TabButton(title: "−", isSelected: selectedOperation == .subtraction) {
                    withAnimation { selectedOperation = .subtraction }
                }
            }
            .padding(4)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Heatmap Content
            switch selectedOperation {
            case .multiplication:
                MultiplicationGrid(colorsByID: colorsByID, numbers: multiplicationNumbers)
            case .addition, .subtraction:
                ArithmeticGrid(colorsByID: colorsByID, operation: selectedOperation)
            }
        }
        .onAppear(perform: loadSnapshot)
        .onChange(of: selectedOperation) {
            loadSnapshot()
        }
    }

    private func loadSnapshot() {
        let operation = selectedOperation.rawValue
        let descriptor = FetchDescriptor<SRSItem>(
            predicate: #Predicate { $0.type == operation }
        )

        do {
            let items = try modelContext.fetch(descriptor)
            colorsByID = Dictionary(
                items.map { item in
                    (item.id, SRSManager.shared.getColor(for: item))
                },
                uniquingKeysWith: { first, _ in first }
            )
        } catch {
            print("SRS heatmap snapshot load failed for \(operation): \(error)")
            colorsByID = [:]
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
    let colorsByID: [String: String]
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
                        let id = SRSItem.identifier(
                            type: OperationType.multiplication.rawValue,
                            op1: row,
                            op2: col
                        )
                        let color = colorsByID[id] ?? SRSManager.shared.getColor(for: nil)
                        CellView(color: Color(hex: color))
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
}

struct ArithmeticGrid: View {
    let colorsByID: [String: String]
    let operation: OperationType

    private let cellWidth: CGFloat = 18
    private let cellHeight: CGFloat = 2.5
    private let cellSpacing: CGFloat = 1

    var body: some View {
        VStack(spacing: 4) {
            Text("1…60 \(operation.symbol) 1…15")
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Canvas { context, size in
                for left in QuestionGenerator.arithmeticLeftOperands {
                    for right in QuestionGenerator.arithmeticRightOperands {
                        let id = SRSItem.identifier(
                            type: operation.rawValue,
                            op1: left,
                            op2: right
                        )
                        let color = Color(hex: colorsByID[id] ?? SRSManager.shared.getColor(for: nil))
                        let rect = CGRect(
                            x: CGFloat(right - 1) * (cellWidth + cellSpacing),
                            y: CGFloat(left - 1) * (cellHeight + cellSpacing),
                            width: cellWidth,
                            height: cellHeight
                        )
                        context.fill(Path(roundedRect: rect, cornerRadius: 0.5), with: .color(color))
                    }
                }
            }
            .frame(
                width: (cellWidth + cellSpacing) * 15,
                height: (cellHeight + cellSpacing) * 60
            )
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
