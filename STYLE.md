# House Style Guide — template t1

The second half of the codegen contract (PRD M2 acceptance: "spec.md + the
house style guide" is everything a cold agent gets). Every generated app
follows these rules; the M5 code lint enforces the mechanical ones.

**Product completeness (required peer document):**
`docs/ios-playbook.md` — Design + Feature Playbook from top-app research.
STYLE owns *how* SwiftUI is written (tokens, empty states, StoreKit shape).
The playbook owns *what complete means* (job loops, category must-haves,
toy vs keep). Specs and codegen must satisfy both; playbook first-reach
beats decorative chrome.

## Architecture

- **SwiftUI only, zero third-party dependencies.** Apple frameworks from the
  spec's allowlist; if a feature seems to need a package, the feature is
  wrong for this portfolio.
- **All pure logic lives in `Core/`** (the local Swift package): parsing,
  arithmetic, formatting, validation, date math. Views stay declarative and
  dumb. Core compiles and tests on Linux — it is the only part of the app we
  can prove correct before the Mac gate, so put everything provable there.
- **One `NavigationStack`**, owned by the app entry point. Screens are plain
  `View` structs navigated by `NavigationLink` or `.sheet`; no custom
  routers.
- **State:** `@State`/`@StateObject` at the owning screen, `@EnvironmentObject`
  only for `PurchaseManager`. Persistence goes through `LocalStore`
  (UserDefaults + Codable) — nothing else touches disk.

## UI rules

- Use `DT` design tokens for every spacing, radius, and color value. Raw
  numbers in view code are a lint smell.
- Every screen must handle **empty, error, and loading** states using the
  standard `EmptyStateView` / `ErrorStateView` / `LoadingStateView`
  components — a blank screen is a 2.1 rejection waiting to happen.
- Every `Button` has a working action; every destination exists. No dead
  ends: error states always offer a retry or a way back.
- User-facing strings are plain English, sentence case for body text, Title
  Case for navigation titles and buttons. All strings flow through the
  String Catalog (`Localizable.xcstrings`) automatically via SwiftUI.
- Respect Dynamic Type; never fix text sizes in points. System SF Symbols
  only — no bundled icon fonts or images beyond the app icon.

## Visual identity (per-app, generated — not hand-picked)

- Each app's identity — icon symbol, palette, and the SwiftUI **AccentColor** —
  is **derived from the concept** by `foundry.assets.design_system.derive`
  (category + name + one-liner + one-job + keywords → a semantically relevant
  icon concept + a coherent palette). A decibel meter gets a soundwave, a ruler
  gets ruler-ticks, a savings app gets coins — never a hash-picked primitive,
  and never the same navy+blue for the whole portfolio.
- The icon, the marketing screenshots, and the running app all read the **same**
  derived palette, so one app has one identity across all three surfaces.
- **Do not hardcode a portfolio-wide background/accent** in the asset or
  screenshot generators, and do not overwrite `AccentColor.colorset` with a
  fixed color — that is the regression this system exists to prevent. Extend the
  palette/concept tables in `design_system.py` instead; a new category or symbol
  is a data addition there, consumed everywhere automatically.
- The QC gate (`imagegen.icon_qc`) is figure/ground based (contrast of the
  symbol against its ground + safe margin), not palette-count based, so richer
  gradient/two-tone icons pass while low-contrast or empty ones fail.

## StoreKit

- `PurchaseManager` is the only StoreKit surface. Views read
  `isUnlocked`/`products` and call `purchase`/`restore`; nothing else
  imports StoreKit except the paywall (for `Product`).
- The paywall always shows the price **before** the purchase button, always
  offers Restore Purchases, and states Family Sharing status. Locked
  features show a clear, honest teaser — never a fake screen.

## Privacy & compliance invariants (M5-lint-enforced)

- `PrivacyInfo.xcprivacy` matches actual API use. Adding an API in the
  required-reason categories (file timestamps, boot time, disk space,
  UserDefaults beyond `LocalStore`) requires updating the manifest in the
  same commit.
- No permission prompt without a spec-justified feature; no analytics, no
  ads, no tracking, no ATT.
- `ITSAppUsesNonExemptEncryption` stays `false` — do not add custom
  cryptography.

## Naming

- Screens end in `Screen` (`HistoryScreen`), reusable pieces in `View`,
  Core types are nouns (`StreakCalculator`). One type per file, file named
  after the type.
