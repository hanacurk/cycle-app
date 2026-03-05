import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \CycleRecord.startDate, order: .reverse) private var cycles: [CycleRecord]
    @State private var viewModel = CalendarViewModel()
    @State private var selectedDate: Date?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Month navigation
                HStack {
                    Button { viewModel.previousMonth() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                    }
                    Spacer()
                    Text(viewModel.monthYearString)
                        .font(.title2.bold())
                    Spacer()
                    Button { viewModel.nextMonth() } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                    }
                }
                .padding(.horizontal)

                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    // Weekday headers
                    ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                    }

                    // Day cells
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
                .padding(.horizontal)

                // Selected date detail
                if let sel = selectedDate {
                    selectedDateDetail(for: sel)
                }

                // Phase legend
                phaseLegend

                Spacer()
            }
            .navigationTitle("Calendar")
        }
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
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
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
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
        .padding(.horizontal)
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
        if isToday { return .pink }
        return .clear
    }

    var body: some View {
        Text("\(dayNumber)")
            .font(.system(.body, weight: isToday ? .bold : .regular))
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
