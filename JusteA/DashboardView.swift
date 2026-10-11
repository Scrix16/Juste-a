import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TodoItem.createdAt) private var todos: [TodoItem]
    @State private var calendar = CalendarService()
    @State private var newTodo = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.title3.bold())

            section("Agenda") {
                if calendar.accessDenied {
                    Text("Accès au calendrier refusé (Réglages Système › Confidentialité).")
                        .foregroundStyle(.secondary)
                } else if calendar.events.isEmpty {
                    Text("Rien de prévu aujourd'hui.").foregroundStyle(.secondary)
                }
                ForEach(calendar.events, id: \.eventIdentifier) { event in
                    HStack {
                        Text(event.isAllDay ? "Journée" : event.startDate.formatted(date: .omitted, time: .shortened))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)
                        Text(event.title ?? "")
                    }
                }
            }

            section("À faire") {
                ForEach(todos.filter { $0.isVisible(on: .now) }) { todo in
                    Toggle(todo.title, isOn: Binding(
                        get: { todo.doneAt != nil },
                        set: { todo.doneAt = $0 ? .now : nil }
                    ))
                    .toggleStyle(.checkbox)
                }
                TextField("Nouvelle tâche", text: $newTodo)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addTodo)
            }

            Divider()
            Button("Quitter Juste-a") { NSApplication.shared.terminate(nil) }
                .buttonStyle(.link)
        }
        .padding()
        .task { await calendar.loadToday() }
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            content()
        }
    }

    private func addTodo() {
        let title = newTodo.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        context.insert(TodoItem(title: title))
        newTodo = ""
    }
}
