# Berkeley Mobile iOS — Build & Automation Guide

Berkeley Mobile is a UIKit + SwiftUI iOS app for UC Berkeley students. Data comes from
Firebase (Firestore, Auth, Messaging). Dependencies come from **CocoaPods (vendored — the
`Pods/` directory is committed)** and **Swift Package Manager** (resolved automatically at
build time).

## Quick facts

| | |
|---|---|
| Default branch | `master` |
| Workspace | `berkeley-mobile.xcworkspace` (always build the workspace, never the `.xcodeproj` alone) |
| Scheme | `berkeley-mobile` (shared) |
| App target / product | `berkeley-mobile` → `berkeley-mobile.app` (home-screen display name: "Berkeley") |
| Widget target | `BerkeleyMobileWidgetExtension` |
| Bundle ID | `org.asuc.ASUC` |
| Deployment target | iOS 18.0 (app), iOS 17.0 (widget) |
| Required toolchain | Xcode 26+ (the code uses iOS 26 APIs like `glassEffect` behind `#available` checks, which need the iOS 26 SDK to compile) |

## Build — step by step

1. Clone the repo. **No dependency installation is required.** `Pods/` is committed and
   `Pods/Manifest.lock` is in sync with `Podfile.lock`. **Do NOT run `pod install`.**
2. Secrets/config placeholders are already committed (see "Secrets" below) — a clean clone
   compiles without adding any files.
3. Build for the simulator:

   ```bash
   xcodebuild -workspace berkeley-mobile.xcworkspace \
              -scheme berkeley-mobile \
              -configuration Debug \
              -destination 'platform=iOS Simulator,name=iPhone 16' \
              build
   ```

   The first build resolves Swift packages (needs network) and cold-compiles the vendored
   Pods (~2–3 min). Incremental rebuilds take ~15–20 s — reuse the same build environment
   instead of recreating it.
4. The built product is `berkeley-mobile.app`. Install and launch it on the simulator as
   usual (e.g. `xcrun simctl install` / `simctl launch`, or your sandbox's installer).
5. On first launch the app requests location permission — dismiss/accept the dialog before
   interacting with the map.

## Secrets and configuration

- `berkeley-mobile/GoogleService-Info.plist` and `berkeley-mobile/Secrets.swift` are
  committed with **placeholder values** so the project builds out of the box. Firebase
  initializes with them, but no real backend is reachable.
- Consequence: Firestore-backed screens (resources, events, gyms, dining…) show
  empty/loading states. If a task needs populated UI (e.g. a screen recording), mock the
  relevant fetch layer locally — and **revert the mock before committing**.
- Never commit real credentials. If you have real values, overwrite the placeholder files
  locally only.

## Committing and pushing

- Configure a git identity before committing if the environment has none:
  `git config user.name` / `git config user.email`.
- Keep environment workarounds (mocked data, signing tweaks) out of commits. Diff-check
  before pushing.

## Pitfalls — do not undo these

- **`objectVersion = 63`** in `project.pbxproj` is intentional: the CocoaPods/xcodeproj
  gem cannot parse version 70. Don't let Xcode bump it back when committing project
  changes.
- **`ENABLE_PREVIEWS = NO`** on the app target is intentional: headless/CI Xcode builds
  fail linking `__preview.dylib` with previews enabled.
- **`PRODUCT_NAME = $(TARGET_NAME)`** is intentional so tooling finds
  `berkeley-mobile.app`; the user-facing name is kept via `CFBundleDisplayName`.
- `SearchViewModel` uses the Observation framework (`@Observable`). Inject it with
  FactoryKit's `@InjectedObservable(\.searchViewModel)` — `@InjectedObject` requires
  `ObservableObject` and will not compile.
- `Secrets.swift` is compiled into the app target. Don't delete it; replace values only.
