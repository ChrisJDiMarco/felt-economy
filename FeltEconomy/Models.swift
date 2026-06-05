import Foundation
import SwiftData
import SwiftUI

enum FeelingSignal: String, CaseIterable, Codable, Identifiable {
    case loneliness
    case trust
    case belonging
    case stability
    case anxiety
    case heard
    case hope

    var id: String { rawValue }

    var title: String {
        switch self {
        case .loneliness: "Feeling alone"
        case .trust: "Trust"
        case .belonging: "Belonging"
        case .stability: "Steadiness"
        case .anxiety: "Anxiety"
        case .heard: "Feeling heard"
        case .hope: "Hope"
        }
    }

    var compactTitle: String {
        switch self {
        case .loneliness: "Alone"
        case .trust: "Trust"
        case .belonging: "Belonging"
        case .stability: "Steady"
        case .anxiety: "Anxiety"
        case .heard: "Heard"
        default: title
        }
    }

    var marketTitle: String {
        switch self {
        case .loneliness: "Feeling alone"
        case .trust: "Trust"
        case .belonging: "Belonging"
        case .stability: "Steadiness"
        case .anxiety: "Anxiety"
        case .heard: "Feeling heard"
        case .hope: "Hope"
        }
    }

    var symbol: String {
        switch self {
        case .loneliness: "person.crop.circle.badge.questionmark"
        case .trust: "hands.sparkles"
        case .belonging: "person.2.wave.2"
        case .stability: "building.columns"
        case .anxiety: "cloud.bolt"
        case .heard: "ear.badge.waveform"
        case .hope: "sun.max"
        }
    }

    var explanation: String {
        switch self {
        case .loneliness:
            "How alone or disconnected you feel."
        case .trust:
            "How safe it feels to rely on people around you."
        case .belonging:
            "How much you feel like you belong somewhere."
        case .stability:
            "How steady your world feels today."
        case .anxiety:
            "How much the future is weighing on you."
        case .heard:
            "How seen, heard, or understood you feel."
        case .hope:
            "How possible the next stretch feels."
        }
    }

    var lowAnchor: String {
        switch self {
        case .loneliness: "not alone"
        case .anxiety: "calm"
        case .trust: "closed"
        case .belonging: "outside"
        case .stability: "shaky"
        case .heard: "unseen"
        case .hope: "low"
        }
    }

    var highAnchor: String {
        switch self {
        case .loneliness: "very alone"
        case .anxiety: "anxious"
        case .trust: "open"
        case .belonging: "at home"
        case .stability: "steady"
        case .heard: "seen"
        case .hope: "bright"
        }
    }

    var isInverse: Bool {
        self == .loneliness || self == .anxiety
    }

    var tint: Color {
        switch self {
        case .loneliness: Color(red: 0.78, green: 0.29, blue: 0.40)
        case .trust: Color(red: 0.08, green: 0.50, blue: 0.72)
        case .belonging: Color(red: 0.24, green: 0.55, blue: 0.32)
        case .stability: Color(red: 0.92, green: 0.55, blue: 0.18)
        case .anxiety: Color(red: 0.62, green: 0.39, blue: 0.86)
        case .heard: Color(red: 0.10, green: 0.60, blue: 0.56)
        case .hope: Color(red: 0.97, green: 0.70, blue: 0.16)
        }
    }

    func healthScore(from value: Int) -> Int {
        isInverse ? 100 - value : value
    }

    func status(for value: Int) -> SignalStatus {
        SignalStatus(score: healthScore(from: value))
    }
}

enum SignalStatus: String {
    case critical
    case low
    case moderate
    case good
    case excellent

    init(score: Int) {
        switch score {
        case ..<25: self = .critical
        case 25..<45: self = .low
        case 45..<65: self = .moderate
        case 65..<82: self = .good
        default: self = .excellent
        }
    }

    var label: String {
        switch self {
        case .critical: "Needs care"
        case .low: "Tender"
        case .moderate: "Mixed"
        case .good: "Steady"
        case .excellent: "Bright"
        }
    }

    var color: Color {
        switch self {
        case .critical: Color(red: 0.79, green: 0.21, blue: 0.27)
        case .low: Color(red: 0.89, green: 0.45, blue: 0.22)
        case .moderate: Color(red: 0.76, green: 0.58, blue: 0.16)
        case .good: Color(red: 0.23, green: 0.55, blue: 0.34)
        case .excellent: Color(red: 0.07, green: 0.55, blue: 0.72)
        }
    }
}

enum EmotionalPosture {
    case struggling
    case hopeful
    case balanced
    case frayed

    static func classify(signals: [FeelingSignal: Int]) -> EmotionalPosture {
        let lonelinessHealth = FeelingSignal.loneliness.healthScore(from: signals[.loneliness, default: 50])
        let anxietyHealth = FeelingSignal.anxiety.healthScore(from: signals[.anxiety, default: 50])
        let hopeHealth = FeelingSignal.hope.healthScore(from: signals[.hope, default: 50])
        let belongingHealth = FeelingSignal.belonging.healthScore(from: signals[.belonging, default: 50])

        if lonelinessHealth < 38 || anxietyHealth < 38 { return .struggling }
        if hopeHealth > 76 && belongingHealth > 68 { return .hopeful }
        if anxietyHealth < 52 && hopeHealth > 60 { return .frayed }
        return .balanced
    }

    var reflectionPrompt: String {
        switch self {
        case .struggling:
            "What felt heaviest this week, and what helped even a little?"
        case .hopeful:
            "What gave you energy this week?"
        case .balanced:
            "What do you want to remember about this week?"
        case .frayed:
            "Where did you feel stretched, and what would make next week gentler?"
        }
    }
}

enum EmotionLayer: String, CaseIterable, Identifiable {
    case overall
    case hope
    case anxiety
    case alone
    case belonging
    case trust

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overall: "Overall"
        case .hope: "Hope"
        case .anxiety: "Anxiety"
        case .alone: "Alone"
        case .belonging: "Belonging"
        case .trust: "Trust"
        }
    }

    var symbol: String {
        switch self {
        case .overall: "sparkles"
        case .hope: FeelingSignal.hope.symbol
        case .anxiety: FeelingSignal.anxiety.symbol
        case .alone: FeelingSignal.loneliness.symbol
        case .belonging: FeelingSignal.belonging.symbol
        case .trust: FeelingSignal.trust.symbol
        }
    }

    var tint: Color {
        switch self {
        case .overall: FeltTheme.cyan
        case .hope: FeelingSignal.hope.tint
        case .anxiety: FeelingSignal.anxiety.tint
        case .alone: FeelingSignal.loneliness.tint
        case .belonging: FeelingSignal.belonging.tint
        case .trust: FeelingSignal.trust.tint
        }
    }

    var readsAsPressure: Bool {
        self == .anxiety || self == .alone
    }

    func value(in region: MoodRegion) -> Int {
        switch self {
        case .overall:
            region.overallScore
        case .hope:
            region.rawValue(for: .hope)
        case .anxiety:
            region.rawValue(for: .anxiety)
        case .alone:
            region.rawValue(for: .loneliness)
        case .belonging:
            region.rawValue(for: .belonging)
        case .trust:
            region.rawValue(for: .trust)
        }
    }

    func accessibilityLabel(for value: Int) -> String {
        switch self {
        case .overall:
            "overall mood \(value) out of 100"
        case .anxiety:
            "anxiety \(value) out of 100"
        case .alone:
            "feeling alone \(value) out of 100"
        default:
            "\(title) \(value) out of 100"
        }
    }
}

struct MoodRegion: Identifiable {
    let id: String
    let name: String
    let abbreviation: String
    let x: Double
    let y: Double
    let participants: Int
    let scores: [FeelingSignal: Int]
    let movement: Double
    let headline: String

    func rawValue(for signal: FeelingSignal) -> Int {
        scores[signal, default: 50]
    }

    var overallScore: Int {
        let total = FeelingSignal.allCases.reduce(0) { partial, signal in
            partial + signal.healthScore(from: rawValue(for: signal))
        }
        return total / FeelingSignal.allCases.count
    }
}

enum FeltSpace: String, CaseIterable, Identifiable {
    case map
    case market
    case pattern
    case commons
    case ritual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .map: "Map"
        case .market: "Today"
        case .ritual: "Weekly"
        case .pattern: "You"
        case .commons: "People"
        }
    }

    var symbol: String {
        switch self {
        case .map: "map"
        case .market: "sparkle"
        case .ritual: "calendar"
        case .pattern: "person.crop.circle"
        case .commons: "person.2.wave.2"
        }
    }
}

enum PulseCadence: String, CaseIterable, Codable, Identifiable {
    case morning
    case midday
    case evening
    case live

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: "Morning"
        case .midday: "Midday"
        case .evening: "Evening"
        case .live: "Right now"
        }
    }

    var shortTitle: String {
        switch self {
        case .morning: "Open"
        case .midday: "Midday"
        case .evening: "Close"
        case .live: "Live"
        }
    }

    var symbol: String {
        switch self {
        case .morning: "sunrise"
        case .midday: "sun.max"
        case .evening: "moon.haze"
        case .live: "dot.radiowaves.left.and.right"
        }
    }

    var prompt: String {
        switch self {
        case .morning:
            "What feeling is strongest as the day begins?"
        case .midday:
            "What feeling is strongest right now?"
        case .evening:
            "What feeling did the day leave you with?"
        case .live:
            "What are you feeling in this moment?"
        }
    }

    var detail: String {
        switch self {
        case .morning:
            "A private tap that helps you notice the shape of the day."
        case .midday:
            "A quick reset, especially when the day changes."
        case .evening:
            "A gentle note for later, not a scorecard."
        case .live:
            "One anonymous moment. No post, no profile."
        }
    }

    static func current(for date: Date = Date()) -> PulseCadence {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<11: return .morning
        case 11..<17: return .midday
        default: return .evening
        }
    }
}

struct SoulCompassEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let createdAt: Date
    let text: String
    var response: SoulCompassResponse

    init(id: UUID = UUID(), createdAt: Date = Date(), text: String, response: SoulCompassResponse = .unrated) {
        self.id = id
        self.createdAt = createdAt
        self.text = text
        self.response = response
    }
}

enum SoulCompassResponse: String, Codable {
    case unrated
    case helpful
    case notHelpful
}

struct Milestone: Identifiable {
    let weeks: Int
    let title: String
    let detail: String

    var id: Int { weeks }
}

enum MilestoneLibrary {
    static let all: [Milestone] = [
        .init(weeks: 4, title: "Baseline formed", detail: "Four check-ins gives the app enough signal to notice a real pattern."),
        .init(weeks: 12, title: "Season tracked", detail: "Twelve weeks turns scattered feelings into a season you can review."),
        .init(weeks: 52, title: "Year archive", detail: "A full year becomes a private emotional almanac.")
    ]

    static func next(after streak: Int) -> Milestone? {
        all.first { $0.weeks > streak }
    }

    static func achieved(for streak: Int) -> [Milestone] {
        all.filter { $0.weeks <= streak }
    }
}

@Model
final class CheckInRecord {
    var id: UUID
    var weekStart: Date
    var submittedAt: Date
    var reflection: String
    var loneliness: Int
    var trust: Int
    var belonging: Int
    var stability: Int
    var anxiety: Int
    var heard: Int
    var hope: Int

    init(
        id: UUID = UUID(),
        weekStart: Date,
        submittedAt: Date = Date(),
        reflection: String = "",
        signals: [FeelingSignal: Int]
    ) {
        self.id = id
        self.weekStart = weekStart
        self.submittedAt = submittedAt
        self.reflection = reflection
        loneliness = signals[.loneliness, default: 50]
        trust = signals[.trust, default: 50]
        belonging = signals[.belonging, default: 50]
        stability = signals[.stability, default: 50]
        anxiety = signals[.anxiety, default: 50]
        heard = signals[.heard, default: 50]
        hope = signals[.hope, default: 50]
    }

    func value(for signal: FeelingSignal) -> Int {
        switch signal {
        case .loneliness: loneliness
        case .trust: trust
        case .belonging: belonging
        case .stability: stability
        case .anxiety: anxiety
        case .heard: heard
        case .hope: hope
        }
    }

    func healthScore(for signal: FeelingSignal) -> Int {
        signal.healthScore(from: value(for: signal))
    }

    var compositeScore: Int {
        let total = FeelingSignal.allCases.reduce(0) { partial, signal in
            partial + healthScore(for: signal)
        }
        return total / FeelingSignal.allCases.count
    }

    var posture: EmotionalPosture {
        EmotionalPosture.classify(signals: Dictionary(uniqueKeysWithValues: FeelingSignal.allCases.map { signal in
            (signal, value(for: signal))
        }))
    }
}

@Model
final class PulseRecord {
    var id: UUID
    var dayStart: Date
    var submittedAt: Date
    var cadenceRaw: String
    var signalRaw: String
    var value: Int
    var tag: String
    var note: String

    init(
        id: UUID = UUID(),
        dayStart: Date,
        submittedAt: Date = Date(),
        cadence: PulseCadence,
        signal: FeelingSignal,
        value: Int,
        tag: String = "",
        note: String = ""
    ) {
        self.id = id
        self.dayStart = dayStart
        self.submittedAt = submittedAt
        cadenceRaw = cadence.rawValue
        signalRaw = signal.rawValue
        self.value = Swift.min(Swift.max(value, 0), 100)
        self.tag = tag
        self.note = note
    }

    var cadence: PulseCadence {
        PulseCadence(rawValue: cadenceRaw) ?? .live
    }

    var signal: FeelingSignal {
        FeelingSignal(rawValue: signalRaw) ?? .hope
    }

    var healthScore: Int {
        signal.healthScore(from: value)
    }
}

extension Calendar {
    static var feltWeek: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }

    func startOfFeltWeek(containing date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components).map { startOfDay(for: $0) } ?? startOfDay(for: date)
    }

    func startOfFeltDay(containing date: Date) -> Date {
        startOfDay(for: date)
    }

    func isSameFeltWeek(_ lhs: Date, _ rhs: Date) -> Bool {
        isDate(startOfFeltWeek(containing: lhs), inSameDayAs: startOfFeltWeek(containing: rhs))
    }
}

extension Array where Element == CheckInRecord {
    var newestFirst: [CheckInRecord] {
        sorted { $0.weekStart > $1.weekStart }
    }

    var oldestFirst: [CheckInRecord] {
        sorted { $0.weekStart < $1.weekStart }
    }

    func currentStreak() -> Int {
        let sortedRecords = newestFirst
        guard let newest = sortedRecords.first else { return 0 }

        let calendar = Calendar.feltWeek
        var expectedWeek = calendar.startOfFeltWeek(containing: newest.weekStart)
        var streak = 0

        for record in sortedRecords {
            let recordWeek = calendar.startOfFeltWeek(containing: record.weekStart)
            if calendar.isDate(recordWeek, inSameDayAs: expectedWeek) {
                streak += 1
                expectedWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: expectedWeek) ?? expectedWeek
            } else if recordWeek < expectedWeek {
                break
            }
        }

        return streak
    }

    func recordForCurrentWeek() -> CheckInRecord? {
        let currentWeek = Calendar.feltWeek.startOfFeltWeek(containing: Date())
        return first { Calendar.feltWeek.isDate($0.weekStart, inSameDayAs: currentWeek) }
    }

    func compositeChange(weeksBack: Int = 3) -> Int? {
        let sortedRecords = newestFirst
        guard let latest = sortedRecords.first else { return nil }
        let comparisonIndex = Swift.min(weeksBack, sortedRecords.count - 1)
        guard comparisonIndex > 0 else { return nil }
        return latest.compositeScore - sortedRecords[comparisonIndex].compositeScore
    }

    func strongestDelta(weeksBack: Int = 3) -> (signal: FeelingSignal, delta: Int)? {
        let sortedRecords = newestFirst
        guard let latest = sortedRecords.first else { return nil }
        let comparisonIndex = Swift.min(weeksBack, sortedRecords.count - 1)
        guard comparisonIndex > 0 else { return nil }
        let prior = sortedRecords[comparisonIndex]
        return FeelingSignal.allCases
            .map { signal in (signal, latest.healthScore(for: signal) - prior.healthScore(for: signal)) }
            .max { abs($0.1) < abs($1.1) }
    }
}

extension Array where Element == PulseRecord {
    var newestFirst: [PulseRecord] {
        sorted { $0.submittedAt > $1.submittedAt }
    }

    var oldestFirst: [PulseRecord] {
        sorted { $0.submittedAt < $1.submittedAt }
    }

    func forDay(_ date: Date = Date()) -> [PulseRecord] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfFeltDay(containing: date)
        return filter { calendar.isDate($0.dayStart, inSameDayAs: dayStart) }
    }

    func submittedToday(cadence: PulseCadence, date: Date = Date()) -> Bool {
        forDay(date).contains { $0.cadence == cadence }
    }

    func averageHealth(forDay date: Date = Date()) -> Int? {
        let todaysPulses = forDay(date)
        guard !todaysPulses.isEmpty else { return nil }
        let total = todaysPulses.reduce(0) { $0 + $1.healthScore }
        return total / todaysPulses.count
    }

    func averageHealth(for signal: FeelingSignal, date: Date = Date()) -> Int? {
        let matches = forDay(date).filter { $0.signal == signal }
        guard !matches.isEmpty else { return nil }
        let total = matches.reduce(0) { $0 + $1.healthScore }
        return total / matches.count
    }

    func movementToday() -> Int? {
        let todaysPulses = forDay().oldestFirst
        guard let first = todaysPulses.first, let last = todaysPulses.last, todaysPulses.count > 1 else { return nil }
        return last.healthScore - first.healthScore
    }

    func dominantSignalToday() -> FeelingSignal? {
        let grouped = Dictionary(grouping: forDay(), by: \.signal)
        return grouped
            .map { signal, records in
                let average = records.reduce(0) { $0 + $1.healthScore } / records.count
                return (signal, average, records.count)
            }
            .sorted {
                if $0.2 == $1.2 { return $0.1 < $1.1 }
                return $0.2 > $1.2
            }
            .first?
            .0
    }
}

extension Date {
    var nextFeltWeekStart: Date {
        let calendar = Calendar.feltWeek
        let thisWeek = calendar.startOfFeltWeek(containing: self)
        return calendar.date(byAdding: .weekOfYear, value: 1, to: thisWeek) ?? self
    }

    var daysUntilNextFeltWeek: Int {
        let calendar = Calendar.feltWeek
        let start = calendar.startOfDay(for: self)
        let next = calendar.startOfDay(for: nextFeltWeekStart)
        return max(calendar.dateComponents([.day], from: start, to: next).day ?? 0, 0)
    }
}
