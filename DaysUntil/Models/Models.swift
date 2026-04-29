import Foundation
import SwiftUI
import Observation

struct Event: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var emoji: String = "🎯"
    var colorID: String = "default"
    var createdAt: Date = .now

    /// Whole days from "today, local time, midnight" to "event-date midnight".
    /// Past events return a negative number; today returns 0.
    var daysFromToday: Int {
        let cal = Calendar.current
        let now = cal.startOfDay(for: .now)
        let then = cal.startOfDay(for: date)
        return cal.dateComponents([.day], from: now, to: then).day ?? 0
    }

    var isPast: Bool { daysFromToday < 0 }
    var isToday: Bool { daysFromToday == 0 }
}

struct EventColor: Identifiable, Hashable {
    let id: String
    let displayName: String
    let color: Color
    let isPremium: Bool

    static let all: [EventColor] = [
        // Free
        EventColor(id: "default", displayName: "Default", color: .accentColor, isPremium: false),
        EventColor(id: "graphite", displayName: "Graphite", color: .gray, isPremium: false),
        // Premium
        EventColor(id: "rose",     displayName: "Rose",     color: hex("#E63946"), isPremium: true),
        EventColor(id: "amber",    displayName: "Amber",    color: hex("#F4A261"), isPremium: true),
        EventColor(id: "ocean",    displayName: "Ocean",    color: hex("#0077B6"), isPremium: true),
        EventColor(id: "forest",   displayName: "Forest",   color: hex("#2A9D8F"), isPremium: true),
        EventColor(id: "violet",   displayName: "Violet",   color: hex("#7209B7"), isPremium: true),
        EventColor(id: "midnight", displayName: "Midnight", color: hex("#10002B"), isPremium: true),
    ]

    static func by(id: String) -> EventColor {
        all.first { $0.id == id } ?? all[0]
    }
}

private func hex(_ s: String) -> Color {
    let cleaned = s.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    var int: UInt64 = 0
    Scanner(string: cleaned).scanHexInt64(&int)
    let r = Double((int >> 16) & 0xFF) / 255
    let g = Double((int >> 8) & 0xFF) / 255
    let b = Double(int & 0xFF) / 255
    return Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
}

@Observable
final class EventStore {
    static let freeEventLimit = 3

    var events: [Event] = []

    init() {
        load()
        if events.isEmpty { seed() }
    }

    private func seed() {
        let cal = Calendar.current
        let newYear = cal.date(from: DateComponents(year: cal.component(.year, from: .now) + 1, month: 1, day: 1)) ?? .now
        events = [Event(title: "New Year", date: newYear, emoji: "🎉", colorID: "default")]
        save()
    }

    /// Past first, today next, future last (chronological with past flipped to most-recent-first).
    var sortedEvents: [Event] {
        events.sorted { lhs, rhs in
            if lhs.daysFromToday >= 0 && rhs.daysFromToday >= 0 {
                return lhs.daysFromToday < rhs.daysFromToday
            }
            if lhs.daysFromToday < 0 && rhs.daysFromToday < 0 {
                return lhs.daysFromToday > rhs.daysFromToday
            }
            // Future events come before past events.
            return lhs.daysFromToday >= 0
        }
    }

    func add(_ event: Event) {
        events.append(event)
        save()
    }

    func update(_ event: Event) {
        guard let idx = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[idx] = event
        save()
    }

    func delete(_ event: Event) {
        events.removeAll { $0.id == event.id }
        save()
    }

    // MARK: - Persistence

    private var saveURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("daysuntil_state.json")
    }

    private func save() {
        if let data = try? JSONEncoder().encode(events) {
            try? data.write(to: saveURL, options: .atomic)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let arr = try? JSONDecoder().decode([Event].self, from: data) else { return }
        events = arr
    }
}
