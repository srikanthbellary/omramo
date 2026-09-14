# Omramo product lock (seed for scaffold)

**Domain:** omramo.com  
**Line:** iPhone Duo  
**Niche:** Telugu stories (core). Hindi + English are preloaded literary editions of the same titles — not live MT.

## v1 loop
1. Open app
2. Browse catalog — titles, posters, descriptions only (free)
3. Tap title → two-page open-book sample on Duo
4. Hard paywall → subscribe
5. After subscribe → Netflix-style all-access to entire catalog

## Prototype content
- 3 dummy books × ~10 pages each
- Sample Telugu text + images
- Te/Hi/En edition packs when dual-pane is on

## Duo wow
- Physical dual panes: open-book sample + reading
- Illustrated/map art on second pane when not bilingual
- Synced Te|En (or Te|Hi) preloaded editions

## Mark
- Splash/logo concept: OM | RA | MO (left / spine / right). Closed = Omramo. Open = the book.
- Do not invent another mark.

## Account and payment (v1)
- Pay only through StoreKit 2 auto-renewable subscription to the Apple Account. No email signup, phone OTP, card form or separate checkout.
- No profile or social page. Settings (gear on the catalog) is the account-adjacent surface: Appearance (System / Light / Dark), Restore Purchases, Manage Subscription (system sheet), Privacy Policy and Terms links.
- Loop that must work: splash → catalog → sample → paywall → reader → catalog → Settings → entitlement still valid.

## Non-goals for scaffold
- Stylepipe is ops backend only — not in the app binary
- No real catalog pipeline in-app
- No Kindle à-la-carte; Netflix subscription only
- Do not invent product names

## Apple
- Target iPhone Duo layouts (adaptive dual display / scenes)
- Xcode 27.1 / Duo Device Hub when available; until then scaffold for current Xcode and keep Duo layout abstractions ready
- Apple Developer org is a TestFlight hard gate (ops)

## Docs for agents
- Apple hub: https://developer.apple.com/iphone-duo/
- HIG: https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo
