import SwiftUI

struct ContentView: View {
    @Environment(EventStore.self) private var store
    @Environment(IAPManager.self) private var iap

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEvent: Event?
    @State private var addingEvent = false

    var body: some View {
        NavigationStack {
            Group {
                if store.events.isEmpty {
                    ContentUnavailableView {
                        Label("No events yet", systemImage: "calendar.badge.plus")
                    } description: {
                        Text("Tap + to add a date you're counting toward.")
                    }
                } else {
                    List {
                        ForEach(store.sortedEvents) { event in
                            EventRow(event: event)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    Haptics.light()
                                    editingEvent = event
                                }
                        }
                        .onDelete(perform: deleteAt)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("DaysUntil")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: { Image(systemName: "gear") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.light()
                        if store.events.count >= EventStore.freeEventLimit && !iap.isPremium {
                            showPaywall = true
                        } else {
                            addingEvent = true
                        }
                    } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(isPresented: $addingEvent) {
                EventEditView(initial: nil) { newEvent in
                    store.add(newEvent)
                    Haptics.success()
                }
            }
            .sheet(item: $editingEvent) { event in
                EventEditView(initial: event,
                              onSave: { updated in store.update(updated) },
                              onDelete: { store.delete(event); Haptics.warning() })
            }
            .fullScreenCover(isPresented: Binding(
                get: { !hasSeenOnboarding },
                set: { _ in /* OnboardingView writes hasSeenOnboarding directly */ }
            )) {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
    }

    private func deleteAt(_ offsets: IndexSet) {
        for i in offsets {
            if let evt = store.sortedEvents[safe: i] { store.delete(evt) }
        }
    }
}

private struct EventRow: View {
    let event: Event

    var body: some View {
        let color = EventColor.by(id: event.colorID).color
        HStack(spacing: 14) {
            Text(event.emoji)
                .font(.system(size: 32))
                .frame(width: 48, height: 48)
                .background(color.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(event.date, format: .dateTime.year().month().day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 0) {
                Text("\(abs(event.daysFromToday))")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
                Text(label(for: event))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func label(for event: Event) -> String {
        if event.isToday { return "today" }
        if event.isPast { return abs(event.daysFromToday) == 1 ? "day ago" : "days ago" }
        return abs(event.daysFromToday) == 1 ? "day to go" : "days to go"
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ContentView()
        .environment(EventStore())
        .environment(IAPManager())
}
