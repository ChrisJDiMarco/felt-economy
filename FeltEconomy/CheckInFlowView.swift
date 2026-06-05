import SwiftData
import SwiftUI

struct CheckInFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let hasCheckedInThisWeek: Bool
    @State private var values: [FeelingSignal: Double] = Dictionary(
        uniqueKeysWithValues: FeelingSignal.allCases.map { signal in (signal, 50) }
    )
    @State private var reflection = ""
    @State private var currentStep = 0
    @State private var feedbackToken = 0

    private let signals = FeelingSignal.allCases

    private var totalSteps: Int {
        signals.count + 1
    }

    private var currentWeekStart: Date {
        Calendar.feltWeek.startOfFeltWeek(containing: Date())
    }

    private var currentPosture: EmotionalPosture {
        EmotionalPosture.classify(signals: signalInts)
    }

    private var signalInts: [FeelingSignal: Int] {
        Dictionary(uniqueKeysWithValues: FeelingSignal.allCases.map { signal in
            (signal, Int(values[signal, default: 50].rounded()))
        })
    }

    private var isReflectionStep: Bool {
        currentStep == signals.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 0) {
                    ritualHeader

                    TabView(selection: $currentStep) {
                        ForEach(Array(signals.enumerated()), id: \.element) { index, signal in
                            SignalRitualStep(
                                signal: signal,
                                value: Binding(
                                    get: { values[signal, default: 50] },
                                    set: {
                                        values[signal] = $0
                                        feedbackToken += 1
                                    }
                                )
                            )
                            .tag(index)
                        }

                        ReflectionRitualStep(
                            prompt: currentPosture.reflectionPrompt,
                            reflection: $reflection,
                            compositeScore: compositeScore
                        )
                        .tag(signals.count)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(reduceMotion ? nil : .snappy, value: currentStep)

                    bottomControls
                }
            }
            .navigationTitle("Weekly Reset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: currentStep)
        .sensoryFeedback(.impact(weight: .light), trigger: feedbackToken)
    }

    private var ritualHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Week of \(currentWeekStart.formatted(.dateTime.month(.wide).day()))")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text(hasCheckedInThisWeek ? "This week is already complete. You can review it, but not submit again." : "Seven quick sliders and one optional note.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                ProgressDots(count: totalSteps, activeIndex: currentStep)
            }

            ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                .tint(FeltTheme.cyan)
                .accessibilityLabel("Weekly reset progress")
                .accessibilityValue("Step \(currentStep + 1) of \(totalSteps)")
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var bottomControls: some View {
        HStack(spacing: 10) {
            Button {
                moveBack()
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .frame(width: 118)
                    .padding(.vertical, 15)
                    .foregroundStyle(currentStep == 0 ? .secondary : .primary)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(.white.opacity(0.66), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .disabled(currentStep == 0)

            CapsuleActionButton(
                title: isReflectionStep ? (hasCheckedInThisWeek ? "Already submitted" : "Submit") : "Continue",
                symbol: isReflectionStep ? "paperplane.fill" : "arrow.right",
                isEnabled: !isReflectionStep || !hasCheckedInThisWeek,
                action: { isReflectionStep ? submit() : moveForward() }
            )
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(.regularMaterial)
    }

    private var compositeScore: Int {
        let total = FeelingSignal.allCases.reduce(0) { partial, signal in
            partial + signal.healthScore(from: signalInts[signal, default: 50])
        }
        return total / FeelingSignal.allCases.count
    }

    private func moveBack() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    private func moveForward() {
        guard currentStep < totalSteps - 1 else { return }
        currentStep += 1
    }

    private func submit() {
        guard !hasCheckedInThisWeek else { return }

        let record = CheckInRecord(
            weekStart: currentWeekStart,
            submittedAt: Date(),
            reflection: reflection.trimmingCharacters(in: .whitespacesAndNewlines),
            signals: signalInts
        )
        modelContext.insert(record)
        try? modelContext.save()
        dismiss()
    }
}

struct SignalRitualStep: View {
    let signal: FeelingSignal
    @Binding var value: Double

    private var integerValue: Int {
        Int(value.rounded())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Panel(padding: 18) {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .top, spacing: 14) {
                            SignalGlyph(signal: signal)
                                .scaleEffect(1.16)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(signal.title)
                                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                    .minimumScaleFactor(0.76)
                                Text(signal.isInverse ? "Right means heavier" : "Right means stronger")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                            InlineInfoButton(title: signal.title, message: signal.explanation)
                        }

                        HStack(alignment: .center, spacing: 18) {
                            ScoreRing(score: signal.healthScore(from: integerValue), size: 132)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(integerValue)")
                                    .font(.system(size: 62, weight: .bold, design: .rounded))
                                    .monospacedDigit()
                                    .foregroundStyle(signal.tint)
                                SignalStatusBadge(status: signal.status(for: integerValue))
                            }
                        }

                        VStack(spacing: 12) {
                            Slider(value: $value, in: 0...100, step: 1)
                                .tint(signal.tint)
                                .accessibilityLabel(signal.title)
                                .accessibilityValue("\(integerValue) out of 100. \(signal.isInverse ? "Right means heavier." : "Right means stronger.")")
                                .accessibilityHint("Swipe up or down to adjust by one point.")

                            HStack {
                                Text(signal.lowAnchor)
                                Spacer()
                                Text(signal.highAnchor)
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        }

                        HStack(spacing: 10) {
                            StepButton(symbol: "minus", title: "Decrease \(signal.title)") {
                                value = max(0, value - 1)
                            }

                            StepButton(symbol: "gobackward.10", title: "Decrease \(signal.title) by ten") {
                                value = max(0, value - 10)
                            }

                            StepButton(symbol: "goforward.10", title: "Increase \(signal.title) by ten") {
                                value = min(100, value + 10)
                            }

                            StepButton(symbol: "plus", title: "Increase \(signal.title)") {
                                value = min(100, value + 1)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
    }
}

struct StepButton: View {
    let symbol: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.headline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.white.opacity(0.64), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct ReflectionRitualStep: View {
    let prompt: String
    @Binding var reflection: String
    let compositeScore: Int

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Panel(padding: 18) {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .center, spacing: 16) {
                            ScoreRing(score: compositeScore, size: 110)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Leave a note")
                                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                    .minimumScaleFactor(0.75)
                                Text("Optional reflection")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Text(prompt)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary.opacity(0.82))
                            .fixedSize(horizontal: false, vertical: true)

                        TextEditor(text: $reflection)
                            .frame(minHeight: 180)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(.white.opacity(0.66), lineWidth: 1)
                            }
                            .accessibilityLabel("Optional reflection")
                            .accessibilityHint("Dictation works well here.")

                        Text("This note stays private in the prototype. People only see anonymous totals.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
    }
}
