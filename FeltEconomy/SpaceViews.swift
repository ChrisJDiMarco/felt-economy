import Foundation
import SwiftUI

struct RitualSpaceView: View {
    let records: [CheckInRecord]
    let currentWeekCheckIn: CheckInRecord?
    let showCheckIn: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            if let currentWeekCheckIn {
                ContributionReceiptPanel(record: currentWeekCheckIn)
                CommonsRevealTeaser()
            } else {
                RitualPromptPanel(records: records, showCheckIn: showCheckIn)
            }

            WeekRhythmPanel(records: records)
        }
    }
}

struct RitualPromptPanel: View {
    let records: [CheckInRecord]
    let showCheckIn: () -> Void

    private var countdownText: String {
        let days = Date().daysUntilNextFeltWeek
        if days == 0 { return "Weekly reset is open" }
        if days == 1 { return "Next reset tomorrow" }
        return "Next reset in \(days) days"
    }

    var body: some View {
        Panel(padding: 18) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your weekly reset is ready")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        Text("A slower check-in for the bigger picture. Share once, then see how people are feeling this week.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    GlassSymbolTile(symbol: "sparkles", tint: FeltTheme.coral, size: 58)
                }

                CapsuleActionButton(title: "Start weekly reset", symbol: "arrow.right", action: showCheckIn)

                HStack(spacing: 8) {
                    StatPill(title: "current streak", value: "\(records.currentStreak())w", symbol: "flame")
                    StatPill(title: "status", value: countdownText, symbol: "calendar.badge.clock")
                }
            }
        }
    }
}

struct ContributionReceiptPanel: View {
    let record: CheckInRecord

    private var strongestSignal: FeelingSignal {
        FeelingSignal.allCases.max { record.healthScore(for: $0) < record.healthScore(for: $1) } ?? .hope
    }

    private var tenderSignal: FeelingSignal {
        FeelingSignal.allCases.min { record.healthScore(for: $0) < record.healthScore(for: $1) } ?? .loneliness
    }

    var body: some View {
        Panel(padding: 18) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 16) {
                    ScoreRing(score: record.compositeScore, size: 112)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Week contributed", systemImage: "checkmark.seal.fill")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color(red: 0.12, green: 0.48, blue: 0.30))
                        Text(record.weekStart.formatted(.dateTime.month(.wide).day()) + " reset")
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            StatPill(title: "brightest", value: strongestSignal.compactTitle, symbol: strongestSignal.symbol)
                            StatPill(title: "tender", value: tenderSignal.compactTitle, symbol: tenderSignal.symbol)
                        }
                    }
                }

                Text("You unlocked the shared view for this week. Your personal notes stay private; people only see anonymous totals.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct CommonsRevealTeaser: View {
    var body: some View {
        Panel {
            HStack(spacing: 14) {
                GlassSymbolTile(symbol: "lock.open.fill", tint: FeltTheme.mint, size: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text("People view is open")
                        .font(.headline)
                    Text("Go to People to see how your week compares with the anonymous group.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct WeekRhythmPanel: View {
    let records: [CheckInRecord]

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("Weekly rhythm", systemImage: "calendar")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                HStack(spacing: 8) {
                    StatPill(title: "next window", value: nextWindowText, symbol: "clock")
                    StatPill(title: "history", value: "\(records.count) weeks", symbol: "archivebox")
                }

                Text("A weekly reset stays closed until next Monday, so the deeper check-in does not turn into another feed.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var nextWindowText: String {
        let days = Date().daysUntilNextFeltWeek
        if days == 1 { return "tomorrow" }
        if days == 0 { return "today" }
        return "\(days)d"
    }
}

struct PatternSpaceView: View {
    let records: [CheckInRecord]
    let showCheckIn: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            if let latest = records.first {
                PersonalSummaryPanel(latest: latest, records: records)
                WhatChangedPanel(records: records)
                MilestonePanel(records: records)
                SoulCompassPanel(records: records)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Your signals")
                        .font(.title3.bold())
                    ForEach(FeelingSignal.allCases) { signal in
                        SignalTrendCard(signal: signal, records: records)
                    }
                }
            } else {
                EmptyStatePanel(
                    title: "Start with one honest check-in",
                    subtitle: "Your private pattern begins after your first weekly reset.",
                    symbol: "waveform.path",
                    buttonTitle: "Start reset",
                    action: showCheckIn
                )
            }
        }
    }
}

struct PersonalSummaryPanel: View {
    let latest: CheckInRecord
    let records: [CheckInRecord]

    private var rankedSignals: [FeelingSignal] {
        FeelingSignal.allCases.sorted {
            latest.healthScore(for: $0) < latest.healthScore(for: $1)
        }
    }

    private var strongestSignal: FeelingSignal { rankedSignals.last ?? .hope }
    private var needsCareSignal: FeelingSignal { rankedSignals.first ?? .loneliness }

    private var summaryTitle: String {
        Calendar.feltWeek.isSameFeltWeek(latest.weekStart, Date()) ? "This week" : "Latest check-in"
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    ScoreRing(score: latest.compositeScore, size: 110)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(summaryTitle)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        Text(latest.weekStart.formatted(.dateTime.month(.abbreviated).day()) + " reset")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            StatPill(title: "brightest", value: strongestSignal.compactTitle, symbol: strongestSignal.symbol)
                            StatPill(title: "tender", value: needsCareSignal.compactTitle, symbol: needsCareSignal.symbol)
                        }
                    }
                }

                Text("Your strongest feeling is \(strongestSignal.compactTitle.lowercased()). The feeling asking for care is \(needsCareSignal.compactTitle.lowercased()).")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct WhatChangedPanel: View {
    let records: [CheckInRecord]

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("What changed", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                if let composite = records.compositeChange(), let strongest = records.strongestDelta() {
                    HStack(spacing: 8) {
                        StatPill(title: "3-week score", value: composite >= 0 ? "+\(composite)" : "\(composite)", symbol: composite >= 0 ? "arrow.up.right" : "arrow.down.right")
                        StatPill(title: strongest.delta >= 0 ? "most lifted" : "most tender", value: strongest.signal.compactTitle, symbol: strongest.signal.symbol)
                    }

                    Text(summaryText(composite: composite, strongest: strongest))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("A few more weekly resets will give this view enough signal to compare patterns without over-reading noise.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func summaryText(composite: Int, strongest: (signal: FeelingSignal, delta: Int)) -> String {
        let direction = composite >= 0 ? "steadier" : "more tender"
        let movement = strongest.delta >= 0 ? "improved" : "softened"
        return "Across the last few entries, you look \(direction) by \(abs(composite)) points. \(strongest.signal.compactTitle) \(movement) the most, moving \(abs(strongest.delta)) points."
    }
}

struct MilestonePanel: View {
    let records: [CheckInRecord]

    private var streak: Int { records.currentStreak() }
    private var achieved: [Milestone] { MilestoneLibrary.achieved(for: streak) }
    private var next: Milestone? { MilestoneLibrary.next(after: streak) }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("Milestones", systemImage: "seal")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                HStack(spacing: 8) {
                    StatPill(title: "streak", value: "\(streak) weeks", symbol: "flame")
                    if let next {
                        StatPill(title: "next", value: "\(max(next.weeks - streak, 0))w", symbol: "flag")
                    }
                }

                if let latest = achieved.last {
                    Text("\(latest.title): \(latest.detail)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else if let next {
                    Text("\(next.title) unlocks at \(next.weeks) weeks. \(next.detail)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct SoulCompassPanel: View {
    let records: [CheckInRecord]
    @AppStorage("feltEconomy.soulCompassEntries") private var entryData = ""

    private var entries: [SoulCompassEntry] {
        decodeEntries()
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Kind note", systemImage: "sparkle.magnifyingglass")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Spacer()
                    Button {
                        addInsight()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                    .background(.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .accessibilityLabel("Refresh kind note")
                }

                Text(entries.first?.text ?? makeInsight())
                    .font(.callout)
                    .foregroundStyle(.primary.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)

                if let latest = entries.first {
                    HStack(spacing: 8) {
                        FeedbackButton(title: "Helpful", symbol: "hand.thumbsup", isSelected: latest.response == .helpful) {
                            rate(latest.id, response: .helpful)
                        }
                        FeedbackButton(title: "Not it", symbol: "hand.thumbsdown", isSelected: latest.response == .notHelpful) {
                            rate(latest.id, response: .notHelpful)
                        }
                    }
                }

                if entries.count > 1 {
                    Divider().opacity(0.35)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent guidance")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        ForEach(entries.dropFirst().prefix(2)) { entry in
                            Text(entry.text)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                } else {
                    Text("Generated locally from recent check-ins")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func makeInsight() -> String {
        guard let latest = records.first else {
            return "Start with one check-in. The first signal gives the compass something honest to work with."
        }

        let rankedSignals = FeelingSignal.allCases.sorted {
            latest.healthScore(for: $0) < latest.healthScore(for: $1)
        }
        let tenderSignal = rankedSignals.first ?? .loneliness
        let strongSignal = rankedSignals.last ?? .hope

        return "Your \(strongSignal.compactTitle.lowercased()) is carrying more strength than your \(tenderSignal.compactTitle.lowercased()) right now. Let the strong signal choose one small social action this week, but keep the ask gentle and specific."
    }

    private func decodeEntries() -> [SoulCompassEntry] {
        guard let data = entryData.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([SoulCompassEntry].self, from: data)) ?? []
    }

    private func save(_ entries: [SoulCompassEntry]) {
        guard let data = try? JSONEncoder().encode(Array(entries.prefix(5))) else { return }
        entryData = String(decoding: data, as: UTF8.self)
    }

    private func addInsight() {
        var current = decodeEntries()
        current.insert(SoulCompassEntry(text: makeInsight()), at: 0)
        save(current)
    }

    private func rate(_ id: UUID, response: SoulCompassResponse) {
        var current = decodeEntries()
        guard let index = current.firstIndex(where: { $0.id == id }) else { return }
        current[index].response = current[index].response == response ? .unrated : response
        save(current)
    }
}

struct FeedbackButton: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : .primary.opacity(0.76))
                .background(isSelected ? FeltTheme.warmGradient : LinearGradient(colors: [Color.white.opacity(0.62), Color.white.opacity(0.36)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SignalTrendCard: View {
    let signal: FeelingSignal
    let records: [CheckInRecord]

    private var orderedRecords: [CheckInRecord] { Array(records.oldestFirst.suffix(10)) }
    private var latest: CheckInRecord? { records.newestFirst.first }
    private var previous: CheckInRecord? { records.newestFirst.dropFirst().first }

    private var trendValues: [Double] {
        orderedRecords.map { Double($0.healthScore(for: signal)) }
    }

    private var delta: Int {
        guard let latest, let previous else { return 0 }
        return latest.healthScore(for: signal) - previous.healthScore(for: signal)
    }

    var body: some View {
        Panel(padding: 14) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    SignalGlyph(signal: signal)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(signal.title)
                            .font(.headline)
                        if let latest {
                            SignalStatusBadge(status: signal.status(for: latest.value(for: signal)))
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text("\(latest?.value(for: signal) ?? 0)")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .monospacedDigit()
                        Label(delta >= 0 ? "+\(delta)" : "\(delta)", systemImage: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(delta >= 0 ? Color(red: 0.13, green: 0.50, blue: 0.30) : Color(red: 0.75, green: 0.24, blue: 0.30))
                            .labelStyle(.titleAndIcon)
                    }
                }

                MiniTrendChart(values: trendValues, color: signal.tint)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(signal.title), current value \(latest?.value(for: signal) ?? 0), health trend \(delta >= 0 ? "up" : "down") \(abs(delta))")
    }
}

struct CommonsSpaceView: View {
    let records: [CheckInRecord]
    let currentWeekCheckIn: CheckInRecord?
    let showCheckIn: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            if let currentWeekCheckIn {
                SocialStatsPanel()
                PersonalCommonsComparisonPanel(record: currentWeekCheckIn)

                VStack(alignment: .leading, spacing: 10) {
                    Text("People this week")
                        .font(.title3.bold())
                    ForEach(SocialPulseData.aggregates) { aggregate in
                        SocialSignalCard(aggregate: aggregate)
                    }
                }

                CorrelationPanel()
            } else {
                LockedCollectivePanel(showCheckIn: showCheckIn)
            }
        }
    }
}

struct SocialStatsPanel: View {
    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("People view unlocked", systemImage: "lock.open.fill")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                HStack(spacing: 8) {
                    StatPill(title: "this week", value: SocialPulseData.weeklyParticipants.formatted(), symbol: "person.3")
                    StatPill(title: "check-ins", value: SocialPulseData.totalResponses.formatted(.number.notation(.compactName)), symbol: "chart.bar")
                    StatPill(title: "updated", value: SocialPulseData.lastUpdated, symbol: "clock")
                }

                Text("You shared first, so you can see the anonymous weekly picture. No names, no profiles, no tiny groups.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct PersonalCommonsComparisonPanel: View {
    let record: CheckInRecord

    private var comparisons: [(signal: FeelingSignal, delta: Int)] {
        FeelingSignal.allCases.compactMap { signal in
            guard let aggregate = SocialPulseData.aggregate(for: signal) else { return nil }
            return (signal, record.healthScore(for: signal) - aggregate.currentHealthScore)
        }
        .sorted { abs($0.delta) > abs($1.delta) }
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("You and people", systemImage: "arrow.left.arrow.right")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                ForEach(comparisons.prefix(3), id: \.signal) { item in
                    HStack(spacing: 12) {
                        SignalGlyph(signal: item.signal)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.signal.compactTitle)
                                .font(.headline)
                            Text(item.delta >= 0 ? "You feel \(item.delta) points steadier than people this week" : "You feel \(abs(item.delta)) points more tender than people this week")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(item.delta >= 0 ? "+\(item.delta)" : "\(item.delta)")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(item.delta >= 0 ? Color(red: 0.13, green: 0.50, blue: 0.30) : Color(red: 0.75, green: 0.24, blue: 0.30))
                    }
                }
            }
        }
    }
}

struct LockedCollectivePanel: View {
    let showCheckIn: () -> Void

    var body: some View {
        EmptyStatePanel(
            title: "People view is locked",
            subtitle: "Share your weekly reset first. Then you can see the anonymous picture for the week.",
            symbol: "lock.fill",
            buttonTitle: "Start reset",
            action: showCheckIn
        )
    }
}

struct SocialSignalCard: View {
    let aggregate: GlobalSignalAggregate

    private var displayedTrend: [Double] {
        aggregate.signal.isInverse ? aggregate.trend.map { 100 - $0 } : aggregate.trend
    }

    var body: some View {
        Panel(padding: 14) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    SignalGlyph(signal: aggregate.signal)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(aggregate.signal.title)
                            .font(.headline)
                        Text(aggregate.participants.formatted() + " people")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text("\(Int(aggregate.current))")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .monospacedDigit()
                        Text(String(format: "%+.1f%%", aggregate.changePercent))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(aggregate.changePercent >= 0 ? Color(red: 0.13, green: 0.50, blue: 0.30) : Color(red: 0.75, green: 0.24, blue: 0.30))
                    }
                }

                HStack(spacing: 12) {
                    MiniTrendChart(values: displayedTrend, color: aggregate.signal.tint)
                    VStack(alignment: .trailing, spacing: 7) {
                        SignalStatusBadge(status: SignalStatus(score: aggregate.currentHealthScore))
                        Text("\(Int((aggregate.confidence * 100).rounded()))% confidence")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct CorrelationPanel: View {
    private let rows = [
        ("Alone", "Trust", "-0.62", "move apart"),
        ("Belonging", "Heard", "+0.71", "move together"),
        ("Anxiety", "Hope", "-0.58", "move apart")
    ]

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("Patterns people share", systemImage: "point.3.connected.trianglepath.dotted")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                ForEach(rows, id: \.0) { left, right, value, label in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(left) / \(right)")
                                .font(.headline)
                            Text(label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(value)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .monospacedDigit()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct EmptyStatePanel: View {
    let title: String
    let subtitle: String
    let symbol: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 18) {
                GlassSymbolTile(symbol: symbol, tint: FeltTheme.violet, size: 62)

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                CapsuleActionButton(title: buttonTitle, symbol: "arrow.right", action: action)
            }
        }
    }
}
