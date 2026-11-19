import SwiftUI
import OmramoCore

// "The Fire-Bird and the Horse of Power": the tap-to-see pictures (432 × 404), the two
// character-card portraits (432 × 400), the four face chips (100 × 100) and the cover.
// Landmark pictures are drawn elsewhere.

extension FirebirdArt {
    // MARK: Tap pictures

    /// One tall dark spruce beside a white-barked birch on a mossy floor, night sky, stars.
    static func taigaPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let groundY: CGFloat = 300
        let sky: Kit.Stops = [(Art.color(0x070D18), 0), (Art.color(0x0B1424), 0.5), (Art.color(0x1A3030), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, groundY), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: groundY))
        Kit.stars(&context, width: w, maxY: 220, count: 46, seed: 51)
        Art.glow(&context, 300, 120, 160, Art.color(0x5A7090), alpha: 0.18)
        Kit.farTrees(&context, x0: -10, x1: 440, baseY: groundY - 4, height: 60, count: 24, color: Art.color(0x0E1C22), conifer: true, seed: 52)
        ArtStyle.atmosphere(&context, width: w, top: groundY - 70, bottom: groundY, color: Art.color(0x16263A), alpha: 0.4)
        let floor: Kit.Stops = [(Art.color(0x1E3A2A), 0), (Art.color(0x173126), 1)]
        Kit.ground(&context, width: w, top: groundY - 6, bottom: h, stops: floor, seed: 53)
        Kit.mound(&context, x0: 60, x1: 380, baseY: groundY + 10, height: 22, bottom: h, stops: Kit.stops(0x2A4A30, 0x173126))
        Kit.conifer(&context, x: 170, baseY: groundY + 4, height: 262, palette: Kit.greens(0x08160F, 0x10261C, 0x1A3A28, 0x2A5236, 0x5A7A4E), seed: 54)
        Kit.birch(&context, x: 282, baseY: groundY + 8, height: 210, palette: nightBirch(), seed: 55)
        Kit.shadow(&context, 170, groundY + 4, width: 90, alpha: 0.3)
        Kit.shadow(&context, 282, groundY + 8, width: 50, alpha: 0.3)
        Kit.grass(&context, in: CGRect(x: 40, y: groundY, width: 352, height: 40), count: 90, seed: 56, color: Art.color(0x3A6040), height: 7)
        Kit.grassTuft(&context, x: 120, baseY: groundY + 26, height: 30, color: 0x2E5A3A, seed: 57)
        Kit.grassTuft(&context, x: 330, baseY: groundY + 22, height: 26, color: 0x2E5A3A, seed: 58)
        Kit.rock(&context, cx: 224, baseY: groundY + 18, width: 40, height: 18, color: 0x4A5254, seed: 59)
        Kit.sink(&context, size, card: 0x173126)
    }

    /// An old crown of gold filigree with a rim of dark sable and a few stones, on a dark red
    /// cushion.
    static func crownPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let back: Kit.Stops = [(Art.color(0x2A0E0E), 0), (Art.color(0x4A1E1E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 200, 170, 220, Art.color(0xFFC96B), alpha: 0.22)
        let cushion: Path = Art.svg("M88,252 C80,232 110,222 216,222 C322,222 352,232 344,252 C352,274 326,292 216,292 C106,292 80,274 88,252Z")
        Kit.solid(&context, cushion, stops: Kit.stops(0xA03030, 0x7A2020, 0x4A1414), light: 0.3, shade: 0.34, rim: 2)
        Art.stroke(&context, Art.svg("M96,252 C140,262 292,262 336,252"), Art.color(0xD9A23A, 0.7), width: 2)
        var tassels = Path()
        tassels.addPath(Art.svg("M86,252 L78,282 L92,282Z"))
        tassels.addPath(Art.svg("M346,252 L340,282 L354,282Z"))
        Art.fill(&context, tassels, Art.color(0xD9A23A))
        ArtStyle.contactShadow(&context, 216, 240, 90, 10, alpha: 0.4)
        Art.group(&context, x: 216, y: 230, scale: 2.4) { c in
            crown(&c)
        }
        Kit.flecks(&context, in: CGRect(x: 110, y: 60, width: 220, height: 150), count: 8, seed: 61, color: Art.color(0xFFE6A0), radius: 0.6...1.4, glow: true)
        Kit.sink(&context, size, card: 0x4A1E1E)
    }

    /// One Fire-Bird in profile, the long tail curving below it, gold and orange on a black
    /// ground: in the spirit of a lacquer box, our own drawing.
    static func firebirdPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let black: Kit.Stops = [(Art.color(0x0E0806), 0), (Art.color(0x1A0E08), 0.7), (Art.color(0x4A2410), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), black, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        let gold: Color = Art.color(0xD9A23A, 0.75)
        Art.stroke(&context, Art.rect(22, 22, w - 44, h - 70, radius: 10), gold, width: 1.6)
        Art.stroke(&context, Art.rect(30, 30, w - 60, h - 86, radius: 7), Art.color(0xD9A23A, 0.35), width: 0.9)
        let curls: Path = Art.svg("M400,40 C380,46 372,60 378,74 C384,84 396,80 394,70 M40,330 C60,322 74,330 72,346 M392,330 C372,322 358,330 360,346 M380,60 q-14,6 -22,-4")
        Art.stroke(&context, curls, gold, width: 1.4)
        var leaves = Path()
        leaves.addPath(Art.svg("M384,94 C390,86 400,86 404,92 C398,98 390,98 384,94Z"))
        leaves.addPath(Art.svg("M54,312 C60,304 70,304 74,310 C68,316 60,316 54,312Z"))
        Art.fill(&context, leaves, gold)
        Art.group(&context, x: 140, y: 236, scale: 1.35) { b in
            firebird(&b, glow: 0.9, wingUp: true)
        }
        Kit.flecks(&context, in: CGRect(x: 80, y: 60, width: 300, height: 220), count: 14, seed: 62, color: Art.color(fireCore), radius: 0.6...1.6, glow: true)
        Kit.sink(&context, size, card: 0x4A2410)
    }

    /// A pale sand shore and a still grey sea under a light grey-blue midnight sky with one
    /// faint star.
    static func whiteSeaPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let horizon: CGFloat = 196
        let light = whiteNight()
        let sky: Kit.Stops = [(Art.color(0x2A3446), 0), (Art.color(0x46526A), 0.6), (Art.color(0x76808E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, horizon), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: horizon))
        ArtStyle.horizonGlow(&context, width: w, y: horizon, rise: 60, color: Art.color(0xA8AEB8), alpha: 0.4)
        Art.glow(&context, 300, 70, 12, Art.color(0xF2EEE2), alpha: 0.4)
        Art.fill(&context, Art.circle(300, 70, 1.8), Art.color(0xF2EEE2, 0.9))
        Kit.cloud(&context, 120, 120, scale: 1.2, color: Art.color(0x5A6476, 0.45))
        let far: Path = Kit.ridge(width: 140, y: horizon - 6, amp: 10, seed: 63, bottom: horizon + 2, x0: 292)
        Art.fill(&context, far, light.far)
        let sea: Kit.Stops = [(Art.color(0x4A5466), 0), (Art.color(0x2A3446), 0.6), (Art.color(0x1C2638), 1)]
        Kit.water(&context, width: w, top: horizon, bottom: h, stops: sea, light: light, ripples: 30, seed: 64)
        Kit.glints(&context, x: 300, top: horizon, depth: 90, color: Art.color(0xC8CCD4), count: 18, seed: 65)
        var sand = Path()
        sand.move(to: CGPoint(x: 0, y: 252))
        sand.addQuadCurve(to: CGPoint(x: w, y: 300), control: CGPoint(x: 220, y: 240))
        sand.addLine(to: CGPoint(x: w, y: h))
        sand.addLine(to: CGPoint(x: 0, y: h))
        sand.closeSubpath()
        Kit.solid(&context, sand, stops: Kit.stops(0xC8BEA8, 0x9A907E, 0x6A6458), light: 0.2, shade: 0.24)
        var foam = Path()
        foam.move(to: CGPoint(x: 0, y: 252))
        foam.addQuadCurve(to: CGPoint(x: w, y: 300), control: CGPoint(x: 220, y: 240))
        Art.stroke(&context, foam, Art.color(0xE6E2D6, 0.5), width: 2)
        Kit.rock(&context, cx: 360, baseY: 300, width: 56, height: 28, color: 0x4A5058, seed: 66)
        Kit.pebbles(&context, in: CGRect(x: 60, y: 272, width: 260, height: 30), count: 10, seed: 67, color: 0x8A8478)
        Kit.sink(&context, size, card: 0x22324A)
    }
}

// MARK: - Portraits and face chips

extension FirebirdArt {
    /// Dark spruce tops behind a portrait, low and quiet.
    static func portraitForest(_ g: inout GraphicsContext, _ size: CGSize, color: UInt32) {
        Kit.farTrees(&g, x0: -10, x1: size.width + 10, baseY: size.height, height: 150, count: 12, color: Art.color(color, 0.8), conifer: true, seed: 71)
        Kit.farTrees(&g, x0: -10, x1: size.width + 10, baseY: size.height + 20, height: 220, count: 6, color: Art.color(color), conifer: true, seed: 72)
    }

    /// The archer half-figure: red-brown kaftan, fur-rimmed cap, bow over one shoulder,
    /// looking down at the feather glowing in his hands; dark spruces behind.
    static func archerPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x7A3A22, bottom: 0x1A1210, halo: 0xFFC978, rays: false) { g in
            portraitForest(&g, size, color: 0x140E0C)
            let p = archerLook()
            Art.group(&g, x: 216, y: 142, scale: 2.2) { b in
                let bow: Path = Art.svg("M34,-30 C64,-10 70,40 62,80 C58,104 60,128 70,150")
                Art.stroke(&b, bow, Art.color(0x4A2C18), width: 4)
                Art.stroke(&b, bow, Art.color(0x8A5A30), width: 1.6)
                Kit.bust(&b, p, look: CGPoint(x: 0, y: 0.8), mouth: .smile)
                archerCapRim(&b)
                Art.stroke(&b, Art.svg("M-60,128 L60,128"), Art.color(p.trim), width: 6, cap: .butt)
                Art.glow(&b, 0, 30, 46, Art.color(fireAmber), alpha: 0.32)
            }
            Art.group(&g, x: 216, y: 366, scale: 1.3) { f in
                feather(&f, glow: 0.9)
            }
            var hands = Path()
            hands.addPath(Art.ellipse(170, 378, 20, 13))
            hands.addPath(Art.ellipse(262, 378, 20, 13))
            Kit.solid(&g, hands, Art.color(0xE6B08A), light: 0.24, shade: 0.24)
            Art.glow(&g, 216, 372, 60, Art.color(fireCore), alpha: 0.3)
        }
    }

    /// The great dark horse: head and neck, long mane, ears pricked, one side lit faintly
    /// gold; night forest behind.
    static func horsePortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x2E3B52, bottom: 0x0C121E, halo: 0xE8D2A8, rays: false) { g in
            portraitForest(&g, size, color: 0x0A1018)
            Art.glow(&g, 90, 330, 180, Art.color(fireAmber), alpha: 0.2)
            Art.group(&g, x: 430, y: 470, scale: 1.55) { h in
                horse(&h, bend: 0, saddled: false, warm: CGPoint(x: -190, y: -150), warmAlpha: 0.4)
            }
        }
    }

    /// The archer's face chip.
    static func archerFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xB2442A) { g in
            Art.group(&g, x: 0, y: 8, scale: 1.2) { f in
                Kit.personHead(&f, archerLook(), look: CGPoint(x: -0.1, y: 0), mouth: .smile)
                archerCapRim(&f)
            }
        }
    }

    /// The horse's face chip: his head in profile, the mane falling, a gold edge of light.
    static func horseFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0x3A4A6A) { g in
            Art.group(&g, x: 126, y: 202, scale: 0.92) { h in
                horse(&h, bend: 0, saddled: false, warm: CGPoint(x: -170, y: -210), warmAlpha: 0.35)
            }
        }
    }

    /// Vasilissa's face chip: braid, tall embroidered headdress.
    static func vasilissaFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let p = vasilissaLook()
        Kit.faceChip(&context, size, background: 0x5E4A8A) { g in
            Art.group(&g, x: 0, y: 14, scale: 0.98) { f in
                braid(&f, p.hair, length: 4)
                Kit.personHead(&f, p, look: CGPoint(x: -0.1, y: 0), mouth: .smile)
                kokoshnik(&f)
            }
        }
    }

    /// The old tsar's face chip: grey beard, gold crown on its sable rim.
    static func tsarFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0x7A2E2E) { g in
            Art.group(&g, x: 0, y: 14, scale: 0.98) { f in
                Kit.personHead(&f, tsarLook(), look: CGPoint(x: -0.2, y: 0), mouth: .oh)
                Art.group(&f, x: 0, y: -22, scale: 0.72) { c in
                    crown(&c)
                }
            }
        }
    }
}

// MARK: - Cover

extension FirebirdArt {
    /// Night in the forest clearing: the huge dark horse with one hoof gently on the wing of
    /// the glowing Fire-Bird, the archer beside them reaching out, the bird's light filling
    /// the clearing and the spruces round it, stars above.
    static func coverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size, wash: 0.03, vignette: 0.18) { g, frame in
            let hd: CGFloat = frame.hd
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let sky: Kit.Stops = [(Art.color(0x060B16), 0), (Art.color(0x0B1424), 0.6), (Art.color(0x1E3040), 1)]
            Art.fillLinear(&g, Art.rect(0, 0, 240, H), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
            Kit.stars(&g, width: 240, maxY: H - 30, count: 40, seed: 81)
            Kit.farTrees(&g, x0: -10, x1: 250, baseY: H + 2, height: 40 * k, count: 22, color: Art.color(0x0E1C26), conifer: true, seed: 82)
            let floor: Kit.Stops = [(Art.color(0x1E2E20), 0), (Art.color(0x0A130E), 1)]
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: floor, seed: 83)
            let birdX: CGFloat = 120 - 20 * k
            let footY: CGFloat = H + 20 * k
            Art.glow(&g, birdX + 10 * k, footY - 20 * k, 150 * k, Art.color(fireAmber), alpha: 0.42)
            Kit.conifer(&g, x: 14, baseY: H + 30 * k, height: hd * 0.9, palette: litSpruce(), seed: 84)
            Kit.conifer(&g, x: 230, baseY: H + 34 * k, height: hd * 0.95, palette: litSpruce(), seed: 85)
            Kit.conifer(&g, x: 60, baseY: H + 4, height: 90 * k, palette: nightSpruce(), seed: 86)
            let sb: CGFloat = 0.42 * k
            Art.group(&g, x: birdX, y: footY, scale: sb) { b in
                firebird(&b, glow: 1, wingUp: false)
                let spread: Path = Art.svg("M8,-30 C28,-24 46,-12 64,-2 C50,2 34,0 22,-8 C14,-14 8,-20 2,-26Z")
                Kit.solid(&b, spread, stops: Kit.stops(fireGold, fireAmber, fireEmber), light: 0.26, shade: 0.12)
            }
            let hoofX: CGFloat = birdX + 58 * sb
            let sh: CGFloat = 0.4 * k
            Art.group(&g, x: hoofX + 121 * sh, y: footY, scale: sh) { h in
                horse(&h, bend: 14, liftHoof: true, saddled: true, warm: CGPoint(x: -150, y: -40), warmAlpha: 0.55)
            }
            Art.group(&g, x: 120 - 74 * k, y: footY + 2 * k, scale: 0.42 * k) { a in
                Kit.shadow(&a, 0, 0, width: 70)
                Art.group(&a, scaleX: -1) { m in
                    archer(&m, pose: .reach, look: CGPoint(x: -0.6, y: 0.6), mouth: .oh, mirrored: true)
                }
                Art.glow(&a, 10, -140, 40, Art.color(fireAmber), alpha: 0.35)
            }
            Kit.flecks(&g, in: CGRect(x: birdX - 30 * k, y: footY - 70 * k, width: 90 * k, height: 60 * k), count: 8, seed: 87, color: Art.color(fireCore), radius: 0.5...1.2, glow: true)
            Kit.grassTuft(&g, x: 200, baseY: hd + 4, height: 24 * k, color: 0x1E3A2A, seed: 88)
        }
    }
}
