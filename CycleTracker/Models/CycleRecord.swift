import Foundation
import SwiftData

@Model
final class CycleRecord {
    var id: UUID = UUID()
    var startDate: Date = Date()
    var endDate: Date?
    var cycleLength: Int = 28
    var periodLength: Int = 5
    var notes: String?

    init(
        startDate: Date,
        endDate: Date? = nil,
        cycleLength: Int = 28,
        periodLength: Int = 5,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.endDate = endDate.map { Calendar.current.startOfDay(for: $0) }
        self.cycleLength = cycleLength
        self.periodLength = periodLength
        self.notes = notes
    }

    var predictedNextStart: Date {
        Calendar.current.date(byAdding: .day, value: cycleLength, to: startDate) ?? startDate
    }
}
