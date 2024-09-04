//
//  Item.swift
//  Perfect Fit
//
//  Created by Howie Long on 9/3/24.
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
