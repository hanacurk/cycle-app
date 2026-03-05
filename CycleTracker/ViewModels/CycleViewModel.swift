import Foundation
import Observation
import SwiftData

@Observable
class CycleViewModel {
    var currentPhase: CyclePhase = .follicular
    var dayInPhase: Int = 1
    var dayInCycle: Int = 1
    var daysUntilNextPeriod: Int = 0
    var cycleLength: Int = 28
    var periodLength: Int = 5
    var phaseRanges: [PhaseRange] = []
    var hasData: Bool = false

    // MARK: - Update from SwiftData query results

    func update(with cycles: [CycleRecord]) {
        guard let latest = cycles.sorted(by: { $0.startDate > $1.startDate }).first else {
            hasData = false
            return
        }

        hasData = true
        cycleLength = latest.cycleLength
        periodLength = latest.periodLength

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let cycleStart = calendar.startOfDay(for: latest.startDate)
        let daysSinceStart = calendar.dateComponents([.day], from: cycleStart, to: today).day ?? 0

        dayInCycle = (daysSinceStart % cycleLength) + 1

        currentPhase = CycleCalculator.phase(
            forDayInCycle: dayInCycle,
            cycleLength: cycleLength,
            periodLength: periodLength
        )

        phaseRanges = CycleCalculator.phaseRanges(cycleLength: cycleLength, periodLength: periodLength)

        for range in phaseRanges where dayInCycle >= range.startDay && dayInCycle <= range.endDay {
            dayInPhase = dayInCycle - range.startDay + 1
            break
        }

        daysUntilNextPeriod = CycleCalculator.daysUntilNextPeriod(from: cycles) ?? 0
    }

    // MARK: - Actions

    func startNewCycle(context: ModelContext, cycleLength: Int = 28, periodLength: Int = 5) {
        let record = CycleRecord(startDate: Date(), cycleLength: cycleLength, periodLength: periodLength)
        context.insert(record)
    }

    func endCurrentPeriod(context: ModelContext, cycles: [CycleRecord]) {
        guard let latest = cycles.sorted(by: { $0.startDate > $1.startDate }).first,
              latest.endDate == nil else { return }
        latest.endDate = Date()
    }
}
