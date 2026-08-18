import SwiftUI

/// Designed empty / error / loading. Playbook §1.3: next action on empty.
struct EmptyStateView: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let systemImage: String
    var actionTitle: LocalizedStringKey? = nil
    var action: (() -> Void)? = nil
    var secondaryTitle: LocalizedStringKey? = nil
    var secondaryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: DT.spaceM) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(DT.accent)
                .frame(width: 72, height: 72)
                .background(DT.accentSoft, in: Circle())
            Text(title)
                .font(DT.titleFont())
                .foregroundStyle(DT.ink)
                .multilineTextAlignment(.center)
            Text(message)
                .font(DT.bodyFont())
                .foregroundStyle(DT.inkSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(DT.headlineFont())
                        .frame(maxWidth: .infinity, minHeight: DT.tap)
                        .foregroundStyle(DT.paperElevated)
                        .background(DT.accent, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, DT.spaceS)
            }
            if let secondaryTitle, let secondaryAction {
                Button(action: secondaryAction) {
                    Text(secondaryTitle)
                        .font(DT.headlineFont())
                        .frame(maxWidth: .infinity, minHeight: DT.tap)
                        .foregroundStyle(DT.accent)
                        .background(DT.accentSoft, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(DT.spaceL)
        .frame(maxWidth: .infinity)
        .background(DT.cardBackground, in: RoundedRectangle(cornerRadius: DT.radiusL, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DT.radiusL, style: .continuous)
                .stroke(DT.rule, lineWidth: 1)
        )
    }
}

struct ErrorStateView: View {
    let message: LocalizedStringKey
    let retry: () -> Void

    var body: some View {
        VStack(spacing: DT.spaceM) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(DT.destructive)
            Text(message)
                .font(DT.bodyFont())
                .multilineTextAlignment(.center)
                .foregroundStyle(DT.ink)
            Button(action: retry) {
                Text("Try again")
                    .font(DT.headlineFont())
                    .frame(maxWidth: .infinity, minHeight: DT.tap)
                    .foregroundStyle(DT.paperElevated)
                    .background(DT.accent, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(DT.spaceL)
        .background(DT.cardBackground, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
        .padding(DT.spaceM)
    }
}

struct LoadingStateView: View {
    let message: LocalizedStringKey

    var body: some View {
        VStack(spacing: DT.spaceM) {
            RoundedRectangle(cornerRadius: DT.radiusS, style: .continuous)
                .fill(DT.accentSoft)
                .frame(height: 10)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: DT.radiusS, style: .continuous)
                        .fill(DT.accent)
                        .frame(width: 72)
                }
                .padding(.horizontal, DT.spaceXL)
            Text(message)
                .font(DT.captionFont())
                .foregroundStyle(DT.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}
