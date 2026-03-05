//
//  PhaseRecommendationsView.swift
//  CycleTracker
//
//  Created by Hana Čurk on 5. 3. 26.
//

import SwiftUI
import SwiftData
import SwiftUI
import SwiftData

// MARK: - Models

struct PhaseContentData: Codable {
    let menstrual: PhaseContent
    let follicular: PhaseContent
    let ovulation: PhaseContent
    let luteal: PhaseContent

    func content(for phase: CyclePhase) -> PhaseContent {
        switch phase {
        case .menstrual:  return menstrual
        case .follicular: return follicular
        case .ovulation:  return ovulation
        case .luteal:     return luteal
        }
    }
}

struct PhaseContent: Codable {
    let tagline: String
    let tip: String
    let bodyExplanation: String
    let seeds: [String]
    let quotes: [String]
    let dos: [String]
    let donts: [String]
    let foods: [FoodItem]
    let recipes: [RecipeItem]
}

struct RecipeItem: Codable, Identifiable {
    var id: String { name }
    let name: String
    let emoji: String
    let description: String
}

struct FoodItem: Codable, Identifiable {
    var id: String { name }
    let name: String
    let emoji: String
}
// MARK: - Content Loader

final class PhaseContentLoader {
    static let shared = PhaseContentLoader()
    private var _data: PhaseContentData?

    var data: PhaseContentData {
        if let cached = _data { return cached }
        guard
            let url = Bundle.main.url(forResource: "PhaseContent", withExtension: "json"),
            let raw = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(PhaseContentData.self, from: raw)
        else {
            fatalError("PhaseContent.json missing or malformed")
        }
        _data = decoded
        return decoded
    }

    /// Picks an item seeded by day-of-year × phase so it's
    /// consistent within a day but rotates the next day.
    func dailyItem<T>(from items: [T], phase: CyclePhase, offset: Int = 0) -> T {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        var rng = SeededRNG(seed: (dayOfYear &+ offset) &* (abs(phase.hashValue) &+ 1))
        let idx = Int(rng.next() % UInt64(items.count))
        return items[idx]
    }
}

private struct SeededRNG {
    var state: UInt64
    init(seed: Int) {
        state = UInt64(bitPattern: Int64(seed)) &* 6364136223846793005 &+ 1442695040888963407
    }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

// MARK: - View

struct HomeView: View {
    @Query(sort: \CycleRecord.startDate, order: .reverse) private var cycles: [CycleRecord]
    @State private var selectedPhase: CyclePhase?

    private var currentPhase: CyclePhase {
        CycleCalculator.phase(for: Date(), cycles: cycles) ?? .follicular
    }

    private var displayedPhase: CyclePhase {
        selectedPhase ?? currentPhase
    }

    private var content: PhaseContent {
        PhaseContentLoader.shared.data.content(for: displayedPhase)
    }

    private var dailyQuote: String { PhaseContentLoader.shared.dailyItem(from: content.quotes, phase: displayedPhase, offset: 0) }
    private var dailyDo: String    { PhaseContentLoader.shared.dailyItem(from: content.dos,    phase: displayedPhase, offset: 1) }
    private var dailyDont: String  { PhaseContentLoader.shared.dailyItem(from: content.donts,  phase: displayedPhase, offset: 2) }

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    displayedPhase.backgroundTint.opacity(0.58)
                        .ignoresSafeArea()
                        .animation(.easeInOut(duration: 0.4), value: displayedPhase)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            headerCard
                            phaseSelector
                            doDontRow
                            seedsCard
                            foodsCard
                            recipesSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 32)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? min(390, geometry.size.width * 0.6) : nil)
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(displayedPhase.displayName + " Phase")
                    .font(.caption.bold())
                    .textCase(.uppercase)
                    .kerning(1.3)
                    .foregroundStyle(displayedPhase.ringColor)
                Text(content.tagline)
                    .font(.title2.bold())
            }
            Spacer()
            PhaseBlobCharacterView(phase: displayedPhase, size: 64)
                .animation(.easeInOut(duration: 0.35), value: displayedPhase)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.62)))
    }

    // MARK: - Phase selector

    private var phaseSelector: some View {
        let phases = CyclePhase.allCases
        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(phases.prefix(2)) { phase in
                    phasePill(phase)
                }
            }
            HStack(spacing: 8) {
                ForEach(phases.suffix(2)) { phase in
                    phasePill(phase)
                }
            }
        }
    }

    private func phasePill(_ phase: CyclePhase) -> some View {
        let isSelected = phase == displayedPhase
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedPhase = phase }
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(phase.accentColor)
                    .frame(width: 7, height: 7)
                Text(phase.displayName)
                    .font(.caption.bold())
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: "#1A1A2E") : Color(hex: "#1A1A2E").opacity(0.08))
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Foods
    
    private var foodsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Foods to enjoy", systemImage: "fork.knife")
                .font(.caption.bold())
                .textCase(.uppercase)
                .kerning(1.1)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(content.foods) { food in
                    VStack(spacing: 5) {
                        Text(food.emoji)
                            .font(.system(size: 26))
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(displayedPhase.ringColor.opacity(0.15))
                            )
                        Text(food.name)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.62)))
    }

    // MARK: - Quote

    private var quoteCard: some View {
        VStack(spacing: 10) {
            HStack {
                Text("✨  Today's thought")
                    .font(.caption.bold())
                    .textCase(.uppercase)
                    .kerning(1.2)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            Text("\(dailyQuote)")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .multilineTextAlignment(.leading)
                .foregroundStyle(.primary)
                .lineSpacing(3)
                .padding(.horizontal, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(displayedPhase.ringColor.opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(displayedPhase.ringColor.opacity(0.28), lineWidth: 1)
                )
        )
    }

    // MARK: - Do / Don't

    private var doDontRow: some View {
        HStack(alignment: .top, spacing: 12) {
            doDontCard(
                label: "Do",
                icon: "checkmark.circle.fill",
                iconColor: .green,
                text: dailyDo
            )
            doDontCard(
                label: "Don't",
                icon: "xmark.circle.fill",
                iconColor: .red.opacity(0.75),
                text: dailyDont
            )
        }
    }

    private func doDontCard(label: String, icon: String, iconColor: Color, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .font(.subheadline.bold())
                .foregroundStyle(iconColor)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.62)))
    }

    // MARK: - Body explanation

    private var bodyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("What your body is doing", systemImage: "heart.text.square")
                .font(.caption.bold())
                .textCase(.uppercase)
                .kerning(1.1)
                .foregroundStyle(.secondary)
            Text(content.bodyExplanation)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.62)))
    }

    // MARK: - Seeds

    private var seedsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Seeds to enjoy", systemImage: "leaf")
                .font(.caption.bold())
                .textCase(.uppercase)
                .kerning(1.1)
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                ForEach(content.seeds, id: \.self) { seed in
                    HStack(spacing: 6) {
                        Text("🌱")
                        Text(seed)
                            .font(.subheadline.bold())
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(displayedPhase.ringColor.opacity(0.15)))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.62)))
    }

    // MARK: - Blob chef

    private var blobChefCard: some View {
        VStack(spacing: 10) {
            PhaseBlobCharacterView(phase: displayedPhase, style: .chef, size: 120)
                .animation(.easeInOut(duration: 0.35), value: displayedPhase)
            Text(content.tip)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: 24).fill(.white.opacity(0.56)))
        .shadow(color: displayedPhase.ringColor.opacity(0.15), radius: 10, y: 4)
    }

    // MARK: - Recipes

    private var recipesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recipe ideas")
                .font(.subheadline.bold())
                .textCase(.uppercase)
                .kerning(1.2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            Text(content.tip)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)

            ForEach(content.recipes) { recipe in
                HStack(spacing: 12) {
                    Text(recipe.emoji)
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(displayedPhase.backgroundTint)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(recipe.name)
                            .font(.subheadline.bold())
                        Text(recipe.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.56)))
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.38)))
    }
}

// MARK: - CyclePhase ring color extension

extension CyclePhase {
    var ringColor: Color {
        switch self {
        case .menstrual:  return Color(hex: "#FF8FAB")
        case .follicular: return Color(hex: "#F0B429")
        case .ovulation:  return Color(hex: "#7DD4E8")
        case .luteal:     return Color(hex: "#80C880")
        }
    }
}
