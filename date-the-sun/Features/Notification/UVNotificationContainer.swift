//
//  UVNotificationContainer.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 07/06/26.
//

import SwiftUI
import SwiftData

// MARK: - Interactive Preview Harness
struct UVNotificationContainer: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailySunSummary.date, order: .reverse) private var summaries: [DailySunSummary]
    
    let uvValue: Int
    
    // Determine context dynamically based on current UV values
    
    var body: some View {
        let todaysSummary = summaries.first(where: { Calendar.current.isDateInToday($0.date) })
        
        VStack(spacing: 12) {
            UVNotificationWidget(
                onLazyTap: {
                    NotificationResponseManager.handleLazyTap(
                        summary: todaysSummary,
                        modelContext: modelContext
                    )
                },
                onDoneTap: {
                    NotificationResponseManager.handleDoneTap(
                        summary: todaysSummary,
                        modelContext: modelContext
                    )
                },
                value: uvValue
            )
            
            // Debug text view showing SwiftData changes in real-time inside the preview canvas!
            VStack(alignment: .leading, spacing: 4) {
                Text("Database Real-time Status:")
                    .font(.caption).bold().foregroundColor(.secondary)
                Text("Wear Sunscreen: \(todaysSummary?.wearSunscreen.description ?? "nil")")
                Text("Wear Protective Clothing: \(todaysSummary?.wearProtectiveClothing.description ?? "nil")")
            }
            .font(.footnote)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
        }
        .padding()
    }
}

#Preview {
    UVNotificationContainer(uvValue: 8)
        .modelContainer(for: DailySunSummary.self, inMemory: true)
}

