import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CycleRecord.startDate, order: .reverse) private var cycles: [CycleRecord]
    @State private var viewModel = CycleViewModel()
    @State private var showingQuickLog = false
    @State private var showingNewCycle = false
    @State private var newStartDate = Date()
    @State private var newCycleLength = 28
    @State private var newPeriodLength = 5

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.hasData {
                    activeContent
                } else {
                    emptyState
                }
            }
            .navigationTitle("CycleTracker")
            .toolbar {
                if viewModel.hasData {
                    ToolbarItem(placement: .primaryAction) {
                        Button { prepareNewCycleForm() } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingQuickLog) {
                LogSymptomView(dismissible: true)
            }
            .sheet(isPresented: $showingNewCycle) {
                newCycleSheet
            }
            .onAppear { viewModel.update(with: cycles) }
            .onChange(of: cycles.count) { _, _ in viewModel.update(with: cycles) }
            .onChange(of: newCycleLength) { _, newValue in
                newPeriodLength = min(newPeriodLength, newValue)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 80)
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.pink)
            Text("Start Tracking")
                .font(.title2.bold())
            Text("Log your first period start date to begin tracking your cycle.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Start New Cycle") {
                prepareNewCycleForm()
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding()
    }

    // MARK: - Active Dashboard

    private var activeContent: some View {
        VStack(spacing: 20) {
            phaseCard
            statsGrid
            phaseTimeline
            quickLogButton
        }
        .padding()
    }

    private var phaseCard: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.currentPhase.icon)
                .font(.system(size: 44))
                .foregroundStyle(viewModel.currentPhase.color)
            Text(viewModel.currentPhase.displayName)
                .font(.title.bold())
            Text(viewModel.currentPhase.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Day \(viewModel.dayInPhase) of phase")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(viewModel.currentPhase.color.opacity(0.12))
        )
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            StatCard(title: "Cycle Day", value: "\(viewModel.dayInCycle)", subtitle: "of \(viewModel.cycleLength)")
            StatCard(title: "Next Period", value: "\(viewModel.daysUntilNextPeriod)", subtitle: "days")
            StatCard(title: "Cycle Length", value: "\(viewModel.cycleLength)", subtitle: "days")
        }
    }

    private var phaseTimeline: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cycle Phases")
                .font(.headline)
            ForEach(viewModel.phaseRanges) { range in
                HStack {
                    Circle()
                        .fill(range.phase.color)
                        .frame(width: 10, height: 10)
                    Text(range.phase.displayName)
                        .font(.subheadline)
                    Spacer()
                    Text("Days \(range.startDay)–\(range.endDay)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
    }

    private var quickLogButton: some View {
        Button {
            showingQuickLog = true
        } label: {
            Label("Quick Log", systemImage: "plus.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(.pink))
                .foregroundStyle(.white)
        }
    }

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
                            Text("\(newCycleLength) days")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Stepper(value: $newPeriodLength, in: 1...min(14, newCycleLength)) {
                        HStack {
                            Text("Period Length")
                            Spacer()
                            Text("\(newPeriodLength) days")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Text("If this is your first entry, previous cycle starts for the past year are generated automatically based on your cycle length.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
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
                        showingNewCycle = false
                    }
                }
            }
        }
    }

    private func prepareNewCycleForm() {
        newCycleLength = max(viewModel.cycleLength, 15)
        newPeriodLength = min(max(viewModel.periodLength, 1), min(14, newCycleLength))
        newStartDate = Date()
        showingNewCycle = true
    }
}

// MARK: - Stat Card

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
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
    }
}
