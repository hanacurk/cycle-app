import SwiftUI
import SwiftData
import Charts

struct CycleHistoryView: View {
    @Query(sort: \CycleRecord.startDate) private var cycles: [CycleRecord]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundPhase.backgroundTint.opacity(0.55)
                    .ignoresSafeArea()

                ScrollView {
                    if cycles.isEmpty {
                        ContentUnavailableView(
                            "No Cycle Data",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("Add a period start date to begin tracking.")
                        )
                    } else {
                        VStack(alignment: .leading, spacing: 24) {
                            HStack(spacing: 12) {
                                PhaseBlobCharacterView(phase: backgroundPhase, size: 78)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("History helper")
                                        .font(.headline)
                                    Text("Edit dates and review trends with your cycle blob guide.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(cardBackground)
                            cycleDatesSection
                            if cycles.count >= 2 {
                                cycleLengthSection
                                phaseBreakdownSection
                            } else {
                                Text("Log at least 2 cycles to see charts and trends.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            recentLogsSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Cycle History")
        }
    }

    // MARK: - Cycle Dates

    private var cycleDatesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cycle Start Dates")
                .font(.headline)

            ForEach(Array(cycles.enumerated()), id: \.element.id) { index, cycle in
                DatePicker(
                    "Cycle \(index + 1)",
                    selection: Binding(
                        get: { cycle.startDate },
                        set: { cycle.startDate = Calendar.current.startOfDay(for: $0) }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
            }

            Text("Edit dates here anytime to correct your tracking history.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(cardBackground)
    }

    // MARK: - Cycle Length Trend

    private var cycleLengthSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cycle Length Trend")
                .font(.headline)
        }
        .padding()
        .background(cardBackground)
    }

    // MARK: - Phase Breakdown

    private var phaseBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Phase Breakdown")
                .font(.headline)

            if let latest = cycles.last {
                let phases = CycleCalculator.phaseRanges(
                    cycleLength: latest.cycleLength,
                    periodLength: latest.periodLength
                )

                Chart(phases) { item in
                    BarMark(
                        x: .value("Phase", item.phase.displayName),
                        y: .value("Days", item.duration)
                    )
                    .foregroundStyle(item.phase.color)
                    .annotation(position: .top) {
                        Text("\(item.duration)d")
                            .font(.caption2)
                    }
                }
                .frame(height: 200)
                .chartLegend(.hidden)

                ForEach(phases) { range in
                    HStack {
                        Circle()
                            .fill(range.phase.color)
                            .frame(width: 10, height: 10)
                        Text(range.phase.displayName)
                            .font(.subheadline)
                        Spacer()
                        Text("\(range.duration) days")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(cardBackground)
    }

    // MARK: - Recent Logs

    private var recentLogsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Logs")
                .font(.headline)

            if logs.isEmpty {
                Text("No symptom logs yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(logs.prefix(10)) { log in
                    HStack {
                        Text(log.date, style: .date)
                            .font(.subheadline)
                        Spacer()
                        if let mood = log.mood {
                            Text(mood.emoji)
                        }
                        Text("Flow: \(log.flowIntensity.displayName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.white.opacity(0.58))
    }

    private var backgroundPhase: CyclePhase {
        CycleCalculator.phase(for: Date(), cycles: cycles) ?? .follicular
    }
}
