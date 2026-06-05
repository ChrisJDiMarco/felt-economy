import Foundation
import SwiftData

struct GlobalSignalAggregate: Identifiable {
    let signal: FeelingSignal
    let current: Double
    let previous: Double
    let trend: [Double]
    let participants: Int
    let confidence: Double

    var id: FeelingSignal { signal }

    var changePercent: Double {
        guard previous != 0 else { return 0 }
        return ((current - previous) / previous) * 100
    }

    var currentHealthScore: Int {
        signal.healthScore(from: Int(current.rounded()))
    }
}

struct MarketIndex: Identifiable {
    let signal: FeelingSignal
    let currentHealth: Double
    let openHealth: Double
    let previousCloseHealth: Double
    let trend: [Double]
    let volume: Int
    let volatility: Double

    var id: FeelingSignal { signal }

    var changeFromOpen: Double {
        currentHealth - openHealth
    }

    var changeFromPreviousClose: Double {
        currentHealth - previousCloseHealth
    }

    var movementLabel: String {
        changeFromOpen >= 0 ? "up from open" : "down from open"
    }
}

struct SocialPulseData {
    static let weeklyParticipants = 48_217
    static let totalResponses = 3_842_109
    static let lastUpdated = "2 min ago"
    static let dailyParticipants = 126_480
    static let livePulseCount = 814_226
    static let marketOpen = "9:00 AM"
    static let marketClose = "9:00 PM"

    static let aggregates: [GlobalSignalAggregate] = [
        .init(signal: .loneliness, current: 41, previous: 45, trend: [53, 49, 50, 47, 46, 44, 45, 43, 45, 41], participants: 47_892, confidence: 0.92),
        .init(signal: .trust, current: 57, previous: 54, trend: [49, 48, 50, 52, 51, 53, 54, 55, 54, 57], participants: 48_061, confidence: 0.94),
        .init(signal: .belonging, current: 62, previous: 60, trend: [55, 56, 58, 59, 58, 60, 59, 61, 60, 62], participants: 47_744, confidence: 0.91),
        .init(signal: .stability, current: 52, previous: 50, trend: [47, 48, 46, 49, 48, 51, 50, 49, 50, 52], participants: 46_988, confidence: 0.88),
        .init(signal: .anxiety, current: 58, previous: 61, trend: [66, 64, 63, 62, 60, 62, 61, 60, 61, 58], participants: 48_103, confidence: 0.93),
        .init(signal: .heard, current: 55, previous: 52, trend: [46, 48, 47, 50, 49, 51, 52, 53, 52, 55], participants: 47_639, confidence: 0.90),
        .init(signal: .hope, current: 64, previous: 61, trend: [56, 57, 59, 58, 60, 62, 61, 63, 61, 64], participants: 48_217, confidence: 0.95)
    ]

    static let moodRegions: [MoodRegion] = [
        .init(id: "SEA", name: "Seattle", abbreviation: "SEA", x: 0.14, y: 0.23, participants: 64_200, scores: [.loneliness: 45, .trust: 59, .belonging: 58, .stability: 52, .anxiety: 57, .heard: 60, .hope: 66], movement: 3.8, headline: "Hope is lifting, but the day still carries a nervous edge."),
        .init(id: "PDX", name: "Portland", abbreviation: "PDX", x: 0.12, y: 0.29, participants: 38_900, scores: [.loneliness: 47, .trust: 57, .belonging: 63, .stability: 50, .anxiety: 54, .heard: 58, .hope: 68], movement: 5.2, headline: "Belonging is unusually strong across the Northwest."),
        .init(id: "SF", name: "San Francisco", abbreviation: "SF", x: 0.11, y: 0.48, participants: 88_400, scores: [.loneliness: 50, .trust: 55, .belonging: 56, .stability: 47, .anxiety: 62, .heard: 57, .hope: 63], movement: -1.4, headline: "Anxiety is elevated, while hope is holding steady."),
        .init(id: "LA", name: "Los Angeles", abbreviation: "LA", x: 0.17, y: 0.64, participants: 142_800, scores: [.loneliness: 48, .trust: 53, .belonging: 61, .stability: 51, .anxiety: 59, .heard: 55, .hope: 67], movement: 2.1, headline: "A mixed day: people feel connected, but not fully settled."),
        .init(id: "PHX", name: "Phoenix", abbreviation: "PHX", x: 0.28, y: 0.63, participants: 52_700, scores: [.loneliness: 42, .trust: 56, .belonging: 59, .stability: 57, .anxiety: 52, .heard: 54, .hope: 65], movement: 3.1, headline: "The Southwest is showing a calmer-than-average mood."),
        .init(id: "SLC", name: "Salt Lake City", abbreviation: "SLC", x: 0.33, y: 0.43, participants: 29_300, scores: [.loneliness: 38, .trust: 61, .belonging: 66, .stability: 60, .anxiety: 49, .heard: 59, .hope: 70], movement: 4.9, headline: "This is one of today's steadier emotional pockets."),
        .init(id: "DEN", name: "Denver", abbreviation: "DEN", x: 0.42, y: 0.47, participants: 61_600, scores: [.loneliness: 40, .trust: 60, .belonging: 64, .stability: 56, .anxiety: 51, .heard: 61, .hope: 69], movement: 4.2, headline: "Hope and belonging are both moving upward."),
        .init(id: "MSP", name: "Minneapolis", abbreviation: "MSP", x: 0.56, y: 0.27, participants: 44_100, scores: [.loneliness: 43, .trust: 58, .belonging: 60, .stability: 54, .anxiety: 56, .heard: 57, .hope: 62], movement: -0.8, headline: "The mood is stable, with anxiety slightly above the national line."),
        .init(id: "KC", name: "Kansas City", abbreviation: "KC", x: 0.53, y: 0.51, participants: 31_500, scores: [.loneliness: 39, .trust: 63, .belonging: 62, .stability: 58, .anxiety: 50, .heard: 60, .hope: 67], movement: 2.7, headline: "Trust is the strongest regional signal today."),
        .init(id: "DAL", name: "Dallas", abbreviation: "DAL", x: 0.51, y: 0.68, participants: 96_300, scores: [.loneliness: 44, .trust: 55, .belonging: 57, .stability: 53, .anxiety: 58, .heard: 52, .hope: 61], movement: -2.2, headline: "People feel functional, but the social signal is a little thin."),
        .init(id: "HOU", name: "Houston", abbreviation: "HOU", x: 0.54, y: 0.77, participants: 82_900, scores: [.loneliness: 46, .trust: 54, .belonging: 58, .stability: 50, .anxiety: 60, .heard: 53, .hope: 62], movement: -1.7, headline: "Anxiety is high, but belonging is keeping the map warm."),
        .init(id: "NOLA", name: "New Orleans", abbreviation: "NOLA", x: 0.61, y: 0.77, participants: 24_700, scores: [.loneliness: 35, .trust: 59, .belonging: 69, .stability: 49, .anxiety: 55, .heard: 62, .hope: 70], movement: 5.6, headline: "Belonging is flashing bright across the Gulf."),
        .init(id: "CHI", name: "Chicago", abbreviation: "CHI", x: 0.63, y: 0.39, participants: 119_500, scores: [.loneliness: 44, .trust: 56, .belonging: 60, .stability: 52, .anxiety: 57, .heard: 56, .hope: 64], movement: 1.2, headline: "A big mixed mood: not light, not collapsing."),
        .init(id: "DET", name: "Detroit", abbreviation: "DET", x: 0.68, y: 0.36, participants: 42_600, scores: [.loneliness: 41, .trust: 60, .belonging: 63, .stability: 54, .anxiety: 53, .heard: 59, .hope: 68], movement: 3.6, headline: "Trust is rising faster here than the national average."),
        .init(id: "NSH", name: "Nashville", abbreviation: "NSH", x: 0.66, y: 0.57, participants: 39_800, scores: [.loneliness: 40, .trust: 58, .belonging: 65, .stability: 55, .anxiety: 54, .heard: 57, .hope: 66], movement: 3.3, headline: "Belonging is doing most of the lifting today."),
        .init(id: "ATL", name: "Atlanta", abbreviation: "ATL", x: 0.70, y: 0.66, participants: 91_200, scores: [.loneliness: 43, .trust: 57, .belonging: 62, .stability: 52, .anxiety: 56, .heard: 58, .hope: 65], movement: 1.9, headline: "The Southeast is warm, social, and a little overloaded."),
        .init(id: "RDU", name: "Raleigh", abbreviation: "RDU", x: 0.76, y: 0.56, participants: 35_600, scores: [.loneliness: 37, .trust: 62, .belonging: 64, .stability: 57, .anxiety: 50, .heard: 61, .hope: 71], movement: 6.1, headline: "One of today's clearest hope fronts is forming here."),
        .init(id: "MIA", name: "Miami", abbreviation: "MIA", x: 0.79, y: 0.84, participants: 76_500, scores: [.loneliness: 49, .trust: 52, .belonging: 59, .stability: 47, .anxiety: 63, .heard: 53, .hope: 60], movement: -3.4, headline: "The mood is vivid but volatile, with anxiety leading."),
        .init(id: "DC", name: "Washington, DC", abbreviation: "DC", x: 0.80, y: 0.48, participants: 73_400, scores: [.loneliness: 48, .trust: 50, .belonging: 55, .stability: 45, .anxiety: 67, .heard: 51, .hope: 58], movement: -4.6, headline: "Anxiety is the loudest signal in the capital region."),
        .init(id: "PHL", name: "Philadelphia", abbreviation: "PHL", x: 0.83, y: 0.42, participants: 58_600, scores: [.loneliness: 42, .trust: 56, .belonging: 61, .stability: 50, .anxiety: 57, .heard: 58, .hope: 64], movement: 2.5, headline: "A gritty, steady mood with belonging slightly ahead."),
        .init(id: "NYC", name: "New York City", abbreviation: "NYC", x: 0.86, y: 0.36, participants: 188_900, scores: [.loneliness: 52, .trust: 51, .belonging: 58, .stability: 46, .anxiety: 66, .heard: 55, .hope: 62], movement: -2.9, headline: "Big-city intensity: anxious, alive, and still hopeful."),
        .init(id: "BOS", name: "Boston", abbreviation: "BOS", x: 0.91, y: 0.30, participants: 49_300, scores: [.loneliness: 43, .trust: 59, .belonging: 60, .stability: 53, .anxiety: 55, .heard: 57, .hope: 66], movement: 2.8, headline: "A balanced Northeast pocket with hope edging up.")
    ]

    static func aggregate(for signal: FeelingSignal) -> GlobalSignalAggregate? {
        aggregates.first { $0.signal == signal }
    }

    static func nationalScore(for layer: EmotionLayer) -> Int {
        guard !moodRegions.isEmpty else { return 0 }
        let total = moodRegions.reduce(0) { $0 + layer.value(in: $1) }
        return total / moodRegions.count
    }

    static func topRegions(for layer: EmotionLayer, limit: Int = 3) -> [MoodRegion] {
        Array(moodRegions.sorted { lhs, rhs in
            layer.value(in: lhs) > layer.value(in: rhs)
        }.prefix(limit))
    }

    static func movingRegions(limit: Int = 3) -> [MoodRegion] {
        Array(moodRegions.sorted { abs($0.movement) > abs($1.movement) }.prefix(limit))
    }

    static func closestRegion(for signal: FeelingSignal, value: Int) -> MoodRegion {
        moodRegions.min { lhs, rhs in
            abs(lhs.rawValue(for: signal) - value) < abs(rhs.rawValue(for: signal) - value)
        } ?? moodRegions[0]
    }

    static func resonanceCount(for signal: FeelingSignal, value: Int) -> Int {
        let weighted = moodRegions.reduce(0.0) { partial, region in
            let distance = abs(Double(region.rawValue(for: signal) - value))
            let closeness = Swift.max(0.10, 1 - distance / 70)
            return partial + Double(region.participants) * closeness * 0.18
        }
        return Swift.max(Int(weighted.rounded()), 1_400)
    }

    static func mapNudge(for signal: FeelingSignal, value: Int) -> Double {
        guard let aggregate = aggregate(for: signal) else { return 0.02 }
        let signedDistance = Double(signal.healthScore(from: value) - aggregate.currentHealthScore)
        return Swift.min(Swift.max(abs(signedDistance) / 600 + 0.01, 0.01), 0.18)
    }

    static var totalMapParticipants: Int {
        moodRegions.reduce(0) { $0 + $1.participants }
    }

    static var liveIndexes: [MarketIndex] {
        let hour = Calendar.current.component(.hour, from: Date())
        let dayProgress = Swift.min(Swift.max(Double(hour - 6) / 16, 0), 1)

        return aggregates.enumerated().map { index, aggregate in
            let priorHealth = Double(aggregate.signal.healthScore(from: Int(aggregate.previous.rounded())))
            let currentHealth = Double(aggregate.currentHealthScore)
            let openHealth = priorHealth + Double(index % 3 - 1) * 1.8
            let drift = (currentHealth - openHealth) * dayProgress
            let pulse = sin(Double(index + 1) * 0.73 + dayProgress * 2.4) * 2.6
            let liveHealth = Swift.min(Swift.max(openHealth + drift + pulse, 0), 100)
            let trend = aggregate.trend.enumerated().map { offset, value in
                let health = Double(aggregate.signal.healthScore(from: Int(value.rounded())))
                return Swift.min(Swift.max(health + sin(Double(offset + index)) * 1.6, 0), 100)
            }

            return MarketIndex(
                signal: aggregate.signal,
                currentHealth: liveHealth,
                openHealth: openHealth,
                previousCloseHealth: priorHealth,
                trend: trend + [liveHealth],
                volume: aggregate.participants * (3 + index % 4),
                volatility: abs(pulse) + Double(index % 4) * 0.8 + (aggregate.signal == .anxiety ? 2.1 : 0.4)
            )
        }
        .sorted { abs($0.changeFromOpen) > abs($1.changeFromOpen) }
    }

    static func marketIndex(for signal: FeelingSignal) -> MarketIndex? {
        liveIndexes.first { $0.signal == signal }
    }
}

enum DemoData {
    static func seedIfNeeded(records: [CheckInRecord], pulses: [PulseRecord], context: ModelContext) {
        if records.isEmpty {
            seedWeeklyRecords(context: context)
        }

        if pulses.isEmpty {
            seedDailyPulses(context: context)
        }
    }

    private static func seedWeeklyRecords(context: ModelContext) {
        let calendar = Calendar.feltWeek
        let reflections = [
            "Felt a little outside the room this week, but walking helped clear some static.",
            "More conversations landed than I expected. Trust felt possible in small doses.",
            "I kept saying yes to things I did not have capacity for.",
            "The week was busy, but I noticed more people checking in sincerely.",
            "Hope came from ordinary proof: meals, texts, and a good stretch of focus.",
            "I felt steadier. Not solved, just less alone inside the week."
        ]

        let signalSets: [[FeelingSignal: Int]] = [
            [.loneliness: 62, .trust: 44, .belonging: 47, .stability: 42, .anxiety: 68, .heard: 40, .hope: 49],
            [.loneliness: 58, .trust: 48, .belonging: 51, .stability: 45, .anxiety: 64, .heard: 45, .hope: 52],
            [.loneliness: 55, .trust: 51, .belonging: 54, .stability: 48, .anxiety: 61, .heard: 48, .hope: 57],
            [.loneliness: 49, .trust: 55, .belonging: 59, .stability: 50, .anxiety: 57, .heard: 52, .hope: 61],
            [.loneliness: 44, .trust: 58, .belonging: 63, .stability: 54, .anxiety: 53, .heard: 58, .hope: 66],
            [.loneliness: 38, .trust: 63, .belonging: 68, .stability: 59, .anxiety: 48, .heard: 63, .hope: 71]
        ]

        for index in signalSets.indices {
            let weeksBack = signalSets.count - index
            let baseDate = calendar.date(byAdding: .weekOfYear, value: -weeksBack, to: Date()) ?? Date()
            let weekStart = calendar.startOfFeltWeek(containing: baseDate)
            let submittedAt = calendar.date(byAdding: .day, value: 2, to: weekStart) ?? weekStart
            let record = CheckInRecord(
                weekStart: weekStart,
                submittedAt: submittedAt,
                reflection: reflections[index],
                signals: signalSets[index]
            )
            context.insert(record)
        }
    }

    private static func seedDailyPulses(context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfFeltDay(containing: Date())
        let historical: [(daysBack: Int, cadence: PulseCadence, signal: FeelingSignal, value: Int, tag: String)] = [
            (6, .morning, .hope, 57, "outside"),
            (6, .evening, .belonging, 64, "friends"),
            (5, .morning, .anxiety, 61, "work"),
            (5, .midday, .heard, 48, "meeting"),
            (5, .evening, .trust, 54, "family"),
            (4, .morning, .loneliness, 46, "quiet"),
            (4, .live, .hope, 68, "walk"),
            (3, .midday, .stability, 58, "money"),
            (3, .evening, .belonging, 66, "dinner"),
            (2, .morning, .trust, 60, "team"),
            (2, .live, .anxiety, 55, "news"),
            (1, .evening, .hope, 70, "rest")
        ]

        for item in historical {
            let day = calendar.date(byAdding: .day, value: -item.daysBack, to: today) ?? today
            let submittedAt = stamped(day: day, cadence: item.cadence)
            context.insert(PulseRecord(
                dayStart: day,
                submittedAt: submittedAt,
                cadence: item.cadence,
                signal: item.signal,
                value: item.value,
                tag: item.tag
            ))
        }

        if PulseCadence.current() != .morning {
            context.insert(PulseRecord(
                dayStart: today,
                submittedAt: stamped(day: today, cadence: .morning),
                cadence: .morning,
                signal: .hope,
                value: 62,
                tag: "start"
            ))
        }

        context.insert(PulseRecord(
            dayStart: today,
            submittedAt: Date().addingTimeInterval(-1_800),
            cadence: .live,
            signal: .belonging,
            value: 58,
            tag: "work"
        ))
    }

    private static func stamped(day: Date, cadence: PulseCadence) -> Date {
        let hour: Int
        switch cadence {
        case .morning: hour = 9
        case .midday: hour = 13
        case .evening: hour = 20
        case .live: hour = 16
        }

        return Calendar.current.date(bySettingHour: hour, minute: 12, second: 0, of: day) ?? day
    }
}
