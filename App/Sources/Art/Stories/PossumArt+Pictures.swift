import SwiftUI
import OmramoCore

// The tap-to-see pictures, the character-card portraits, the face chips and the cover of
// "Why the Possum's Tail Is Bare". Only animals and the mountain forest: no people, no
// lettering, no patterns.

// MARK: - Tap-to-see: the Smoky Mountains

extension PossumArt {
    /// Blue forested mountain ridges fading into morning mist. No buildings, no people.
    static func smokyMountainsPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = morning()
        Art.fillLinear(&context, Art.rect(0, 0, w, h), light.sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 236))
        Kit.sun(&context, 104, 150, 19, light: light)
        Kit.cloud(&context, 306, 74, scale: 0.6, color: Art.color(0xFFFFFF, 0.7))
        Kit.birds(&context, 236, 112, scale: 0.8, color: Art.color(0x6F9DB6, 0.7))
        // Six ridges, each nearer one darker and greener, with mist lying in the valleys.
        let tones: [UInt32] = [0xC6DBE8, 0xA9C6DC, 0x8BB1CC, 0x6F9DB6, 0x4F86A0, 0x2F6A6A]
        let crests: [CGFloat] = [170, 196, 224, 252, 284, 322]
        let amps: [CGFloat] = [22, 24, 26, 26, 24, 20]
        for index in 0..<6 {
            let y: CGFloat = crests[index]
            let amp: CGFloat = amps[index]
            let seed: UInt32 = 90 &+ UInt32(index) &* 5
            let shape: Path = Kit.ridge(width: w, y: y, amp: amp, seed: seed, bottom: h, step: 6)
            Art.fill(&context, shape, Art.color(tones[index]))
            // The forest on the slope: a second, finer skyline a little lower and lighter.
            let woods: Path = Kit.ridge(width: w, y: y + 9, amp: amp * 0.8, seed: seed &+ 2, bottom: h, step: 4)
            Art.fill(&context, woods, Art.color(0xFFFFFF, 0.1))
            // The warm light on the crest.
            let crest: Kit.Stops = [(light.glow.opacity(0.3), 0), (light.glow.opacity(0), 1)]
            let litTop: CGFloat = y - amp
            Art.clipped(&context, to: shape) { g in
                Art.fillLinear(&g, Art.rect(0, litTop, w, amp * 1.6), crest, from: CGPoint(x: 0, y: litTop), to: CGPoint(x: 0, y: litTop + amp * 1.6))
            }
            if index < 5 {
                let top: CGFloat = y + amp * 0.2
                let mist: Kit.Stops = [(Color.white.opacity(0), 0), (Color.white.opacity(0.62), 0.6), (Color.white.opacity(0.4), 1)]
                Art.fillLinear(&context, Art.rect(0, top, w, 44), mist, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: top + 44))
            }
        }
        // Near: the dark crowns of the woods we stand in, at the two bottom corners.
        let nearGreens: Kit.Greens = Kit.greens(0x163E46, 0x1F5A5A, 0x2F7A6A, 0x5E9A80, 0xA9D6A0)
        let leftCrowns: [Kit.Blob] = [(14, 318, 44), (66, 352, 38), (-6, 372, 40)]
        let rightCrowns: [Kit.Blob] = [(420, 330, 42), (366, 362, 34), (440, 380, 40)]
        Kit.canopy(&context, leftCrowns, seed: 81, palette: nearGreens, density: 1.6)
        Kit.canopy(&context, rightCrowns, seed: 83, palette: nearGreens, density: 1.6)
        Kit.sink(&context, size, card: 0x27506B)
    }
}

// MARK: - Tap-to-see: the cricket

extension PossumArt {
    /// A real black field cricket on a broad green leaf, side view.
    static func cricketPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let ground: Kit.Stops = [(Art.color(0xE9F3DA), 0), (Art.color(0xBFE0B0), 0.6), (Art.color(0x7FB08A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), ground, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 110, 80, 230, ramp.glowColor, alpha: 0.6)
        // Far: soft leaves out of focus.
        Art.blurred(&context, radius: 9, opacity: 0.55) { g in
            Art.fill(&g, Art.ellipse(350, 96, 90, 34), Art.color(0x7FB08A))
            Art.fill(&g, Art.ellipse(60, 250, 80, 30), Art.color(0x6FA87A))
            Art.fill(&g, Art.ellipse(380, 300, 100, 36), Art.color(0x5E9A6E))
            Art.fill(&g, Art.ellipse(210, 130, 60, 18), Art.color(0x9CCB8E))
        }
        // The leaf.
        let stem = Kit.placed("M-166,10 C-186,14 -204,24 -220,40", x: 216, y: 240)
        Art.stroke(&context, stem, Art.color(0x4F7A3E), width: 6)
        Kit.shadow(&context, 222, 300, width: 300, alpha: 0.16)
        let leaf = Kit.placed("M-172,10 C-120,-52 40,-72 176,-22 C122,42 -40,70 -172,10Z", x: 216, y: 240)
        let leafStops: Kit.Stops = [(Art.color(0x9AD06E), 0), (Art.color(0x5FA852), 0.55), (Art.color(0x3F8A4E), 1)]
        Kit.solid(&context, leaf, stops: leafStops, light: 0.3, shade: 0.24, rim: 2.4)
        let midrib = Kit.placed("M-170,10 C-60,-8 60,-22 174,-22", x: 216, y: 240)
        let veinData: String = "M-110,2 C-96,-18 -80,-30 -60,-38 M-50,-6 C-34,-28 -14,-42 8,-50 M14,-14 C32,-34 54,-46 78,-50 M76,-20 C92,-32 110,-38 130,-38 M-104,4 C-86,22 -64,34 -40,40 M-40,-4 C-22,18 2,32 28,36 M26,-12 C44,6 64,16 88,16"
        let veins = Kit.placed(veinData, x: 216, y: 240)
        Art.clipped(&context, to: leaf) { g in
            Art.stroke(&g, veins, Art.color(0xC9E69A, 0.55), width: 1.6)
            Art.stroke(&g, midrib, Art.color(0xD9F0A6, 0.85), width: 2.6)
        }
        // The cricket, drawn naturally: glossy, feelers long, wings folded.
        ArtStyle.contactShadow(&context, 266, 238, 96, 9, alpha: 0.3)
        Art.group(&context, x: 258, y: 236, scale: 2.6) { g in
            cricket(&g, natural: true)
        }
        Kit.sink(&context, size, card: 0x1F5A3C)
    }
}

// MARK: - Tap-to-see: the opossum

extension PossumArt {
    /// A real Virginia opossum walking along a fallen log by day: grey fur, white face, the
    /// long bare tail clearly shown.
    static func opossumPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = morning()
        let H: CGFloat = 250
        Kit.sky(&context, size, horizon: H, light: light)
        ridges(&context, width: w, horizon: H, scale: 0.7, light: light, layers: 3)
        Kit.farTrees(&context, x0: 0, x1: 432, baseY: H + 3, height: 46, count: 11, color: Art.color(0x6E9A80), seed: 5)
        ArtStyle.atmosphere(&context, width: w, top: H - 70, bottom: H + 4, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: grassStops())
        Kit.tree(&context, x: 404, baseY: H + 10, height: 236, spread: 150, palette: Kit.summerGreens(), bark: 0x6B4E40, seed: 7)
        let area = CGRect(x: 0, y: H + 8, width: w, height: 60)
        Kit.grass(&context, in: area, count: 40, seed: 3, color: Art.color(0x3F7A5A, 0.5), height: 8)
        // The log, and the opossum walking along it.
        Art.group(&context, x: 216, y: 288) { g in
            mossyLog(&g, length: 396)
        }
        let tail: [CGPoint] = tailFrom(.walk, CGPoint(x: 40, y: -6), CGPoint(x: 66, y: 44), CGPoint(x: 78, y: 16))
        Art.group(&context, x: 222, y: 244, scale: 1.3) { g in
            Kit.shadow(&g, 4, 0, width: 120)
            cord(&g, tail, wrapped: false)
            possum(&g, pose: .walk, mood: .calm)
        }
        fern(&context, x: 34, baseY: 304, height: 50, seed: 2)
        fern(&context, x: 330, baseY: 310, height: 40, color: 0x2F7A4A, seed: 3)
        Kit.sink(&context, size, card: 0x4A3F5C)
    }
}

// MARK: - Portraits

extension PossumArt {
    /// Possum in the morning sun, the comb in one paw, the full bushy tail fanned beside him,
    /// eyes shut with pride.
    static func possumPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xCFE6DA, bottom: 0x3F8468, halo: 0xFFF3CF, rays: true) { g in
            Art.group(&g, x: 216, y: 432) { l in
                mossyLog(&l, length: 470)
            }
            let line: [CGPoint] = tailLine(CGPoint(x: 0, y: 0), CGPoint(x: 56, y: -16), CGPoint(x: 84, y: -84), CGPoint(x: 56, y: -134))
            Art.group(&g, x: 262, y: 404, scale: 2.0) { t in
                plume(&t, line)
            }
            Art.group(&g, x: 216, y: 142, scale: 2.3) { b in
                Kit.beastBust(&b, possumLook(), mood: .proud, wave: true)
                possumNose(&b)
                comb(&b, x: 64, y: -24, turn: -30)
            }
            fern(&g, x: 26, baseY: 404, height: 70, seed: 2)
        }
    }

    /// Rabbit upright on a mossy path, ears high, one paw up as if an idea has just arrived;
    /// his tiny white tail showing.
    static func rabbitPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFFE6A6, bottom: 0xD9853C, halo: 0xFFF6D8, rays: true) { g in
            let moss = Art.ellipse(216, 424, 270, 56)
            Kit.solid(&g, moss, Art.color(0x7DB24E), light: 0.3, shade: 0.2)
            // The bit of fluff.
            var puff = Path()
            puff.addEllipse(in: CGRect(x: 316, y: 334, width: 30, height: 30))
            puff.addEllipse(in: CGRect(x: 330, y: 344, width: 24, height: 24))
            puff.addEllipse(in: CGRect(x: 314, y: 350, width: 22, height: 22))
            Kit.solid(&g, puff, Art.color(0xFFFFFF), light: 0.1, shade: 0.14)
            Art.group(&g, x: 216, y: 182, scale: 1.9) { b in
                Kit.beastBust(&b, rabbitLook(), mood: .sly, look: CGPoint(x: -0.3, y: -0.2), wave: true)
            }
            fern(&g, x: 30, baseY: 402, height: 64, color: 0x3F8A4E, seed: 4)
            fern(&g, x: 406, baseY: 404, height: 52, color: 0x2F7A4A, seed: 5)
        }
    }
}

// MARK: - Face chips

extension PossumArt {
    static func possumFaceChip(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xE3E4F2) { g in
            Art.group(&g, x: 0, y: 2, scale: 1.25) { f in
                possumFace(&f, mood: .happy)
            }
        }
    }

    static func rabbitFaceChip(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE2A8) { g in
            Art.group(&g, x: 0, y: 15, scale: 0.86) { f in
                Kit.beastFace(&f, rabbitLook(), mood: .happy)
            }
        }
    }

    static func cricketFaceChip(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD9F5E4) { g in
            Art.group(&g, x: 0, y: 5, scale: 1.12) { f in
                cricketFace(&f)
            }
        }
    }

    /// Cricket's face from the front: a round glossy dark head about 62 across, big friendly
    /// eyes, long feelers. Origin at the middle of the head.
    static func cricketFace(_ context: inout GraphicsContext) {
        let dark: Color = Art.color(0x2E2220)
        Art.stroke(&context, Art.svg("M-9,-20 C-14,-36 -26,-42 -38,-38 M9,-20 C14,-36 26,-42 38,-38"), dark, width: 2.4)
        let head = Art.svg("M0,-26 C-20,-26 -31,-12 -31,4 C-31,20 -18,31 0,31 C18,31 31,20 31,4 C31,-12 20,-26 0,-26Z")
        Kit.solid(&context, head, Art.color(0x46322A), light: 0.4, shade: 0.24, rim: 2)
        Art.fill(&context, Art.ellipse(-10, -17, 10, 4), Art.color(0xFFFFFF, 0.22))
        ArtStyle.eye(&context, -12, 0, 9.5)
        ArtStyle.eye(&context, 12, 0, 9.5)
        ArtStyle.cheek(&context, -21, 14, 6, alpha: 0.5)
        ArtStyle.cheek(&context, 21, 14, 6, alpha: 0.5)
        ArtStyle.smile(&context, 0, 17, width: 16, curve: 3, color: Art.color(0xF0D2A8), lineWidth: 2)
        Art.stroke(&context, Art.svg("M-5,28 q-3,5 -7,5 M5,28 q3,5 7,5"), dark, width: 2)
    }
}

// MARK: - Cover

extension PossumArt {
    /// Possum on his log, the long bushy tail held high like a plume, mouth open in song;
    /// Rabbit small in the ferns below, looking up; blue misty ridges behind.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = morning()
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let page = CGSize(width: 240, height: hd)
            Kit.sky(&g, page, horizon: H, light: light)
            Kit.sun(&g, 44, H - 30 * k, 11 * k, light: light)
            ridges(&g, width: 240, horizon: H, scale: 0.55 * k, light: light)
            Kit.farTrees(&g, x0: 0, x1: 240, baseY: H + 2, height: 18 * k, count: 12, color: Art.color(0x5E947F), seed: 3)
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: grassStops())
            let area = CGRect(x: 0, y: H + 5, width: 240, height: max(1, hd - H - 5))
            Kit.grass(&g, in: area, count: 30, seed: 4, color: Art.color(0x3F7A5A, 0.5), height: 5)
            Kit.flowers(&g, in: area, count: 8, seed: 6, petal: 0xFFFFFF)
            let tallTree: CGFloat = max(60, H - 2)
            Kit.tree(&g, x: 234, baseY: H + 8 * k, height: tallTree, spread: 96, palette: Kit.summerGreens(), bark: 0x6B4E40, seed: 7)
            coverSubject(&g, frame)
            // Near: a dark bough in the top trailing corner (the tier pill is top-left).
            let boughs: [Kit.Blob] = [(232, 4, 30), (196, -2, 20), (244, 34, 20)]
            Kit.canopy(&g, boughs, seed: 31, palette: Kit.pineGreens(), density: 1.6)
        }
    }

    static func coverSubject(_ context: inout GraphicsContext, _ frame: Kit.CoverFrame) {
        let k: CGFloat = frame.k
        let s: CGFloat = 0.66 * k
        let feetY: CGFloat = frame.H + 6 * k
        Art.group(&context, x: 124, y: feetY + 44 * s, scale: s) { g in
            mossyLog(&g, length: 200)
        }
        let root: CGPoint = tailRoot(.stand)
        let line: [CGPoint] = tailLine(CGPoint(x: 0, y: 0), CGPoint(x: 50, y: -8), CGPoint(x: 92, y: -78), CGPoint(x: 56, y: -136))
        Art.group(&context, x: 120, y: feetY, scale: s) { g in
            Kit.shadow(&g, 6, 0, width: 120)
            Art.group(&g, x: root.x, y: root.y, scale: 0.8) { t in
                plume(&t, line)
            }
            possum(&g, pose: .stand, mood: .proud, singing: true)
        }
        Art.group(&context, x: 50, y: feetY + 52 * s, scale: 0.62 * s, scaleX: -1) { g in
            rabbit(&g, pose: .sit, mood: .calm, look: CGPoint(x: -0.7, y: -0.7), mirrored: true)
        }
        fern(&context, x: 30, baseY: feetY + 62 * s, height: 32 * s, seed: 2)
        fern(&context, x: 74, baseY: feetY + 66 * s, height: 28 * s, color: 0x2F7A4A, seed: 3)
        fern(&context, x: 214, baseY: frame.hd - 8, height: 34 * k, color: 0x2F6A4A, seed: 5)
    }
}
