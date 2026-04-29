import SwiftUI

@main
struct DaysUntilApp: App {
    @State private var store = EventStore()
    @State private var iap = IAPManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(iap)
                .task { await iap.refresh() }
                .tint(.accentColor)
        }
    }
}
