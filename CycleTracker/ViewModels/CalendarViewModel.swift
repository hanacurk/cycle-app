import Foundation
import Observation

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    let dayNumber: Int
}

@Observable
class CalendarViewModel {
    var currentMonth: Date

    init() {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        self.currentMonth = Calendar.current.date(from: comps) ?? Date()
    }

    var monthYearString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: currentMonth)
    }

    var weekdaySymbols: [String] {
        Calendar.current.veryShortWeekdaySymbols
    }

    var calendarDays: [CalendarDay] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        var days: [CalendarDay] = []

        // Leading empty cells
        for _ in 1..<firstWeekday {
            days.append(CalendarDay(date: nil, dayNumber: 0))
        }

        // Actual days
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(CalendarDay(date: date, dayNumber: day))
            }
        }

        return days
    }

    // MARK: - Navigation

    func previousMonth() {
        if let m = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = m
        }
    }

    func nextMonth() {
        if let m = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = m
        }
    }

    // MARK: - Phase lookup

    func phase(for date: Date, cycles: [CycleRecord]) -> CyclePhase? {
        CycleCalculator.phase(for: date, cycles: cycles)
    }
}
