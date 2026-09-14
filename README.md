# Omramo

Telugu-first illustrated serial reader for **iPhone Duo** (`omramo.com`).

Sunrise Gen AI LLC · private · Duo ops.

See `docs/PRODUCT.md` for the locked v1 loop and constraints,
`docs/ARCHITECTURE.md` for how the scaffold is built, and `docs/DESIGN.md`
for the core UI and the OM | RA | MO mark.

## What is here

The v1 loop, end to end, with dummy content:

1. Open app (OM | RA | MO splash)
2. Browse the catalog of 3 titles, free
3. Tap a title, read a two page sample as an open book across two panes
4. Hard paywall, one subscription (StoreKit 2, monthly or yearly)
5. Read every title in the catalog

Content is 3 dummy books x 10 pages, Telugu and English paired editions with
Hindi listed as planned, all bundled as JSON. No network, no secrets, no
generation pipeline in the binary.

## Requirements

- Xcode 16 or later (the project uses synchronized folders). Xcode 27.1 with
  the iPhone Duo Device Hub when available.
- iOS 18 simulator or device.

## Open and run

```bash
git clone <this repo>
cd omramo
open Omramo.xcodeproj
```

1. Select the **Omramo** scheme and an iPhone or iPad simulator.
   An iPad or a Max phone in landscape shows the two pane layout today; a
   regular phone shows the compact one pane layout. Both are Duo foundations.
2. Press Run. The shared scheme attaches `Configuration/Omramo.storekit`, so
   the paywall lists real StoreKit 2 products and purchases complete in the
   simulator without an App Store Connect account.
3. On first launch Xcode will resolve the local package `Packages/OmramoCore`
   automatically. If signing complains, set your team under
   Signing & Capabilities; the bundle id is `com.omramo.app`.

### Walking the loop

- Catalog shows three titles. While browsing free, tap one. The sample opens
  on pages 1 and 2 only; the rest of the book is not held on that screen.
- On a wide layout, switch the segmented control to `తెలుగు | English` to see
  the synced editions.
- Tap **Subscribe to continue reading**. Pick a plan and subscribe (StoreKit
  test purchase, no charge). The paywall dismisses and the reader replaces
  the sample on the same title.
- All access is now on. Back on the catalog, tap any title and it opens in
  the reader, not the sample. Use the toolbar **Spread** menu to switch
  Pages, `తెలుగు | English`, or Art.
- Tap the gear. Switch Appearance (System / Light / Dark), tap Restore
  Purchases (the status row stays on all access), and open Manage Subscription
  for the StoreKit system sheet. Quit and reopen: entitlement is still valid
  (StoreKit transactions, or the simulated store if you launched with
  `-OmramoSimulatedStore`).

### Without StoreKit

Two other ways to get past the paywall while developing:

- Add the launch argument `-OmramoSimulatedStore` in the scheme to use an in
  memory store where purchases always succeed. That stand-in writes its
  entitlement to `UserDefaults` so a relaunch still has all access.
- In Debug builds, open the **Developer** disclosure at the bottom of the
  paywall and tap **Simulate an active subscription**. That override is also
  persisted so the loop stays unlocked until you clear it.

Both compile out of, or are ignored by, Release builds.

## Tests

The core package has no UI dependencies and runs anywhere Swift runs:

```bash
cd Packages/OmramoCore
swift test
```

It checks the content contract (3 titles, 10 pages each, editions paired page
for page, Telugu script present, no em dashes in English copy), the
entitlement gate and loop destinations, sample page clipping, persisted
entitlement round trip, and the pane layout rules. In Xcode, Cmd+U on the
Omramo scheme runs the same tests.

## Layout

```
Omramo.xcodeproj         Xcode project (one app target)
Omramo/                  SwiftUI app: App, Features, Layout, DesignSystem, Store
Packages/OmramoCore/     Swift package: model, bundled content, gate, layout policy, tests
Configuration/           Omramo.storekit for local StoreKit testing
docs/                    PRODUCT.md (lock), ARCHITECTURE.md, DESIGN.md
```

## Renaming the product

The display name is atomically swappable. The current value is Omramo.

1. Set `Brand.displayName` in `Packages/OmramoCore/Sources/OmramoCore/Brand/Brand.swift`. Every in app string, the splash wordmark and the fold mark tiles (OM | RA | MO today) derive from it.
2. Set `BRAND_DISPLAY_NAME` in `Configuration/Brand.xcconfig` to the same value. It feeds `CFBundleDisplayName`; the core tests fail if the two drift.
3. Optionally set `Brand.domain` and `BRAND_DOMAIN`. Bundle id and product ids are App Store keys, not brand, and stay as they are.

## Adding a title

1. Add a folder `Packages/OmramoCore/Sources/OmramoCore/Resources/Content/books/<id>/`
   with `<id>.te.json` and, if ready, `<id>.en.json`. Pages are numbered from 1
   and the editions must have the same page count.
2. Add the entry to `catalog.json` with the poster `Artwork`, `pageCount`,
   `editions` and `sample.pageCount`.
3. Run `swift test` in the package. The content tests will tell you if
   anything is mismatched.
