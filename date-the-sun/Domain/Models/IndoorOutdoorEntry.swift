//
//  IndoorOutdoorClassificationEntry.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 04/06/26.
//

import Foundation
import SwiftData

/// Result of classification from MapTileClassficiation
@Model
class IndoorOutdoorEntry {
    var identifier: String
    var confidence: Double
    var provider: String /// A, G
    var timestamp: Date
    
    init(identifier: String, confidence: Double, provider: String, timestamp: Date) {
        self.identifier = identifier
        self.confidence = confidence
        self.provider = provider
        self.timestamp = timestamp
    }
}
