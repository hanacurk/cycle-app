import SwiftUI
import SwiftData

struct CircleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CycleRecord.startDate, order: .reverse) private var cycles: [CycleRecord]
    @State private var viewModel = CycleViewModel()
    @State private var showingQuickLog = false
    @State private var showingNewCycle = false
    @State private var newStartDate = Date()
    @State private var newCycleLength = 28
    @State private var newPeriodLength = 5
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())

    private let selectableDayOffsets = Array(-10...10)

    var body: some View {
        ZStack {
            // Phase-tinted background
            backgroundPhase.backgroundTint
                .opacity(0.6)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: backgroundPhase)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    if viewModel.hasData, let snapshot = cycleSnapshot(for: selectedDate) {
                        activeContent(snapshot: snapshot)
                    } else {
                        emptyState
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showingQuickLog) {
            LogSymptomView(dismissible: true)
        }
        .sheet(isPresented: $showingNewCycle) {
            newCycleSheet
        }
        .onAppear {
            viewModel.update(with: cycles)
            selectedDate = Calendar.current.startOfDay(for: Date())
        }
        .onChange(of: cycles.count) { _, _ in viewModel.update(with: cycles) }
        .onChange(of: newCycleLength) { _, newValue in
            newPeriodLength = min(newPeriodLength, newValue)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 100)
            PhaseBlobCharacterView(phase: .follicular, size: 140)
            Text("Start Tracking")
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text("Log your first period to begin\ntracking your cycle.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Start New Cycle") {
                prepareNewCycleForm()
            }
            .font(.headline)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(Capsule().fill(CyclePhase.menstrual.color))
            .foregroundStyle(.white)
        }
        .padding()
    }

    // MARK: - Active Dashboard

    private func activeContent(snapshot: CycleSnapshot) -> some View {
        VStack(spacing: 24) {
            headerSection
            // Week strip
            weekStrip

            // Main cycle ring
            cycleRingSection(snapshot: snapshot)

            // Phase legend
            phaseLegend

            // Log Period button
            logPeriodButton

            // Info cards
            infoCards(snapshot: snapshot)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 0) {
                    Text("Hello, ")
                        .font(.system(size: 28, weight: .regular, design: .rounded))
                    Text("Hana")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
                Text(Date(), format: .dateTime.day().month(.wide).year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            // Plus button
            Button { prepareNewCycleForm() } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.7))
                    )
                    .foregroundStyle(.primary)
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Week Strip

    private var weekStrip: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(selectableDayOffsets, id: \.self) { offset in
                        if let date = calendar.date(byAdding: .day, value: offset, to: today) {
                            weekDayChip(for: date)
                                .id(offset)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            .onAppear {
                proxy.scrollTo(0, anchor: .center)
            }
        }
    }

    private func weekDayChip(for date: Date) -> some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let phase = cycleSnapshot(for: date)?.phase ?? .follicular

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedDate = calendar.startOfDay(for: date)
            }
        } label: {
            VStack(spacing: 4) {
                Text(date, format: .dateTime.weekday(.narrow))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .secondary)
                Text(date, format: .dateTime.day())
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .primary)
                if isToday && !isSelected {
                    Circle()
                        .fill(phase.color)
                        .frame(width: 5, height: 5)
                } else {
                    Circle()
                        .fill(.clear)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(width: 42, height: 62)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? phase.color : .white.opacity(0.5))
            )
            .shadow(color: isSelected ? phase.color.opacity(0.3) : .clear, radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Cycle Ring

    private func cycleRingSection(snapshot: CycleSnapshot) -> some View {
        ZStack {
            // Outer white circle bg
            Circle()
                .fill(.white.opacity(0.55))
                .frame(width: 290, height: 290)
                .shadow(color: .black.opacity(0.06), radius: 16, y: 6)

            // Track ring
            Circle()
                .stroke(.white.opacity(0.6), lineWidth: 20)
                .frame(width: 248, height: 248)

            // Progress ring
            Circle()
                .trim(from: 0, to: snapshot.progress)
                .stroke(
                    snapshot.phase.color,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 248, height: 248)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: snapshot.progress)

            // Inner content
            VStack(spacing: 4) {
                PhaseBlobCharacterView(phase: snapshot.phase, size: 96)
                    .animation(.easeInOut(duration: 0.4), value: snapshot.phase)

                Text("Day \(snapshot.dayInCycle)")
                    .font(.system(size: 38, weight: .bold, design: .rounded))

                Text(snapshot.phase.displayName)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 290, height: 290)
    }

    // MARK: - Phase Legend

    private var phaseLegend: some View {
        HStack(spacing: 16) {
            legendDot(color: CyclePhase.menstrual.color, label: "Period phase")
            legendDot(color: CyclePhase.ovulation.color, label: "Fertile window")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
        }
    }

    // MARK: - Log Period Button

    private var logPeriodButton: some View {
        Button {
            showingQuickLog = true
        } label: {
            HStack(spacing: 6) {
                Text("Log Period")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.primary.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.9), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Info Cards

    private func infoCards(snapshot: CycleSnapshot) -> some View {
        VStack(spacing: 10) {
            // Cycle stats row
            HStack(spacing: 10) {
                infoCard(
                    icon: "calendar",
                    title: "Next Period",
                    value: "\(snapshot.daysUntilNextPeriod) days",
                    tint: backgroundPhase.color
                )
                infoCard(
                    icon: "clock",
                    title: "Phase Day",
                    value: "Day \(snapshot.dayInPhase)",
                    tint: backgroundPhase.color
                )
            }

            // Chances of pregnancy card
            pregnancyChanceCard(snapshot: snapshot)
        }
    }

    private func infoCard(icon: String, title: String, value: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(Circle().fill(tint.opacity(0.15)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.55))
        )
        .frame(maxWidth: .infinity)
    }

    private func pregnancyChanceCard(snapshot: CycleSnapshot) -> some View {
        let (label, dotColor) = pregnancyChance(for: snapshot.phase)

        return HStack {
            Image(systemName: "leaf")
                .font(.system(size: 18))
                .foregroundStyle(backgroundPhase.color)
                .frame(width: 36, height: 36)
                .background(Circle().fill(backgroundPhase.color.opacity(0.15)))
            Text("Chances of Pregnancy")
                .font(.system(size: 15, weight: .medium, design: .rounded))
            Spacer()
            HStack(spacing: 5) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)
                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(dotColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.55))
        )
    }

    private func pregnancyChance(for phase: CyclePhase) -> (String, Color) {
        switch phase {
        case .ovulation:   return ("High", .green)
        case .follicular:  return ("Medium", .orange)
        case .menstrual:   return ("Low", .gray)
        case .luteal:      return ("Low", .gray)
        }
    }

    // MARK: - New Cycle Sheet

    private var newCycleSheet: some View {
        NavigationStack {
            Form {
                Section("Period Start Date") {
                    DatePicker(
                        "Start Date",
                        selection: $newStartDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                }
                Section("Cycle Settings") {
                    Stepper(value: $newCycleLength, in: 15...60) {
                        HStack {
                            Text("Cycle Length")
                            Spacer()
                            Text("\(newCycleLength) days").foregroundStyle(.secondary)
                        }
                    }
                    Stepper(value: $newPeriodLength, in: 1...min(14, newCycleLength)) {
                        HStack {
                            Text("Period Length")
                            Spacer()
                            Text("\(newPeriodLength) days").foregroundStyle(.secondary)
                        }
                    }
                }
                Section {
                    Text("If this is your first entry, previous cycle starts are generated automatically based on your cycle length.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(backgroundPhase.backgroundTint.opacity(0.55))
            .navigationTitle("Start New Cycle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingNewCycle = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.startNewCycle(
                            context: modelContext,
                            existingCycles: cycles,
                            startDate: newStartDate,
                            cycleLength: newCycleLength,
                            periodLength: newPeriodLength
                        )
                        selectedDate = Calendar.current.startOfDay(for: newStartDate)
                        showingNewCycle = false
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var backgroundPhase: CyclePhase {
        cycleSnapshot(for: Date())?.phase ?? .follicular
    }

    private func prepareNewCycleForm() {
        newCycleLength = max(viewModel.cycleLength, 15)
        newPeriodLength = min(max(viewModel.periodLength, 1), min(14, newCycleLength))
        newStartDate = Date()
        showingNewCycle = true
    }

    private func cycleSnapshot(for date: Date) -> CycleSnapshot? {
        guard let latest = cycles.sorted(by: { $0.startDate > $1.startDate }).first else { return nil }
        let calendar = Calendar.current
        let cycleLength = max(latest.cycleLength, 1)
        let periodLength = min(max(latest.periodLength, 1), cycleLength)
        let start = calendar.startOfDay(for: latest.startDate)
        let target = calendar.startOfDay(for: date)
        let daysSinceStart = calendar.dateComponents([.day], from: start, to: target).day ?? 0
        let zeroIndexedDay = ((daysSinceStart % cycleLength) + cycleLength) % cycleLength
        let dayInCycle = zeroIndexedDay + 1
        let phase = CycleCalculator.phase(
            forDayInCycle: dayInCycle,
            cycleLength: cycleLength,
            periodLength: periodLength
        )
        let dayInPhase = CycleCalculator.phaseRanges(cycleLength: cycleLength, periodLength: periodLength)
            .first(where: { dayInCycle >= $0.startDay && dayInCycle <= $0.endDay })
            .map { dayInCycle - $0.startDay + 1 } ?? 1
        let daysUntilNextPeriod = cycleLength - zeroIndexedDay

        return CycleSnapshot(
            date: target,
            dayInCycle: dayInCycle,
            dayInPhase: dayInPhase,
            daysUntilNextPeriod: daysUntilNextPeriod,
            cycleLength: cycleLength,
            periodLength: periodLength,
            phase: phase
        )
    }
}

// MARK: - Cycle Snapshot

private struct CycleSnapshot {
    let date: Date
    let dayInCycle: Int
    let dayInPhase: Int
    let daysUntilNextPeriod: Int
    let cycleLength: Int
    let periodLength: Int
    let phase: CyclePhase

    var progress: CGFloat {
        CGFloat(dayInCycle) / CGFloat(max(cycleLength, 1))
    }
}

// MARK: - Stat Card (kept for compatibility)

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.58)))
    }
}
