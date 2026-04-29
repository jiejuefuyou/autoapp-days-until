import SwiftUI

struct EventEditView: View {
    @Environment(IAPManager.self) private var iap
    @Environment(\.dismiss) private var dismiss

    let initial: Event?
    let onSave: (Event) -> Void
    let onDelete: (() -> Void)?

    @State private var title: String
    @State private var date: Date
    @State private var emoji: String
    @State private var colorID: String

    @State private var showPaywall = false

    init(initial: Event?,
         onSave: @escaping (Event) -> Void,
         onDelete: (() -> Void)? = nil) {
        self.initial = initial
        self.onSave = onSave
        self.onDelete = onDelete
        _title   = State(initialValue: initial?.title ?? "")
        _date    = State(initialValue: initial?.date ?? Calendar.current.date(byAdding: .day, value: 30, to: .now)!)
        _emoji   = State(initialValue: initial?.emoji ?? "🎯")
        _colorID = State(initialValue: initial?.colorID ?? "default")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("e.g. Anna's birthday", text: $title)
                        .submitLabel(.done)
                }
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section("Icon") {
                    HStack(spacing: 16) {
                        TextField("🎯", text: $emoji)
                            .font(.system(size: 36))
                            .frame(width: 64)
                            .multilineTextAlignment(.center)
                            .onChange(of: emoji) { _, new in
                                emoji = String(new.prefix(2))
                            }
                        Text("Type or paste any emoji.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Color") {
                    let cols = [GridItem(.adaptive(minimum: 56), spacing: 12)]
                    LazyVGrid(columns: cols, spacing: 12) {
                        ForEach(EventColor.all) { c in
                            colorTile(c)
                        }
                    }
                    .padding(.vertical, 4)
                }
                if onDelete != nil {
                    Section {
                        Button("Delete event", role: .destructive) {
                            onDelete?()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(initial == nil ? "New event" : "Edit event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }

    private func colorTile(_ c: EventColor) -> some View {
        Button {
            if c.isPremium && !iap.isPremium {
                showPaywall = true
            } else {
                colorID = c.id
                Haptics.light()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(c.color)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle().strokeBorder(c.id == colorID ? Color.primary : .clear, lineWidth: 3)
                    )
                if c.isPremium && !iap.isPremium {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(.black.opacity(0.5), in: Circle())
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let evt = Event(
            id: initial?.id ?? UUID(),
            title: trimmed,
            date: date,
            emoji: emoji.isEmpty ? "🎯" : emoji,
            colorID: colorID,
            createdAt: initial?.createdAt ?? .now
        )
        onSave(evt)
        Haptics.medium()
        dismiss()
    }
}
