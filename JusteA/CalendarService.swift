import EventKit

/// Lit les calendriers déjà synchronisés sur le Mac (iCloud, Google, Outlook, abonnements .ics…).
@MainActor
@Observable
final class CalendarService {
    private let store = EKEventStore()
    private(set) var events: [EKEvent] = []
    private(set) var accessDenied = false

    func loadToday() async {
        do {
            guard try await store.requestFullAccessToEvents() else {
                accessDenied = true
                return
            }
            let start = Calendar.current.startOfDay(for: .now)
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
            events = store.events(matching: predicate).sorted { $0.startDate < $1.startDate }
        } catch {
            accessDenied = true
        }
    }
}
