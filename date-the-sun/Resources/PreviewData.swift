//
//  PreviewData.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 05/06/26.
//

import Foundation

#if DEBUG
enum PreviewData { // as static
    static let cal = Calendar.current
    static let today = Date.now
    static func t(_ h: Int, _ m: Int = 0) -> Date {
        cal.date(bySettingHour: h, minute: m, second: 0, of: today)!
    }
    /// 10 am – 2 pm UV peak window (UV ≥ 6), representative of a sunny summer day.
    static let uvPeakWindow: (startMinute: Double, endMinute: Double) = (startMinute: 600, endMinute: 840)

    static let observations: [HMMObservation] = [
        .init(classifierLabel: "indoor",  classifierConfidence: 0.95, provider: "A",  speed: 0.0, horizontalAccuracy: 4,  isMeasured: true, timestamp: t(0)),
        .init(classifierLabel: "indoor",  classifierConfidence: 0.91, provider: "A",  speed: 0.0, horizontalAccuracy: 4,  isMeasured: true, timestamp: t(6)),
        .init(classifierLabel: "outdoor", classifierConfidence: 0.83, provider: "AG", speed: 1.4, horizontalAccuracy: 9,  isMeasured: true, timestamp: t(8, 15)),
        .init(classifierLabel: "indoor",  classifierConfidence: 0.88, provider: "A",  speed: 0.0, horizontalAccuracy: 5,  isMeasured: true, timestamp: t(9, 30)),
        .init(classifierLabel: "outdoor", classifierConfidence: 0.79, provider: "G",  speed: 1.1, horizontalAccuracy: 11, isMeasured: true, timestamp: t(12, 0)),
        .init(classifierLabel: "outdoor", classifierConfidence: 0.85, provider: "AG", speed: 0.9, horizontalAccuracy: 8,  isMeasured: true, timestamp: t(13, 15)),
        .init(classifierLabel: "indoor",  classifierConfidence: 0.93, provider: "A",  speed: 0.0, horizontalAccuracy: 4,  isMeasured: true, timestamp: t(14, 30)),
        .init(classifierLabel: "outdoor", classifierConfidence: 0.76, provider: "G",  speed: 1.8, horizontalAccuracy: 13, isMeasured: true, timestamp: t(17, 0)),
        .init(classifierLabel: "indoor",  classifierConfidence: 0.89, provider: "A",  speed: 0.0, horizontalAccuracy: 5,  isMeasured: true, timestamp: t(18, 45)),
        .init(classifierLabel: "outdoor", classifierConfidence: 0.71, provider: "AG", speed: 0.6, horizontalAccuracy: 10, isMeasured: true, timestamp: t(20, 0)),
        .init(classifierLabel: "indoor",  classifierConfidence: 0.97, provider: "A",  speed: 0.0, horizontalAccuracy: 3,  isMeasured: true, timestamp: t(21, 30)),
    ]
}
#endif
