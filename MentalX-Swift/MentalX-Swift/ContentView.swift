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
                SRSManager.shared.deduplicate(in: modelContext)
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SRSItem.self, inMemory: true)
}
