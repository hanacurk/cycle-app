import Foundation
import SwiftData

@Model
final class DailyLog {
    var id: UUID = UUID()
    var date: Date = Date()
    var moodRaw: String?
    var flowIntensityRaw: Int?
    var crampSeverityRaw: Int?
    var energyLevelRaw: Int?
    var notes: String?

    // MARK: - Computed enum accessors

    var mood: Mood? {
        get { moodRaw.flatMap { Mood(rawValue: $0) } }
        set { moodRaw = newValue?.rawValue }
    }

    var flowIntensity: FlowIntensity {
        get { FlowIntensity(rawValue: flowIntensityRaw ?? 0) ?? .none }
        set { flowIntensityRaw = newValue.rawValue }
    }

    var crampSeverity: CrampSeverity {
        get { CrampSeverity(rawValue: crampSeverityRaw ?? 0) ?? .none }
        set { crampSeverityRaw = newValue.rawValue }
    }

    var energyLevel: EnergyLevel {
        get { EnergyLevel(rawValue: energyLevelRaw ?? 3) ?? .medium }
        set { energyLevelRaw = newValue.rawValue }
    }

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
    }
}
