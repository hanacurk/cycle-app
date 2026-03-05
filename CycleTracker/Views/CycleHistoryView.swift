import SwiftUI
import SwiftData
import Charts

struct CycleHistoryView: View {
    @Query(sort: \CycleRecord.startDate) private var cycles: [CycleRecord]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]

    var body: some View {
        NavigationStack {
            ScrollView {
                if cycles.count >= 2 {
                    VStack(alignment: .leading, spacing: 24) {
                        cycleLengthSection
                        phaseBreakdownSection
                        recentLogsSection
                    }
                    .padding()
                } else {
                    ContentUnavailableView(
                        "Not Enough Data",
                        systemImage: "chart.bar",
                        description: Text("Log at least 2 cycles to see charts and trends.")
                    )
                }
            }
            .navigationTitle("Cycle History")
        }
    }

    // MARK: - Cycle Length Trend

    private var cycleLengthSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cycle Length Trend")
                .font(.headline)

        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
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

                // Phase detail list
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
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
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
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
    }

    // MARK: - Helpers

    private var averageCycleLength: Double? {
        guard !cycles.isEmpty else { return nil }
        let total = cycles.reduce(0) { $0 + $1.cycleLength }
        return Double(total) / Double(cycles.count)
    }
}
