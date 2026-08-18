import StoreKit
import SwiftUI

/// Kitchen-table unlock — price before CTA, restore, no house lock glyph.
struct PaywallView: View {
    @EnvironmentObject private var purchases: PurchaseManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DT.spaceL) {
                Text("Keep the quotes on this phone")
                    .font(DT.heroFont())
                    .foregroundStyle(DT.ink)
                Text("One purchase unlocks unlimited local transcripts, import, search, and TXT/PDF share. No account. No minute meter. Family Sharing.")
                    .font(DT.bodyFont())
                    .foregroundStyle(DT.inkSecondary)

                if purchases.products.isEmpty {
                    LoadingStateView(message: "Loading the one-time price.")
                        .task { await purchases.loadProducts() }
                } else {
                    ForEach(purchases.products, id: \.id) { product in
                        VStack(alignment: .leading, spacing: DT.spaceM) {
                            Text(product.displayPrice)
                                .font(DT.heroFont())
                                .foregroundStyle(DT.ink)
                            Text("One-time · \(product.displayName)")
                                .font(DT.captionFont())
                                .foregroundStyle(DT.inkSecondary)
                            Button {
                                Task { await purchases.purchase(product) }
                            } label: {
                                Text("Unlock Memo to Text")
                                    .font(DT.headlineFont())
                                    .frame(maxWidth: .infinity, minHeight: DT.tap)
                                    .foregroundStyle(DT.paperElevated)
                                    .background(DT.accent, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
                            }
                            .buttonStyle(PressableButtonStyle())
                            .disabled(purchases.isBusy)
                        }
                        .padding(DT.spaceM)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DT.cardBackground, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
                    }
                }

                if let message = purchases.lastErrorMessage {
                    Text(message)
                        .font(DT.captionFont())
                        .foregroundStyle(DT.destructive)
                }

                Button {
                    Task { await purchases.restore() }
                } label: {
                    Text("Restore purchase")
                        .font(DT.headlineFont())
                        .frame(maxWidth: .infinity, minHeight: DT.tap)
                        .foregroundStyle(DT.accent)
                        .background(DT.accentSoft, in: RoundedRectangle(cornerRadius: DT.radiusM, style: .continuous))
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(purchases.isBusy)

                Text("Family Sharing is on. Recordings never leave this device.")
                    .font(DT.captionFont())
                    .foregroundStyle(DT.inkSecondary)
            }
            .padding(DT.spaceM)
        }
        .background(DT.screenBackground.ignoresSafeArea())
        .navigationTitle("Unlock")
        .navigationBarTitleDisplayMode(.inline)
    }
}
