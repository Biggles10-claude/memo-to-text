import Foundation
import StoreKit

/// Which StoreKit shape this app ships (from the spec's monetization
/// section; wired via `GeneratedConfig.purchaseMode`).
enum PurchaseMode: Equatable {
    /// Paid-upfront app: no StoreKit surface at all (house default).
    case paidUpfront
    /// Free + one-time unlock: a single non-consumable product.
    case iapUnlock(productID: String)
    /// Subscription (exceptional; higher M1 bar): auto-renewable products,
    /// annual first.
    case subscription(productIDs: [String])
}

/// StoreKit 2 manager (template t1) covering both monetization variants with
/// the mandatory restore flow. Uses `Transaction.currentEntitlements` as the
/// source of truth and keeps listening for updates for the app's lifetime.
@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var isUnlocked: Bool
    @Published private(set) var products: [Product] = []
    @Published private(set) var isBusy = false
    @Published private(set) var lastErrorMessage: String?

    let mode: PurchaseMode
    private var updatesTask: Task<Void, Never>?

    init(mode: PurchaseMode) {
        self.mode = mode
        // Paid-upfront apps are fully unlocked by definition.
        self.isUnlocked = mode == .paidUpfront
    }

    deinit {
        updatesTask?.cancel()
    }

    private var productIDs: [String] {
        switch mode {
        case .paidUpfront:
            return []
        case let .iapUnlock(productID):
            return [productID]
        case let .subscription(productIDs):
            return productIDs
        }
    }

    /// Load products, refresh entitlements and start the transaction
    /// listener. Safe to call once from the root `.task`.
    func start() async {
        guard mode != .paidUpfront else { return }
        await loadProducts()
        await refreshEntitlements()
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                if case let .verified(transaction) = update {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }

    func loadProducts() async {
        guard !productIDs.isEmpty else { return }
        do {
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = String(localized: "Could not load products. Check your connection and try again.")
        }
    }

    func purchase(_ product: Product) async {
        isBusy = true
        defer { isBusy = false }
        do {
            let result = try await product.purchase()
            switch result {
            case let .success(verification):
                if case let .verified(transaction) = verification {
                    await transaction.finish()
                }
                await refreshEntitlements()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastErrorMessage = String(localized: "The purchase could not be completed. You have not been charged.")
        }
    }

    /// Restore purchases — mandatory entry point whenever products exist
    /// (App Review; surfaced in Settings and on the paywall).
    func restore() async {
        isBusy = true
        defer { isBusy = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = String(localized: "Restore did not complete. Try again later.")
        }
    }

    func refreshEntitlements() async {
        guard mode != .paidUpfront else {
            isUnlocked = true
            return
        }
        var unlocked = false
        for await entitlement in Transaction.currentEntitlements {
            if case let .verified(transaction) = entitlement,
               productIDs.contains(transaction.productID) {
                unlocked = true
            }
        }
        isUnlocked = unlocked
    }
}
