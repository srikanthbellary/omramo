import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the two character-card portraits (432 × 400), the face
// chips (100 × 100) and the cover of "Iktomi and the Muskrat". Cultural care as in
// `IktomiArt+Cast.swift`: no people beyond Iktomi, no sacred object, no tipi, no copied
// beadwork; the storyteller picture shows only a book, a blanket and a small fire.

// MARK: - see-great-plains

extension IktomiArt {
    /// Open gold-green prairie rolling to a level horizon, one blue lake in the middle, a huge
    /// sky of white clouds; a meadowlark on a grass stem in front. No people, no buildings.
    static func greatPlainsPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = 214
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 250, 64, scale: 0.5, color: Color.white.opacity(0.7))
        cumulus(&context, 130, 128, scale: 0.7)
        cumulus(&context, 330, 168, scale: 1.0)
        Kit.birds(&context, 90, 176, scale: 0.8, color: ramp.shadeColor.opacity(0.45))
        farPrairie(&context, width: w, horizon: H, scale: 1, light: light, seed: 23)
        let land: Kit.Stops = [(Art.color(0xC9CE84), 0), (Art.color(0xA9B865), 0.4), (Art.color(0x7E9A50), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: land, seed: 29)
        Kit.mound(&context, x0: -40, x1: 190, baseY: H + 24, height: 9, bottom: h, stops: Kit.stops(0xC2C97C, 0x9DB15C), crest: 0.4)
        Kit.mound(&context, x0: 250, x1: 470, baseY: H + 20, height: 8, bottom: h, stops: Kit.stops(0xC2C97C, 0x9DB15C), crest: 0.6)
        plainsLake(&context)
        Kit.mound(&context, x0: -30, x1: 470, baseY: 330, height: 20, bottom: h, stops: Kit.stops(0xA9B865, 0x6E8C48), crest: 0.3)
        let near = CGRect(x: 0, y: 316, width: w, height: h - 316)
        Kit.grass(&context, in: near, count: 70, seed: 11, color: Art.color(0x6E8C48), height: 9)
        Kit.grass(&context, in: near, count: 40, seed: 12, color: Art.color(0xD6DC8C), height: 7)
        Kit.flowers(&context, in: CGRect(x: 30, y: 296, width: 380, height: 34), count: 8, seed: 5, petal: 0xF4E9B8)
        Kit.flowers(&context, in: CGRect(x: 60, y: 300, width: 300, height: 30), count: 5, seed: 8, petal: 0xC9A0D0)
        Art.stroke(&context, Art.svg("M362,332 C360,316 362,302 366,290"), Kit.groundTone(grassGold, 0.8), width: 1.8)
        Art.group(&context, x: 366, y: 292, scale: 1.3) { b in
            meadowlark(&b)
        }
        Kit.grassTuft(&context, x: 26, baseY: 360, height: 44, color: 0x6F8E4A, seed: 4)
        Kit.sink(&context, size, card: 0x3F5A2E)
    }

    /// The one lake of the prairie picture: soft muddy edges, reeds and wild rice, the clouds
    /// lying on it, two far ducks.
    static func plainsLake(_ context: inout GraphicsContext) {
        let lake: Path = Art.svg("M96,252 C110,236 170,228 230,229 C300,230 352,238 358,250 C360,262 300,272 226,272 C160,272 100,266 96,252Z")
        Art.fill(&context, lake.applying(CGAffineTransform(translationX: 0, y: 3)), Art.color(0x9A8660))
        Art.fillLinear(&context, lake, dayWater(), from: CGPoint(x: 0, y: 229), to: CGPoint(x: 0, y: 272))
        Art.clipped(&context, to: lake) { c in
            Art.fill(&c, Art.ellipse(180, 240, 60, 4), Color.white.opacity(0.35))
            Art.fill(&c, Art.ellipse(300, 248, 44, 3.5), Color.white.opacity(0.3))
            Art.fill(&c, Art.rect(90, 229, 280, 5), ramp.deepColor.opacity(0.12))
        }
        Kit.ripples(&context, 220, 260, 120, count: 2, color: Color.white, opacity: 0.5)
        farDuck(&context, x: 250, y: 252, scale: 0.9)
        farDuck(&context, x: 272, y: 256, scale: 0.8)
        Kit.reeds(&context, x: 108, baseY: 258, count: 5, height: 30, seed: 2, color: reedGreen)
        Kit.reeds(&context, x: 352, baseY: 256, count: 4, height: 26, seed: 6, color: reedGreen)
        wildRice(&context, x: 300, baseY: 270, count: 5, height: 24, seed: 9)
    }
}

// MARK: - see-guest-custom

extension IktomiArt {
    /// The plain dark pot of fish on the grass with two horn spoons leaning side by side
    /// against it, as if set out for two.
    static func guestCustomPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = 168
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        cumulus(&context, 330, 104, scale: 0.6)
        Kit.cloud(&context, 120, 70, scale: 0.4, color: Color.white.opacity(0.65))
        farPrairie(&context, width: w, horizon: H, scale: 1, light: light, seed: 31)
        let land: Kit.Stops = [(Art.color(0xC2C97C), 0), (Art.color(0xA9B865), 0.45), (Art.color(0x7C9650), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: land, seed: 33)
        Kit.grass(&context, in: CGRect(x: 0, y: H + 6, width: w, height: 60), count: 50, seed: 3, color: Art.color(0x8FA35A), height: 5)
        Kit.mound(&context, x0: -30, x1: 470, baseY: 250, height: 14, bottom: h, stops: Kit.stops(0xB2C06C, 0x6E8C48), crest: 0.55)
        ArtStyle.contactShadow(&context, 210, 264, 104, 13, alpha: 0.32)
        Art.group(&context, x: 200, y: 262, scale: 3.2) { p in
            pot(&p, fish: true, handle: true)
            steam(&p, x: 0, y: -40, height: 20)
        }
        Kit.shadow(&context, 336, 270, width: 50, alpha: 0.2)
        Art.group(&context, x: 322, y: 268, scale: 2.6) { s in
            spoon(&s)
        }
        Art.group(&context, x: 342, y: 270, rotate: Kit.deg(5), scale: 2.6) { s in
            spoon(&s)
        }
        let near = CGRect(x: 0, y: 270, width: w, height: h - 270)
        Kit.grass(&context, in: near, count: 70, seed: 13, color: Art.color(0x5F7E44), height: 10)
        Kit.grass(&context, in: near, count: 40, seed: 17, color: Art.color(0xCBD384), height: 8)
        Kit.flowers(&context, in: CGRect(x: 40, y: 276, width: 120, height: 30), count: 4, seed: 6, petal: 0xF4E9B8)
        Kit.flowers(&context, in: CGRect(x: 300, y: 284, width: 110, height: 26), count: 3, seed: 7, petal: 0xC9A0D0)
        Kit.grassTuft(&context, x: 86, baseY: 284, height: 30, color: 0x7E9A50, seed: 2)
        Kit.grassTuft(&context, x: 396, baseY: 292, height: 34, color: 0x6F8E4A, seed: 5)
        Kit.sink(&context, size, card: 0x7A3A26)
    }
}

// MARK: - see-reed-lodge

extension IktomiArt {
    /// One round dome of heaped reeds and cattails standing in still blue-green water, the
    /// muskrat swimming toward it with a small V of ripples.
    static func reedLodgePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = 132
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        cumulus(&context, 310, 92, scale: 0.55)
        Kit.cloud(&context, 140, 60, scale: 0.4, color: Color.white.opacity(0.65))
        farPrairie(&context, width: w, horizon: H, scale: 1, light: light, seed: 41)
        farWillow(&context, x: 90, baseY: H - 1, height: 16, color: light.near.opacity(0.8))
        let pond: Kit.Stops = [(Art.color(0xD2E6EC), 0), (Art.color(0x9CC8C8), 0.4), (Art.color(0x4F9A9A), 1)]
        Kit.water(&context, width: w, top: H, bottom: h, stops: pond, light: light, ripples: 30, seed: 5)
        Art.fill(&context, Art.ellipse(260, 268, 130, 8), Art.color(0x6E5A3C, 0.18))
        Kit.reeds(&context, x: 196, baseY: 236, count: 6, height: 110, seed: 61, color: reedGreen)
        Kit.reeds(&context, x: 340, baseY: 234, count: 7, height: 120, seed: 62, color: reedGreen)
        lodge(&context, cx: 266, waterY: 238, width: 230, seed: 5)
        Kit.reeds(&context, x: 384, baseY: 252, count: 5, height: 80, seed: 63, color: 0x5C8A4A)
        Kit.reeds(&context, x: 158, baseY: 254, count: 4, height: 64, seed: 64, color: 0x5C8A4A)
        Art.group(&context, x: 116, y: 290, scale: 1.2, scaleX: -1) { m in
            wake(&m, x: -30, y: 1, length: 100, spread: 18)
            muskratSwim(&m, mirrored: true)
        }
        Kit.ripples(&context, 140, 296, 60, count: 2, color: Color.white, opacity: 0.55)
        Kit.reeds(&context, x: 18, baseY: 330, count: 5, height: 120, seed: 65, color: 0x4E7A44)
        Kit.sink(&context, size, card: 0x1F4F5E)
    }
}

// MARK: - see-storyteller

extension IktomiArt {
    /// One open book lying on a plain striped wool blanket, the warm glow of a small fire
    /// behind it. No person, nothing else.
    static func storytellerPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let dusk: Kit.Stops = [(Art.color(0x5A3A5A), 0), (Art.color(0x8A5248), 0.55), (Art.color(0xC98A5A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), dusk, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 180))
        Art.glow(&context, 216, 140, 230, Art.color(0xFFB55A), alpha: 0.5)
        Kit.ground(&context, width: w, top: 176, bottom: h, stops: Kit.stops(0x6A4A3A, 0x3E2A30), seed: 51, tooth: Art.color(0xFFD9A0))
        Kit.campfire(&context, cx: 216, baseY: 182, scale: 1.3)
        storyBlanket(&context, h: h)
        openBook(&context)
        Kit.sink(&context, size, card: 0x4A2F4F)
    }

    /// The plain wool blanket spread toward the viewer: one earth colour, two simple red
    /// stripes near each end, soft folds, the firelight on its far edge.
    static func storyBlanket(_ context: inout GraphicsContext, h: CGFloat) {
        let bottom: CGFloat = h + 4
        var cloth = Path()
        cloth.move(to: CGPoint(x: 60, y: 198))
        cloth.addQuadCurve(to: CGPoint(x: 372, y: 196), control: CGPoint(x: 216, y: 190))
        cloth.addLine(to: CGPoint(x: 456, y: bottom))
        cloth.addLine(to: CGPoint(x: -24, y: bottom))
        cloth.closeSubpath()
        let shape: Path = cloth
        let wool: Kit.Stops = [(Art.color(0xDDB884), 0), (Art.color(blanketTan), 0.4), (Art.color(0x9A7A50), 1)]
        Art.fillLinear(&context, shape, wool, from: CGPoint(x: 0, y: 192), to: CGPoint(x: 0, y: bottom))
        let box = CGRect(x: -24, y: 190, width: 480, height: bottom - 190)
        ArtStyle.form(&context, shape, bounds: box, light: 0.2, shade: 0.2)
        let red: Color = Art.color(0xD94F3D)
        Art.clipped(&context, to: shape) { c in
            Art.fill(&c, Art.rect(-30, 206, 500, 6), red)
            Art.fill(&c, Art.rect(-30, 216, 500, 2.5), red)
            Art.fill(&c, Art.rect(-30, 362, 500, 12), red)
            Art.fill(&c, Art.rect(-30, 380, 500, 5), red)
            let folds: Path = Art.svg("M120,230 C110,280 96,330 84,400 M330,226 C344,280 356,330 372,400 M220,310 C230,340 236,370 240,404")
            Art.stroke(&c, folds, Kit.personTone(blanketTan, 0.8), width: 2)
            Art.glow(&c, 216, 196, 170, Art.color(0xFFC070), alpha: 0.3)
            ArtStyle.tooth(&c, in: box, seed: 53, alpha: 0.08)
        }
        Art.stroke(&context, Art.svg("M60,198 Q216,190 372,196"), Art.color(0xFFD9A0, 0.7), width: 1.6)
    }

    /// The open book on the blanket: a dark cover, two pale pages curving up from the gutter,
    /// lines of print as soft strokes, the firelight on the top edges.
    static func openBook(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 216, 300, 134, 11, alpha: 0.38)
        let boards: Path = Art.svg("M100,232 L94,296 C140,290 186,292 216,302 C246,292 292,290 338,296 L332,232 C292,226 246,228 216,238 C186,228 140,226 100,232Z")
        Kit.solid(&context, boards, Art.color(0x6B3A2E), light: 0.2, shade: 0.24)
        let left: Path = Art.svg("M216,236 C190,226 150,224 112,230 L104,290 C144,284 186,286 216,296Z")
        let right: Path = Art.svg("M216,236 C242,226 282,224 320,230 L328,290 C288,284 246,286 216,296Z")
        Kit.solid(&context, left, Art.color(0xF6EFDC), light: 0.18, shade: 0.12)
        Kit.solid(&context, right, Art.color(0xEFE6CF), light: 0.12, shade: 0.18)
        var lines = Path()
        for i in 0..<6 {
            let y: CGFloat = 242 + CGFloat(i) * 8
            lines.move(to: CGPoint(x: 124, y: y - 2))
            lines.addQuadCurve(to: CGPoint(x: 204, y: y + 4), control: CGPoint(x: 166, y: y - 6))
            lines.move(to: CGPoint(x: 228, y: y + 4))
            lines.addQuadCurve(to: CGPoint(x: 308, y: y - 2), control: CGPoint(x: 266, y: y - 6))
        }
        Art.stroke(&context, lines, Art.color(0xB9AE98), width: 1.3)
        let gutter: Path = Art.line(216, 238, 216, 296)
        Art.stroke(&context, gutter, ArtStyle.coolShade.opacity(0.28), width: 3)
        let edges: Path = Art.svg("M216,236 C190,226 150,224 112,230 M216,236 C242,226 282,224 320,230")
        Art.stroke(&context, edges, Art.color(0xFFC070, 0.8), width: 1.6)
    }
}

// MARK: - Portraits (432 × 400)

extension IktomiArt {
    /// char-iktomi: hugging the pot of fish to his chest, looking sideways out of the corner
    /// of his eye, the horn spoon sticking up from his fist; warm gold to earth-red behind.
    static func iktomiPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xF6D9A8, bottom: 0xC9603E, halo: 0xFFF1C8, rays: false) { g in
            wildRice(&g, x: 46, baseY: 404, count: 6, height: 150, seed: 71)
            wildRice(&g, x: 392, baseY: 404, count: 6, height: 140, seed: 72)
            Art.group(&g, x: 216, y: 130, scale: 2.2) { b in
                iktomiBust(&b)
            }
        }
    }

    /// Iktomi head-and-shoulders (origin at the head's centre, bust units): the kit bust in
    /// his deerskin, shoulder fringes, a plain two-colour bead band, red bands on the braids,
    /// the pot hugged in both arms and the spoon in his fist.
    static func iktomiBust(_ b: inout GraphicsContext) {
        let p = iktomiLook()
        Kit.bust(&b, p, look: CGPoint(x: -1, y: 0.1), mouth: .smile)
        let fringe: Color = Kit.personTone(deerskin, 0.74)
        var strands = Path()
        for i in 0..<7 {
            let t: CGFloat = CGFloat(i) / 6
            let fx: CGFloat = 59 + t * 2
            let fy: CGFloat = 54 + t * 44
            strands.move(to: CGPoint(x: -fx, y: fy))
            strands.addLine(to: CGPoint(x: -fx - 7, y: fy + 4))
            strands.move(to: CGPoint(x: fx, y: fy))
            strands.addLine(to: CGPoint(x: fx + 7, y: fy + 4))
        }
        Art.stroke(&b, strands, fringe, width: 1.8)
        let yoke: Path = Art.svg("M-52,56 C-30,72 30,72 52,56")
        Art.stroke(&b, yoke, Art.color(0xF4EBDC), width: 4.4, cap: .butt)
        Art.stroke(&b, yoke, Art.color(0x4F7F94), width: 4.4, cap: .butt, dash: [3.5, 3.5])
        braidBands(&b, p)
        Art.group(&b, x: 0, y: 114, scale: 1.35) { q in
            pot(&q, fish: true, handle: false)
        }
        let arm: Color = Art.color(Kit.bodyArmHex(p))
        Art.stroke(&b, Art.svg("M-54,62 C-68,98 -50,122 -16,118"), arm, width: 19)
        Art.stroke(&b, Art.svg("M54,62 C68,96 54,116 26,110"), arm, width: 19)
        Art.stroke(&b, Art.svg("M-62,92 L-70,96 M-60,100 L-68,105 M62,90 L70,94 M60,98 L68,103"), fringe, width: 1.6)
        Art.group(&b, x: 26, y: 108, rotate: Kit.deg(24), scale: 1.5) { s in
            spoon(&s)
        }
        let skin: Color = Art.color(p.skin)
        Kit.bodyHand(&b, CGPoint(x: -14, y: 118), 9, skin, open: false)
        Kit.bodyHand(&b, CGPoint(x: 26, y: 109), 9, skin, open: false)
    }

    /// A second red band wrapped high on each braid (the kit ties the ends).
    static func braidBands(_ g: inout GraphicsContext, _ p: Kit.Person) {
        var bands = Path()
        bands.addPath(Art.rect(-31.6, 26, 9.2, 3.6, radius: 1.6))
        bands.addPath(Art.rect(22.4, 26, 9.2, 3.6, radius: 1.6))
        Art.fill(&g, bands, Art.color(p.trim))
    }

    /// char-muskrat: sitting upright among green cattails at the water's edge, paws together,
    /// whiskers wet, a friendly patient look; pale lake blue behind.
    static func muskratPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xCDE6EE, bottom: 0x4A8FAE, halo: 0xFFF4D6, rays: false) { g in
            let lake: Kit.Stops = [(Art.color(0xBFE0EA), 0), (Art.color(0x6FA3B8), 1)]
            Art.fillLinear(&g, Art.rect(0, 296, 432, 110), lake, from: CGPoint(x: 0, y: 296), to: CGPoint(x: 0, y: 404))
            Kit.ripples(&g, 216, 330, 320, count: 3, color: Color.white, opacity: 0.5)
            Kit.reeds(&g, x: 74, baseY: 318, count: 7, height: 230, seed: 71, color: reedGreen)
            Kit.reeds(&g, x: 366, baseY: 316, count: 7, height: 220, seed: 72, color: reedGreen)
            let edge: Path = Art.svg("M54,356 C104,324 320,322 378,352 L384,380 L48,380Z")
            Art.fill(&g, edge.applying(CGAffineTransform(translationX: 0, y: 4)), Color.white.opacity(0.3))
            Kit.solid(&g, edge, Art.color(0x9A8660), light: 0.22, shade: 0.24, rim: 1.6)
            Art.clipped(&g, to: edge) { c in
                Kit.grass(&c, in: CGRect(x: 80, y: 330, width: 270, height: 26), count: 40, seed: 7, color: Art.color(0x7C9650), height: 8)
            }
            Kit.shadow(&g, 216, 348, width: 190, alpha: 0.3)
            Art.group(&g, x: 206, y: 348, scale: 3.1) { m in
                muskrat(&m, front: true, look: CGPoint(x: 0, y: 0.2))
            }
            Kit.reeds(&g, x: 24, baseY: 412, count: 5, height: 150, seed: 73, color: 0x4E7A44)
            Kit.reeds(&g, x: 412, baseY: 412, count: 5, height: 140, seed: 74, color: 0x4E7A44)
        }
    }
}

// MARK: - Face chips (100 × 100)

extension IktomiArt {
    /// face-iktomi on #FBE0D2.
    static func iktomiFaceChip(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFBE0D2) { g in
            Art.group(&g, x: 0, y: 2, scale: 1.25) { f in
                let p = iktomiLook()
                Kit.personHead(&f, p, look: CGPoint(x: -0.5, y: 0), mouth: .smile)
                braidBands(&f, p)
            }
        }
    }

    /// face-muskrat on #E9DCC8.
    static func muskratFaceChip(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xE9DCC8) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.22) { f in
                muskratFace(&f, look: .zero)
            }
        }
    }
}

// MARK: - Cover (300 wide, 150…375 high)

extension IktomiArt {
    /// cover: the race in one picture. Iktomi running along the shore under the stone, very
    /// pleased with himself; out on the pale lake the muskrat's small head and its long V;
    /// a huge pale sky with white clouds.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            coverScene(&g, frame)
        }
    }

    static func coverScene(_ g: inout GraphicsContext, _ frame: Kit.CoverFrame) {
        let H: CGFloat = frame.H
        let k: CGFloat = frame.k
        let hd: CGFloat = frame.hd
        let light = day()
        let area = CGSize(width: 240, height: hd)
        Kit.sky(&g, area, horizon: H, light: light)
        cumulus(&g, 168, H * 0.6, scale: 0.6 * k)
        cumulus(&g, 64, H * 0.42, scale: 0.34 * k)
        farPrairie(&g, width: 240, horizon: H, scale: 0.6 * k, light: light, seed: 9)
        Kit.water(&g, width: 240, top: H, bottom: hd, stops: dayWater(), light: light, ripples: 16, seed: 12)
        smoke(&g, x: 36, baseY: H - 2, height: 24 * k)
        Art.group(&g, x: 58, y: H + 12 * k, scale: 0.42 * k) { m in
            wake(&m, x: -34, y: 1, length: 230, spread: 30)
            muskratSwim(&m)
        }
        var edge = Path()
        edge.move(to: CGPoint(x: 30, y: hd + 4))
        edge.addQuadCurve(to: CGPoint(x: 250, y: H + 14 * k), control: CGPoint(x: 120, y: H + 20 * k))
        edge.addLine(to: CGPoint(x: 250, y: hd + 4))
        edge.closeSubpath()
        let shore: Path = edge
        Art.fill(&g, shore.applying(CGAffineTransform(translationX: -5, y: -3)), Art.color(0x9A8660))
        let grass: Kit.Stops = [(Art.color(0xBAC670), 0), (Art.color(0x7C9650), 1)]
        Art.fillLinear(&g, shore, grass, from: CGPoint(x: 0, y: H + 14 * k), to: CGPoint(x: 0, y: hd))
        let box = CGRect(x: 30, y: H + 10 * k, width: 220, height: max(1, hd - H))
        ArtStyle.form(&g, shore, bounds: box, light: 0.16, shade: 0.16)
        Kit.reeds(&g, x: 228, baseY: H + 22 * k, count: 5, height: 40 * k, seed: 33, color: reedGreen)
        let fy: CGFloat = min(hd - 6, H + 68 * k)
        let s: CGFloat = 0.6 * k
        Art.group(&g, x: 140, y: fy, scale: s) { p in
            Kit.shadow(&p, 0, 2, width: 120)
            iktomi(&p, rig: iktomiRunRig(), look: CGPoint(x: -0.7, y: 0), mouth: .grin, load: true)
        }
        Kit.reeds(&g, x: 12, baseY: hd + 4, count: 5, height: 56 * k, seed: 37, color: 0x4E7A44)
        Kit.cornerLeaves(&g, size: area, corner: 1, color: Art.color(0x3F6A46), scale: 0.55 * k, seed: 4)
    }
}
