import Charts
import SwiftUI

enum FeltTheme {
    static let ink = Color(red: 0.09, green: 0.10, blue: 0.13)
    static let graphite = Color(red: 0.17, green: 0.19, blue: 0.23)
    static let pearl = Color(red: 0.97, green: 0.99, blue: 0.98)
    static let blue = Color(red: 0.13, green: 0.49, blue: 0.92)
    static let cyan = Color(red: 0.12, green: 0.72, blue: 0.82)
    static let mint = Color(red: 0.28, green: 0.74, blue: 0.58)
    static let coral = Color(red: 0.94, green: 0.39, blue: 0.45)
    static let amber = Color(red: 0.95, green: 0.70, blue: 0.28)
    static let violet = Color(red: 0.52, green: 0.48, blue: 0.86)
    static let panelRadius: CGFloat = 28
    static let controlRadius: CGFloat = 22

    static let actionGradient = LinearGradient(
        colors: [blue, cyan, mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmGradient = LinearGradient(
        colors: [coral, amber, mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glassStroke = LinearGradient(
        colors: [
            .white.opacity(0.74),
            cyan.opacity(0.28),
            violet.opacity(0.14),
            .white.opacity(0.30)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            FeltTheme.pearl
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 1.00, blue: 0.99),
                    Color(red: 0.93, green: 0.99, blue: 1.00),
                    Color(red: 1.00, green: 0.985, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(colors: [FeltTheme.cyan.opacity(0.20), .clear], center: .topTrailing, startRadius: 30, endRadius: 520)
            RadialGradient(colors: [FeltTheme.violet.opacity(0.08), .clear], center: .center, startRadius: 70, endRadius: 620)
            RadialGradient(colors: [FeltTheme.amber.opacity(0.10), .clear], center: .bottomLeading, startRadius: 60, endRadius: 600)
            CalmLightField()
        }
        .ignoresSafeArea()
    }
}

struct CalmLightField: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        Canvas { context, size in
            guard !reduceTransparency else { return }

            let lines: [(Color, CGFloat, CGFloat)] = [
                (FeltTheme.cyan, 0.08, 0.30),
                (FeltTheme.mint, 0.06, 0.58)
            ]

            for (color, opacity, yRatio) in lines {
                var path = Path()
                let y = size.height * yRatio
                path.move(to: CGPoint(x: -80, y: y))
                path.addCurve(
                    to: CGPoint(x: size.width + 80, y: y + 90),
                    control1: CGPoint(x: size.width * 0.28, y: y - 86),
                    control2: CGPoint(x: size.width * 0.62, y: y + 150)
                )
                context.stroke(path, with: .color(color.opacity(opacity)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            }

            for index in 0..<3 {
                let rect = CGRect(
                    x: size.width * 0.08 - CGFloat(index) * 38,
                    y: size.height * 0.18 + CGFloat(index) * 42,
                    width: size.width * 1.02 + CGFloat(index) * 74,
                    height: size.width * 1.02 + CGFloat(index) * 74
                )
                context.stroke(
                    Path(ellipseIn: rect),
                    with: .color(.white.opacity(0.08 - CGFloat(index) * 0.015)),
                    lineWidth: 1
                )
            }
        }
        .blendMode(.plusLighter)
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

struct Panel<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    var padding: CGFloat = 16
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: FeltTheme.panelRadius, style: .continuous)
                    .fill(Color.white.opacity(reduceTransparency ? 0.97 : 0.22))
                if !reduceTransparency {
                    RoundedRectangle(cornerRadius: FeltTheme.panelRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
                RoundedRectangle(cornerRadius: FeltTheme.panelRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.48), FeltTheme.cyan.opacity(0.06), FeltTheme.violet.opacity(0.04), .white.opacity(0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: FeltTheme.panelRadius, style: .continuous)
                    .stroke(.white.opacity(0.34), lineWidth: 8)
                    .blur(radius: 14)
                    .offset(y: -4)
                    .mask {
                        RoundedRectangle(cornerRadius: FeltTheme.panelRadius, style: .continuous)
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: FeltTheme.panelRadius, style: .continuous)
                    .stroke(FeltTheme.glassStroke, lineWidth: 1)
            }
            .shadow(color: FeltTheme.blue.opacity(0.06), radius: 24, x: 0, y: 16)
            .shadow(color: .white.opacity(0.70), radius: 8, x: -3, y: -4)
    }
}

struct SpacePicker: View {
    @Binding var selection: FeltSpace

    var body: some View {
        HStack(spacing: 6) {
            ForEach(FeltSpace.allCases) { mode in
                Button {
                    withAnimation(.snappy) {
                        selection = mode
                    }
                } label: {
                    Image(systemName: mode.symbol)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .frame(width: 50, height: 46)
                        .foregroundStyle(selection == mode ? .white : FeltTheme.ink.opacity(0.46))
                        .background {
                            if selection == mode {
                                RoundedRectangle(cornerRadius: FeltTheme.controlRadius, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                FeltTheme.blue.opacity(0.92),
                                                FeltTheme.cyan.opacity(0.84),
                                                FeltTheme.mint.opacity(0.78)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: FeltTheme.controlRadius, style: .continuous)
                                            .stroke(.white.opacity(0.60), lineWidth: 1)
                                    }
                                    .shadow(color: FeltTheme.cyan.opacity(0.18), radius: 12, x: 0, y: 7)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mode.title)
                .accessibilityAddTraits(selection == mode ? .isSelected : [])
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white.opacity(0.30))
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.58), lineWidth: 1)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: FeltTheme.ink.opacity(0.07), radius: 22, x: 0, y: 12)
    }
}

struct CapsuleActionButton: View {
    let title: String
    let symbol: String
    var tint: Color = FeltTheme.blue
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.system(.callout, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .foregroundStyle(isEnabled ? .white : .secondary)
                .background {
                    RoundedRectangle(cornerRadius: FeltTheme.controlRadius, style: .continuous)
                        .fill(isEnabled ? LinearGradient(colors: [FeltTheme.blue.opacity(0.92), FeltTheme.cyan.opacity(0.82), FeltTheme.mint.opacity(0.74)], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.gray.opacity(0.20), Color.gray.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    RoundedRectangle(cornerRadius: FeltTheme.controlRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(isEnabled ? 0.22 : 0.06), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    RoundedRectangle(cornerRadius: FeltTheme.controlRadius, style: .continuous)
                        .stroke(.white.opacity(0.58), lineWidth: 1)
                }
                .shadow(color: tint.opacity(isEnabled ? 0.18 : 0), radius: 16, x: 0, y: 9)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

struct MoodOrb: View {
    let score: Int
    var size: CGFloat = 220

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.95),
                            FeltTheme.cyan.opacity(0.24),
                            FeltTheme.violet.opacity(0.12),
                            .white.opacity(0.06)
                        ],
                        center: .topLeading,
                        startRadius: 8,
                        endRadius: size * 0.62
                    )
                )
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.74), lineWidth: 1)
                }
                .shadow(color: FeltTheme.cyan.opacity(0.24), radius: 36, x: 0, y: 20)

            Circle()
                .trim(from: 0.08, to: 0.08 + CGFloat(score) / 120)
                .stroke(
                    AngularGradient(
                        colors: [FeltTheme.blue, FeltTheme.cyan, FeltTheme.mint, FeltTheme.amber, FeltTheme.blue],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(size * 0.08)

            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: size * 0.24, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("shared mood")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Shared mood \(score) out of 100")
    }
}

struct ScoreRing: View {
    let score: Int
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.60), lineWidth: 1)
                }
            Circle()
                .stroke(FeltTheme.blue.opacity(0.08), lineWidth: 9)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    AngularGradient(
                        colors: [
                            FeltTheme.blue,
                            FeltTheme.cyan,
                            FeltTheme.mint,
                            FeltTheme.amber,
                            FeltTheme.coral,
                            FeltTheme.blue
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("mood")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .shadow(color: FeltTheme.cyan.opacity(0.26), radius: 18, x: 0, y: 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Mood \(score) out of 100")
    }
}

struct MiniTrendChart: View {
    let values: [Double]
    let color: Color

    var body: some View {
        Chart(Array(values.enumerated()), id: \.offset) { item in
            AreaMark(
                x: .value("Week", item.offset),
                yStart: .value("Minimum", 0),
                yEnd: .value("Score", item.element)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [color.opacity(0.22), color.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Week", item.offset),
                y: .value("Score", item.element)
            )
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: 0...100)
        .frame(height: 58)
        .accessibilityHidden(true)
    }
}

struct SignalGlyph: View {
    let signal: FeelingSignal

    var body: some View {
        Image(systemName: signal.symbol)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 34, height: 34)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(LinearGradient(colors: [signal.tint.opacity(0.92), FeltTheme.cyan.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.white.opacity(0.58), lineWidth: 1)
            }
            .shadow(color: signal.tint.opacity(0.26), radius: 10, x: 0, y: 5)
    }
}

struct StatPill: View {
    let title: String
    let value: String
    var symbol: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(FeltTheme.blue.opacity(0.72))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.white.opacity(0.40))
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.68), lineWidth: 1)
        }
    }
}

struct SignalStatusBadge: View {
    let status: SignalStatus

    var body: some View {
        Text(status.label)
            .font(.caption.weight(.bold))
            .foregroundStyle(status.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(status.color.opacity(0.12))
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(status.color.opacity(0.18), lineWidth: 1)
            }
    }
}

struct ProgressDots: View {
    let count: Int
    let activeIndex: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index <= activeIndex ? FeltTheme.actionGradient : LinearGradient(colors: [FeltTheme.blue.opacity(0.16), FeltTheme.cyan.opacity(0.12)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: index == activeIndex ? 22 : 8, height: 8)
            }
        }
        .accessibilityLabel("Step \(activeIndex + 1) of \(count)")
    }
}

struct InlineInfoButton: View {
    let title: String
    let message: String
    @State private var showingInfo = false

    var body: some View {
        Button {
            showingInfo = true
        } label: {
            Image(systemName: "info.circle")
                .font(.headline)
                .frame(width: 34, height: 34)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .accessibilityLabel("About \(title)")
        .alert(title, isPresented: $showingInfo) {
            Button("Done", role: .cancel) {}
        } message: {
            Text(message)
        }
    }
}

extension View {
    func bottomBarButtonStyle(enabled: Bool = true) -> some View {
        self
                .font(.system(.headline, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundStyle(.white)
            .background(enabled ? FeltTheme.actionGradient : LinearGradient(colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct GlassSymbolTile: View {
    let symbol: String
    var tint: Color = FeltTheme.blue
    var size: CGFloat = 48

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.42, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(LinearGradient(colors: [tint, FeltTheme.cyan, FeltTheme.mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.white.opacity(0.14))
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.white.opacity(0.66), lineWidth: 1)
            }
            .shadow(color: tint.opacity(0.30), radius: 14, x: 0, y: 7)
    }
}
