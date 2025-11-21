import SwiftUI
import SwiftData

@main
struct RolledPromptMakerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Template.self,
            History.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("새 템플릿") {
                    // 새 템플릿 생성
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
