import MapKit
import SwiftUI

struct TodayMarketView: View {
    let pulses: [PulseRecord]
    let records: [CheckInRecord]
    let showPulse: () -> Void
    let showWeeklyRitual: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            MarketStatusPanel(pulses: pulses, showPulse: showPulse)
            DailyLoopPanel(pulses: pulses, showPulse: showPulse, showWeeklyRitual: showWeeklyRitual)
            MarketDivergencePanel(pulses: pulses)

            VStack(alignment: .leading, spacing: 10) {
                Text("Today around you")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(FeltTheme.ink.opacity(0.76))
                    .padding(.horizontal, 4)
                ForEach(SocialPulseData.liveIndexes.prefix(4)) { index in
                    MarketIndexCard(index: index)
                }
            }

            MarketGuardrailPanel()
        }
    }
}

struct MarketStatusPanel: View {
    let pulses: [PulseRecord]
    let showPulse: () -> Void

    private var todayAverage: Int? {
        pulses.averageHealth()
    }

    private var leadingIndex: MarketIndex {
        SocialPulseData.liveIndexes.first ?? MarketIndex(
            signal: .hope,
            currentHealth: 62,
            openHealth: 60,
            previousCloseHealth: 58,
            trend: [56, 58, 59, 61, 62],
            volume: 48_000,
            volatility: 2.2
        )
    }

    var body: some View {
        Panel(padding: 20) {
            VStack(alignment: .center, spacing: 18) {
                VStack(spacing: 8) {
                    Text("What are you feeling?")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.72)
                    Text("Tap once. See the shared mood.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)

                MoodOrb(score: todayAverage ?? Int(leadingIndex.currentHealth.rounded()), size: 190)

                CapsuleActionButton(title: "Share one feeling", symbol: "plus", action: showPulse)
            }
        }
    }
}

struct DailyLoopPanel: View {
    let pulses: [PulseRecord]
    let showPulse: () -> Void
    let showWeeklyRitual: () -> Void

    private let dailyCadences: [PulseCadence] = [.morning, .midday, .evening]

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Tiny rhythm", systemImage: "clock.arrow.circlepath")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Spacer()
                    Text("10 sec")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    ForEach(dailyCadences) { cadence in
                        let completed = pulses.submittedToday(cadence: cadence)
                        VStack(alignment: .leading, spacing: 6) {
                            Image(systemName: completed ? "checkmark.seal.fill" : cadence.symbol)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(completed ? Color(red: 0.13, green: 0.50, blue: 0.30) : .secondary)
                            Text(cadence.shortTitle)
                                .font(.caption.weight(.bold))
                            Text(completed ? "done" : "ready")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(11)
                        .background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }

                Text("A tiny return loop without turning your mood into a feed.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Button(action: showPulse) {
                        Label("Check in", systemImage: PulseCadence.current().symbol)
                            .bottomBarButtonStyle()
                    }
                    .buttonStyle(.plain)

                    Button(action: showWeeklyRitual) {
                        Label("Weekly reset", systemImage: "calendar")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .foregroundStyle(.primary)
                            .background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct MarketDivergencePanel: View {
    let pulses: [PulseRecord]

    private var comparisons: [(signal: FeelingSignal, delta: Int)] {
        FeelingSignal.allCases.compactMap { signal in
            guard let personal = pulses.averageHealth(for: signal),
                  let market = SocialPulseData.marketIndex(for: signal)
            else { return nil }
            return (signal, personal - Int(market.currentHealth.rounded()))
        }
        .sorted { abs($0.delta) > abs($1.delta) }
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("Your mirror", systemImage: "arrow.left.arrow.right")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                if comparisons.isEmpty {
                    Text("After one check-in, this shows where your day matches the crowd and where it feels different.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(comparisons.prefix(3), id: \.signal) { item in
                        HStack(spacing: 12) {
                            SignalGlyph(signal: item.signal)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.signal.marketTitle)
                                    .font(.headline)
                                Text(item.delta >= 0 ? "You feel \(item.delta) points steadier than people today" : "You feel \(abs(item.delta)) points more tender than people today")
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
}

struct ClosingBellPanel: View {
    let pulses: [PulseRecord]
    let records: [CheckInRecord]

    private var summary: String {
        if let movement = pulses.movementToday(), let signal = pulses.dominantSignalToday() {
            let direction = movement >= 0 ? "steadier" : "more tender"
            return "Your day feels \(direction) than it started, mostly around \(signal.compactTitle.lowercased()). Treat it as a clue, not a verdict."
        }

        if let latest = records.first {
            let strongest = FeelingSignal.allCases.max { latest.healthScore(for: $0) < latest.healthScore(for: $1) } ?? .hope
            return "Your last weekly reset says \(strongest.compactTitle.lowercased()) has been your strongest signal. A quick tap can show whether that still feels true today."
        }

        return "Share one feeling to start today's mirror."
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("A note for later", systemImage: "sparkle.magnifyingglass")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                Text(summary)
                    .font(.callout)
                    .foregroundStyle(.primary.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    StatPill(title: "today", value: "\(pulses.forDay().count)", symbol: "waveform.path.ecg")
                    StatPill(title: "right now", value: PulseCadence.current().shortTitle, symbol: PulseCadence.current().symbol)
                }
            }
        }
    }
}

struct MarketIndexCard: View {
    let index: MarketIndex

    var body: some View {
        Panel(padding: 13) {
            HStack(spacing: 12) {
                SignalGlyph(signal: index.signal)

                VStack(alignment: .leading, spacing: 3) {
                    Text(index.signal.marketTitle)
                        .font(.headline)
                    Text("\(index.volume.formatted()) people")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 10) {
                    Text("\(Int(index.currentHealth.rounded()))")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .monospacedDigit()
                    Text(index.changeFromOpen >= 0 ? "up" : "soft")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(index.changeFromOpen >= 0 ? Color(red: 0.13, green: 0.50, blue: 0.30) : Color(red: 0.75, green: 0.24, blue: 0.30))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(index.signal.marketTitle), \(Int(index.currentHealth.rounded())) out of 100, \(index.changeFromOpen >= 0 ? "rising" : "softening") today")
    }
}

struct MarketGuardrailPanel: View {
    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 10) {
                Label("Why it feels safe", systemImage: "shield.lefthalf.filled")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("No followers, no comments, no public profile. You give one signal, then see an anonymous mood only when enough people have shared.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct MoodMapSpaceView: View {
    let pulses: [PulseRecord]
    let showPulse: () -> Void

    @State private var selectedLayer: EmotionLayer = .overall
    @State private var selectedRegionID = "NYC"

    private var latestTodayPulse: PulseRecord? {
        pulses.newestFirst.first { Calendar.current.isDate($0.dayStart, inSameDayAs: Date()) }
    }

    var body: some View {
        VStack(spacing: 8) {
            QuietMapInstrument(
                selectedLayer: $selectedLayer,
                selectedRegionID: $selectedRegionID,
                latestPulse: latestTodayPulse,
                showPulse: showPulse
            )
        }
    }
}

struct QuietMapInstrument: View {
    @Binding var selectedLayer: EmotionLayer
    @Binding var selectedRegionID: String
    let latestPulse: PulseRecord?
    let showPulse: () -> Void

    private var nationalScore: Int {
        SocialPulseData.nationalScore(for: selectedLayer)
    }

    var body: some View {
        Panel(padding: 12) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Mood map")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        Text("emotional weather")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary.opacity(0.88))
                    }

                    Spacer()

                    LayerCycleButton(selection: $selectedLayer)

                    VStack(alignment: .trailing, spacing: 0) {
                        Text("\(nationalScore)")
                            .font(.system(size: 31, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text("now")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary.opacity(0.88))
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("National \(selectedLayer.accessibilityLabel(for: nationalScore))")
                }

                USMoodMap(
                    regions: SocialPulseData.moodRegions,
                    layer: selectedLayer,
                    selectedRegionID: $selectedRegionID
                )
                .frame(height: 278)
                .accessibilityLabel("United States mood heat map")

                if let latestPulse {
                    QuietSignalLine(pulse: latestPulse)
                } else {
                    Text("Tap once to join the weather.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary.opacity(0.88))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                }

                CapsuleActionButton(title: "Add feeling", symbol: "plus", action: showPulse)
            }
        }
    }
}

struct LayerCycleButton: View {
    @Binding var selection: EmotionLayer

    private var nextLayer: EmotionLayer {
        let all = EmotionLayer.allCases
        guard let currentIndex = all.firstIndex(of: selection) else { return all[0] }
        return all[(currentIndex + 1) % all.count]
    }

    var body: some View {
        Button {
            withAnimation(.snappy) {
                selection = nextLayer
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: selection.symbol)
                    .font(.caption.weight(.bold))
                Text(selection.title)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
            }
            .foregroundStyle(selection.tint)
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(.white.opacity(0.28))
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .stroke(.white.opacity(0.58), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Change map layer, currently \(selection.title)")
    }
}

struct MinimalLayerDock: View {
    @Binding var selection: EmotionLayer

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EmotionLayer.allCases) { layer in
                    Button {
                        withAnimation(.snappy) {
                            selection = layer
                        }
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: layer.symbol)
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                            if selection == layer {
                                Text(layer.title)
                                    .font(.caption.weight(.bold))
                                    .lineLimit(1)
                            }
                        }
                        .frame(height: 42)
                        .padding(.horizontal, selection == layer ? 13 : 12)
                        .foregroundStyle(selection == layer ? .white : FeltTheme.ink.opacity(0.58))
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(selection == layer ? LinearGradient(colors: [layer.tint, FeltTheme.cyan], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.white.opacity(0.42), Color.white.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(.white.opacity(0.48), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(layer.title)
                    .accessibilityAddTraits(selection == layer ? .isSelected : [])
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        }
    }
}

struct QuietSignalLine: View {
    let pulse: PulseRecord

    private var resonanceCount: Int {
        SocialPulseData.resonanceCount(for: pulse.signal, value: pulse.value)
    }

    private var closestRegion: MoodRegion {
        SocialPulseData.closestRegion(for: pulse.signal, value: pulse.value)
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: pulse.signal.symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(pulse.signal.tint)
                .frame(width: 26, height: 26)
                .background {
                    Circle()
                        .fill(.ultraThinMaterial)
                    Circle()
                        .fill(.white.opacity(0.28))
                    Circle()
                        .stroke(.white.opacity(0.54), lineWidth: 1)
                }

            Text("\(resonanceCount.formatted(.number.notation(.compactName))) in sync · \(closestRegion.abbreviation) glow")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary.opacity(0.84))
                .lineLimit(1)
                .minimumScaleFactor(0.84)

        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your \(pulse.signal.title) signal joined \(resonanceCount) anonymous nearby signals")
    }
}

struct QuietRegionLine: View {
    let region: MoodRegion
    let layer: EmotionLayer

    var body: some View {
        Text("\(region.name) · \(region.headline)")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary.opacity(0.86))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(region.name), \(layer.accessibilityLabel(for: layer.value(in: region)))")
    }
}

struct MapHeroPanel: View {
    let selectedLayer: EmotionLayer
    let showPulse: () -> Void

    private var nationalScore: Int {
        SocialPulseData.nationalScore(for: selectedLayer)
    }

    var body: some View {
        Panel(padding: 20) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("The mood map")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .minimumScaleFactor(0.72)
                        Text("Watch the emotional weather of the US glow and shift as private signals arrive.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    MapScoreBadge(score: nationalScore, layer: selectedLayer)
                }

                HStack(spacing: 8) {
                    StatPill(title: "today", value: SocialPulseData.totalMapParticipants.formatted(.number.notation(.compactName)), symbol: "person.3")
                    StatPill(title: "updated", value: SocialPulseData.lastUpdated, symbol: "dot.radiowaves.left.and.right")
                }

                CapsuleActionButton(title: "Add your feeling", symbol: PulseCadence.current().symbol, action: showPulse)
            }
        }
    }
}

struct FreshSignalPanel: View {
    let pulse: PulseRecord

    private var resonanceCount: Int {
        SocialPulseData.resonanceCount(for: pulse.signal, value: pulse.value)
    }

    private var closestRegion: MoodRegion {
        SocialPulseData.closestRegion(for: pulse.signal, value: pulse.value)
    }

    private var nudge: String {
        String(format: "+%.2f", SocialPulseData.mapNudge(for: pulse.signal, value: pulse.value))
    }

    var body: some View {
        Panel(padding: 14) {
            HStack(alignment: .top, spacing: 12) {
                SignalGlyph(signal: pulse.signal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your signal is in the weather")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Text("\(resonanceCount.formatted()) people are near your \(pulse.signal.compactTitle.lowercased()) signal today. Closest regional glow: \(closestRegion.name).")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 8) {
                        StatPill(title: "closest", value: closestRegion.abbreviation, symbol: "mappin.and.ellipse")
                        StatPill(title: "ripple", value: nudge, symbol: "sparkles")
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your \(pulse.signal.title) signal joined \(resonanceCount) anonymous nearby signals")
    }
}

struct MapScoreBadge: View {
    let score: Int
    let layer: EmotionLayer

    var body: some View {
        VStack(spacing: 4) {
            Text("\(score)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()
            Text(layer.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: 78, height: 78)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.98), layer.tint.opacity(0.26), .white.opacity(0.18)],
                        center: .topLeading,
                        startRadius: 4,
                        endRadius: 78
                    )
                )
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.76), lineWidth: 1)
        }
        .shadow(color: layer.tint.opacity(0.22), radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("National \(layer.accessibilityLabel(for: score))")
    }
}

struct EmotionLayerPicker: View {
    @Binding var selection: EmotionLayer

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EmotionLayer.allCases) { layer in
                    Button {
                        withAnimation(.snappy) {
                            selection = layer
                        }
                    } label: {
                        Label(layer.title, systemImage: layer.symbol)
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .foregroundStyle(selection == layer ? .white : FeltTheme.ink.opacity(0.72))
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(selection == layer ? LinearGradient(colors: [layer.tint, FeltTheme.cyan], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.white.opacity(0.60), Color.white.opacity(0.34)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(.white.opacity(selection == layer ? 0.70 : 0.50), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selection == layer ? .isSelected : [])
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        }
    }
}

struct USMoodMapPanel: View {
    let selectedLayer: EmotionLayer
    @Binding var selectedRegionID: String

    var body: some View {
        Panel(padding: 14) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Live emotional weather", systemImage: "map")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        Text("Tap a bright spot. Heat means more of the selected feeling.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(selectedLayer.readsAsPressure ? "pressure" : "signal")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(selectedLayer.tint)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(selectedLayer.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                USMoodMap(
                    regions: SocialPulseData.moodRegions,
                    layer: selectedLayer,
                    selectedRegionID: $selectedRegionID
                )
                .frame(height: 270)
                .accessibilityLabel("United States mood heat map")
            }
        }
    }
}

struct USMoodMap: View {
    let regions: [MoodRegion]
    let layer: EmotionLayer
    @Binding var selectedRegionID: String

    @State private var cameraPosition: MapCameraPosition = .region(Self.nationalRegion)

    private static let nationalRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.2, longitude: -96.4),
        span: MKCoordinateSpan(latitudeDelta: 25.8, longitudeDelta: 60.0)
    )

    private let mapRadius: CGFloat = 24

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                Map(position: $cameraPosition, interactionModes: [])
                    .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
                    .clipShape(RoundedRectangle(cornerRadius: mapRadius, style: .continuous))
                    .saturation(0.24)
                    .contrast(0.86)
                    .brightness(0.10)
                    .overlay {
                        MapAtmosphereOverlay(color: layer.tint)
                            .clipShape(RoundedRectangle(cornerRadius: mapRadius, style: .continuous))
                    }
                    .accessibilityHidden(true)

                MapGlassSheen()
                    .clipShape(RoundedRectangle(cornerRadius: mapRadius, style: .continuous))
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                ZStack {
                    ForEach(regions) { region in
                        let value = layer.value(in: region)
                        HeatBlob(color: layer.tint, value: value)
                            .frame(width: heatSize(for: value), height: heatSize(for: value))
                            .position(point(for: region.coordinate, in: size))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                ForEach(regions) { region in
                    Button {
                        withAnimation(.snappy) {
                            selectedRegionID = region.id
                        }
                    } label: {
                        RegionPin(
                            region: region,
                            layer: layer,
                            isSelected: selectedRegionID == region.id
                        )
                    }
                    .buttonStyle(.plain)
                    .position(point(for: region.coordinate, in: size))
                    .accessibilityLabel("\(region.name), \(layer.accessibilityLabel(for: layer.value(in: region)))")
                }

                RoundedRectangle(cornerRadius: mapRadius, style: .continuous)
                    .stroke(.white.opacity(0.62), lineWidth: 1)
                    .allowsHitTesting(false)

                RoundedRectangle(cornerRadius: mapRadius, style: .continuous)
                    .stroke(layer.tint.opacity(0.18), lineWidth: 1.2)
                    .blur(radius: 5)
                    .allowsHitTesting(false)
            }
            .background {
                RoundedRectangle(cornerRadius: mapRadius, style: .continuous)
                    .fill(.white.opacity(0.24))
                    .shadow(color: layer.tint.opacity(0.11), radius: 28, x: 0, y: 16)
            }
        }
    }

    private func point(for coordinate: CLLocationCoordinate2D, in size: CGSize) -> CGPoint {
        let west = -126.4
        let east = -66.4
        let north = 51.1
        let south = 24.0
        let x = (coordinate.longitude - west) / (east - west)
        let top = mercatorLatitude(north)
        let bottom = mercatorLatitude(south)
        let y = (top - mercatorLatitude(coordinate.latitude)) / (top - bottom)

        return CGPoint(
            x: size.width * min(max(x, 0.03), 0.97),
            y: size.height * min(max(y, 0.05), 0.95)
        )
    }

    private func mercatorLatitude(_ latitude: Double) -> Double {
        let radians = latitude * .pi / 180
        return log(tan(.pi / 4 + radians / 2))
    }

    private func heatSize(for value: Int) -> CGFloat {
        CGFloat(46 + value)
    }
}

struct MapAtmosphereOverlay: View {
    let color: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    .white.opacity(0.64),
                    color.opacity(0.15),
                    FeltTheme.pearl.opacity(0.52)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [color.opacity(0.23), .clear],
                center: .trailing,
                startRadius: 40,
                endRadius: 360
            )

            MapSweep(color: color)
        }
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct MapGlassSheen: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.white.opacity(0.42), .white.opacity(0.08), .clear],
                startPoint: .topLeading,
                endPoint: .center
            )

            LinearGradient(
                colors: [.clear, .white.opacity(0.16)],
                startPoint: .center,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.24), lineWidth: 8)
                .blur(radius: 12)
                .offset(y: -6)
        }
        .blendMode(.plusLighter)
    }
}

private extension MoodRegion {
    var coordinate: CLLocationCoordinate2D {
        switch id {
        case "SEA":
            CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321)
        case "PDX":
            CLLocationCoordinate2D(latitude: 45.5152, longitude: -122.6784)
        case "SF":
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        case "LA":
            CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        case "PHX":
            CLLocationCoordinate2D(latitude: 33.4484, longitude: -112.0740)
        case "SLC":
            CLLocationCoordinate2D(latitude: 40.7608, longitude: -111.8910)
        case "DEN":
            CLLocationCoordinate2D(latitude: 39.7392, longitude: -104.9903)
        case "MSP":
            CLLocationCoordinate2D(latitude: 44.9778, longitude: -93.2650)
        case "KC":
            CLLocationCoordinate2D(latitude: 39.0997, longitude: -94.5786)
        case "DAL":
            CLLocationCoordinate2D(latitude: 32.7767, longitude: -96.7970)
        case "HOU":
            CLLocationCoordinate2D(latitude: 29.7604, longitude: -95.3698)
        case "NOLA":
            CLLocationCoordinate2D(latitude: 29.9511, longitude: -90.0715)
        case "CHI":
            CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298)
        case "DET":
            CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458)
        case "NSH":
            CLLocationCoordinate2D(latitude: 36.1627, longitude: -86.7816)
        case "ATL":
            CLLocationCoordinate2D(latitude: 33.7490, longitude: -84.3880)
        case "RDU":
            CLLocationCoordinate2D(latitude: 35.7796, longitude: -78.6382)
        case "MIA":
            CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)
        case "DC":
            CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369)
        case "PHL":
            CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652)
        case "NYC":
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        case "BOS":
            CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589)
        default:
            CLLocationCoordinate2D(
                latitude: 49.5 - (y * 25.5),
                longitude: -124.5 + (x * 58.0)
            )
        }
    }
}

struct MapSweep: View {
    let color: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var active = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            LinearGradient(
                colors: [.clear, color.opacity(0.10), .white.opacity(0.18), color.opacity(0.06), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: size.width * 0.34, height: size.height * 1.65)
            .rotationEffect(.degrees(18))
            .offset(x: reduceMotion ? size.width * 0.20 : (active ? size.width * 1.05 : -size.width * 0.72), y: -size.height * 0.22)
            .blendMode(.plusLighter)
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 4.2).repeatForever(autoreverses: false)) {
                active = true
            }
        }
    }
}

struct USOutlineShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let w = rect.width
        let h = rect.height
        let x = rect.minX
        let y = rect.minY

        var path = Path()
        path.move(to: CGPoint(x: x + w * 0.10, y: y + h * 0.48))
        path.addCurve(
            to: CGPoint(x: x + w * 0.18, y: y + h * 0.25),
            control1: CGPoint(x: x + w * 0.09, y: y + h * 0.39),
            control2: CGPoint(x: x + w * 0.12, y: y + h * 0.30)
        )
        path.addLine(to: CGPoint(x: x + w * 0.30, y: y + h * 0.18))
        path.addCurve(
            to: CGPoint(x: x + w * 0.46, y: y + h * 0.25),
            control1: CGPoint(x: x + w * 0.35, y: y + h * 0.17),
            control2: CGPoint(x: x + w * 0.41, y: y + h * 0.22)
        )
        path.addLine(to: CGPoint(x: x + w * 0.55, y: y + h * 0.18))
        path.addCurve(
            to: CGPoint(x: x + w * 0.79, y: y + h * 0.24),
            control1: CGPoint(x: x + w * 0.62, y: y + h * 0.19),
            control2: CGPoint(x: x + w * 0.72, y: y + h * 0.18)
        )
        path.addCurve(
            to: CGPoint(x: x + w * 0.92, y: y + h * 0.34),
            control1: CGPoint(x: x + w * 0.86, y: y + h * 0.25),
            control2: CGPoint(x: x + w * 0.91, y: y + h * 0.27)
        )
        path.addCurve(
            to: CGPoint(x: x + w * 0.83, y: y + h * 0.45),
            control1: CGPoint(x: x + w * 0.90, y: y + h * 0.39),
            control2: CGPoint(x: x + w * 0.86, y: y + h * 0.42)
        )
        path.addCurve(
            to: CGPoint(x: x + w * 0.82, y: y + h * 0.58),
            control1: CGPoint(x: x + w * 0.87, y: y + h * 0.50),
            control2: CGPoint(x: x + w * 0.88, y: y + h * 0.56)
        )
        path.addCurve(
            to: CGPoint(x: x + w * 0.73, y: y + h * 0.83),
            control1: CGPoint(x: x + w * 0.78, y: y + h * 0.68),
            control2: CGPoint(x: x + w * 0.81, y: y + h * 0.78)
        )
        path.addCurve(
            to: CGPoint(x: x + w * 0.64, y: y + h * 0.72),
            control1: CGPoint(x: x + w * 0.69, y: y + h * 0.82),
            control2: CGPoint(x: x + w * 0.66, y: y + h * 0.76)
        )
        path.addLine(to: CGPoint(x: x + w * 0.48, y: y + h * 0.76))
        path.addLine(to: CGPoint(x: x + w * 0.36, y: y + h * 0.69))
        path.addLine(to: CGPoint(x: x + w * 0.23, y: y + h * 0.70))
        path.addCurve(
            to: CGPoint(x: x + w * 0.16, y: y + h * 0.63),
            control1: CGPoint(x: x + w * 0.19, y: y + h * 0.69),
            control2: CGPoint(x: x + w * 0.17, y: y + h * 0.66)
        )
        path.addLine(to: CGPoint(x: x + w * 0.08, y: y + h * 0.57))
        path.addCurve(
            to: CGPoint(x: x + w * 0.10, y: y + h * 0.48),
            control1: CGPoint(x: x + w * 0.06, y: y + h * 0.54),
            control2: CGPoint(x: x + w * 0.07, y: y + h * 0.50)
        )
        path.closeSubpath()

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }
}

struct HeatBlob: View {
    let color: Color
    let value: Int

    private var opacity: Double {
        0.07 + Double(value) / 340
    }

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(opacity),
                        color.opacity(opacity * 0.46),
                        color.opacity(0.04),
                        .clear
                    ],
                    center: .center,
                    startRadius: 2,
                    endRadius: 86
                )
            )
            .blur(radius: 7)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

struct RegionPin: View {
    let region: MoodRegion
    let layer: EmotionLayer
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(isSelected ? layer.tint : .white.opacity(0.36))
                    .frame(width: isSelected ? 19 : 4, height: isSelected ? 19 : 4)
                Circle()
                    .fill(.white.opacity(isSelected ? 0.20 : 0))
                    .frame(width: isSelected ? 29 : 0, height: isSelected ? 29 : 0)
                Circle()
                    .stroke(.white.opacity(isSelected ? 0.88 : 0.28), lineWidth: isSelected ? 1.2 : 0.6)
                    .frame(width: isSelected ? 25 : 8, height: isSelected ? 25 : 8)
            }

            if isSelected {
                Text(region.abbreviation)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(FeltTheme.ink)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.white.opacity(0.70))
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(.white.opacity(0.75), lineWidth: 1)
                    }
            }
        }
        .shadow(color: layer.tint.opacity(isSelected ? 0.32 : 0), radius: isSelected ? 12 : 0, x: 0, y: 5)
    }
}

struct RegionInsightPanel: View {
    let region: MoodRegion
    let layer: EmotionLayer

    private var value: Int {
        layer.value(in: region)
    }

    private var movementText: String {
        region.movement >= 0 ? "+\(String(format: "%.1f", region.movement)) today" : "\(String(format: "%.1f", region.movement)) today"
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center, spacing: 14) {
                    GlassSymbolTile(symbol: layer.symbol, tint: layer.tint, size: 52)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(region.name)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        Text(region.headline)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 4)
                }

                HStack(spacing: 8) {
                    StatPill(title: layer.readsAsPressure ? "pressure" : "signal", value: "\(value)", symbol: layer.symbol)
                    StatPill(title: "movement", value: movementText, symbol: region.movement >= 0 ? "arrow.up.right" : "arrow.down.right")
                    StatPill(title: "people", value: region.participants.formatted(.number.notation(.compactName)), symbol: "person.3")
                }

                Text(layer.readsAsPressure ? "Higher heat means this feeling is heavier there. The goal is awareness, not ranking places as good or bad." : "Higher heat means more people are reporting this feeling there. Treat it like emotional weather, not a scoreboard.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct MapLoopPanel: View {
    let pulses: [PulseRecord]
    let showPulse: () -> Void

    private let cadences: [PulseCadence] = [.morning, .midday, .evening]

    private var completedCount: Int {
        cadences.filter { pulses.submittedToday(cadence: $0) }.count
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    Label("Keep the map alive", systemImage: "repeat")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                    Spacer()
                    Text("\(completedCount)/3")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(FeltTheme.blue)
                }

                HStack(spacing: 8) {
                    ForEach(cadences) { cadence in
                        let completed = pulses.submittedToday(cadence: cadence)
                        VStack(alignment: .leading, spacing: 6) {
                            Image(systemName: completed ? "checkmark.seal.fill" : cadence.symbol)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(completed ? FeltTheme.mint : .secondary)
                            Text(cadence.shortTitle)
                                .font(.caption.weight(.bold))
                            Text(completed ? "shared" : "open")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(11)
                        .background(.white.opacity(0.48), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }

                Text("The sticky loop is simple: morning, middle, evening. Each private tap refreshes the public weather without becoming a feed.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: showPulse) {
                    Label("Share right now", systemImage: PulseCadence.current().symbol)
                        .bottomBarButtonStyle()
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct MoodFrontsPanel: View {
    let layer: EmotionLayer

    private var movers: [MoodRegion] {
        SocialPulseData.movingRegions(limit: 3)
    }

    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 14) {
                Label("Mood fronts", systemImage: "wind")
                    .font(.system(.title3, design: .rounded, weight: .bold))

                ForEach(movers) { region in
                    MoodFrontRow(region: region, layer: layer)
                }
            }
        }
    }
}

struct MoodFrontRow: View {
    let region: MoodRegion
    let layer: EmotionLayer

    private var direction: String {
        region.movement >= 0 ? "warming" : "cooling"
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(layer.tint.opacity(0.16))
                    .frame(width: 42, height: 42)
                Image(systemName: region.movement >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(layer.tint)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("\(region.name) is \(direction)")
                    .font(.headline)
                Text("\(layer.title) reads \(layer.value(in: region)) with \(String(format: "%+.1f", region.movement)) movement.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct MapPrivacyPanel: View {
    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 10) {
                Label("No exact pins", systemImage: "location.slash")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("The map only shows large anonymous buckets. No profiles, comments, usernames, exact location, or small-group results.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
