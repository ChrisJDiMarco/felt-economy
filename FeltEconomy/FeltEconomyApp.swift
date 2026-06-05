import SwiftData
import SwiftUI

@main
struct FeltEconomyApp: App {
    var body: some Scene {
        WindowGroup {
            FeltEconomyRootView()
        }
        .modelContainer(for: [CheckInRecord.self, PulseRecord.self])
    }
}
