import XCTest
@testable import DaysUntil

final class EventTests: XCTestCase {

    func testEventCodableRoundTrip() throws {
        let original = Event(title: "Birthday", date: Date(timeIntervalSince1970: 1_800_000_000), emoji: "🎂", colorID: "rose")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Event.self, from: data)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.date, original.date)
        XCTAssertEqual(decoded.emoji, original.emoji)
        XCTAssertEqual(decoded.colorID, original.colorID)
    }

    func testDaysFromTodayPositiveForFutureDate() {
        let future = Calendar.current.date(byAdding: .day, value: 10, to: .now)!
        let evt = Event(title: "Soon", date: future)
        XCTAssertGreaterThanOrEqual(evt.daysFromToday, 9)
        XCTAssertLessThanOrEqual(evt.daysFromToday, 10)
        XCTAssertFalse(evt.isPast)
        XCTAssertFalse(evt.isToday)
    }

    func testDaysFromTodayNegativeForPastDate() {
        let past = Calendar.current.date(byAdding: .day, value: -5, to: .now)!
        let evt = Event(title: "Then", date: past)
        XCTAssertLessThanOrEqual(evt.daysFromToday, -4)
        XCTAssertTrue(evt.isPast)
    }

    func testTodayIsZero() {
        let now = Calendar.current.startOfDay(for: .now)
        let evt = Event(title: "Today", date: now)
        XCTAssertEqual(evt.daysFromToday, 0)
        XCTAssertTrue(evt.isToday)
        XCTAssertFalse(evt.isPast)
    }

    func testColorRegistry() {
        XCTAssertTrue(EventColor.all.contains(where: { $0.id == "default" && !$0.isPremium }))
        XCTAssertTrue(EventColor.all.contains(where: { $0.id == "rose" && $0.isPremium }))
        XCTAssertEqual(EventColor.by(id: "nonexistent").id, "default")
    }

    func testStoreCRUD() {
        let store = EventStore()
        let initialCount = store.events.count

        let evt = Event(title: "Test", date: .now, emoji: "🧪", colorID: "default")
        store.add(evt)
        XCTAssertEqual(store.events.count, initialCount + 1)

        var updated = evt
        updated.title = "Updated"
        store.update(updated)
        XCTAssertEqual(store.events.first(where: { $0.id == evt.id })?.title, "Updated")

        store.delete(evt)
        XCTAssertEqual(store.events.count, initialCount)
    }

    func testFreeEventLimitConstant() {
        XCTAssertGreaterThanOrEqual(EventStore.freeEventLimit, 1)
        XCTAssertLessThanOrEqual(EventStore.freeEventLimit, 10)
    }

    func testSortPutsFutureBeforePast() {
        let store = EventStore()
        // Wipe seeded
        for e in store.events { store.delete(e) }

        let future10 = Event(title: "f10", date: Calendar.current.date(byAdding: .day, value: 10, to: .now)!)
        let future3  = Event(title: "f3",  date: Calendar.current.date(byAdding: .day, value: 3,  to: .now)!)
        let past2    = Event(title: "p2",  date: Calendar.current.date(byAdding: .day, value: -2, to: .now)!)
        store.add(future10)
        store.add(past2)
        store.add(future3)

        let sorted = store.sortedEvents
        XCTAssertEqual(sorted[0].title, "f3")
        XCTAssertEqual(sorted[1].title, "f10")
        XCTAssertEqual(sorted[2].title, "p2")
    }
}
