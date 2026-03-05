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
        case .menstrual:  return Color(hex: "#D96C8E")
        case .follicular: return Color(hex: "#C2A100")
        case .ovulation:  return Color(hex: "#4B93AA")
        case .luteal:     return Color(hex: "#649864")
        }
    }

    var accentColor: Color {
        switch self {
        case .menstrual:  return Color(hex: "#FF8FAB")
        case .follicular: return Color(hex: "#F0C830")
        case .ovulation:  return Color(hex: "#7DD4E8")
        case .luteal:     return Color(hex: "#80C880")
        }
    }

    var blobColor: Color {
        switch self {
        case .menstrual:  return Color(hex: "#FFB8CC")
        case .follicular: return Color(hex: "#FFE860")
        case .ovulation:  return Color(hex: "#A8D8F0")
        case .luteal:     return Color(hex: "#A8E0A8")
        }
    }

    var backgroundTint: Color {
        switch self {
        case .menstrual:  return Color(hex: "#FFD8E0")
        case .follicular: return Color(hex: "#FFF5A0")
        case .ovulation:  return Color(hex: "#C8E8F0")
        case .luteal:     return Color(hex: "#D8F0D8")
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

    var faceEmoji: String {
        switch self {
        case .menstrual:  return "😣"
        case .follicular: return "🙂"
        case .ovulation:  return "😄"
        case .luteal:     return "😌"
        }
    }
}

enum BlobCharacterStyle {
    case regular
    case chef
}

struct PhaseBlobCharacterView: View {
    let phase: CyclePhase
    var style: BlobCharacterStyle = .regular
    var size: CGFloat = 120

    @State private var floating = false
    @State private var stirring = false

    var body: some View {
        ZStack {
            // Blob body
            Group {
                Ellipse()
                    .fill(phase.blobColor)
                    .frame(width: size * 0.78, height: size * 0.66)
                    .offset(y: size * 0.06)

                Ellipse()
                    .fill(phase.blobColor)
                    .frame(width: size * 0.36, height: size * 0.28)
                    .offset(x: -size * 0.24, y: -size * 0.11)

                Ellipse()
                    .fill(phase.blobColor)
                    .frame(width: size * 0.33, height: size * 0.25)
                    .offset(x: size * 0.21, y: -size * 0.13)
            }

            Ellipse()
                .fill(.white.opacity(0.32))
                .frame(width: size * 0.14, height: size * 0.1)
                .offset(x: -size * 0.15, y: -size * 0.23)

            expressionEyes
                .offset(y: size * 0.01)

            expressionMouth
                .stroke(Color(hex: "#1A1A2E"), style: StrokeStyle(lineWidth: size * 0.02, lineCap: .round))
                .frame(width: size * 0.2, height: size * 0.1)
                .offset(y: size * 0.22)

            if phase == .menstrual {
                Ellipse()
                    .fill(Color(hex: "#A8C8F0").opacity(0.85))
                    .frame(width: size * 0.045, height: size * 0.06)
                    .offset(x: -size * 0.31, y: size * 0.15)
            }

            if style == .chef {
                ChefHatView(size: size * 0.36)
                    .offset(y: -size * 0.48)

                SpoonView(size: size * 0.12, color: phase.accentColor)
                    .rotationEffect(.degrees(stirring ? 22 : -18))
                    .offset(x: size * 0.36, y: size * 0.12)
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(y: floating ? 1.03 : 0.97)
        .offset(y: floating ? -3 : 3)
        .shadow(color: phase.accentColor.opacity(0.22), radius: 8, y: 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                floating = true
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                stirring = true
            }
        }
    }

    @ViewBuilder
    private var expressionEyes: some View {
        switch phase {
        case .follicular:
            HStack(spacing: size * 0.14) {
                Capsule()
                    .fill(Color(hex: "#1A1A2E"))
                    .frame(width: size * 0.09, height: size * 0.024)
                    .rotationEffect(.degrees(-22))
                Capsule()
                    .fill(Color(hex: "#1A1A2E"))
                    .frame(width: size * 0.09, height: size * 0.024)
                    .rotationEffect(.degrees(22))
            }
            .offset(y: size * 0.02)
        case .ovulation:
            HStack(spacing: size * 0.16) {
                Image(systemName: "heart.fill")
                    .font(.system(size: size * 0.08, weight: .bold))
                Image(systemName: "heart.fill")
                    .font(.system(size: size * 0.08, weight: .bold))
            }
            .foregroundStyle(Color(hex: "#1A1A2E"))
        default:
            HStack(spacing: size * 0.16) {
                eyeDot
                eyeDot
            }
        }
    }

    private var eyeDot: some View {
        ZStack {
            Ellipse()
                .fill(Color(hex: "#1A1A2E"))
                .frame(width: size * 0.1, height: size * 0.08)
            Circle()
                .fill(.white.opacity(0.75))
                .frame(width: size * 0.022, height: size * 0.022)
                .offset(x: size * 0.016, y: -size * 0.014)
        }
    }

    private var expressionMouth: BlobArcShape {
        switch phase {
        case .menstrual:
            return BlobArcShape(curve: -0.22)
        case .follicular:
            return BlobArcShape(curve: 0.42)
        case .ovulation:
            return BlobArcShape(curve: 0.34)
        case .luteal:
            return BlobArcShape(curve: 0.06)
        }
    }
}

private struct BlobArcShape: Shape {
    var curve: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = CGPoint(x: rect.minX, y: rect.midY)
        let end = CGPoint(x: rect.maxX, y: rect.midY)
        let control = CGPoint(x: rect.midX, y: rect.midY + rect.height * curve)
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        return path
    }
}

private struct ChefHatView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Ellipse()
                .fill(.white)
                .frame(width: size, height: size * 0.45)
                .offset(y: size * 0.18)

            Circle()
                .fill(.white)
                .frame(width: size * 0.48, height: size * 0.48)
                .offset(y: -size * 0.12)

            Circle()
                .fill(.white)
                .frame(width: size * 0.34, height: size * 0.34)
                .offset(x: -size * 0.24, y: -size * 0.04)

            Circle()
                .fill(.white)
                .frame(width: size * 0.34, height: size * 0.34)
                .offset(x: size * 0.24, y: -size * 0.04)

            RoundedRectangle(cornerRadius: size * 0.07)
                .fill(.white.opacity(0.92))
                .frame(width: size * 0.84, height: size * 0.2)
                .offset(y: size * 0.24)
        }
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }
}

private struct SpoonView: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            Ellipse()
                .fill(color)
                .frame(width: size * 0.95, height: size * 1.08)
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(color)
                .frame(width: size * 0.36, height: size * 2.3)
                .offset(y: -size * 0.12)
        }
    }
}

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)

        let red, green, blue: UInt64
        switch sanitized.count {
        case 6:
            red = (int >> 16) & 0xFF
            green = (int >> 8) & 0xFF
            blue = int & 0xFF
        case 3:
            red = ((int >> 8) & 0xF) * 17
            green = ((int >> 4) & 0xF) * 17
            blue = (int & 0xF) * 17
        default:
            red = 255
            green = 255
            blue = 255
        }

        self.init(
            .sRGB,
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0,
            opacity: 1.0
        )
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
