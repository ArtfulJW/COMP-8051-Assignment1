//
//  Item.swift
//  COMP-8051-Lab2
//
//  Created by Jay Wang on 2024-01-19.
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
