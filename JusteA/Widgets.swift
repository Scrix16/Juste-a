import SwiftUI
import SwiftData

/// Les briques communes au tableau de bord et à la barre de menu.

struct Card<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage).font(.headline)
            content
            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.background.secondary, in: .rect(cornerRadius: 12))
    }
}

struct AgendaList: View {
    @Environment(CalendarService.self) private var calendar

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
                .opacity(event.endDate < .now ? 0.4 : 1)
            }
        }
        .task { await calendar.loadToday() }
    }
}

struct TodoList: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TodoItem.createdAt) private var todos: [TodoItem]
    @State private var newTodo = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
    }

    private func addTodo() {
        let title = newTodo.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        context.insert(TodoItem(title: title))
        newTodo = ""
    }
}
