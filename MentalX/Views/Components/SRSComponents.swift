import SwiftUI
import Charts
import Foundation

enum SRSStatus: String, CaseIterable {
    case critical = "CRITICAL"
    case unstable = "UNSTABLE"
    case stable = "STABLE"
    
    var color: Color {
        switch self {
        case .critical: return .neonRed
        case .unstable: return .orange
        case .stable: return .neonGreen
        }
    }
}

struct SRSItem: Identifiable {
    let id = UUID()
    let operation: String
    let avgTime: Double
    let errorRate: Double
    let mastery: Double
    let lastSeen: Date
    
    var status: SRSStatus {
        if mastery < 0.4 { return .critical }
        if mastery < 0.8 { return .unstable }
        return .stable
    }
}

struct CognitiveLoadChart: View {
    let items: [SRSItem]
    
    var criticalCount: Int { items.filter { $0.status == .critical }.count }
    var unstableCount: Int { items.filter { $0.status == .unstable }.count }
    var stableCount: Int { items.filter { $0.status == .stable }.count }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.neonRed)
                Text("Cognitive Vulnerabilities")
                    .font(.headline)
                    .foregroundColor(.textSecondary)
                Spacer()
                Text("\(criticalCount)")
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            GeometryReader { geo in
                HStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.neonRed)
                        .frame(width: width(for: criticalCount, total: items.count, in: geo.size.width))
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: width(for: unstableCount, total: items.count, in: geo.size.width))
                    Rectangle()
                        .fill(Color.neonGreen)
                        .frame(width: width(for: stableCount, total: items.count, in: geo.size.width))
                }
            }
            .frame(height: 6)
            .cornerRadius(3)
            .padding(.vertical, 8)
            
            HStack(spacing: 20) {
                legendItem(label: "Critical", color: .neonRed, value: criticalCount)
                legendItem(label: "Review", color: .orange, value: unstableCount)
                Spacer()
                Text("Total: \(items.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.cyberCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
    
    private func width(for count: Int, total: Int, in width: CGFloat) -> CGFloat {
        guard total > 0 else { return 0 }
        return (CGFloat(count) / CGFloat(total)) * width
    }
    
    private func legendItem(label: String, color: Color, value: Int) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.caption).foregroundColor(.textSecondary)
            Text("\(value)").font(.caption).bold().foregroundColor(.white)
        }
    }
}

struct SRSListRow: View {
    let item: SRSItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .stroke(item.status.color.opacity(0.3), lineWidth: 2)
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconForStatus(item.status))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(item.status.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.operation)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    Text("\(String(format: "%.1fs", item.avgTime)) avg")
                        .foregroundColor(item.avgTime > 3.0 ? .neonRed : .textSecondary)
                    Text("•")
                        .foregroundColor(.gray)
                    Text("Err: \(Int(item.errorRate * 100))%")
                        .foregroundColor(item.errorRate > 0.1 ? .neonRed : .textSecondary)
                }
                .font(.caption)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(item.mastery * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(item.status.color)
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 80, height: 6)
                    
                    Capsule()
                        .fill(item.status.color)
                        .frame(width: 80 * CGFloat(item.mastery), height: 6)
                }
            }
        }
        .padding()
        .background(Color.cyberCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.status == .critical ? Color.neonRed.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
        )
    }
    
    func iconForStatus(_ status: SRSStatus) -> String {
        switch status {
        case .critical: return "exclamationmark"
        case .unstable: return "arrow.triangle.2.circlepath"
        case .stable: return "checkmark"
        }
    }
}
