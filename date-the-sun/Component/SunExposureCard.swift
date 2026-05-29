//
//  SunExposureCard.swift
//  date-the-sun
//
//  Created by Heryan Djaruma on 29/05/26.
//

import SwiftUI

struct SunExposureCard: View {
    @State var clockDataPoints: [ClockDataPoint] = [
        .init(isOutdoor: false, startMinute: 1 * 60, endMinute: 4 * 60, isAM: true),
        .init(isOutdoor: true, startMinute: (4 * 60) , endMinute: (4 * 60) + 30, isAM: true),
        .init(isOutdoor: false, startMinute: (4 * 60) + 30, endMinute: (6 * 60) + 30, isAM: true),
        .init(isOutdoor: true, startMinute: (6 * 60) + 30, endMinute: (9 * 60) + 30, isAM: true),
        .init(isOutdoor: false, startMinute: (9 * 60) + 30, endMinute: 11 * 60, isAM: true),
    ]
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "sun.max.fill")
                Text("Sun Exposure")
                Spacer()
                Image(systemName: "info.circle.fill")
            }
            .padding()
            .foregroundStyle(.white)
            .background(.black)
            
            IndoorOutdoorClock(clockDataPoints: clockDataPoints)
            
            HStack {
                HStack {
                    Circle()
                        .foregroundStyle(.indoor)
                        .frame(width: 10, height: 10)
                    Text("Indoor Time")
                }
                HStack {
                    Circle()
                        .foregroundStyle(.outdoor)
                        .frame(width: 10, height: 10)
                    Text("Outdoor Time")
                }
                HStack {
                    Circle()
                        .foregroundStyle(.vermillion)
                        .frame(width: 10, height: 10)
                    Text("Peak UV Index")
                }
            }
        }
        .background(.shrek)
    }
}

#Preview {
//    let data: [ClockDataPoint] =
//    SunExposureCard(clockDataPoints: data)
    SunExposureCard()
}
