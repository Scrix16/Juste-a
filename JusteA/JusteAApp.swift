import SwiftUI
import SwiftData

@main
struct JusteAApp: App {
    // Une seule source de données partagée par le tableau de bord et la barre de menu.
    private let container = try! ModelContainer(for: TodoItem.self)
    @State private var calendar = CalendarService()

    var body: some Scene {
        Window("Juste-a", id: "dashboard") {
            DashboardView()
                .frame(minWidth: 760, minHeight: 500)
        }
        .environment(calendar)
        .modelContainer(container)

        MenuBarExtra("Juste-a", systemImage: "sun.horizon") {
            MenuBarView()
                .frame(width: 340)
        }
        .menuBarExtraStyle(.window)
        .environment(calendar)
        .modelContainer(container)
    }
}
