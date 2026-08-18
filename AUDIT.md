# Template t1 — hand-audit against the M5 code-level checks

> **Scope: the EMPTY template only. This page says nothing about generated apps.**
>
> Every ✓ below is true of `template/` as it sits on disk, and several are true
> *because it is empty*. The permission-strings row passes because the bare
> template touches no capabilities — a generated app that opens the camera does
> not inherit that pass, and `biggle-table-scan-pdf` shipped presenting
> `VNDocumentCameraViewController` with no `NSCameraUsageDescription`, which is a
> guaranteed crash on its primary action. This audit was read as evidence that
> generated apps were clean. It never was, and it was never re-run against one.
>
> The authority for a *generated* app is `foundry lint code` against its own
> tree — including `CODE-FEATURE-PROOF`, which checks the app actually contains
> what its spec claims. See `../HONEST-AUDIT-2026-07-15.md`.

P1-M3 exit criterion: "bare template passes every M5 code-level check by
hand-audit." The code-level rule *engine* lands at P1-M5 (per the roadmap);
this audit pins each future check to how the bare template satisfies it
today, and `tests/test_template.py` mechanizes every row marked ✓⚙ so the
audit cannot rot silently.

| Future M5 code check (PRD M5 "code-level") | Bare template t1 status | Mechanized |
|---|---|---|
| `PrivacyInfo.xcprivacy` present & valid plist | ✓ `Sources/App/Resources/PrivacyInfo.xcprivacy` | ✓⚙ |
| Manifest declares required-reason APIs actually used | ✓ UserDefaults (`LocalStore`) → `CA92.1`; no file-timestamp/boot-time/disk-space APIs anywhere | ✓⚙ |
| `ITSAppUsesNonExemptEncryption=false` in Info.plist | ✓ `Support/Info.plist` | ✓⚙ |
| Permission strings for every touched capability | ✓ template touches no camera/mic/location/photos APIs → zero `NS*UsageDescription` keys needed or present | ✓⚙ |
| No private-API symbol patterns | ✓ only public SwiftUI/StoreKit/Foundation symbols | ✓⚙ (denylist scan) |
| No third-party SDK imports | ✓ imports are exactly SwiftUI/StoreKit/Foundation/XCTest + local `Core` | ✓⚙ |
| StoreKit: restore entry point present if IAP exists | ✓ `PaywallView` + `SettingsScreen` both expose Restore Purchases | ✓⚙ |
| StoreKit: price shown before purchase CTA | ✓ `PaywallView` renders `displayPrice` above the buy button | ✓⚙ (ordering scan) |
| Placeholder detection (no lorem/TODO, no dead buttons) | ✓ no TODO/lorem strings; every `Button` closure calls real code | ✓⚙ |
| 2.1 completeness: empty/error/loading states exist | ✓ `StateViews.swift` components used by the home screen | ✓⚙ |

Additional invariants the audit checked once, manually:

- `project.yml` declares App / AppTests / AppUITests targets, iPhone-only
  (`TARGETED_DEVICE_FAMILY: 1`), portrait-only, iOS 18 minimum, Xcode 26 —
  matching PRD M6's target block.
- The String Catalog covers every user-facing literal in the template
  sources (SwiftUI auto-extracts; catalog checked in for locale slots).
- `Core` builds with `swift build && swift test` on a Linux toolchain
  (mechanized in P1-M5's verification chain; spot-verified by hand for t1).
- StoreKit configuration file loads in Xcode's transaction manager
  (structure follows the version-3 schema; full validation is a Phase-2
  concern the first time a Mac opens the project).

Template changes MUST bump `foundry.codegen.TEMPLATE_VERSION` and re-run
this audit (the mechanized rows run in CI on every commit regardless).
