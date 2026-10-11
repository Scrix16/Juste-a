import Foundation
import SwiftData

@Model
final class TodoItem {
    var title: String
    var createdAt: Date
    var doneAt: Date?

    init(title: String, createdAt: Date = .now) {
        self.title = title
        self.createdAt = createdAt
    }

    /// Une tâche reste visible tant qu'elle n'est pas faite, ou si elle a été faite aujourd'hui.
    func isVisible(on day: Date, calendar: Calendar = .current) -> Bool {
        guard let doneAt else { return true }
        return calendar.isDate(doneAt, inSameDayAs: day)
    }
}
