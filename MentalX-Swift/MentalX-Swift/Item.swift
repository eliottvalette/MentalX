//
//  Item.swift
//  MentalX-Swift
//
//  Created by Eliott VALETTE on 02/02/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
