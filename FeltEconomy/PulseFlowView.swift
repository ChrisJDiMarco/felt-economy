import SwiftData
import SwiftUI
import UIKit

struct PulseReceipt: Identifiable {
    let id = UUID()
    let cadence: PulseCadence
    let signal: FeelingSignal
    let value: Int
    let tag: String
    let resonanceCount: Int
    let closestRegion: MoodRegion
    let nudge: Double

    var healthScore: Int {
        signal.healthScore(from: value)
    }
}

struct PulseFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let existingPulses: [PulseRecord]

    @State private var selectedCadence = PulseCadence.live
    @State private var selectedSignal: FeelingSignal = .hope
    @State private var value = 58.0
    @State private var selectedTag = "Work"
    @State private var note = ""
    @State private var receipt: PulseReceipt?

    private let tagOptions = ["Work", "Home", "People", "News", "Money", "Health", "Alone", "Outside"]
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    private var integerValue: Int {
        Int(value.rounded())
    }

    private var cadenceAlreadyLogged: Bool {
        selectedCadence != .live && existingPulses.submittedToday(cadence: selectedCadence)
    }

    private var canSubmit: Bool {
        !cadenceAlreadyLogged
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if let receipt {
                    ResonanceReceiptView(receipt: receipt) {
                        dismiss()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            header
                            signalPicker
                            valuePanel
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 10)
                        .padding(.bottom, 110)
                    }

                    VStack {
                        Spacer()
                        bottomBar
                    }
                }
            }
            .navigationTitle(receipt == nil ? "Check In" : "Signal Sent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            if cadenceAlreadyLogged {
                selectedCadence = .live
            }
        }
    }

    private var header: some View {
        Panel(padding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Label("Right now", systemImage: selectedCadence.symbol)
                    .font(.system(.title2, design: .rounded, weight: .bold))

                Text(selectedCadence.prompt)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)

                Text("One private signal. No post, no profile.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var cadencePicker: some View {
        Panel {
            VStack(alignment: .leading, spacing: 12) {
                Text("When")
                    .font(.headline)

                HStack(spacing: 8) {
                    ForEach(PulseCadence.allCases) { cadence in
                        CadenceChoiceButton(
                            cadence: cadence,
                            isSelected: selectedCadence == cadence,
                            isLogged: cadence != .live && existingPulses.submittedToday(cadence: cadence)
                        ) {
                            selectedCadence = cadence
                        }
                    }
                }
            }
        }
    }

    private var signalPicker: some View {
        Panel {
            VStack(alignment: .leading, spacing: 12) {
                Text("Feeling")
                    .font(.headline)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(FeelingSignal.allCases) { signal in
                        SignalChoiceButton(signal: signal, isSelected: selectedSignal == signal) {
                            selectedSignal = signal
                        }
                    }
                }
            }
        }
    }

    private var valuePanel: some View {
        Panel(padding: 18) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 18) {
                    ScoreRing(score: selectedSignal.healthScore(from: integerValue), size: 116)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(integerValue)")
                            .font(.system(size: 58, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(selectedSignal.tint)
                        SignalStatusBadge(status: selectedSignal.status(for: integerValue))
                        Text(selectedSignal.isInverse ? "Right means heavier" : "Right means stronger")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                Slider(value: $value, in: 0...100, step: 1)
                    .tint(selectedSignal.tint)
                    .accessibilityLabel(selectedSignal.title)
                    .accessibilityValue("\(integerValue) out of 100")

                HStack {
                    Text(selectedSignal.lowAnchor)
                    Spacer()
                    Text(selectedSignal.highAnchor)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    StepButton(symbol: "minus", title: "Decrease \(selectedSignal.title)") {
                        value = Swift.max(0, value - 1)
                    }
                    StepButton(symbol: "gobackward.10", title: "Decrease \(selectedSignal.title) by ten") {
                        value = Swift.max(0, value - 10)
                    }
                    StepButton(symbol: "goforward.10", title: "Increase \(selectedSignal.title) by ten") {
                        value = Swift.min(100, value + 10)
                    }
                    StepButton(symbol: "plus", title: "Increase \(selectedSignal.title)") {
                        value = Swift.min(100, value + 1)
                    }
                }
            }
        }
    }

    private var tagPanel: some View {
        Panel {
            VStack(alignment: .leading, spacing: 12) {
                Text("What shaped it?")
                    .font(.headline)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(tagOptions, id: \.self) { tag in
                        TagChip(title: tag, isSelected: selectedTag == tag) {
                            selectedTag = tag
                        }
                    }
                }

                TextField("Add a few words if you want", text: $note, axis: .vertical)
                    .lineLimit(2...4)
                    .padding(12)
                    .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 8) {
            if cadenceAlreadyLogged {
                Text("\(selectedCadence.title) is already done today. Choose Right now to add another moment.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
            }

            CapsuleActionButton(
                title: selectedCadence == .live ? "Share this moment" : "Unlock today",
                symbol: "paperplane.fill",
                isEnabled: canSubmit,
                action: submit
            )
            .padding(.horizontal, 18)
        }
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(.regularMaterial)
    }

    private func submit() {
        guard canSubmit else { return }
        let record = PulseRecord(
            dayStart: Calendar.current.startOfFeltDay(containing: Date()),
            submittedAt: Date(),
            cadence: selectedCadence,
            signal: selectedSignal,
            value: integerValue,
            tag: selectedTag,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(record)
        try? modelContext.save()

        let pulseReceipt = PulseReceipt(
            cadence: selectedCadence,
            signal: selectedSignal,
            value: integerValue,
            tag: selectedTag,
            resonanceCount: SocialPulseData.resonanceCount(for: selectedSignal, value: integerValue),
            closestRegion: SocialPulseData.closestRegion(for: selectedSignal, value: integerValue),
            nudge: SocialPulseData.mapNudge(for: selectedSignal, value: integerValue)
        )

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) {
            receipt = pulseReceipt
        }
    }
}

struct ResonanceReceiptView: View {
    let receipt: PulseReceipt
    let done: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private var title: String {
        if receipt.signal.isInverse && receipt.value >= 58 {
            return "You are not alone in this."
        }

        if receipt.signal == .hope && receipt.value >= 55 {
            return "You added a little light."
        }

        if receipt.signal == .belonging || receipt.signal == .heard {
            return "Your signal found company."
        }

        return "Your signal joined the map."
    }

    private var subtitle: String {
        "\(receipt.resonanceCount.formatted()) people are near this \(receipt.signal.compactTitle.lowercased()) signal today."
    }

    private var nudgeText: String {
        String(format: "+%.2f", receipt.nudge)
    }

    private var shareText: String {
        "Today's Felt weather: \(SocialPulseData.nationalScore(for: .overall))/100 overall. \(receipt.resonanceCount.formatted()) anonymous signals are near my check-in."
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                Spacer(minLength: 8)

                Panel(padding: 22) {
                    VStack(spacing: 18) {
                        ReceiptConstellation(receipt: receipt)
                            .frame(height: 230)
                            .scaleEffect(appeared ? 1 : 0.92)
                            .opacity(appeared ? 1 : 0)

                        VStack(spacing: 8) {
                            Text(title)
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.72)
                            Text(subtitle)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)

                        Text("\(receipt.closestRegion.abbreviation) glow · \(nudgeText) ripple")
                            .font(.callout.weight(.bold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(spacing: 9) {
                            CapsuleActionButton(title: "See the map", symbol: "map", action: done)

                            ShareLink(item: shareText) {
                                Label("Share the weather", systemImage: "square.and.arrow.up")
                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .foregroundStyle(FeltTheme.ink.opacity(0.78))
                                    .background(.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Text("Anonymous. No profile. No exact location.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 22)
            }
            .padding(18)
        }
        .onAppear {
            guard !reduceMotion else {
                appeared = true
                return
            }

            withAnimation(.spring(response: 0.8, dampingFraction: 0.78).delay(0.08)) {
                appeared = true
            }
        }
    }
}

struct ReceiptConstellation: View {
    let receipt: PulseReceipt

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    private let dots: [(x: CGFloat, y: CGFloat, scale: CGFloat)] = [
        (0.18, 0.26, 0.72),
        (0.30, 0.72, 0.58),
        (0.48, 0.18, 0.48),
        (0.68, 0.31, 0.66),
        (0.78, 0.67, 0.54),
        (0.40, 0.84, 0.42)
    ]

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(receipt.signal.tint.opacity(0.20 - Double(index) * 0.04), lineWidth: 1.4)
                        .frame(width: CGFloat(130 + index * 48), height: CGFloat(130 + index * 48))
                        .scaleEffect(pulse ? 1.08 : 0.96)
                }

                ForEach(dots.indices, id: \.self) { index in
                    let dot = dots[index]
                    Circle()
                        .fill(.white.opacity(0.88))
                        .frame(width: 18 * dot.scale, height: 18 * dot.scale)
                        .overlay {
                            Circle().stroke(receipt.signal.tint.opacity(0.44), lineWidth: 1)
                        }
                        .position(x: size.width * dot.x, y: size.height * dot.y)
                        .shadow(color: receipt.signal.tint.opacity(0.22), radius: 10, x: 0, y: 4)
                }

                Path { path in
                    for dot in dots {
                        path.move(to: center)
                        path.addLine(to: CGPoint(x: size.width * dot.x, y: size.height * dot.y))
                    }
                }
                .stroke(receipt.signal.tint.opacity(0.18), style: StrokeStyle(lineWidth: 1, dash: [4, 7]))

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white, receipt.signal.tint.opacity(0.42), FeltTheme.cyan.opacity(0.10)],
                                center: .topLeading,
                                startRadius: 4,
                                endRadius: 84
                            )
                        )
                        .frame(width: 132, height: 132)
                        .shadow(color: receipt.signal.tint.opacity(0.30), radius: 28, x: 0, y: 12)

                    VStack(spacing: 3) {
                        Image(systemName: receipt.signal.symbol)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(receipt.signal.tint)
                        Text("\(receipt.value)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text(receipt.signal.compactTitle)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                }
                .scaleEffect(pulse ? 1.02 : 0.98)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Your \(receipt.signal.title) signal joined \(receipt.resonanceCount) anonymous nearby signals")
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

struct CadenceChoiceButton: View {
    let cadence: PulseCadence
    let isSelected: Bool
    let isLogged: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                Image(systemName: isLogged ? "checkmark.seal.fill" : cadence.symbol)
                    .font(.headline.weight(.bold))
                Text(cadence.shortTitle)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .foregroundStyle(isSelected ? .white : .primary.opacity(0.78))
            .background(isSelected ? FeltTheme.actionGradient : LinearGradient(colors: [Color.white.opacity(0.66), Color.white.opacity(0.40)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct SignalChoiceButton: View {
    let signal: FeelingSignal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                SignalGlyph(signal: signal)
                Text(signal.compactTitle)
                    .font(.caption.weight(.bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                Spacer(minLength: 0)
            }
            .padding(10)
            .foregroundStyle(isSelected ? .white : .primary.opacity(0.82))
            .background(isSelected ? LinearGradient(colors: [signal.tint, FeltTheme.cyan], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.white.opacity(0.66), Color.white.opacity(0.40)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct TagChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(isSelected ? .white : .primary.opacity(0.78))
                .background(isSelected ? FeltTheme.warmGradient : LinearGradient(colors: [Color.white.opacity(0.66), Color.white.opacity(0.40)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
