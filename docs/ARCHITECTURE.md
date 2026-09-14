# Omramo architecture (v1 scaffold)

This document describes how the scaffold is put together. The product lock in
`PRODUCT.md` is the source of truth for what the app does; this file only
describes how.

## Modules

```
Omramo.xcodeproj            Xcode 16 project, one iOS app target
Omramo/                     App target (SwiftUI, StoreKit 2). Synchronized folder.
  App/                      Composition root, stores, navigator, root and splash
  Features/                 One folder per screen in the loop
    Catalog/                Free browsing
    Sample/                 Two page open book sample
    Paywall/                Hard paywall
    Reader/                 Full reader
    Settings/               Appearance, restore, manage subscription, legal links
  Layout/                   Duo pane abstraction and page surfaces
  DesignSystem/             Palette, type, placeholder art, FoldMarkView (OM | RA | MO)
  Store/                    EntitlementBackend implementations
  Assets.xcassets           App icon slot and accent colour only
Packages/OmramoCore/        Swift package, no UI. Builds and tests on Linux.
  Brand/                    Brand (display name, domain, legal URLs, derived FoldMark, tagline)
  Settings/                 AppearanceMode
  Model/                    Book, Edition, Page, Artwork, Language
  Content/                  ContentRepository, LoadState, ContentError
  Entitlement/              SubscriptionPlan, EntitlementState, EntitlementGate
  Layout/                   SpreadLayoutPolicy, SpreadMode, SpreadPager
  Resources/Content/        The bundled prototype catalog (JSON)
Configuration/Omramo.storekit   Local StoreKit configuration for the simulator
Configuration/Brand.xcconfig    BRAND_DISPLAY_NAME and BRAND_DOMAIN for build settings
```

## Brand

`Brand` in the core is the only place the product is named. Views interpolate
`Brand.displayName`; the fold mark view takes `Brand.mark`, a `FoldMark`
derived from the name; `ContentError` copy and the simulated store's offer
names use it too. The app target's build configurations inherit
`Configuration/Brand.xcconfig`, and `INFOPLIST_KEY_CFBundleDisplayName` is
`$(BRAND_DISPLAY_NAME)`. `BrandTests` asserts the constant and the xcconfig
agree. Identifiers that must never change with a rename (bundle id, product
ids, module names) are kept out of `Brand` on purpose.

Dependency direction is one way: `Omramo` imports `OmramoCore`; the core
imports Foundation only. Anything that can be expressed without SwiftUI,
UIKit or StoreKit lives in the core so it can be unit tested with `swift test`
without a Mac.

## Navigation

```
RootView  (owns a per-window AppNavigator)
  NavigationStack(path: navigator.path)
    CatalogView                        root
      -> .sample(BookID)  SampleSpreadView
      -> .reader(BookID)  ReaderView
  .fullScreenCover(item: navigator.paywallBookID)  PaywallView
```

`AppNavigator` is an `@Observable` object created by `RootView` so a second
Duo window does not share the path. Catalog and entitlement stores stay
shared. The gate lives in `EntitlementGate` and the navigator only applies it:

```swift
EntitlementGate.destinationFromCatalog(for:)
    .allow        -> .reader     (Netflix all access)
    .showPaywall  -> .sample     (free two page open book)
    .wait         -> .sample     (sample is free; do not block the shelf)

EntitlementGate.destinationFromSample(for:)
    .allow        -> .reader
    .showPaywall  -> .paywall
    .wait         -> .wait       (the button shows a spinner)
```

`openTitle` is the catalog tap. `openReader` is continue-from-sample. Neither
pushes the full reader without `.allow`. After a successful subscribe,
`revealReader` replaces the sample of that title so Back returns to the
catalog. `finishPaywall` is idempotent because a purchase can report success
through both the button and the entitlement stream; the reader is revealed
from the cover's `onDismiss` so the two transitions never overlap.

The sample loads `loadSampleContent`, which clips every edition to
`book.sample.pageCount` so pages past the sample never sit in that screen.

The splash is an overlay on the root, not a route. It stays up for at least
1.6s and until the catalog has loaded, then fades to the shelf.

## Content model

Content is bundled JSON inside `OmramoCore`'s resource bundle. The catalog is
light; page text lives in per edition files so browsing never loads pages.

```
Content/catalog.json
Content/books/<book-id>/<book-id>.<lang>.json
```

Types (all `Codable`, `Hashable`, `Sendable`):

- `Catalog { schemaVersion, books }`
- `Book { id, title, author, description: LocalizedText, poster: Artwork,
  pageCount, editions: [EditionManifest], sample: SampleSpec }`
- `EditionManifest { language, status: ready | planned, file? }`
- `Edition { bookID, language, pages: [Page] }`
- `Page { number (1 based), text, illustration: Artwork?, caption? }`
- `Artwork { motif, colors: [HexColor], assetName? }`
- `LocalizedText` is `[Language: String]` and must contain the primary
  (Telugu) value; lookups fall back to Telugu.

Editions are **paired by page number**. The Telugu edition is primary; the
English edition (and later Hindi) has the same page count and numbering, which
is what lets `SpreadMode.synced` show page n in two languages across two
panes. Hindi is listed as `planned` with no file so the catalog can show it
without a loader crash. There is no machine translation anywhere in the app.

Images are `Artwork` descriptors rendered procedurally by `PlaceholderArt`.
When real illustrations land, set `assetName` and the same descriptor keeps
the colour story for loading and fallback.

`BundledContentRepository` validates on load: schema version, page numbering
1...n, and that an edition's page count matches the catalog. Failures become
`ContentError` with a reader facing `userMessage`, then `LoadFailure` with a
`isRetryable` flag.

### Screen state

Every loading surface holds a `LoadState<Value>`:

```
idle | loading | empty | failed(LoadFailure) | loaded(Value)
```

`CatalogView`, `SampleSpreadView`, `ReaderView` and the paywall's plan list all
switch exhaustively over it. Nothing renders a raw error.

## Entitlement gate

```
EntitlementBackend (protocol, Sendable)        OmramoCore
  StoreKitEntitlementBackend                   Omramo/Store  (StoreKit 2)
  SimulatedEntitlementBackend                  Omramo/Store  (in memory)
EntitlementStore (@Observable, MainActor)      Omramo/App
EntitlementGate.decision(for:)                 OmramoCore    (pure function)
```

- `SubscriptionPlan` is `monthly | yearly`, one subscription group, product
  ids `com.omramo.allaccess.monthly` and `com.omramo.allaccess.yearly`. There
  is no per title product and no code path to add one.
- `EntitlementState` is `unknown | notSubscribed | subscribed(plan, renewsOn)`.
  `unknown` maps to `AccessDecision.wait` so the paywall never flashes before
  the store has answered.
- `EntitlementGate.canRead(pageIndex:in:state:)` keeps sample pages free and
  gates everything else. `ReaderView` calls it for every pane it draws, so a
  lapsed subscription locks pages in place instead of trusting the route.
- `EntitlementStore.start()` reads `Transaction.currentEntitlements` and then
  listens to `Transaction.updates` for the life of the app.
- Purchases use `Product.purchase()`; `pending` (Ask to Buy) is surfaced as a
  message and resolves through the update stream.
- No secrets. StoreKit 2 verifies transactions on device; the app never talks
  to a server for entitlement.

### No custom account system

Identity is the Apple Account. There is no sign up, sign in, email, phone or
card form, and no server. Restore is `AppStore.sync()`; cancel and plan
changes go through StoreKit's `manageSubscriptionsSheet` from Settings. If a
server ever needs to know about entitlements, App Store Server Notifications
are the path, not an app side login.

### Settings and appearance

`AppSettings` (`@Observable`, `MainActor`) holds `AppearanceMode` from the
core, persisted in `UserDefaults` under `AppearanceMode.storageKey`.
`RootView` applies `preferredColorScheme(settings.appearance.colorScheme)`
so the choice reaches every scene, and `OmramoPalette` resolves paper and ink
through dynamic `UIColor` providers so the reading surface itself changes.
`SettingsView` is a sheet from the catalog toolbar; it is the only view that
imports StoreKit besides the backend, and only for the system sheet.

### Testing the gate without App Store Connect

1. The shared scheme attaches `Configuration/Omramo.storekit`, so Run in the
   simulator gives real StoreKit 2 purchases against local products.
2. Launch argument `-OmramoSimulatedStore` swaps in
   `SimulatedEntitlementBackend` (purchases succeed after a short delay and
   the resulting state is persisted so entitlement survives relaunch).
3. Debug builds have a "Developer" disclosure at the bottom of the paywall
   that sets an override on `EntitlementStore`. It persists in Debug
   `UserDefaults` and compiles out of Release.

## Duo layout

`OpenBookSpread` is the single place that decides between one pane and two.
Every screen (catalog, sample, paywall, reader) lays out through it. It
measures its width and asks `SpreadLayoutPolicy`:

```
regular width  -> dual   (any orientation; width >= 400 sanity floor)
compact width  -> dual   if width >= 700 (landscape phones), else single
```

This follows Apple's guidance for iPhone Duo (a compact width foundation for
the outer display and a regular width foundation for the inner display, no
pose or hinge angle checks) and the foldable reader P0 locks in `DESIGN.md`:
two panes by default on the inner display, no rotation needed, never a
stretched phone column. The dual branch renders `BookPanes`, two pages around
a `BookSpine` gap of 28pt that stands in for the reserved fold region; other
screens leave the same gap empty.

### Reading position

`ReadingPosition { pageIndex, mode }` is a value in the core that knows
nothing about panes. `SpreadPager` turns it into a `Spread` for whichever
arrangement is current, so a compact to regular change re-derives the spread
from the same index instead of resetting it. `ReaderModel` owns the position,
validates it against the title (`validated(for:)` clamps the index and drops
modes the title cannot offer), and saves it per title through
`ReadingProgressStore` (`UserDefaults`, two keys per book) on every turn or
mode change. On a single pane, `synced` renders a `CompanionPage` stacked
under the primary page so the mode still means something.

`SpreadPager` (core) maps a page index to a `Spread { leftIndex, rightIndex? }`
for the current arrangement and `SpreadMode`:

- `facingPages`: left n, right n + 1, even index always on the left
- `synced(secondary)`: same page in Telugu and the secondary edition
- `illustrated`: text left, the page's art on the right

Xcode 27.1 seam: when the iOS 27.1 SDK is available, the dual branch of
`OpenBookSpread` can become `ArrangementView { left } secondary: { right }
.arrangementViewStyle(.split)` and the spine width can be read from
`GeometryProxy.reservedRegions(kind: .division)`. Callers do not change.

Multiple scenes are enabled through the generated scene manifest, so a
second window can be opened on the inner display; each window has its own
`AppNavigator`-driven path while sharing `CatalogStore` and
`EntitlementStore`.

## Concurrency

`OmramoCore` compiles in Swift 6 language mode. The app target is Swift 5
mode with `SWIFT_STRICT_CONCURRENCY = complete`. Stores are `@MainActor`
`@Observable` classes; backends are `Sendable` (a stateless struct for
StoreKit, an actor for the simulator).

## What is deliberately not here

- No Stylepipe or any generation pipeline. Content arrives as files.
- No network, no analytics, no accounts.
- No per book purchase, offer codes or trials (trials can be added in App
  Store Connect without code changes).
- No custom fonts. System fonts fall back to Telugu Sangam MN and Devanagari
  Sangam MN with Dynamic Type.
