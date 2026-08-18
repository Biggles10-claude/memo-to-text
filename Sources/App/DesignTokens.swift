import SwiftUI

/// Memo to Text visual system.
/// Scene: a journalist at a kitchen table at 8pm after an interview — amber
/// desk lamp, oat paper, rust ink. Not a dark studio, not Otter teal.
/// Color strategy: Restrained tinted neutrals + one oxide accent ≤10%.
/// Register: product (engineer + redesign). 8pt grid, 44pt targets.
enum DT {
    static let spaceXS: CGFloat = 4
    static let spaceS: CGFloat = 8
    static let spaceM: CGFloat = 16
    static let spaceL: CGFloat = 24
    static let spaceXL: CGFloat = 32

    static let radiusS: CGFloat = 10
    static let radiusM: CGFloat = 16
    static let radiusL: CGFloat = 24

    static let tap: CGFloat = 44

    // Oxide rust on oat paper
    static let accent = Color(red: 0.61, green: 0.27, blue: 0.14)
    static let accentSoft = Color(red: 0.61, green: 0.27, blue: 0.14).opacity(0.12)
    static let ink = Color(red: 0.20, green: 0.15, blue: 0.12)
    static let inkSecondary = Color(red: 0.47, green: 0.40, blue: 0.34)
    static let paper = Color(red: 0.96, green: 0.93, blue: 0.87)
    static let paperElevated = Color(red: 0.99, green: 0.97, blue: 0.93)
    static let cardBackground = paperElevated
    static let screenBackground = paper
    static let positive = Color(red: 0.28, green: 0.46, blue: 0.32)
    static let caution = Color(red: 0.70, green: 0.44, blue: 0.16)
    static let destructive = Color(red: 0.68, green: 0.24, blue: 0.20)
    static let rule = Color(red: 0.20, green: 0.15, blue: 0.12).opacity(0.08)

    // Three weights only: regular, medium, semibold. Serif display + SF body + mono clocks.
    static func heroFont() -> Font { .system(size: 34, weight: .semibold, design: .serif) }
    static func titleFont() -> Font { .system(.title2, design: .serif).weight(.semibold) }
    static func headlineFont() -> Font { .system(.headline, design: .default).weight(.semibold) }
    static func bodyFont() -> Font { .system(.body, design: .default) }
    static func captionFont() -> Font { .system(.caption, design: .default).weight(.medium) }
    static func monoFont() -> Font { .system(.footnote, design: .monospaced).weight(.medium) }
    static func timerFont() -> Font { .system(size: 52, weight: .semibold, design: .serif) }

    static let press = Animation.timingCurve(0.32, 0.72, 0, 1, duration: 0.22)
    static let appear = Animation.timingCurve(0.22, 0.8, 0.2, 1, duration: 0.26)
    static let chip = Animation.timingCurve(0.32, 0.72, 0, 1, duration: 0.18)
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(DT.press, value: configuration.isPressed)
    }
}
