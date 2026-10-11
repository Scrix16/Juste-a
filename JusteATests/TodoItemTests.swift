import XCTest
@testable import JusteA

final class TodoItemTests: XCTestCase {
    private let day = Date(timeIntervalSince1970: 1_760_000_000)

    func testUndoneTodoIsAlwaysVisible() {
        XCTAssertTrue(TodoItem(title: "a").isVisible(on: day))
    }

    func testTodoDoneTodayIsVisible() {
        let todo = TodoItem(title: "a")
        todo.doneAt = day
        XCTAssertTrue(todo.isVisible(on: day))
    }

    func testTodoDoneYesterdayIsHidden() {
        let todo = TodoItem(title: "a")
        todo.doneAt = day.addingTimeInterval(-86_400)
        XCTAssertFalse(todo.isVisible(on: day))
    }
}
