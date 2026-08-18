import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @EnvironmentObject private var library: MemoLibrary

    private var versionLine: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DT.spaceL) {
                card {
                    Text("On this phone")
                        .font(DT.titleFont())
                        .foregroundStyle(DT.ink)
                    Text("Recordings and transcripts stay in the app sandbox. There is no account, no cloud, and no minute meter.")
                        .font(DT.bodyFont())
                        .foregroundStyle(DT.inkSecondary)
                    Text("\(library.memos.count) memos  ·  \(library.folders.count) folders")
                        .font(DT.captionFont())
                        .foregroundStyle(DT.accent)
                }

                if purchases.mode != .paidUpfront {
                    card {
                        Text("Purchase")
                            .font(DT.titleFont())
                            .foregroundStyle(DT.ink)
                        if purchases.isUnlocked {
                            Text("Full version unlocked")
                                .font(DT.bodyFont())
                                .foregroundStyle(DT.positive)
                        } else {
                            NavigationLink {
                                PaywallView()
                            } label: {
                                Text("See the one-time price")
                                    .font(DT.headlineFont())
                                    .frame(maxWidth: .infinity, minHeight: DT.tap)
                                    .foregroundStyle(DT.paperElevated)
                                    .background(DT.accent, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                        Button {
                            Task { await purchases.restore() }
                        } label: {
                            Text("Restore purchase")
                                .font(DT.headlineFont())
                                .frame(maxWidth: .infinity, minHeight: DT.tap)
                                .foregroundStyle(DT.accent)
                        }
                        .disabled(purchases.isBusy)
                    }
                }

                card {
                    Text("Help")
                        .font(DT.titleFont())
                        .foregroundStyle(DT.ink)
                    Link(destination: GeneratedConfig.supportURL) {
                        row("Support")
                    }
                    Link(destination: GeneratedConfig.privacyURL) {
                        row("Privacy")
                    }
                }

                card {
                    Text("About")
                        .font(DT.titleFont())
                        .foregroundStyle(DT.ink)
                    labeled("Version", versionLine)
                    labeled("Data", "Stays on this device")
                }
            }
            .padding(DT.spaceM)
        }
        .background(DT.screenBackground.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DT.spaceS) {
            content()
        }
        .padding(DT.spaceM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DT.cardBackground, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous)
                .stroke(DT.rule, lineWidth: 1)
        )
    }

    private func row(_ title: String) -> some View {
        Text(title)
            .font(DT.headlineFont())
            .foregroundStyle(DT.accent)
            .frame(maxWidth: .infinity, minHeight: DT.tap, alignment: .leading)
    }

    private func labeled(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(DT.bodyFont())
                .foregroundStyle(DT.inkSecondary)
            Spacer()
            Text(value)
                .font(DT.bodyFont())
                .foregroundStyle(DT.ink)
        }
        .frame(minHeight: DT.tap)
    }
}
