import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \CycleRecord.startDate, order: .reverse) private var cycles: [CycleRecord]

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
        .fontDesign(.rounded)
        .tint(activePhase.color)
    }

    private var activePhase: CyclePhase {
        CycleCalculator.phase(for: Date(), cycles: cycles) ?? .follicular
    }
}
