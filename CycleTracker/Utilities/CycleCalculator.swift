import Foundation

struct PhaseRange: Identifiable {
    let phase: CyclePhase
    let startDay: Int
    let endDay: Int

    var id: String { phase.rawValue }
    var duration: Int { endDay - startDay + 1 }
}

struct CycleCalculator {

    // MARK: - Phase for a given cycle day (1-indexed)

    static func phase(forDayInCycle day: Int, cycleLength: Int, periodLength: Int) -> CyclePhase {
        guard day >= 1, day <= cycleLength else { return .luteal }

        let ovDay = ovulationDay(for: cycleLength)

        if day <= periodLength {
            return .menstrual
        } else if day < ovDay {
            return .follicular
        } else if day <= min(ovDay + 2, cycleLength) {
            return .ovulation
        } else {
            return .luteal
        }
    }

    // MARK: - Phase ranges for a full cycle

    static func phaseRanges(cycleLength: Int, periodLength: Int) -> [PhaseRange] {
        let ovDay = ovulationDay(for: cycleLength)
        var ranges: [PhaseRange] = []

        let menstrualEnd = min(periodLength, cycleLength)
        ranges.append(PhaseRange(phase: .menstrual, startDay: 1, endDay: menstrualEnd))

        let follicularStart = menstrualEnd + 1
        let follicularEnd = ovDay - 1
        if follicularStart <= follicularEnd {
            ranges.append(PhaseRange(phase: .follicular, startDay: follicularStart, endDay: follicularEnd))
        }

        let ovulationStart = max(ovDay, menstrualEnd + 1)
        let ovulationEnd = min(ovDay + 2, cycleLength)
        if ovulationStart <= ovulationEnd {
            ranges.append(PhaseRange(phase: .ovulation, startDay: ovulationStart, endDay: ovulationEnd))
        }

        let lutealStart = ovulationEnd + 1
        if lutealStart <= cycleLength {
            ranges.append(PhaseRange(phase: .luteal, startDay: lutealStart, endDay: cycleLength))
        }

        return ranges
    }

    // MARK: - Phase for a calendar date

    static func phase(for date: Date, cycles: [CycleRecord]) -> CyclePhase? {
        let calendar = Calendar.current
        let target = calendar.startOfDay(for: date)
        let sorted = cycles.sorted { $0.startDate > $1.startDate }

        for cycle in sorted {
            let start = calendar.startOfDay(for: cycle.startDate)
            guard let end = calendar.date(byAdding: .day, value: cycle.cycleLength - 1, to: start) else { continue }

            if target >= start && target <= end {
                let day = (calendar.dateComponents([.day], from: start, to: target).day ?? 0) + 1
                return phase(forDayInCycle: day, cycleLength: cycle.cycleLength, periodLength: cycle.periodLength)
            }
        }

        // Predict future/gap dates from the latest cycle
        guard let latest = sorted.first else { return nil }
        let latestStart = calendar.startOfDay(for: latest.startDate)
        let daysSinceStart = calendar.dateComponents([.day], from: latestStart, to: target).day ?? 0
        guard daysSinceStart > 0 else { return nil }

        let dayInCycle = ((daysSinceStart - 1) % latest.cycleLength) + 1
        return phase(forDayInCycle: dayInCycle, cycleLength: latest.cycleLength, periodLength: latest.periodLength)
    }

    // MARK: - Predictions

    static func daysUntilNextPeriod(from cycles: [CycleRecord]) -> Int? {
        guard let latest = cycles.sorted(by: { $0.startDate > $1.startDate }).first else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: latest.startDate)
        let daysSinceStart = calendar.dateComponents([.day], from: start, to: today).day ?? 0

        let offsetInCycle = daysSinceStart % latest.cycleLength
        return (latest.cycleLength - offsetInCycle) % latest.cycleLength
    }

    static func currentDayInCycle(from cycles: [CycleRecord]) -> Int? {
        guard let latest = cycles.sorted(by: { $0.startDate > $1.startDate }).first else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: latest.startDate)
        let daysSinceStart = calendar.dateComponents([.day], from: start, to: today).day ?? 0

        return (daysSinceStart % latest.cycleLength) + 1
    }

    // MARK: - Helpers

    private static func ovulationDay(for cycleLength: Int) -> Int {
        max(cycleLength - 14, 1)
    }
}
