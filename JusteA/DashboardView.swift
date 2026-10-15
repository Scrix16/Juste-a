import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(CalendarService.self) private var calendar
    @Query private var todos: [TodoItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting).font(.largeTitle.bold())
                Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide).year())
                    .foregroundStyle(.secondary)
            }

            Card(title: "Aujourd'hui", systemImage: "sparkles") {
                Text(summary)
            }
            .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 16) {
                Card(title: "Agenda", systemImage: "calendar") { AgendaList() }
                Card(title: "À faire", systemImage: "checklist") { TodoList() }
            }
        }
        .padding(24)
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: "Bonjour"
        case 12..<18: "Bon après-midi"
        default: "Bonsoir"
        }
    }

    // ponytail: résumé construit à la main ; il sera remplacé par le brief IA du matin.
    private var summary: String {
        let todayTodos = todos.filter { $0.isVisible(on: .now) }
        let done = todayTodos.filter { $0.doneAt != nil }.count
        var text = "\(done)/\(todayTodos.count) tâches faites."
        if let next = calendar.events.first(where: { !$0.isAllDay && $0.startDate > .now }) {
            text += " Prochain : \(next.title ?? "") à \(next.startDate.formatted(date: .omitted, time: .shortened))."
        } else {
            text += " Plus rien à l'agenda aujourd'hui."
        }
        return text
    }
}
