import Foundation
import SwiftUI

// MARK: - Cycle Phase

enum CyclePhase: String, Codable, CaseIterable, Identifiable {
    case menstrual
    case follicular
    case ovulation
    case luteal

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .menstrual:  return Color(.systemRed)
        case .follicular: return Color(.systemPink)
        case .ovulation:  return Color(.systemPurple)
        case .luteal:     return Color(.systemOrange)
        }
    }

    var icon: String {
        switch self {
        case .menstrual:  return "drop.fill"
        case .follicular: return "leaf.fill"
        case .ovulation:  return "sparkles"
        case .luteal:     return "moon.fill"
        }
    }

    var summary: String {
        switch self {
        case .menstrual:  return "Menstrual phase"
        case .follicular: return "Building up"
        case .ovulation:  return "Fertile window"
        case .luteal:     return "Winding down"
        }
    }
}

// MARK: - Mood

enum Mood: String, Codable, CaseIterable, Identifiable {
    case happy, calm, anxious, sad, irritable, energetic

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .happy:     return "😊"
        case .calm:      return "😌"
        case .anxious:   return "😰"
        case .sad:       return "😢"
        case .irritable: return "😤"
        case .energetic: return "⚡️"
        }
    }

    var displayName: String { rawValue.capitalized }
}

// MARK: - Flow Intensity

enum FlowIntensity: Int, Codable, CaseIterable, Identifiable {
    case none     = 0
    case spotting = 1
    case light    = 2
    case medium   = 3
    case heavy    = 4

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .none:     return "None"
        case .spotting: return "Spotting"
        case .light:    return "Light"
        case .medium:   return "Medium"
        case .heavy:    return "Heavy"
        }
    }
}

// MARK: - Cramp Severity

enum CrampSeverity: Int, Codable, CaseIterable, Identifiable {
    case none     = 0
    case mild     = 1
    case moderate = 2
    case severe   = 3

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .none:     return "None"
        case .mild:     return "Mild"
        case .moderate: return "Moderate"
        case .severe:   return "Severe"
        }
    }
}

// MARK: - Energy Level

enum EnergyLevel: Int, Codable, CaseIterable, Identifiable {
    case veryLow  = 1
    case low      = 2
    case medium   = 3
    case high     = 4
    case veryHigh = 5

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .veryLow:  return "Very Low"
        case .low:      return "Low"
        case .medium:   return "Medium"
        case .high:     return "High"
        case .veryHigh: return "Very High"
        }
    }
}
