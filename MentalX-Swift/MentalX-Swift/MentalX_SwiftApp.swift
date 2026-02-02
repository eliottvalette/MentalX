//
//  MentalX_SwiftApp.swift
//  MentalX-Swift
//
//  Created by Eliott VALETTE on 02/02/2026.
//

import SwiftData
import SwiftUI

@main
struct MentalX_SwiftApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SRSItem.self)
    }
}
