import SwiftUI

struct WaveformView: View {
    let levels: [CGFloat]
    var progress: CGFloat = 1

    var body: some View {
        GeometryReader { geo in
            let count = max(levels.count, 1)
            let gap = DT.spaceXS / 2
            let width = max(2, (geo.size.width - gap * CGFloat(count - 1)) / CGFloat(count))
            HStack(alignment: .center, spacing: gap) {
                ForEach(levels.indices, id: \.self) { idx in
                    let played = CGFloat(idx) / CGFloat(count) <= progress
                    Capsule()
                        .fill(played ? DT.accent : DT.ink.opacity(0.18))
                        .frame(width: width, height: max(6, levels[idx] * geo.size.height))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

struct PrimaryCTA: View {
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(DT.headlineFont())
                .frame(maxWidth: .infinity, minHeight: DT.tap)
                .foregroundStyle(DT.paperElevated)
                .background(DT.accent, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct GhostCTA: View {
    let title: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(DT.headlineFont())
                .frame(maxWidth: .infinity, minHeight: DT.tap)
                .foregroundStyle(DT.accent)
                .background(DT.accentSoft, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }
}
