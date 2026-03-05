import SwiftUI
import SwiftData

@main
struct CycleTrackerApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([CycleRecord.self, DailyLog.self])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
