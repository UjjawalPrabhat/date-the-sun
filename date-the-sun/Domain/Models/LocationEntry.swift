//
//  LocationEntry.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 04/06/26.
//

import Foundation
import SwiftData
import CoreLocation

@Model
class LocationEntry {
    var latitude: Double
    var longitude: Double
    var horizontalAccuracy: Double
    var speed: Double
    var course: Double
    var altitude: Double
    var timestamp: Date
    
    init(latitude: Double, longitude: Double, horizontalAccuracy: Double, speed: Double, course: Double, altitude: Double, timestamp: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
        self.speed = speed
        self.course = course
        self.altitude = altitude
        self.timestamp = timestamp
    }
}
