import SwiftUI

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.title3.bold())
            Label("Agenda", systemImage: "calendar").font(.headline)
            AgendaList()
            Label("À faire", systemImage: "checklist").font(.headline)
            TodoList()
            Divider()
            HStack {
                Button("Ouvrir le tableau de bord") {
                    openWindow(id: "dashboard")
                    NSApplication.shared.activate()
                }
                Spacer()
                Button("Quitter") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(.link)
            }
        }
        .padding()
    }
}
