import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CycleRecord.startDate, order: .reverse) private var cycles: [CycleRecord]
    @State private var viewModel = CalendarViewModel()
    @State private var cycleEditor = CycleViewModel()
    @State private var selectedDate: Date?
    @State private var showingAddPeriod = false
    @State private var newStartDate = Date()
    @State private var newCycleLength = 28
    @State private var newPeriodLength = 5

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    backgroundPhase.backgroundTint.opacity(0.55)
                        .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            monthNavigation
                            
                            if let sel = selectedDate {
                                selectedDateDetail(for: sel)
                            }
                            
                            calendarGrid
                            phaseLegend
                        }
                        .padding(.bottom, 24)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? min(390, geometry.size.width * 0.6) : nil)
                    }
                }
                .fontDesign(.rounded)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            prepareAddPeriodForm()
                            showingAddPeriod = true
                        } label: {
                            Label("Add Period", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddPeriod) {
                    addPeriodSheet
                }
                .onAppear {
                    if selectedDate == nil {
                        selectedDate = Calendar.current.startOfDay(for: Date())
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var buddyHeader: some View {
        HStack(spacing: 12) {
            PhaseBlobCharacterView(phase: backgroundPhase, size: 76)
            VStack(alignment: .leading, spacing: 2) {
                Text("Calendar buddy")
                    .font(.headline)
                Text("Track your cycle and edit period dates here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.62))
        )
        .padding(.horizontal)
    }

    private var monthNavigation: some View {
        HStack {
            Button { viewModel.previousMonth() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.white.opacity(0.68)))
            }
            Spacer()
            Text(viewModel.monthYearString)
                .font(.title2.bold())
            Spacer()
            Button { viewModel.nextMonth() } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.bold())
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.white.opacity(0.68)))
            }
        }
        .padding(.horizontal)
        .padding(.top, 25)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.calendarDays) { day in
                if let date = day.date {
                    let phase = viewModel.phase(for: date, cycles: cycles)
                    DayCell(
                        dayNumber: day.dayNumber,
                        phase: phase,
                        isToday: Calendar.current.isDateInToday(date),
                        isSelected: selectedDate.map { Calendar.current.isDate(date, inSameDayAs: $0) } ?? false
                    )
                    .onTapGesture { selectedDate = date }
                } else {
                    Text("")
                        .frame(height: 36)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.58))
        )
        .padding(.horizontal)
    }

    // MARK: - Selected date detail

    private func selectedDateDetail(for date: Date) -> some View {
        let phase = viewModel.phase(for: date, cycles: cycles)
        return HStack {
            if let phase {
                Image(systemName: phase.icon)
                    .foregroundStyle(phase.color)
                Text(phase.displayName)
                    .font(.subheadline.bold())
            }
            Spacer()
            Text(date, style: .date)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.white.opacity(0.58)))
        .padding(.horizontal)
    }

    // MARK: - Period Management

    private var periodManagementSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Period Dates", systemImage: "drop.circle.fill")
                    .font(.headline)
                    .foregroundStyle(backgroundPhase.color)
                Spacer()
                Button {
                    prepareAddPeriodForm()
                    showingAddPeriod = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.caption.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(backgroundPhase.color)
            }

            if cycles.isEmpty {
                Text("No period start dates yet. Add your first one.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(cycles.enumerated()), id: \.element.id) { index, cycle in
                    DatePicker(
                        "Cycle \(index + 1) start",
                        selection: Binding(
                            get: { cycle.startDate },
                            set: { cycle.startDate = Calendar.current.startOfDay(for: $0) }
                        ),
                        in: ...Date(),
                        displayedComponents: .date
                    )
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.62)))
        .padding(.horizontal)
    }

    // MARK: - Legend

    private var phaseLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Phases")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(CyclePhase.allCases) { phase in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(phase.color)
                            .frame(width: 12, height: 12)
                        Text(phase.displayName)
                            .font(.caption)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.58)))
        .padding(.horizontal)
    }

    // MARK: - Add Period Sheet

    private var addPeriodSheet: some View {
        NavigationStack {
            Form {
                Section("Period Start Date") {
                    DatePicker(
                        "Start",
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
            }
            .scrollContentBackground(.hidden)
            .background(backgroundPhase.backgroundTint.opacity(0.58))
            .navigationTitle("Add Period")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAddPeriod = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        cycleEditor.startNewCycle(
                            context: modelContext,
                            existingCycles: cycles,
                            startDate: newStartDate,
                            cycleLength: newCycleLength,
                            periodLength: newPeriodLength
                        )
                        selectedDate = Calendar.current.startOfDay(for: newStartDate)
                        showingAddPeriod = false
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var backgroundPhase: CyclePhase {
        CycleCalculator.phase(for: Date(), cycles: cycles) ?? .follicular
    }

    private func prepareAddPeriodForm() {
        if let latest = cycles.first {
            newCycleLength = max(latest.cycleLength, 15)
            newPeriodLength = min(max(latest.periodLength, 1), min(14, newCycleLength))
        } else {
            newCycleLength = 28
            newPeriodLength = 5
        }
        newStartDate = Calendar.current.startOfDay(for: Date())
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let dayNumber: Int
    let phase: CyclePhase?
    let isToday: Bool
    let isSelected: Bool

    private var strokeColor: Color {
        if isSelected { return .primary }
        if isToday { return phase?.color ?? .primary }
        return .clear
    }

    var body: some View {
        Text("\(dayNumber)")
            .font(.system(size: 16, weight: isToday ? .bold : .regular, design: .rounded))
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(phase?.color.opacity(0.3) ?? Color.clear)
            )
            .overlay(
                Circle()
                    .stroke(strokeColor, lineWidth: 2)
            )
    }
}
