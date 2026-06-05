import SwiftData
import SwiftUI

struct FeltEconomyRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CheckInRecord.weekStart, order: .reverse) private var checkIns: [CheckInRecord]
    @Query(sort: \PulseRecord.submittedAt, order: .reverse) private var pulses: [PulseRecord]
    @AppStorage("feltEconomy.hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var selectedSpace: FeltSpace = .map
    @State private var showingCheckIn = false
    @State private var showingPulse = false
    @State private var showingSettings = false

    private var currentWeekStart: Date {
        Calendar.feltWeek.startOfFeltWeek(containing: Date())
    }

    private var currentWeekCheckIn: CheckInRecord? {
        checkIns.first { Calendar.feltWeek.isDate($0.weekStart, inSameDayAs: currentWeekStart) }
    }

    private var hasCheckedInThisWeek: Bool {
        currentWeekCheckIn != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            header

                            switch selectedSpace {
                            case .map:
                                MoodMapSpaceView(
                                    pulses: pulses,
                                    showPulse: { showingPulse = true }
                                )
                            case .market:
                                TodayMarketView(
                                    pulses: pulses,
                                    records: checkIns,
                                    showPulse: { showingPulse = true },
                                    showWeeklyRitual: { showingCheckIn = true }
                                )
                            case .ritual:
                                RitualSpaceView(
                                    records: checkIns,
                                    currentWeekCheckIn: currentWeekCheckIn,
                                    showCheckIn: { showingCheckIn = true }
                                )
                            case .pattern:
                                PatternSpaceView(records: checkIns, showCheckIn: { showingCheckIn = true })
                            case .commons:
                                CommonsSpaceView(
                                    records: checkIns,
                                    currentWeekCheckIn: currentWeekCheckIn,
                                    showCheckIn: { showingCheckIn = true }
                                )
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 6)
                        .padding(.bottom, 16)
                    }

                    SpacePicker(selection: $selectedSpace)
                        .padding(.horizontal, 22)
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showingCheckIn) {
            CheckInFlowView(hasCheckedInThisWeek: hasCheckedInThisWeek)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingPulse) {
            PulseFlowView(existingPulses: pulses)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSettings) {
            AppSettingsView(records: checkIns, pulses: pulses)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: Binding(
            get: { !hasSeenOnboarding },
            set: { if !$0 { hasSeenOnboarding = true } }
        )) {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
        .task {
            DemoData.seedIfNeeded(records: checkIns, pulses: pulses, context: modelContext)
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Felt")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .tracking(0)
                Text("one private signal")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary.opacity(0.82))
            }

            Spacer(minLength: 8)

            Button {
                showingSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FeltTheme.ink.opacity(0.54))
                    .frame(width: 38, height: 38)
                    .background {
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .fill(.white.opacity(0.26))
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .stroke(.white.opacity(0.50), lineWidth: 1)
                    }
                    .shadow(color: FeltTheme.blue.opacity(0.05), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
            .accessibilityLabel("Settings and privacy")
        }
        .padding(.top, 2)
        .padding(.bottom, 2)
    }
}
