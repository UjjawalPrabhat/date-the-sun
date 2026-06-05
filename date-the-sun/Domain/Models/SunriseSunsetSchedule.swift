//
//  SunriseSunsetSchedule.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import SwiftData
import Foundation

@Model
class SunriseSunsetSchedule {
    var sunrise: Date
    var sunset: Date
    
    init(sunrise: Date, sunset: Date) {
        self.sunrise = sunrise
        self.sunset = sunset
    }
}
