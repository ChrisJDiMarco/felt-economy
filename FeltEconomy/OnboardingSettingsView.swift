import SwiftData
import SwiftUI
@preconcurrency import UserNotifications

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 20) {
                Spacer(minLength: 32)

                Text("Felt")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.72)

                Text("One private tap. A calmer way to see how people are really doing.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 12) {
                    OnboardingCard(
                        symbol: "dot.radiowaves.left.and.right",
                        title: "Tap one feeling",
                        text: "No post, no profile, no performance. Just a quick private signal."
                    )
                    OnboardingCard(
                        symbol: "map",
                        title: "Open the map",
                        text: "Watch anonymous emotional weather shift across the country."
                    )
                    OnboardingCard(
                        symbol: "calendar",
                        title: "Reset weekly",
                        text: "Daily taps keep the map alive. Weekly resets reveal your deeper pattern."
                    )
                }

                Spacer()

                CapsuleActionButton(title: "Start", symbol: "arrow.right") {
                    hasSeenOnboarding = true
                }
            }
            .padding(22)
        }
    }
}

struct OnboardingCard: View {
    let symbol: String
    let title: String
    let text: String

    var body: some View {
        Panel {
            HStack(alignment: .top, spacing: 14) {
                GlassSymbolTile(symbol: symbol, tint: FeltTheme.blue, size: 48)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                    Text(text)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct ReminderDay: Identifiable, Hashable {
    let id: Int
    let title: String
}

struct AppSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let records: [CheckInRecord]
    let pulses: [PulseRecord]

    @AppStorage("feltEconomy.dailyRemindersEnabled") private var dailyRemindersEnabled = false
    @AppStorage("feltEconomy.remindersEnabled") private var remindersEnabled = false
    @AppStorage("feltEconomy.reminderWeekday") private var reminderWeekday = 2
    @AppStorage("feltEconomy.hasSeenOnboarding") private var hasSeenOnboarding = true
    @State private var showingDeleteConfirmation = false
    @State private var notificationStatus = "Off"

    private let dayOptions = [
        ReminderDay(id: 1, title: "Sunday"),
        ReminderDay(id: 2, title: "Monday"),
        ReminderDay(id: 3, title: "Tuesday")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        reminderPanel
                        privacyPanel
                        accessibilityPanel
                        aboutPanel
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task {
            await refreshNotificationStatus()
        }
        .confirmationDialog("Delete local check-ins?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete local data", role: .destructive) {
                deleteLocalData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the local prototype history from this simulator. It cannot be undone.")
        }
    }

    private var reminderPanel: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("Reminders", systemImage: "bell.badge")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                Toggle("Daily check-in", isOn: Binding(
                    get: { dailyRemindersEnabled },
                    set: { newValue in
                        dailyRemindersEnabled = newValue
                        if newValue {
                            Task { await scheduleDailyReminder() }
                        } else {
                            cancelDailyReminder()
                        }
                    }
                ))
                .font(.headline)

                Toggle("Weekly reset", isOn: Binding(
                    get: { remindersEnabled },
                    set: { newValue in
                        remindersEnabled = newValue
                        if newValue {
                            Task { await scheduleReminder() }
                        } else {
                            cancelReminder()
                        }
                    }
                ))
                .font(.headline)

                Picker("Reminder day", selection: $reminderWeekday) {
                    ForEach(dayOptions) { day in
                        Text(day.title).tag(day.id)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: reminderWeekday) { _, _ in
                    if remindersEnabled {
                        Task { await scheduleReminder() }
                    }
                }

                Text("Notification permission: \(notificationStatus). Daily check-in is 9:00 AM. Weekly reset uses the selected day at 9:00 AM.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var privacyPanel: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("Privacy and data", systemImage: "lock.shield")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                Text("Personal check-ins are stored locally with SwiftData. The map and People views use mock anonymous regional totals without user identifiers, exact location, or small-group results.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    ShareLink(item: exportText) {
                        Label("Export", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundStyle(Color(red: 0.75, green: 0.24, blue: 0.30))
                            .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var accessibilityPanel: some View {
        Panel {
            VStack(alignment: .leading, spacing: 12) {
                Label("Accessibility", systemImage: "accessibility")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                Text("Check-ins support VoiceOver labels, step buttons for precise 0-100 control, Dynamic Type, Reduce Motion, and Reduce Transparency fallbacks.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var aboutPanel: some View {
        Panel {
            VStack(alignment: .leading, spacing: 12) {
                Label("Prototype", systemImage: "app.badge")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                Button {
                    hasSeenOnboarding = false
                    dismiss()
                } label: {
                    Label("Replay onboarding", systemImage: "arrow.counterclockwise")
                        .font(.headline)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var exportText: String {
        records.oldestFirst.map { record in
            let values = FeelingSignal.allCases
                .map { "\($0.compactTitle): \(record.value(for: $0))" }
                .joined(separator: ", ")
            return "\(record.weekStart.formatted(date: .abbreviated, time: .omitted)) | score \(record.compositeScore) | \(values)"
        }
        .joined(separator: "\n")
        + "\n\nDaily check-ins\n"
        + pulses.oldestFirst.map { pulse in
            "\(pulse.submittedAt.formatted(date: .abbreviated, time: .shortened)) | \(pulse.cadence.title) | \(pulse.signal.compactTitle): \(pulse.value) | \(pulse.tag)"
        }
        .joined(separator: "\n")
    }

    private func refreshNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationStatus = switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral: "On"
        case .denied: "Denied"
        case .notDetermined: "Not requested"
        @unknown default: "Unknown"
        }
    }

    private func scheduleReminder() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else {
                remindersEnabled = false
                await refreshNotificationStatus()
                return
            }

            cancelReminder()

            let content = UNMutableNotificationContent()
            content.title = "Felt"
            content.body = "Your weekly reset is open."
            content.sound = .default

            var components = DateComponents()
            components.weekday = reminderWeekday
            components.hour = 9
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "feltEconomy.weeklyReminder", content: content, trigger: trigger)
            try await UNUserNotificationCenter.current().add(request)
            await refreshNotificationStatus()
        } catch {
            remindersEnabled = false
            await refreshNotificationStatus()
        }
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["feltEconomy.weeklyReminder"])
    }

    private func scheduleDailyReminder() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else {
                dailyRemindersEnabled = false
                await refreshNotificationStatus()
                return
            }

            cancelDailyReminder()

            let content = UNMutableNotificationContent()
            content.title = "Felt"
            content.body = "Add one private signal to the mood map."
            content.sound = .default

            var components = DateComponents()
            components.hour = 9
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "feltEconomy.dailyMarketReminder", content: content, trigger: trigger)
            try await UNUserNotificationCenter.current().add(request)
            await refreshNotificationStatus()
        } catch {
            dailyRemindersEnabled = false
            await refreshNotificationStatus()
        }
    }

    private func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["feltEconomy.dailyMarketReminder"])
    }

    private func deleteLocalData() {
        for record in records {
            modelContext.delete(record)
        }
        for pulse in pulses {
            modelContext.delete(pulse)
        }
        try? modelContext.save()
    }
}
