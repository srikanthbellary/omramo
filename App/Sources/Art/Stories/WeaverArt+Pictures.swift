import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the two character-card portraits (432 × 400), the
// three face chips (100 × 100) and the cover of "The Herd Boy and the Weaving Maiden". Dark
// like the scenes: each picture follows its card's own deep colour, and the warm note is the
// rose-gold of the silk.

extension WeaverArt {
    // MARK: see-silk

    /// see-silk: one skein of shining rose-pink silk, loosely twisted, and below it three white
    /// silkworm cocoons resting on a single green mulberry leaf; a deep plum ground.
    static func silkPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let back: Kit.Stops = [(Art.color(0x2A1232), 0), (Art.color(0x3E1C46), 0.6), (Art.color(0x4A2350), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 236))
        // The plum cloth the things lie on.
        let tableTop: CGFloat = 226
        let table: Kit.Stops = [(Art.color(0x5E2C5E), 0), (Art.color(0x4A2350), 0.5), (Art.color(0x3A1A42), 1)]
        Art.fillLinear(&context, Art.rect(0, tableTop, w, h - tableTop), table, from: CGPoint(x: 0, y: tableTop), to: CGPoint(x: 0, y: h))
        Art.stroke(&context, Art.line(0, tableTop, w, tableTop), Art.color(0x8A4A7A, 0.5), width: 1.4)
        Art.glow(&context, 150, 120, 220, Art.color(0x8A4A86), alpha: 0.18)

        // The skein, glowing.
        Art.glow(&context, 216, 160, 170, Art.color(rose), alpha: 0.2)
        Art.glow(&context, 196, 150, 90, Art.color(gold), alpha: 0.12)
        Art.group(&context, x: 216, y: 160, rotate: -0.06, scale: 1.3) { s in
            skein(&s)
        }

        // The leaf, lying flat, and the cocoons on it.
        Kit.shadow(&context, 222, 286, width: 230, alpha: 0.34)
        Art.group(&context, x: 216, y: 262, rotate: -0.05, scale: 1.2) { l in
            mulberryLeaf(&l)
        }
        // A single fine thread runs from one cocoon up into the skein.
        var thread = Path()
        thread.move(to: CGPoint(x: 262, y: 246))
        thread.addCurve(to: CGPoint(x: 300, y: 184), control1: CGPoint(x: 286, y: 236), control2: CGPoint(x: 276, y: 204))
        Art.stroke(&context, thread, Art.color(rose, 0.5), width: 2.4)
        Art.stroke(&context, thread, Art.color(0xFFE6C8, 0.8), width: 0.9)
        let places: [(CGFloat, CGFloat, CGFloat)] = [(176, 254, -0.32), (220, 264, 0.1), (262, 248, 0.42)]
        for place in places {
            Kit.shadow(&context, place.0 + 2, place.1 + 10, width: 40, alpha: 0.3)
            Art.group(&context, x: place.0, y: place.1, rotate: place.2) { c in
                cocoon(&c)
            }
        }
        // A few soft motes of silk light.
        let motes: [(CGFloat, CGFloat, CGFloat)] = [(96, 100, 2.4), (340, 92, 2), (366, 196, 1.6), (70, 210, 1.6)]
        for mote in motes {
            Art.glow(&context, mote.0, mote.1, mote.2 * 4, Art.color(gold), alpha: 0.3)
            Art.fill(&context, Art.circle(mote.0, mote.1, mote.2 * 0.6), Art.color(0xFFE6C8, 0.8))
        }
        Kit.sink(&context, size, card: 0x4A2350)
    }

    /// A broad heart-shaped mulberry leaf lying flat, stem to the left, tip to the right; about
    /// 150 long and 56 deep, centred on the origin.
    static func mulberryLeaf(_ context: inout GraphicsContext) {
        Art.stroke(&context, Art.svg("M-62,0 C-70,2 -78,6 -84,4"), Art.color(0x3A6A3A), width: 3)
        let leaf: Path = Art.svg("M-60,0 C-76,-12 -68,-30 -34,-30 C2,-30 42,-18 78,2 C44,18 4,30 -34,30 C-68,30 -76,12 -60,0Z")
        Kit.solid(&context, leaf, Art.color(0x4E8A4A), light: 0.3, shade: 0.3, rim: 2)
        Art.clipped(&context, to: leaf) { g in
            // The serrated edge reads as a faint lighter rim; the veins in a paler green.
            let veins: Path = Art.svg("M-60,0 C-20,-2 30,0 76,2 M-34,-1 C-30,-12 -24,-20 -14,-26 M-10,-1 C-4,-10 4,-18 16,-23 M16,0 C22,-8 30,-14 40,-16 M-34,1 C-30,12 -24,20 -14,26 M-10,1 C-4,10 4,18 16,23 M16,1 C22,8 30,14 40,16")
            Art.stroke(&g, veins, Art.color(0x9ACB86, 0.7), width: 1.5)
            Art.fill(&g, Art.ellipse(-20, -16, 36, 9), Art.color(0xBFE6A8, 0.18))
        }
        Art.stroke(&context, Art.svg("M-34,30 C4,30 44,18 78,2"), Art.color(0x2E5A34, 0.6), width: ArtStyle.detailLine)
    }

    /// One silkworm cocoon, about 34 long and 20 deep, centred on the origin: pale, a little
    /// waisted, wound with fine silk.
    static func cocoon(_ context: inout GraphicsContext) {
        let shell: Path = Art.svg("M-17,0 C-17,-9 -9,-10 -4,-8 C-1,-7 1,-7 4,-8 C9,-10 17,-9 17,0 C17,9 9,10 4,8 C1,7 -1,7 -4,8 C-9,10 -17,9 -17,0Z")
        Kit.solid(&context, shell, Art.color(0xF4EEE2), light: 0.3, shade: 0.3)
        Art.clipped(&context, to: shell) { g in
            let wind: Path = Art.svg("M-14,-6 C-10,-2 -10,4 -14,7 M-8,-8 C-4,-3 -4,4 -8,8 M8,-8 C4,-3 4,4 8,8 M14,-6 C10,-2 10,4 14,7")
            Art.stroke(&g, wind, Art.color(0xC9BFAE, 0.7), width: 1)
            Art.fill(&g, Art.ellipse(-8, -5, 7, 2.6), Color.white.opacity(0.7))
        }
    }

    // MARK: see-silver-river

    /// see-silver-river: the Milky Way as one pale silver band of stars slanting across a dark
    /// blue sky, above a low black line of hills; no figures.
    static func silverRiverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let hills: CGFloat = 300
        let sky: Kit.Stops = [(Art.color(0x080B26), 0), (Art.color(0x0D1236), 0.45), (Art.color(0x1D2A63), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: hills))
        ArtStyle.horizonGlow(&context, width: w, y: hills, rise: 70, color: Art.color(0x3F5596), alpha: 0.4)
        Kit.stars(&context, width: w, maxY: hills - 10, count: 120, seed: 41)
        // The river of stars, from the upper right down toward the lower left.
        let p0 = CGPoint(x: 470, y: 18)
        let p1 = CGPoint(x: -40, y: 290)
        silverRiver(&context, from: p0, to: p1, width0: 150, width1: 100, count: 820, seed: 17, mist0: 0.17, mist1: 0.1)
        brightStar(&context, 318, 70, 4, color: 0xE6F0FF)
        brightStar(&context, 138, 250, 3.4, color: 0xFFF1D6)
        // The low black hills, with a few far trees along the crest.
        let far: Path = Kit.ridge(width: w, y: hills - 6, amp: 14, seed: 4, bottom: h + 4, step: 10)
        Art.fill(&context, far, Art.color(0x0E1432))
        Kit.farTrees(&context, x0: 230, x1: 420, baseY: hills - 2, height: 14, count: 8, color: Art.color(0x0E1432), seed: 2)
        ArtStyle.atmosphere(&context, width: w, top: hills - 40, bottom: hills + 10, color: Art.color(0x1D2A63), alpha: 0.24)
        let near: Path = Kit.ridge(width: w, y: hills + 22, amp: 10, seed: 9, bottom: h + 4, step: 12)
        Art.fill(&context, near, Art.color(0x080C20))
        Art.stroke(&context, Art.svg("M0,322 C60,316 120,318 180,324"), Art.color(silver, 0.18), width: 1.2)
        Kit.sink(&context, size, card: 0x141B45)
    }

    // MARK: see-qixi

    /// see-qixi: one fine needle with a long red thread through its eye, held up against the
    /// half moon of a seventh night in a dark violet sky.
    static func qixiPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let sky: Kit.Stops = [(Art.color(0x1A0F30), 0), (Art.color(0x2A1844), 0.5), (Art.color(0x3A1F4F), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Kit.stars(&context, width: w, maxY: 300, count: 60, seed: 77, color: Art.color(0xF4E8FF))
        halfMoon(&context, 236, 150, 72)
        // A low bank of violet cloud at the foot.
        cloudBank(&context, x: 216, y: 330, width: 520, height: 26, color: 0x2E1A46, edge: silver, seed: 23, bottom: h + 10)
        // The needle and its thread, held up against the moon.
        Art.group(&context, x: 222, y: 196, rotate: 0.3) { n in
            qixiThread(&n, behind: true)
            needle(&n)
            qixiThread(&n, behind: false)
        }
        Kit.sink(&context, size, card: 0x3A1F4F)
    }

    /// The half moon of the seventh night: lit on its right side, with a faint earthshine on
    /// the dark half and two quiet marks.
    static func halfMoon(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat) {
        let pale: Color = Art.color(0xFFF1D6)
        Art.glow(&context, x + r * 0.3, y, r * 2.6, pale, alpha: 0.28)
        let disc: Path = Art.circle(x, y, r)
        Art.fill(&context, disc, Art.color(0x4A3A6A, 0.85))
        Art.clipped(&context, to: disc) { g in
            Art.fill(&g, Art.rect(x, y - r, r + 2, r * 2), pale)
            Art.fill(&g, Art.ellipse(x, y, r * 0.12, r), pale)
            Art.fill(&g, Art.circle(x + r * 0.42, y - r * 0.3, r * 0.16), Art.color(0xE8D49A, 0.5))
            Art.fill(&g, Art.circle(x + r * 0.56, y + r * 0.34, r * 0.22), Art.color(0xE8D49A, 0.4))
            Art.fill(&g, Art.circle(x + r * 0.2, y + r * 0.08, r * 0.1), Art.color(0xE8D49A, 0.4))
            Art.stroke(&g, disc, Color.white.opacity(0.4), width: 3)
        }
    }

    /// A fine steel needle, upright, centred on the origin: about 220 long, its eye near the
    /// top at (0, −90), its point at the bottom.
    static func needle(_ context: inout GraphicsContext) {
        let body: Path = Art.svg("M-2.6,-100 C-3,-60 -2.8,40 0,114 C2.8,40 3,-60 2.6,-100 C2.6,-108 -2.6,-108 -2.6,-100Z")
        Art.glow(&context, 0, -20, 40, Art.color(silver), alpha: 0.12)
        Art.fill(&context, body, Art.color(0x9AA2C4))
        Art.stroke(&context, Art.svg("M-1.6,-100 C-1.9,-60 -1.7,40 0,106"), Color.white.opacity(0.85), width: 1)
        Art.stroke(&context, Art.svg("M1.8,-96 C2,-60 1.8,30 0.6,90"), Art.color(0x5A6288, 0.7), width: 0.8)
        // The eye.
        Art.fill(&context, Art.ellipse(0, -92, 1, 5.4), Art.color(0x2A1844))
    }

    /// The red thread through the needle's eye at (0, −92): the short end behind the needle
    /// (`behind`), the long end falling and curling away to the right in front of it.
    static func qixiThread(_ context: inout GraphicsContext, behind: Bool) {
        let red: Color = Art.color(0xD8324A)
        let lit: Color = Art.color(0xFF8A8A, 0.8)
        if behind {
            let short: Path = Art.svg("M0,-92 C-8,-98 -16,-94 -18,-84 C-20,-74 -14,-66 -16,-56")
            Art.stroke(&context, short, Art.color(0xA8243A), width: 2.4)
            return
        }
        let long: Path = Art.svg("M0,-92 C12,-100 24,-90 22,-72 C20,-44 48,-26 58,4 C68,36 44,62 50,92 C56,118 80,124 92,110")
        Art.glow(&context, 40, -10, 50, red, alpha: 0.12)
        Art.stroke(&context, long, red, width: 2.6)
        Art.stroke(&context, long.trimmedPath(from: 0, to: 0.55), lit, width: 0.9)
    }

    // MARK: see-two-stars

    /// see-two-stars: Vega (a little blue-white, on the left) and Altair (on the right), one on
    /// each side of a pale band of small stars; dark blue sky, nothing else.
    static func twoStarsPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let sky: Kit.Stops = [(Art.color(0x080B26), 0), (Art.color(0x0D1236), 0.5), (Art.color(0x1A2152), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Kit.stars(&context, width: w, maxY: 330, count: 110, seed: 52)
        // The band, slanting gently from the top right to the bottom left.
        let p0 = CGPoint(x: 300, y: -30)
        let p1 = CGPoint(x: 150, y: 380)
        silverRiver(&context, from: p0, to: p1, width0: 116, width1: 96, count: 640, seed: 13, mist0: 0.14, mist1: 0.1)
        // Vega on the Weaving Maiden's side, Altair on the Herd Boy's.
        Art.glow(&context, 96, 150, 64, Art.color(0xBFD6FF), alpha: 0.18)
        brightStar(&context, 96, 150, 17, color: 0xE6F0FF)
        Art.glow(&context, 350, 214, 56, Art.color(0xFFE2B8), alpha: 0.16)
        brightStar(&context, 350, 214, 14, color: 0xFFF1D6)
        Kit.sink(&context, size, card: 0x1A2152)
    }
}

// MARK: - Portraits, face chips, cover

extension WeaverArt {
    /// char-zhinu: half figure in her pale rose robe, hair in a high knot with its one pin,
    /// holding a skein of dawn-pink silk in both hands; deep violet sky with a faint band of
    /// rose behind her. No rays.
    static func zhinuPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x6A3468, bottom: 0x1E1640, halo: 0xF4C8B4, rays: false) { g in
            Kit.stars(&g, width: 432, maxY: 220, count: 40, seed: 61, color: Art.color(0xF4E8FF))
            // The faint band of rose behind her shoulders.
            var band = Path()
            band.move(to: CGPoint(x: -20, y: 300))
            band.addCurve(to: CGPoint(x: 452, y: 236), control1: CGPoint(x: 120, y: 250), control2: CGPoint(x: 300, y: 290))
            Art.stroke(&g, band, Art.color(rose, 0.14), width: 70)
            Art.stroke(&g, band, Art.color(gold, 0.12), width: 26)
            let spec = zhinuLook()
            Art.group(&g, x: 216, y: 150, rotate: 0.04, scale: 2.1) { b in
                Kit.bust(&b, spec, look: CGPoint(x: 0.25, y: 0.1), mouth: .smile)
                zhinuPin(&b)
                zhinuHands(&b, spec)
            }
        }
    }

    /// Zhinü's long sleeves coming forward and her hands holding the skein, in bust units
    /// (origin at the head's centre; the frame cuts the bust near y +119).
    static func zhinuHands(_ context: inout GraphicsContext, _ spec: Kit.Person) {
        // Her scarf over the shoulders, the one warm note.
        let scarf: Path = Art.svg("M-62,58 C-40,78 40,78 62,58")
        silkRibbon(&context, scarf, width: 8, glow: 0.6)
        let cloth: Color = Art.color(spec.cloth)
        let sleeves: Path = Art.svg("M-58,64 C-70,82 -62,96 -44,98 M58,64 C70,82 62,96 44,98")
        Art.stroke(&context, sleeves, cloth, width: 22)
        Art.stroke(&context, Art.svg("M-62,70 C-68,80 -64,88 -56,92"), Color.white.opacity(0.25), width: 3)
        Art.group(&context, x: 0, y: 96, rotate: -0.05, scale: 0.5) { s in
            skein(&s)
        }
        // The deep rose cuffs, then the hands over them.
        let cuffs: Path = Art.svg("M-54,90 C-52,98 -49,102 -45,104 M54,88 C52,96 49,100 45,102")
        Art.stroke(&context, cuffs, Art.color(spec.trim), width: 4)
        let skin: Color = Art.color(spec.skin)
        Kit.bodyHand(&context, CGPoint(x: -42, y: 98), 8, skin, open: false)
        Kit.bodyHand(&context, CGPoint(x: 42, y: 96), 8, skin, open: false)
    }

    /// char-niulang: half figure in his short blue jacket and cloth-tied topknot, one hand on
    /// the neck of the Old Ox, whose head shares the picture; deep blue starry sky. No rays.
    static func niulangPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x2A5682, bottom: 0x101F45, halo: 0xF4E3C0, rays: false) { g in
            Kit.stars(&g, width: 432, maxY: 240, count: 60, seed: 63, color: Art.color(0xE8F0FF))
            brightStar(&g, 52, 92, 5, color: 0xFFF1D6)
            // The Old Ox, his head beside Niulang's on the right.
            Art.glow(&g, 330, 210, 120, Art.color(oxLight), alpha: 0.12)
            Art.group(&g, x: 330, y: 206, scale: 1.45) { o in
                oxNeck(&o)
                oxFace(&o)
            }
            let spec = niulangLook()
            Art.group(&g, x: 172, y: 150, scale: 2.0) { b in
                Kit.bust(&b, spec, look: CGPoint(x: 0.2, y: 0), mouth: .smile)
            }
            // His near arm reaching up, the hand resting on the ox's neck.
            let sleeve: Path = Art.svg("M286,420 C292,380 300,344 314,312")
            Art.stroke(&g, sleeve, Art.color(spec.cloth), width: 30)
            Art.stroke(&g, Art.svg("M276,410 C282,376 290,346 302,318"), Color.white.opacity(0.2), width: 4)
            Art.stroke(&g, Art.svg("M304,320 L326,328"), Art.color(spec.trim), width: 6)
            Kit.bodyHand(&g, CGPoint(x: 322, y: 302), 13, Art.color(spec.skin), open: true)
        }
    }

    /// face-zhinu: her calm round face, the high knot and its pin.
    static func zhinuChip(_ context: inout GraphicsContext, _ size: CGSize) {
        let spec = zhinuLook()
        Kit.faceChip(&context, size, background: 0xFBDDE6) { g in
            Art.group(&g, x: 0, y: 7, scale: 1.2) { f in
                Kit.personHead(&f, spec, mouth: .smile)
                zhinuPin(&f)
            }
        }
    }

    /// face-niulang: his open, sun-browned face and the cloth-tied topknot.
    static func niulangChip(_ context: inout GraphicsContext, _ size: CGSize) {
        let spec = niulangLook()
        Kit.faceChip(&context, size, background: 0xD6E6F7) { g in
            Art.group(&g, x: 0, y: 7, scale: 1.2) { f in
                Kit.personHead(&f, spec, mouth: .smile)
            }
        }
    }

    /// face-ox: the Old Ox from the front, horns, grey muzzle and kind half-closed eyes.
    static func oxChip(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xF6E3B5) { g in
            Art.group(&g, x: 0, y: 3, scale: 0.86) { f in
                oxFace(&f)
            }
        }
    }

    /// cover: the meeting on the bridge. The arch of magpies across the middle over the river
    /// of stars, Zhinü and Niulang at its top reaching for each other's hands, her scarf the
    /// one warm note in a deep blue night.
    static func coverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size, wash: 0.04, vignette: 0.14) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let full = CGSize(width: 240, height: hd)
            let light = night()
            Kit.sky(&g, full, horizon: H, light: light)
            Kit.stars(&g, width: 240, maxY: H * 0.9, count: 60, seed: 71)
            let p0 = CGPoint(x: 260, y: H - 54 * k)
            let p1 = CGPoint(x: -20, y: H - 20 * k)
            silverRiver(&g, from: p0, to: p1, width0: 70 * k, width1: 48 * k, count: 300, seed: 19, mist0: 0.14, mist1: 0.08)
            let midBank: Path = Kit.ridge(width: 240, y: H - 4 * k, amp: 5 * k, seed: 23, bottom: H + 6)
            Art.fill(&g, midBank, light.mid)
            let floor: Kit.Stops = [(Art.color(0x1D2460), 0), (Art.color(0x0B0E2C), 1)]
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: floor, seed: 21, tooth: Art.color(silver))
            coverBridge(&g, frame)
        }
    }

    /// The arch, its two stars, a near magpie in the top-right corner, and the meeting at the
    /// crown, in cover units.
    static func coverBridge(_ context: inout GraphicsContext, _ frame: Kit.CoverFrame) {
        let H: CGFloat = frame.H
        let k: CGFloat = frame.k
        let hd: CGFloat = frame.hd
        let baseY: CGFloat = H + 22 * k
        let rise: CGFloat = 66 * k
        let thick: CGFloat = 15 * k
        cloudBank(&context, x: 16, y: baseY - 2, width: 70, height: 12 * k, color: 0x232A66, edge: silver, seed: 31, bottom: hd + 6)
        cloudBank(&context, x: 224, y: baseY - 2, width: 70, height: 12 * k, color: 0x232A66, edge: silver, seed: 35, bottom: hd + 6)
        magpieArch(&context, x0: 14, x1: 226, baseY: baseY, rise: rise, thick: thick)
        brightStar(&context, 10, H + 2, 4 * k + 1, color: 0xE6F0FF)
        brightStar(&context, 230, H + 2, 4 * k + 1, color: 0xFFF1D6)
        // Two of the nearest birds, drawn as birds.
        Art.group(&context, x: 60, y: H - 6 * k, rotate: -0.2, scale: 0.3 * k, scaleX: -1) { m in
            magpie(&m)
        }
        Art.group(&context, x: 182, y: H - 10 * k, rotate: 0.2, scale: 0.3 * k) { m in
            magpie(&m)
        }
        // Near-plane framing: one magpie cropped by the top-right corner.
        Art.group(&context, x: 236, y: 16, rotate: 0.3, scale: 0.6) { m in
            magpie(&m)
        }
        // The meeting at the crown.
        let feet: CGFloat = baseY - rise - thick * 0.3
        let s: CGFloat = 0.36 * k
        Art.glow(&context, 120, feet - 34 * k, 60 * k, Art.color(rose), alpha: 0.2)
        Art.glow(&context, 120, feet - 30 * k, 28 * k, Art.color(gold), alpha: 0.16)
        Art.group(&context, x: 120 - 13 * k, y: feet, scale: s, scaleX: -1) { z in
            zhinu(&z, pose: .carry, look: CGPoint(x: -0.7, y: 0), mouth: .smile, mirrored: true)
        }
        Art.group(&context, x: 120 + 13 * k, y: feet, scale: s) { p in
            niulang(&p, pose: .carry, look: CGPoint(x: -0.7, y: 0), mouth: .smile)
        }
    }
}
