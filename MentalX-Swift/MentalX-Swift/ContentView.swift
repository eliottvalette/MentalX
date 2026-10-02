//
//  ContentView.swift
//  MentalX-Swift
//
//  Created by Eliott VALETTE on 02/02/2026.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        DashboardView()
            .onAppear {
                do {
                    let didReset = try SRSManager.shared.resetOutdatedProgressIfNeeded(
                        in: modelContext
                    )
                    if !didReset {
                        SRSManager.shared.deduplicate(in: modelContext)
                    }
                } catch {
                    print("SRS scoring migration failed: \(error)")
                }
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [SRSItem.self, GameResult.self], inMemory: true)
}
