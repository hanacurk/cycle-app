import SwiftUI

struct ContentView: View {
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

            LogSymptomView()
                .tabItem {
                    Label("Log", systemImage: "plus.circle.fill")
                }

            CycleHistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar.fill")
                }
        }
        .tint(.pink)
    }
}
