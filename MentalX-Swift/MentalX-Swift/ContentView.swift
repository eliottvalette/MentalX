//
//  ContentView.swift
//  MentalX-Swift
//
//  Created by Eliott VALETTE on 02/02/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        DashboardView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SRSItem.self, inMemory: true)
}
