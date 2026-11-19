import SwiftUI
import OmramoCore

// The tap-to-see pictures, the character-card portraits, the face chips and the cover of
// "The Woman Who Raised a Bear".

extension BearWomanArt {
    // MARK: Tap pictures (432 × 404)

    /// Greenland seen from high above: the white ice sheet in the middle, dark rocky coasts at
    /// its edges, in a blue sea.
    static func greenlandPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let sea: Kit.Stops = [(Art.color(0x46769A), 0), (Art.color(0x2E557A), 0.6), (Art.color(0x1E3348), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), sea, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 120, 80, 260, Art.color(0x8FB4CC), alpha: 0.3)
        Kit.rippleMarks(&context, x0: 0, x1: w, y0: 20, y1: 300, count: 60, seed: 4, color: Color.white, alpha: 0.12)
        let outline: String = "M170,58 C200,48 250,46 290,56 C316,64 330,80 322,98 C316,112 330,124 324,140 C318,160 300,170 296,188 C292,206 284,224 270,238 C258,252 248,268 236,284 C230,292 222,298 216,296 C210,290 206,276 198,262 C188,246 176,236 168,220 C160,204 158,186 150,172 C140,156 126,146 124,130 C122,112 134,104 132,90 C130,76 146,64 170,58 Z"
        let island: Path = Art.svg(outline)
        Art.group(&context, x: 6, y: 8) { s in
            Art.fill(&s, island, ArtStyle.coolShade.opacity(0.22))
        }
        Kit.solid(&context, island, Art.color(0x4E5A64), light: 0.24, shade: 0.24, rim: 2.4)
        let sheet: Kit.Stops = [(Art.color(0xFFFFFF), 0), (Art.color(0xE4EEF5), 0.6), (Art.color(0xC4D8E6), 1)]
        let scale: CGFloat = 0.8
        Art.group(&context, x: 222 * (1 - scale), y: 166 * (1 - scale), scale: scale) { g in
            Kit.solid(&g, island, stops: sheet, light: 0.3, shade: 0.24)
            Art.glow(&g, 200, 110, 90, Color.white, alpha: 0.5)
        }
        let fjords: Path = Art.svg("M134,92 L148,96 M126,128 L142,130 M152,170 L166,168 M168,214 L180,208 M198,258 L206,250 M318,100 L304,104 M318,144 L304,142 M292,194 L280,190 M262,240 L252,232")
        Art.stroke(&context, fjords, Art.color(0x2E557A, 0.8), width: 2)
        let disko: Path = Art.svg("M128,150 C122,146 116,150 118,156 C120,162 128,162 130,156 Z")
        Kit.solid(&context, disko, Art.color(0x4E5A64), light: 0.24, shade: 0.2)
        let bergs: [(CGFloat, CGFloat)] = [(112, 168), (138, 188), (120, 200), (150, 232), (176, 262), (300, 230), (318, 180)]
        var flecks = Path()
        for b in bergs {
            flecks.addEllipse(in: CGRect(x: b.0 - 2, y: b.1 - 1.4, width: 4, height: 2.8))
        }
        Art.fill(&context, flecks, Color.white.opacity(0.85))
        Kit.sink(&context, size, card: 0x1E3348)
    }

    /// One polar bear standing on a floe of sea ice, looking back over its shoulder.
    static func polarBearPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let sky: Kit.Stops = [(Art.color(0xDDEAF3), 0), (Art.color(0xEEF4F7), 0.7), (Art.color(0xF8EEDB), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, 226), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 226))
        let water: Kit.Stops = [(Art.color(0x6F95B0), 0), (Art.color(0x3E6A8A), 0.5), (Art.color(0x24435C), 1)]
        Art.fillLinear(&context, Art.rect(0, 224, w, h - 224), water, from: CGPoint(x: 0, y: 224), to: CGPoint(x: 0, y: h))
        iceberg(&context, x: 352, baseY: 226, width: 70, height: 40, sharp: true, seed: 12)
        iceberg(&context, x: 70, baseY: 226, width: 46, height: 14, sharp: false, seed: 5)
        ArtStyle.atmosphere(&context, width: w, top: 180, bottom: 228, color: Art.color(0xEEF4F7), alpha: 0.4)
        Kit.rippleMarks(&context, x0: 0, x1: w, y0: 232, y1: 300, count: 30, seed: 8, color: Color.white, alpha: 0.3)
        let floe: Path = Art.svg("M66,262 L84,240 L190,232 L300,236 L364,244 L380,264 L340,276 L120,278 Z")
        let side: Path = Art.svg("M66,262 L120,278 L340,276 L380,264 L382,272 L340,288 L118,290 L64,272 Z")
        Kit.solid(&context, side, Art.color(0xA8C3D6), light: 0.2, shade: 0.3)
        Kit.solid(&context, floe, stops: Kit.stops(0xF0F6FA, 0xFFFFFF), light: 0.3, shade: 0.2, rim: 2.4)
        Kit.ripples(&context, 222, 290, 300, count: 2)
        Art.group(&context, x: 204, y: 258, scale: 1.05) { g in
            bear(&g, head: 2, collar: false, soot: false)
        }
        Kit.sink(&context, size, card: 0x24435C)
    }

    /// One slim sealskin kayak on a stand of wooden posts, harpoon and coiled line on its deck.
    static func kayakPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let sky: Kit.Stops = [(Art.color(0xDCE8F0), 0), (Art.color(0xEEF4F7), 0.7), (Art.color(0xF6E9D2), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, 250), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 250))
        let hills: Path = Kit.peaks(width: w, y: 236, amp: 30, seed: 21, bottom: 252, sharp: 0.5)
        Art.fill(&context, hills, Art.color(0xC3D4E0, 0.8))
        ArtStyle.atmosphere(&context, width: w, top: 190, bottom: 252, color: Art.color(0xE6EFF4), alpha: 0.4)
        let ground: Kit.Stops = [(Art.color(0x8E989E), 0), (Art.color(0x6C777E), 0.5), (Art.color(0x3A2A1E), 1)]
        Kit.ground(&context, width: w, top: 248, bottom: h, stops: ground)
        Kit.drift(&context, x0: 30, x1: 200, baseY: 266, height: 10, bottom: 280, snow: true)
        Kit.drift(&context, x0: 250, x1: 420, baseY: 272, height: 8, bottom: 284, snow: true)
        Kit.grass(&context, in: CGRect(x: 40, y: 256, width: 350, height: 30), count: 20, seed: 6, color: Art.color(0x6C6A44), height: 7)
        Art.group(&context, x: 216, y: 284, scale: 2.6) { g in
            kayakOnStand(&g)
        }
        let paddle: Path = Art.svg("M110,290 L330,270")
        Art.stroke(&context, paddle, Art.color(woodHex), width: 4)
        Art.fill(&context, Art.svg("M96,286 C100,282 116,284 118,290 C112,296 100,296 96,292 Z"), Art.color(woodHex))
        Art.fill(&context, Art.svg("M322,266 C330,262 346,264 346,270 C340,276 328,276 322,272 Z"), Art.color(woodHex))
        Kit.sink(&context, size, card: 0x3A2A1E)
    }

    /// A row of neat bundles of meat and blubber on a flat stone, one for each household.
    static func sharingPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let sky: Kit.Stops = [(Art.color(0xE2ECF3), 0), (Art.color(0xF1F1EC), 0.7), (Art.color(0xF8E6C8), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, 200), sky, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 200))
        Art.group(&context, x: 330, y: 200, scale: 0.8) { g in turfHouse(&g, window: true, seed: 4) }
        Art.group(&context, x: 70, y: 196, scale: 0.55) { g in turfHouse(&g, window: true, seed: 8) }
        ArtStyle.atmosphere(&context, width: w, top: 150, bottom: 202, color: Art.color(0xEEF4F7), alpha: 0.45)
        let snow: Kit.Stops = [(Art.color(0xE4EDF3), 0), (Art.color(0xF6F9FB), 0.5), (Art.color(0x4A2E22), 1)]
        Kit.ground(&context, width: w, top: 198, bottom: h, stops: snow)
        let stone: Path = Art.svg("M64,224 C70,206 120,198 216,198 C312,198 362,206 370,224 C372,240 340,252 216,252 C92,252 62,240 64,224 Z")
        Kit.shadow(&context, 216, 250, width: 330, alpha: 0.24)
        Kit.solid(&context, stone, Art.color(0x8A867C), light: 0.3, shade: 0.3, rim: 2.4)
        let top: Path = Art.svg("M74,220 C84,208 130,204 216,204 C302,204 348,208 360,220 C340,226 300,228 216,228 C132,228 92,226 74,220 Z")
        Art.fill(&context, top, Art.color(0xA4A098))
        let places: [CGFloat] = [108, 162, 216, 270, 324]
        for (i, px) in places.enumerated() {
            Art.group(&context, x: px, y: 222, scale: 1.3) { g in
                meatBundle(&g, seed: UInt32(i + 3))
            }
        }
        Kit.sink(&context, size, card: 0x4A2E22)
    }

    // MARK: Portraits (432 × 400)

    /// The old woman by the half-moon lamp, its long low flame lighting her face from below;
    /// grey top-knot, sealskin anorak, her hands open in her lap.
    static func womanPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFBF3E6, bottom: 0xD9B98E, halo: 0xFFE9B8, rays: false) { g in
            Art.glow(&g, 100, 300, 160, Art.color(sootHex), alpha: 0.06)
            Art.group(&g, x: 216, y: 150, scale: 2.2) { b in
                Kit.bust(&b, womanLook(), look: CGPoint(x: -0.2, y: 0.2), mouth: .smile, wave: false)
            }
            let skin: UInt32 = womanLook().skin
            let hands: Path = Art.svg("M150,330 C150,316 170,310 188,314 C200,318 206,326 204,334 L152,338 Z M228,334 C226,326 232,318 244,314 C262,310 282,316 282,330 L280,338 Z")
            Kit.solid(&g, hands, Art.color(skin), light: 0.24, shade: 0.24, rim: 1.6)
            let fingers: Path = Art.svg("M162,318 L160,330 M172,315 L171,330 M182,315 L182,330 M250,315 L250,330 M260,315 L261,330 M270,318 L272,330")
            Art.stroke(&g, fingers, Kit.personTone(skin, 0.75), width: 1.4)
            Art.glow(&g, 216, 330, 220, Art.color(0xFFD98A), alpha: 0.24)
            Art.group(&g, x: 216, y: 368) { l in stoneLamp(&l, width: 220, glow: false) }
            Art.glow(&g, 216, 250, 120, Art.color(0xFFE2A8), alpha: 0.14)
        }
    }

    /// The young bear lying on sealskins on the platform, the braided collar round his neck,
    /// his nose lifted toward someone out of the picture.
    static func bearPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xEEF4F7, bottom: 0x8FB4CC, halo: 0xFFF4DE, rays: false) { g in
            skins(&g, x0: -30, x1: 470, y: 322, depth: 90, seed: 12)
            let body: Path = Art.svg("M120,404 C112,336 170,290 250,282 C330,276 404,300 444,336 L444,404 Z")
            lit(&g, body, coatHex, mirrored: false)
            let haunch: Path = Art.svg("M360,296 C392,312 408,340 404,380")
            Art.stroke(&g, haunch, Art.color(0xD6CDBA, 0.7), width: 3)
            let neck: Path = Art.svg("M150,316 C136,262 146,208 178,172 L244,160 C254,206 268,252 300,292 Z")
            lit(&g, neck, coatHex, mirrored: false, rim: false)
            Art.group(&g, x: 206, y: 150, rotate: 0.3, scale: 3.1) { h in
                bearHead(&h)
            }
            Art.group(&g, x: 222, y: 254, rotate: -0.12, scale: 2.4) { c in
                collar(&c, "M-30,-8 C-16,2 10,4 30,-6")
            }
            let paws: Path = Art.svg("M60,392 C52,372 70,356 100,356 C130,356 150,368 150,388 L150,404 L60,404 Z")
            lit(&g, paws, coatHex, mirrored: false)
            let toes: Path = Art.svg("M74,362 L76,372 M90,358 L91,368 M106,358 L106,368 M122,360 L121,370")
            Art.stroke(&g, toes, Art.color(0xBDB4A2, 0.8), width: 1.8)
        }
    }

    // MARK: Face chips (100 × 100)

    /// The old woman's face: grey top-knot, lined brown face, plain eyes.
    static func womanFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xF6E3CF) { g in
            Art.group(&g, x: 0, y: 8, scale: 1.18) { f in
                Kit.personHead(&f, womanLook(), look: .zero, mouth: .smile)
            }
        }
    }

    /// The bear's face from the front: small round ears, long pale muzzle, black nose.
    static func bearFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xE3EEF5) { g in
            Art.group(&g, x: 0, y: 4) { f in
                bearFront(&f)
            }
        }
    }

    /// The bear's head seen from the front, centred, radius about 36; the collar below.
    static func bearFront(_ f: inout GraphicsContext) {
        collar(&f, "M-30,40 C-14,48 14,48 30,40")
        let ears: Path = Art.svg("M-32,-22 C-36,-32 -28,-40 -20,-36 C-16,-34 -16,-28 -20,-24 Z M32,-22 C36,-32 28,-40 20,-36 C16,-34 16,-28 20,-24 Z")
        lit(&f, ears, coatHex, mirrored: false, rim: false)
        Art.fill(&f, Art.svg("M-28,-28 C-29,-33 -25,-36 -22,-33 Z M28,-28 C29,-33 25,-36 22,-33 Z"), Art.color(0xB9A894))
        let skull: Path = Art.svg("M0,-34 C22,-34 34,-18 34,0 C34,18 22,32 0,34 C-22,32 -34,18 -34,0 C-34,-18 -22,-34 0,-34 Z")
        lit(&f, skull, coatHex, mirrored: false)
        let muzzle: Path = Art.svg("M-15,8 C-15,-4 15,-4 15,8 C15,22 8,30 0,30 C-8,30 -15,22 -15,8 Z")
        Kit.solid(&f, muzzle, Art.color(0xF9F5EA), light: 0.3, shade: 0.18)
        let nose: Path = Art.svg("M-8,6 C-8,1 8,1 8,6 C8,10 3,13 0,13 C-3,13 -8,10 -8,6 Z")
        Art.fill(&f, nose, Art.color(noseHex))
        Art.fill(&f, Art.ellipse(-3, 4, 2.4, 1.4), Color.white.opacity(0.45))
        let mouth: Path = Art.svg("M0,13 L0,19 M-7,21 C-3,24 3,24 7,21")
        Art.stroke(&f, mouth, Art.color(noseHex, 0.8), width: 1.8)
        ArtStyle.eye(&f, -13, -8, 3.6, showsWhite: false)
        ArtStyle.eye(&f, 13, -8, 3.6, showsWhite: false)
        ArtStyle.cheek(&f, -18, 6, 7, alpha: 0.18)
        ArtStyle.cheek(&f, 18, 6, 7, alpha: 0.18)
    }

    // MARK: Cover (300 × 150…375)

    /// A clear pale morning: the old woman at the edge of the sea ice with one hand raised, and
    /// the great white bear, the dark streak on his side, walking away among the icebergs and
    /// looking back once.
    static func coverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let light = morning()
            let box = CGSize(width: 240, height: frame.hd)
            Kit.sky(&g, box, horizon: H, light: light)
            Kit.sun(&g, 52, H - 16 * k, 7 * k, light: light)
            iceberg(&g, x: 150, baseY: H + 2, width: 34 * k, height: 28 * k, sharp: true, seed: 11)
            iceberg(&g, x: 212, baseY: H + 3, width: 56 * k, height: 42 * k, sharp: true, seed: 12)
            iceberg(&g, x: 108, baseY: H + 1, width: 26 * k, height: 9 * k, sharp: false, seed: 13)
            ArtStyle.atmosphere(&g, width: 240, top: H - 30 * k, bottom: H + 3, color: light.haze, alpha: 0.35)
            Art.fill(&g, Art.rect(0, H - 1, 240, 2.5), Art.color(0x6F95B0, 0.6))
            Kit.ground(&g, width: 240, top: H + 2, bottom: frame.hd, stops: iceStops())
            pawPrints(&g, from: Kit.pt(96, H + 40 * k), to: Kit.pt(160, H + 12 * k), count: 9, size: 2.6 * k)
            Art.group(&g, x: 172, y: H + 11 * k, scale: 0.3 * k) { b in
                bear(&b, head: 2, collar: true, soot: true, mirrored: true)
            }
            coverShore(&g, frame)
            Art.group(&g, x: 70, y: H + 46 * k, scale: 0.5 * k) { p in
                woman(&p, pose: .wave, mouth: .flat, mirrored: true, sooty: true)
            }
            iceBlock(&g, x: 196, baseY: frame.hd + 4, width: 60, height: 24 * k, seed: 3)
        }
    }

    /// The rocky shore under the old woman on the cover.
    static func coverShore(_ g: inout GraphicsContext, _ frame: Kit.CoverFrame) {
        let H: CGFloat = frame.H
        let k: CGFloat = frame.k
        var shore = Path()
        shore.move(to: Kit.pt(-10, frame.hd + 10))
        shore.addLine(to: Kit.pt(-10, H + 40 * k))
        shore.addQuadCurve(to: Kit.pt(124, H + 50 * k), control: Kit.pt(60, H + 34 * k))
        shore.addLine(to: Kit.pt(136, frame.hd + 10))
        shore.closeSubpath()
        Kit.solid(&g, shore, stops: Kit.stops(0x7E8A92, 0x5E6A72, 0x4E5A62), light: 0.2, shade: 0.22, rim: 2)
        Kit.drift(&g, x0: 0, x1: 110, baseY: H + 47 * k, height: 4 * k, bottom: H + 54 * k, snow: true)
    }
}
