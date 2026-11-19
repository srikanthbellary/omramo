import SwiftUI
import OmramoCore

// The Two Sisters: palette, the four lights, the land and water of the inlet, the bridge,
// the cedar-plank houses and canoes, and the people (the two sisters and the chief).

extension SistersArt {
    // MARK: Palette and light

    /// Pacific coast mist: deep sea green, fir green, silver-white, and the cedar red-brown.
    static let ramp = ArtStyle.Ramp(deep: 0x12262A, shade: 0x2F5A55, mid: 0x6E8F86, light: 0xEEF2EF, glow: 0xF3C9A0, accent: 0xA8452A)

    /// Cedar wood (canoes, planks): the one strong warm colour.
    static let cedar: UInt32 = 0xA8452A
    static let cedarDark: UInt32 = 0x6E2E1E
    static let plank: UInt32 = 0x8A5A40
    static let plankDark: UInt32 = 0x5A3A2C
    /// Woven cedar bark (capes, mats, baskets).
    static let bark: UInt32 = 0xB08A5E
    static let barkDark: UInt32 = 0x7E5E3C
    /// Mountain-goat wool, undyed.
    static let wool: UInt32 = 0xEDE4D0
    static let skin: UInt32 = 0xB87A58
    static let hairDark: UInt32 = 0x1E1A1C
    static let hairGrey: UInt32 = 0xBDB8B0

    /// Early-morning mist over the narrows (scene-bridge, the cover).
    static func mist() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xE3EAE7), 0), (Art.color(0xEEF2EF), 0.55), (Art.color(0xF4E4D2), 0.86), (Art.color(0xF3C9A0), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6E8, glow: 0xF3C9A0, haze: 0xE8EEEA, far: 0xB4C6C2, mid: 0x7E9A92, near: 0x3E5E57)
    }

    /// Soft silver daylight in the village, long ago.
    static func silver() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xDDE6E4), 0), (Art.color(0xECF0EC), 0.55), (Art.color(0xF3E6D6), 0.88), (Art.color(0xF1D2B2), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF4E4, glow: 0xF3C9A0, haze: 0xE6ECE8, far: 0xAFC2BC, mid: 0x6E8F86, near: 0x3A5A52)
    }

    /// A bright pale morning for the canoes.
    static func bright() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD8E7EA), 0), (Art.color(0xEDF4F1), 0.55), (Art.color(0xF7EAD4), 0.86), (Art.color(0xF6D2A6), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF8EA, glow: 0xF6CFA0, haze: 0xEAF1EE, far: 0xA9C4C0, mid: 0x6A9088, near: 0x355A52)
    }

    /// The pale rose-gold evening of the last pages (never night).
    static func evening() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xEFDCDC), 0), (Art.color(0xF8E6DE), 0.5), (Art.color(0xF9DCC6), 0.82), (Art.color(0xF6C79A), 1)]
        return Kit.Light(sky: sky, sun: 0xFFE9CC, glow: 0xF5C08E, haze: 0xF4E0D6, far: 0xA8AEC0, mid: 0x6E7A92, near: 0x3E4A5E)
    }

    /// Douglas fir and western red cedar.
    static func firGreens() -> Kit.Greens {
        Kit.greens(0x12302C, 0x1E4640, 0x2F5A55, 0x4E7A6A, 0x9CB89E)
    }

    /// Salmonberry leaves.
    static func berryGreens() -> Kit.Greens {
        Kit.greens(0x1E4A36, 0x2E6A46, 0x4A8A52, 0x7EB06A, 0xC6DE9A)
    }

    /// `y` on the quadratic curve y0 → (control c) → y1 at `t`.
    static func quadY(_ y0: CGFloat, _ c: CGFloat, _ y1: CGFloat, _ t: CGFloat) -> CGFloat {
        let u: CGFloat = 1 - t
        let a: CGFloat = u * u * y0
        let b: CGFloat = 2 * t * u * c
        return a + b + t * t * y1
    }

    // MARK: Land, mist and water

    /// A soft band of mist lying along `y`.
    static func mistBand(_ context: inout GraphicsContext, width w: CGFloat, y: CGFloat, height h: CGFloat, alpha: Double) {
        let white = Color.white
        let band: Kit.Stops = [(white.opacity(0), 0), (white.opacity(alpha), 0.5), (white.opacity(0), 1)]
        let top: CGFloat = y - h / 2
        Art.fillLinear(&context, Art.rect(0, top, w, h), band, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: top + h))
    }

    /// The North Shore: forested lower slopes along the whole far shore and higher ridges
    /// rising on the trailing side, veiled by the air.
    static func northShore(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light) {
        let high = Kit.ridge(width: 460, y: H - 44 * s, amp: 16 * s, seed: 21, bottom: H + 6, step: 8, x0: 470)
        Art.fill(&context, high, light.mid.opacity(0.7))
        let low = Kit.ridge(width: w, y: H - 16 * s, amp: 9 * s, seed: 23, bottom: H + 6)
        Art.fill(&context, low, light.mid)
        let crest: Stops = [(light.glow.opacity(0.22), 0), (light.glow.opacity(0), 1)]
        Art.clipped(&context, to: high) { g in
            Art.fillLinear(&g, Art.rect(0, H - 64 * s, w, 30 * s), crest, from: CGPoint(x: 0, y: H - 64 * s), to: CGPoint(x: 0, y: H - 34 * s))
        }
        Kit.farTrees(&context, x0: 0, x1: w, baseY: H - 8 * s, height: 10 * s, count: 46, color: light.near.opacity(0.35), conifer: true, seed: 17)
        ArtStyle.atmosphere(&context, width: w, top: H - 70 * s, bottom: H + 6, color: light.haze, alpha: 0.32)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: H - 70 * s, width: w, height: 76 * s), seed: 19, alpha: 0.05)
    }

    typealias Stops = Kit.Stops

    /// The two rounded summits side by side, the left one a little higher, with snow on their
    /// shoulders. About 140 wide and 60 tall at scale 1; origin at the middle of their base.
    static func twinPeaks(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        scale: CGFloat,
        rock: Color,
        snow: Color,
        glow: Color? = nil,
        seed: UInt32 = 1
    ) {
        Art.group(&context, x: cx, y: baseY, scale: scale) { g in
            let shape = Art.svg("M-74,0 C-60,-12 -48,-30 -38,-44 C-31,-56 -12,-64 -5,-52 C-2,-46 0,-42 3,-44 C9,-56 29,-57 35,-44 C45,-28 60,-12 76,0 Z")
            Art.fill(&g, shape, rock)
            Art.clipped(&g, to: shape) { c in
                let cap = Art.svg("M-90,-30 L-52,-27 L-44,-36 L-36,-27 L-27,-35 L-18,-27 L-10,-33 L-2,-29 L6,-36 L14,-29 L22,-35 L30,-28 L42,-33 L52,-24 L90,-26 L90,-90 L-90,-90 Z")
                Art.fill(&c, cap, snow)
                var streaks = Path()
                streaks.move(to: CGPoint(x: -22, y: -40))
                streaks.addLine(to: CGPoint(x: -26, y: -24))
                streaks.move(to: CGPoint(x: -34, y: -38))
                streaks.addLine(to: CGPoint(x: -40, y: -26))
                streaks.move(to: CGPoint(x: 18, y: -36))
                streaks.addLine(to: CGPoint(x: 14, y: -24))
                streaks.move(to: CGPoint(x: 28, y: -40))
                streaks.addLine(to: CGPoint(x: 30, y: -28))
                Art.stroke(&c, streaks, rock.opacity(0.55), width: 2.2)
                // The shaded right-hand faces of both summits.
                let faces = Art.svg("M-12,-62 C-4,-48 -6,-30 -16,0 L4,0 C4,-20 2,-34 1,-44 Z M24,-58 C32,-44 34,-26 30,0 L80,0 L40,-40 Z")
                Art.fill(&c, faces, ArtStyle.coolShade.opacity(0.16))
                if let glow {
                    let lit: Kit.Stops = [(glow.opacity(0.55), 0), (glow.opacity(0), 1)]
                    Art.fillLinear(&c, Art.rect(-90, -66, 180, 50), lit, from: CGPoint(x: -40, y: -66), to: CGPoint(x: -10, y: -16))
                }
                ArtStyle.tooth(&c, in: CGRect(x: -76, y: -64, width: 152, height: 64), seed: seed, color: Color.white, alpha: 0.08)
            }
            ArtStyle.rimEdge(&g, shape, bounds: CGRect(x: -74, y: -64, width: 150, height: 64), width: 1.6, alpha: 0.45)
        }
    }

    /// A grey, sea-worn drift log lying on the beach, centred on (x, y).
    static func driftLog(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, length: CGFloat, tilt: CGFloat) {
        let r: CGFloat = max(4, length * 0.07)
        Kit.shadow(&context, x, y + r * 0.8, width: length * 1.1, alpha: 0.22)
        Art.group(&context, x: x, y: y, rotate: tilt) { g in
            let half: CGFloat = length / 2
            let log = Art.rect(-half, -r, length, r * 2, radius: r)
            Kit.solid(&g, log, Art.color(0xB6AC9C), light: 0.3, shade: 0.3, rim: 1.4)
            var grain = Path()
            grain.move(to: CGPoint(x: -half * 0.8, y: -r * 0.3))
            grain.addQuadCurve(to: CGPoint(x: half * 0.6, y: -r * 0.2), control: CGPoint(x: 0, y: -r * 0.5))
            grain.move(to: CGPoint(x: -half * 0.5, y: r * 0.35))
            grain.addQuadCurve(to: CGPoint(x: half * 0.8, y: r * 0.3), control: CGPoint(x: half * 0.2, y: r * 0.5))
            Art.stroke(&g, grain, Art.color(0x8A8070, 0.7), width: 1.1)
            Kit.solid(&g, Art.ellipse(-half + r * 0.5, 0, r * 0.55, r * 0.95), Art.color(0xD6CCB8), light: 0.2, shade: 0.1)
            Art.stroke(&g, Art.ellipse(-half + r * 0.5, 0, r * 0.28, r * 0.5), Art.color(0xA89A84, 0.7), width: 0.9)
        }
    }

    /// A gull hanging in the wind, body centre at (x, y), facing left.
    static func gull(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat, glide: Bool) {
        Art.group(&context, x: x, y: y, scale: scale) { g in
            let wings: Path = glide
                ? Art.svg("M-2,0 C-8,-6 -16,-8 -26,-4 C-18,-3 -10,-1 -4,3 Z M3,0 C9,-7 18,-9 28,-6 C20,-4 11,-1 5,3 Z")
                : Art.svg("M-2,0 C-6,-10 -12,-15 -20,-16 C-14,-10 -9,-4 -4,3 Z M3,0 C8,-9 15,-13 22,-13 C16,-8 10,-3 5,3 Z")
            Art.fill(&g, wings, Art.color(0xC9D2D2))
            let tips: Path = glide
                ? Art.svg("M-26,-4 C-22,-5 -19,-5 -17,-4 C-20,-3 -23,-3 -26,-4 Z M28,-6 C24,-6 21,-6 19,-5 C22,-4 25,-4 28,-6 Z")
                : Art.svg("M-20,-16 C-18,-13 -17,-12 -15,-11 C-17,-14 -18,-15 -20,-16 Z M22,-13 C20,-11 19,-10 17,-9 C19,-11 20,-12 22,-13 Z")
            Art.fill(&g, tips, Art.color(0x3E4A4E))
            Kit.solid(&g, Art.ellipse(0, 1.5, 7, 2.8), Color.white, light: 0.1, shade: 0.25)
            Art.fill(&g, Art.circle(-6.5, 0, 2.4), Color.white)
            Art.fill(&g, Art.rect(-11, 0, 3.2, 1, radius: 0.5), Art.color(0xE8B23A))
        }
    }

    /// A bald eagle far off on the wing (a broad dark shape, white head and tail).
    static func eagle(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: y, scale: scale) { g in
            let wings = Art.svg("M0,0 C-8,-4 -18,-6 -30,-3 C-26,-1 -22,0 -20,1 C-14,2 -6,3 0,4 C6,3 14,2 20,1 C22,0 26,-1 30,-3 C18,-6 8,-4 0,0 Z")
            Art.fill(&g, wings, Art.color(0x3A2E28))
            Art.fill(&g, Art.ellipse(-1, 2, 4, 2.2), Art.color(0x3A2E28))
            Art.fill(&g, Art.circle(-5, 1, 1.8), Art.color(0xF4F0E6))
            Art.fill(&g, Art.svg("M3,2 L8,1 L8,4 Z"), Art.color(0xF4F0E6))
        }
    }
}

// MARK: - The bridge and the ship (today)

extension SistersArt {
    /// The green suspension bridge across the narrows: two towers, the main cable swooping
    /// between them, the side spans, the long viaduct to the north shore. All in the units of
    /// the caller; `top` is the top of the towers, `waterY` where their piers stand.
    static func bridge(
        _ context: inout GraphicsContext,
        south: CGFloat,
        north: CGFloat,
        towerA: CGFloat,
        towerB: CGFloat,
        deckY: CGFloat,
        top: CGFloat,
        waterY: CGFloat
    ) {
        let green: Color = Art.color(0x4E7E5C)
        let dark: Color = Art.color(0x2E5A44)
        let cableTop: CGFloat = top + 3
        // The north viaduct: slim piers under the deck.
        var piers = Path()
        var px: CGFloat = towerB + 46
        while px < north {
            piers.addPath(Art.rect(px - 1.5, deckY + 3, 3, max(2, waterY - deckY - 3)))
            px += 30
        }
        Art.fill(&context, piers, dark.opacity(0.7))
        // The deck and its railing.
        let deck = Art.rect(south, deckY, north - south, 4.5)
        Kit.solid(&context, deck, green, light: 0.2, shade: 0.3)
        Art.stroke(&context, Art.line(south, deckY - 2, north, deckY - 2), Art.color(0x8FB894, 0.7), width: 0.9)
        // The cables and their hangers.
        let mainC: CGFloat = 2 * (deckY - 4) - cableTop
        let side: CGFloat = towerA - south
        let northEnd: CGFloat = towerB + side
        var cables = Path()
        cables.move(to: CGPoint(x: south, y: deckY - 1))
        cables.addQuadCurve(to: CGPoint(x: towerA, y: cableTop), control: CGPoint(x: south + side * 0.5, y: deckY - 6))
        cables.addQuadCurve(to: CGPoint(x: towerB, y: cableTop), control: CGPoint(x: (towerA + towerB) / 2, y: mainC))
        cables.addQuadCurve(to: CGPoint(x: northEnd, y: deckY - 1), control: CGPoint(x: towerB + side * 0.5, y: deckY - 6))
        var hangers = Path()
        let span: CGFloat = towerB - towerA
        let count: Int = max(2, Int(span / 8))
        for i in 1..<count {
            let t: CGFloat = CGFloat(i) / CGFloat(count)
            let hx: CGFloat = towerA + span * t
            let hy: CGFloat = quadY(cableTop, mainC, cableTop, t)
            hangers.move(to: CGPoint(x: hx, y: hy))
            hangers.addLine(to: CGPoint(x: hx, y: deckY))
        }
        let sideCount: Int = max(2, Int(side / 8))
        for i in 1..<sideCount {
            let t: CGFloat = CGFloat(i) / CGFloat(sideCount)
            let hy: CGFloat = quadY(deckY - 1, deckY - 6, cableTop, t)
            let sx: CGFloat = south + side * t
            let nx: CGFloat = northEnd - side * t
            hangers.move(to: CGPoint(x: sx, y: hy))
            hangers.addLine(to: CGPoint(x: sx, y: deckY))
            hangers.move(to: CGPoint(x: nx, y: hy))
            hangers.addLine(to: CGPoint(x: nx, y: deckY))
        }
        Art.stroke(&context, hangers, dark.opacity(0.5), width: 0.6)
        Art.stroke(&context, cables, dark, width: 1.7)
        bridgeTower(&context, x: towerA, top: top, deckY: deckY, waterY: waterY)
        bridgeTower(&context, x: towerB, top: top, deckY: deckY, waterY: waterY)
    }

    /// One tower: two slim green legs with cross struts, on a grey pier in the water.
    static func bridgeTower(_ context: inout GraphicsContext, x: CGFloat, top: CGFloat, deckY: CGFloat, waterY: CGFloat) {
        let green: Color = Art.color(0x4E7E5C)
        let tall: CGFloat = max(4, waterY - top)
        Kit.solid(&context, Art.rect(x - 7, waterY - 4, 14, 6, radius: 1.5), Art.color(0x8E918A), light: 0.2, shade: 0.3)
        Kit.solid(&context, Art.rect(x - 5.2, top, 3.8, tall, radius: 0.8), green, light: 0.3, shade: 0.2)
        Kit.solid(&context, Art.rect(x + 1.4, top + 1, 3.8, tall - 1, radius: 0.8), Art.color(0x3F6E4E), light: 0.1, shade: 0.3)
        var struts = Path()
        struts.addPath(Art.rect(x - 5, top + 4, 10, 2.6))
        struts.addPath(Art.rect(x - 5, top + (deckY - top) * 0.48, 10, 2))
        struts.addPath(Art.rect(x - 5, deckY + 6, 10, 2.2))
        Art.fill(&context, struts, Art.color(0x3A6A4A))
        Art.fill(&context, Art.rect(x - 5.2, top, 1.2, tall), Art.color(0xA9D0A8, 0.5))
    }

    /// A container ship heading LEFT, stacked with steel boxes, its wake fanning behind it.
    /// `x` is the middle of the hull, `waterY` its waterline.
    static func containerShip(_ context: inout GraphicsContext, x: CGFloat, waterY: CGFloat, length L: CGFloat) {
        Art.group(&context, x: x, y: waterY, scale: L / 100) { g in
            var wake = Path()
            wake.move(to: CGPoint(x: 50, y: 0.5))
            wake.addQuadCurve(to: CGPoint(x: 140, y: -1.5), control: CGPoint(x: 96, y: -0.5))
            wake.move(to: CGPoint(x: 50, y: 2))
            wake.addQuadCurve(to: CGPoint(x: 140, y: 9), control: CGPoint(x: 96, y: 4))
            wake.move(to: CGPoint(x: 60, y: 1.4))
            wake.addQuadCurve(to: CGPoint(x: 120, y: 3.6), control: CGPoint(x: 90, y: 2))
            Art.stroke(&g, wake, Color.white.opacity(0.6), width: 1.3)
            Art.stroke(&g, Art.svg("M-52,1 Q-46,-1 -40,2"), Color.white.opacity(0.7), width: 1.2)
            Art.fill(&g, Art.rect(-46, 2, 94, 3), ArtStyle.coolShade.opacity(0.14))
            let colors: [UInt32] = [0xB8432E, 0x2F5E8E, 0xC07A3A, 0x3E7A8A, 0xD8D0C0]
            for tier in 0..<2 {
                for i in 0..<11 {
                    let bx: CGFloat = -40 + CGFloat(i) * 6.8
                    let by: CGFloat = -13.4 - CGFloat(tier) * 4.9
                    let pick: Int = (i * 3 + tier * 2) % colors.count
                    Art.fill(&g, Art.rect(bx, by, 6.4, 4.7, radius: 0.4), Art.color(colors[pick]))
                }
            }
            Art.fill(&g, Art.rect(-40, -18.3, 75, 1.2), Color.white.opacity(0.25))
            let hull = Art.svg("M-50,-8.5 L44,-8.5 C47,-8.5 50,-7 50,-5 L48,2 L-40,2 C-44,2 -47,-3 -50,-8.5 Z")
            Kit.solid(&g, hull, Art.color(0x2E3A48), light: 0.22, shade: 0.2)
            Art.clipped(&g, to: hull) { c in
                Art.fill(&c, Art.rect(-60, -0.6, 120, 4), Art.color(0x8A3A2A))
            }
            Kit.solid(&g, Art.rect(36, -24, 9, 15.6, radius: 0.6), Art.color(0xE6E4DE), light: 0.2, shade: 0.25)
            Art.fill(&g, Art.rect(36.8, -21.6, 7.4, 1.2), Art.color(0x2E3A48, 0.8))
            Art.fill(&g, Art.rect(39, -28, 4, 4), Art.color(0x2E3A48))
        }
    }
}

// MARK: - The village and its canoes (long ago)

extension SistersArt {
    /// One passenger of a canoe: where they sit (−40…40 along a 100-long hull), what they wear,
    /// and who they are (0 a paddler, 1 an elder or a mother wrapped in a blanket, 2 a child
    /// leaning over the side).
    typealias Rider = (x: CGFloat, cloth: UInt32, kind: Int)

    /// A long dugout canoe of one cedar log, bow raised to the LEFT, drawn about its middle at
    /// the waterline (or, `beached`, on the ground). Riders sit in it; `paddlesUp` lifts every
    /// paddle (the arrival).
    static func canoe(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        waterY: CGFloat,
        length L: CGFloat,
        riders: [Rider],
        paddlesUp: Bool,
        beached: Bool
    ) {
        if beached {
            Kit.shadow(&context, cx, waterY + L * 0.02, width: L * 0.95, alpha: 0.24)
        }
        Art.group(&context, x: cx, y: waterY, scale: L / 100) { g in
            let inside = Art.svg("M-41,-4.4 C-20,-7.4 20,-7.4 43,-5 C20,-3.4 -20,-3.4 -41,-4.4 Z")
            Art.fill(&g, inside, Art.color(cedarDark))
            for rider in riders {
                canoeRider(&g, rider, paddleUp: paddlesUp)
            }
            let hull = Art.svg("M-50,-11.5 C-48,-9 -45,-6.4 -39,-4.6 L38,-4.6 C42,-4.6 46,-6.4 49,-8.6 C48,-4 44,0 38,2.2 L-32,2.2 C-40,2.2 -46,-4 -50,-11.5 Z")
            Kit.solid(&g, hull, Art.color(cedar), light: 0.3, shade: 0.3)
            let gunwale = Art.svg("M-49,-10.4 C-46,-7.6 -43,-5.6 -38,-4.4 L39,-4.4 C43,-4.4 46,-6 48.4,-8")
            Art.stroke(&g, gunwale, Art.color(0xE08A5A, 0.75), width: 0.9)
            Art.stroke(&g, Art.svg("M-34,0.6 L36,0.6"), Art.color(cedarDark, 0.5), width: 0.7)
            if !beached {
                Art.fill(&g, Art.rect(-40, 0.4, 80, 2.4), Art.color(0x2F5A55, 0.45))
                Kit.ripples(&g, -2, 1.6, 96, count: 2, color: Color.white, opacity: 0.45)
            }
        }
    }

    /// One rider, in hull units (the gunwale at y −4.5).
    static func canoeRider(_ context: inout GraphicsContext, _ r: Rider, paddleUp: Bool) {
        let child: Bool = r.kind == 2
        let k: CGFloat = child ? 0.7 : 1
        Art.group(&context, x: r.x, y: -4.5, scale: k) { g in
            let lean: CGFloat = child ? -0.5 : 0
            Art.group(&g, rotate: lean) { b in
                let torso = Art.svg("M-4.6,1 C-4.8,-4 -4.4,-8 -2.6,-9.4 L2.6,-9.4 C4.4,-8 4.8,-4 4.6,1 Z")
                Kit.solid(&b, torso, Art.color(r.cloth), light: 0.25, shade: 0.25)
                Art.fill(&b, Art.circle(0, -12.6, 3.2), Art.color(skin))
                Art.fill(&b, Art.svg("M-3.4,-12.4 C-3.6,-15.6 -1.8,-16.2 0,-16.2 C2,-16.2 3.6,-15.4 3.4,-12 C2.4,-13.8 -2,-14 -3.4,-12.4 Z"), Art.color(hairDark))
                if r.kind == 1 {
                    Art.fill(&b, Art.svg("M-5.2,1 C-5.6,-4 -5,-8.6 -2.8,-10 L2.8,-10 C5,-8.6 5.6,-4 5.2,1 Z"), Art.color(wool))
                    Art.stroke(&b, Art.svg("M-4,-6 L4,-4"), Art.color(0xC9BCA0), width: 0.6)
                }
            }
            if r.kind == 0 {
                let shaft: Path = paddleUp ? Art.svg("M-6,-22 L3,-4") : Art.svg("M-8,-14 L7,8")
                Art.stroke(&g, shaft, Art.color(plankDark), width: 1)
                let blade: Path = paddleUp
                    ? Art.svg("M-6,-22 C-8.6,-24 -9.4,-27 -9,-30 C-6.6,-28 -5,-25.4 -6,-22 Z")
                    : Art.svg("M7,8 C8.6,10 9.4,13 9,15 C6.6,13.6 5.4,11 7,8 Z")
                Art.fill(&g, blade, Art.color(plank))
                Art.stroke(&g, Art.svg("M-2.6,-8 L-3,-12"), Art.color(r.cloth), width: 1.8)
            }
        }
    }

    /// A long Coast Salish plank house seen from the water and a little to the left: the tall
    /// front of wide horizontal cedar planks between posts, the single-slope roof falling away
    /// toward the hills, a low door, smoke between the roof planks.
    static func plankHouse(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width w: CGFloat, height h: CGFloat, depth d: CGFloat) {
        let half: CGFloat = w / 2
        let backH: CGFloat = h * 0.62
        let rise: CGFloat = d * 0.22
        Kit.shadow(&context, x + d * 0.4, baseY, width: w + d, alpha: 0.24)
        // The roof, seen falling away over the side wall.
        let roof = Art.polygon([
            Kit.pt(x - half - 4, baseY - h - 3), Kit.pt(x + half + 4, baseY - h - 3),
            Kit.pt(x + half + d + 4, baseY - backH - rise - 2), Kit.pt(x - half + d, baseY - backH - rise - 2)
        ])
        Kit.solid(&context, roof, Art.color(0x8A7A6C), light: 0.3, shade: 0.2)
        // The side wall: tall at the front, low at the back.
        let sideWall = Art.polygon([
            Kit.pt(x + half, baseY), Kit.pt(x + half, baseY - h),
            Kit.pt(x + half + d, baseY - backH - rise), Kit.pt(x + half + d, baseY - rise)
        ])
        Art.fill(&context, sideWall, Art.color(plankDark))
        Art.fill(&context, sideWall, ArtStyle.coolShade.opacity(0.18))
        // The front.
        let front = Art.rect(x - half, baseY - h, w, h)
        Kit.solid(&context, front, Art.color(plank), light: 0.22, shade: 0.24)
        var seams = Path()
        for i in 1..<7 {
            let sy: CGFloat = baseY - h * CGFloat(i) / 7
            seams.move(to: CGPoint(x: x - half, y: sy))
            seams.addLine(to: CGPoint(x: x + half, y: sy))
        }
        Art.stroke(&context, seams, Art.color(plankDark, 0.6), width: 0.9)
        var posts = Path()
        let postXs: [CGFloat] = [x - half, x - half * 0.34, x + half * 0.34, x + half - 4]
        for postX in postXs {
            posts.addPath(Art.rect(postX, baseY - h - 1, 4, h + 1))
        }
        Art.fill(&context, posts, Art.color(0x6A4432))
        Art.fill(&context, Art.rect(x - half * 0.16, baseY - h * 0.42, w * 0.11, h * 0.42), Art.color(0x2A1E1A))
        Art.fill(&context, Art.rect(x - half - 4, baseY - h - 4, w + 8, 3), Art.color(0x6E5A4E))
    }

    /// Smoke rising slowly from a roof and drifting to the right.
    static func smoke(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, height: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed)
        Art.blurred(&context, radius: 4, opacity: 0.5) { g in
            for i in 0..<6 {
                let t: CGFloat = CGFloat(i) / 5
                let drift: CGFloat = t * t * height * 0.5 + Kit.rnd(&random) * 4
                let r: CGFloat = 4 + t * height * 0.12
                Art.fill(&g, Art.circle(x + drift, y - t * height, r), Art.color(0xD6DCD8))
            }
        }
    }
}

// MARK: - The people

extension SistersArt {
    /// The elder sister: long straight hair worn loose.
    static func elderSisterLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: skin, hair: hairDark, hairStyle: .long, garment: .dress, cloth: 0x9A7652, trim: barkDark, legs: skin, showsEyeWhite: false)
    }

    /// The younger sister: her hair tied back.
    static func youngerSisterLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xB27454, hair: hairDark, hairStyle: .bun, garment: .dress, cloth: 0x8C6A4A, trim: barkDark, legs: 0xB27454, showsEyeWhite: false)
    }

    /// The chief: grey hair, a cedar-bark garment under a plain wool blanket; no headdress.
    static func chiefLook() -> Kit.Person {
        Kit.Person(age: .elder, skin: 0xA86E4E, hair: hairGrey, hairStyle: .long, garment: .robe, cloth: bark, trim: barkDark, legs: 0xA86E4E, showsEyeWhite: false)
    }

    /// A short cape of woven cedar bark over the shoulders, in an adult's units (the neck at
    /// about y −106): twined rows and a soft fringe.
    static func barkCape(_ context: inout GraphicsContext, tone: UInt32, mirrored: Bool) {
        let cape = Art.svg("M-21,-107 C-10,-109 10,-109 21,-107 C28,-103 31,-95 31,-86 L29,-72 C14,-67 -14,-67 -29,-72 L-31,-86 C-31,-95 -28,-103 -21,-107 Z")
        let box = CGRect(x: -31, y: -109, width: 62, height: 42)
        Kit.personLit(&context, cape, Art.color(tone), bounds: box, mirrored: mirrored, light: 0.26, shade: 0.24)
        var rows = Path()
        let ys: [CGFloat] = [-100, -93, -86, -79]
        for y in ys {
            rows.move(to: CGPoint(x: -30, y: y + 2))
            rows.addQuadCurve(to: CGPoint(x: 30, y: y + 2), control: CGPoint(x: 0, y: y + 5))
        }
        Art.stroke(&context, rows, Kit.personTone(tone, 0.74), width: 0.9, dash: [2.2, 1.6])
        var fringe = Path()
        var fx: CGFloat = -27
        while fx <= 27 {
            fringe.move(to: CGPoint(x: fx, y: -71.5))
            fringe.addLine(to: CGPoint(x: fx + 0.6, y: -66.5))
            fx += 3.4
        }
        Art.stroke(&context, fringe, Kit.personTone(tone, 0.8), width: 1.1)
    }

    /// The two sisters side by side, shoulders touching, holding hands; origin on the ground
    /// between them, facing LEFT (the elder, a little taller, in front on the left).
    static func sisters(_ context: inout GraphicsContext, look: CGPoint = .zero, mouth: Kit.Mouth = .smile) {
        let elder = elderSisterLook()
        let younger = youngerSisterLook()
        Kit.shadow(&context, 0, 0, width: 92, alpha: 0.26)
        Art.group(&context, x: 19, y: 0, scale: 0.93) { g in
            Kit.person(&g, younger, pose: .stand, look: look, mouth: mouth)
            barkCape(&g, tone: bark, mirrored: false)
        }
        // The joined hands between them.
        Art.stroke(&context, Art.svg("M-6,-84 Q-3,-74 1,-66"), Art.color(elder.cloth), width: 6.5)
        Art.stroke(&context, Art.svg("M12,-80 Q8,-71 3,-66"), Art.color(younger.cloth), width: 6)
        Art.group(&context, x: -16, y: 0, scale: 0.98) { g in
            Kit.person(&g, elder, pose: .stand, look: look, mouth: mouth)
            barkCape(&g, tone: 0xA88456, mirrored: false)
        }
        Kit.solid(&context, Art.ellipse(2, -65, 5.6, 4.8), Art.color(skin), light: 0.3, shade: 0.2)
    }

    /// The chief standing, wrapped in his cream wool blanket; origin at his feet, facing LEFT
    /// unless `mirrored` (the caller flips x).
    static func chief(_ context: inout GraphicsContext, look: CGPoint = .zero, mouth: Kit.Mouth = .flat, mirrored: Bool = false) {
        let p = chiefLook()
        Kit.person(&context, p, pose: .stand, look: look, mouth: mouth, mirrored: mirrored)
        let blanket = Art.svg("M-27,-99 C-15,-103 5,-103 17,-99 C24,-95 27,-86 27,-74 L25,-44 C7,-40 -15,-40 -31,-44 L-33,-74 C-33,-87 -33,-95 -27,-99 Z")
        let box = CGRect(x: -33, y: -103, width: 60, height: 63)
        Kit.personLit(&context, blanket, Art.color(wool), bounds: box, mirrored: mirrored, light: 0.26, shade: 0.26)
        var folds = Path()
        folds.move(to: CGPoint(x: -24, y: -96))
        folds.addQuadCurve(to: CGPoint(x: 18, y: -60), control: CGPoint(x: -4, y: -84))
        folds.move(to: CGPoint(x: -28, y: -70))
        folds.addQuadCurve(to: CGPoint(x: -18, y: -46), control: CGPoint(x: -26, y: -56))
        Art.stroke(&context, folds, Art.color(0xC4B696), width: 1.2)
        Art.stroke(&context, Art.svg("M-31,-48.5 C-15,-45 7,-45 25,-48.5"), Art.color(0x9A7E5A, 0.8), width: 2.2)
    }

    /// One sister seen from behind (for the cover): long hair down her back, or tied back,
    /// the cape, the skirt, bare feet. Origin at her feet; an adult's units.
    static func sisterBack(_ context: inout GraphicsContext, loose: Bool, cloth: UInt32, cape: UInt32) {
        let legs = Art.svg("M-8,-32 L-8,-2 M7,-32 L7,-2")
        Art.stroke(&context, legs, Art.color(skin), width: 7)
        Art.stroke(&context, Art.svg("M-11,-1 L-5,-1 M4,-1 L10,-1"), Art.color(0x9A6446), width: 4)
        let skirt = Art.svg("M-20,-88 L20,-88 C23,-70 27,-46 28,-26 C10,-22 -10,-22 -28,-26 C-27,-46 -23,-70 -20,-88 Z")
        Kit.solid(&context, skirt, Art.color(cloth), light: 0.24, shade: 0.24)
        Art.stroke(&context, Art.svg("M-6,-84 L-8,-26 M8,-84 L10,-26"), Kit.personTone(cloth, 0.8), width: 1)
        let arms = Art.svg("M-27,-98 C-32,-84 -33,-72 -31,-60 M27,-98 C32,-84 33,-72 31,-60")
        Art.stroke(&context, arms, Art.color(cloth), width: 9)
        let back = Art.svg("M-21,-110 C-10,-113 10,-113 21,-110 C29,-106 32,-96 32,-86 L30,-72 C14,-67 -14,-67 -30,-72 L-32,-86 C-32,-96 -29,-106 -21,-110 Z")
        Kit.solid(&context, back, Art.color(cape), light: 0.26, shade: 0.24)
        Art.stroke(&context, Art.svg("M-31,-96 Q0,-90 31,-96 M-31,-86 Q0,-80 31,-86 M-30,-77 Q0,-71 30,-77"), Kit.personTone(cape, 0.74), width: 0.9, dash: [2.2, 1.6])
        Art.fill(&context, Art.ellipse(-27, -138, 3.4, 6), Art.color(skin))
        Art.fill(&context, Art.ellipse(27, -138, 3.4, 6), Art.color(skin))
        let head = Art.svg("M0,-168 C16,-168 27,-157 27,-140 C27,-126 20,-114 0,-112 C-20,-114 -27,-126 -27,-140 C-27,-157 -16,-168 0,-168 Z")
        Kit.solid(&context, head, Art.color(hairDark), light: 0.18, shade: 0.2)
        if loose {
            let fall = Art.svg("M-24,-130 C-26,-112 -24,-94 -18,-80 L18,-80 C24,-94 26,-112 24,-130 C14,-120 -14,-120 -24,-130 Z")
            Kit.solid(&context, fall, Art.color(hairDark), light: 0.16, shade: 0.2)
            Art.stroke(&context, Art.svg("M-12,-118 C-13,-104 -12,-92 -10,-82 M4,-118 C5,-104 4,-92 5,-82"), Art.color(0x3A3236), width: 1)
        } else {
            Kit.solid(&context, Art.circle(0, -140, 9), Art.color(0x2A2428), light: 0.2, shade: 0.2)
            Art.stroke(&context, Art.svg("M0,-132 C1,-122 0,-112 -1,-104"), Art.color(hairDark), width: 5)
        }
        Art.stroke(&context, Art.svg("M-20,-158 C-10,-163 8,-163 18,-158"), Art.color(0x4A4246, 0.7), width: 1.2)
    }

    /// The two sisters from behind, hand in hand; origin on the ground between them.
    static func sistersBack(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 0, 0, width: 96, alpha: 0.26)
        Art.group(&context, x: -20, y: 0, scale: 1) { g in
            sisterBack(&g, loose: true, cloth: 0x9A7652, cape: 0xA88456)
        }
        Art.group(&context, x: 22, y: 0, scale: 0.93) { g in
            sisterBack(&g, loose: false, cloth: 0x8C6A4A, cape: bark)
        }
        Art.stroke(&context, Art.svg("M8,-62 Q2,-58 -2,-60"), Art.color(skin), width: 5)
        Kit.solid(&context, Art.ellipse(2, -60, 5, 4.4), Art.color(skin), light: 0.3, shade: 0.2)
    }

    /// The people of the village waiting on the beach (0 a warrior with empty hands, 1 a woman
    /// in a cedar-bark cape, 2 an old man in a grey wool blanket).
    static func villagerLook(_ kind: Int) -> Kit.Person {
        switch kind {
        case 1:
            return Kit.Person(age: .adult, skin: 0xB07252, hair: hairDark, hairStyle: .long, garment: .dress, cloth: bark, trim: barkDark, legs: 0xB07252, showsEyeWhite: false)
        case 2:
            return Kit.Person(age: .elder, skin: 0xA06A4C, hair: 0xA8A49C, hairStyle: .short, garment: .robe, cloth: 0x9A968C, trim: 0x7A766C, legs: 0xA06A4C, showsEyeWhite: false)
        default:
            return Kit.Person(age: .adult, skin: 0xA86E4E, hair: hairDark, hairStyle: .bun, garment: .kilt, cloth: 0x8C6A4A, trim: barkDark, legs: 0xA86E4E, showsEyeWhite: false)
        }
    }

    /// A salmon split open and held flat between cedar sticks, roasting beside a fire; origin
    /// where the stake enters the ground. About 70 tall at scale 1.
    static func salmonStake(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: baseY, scale: scale) { g in
            Art.stroke(&g, Art.svg("M0,0 L4,-70"), Art.color(plankDark), width: 3)
            let fish = Art.svg("M3,-58 C11,-56 13,-46 12,-36 C11,-28 8,-22 4,-18 C0,-22 -4,-28 -5,-36 C-6,-46 -4,-56 3,-58 Z")
            Kit.solid(&g, fish, Art.color(0xE0704A), light: 0.3, shade: 0.22)
            Art.stroke(&g, fish, Art.color(0xF2B48A, 0.8), width: 1.4)
            Art.stroke(&g, Art.svg("M-7,-50 L14,-50 M-8,-32 L13,-32"), Art.color(barkDark), width: 1.6)
            Art.stroke(&g, Art.svg("M3.5,-55 L3.5,-21"), Art.color(0xC85A3A, 0.6), width: 0.8)
        }
    }
}
