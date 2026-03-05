import SwiftUI
import SwiftData

struct LogSymptomView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CycleRecord.startDate, order: .reverse) private var cycles: [CycleRecord]

    let dismissible: Bool

    @State private var selectedDate = Date()
    @State private var selectedMood: Mood?
    @State private var selectedFlow: FlowIntensity = .none
    @State private var selectedCramps: CrampSeverity = .none
    @State private var selectedEnergy: EnergyLevel = .medium
    @State private var notes = ""
    @State private var showingSaved = false

    init(dismissible: Bool = false) {
        self.dismissible = dismissible
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        PhaseBlobCharacterView(phase: backgroundPhase, size: 70)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quick check-in")
                                .font(.headline)
                            Text("Log how you feel today.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Date") {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }

                Section("Mood") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Mood.allCases) { mood in
                                VStack(spacing: 4) {
                                    Text(mood.emoji)
                                        .font(.title)
                                    Text(mood.displayName)
                                        .font(.caption2)
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedMood == mood ? backgroundPhase.color.opacity(0.2) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedMood == mood ? backgroundPhase.color : Color.clear, lineWidth: 1.5)
                                )
                                .onTapGesture {
                                    selectedMood = selectedMood == mood ? nil : mood
                                }
                            }
                        }
                    }
                }

                Section("Flow Intensity") {
                    Picker("Flow", selection: $selectedFlow) {
                        ForEach(FlowIntensity.allCases) { flow in
                            Text(flow.displayName).tag(flow)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Cramps") {
                    Picker("Cramps", selection: $selectedCramps) {
                        ForEach(CrampSeverity.allCases) { cramp in
                            Text(cramp.displayName).tag(cramp)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Energy Level") {
                    Picker("Energy", selection: $selectedEnergy) {
                        ForEach(EnergyLevel.allCases) { energy in
                            Text(energy.displayName).tag(energy)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .scrollContentBackground(.hidden)
            .background(backgroundPhase.backgroundTint.opacity(0.55))
            .navigationTitle("Log Symptoms")
            .toolbar {
                if dismissible {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveLog() }
                }
            }
            .overlay {
                if showingSaved {
                    savedConfirmation
                }
            }
        }
    }

    private var backgroundPhase: CyclePhase {
        CycleCalculator.phase(for: Date(), cycles: cycles) ?? .follicular
    }

    // MARK: - Save confirmation overlay

    private var savedConfirmation: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)
            Text("Saved!")
                .font(.headline)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Actions

    private func saveLog() {
        let log = DailyLog(date: selectedDate)
        log.mood = selectedMood
        log.flowIntensity = selectedFlow
        log.crampSeverity = selectedCramps
        log.energyLevel = selectedEnergy
        log.notes = notes.isEmpty ? nil : notes
        modelContext.insert(log)

        if dismissible {
            dismiss()
        } else {
            withAnimation { showingSaved = true }
            resetForm()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showingSaved = false }
            }
        }
    }

    private func resetForm() {
        selectedMood = nil
        selectedFlow = .none
        selectedCramps = .none
        selectedEnergy = .medium
        notes = ""
    }
}
