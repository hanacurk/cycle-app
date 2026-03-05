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

    func startNewCycle(
        context: ModelContext,
        existingCycles: [CycleRecord],
        startDate: Date,
        cycleLength: Int = 28,
        periodLength: Int = 5
    ) {
        let normalizedCycleLength = max(cycleLength, 1)
        let normalizedPeriodLength = min(max(periodLength, 1), normalizedCycleLength)
        let calendar = Calendar.current
        let normalizedStartDate = calendar.startOfDay(for: startDate)

        guard !existingCycles.contains(where: { calendar.isDate($0.startDate, inSameDayAs: normalizedStartDate) }) else {
            return
        }

        let record = CycleRecord(
            startDate: normalizedStartDate,
            cycleLength: normalizedCycleLength,
            periodLength: normalizedPeriodLength
        )
        context.insert(record)

        if existingCycles.isEmpty {
            generateHistoricalCycles(
                context: context,
                from: normalizedStartDate,
                cycleLength: normalizedCycleLength,
                periodLength: normalizedPeriodLength
            )
        }
    }

    func endCurrentPeriod(context: ModelContext, cycles: [CycleRecord]) {
        guard let latest = cycles.sorted(by: { $0.startDate > $1.startDate }).first,
              latest.endDate == nil else { return }
        latest.endDate = Date()
    }

    private func generateHistoricalCycles(
        context: ModelContext,
        from firstStartDate: Date,
        cycleLength: Int,
        periodLength: Int
    ) {
        let calendar = Calendar.current
        guard let oneYearBack = calendar.date(byAdding: .year, value: -1, to: firstStartDate) else { return }

        var cursor = firstStartDate

        while let previousStart = calendar.date(byAdding: .day, value: -cycleLength, to: cursor),
              previousStart >= oneYearBack {
            context.insert(
                CycleRecord(
                    startDate: previousStart,
                    cycleLength: cycleLength,
                    periodLength: periodLength
                )
            )
            cursor = previousStart
        }
    }
}
