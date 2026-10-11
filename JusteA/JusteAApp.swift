import SwiftUI
import SwiftData

@main
struct JusteAApp: App {
    var body: some Scene {
        MenuBarExtra("Juste-a", systemImage: "sun.horizon") {
            DashboardView()
                .frame(width: 340)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(for: TodoItem.self)
    }
}
