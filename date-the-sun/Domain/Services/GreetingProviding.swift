import Foundation

/// Produces a time-of-day greeting.
nonisolated protocol GreetingProviding {
    func greeting(at date: Date) -> String
}

nonisolated struct GreetingProvider: GreetingProviding {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func greeting(at date: Date) -> String {
        switch calendar.component(.hour, from: date) {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Good night"
        }
    }
}
