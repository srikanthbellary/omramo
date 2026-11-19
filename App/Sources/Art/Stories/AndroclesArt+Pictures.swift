import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the character-card portraits (432 × 400), the face
// chips (100 × 100) and the cover of "Androcles and the Lion".

// MARK: - see-slavery: the open gate

extension AndroclesArt {
    /// A heavy wooden house gate standing a little open, its iron bar lying on the ground
    /// beside it and pale morning light coming through the gap. No people; quiet, not grim.
    static func slaveryPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = morning()
        let groundY: CGFloat = 288
        Kit.sky(&context, size, horizon: groundY, light: light)
        Kit.ground(&context, width: size.width, top: groundY, bottom: size.height, stops: sandGround())
        gateView(&context, light: light, groundY: groundY)
        gateWall(&context, groundY: groundY)
        gateLeaves(&context, groundY: groundY)
        // The morning light lying across the yard from the gap.
        let wedge = Art.polygon([
            CGPoint(x: 214, y: groundY), CGPoint(x: 252, y: groundY - 2), CGPoint(x: 306, y: 404), CGPoint(x: 150, y: 404),
        ])
        let lit: Kit.Stops = [(Art.color(0xFFE9B0, 0.55), 0), (Art.color(0xFFE9B0, 0), 1)]
        Art.fillLinear(&context, wedge, lit, from: CGPoint(x: 0, y: groundY), to: CGPoint(x: 0, y: 404))
        // The bar, lifted off and laid down on the ground.
        Kit.shadow(&context, 164, 314, width: 170, alpha: 0.24)
        let bar = Art.line(92, 302, 236, 314)
        Art.stroke(&context, bar, Art.color(0x5A5560), width: 10, cap: .round)
        Art.stroke(&context, Art.line(96, 299, 232, 310.5), Art.color(0xB8B4C0, 0.55), width: 2)
        Art.stroke(&context, Art.line(130, 302, 131, 310), Art.color(0x46424C), width: 1.4)
        Kit.pot(&context, cx: 372, baseY: groundY + 14, width: 40, height: 46, color: tileHex)
        Kit.grassTuft(&context, x: 372, baseY: groundY - 30, height: 34, color: 0x6B7446, seed: 4)
        Kit.pebbles(&context, in: CGRect(x: 20, y: groundY + 20, width: 390, height: 70), count: 12, seed: 7, color: 0xC9A070)
        Kit.sink(&context, size, card: 0x4A2F26)
    }

    /// What the gap shows: the pale morning sky, far hills and the warm glow of sunrise.
    static func gateView(_ context: inout GraphicsContext, light: Kit.Light, groundY: CGFloat) {
        let opening = Art.rect(120, 100, 192, groundY - 100)
        Art.clipped(&context, to: opening) { g in
            let sky: Kit.Stops = [(Art.color(0xE4EEE6), 0), (Art.color(0xFBE7BE), 1)]
            Art.fillLinear(&g, opening, sky, from: CGPoint(x: 0, y: 100), to: CGPoint(x: 0, y: groundY))
            Art.glow(&g, 232, groundY - 40, 130, light.glow, alpha: 0.7)
            let hills = Kit.ridge(width: 210, y: groundY - 40, amp: 10, seed: 5, bottom: groundY + 2, x0: 112)
            Art.fill(&g, hills, Art.color(0xE6CFA6))
            let near = Kit.ridge(width: 210, y: groundY - 18, amp: 6, seed: 9, bottom: groundY + 2, x0: 112)
            Art.fill(&g, near, Art.color(0xDDB680))
            Kit.farTrees(&g, x0: 130, x1: 300, baseY: groundY - 14, height: 14, count: 3, color: Art.color(0x9AA070), seed: 3)
        }
    }

    /// The whitewashed yard wall round the gateway, its tiled coping and wooden lintel.
    static func gateWall(_ context: inout GraphicsContext, groundY: CGFloat) {
        let top: CGFloat = 74
        var wall = Path()
        wall.addRect(CGRect(x: -4, y: top, width: 124, height: groundY - top + 2))
        wall.addRect(CGRect(x: 312, y: top, width: 124, height: groundY - top + 2))
        wall.addRect(CGRect(x: 120, y: top, width: 192, height: 26))
        Kit.solid(&context, wall, Art.color(0xF3E9D6), light: 0.2, shade: 0.18)
        Art.clipped(&context, to: wall) { g in
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: top, width: 432, height: groundY - top), seed: 41, color: Art.color(0xB89A70), alpha: 0.08)
            Art.fill(&g, Art.rect(-4, groundY - 12, 440, 14), Art.color(0xD9C29A, 0.6))
            // The jambs' inner faces in shade.
            Art.fill(&g, Art.rect(108, 100, 12, groundY - 100), ArtStyle.coolShade.opacity(0.12))
            Art.fill(&g, Art.rect(312, 100, 10, groundY - 100), ArtStyle.coolShade.opacity(0.18))
        }
        let coping = Art.rect(-4, top - 9, 440, 11, radius: 2)
        Kit.solid(&context, coping, Art.color(tileHex), light: 0.28, shade: 0.22)
        var tiles = Path()
        var x: CGFloat = 6
        while x < 432 {
            tiles.move(to: CGPoint(x: x, y: top - 8))
            tiles.addLine(to: CGPoint(x: x, y: top + 1))
            x += 14
        }
        Art.stroke(&context, tiles, Art.color(0x8A4F2C, 0.45), width: 1.2)
        let lintel = Art.rect(108, 94, 216, 12, radius: 2)
        Kit.solid(&context, lintel, Art.color(0x8A6A48), light: 0.26, shade: 0.24)
        Art.fill(&context, Art.rect(110, 106, 212, 5), ArtStyle.coolShade.opacity(0.14))
    }

    /// The two heavy plank leaves: the left one shut, the right one swung a little inward on
    /// its hinges; the empty iron brackets that held the bar.
    static func gateLeaves(_ context: inout GraphicsContext, groundY: CGFloat) {
        let iron = Art.color(0x4E4A52)
        let left = Art.rect(120, 106, 96, groundY - 106)
        Kit.solid(&context, left, Art.color(0x9A6B44), light: 0.26, shade: 0.22, rim: 2)
        var planks = Path()
        for i in 1..<6 {
            let px: CGFloat = 120 + CGFloat(i) * 16
            planks.move(to: CGPoint(x: px, y: 108))
            planks.addLine(to: CGPoint(x: px, y: groundY - 2))
        }
        Art.stroke(&context, planks, Art.color(0x6B4A30, 0.6), width: 1.4)
        let battens = Art.svg("M122,140 L214,140 M122,252 L214,252")
        Art.stroke(&context, battens, Art.color(0x7A5234), width: 8, cap: .butt)
        Art.stroke(&context, Art.svg("M122,137 L214,137 M122,249 L214,249"), Art.color(0xC99A6A, 0.5), width: 1.2)
        let leaf = Art.polygon([CGPoint(x: 252, y: 114), CGPoint(x: 312, y: 106), CGPoint(x: 312, y: groundY), CGPoint(x: 252, y: groundY - 4)])
        Kit.solid(&context, leaf, Art.color(0x7A5234), light: 0.1, shade: 0.26)
        var far = Path()
        for i in 1..<4 {
            let t: CGFloat = CGFloat(i) / 4
            let px: CGFloat = 252 + 60 * t
            far.move(to: CGPoint(x: px, y: 114 - 8 * t))
            far.addLine(to: CGPoint(x: px, y: groundY - 4 + 4 * t))
        }
        Art.stroke(&context, far, Art.color(0x5A3A26, 0.6), width: 1.2)
        Art.stroke(&context, Art.svg("M252,148 L312,141 M252,250 L312,252"), Art.color(0x5E3E28), width: 6, cap: .butt)
        Art.stroke(&context, Art.svg("M300,120 L312,119 M300,268 L312,268"), iron, width: 3.4, cap: .butt)
        // The empty brackets either side of the gap.
        Art.stroke(&context, Art.svg("M196,192 L213,192 L213,206 L196,206"), iron, width: 3, cap: .round, join: .round)
        Art.stroke(&context, Art.svg("M266,190 L255,191 L255,204 L266,203"), iron, width: 2.6, cap: .round, join: .round)
        // Iron studs on the shut leaf.
        var studs = Path()
        for row in 0..<2 {
            for col in 0..<5 {
                let sx: CGFloat = 128 + CGFloat(col) * 20
                let sy: CGFloat = row == 0 ? 140 : 252
                studs.addEllipse(in: CGRect(x: sx - 1.6, y: sy - 1.6, width: 3.2, height: 3.2))
            }
        }
        Art.fill(&context, studs, iron)
        Art.glow(&context, 234, 200, 60, Art.color(0xFFF3CF), alpha: 0.4)
    }
}

// MARK: - see-north-africa: the dry hill above the wheat and the sea

extension AndroclesArt {
    /// One dry ochre hill with thorn bushes and a single olive tree, centred, above a strip
    /// of golden wheat and a strip of blue sea, a small white town on the far shore.
    static func northAfricaPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = day()
        let w: CGFloat = size.width
        let H: CGFloat = 196
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 330, 66, scale: 0.6, color: Art.color(0xFFFFFF, 0.55))
        Kit.cloud(&context, 120, 104, scale: 0.4, color: Art.color(0xFFFFFF, 0.4))
        farPlain(&context, width: w, horizon: H, scale: 1.5, town: false)
        let white = Art.color(0xFBF6EA)
        let roof = Art.color(0xD9A27A)
        Kit.farHouse(&context, cx: 46, baseY: H - 22, width: 20, height: 13, wall: white, roof: roof, flat: true)
        Kit.farHouse(&context, cx: 66, baseY: H - 21, width: 16, height: 10, wall: Art.color(0xF3E2BC), roof: roof, flat: true)
        Kit.farHouse(&context, cx: 28, baseY: H - 21, width: 15, height: 10, wall: white, roof: roof)
        let wheat: Kit.Stops = [(Art.color(0xEBC46C), 0), (Art.color(0xD9A848), 1)]
        Art.fillLinear(&context, Art.rect(0, H, w, 52), wheat, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: H + 52))
        var rows = Path()
        for i in 0..<12 {
            let x: CGFloat = w * (CGFloat(i) + 0.5) / 12
            rows.move(to: CGPoint(x: x, y: H + 2))
            rows.addLine(to: CGPoint(x: x - 40, y: H + 52))
        }
        Art.stroke(&context, rows, Art.color(0xB98A36, 0.35), width: 1.2)
        Kit.ground(&context, width: w, top: H + 46, bottom: size.height, stops: ochreGround())
        Kit.mound(&context, x0: 70, x1: 362, baseY: H + 70, height: 118, bottom: size.height, stops: ochreGround(), crest: 0.52)
        Kit.grass(&context, in: CGRect(x: 100, y: 176, width: 232, height: 80), count: 22, seed: 12, color: Art.color(0xB8935A, 0.7), height: 8)
        Kit.rock(&context, cx: 170, baseY: 238, width: 44, height: 22, color: rockHex, seed: 4)
        Kit.rock(&context, cx: 284, baseY: 246, width: 36, height: 18, color: 0xD3A566, seed: 6)
        thornBush(&context, x: 264, baseY: 160, width: 30, seed: 13)
        Kit.olive(&context, x: 222, baseY: 152, height: 100, seed: 5)
        thornBush(&context, x: 130, baseY: 192, width: 46, seed: 11)
        thornBush(&context, x: 308, baseY: 192, width: 40, seed: 12)
        Kit.pebbles(&context, in: CGRect(x: 20, y: 270, width: 390, height: 60), count: 12, seed: 14, color: 0xC9A070)
        Kit.sink(&context, size, card: 0x6B4423)
    }
}

// MARK: - see-old-book: the scroll

extension AndroclesArt {
    /// A half-open papyrus scroll on its two wooden rods, lines of small dark writing, a reed
    /// pen and a little round inkpot beside it, on a lamp-lit table. A scroll, not a book.
    static func oldBookPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let plaster: Kit.Stops = [(Art.color(0xF1DFC0), 0), (Art.color(0xE2C59A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, 120), plaster, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 120))
        Art.glow(&context, 90, 30, 240, Art.color(0xFFF0C8), alpha: 0.5)
        let wood: Kit.Stops = [(Art.color(0xC0905E), 0), (Art.color(0x9A6B44), 0.5), (Art.color(0x7A5234), 1)]
        Art.fillLinear(&context, Art.rect(0, 116, w, h - 116), wood, from: CGPoint(x: 0, y: 116), to: CGPoint(x: 0, y: h))
        Art.fill(&context, Art.rect(0, 116, w, 2.4), Art.color(0xE9C08A, 0.8))
        var grain = Path()
        for i in 0..<7 {
            let y: CGFloat = 136 + CGFloat(i) * CGFloat(18 + i * 4)
            grain.move(to: CGPoint(x: -10, y: y))
            grain.addQuadCurve(to: CGPoint(x: 442, y: y + 6), control: CGPoint(x: 220, y: y - 6))
        }
        Art.stroke(&context, grain, Art.color(0x6B4A30, 0.3), width: 1.2)
        Kit.shadow(&context, 216, 250, width: 300, alpha: 0.22)
        scrollSheet(&context)
        scrollRoll(&context, x: 86, top: 140, width: 26, height: 110)
        scrollRoll(&context, x: 322, top: 134, width: 38, height: 120)
        inkpot(&context, x: 128, y: 300)
        reedPen(&context)
        Kit.sink(&context, size, card: 0x3B2A4A)
    }

    /// The open stretch of papyrus with two columns of small writing (not readable).
    static func scrollSheet(_ context: inout GraphicsContext) {
        let sheet = Art.polygon([CGPoint(x: 104, y: 148), CGPoint(x: 328, y: 142), CGPoint(x: 336, y: 244), CGPoint(x: 96, y: 250)])
        Kit.solid(&context, sheet, Art.color(0xF0DDB0), light: 0.3, shade: 0.16)
        var random = ArtRandom(17)
        var fibres = Path()
        var writing = Path()
        Art.clipped(&context, to: sheet) { g in
            ArtStyle.tooth(&g, in: CGRect(x: 96, y: 142, width: 240, height: 108), seed: 18, color: Art.color(0xA98A5A), alpha: 0.12)
        }
        for i in 0..<9 {
            let y: CGFloat = 156 + CGFloat(i) * 10.5
            fibres.move(to: CGPoint(x: 106, y: y + 4))
            fibres.addLine(to: CGPoint(x: 330, y: y - 1))
            for column in 0..<2 {
                var x: CGFloat = column == 0 ? 126 : 226
                let end: CGFloat = x + 82
                while x < end {
                    let length: CGFloat = 4 + Kit.rnd(&random) * 12
                    let stop: CGFloat = min(end, x + length)
                    let lean: CGFloat = -0.03 * (x - 104)
                    writing.move(to: CGPoint(x: x, y: y + lean * 0.2))
                    writing.addLine(to: CGPoint(x: stop, y: y + lean * 0.2 - 0.2))
                    x = stop + 3
                }
            }
        }
        Art.stroke(&context, fibres, Art.color(0xD9BE88, 0.5), width: 0.8)
        Art.stroke(&context, writing, Art.color(0x3A2A2A, 0.78), width: 1.7, cap: .round)
    }

    /// A rolled end of the scroll lying along the sheet's edge, with its wooden rod's knobs.
    static func scrollRoll(_ context: inout GraphicsContext, x: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) {
        let r: CGFloat = width / 2
        let cx: CGFloat = x + r
        Art.stroke(&context, Art.line(cx, top - 12, cx, top + height + 12), Art.color(0x7A5234), width: 5)
        Art.fill(&context, Art.circle(cx, top - 13, 5.5), Art.color(0x8A6A48))
        Art.fill(&context, Art.circle(cx, top + height + 13, 5.5), Art.color(0x8A6A48))
        Art.fill(&context, Art.circle(cx - 1.6, top - 14.6, 1.8), Art.color(0xE0B884, 0.8))
        let roll = Art.rect(x, top, width, height, radius: r)
        let paper: Kit.Stops = [(Art.color(0xE6CC98), 0), (Art.color(0xF6E6C0), 0.35), (Art.color(0xD2B07A), 1)]
        Art.fillLinear(&context, roll, paper, from: CGPoint(x: x, y: 0), to: CGPoint(x: x + width, y: 0))
        Kit.model(&context, roll, light: 0.2, shade: 0.2)
        let end = Art.ellipse(cx, top + r * 0.5, r * 0.92, r * 0.4)
        Art.fill(&context, end, Art.color(0xDCC08C))
        let swirl = Art.ellipse(cx, top + r * 0.5, r * 0.5, r * 0.2)
        Art.stroke(&context, swirl, Art.color(0xA98A5A, 0.7), width: 1)
        Art.fill(&context, Art.circle(cx, top + r * 0.5, 2.6), Art.color(0x7A5234))
    }

    /// A small round pot of black ink centred on (x, y).
    static func inkpot(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        Kit.shadow(&context, x, y + 20, width: 64, alpha: 0.3)
        let pot = Art.ellipse(x, y, 26, 21)
        Kit.solid(&context, pot, Art.color(0x8A4F2C), light: 0.34, shade: 0.3, rim: 2)
        let rim = Art.ellipse(x, y - 18, 13, 5)
        Art.fill(&context, rim, Art.color(0xA9683C))
        Art.fill(&context, Art.ellipse(x, y - 18, 10, 3.4), Art.color(0x2A2033))
        Art.stroke(&context, Art.svg("M-18,-6 C-12,-13 -4,-15 4,-15").applying(CGAffineTransform(translationX: x, y: y)), Art.color(0xFFE0B0, 0.5), width: 1.6)
    }

    /// The reed pen laid down at the lower right, its cut nib dark with ink.
    static func reedPen(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 324, 296, width: 120, alpha: 0.2)
        let shaft = Art.line(268, 296, 388, 266)
        Art.stroke(&context, shaft, Art.color(0xC9A46A), width: 5.5)
        Art.stroke(&context, Art.line(270, 294.4, 386, 264.4), Art.color(0xF0D8A8, 0.7), width: 1.2)
        var joints = Path()
        joints.move(to: CGPoint(x: 318, y: 280.5))
        joints.addLine(to: CGPoint(x: 319.4, y: 286))
        joints.move(to: CGPoint(x: 356, y: 271))
        joints.addLine(to: CGPoint(x: 357.4, y: 276.5))
        Art.stroke(&context, joints, Art.color(0x9A7A48), width: 1.4)
        let nib = Art.polygon([CGPoint(x: 268, y: 293), CGPoint(x: 252, y: 302), CGPoint(x: 269, y: 299)])
        Art.fill(&context, nib, Art.color(0x2A2033))
    }
}

// MARK: - Portraits (432 × 400)

extension AndroclesArt {
    /// Warm pale ochre rock behind a portrait: a ledge on each side with its strata.
    static func portraitRock(_ context: inout GraphicsContext) {
        let stops: Kit.Stops = [(Art.color(rockPaleHex), 0), (Art.color(rockHex), 0.6), (Art.color(0xC08448), 1)]
        let left = Art.svg("M-10,410 L-10,214 C20,200 60,206 88,226 C110,242 118,290 124,410Z")
        let right = Art.svg("M442,410 L442,190 C410,180 368,190 344,214 C322,238 312,300 306,410Z")
        Kit.solid(&context, left, stops: stops, light: 0.28, shade: 0.2, rim: 2.4)
        Kit.solid(&context, right, stops: stops, light: 0.22, shade: 0.22, rim: 2.4)
        let strata = Art.svg("M-6,262 C30,252 70,258 104,280 M-6,320 C34,312 76,318 114,336 M440,246 C404,238 366,246 336,268 M440,304 C402,296 360,304 324,326")
        Art.stroke(&context, strata, Art.color(0x9A6238, 0.4), width: ArtStyle.detailLine)
    }

    /// Androcles, half figure in his rough tunic with the water-skin strap across it, a small
    /// relieved smile, holding the long thorn up between finger and thumb.
    static func androclesPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let p = androclesLook()
        Kit.portrait(&context, size, top: 0xFBE2B8, bottom: 0xC9803F, halo: 0xFFF3D6, rays: false) { g in
            portraitRock(&g)
            thornBush(&g, x: 40, baseY: 222, width: 56, seed: 3)
            Art.group(&g, x: 216, y: 140, scale: 2.1) { b in
                Kit.bust(&b, p, look: CGPoint(x: 0, y: 0), mouth: .smile, wave: true)
                Art.stroke(&b, Art.svg("M-46,44 C-14,80 14,112 40,150"), Art.color(0x6B4A30), width: 4)
                Art.stroke(&b, Art.svg("M-44,42 C-12,78 16,110 42,148"), Art.color(0x9A6B44, 0.6), width: 1)
                thorn(&b, x: 70, y: -14, length: 28, angle: Kit.deg(-78))
                // The thumb pinching the thorn's thick end.
                Art.fill(&b, Art.ellipse(65, -12, 4.6, 3.6), Art.color(skinHex))
                Art.fill(&b, Art.ellipse(64, -13.4, 2.4, 1.4), Art.color(0xD9A07A, 0.7))
            }
        }
    }

    /// The Lion sitting up, seen from the front, his dark mane round a calm face and down
    /// his chest, one front paw raised and bound in a strip of pale cloth.
    static func lionPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let head = lionHeadLook()
        Kit.portrait(&context, size, top: 0xFFE9A8, bottom: 0xC98A2B, halo: 0xFFF6D6, rays: false) { g in
            Art.group(&g, x: 216, y: 158, scale: 1.75) { b in
                Kit.beastBust(&b, head, mood: .calm, look: CGPoint(x: 0, y: 0), wave: true)
                lionBustMane(&b)
                lionBustBandage(&b)
            }
            let ledge = Art.svg("M-10,410 L-10,384 C80,374 170,380 216,378 C300,376 380,382 442,374 L442,410Z")
            let stops: Kit.Stops = [(Art.color(rockPaleHex), 0), (Art.color(rockHex), 1)]
            Kit.solid(&g, ledge, stops: stops, light: 0.3, shade: 0.2, rim: 2.4)
            // The thorn, pulled out, lying on the rock.
            thorn(&g, x: 52, y: 386, length: 30, angle: Kit.deg(-8))
        }
    }

    /// The Barbary mane hanging down the chest of the front-view bust (bust units).
    static func lionBustMane(_ context: inout GraphicsContext) {
        var mass = Path()
        mass.addEllipse(in: CGRect(x: -24, y: 40, width: 48, height: 56))
        mass.addEllipse(in: CGRect(x: -25, y: 72, width: 26, height: 36))
        mass.addEllipse(in: CGRect(x: -1, y: 74, width: 26, height: 36))
        Art.fill(&context, mass, Art.color(maneHex))
        let strands = Art.svg("M-10,52 q-3,14 0,28 M4,50 q-2,16 2,32 M14,58 q2,14 0,26 M-16,82 q-2,10 1,20 M12,88 q2,8 0,16")
        Art.stroke(&context, strands, Kit.beastTone(maneHex, 1.9), width: 1.3)
    }

    /// The strip of undyed cloth bound round the raised paw (bust units; the paw is at 68, -12).
    static func lionBustBandage(_ context: inout GraphicsContext) {
        let cloth = Art.color(woolHex)
        Art.stroke(&context, Art.line(57, -6, 79, -11), cloth, width: 7, cap: .butt)
        Art.stroke(&context, Art.line(58, -15, 78, -20), cloth, width: 6, cap: .butt)
        let edges = Art.svg("M57,-2.6 L79,-7.6 M58,-12 L78,-17")
        Art.stroke(&context, edges, Kit.personTone(woolHex, 0.74), width: 1)
        let tails = Art.svg("M79,-10 q8,-2 10,5 M79,-10 q7,4 4,11")
        Art.stroke(&context, tails, cloth, width: 2.6)
    }
}

// MARK: - Face chips (100 × 100)

extension AndroclesArt {
    static func androclesFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let p = androclesLook()
        Kit.faceChip(&context, size, background: 0xFBE3C4) { g in
            Art.group(&g, x: 0, y: 2, scale: 1.22) { f in
                Kit.personHead(&f, p, look: CGPoint(x: 0, y: 0), mouth: .smile)
            }
        }
    }

    static func lionFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let head = lionHeadLook()
        Kit.faceChip(&context, size, background: 0xFFE2A0) { g in
            Art.group(&g, x: 0, y: 2, scale: 0.95) { f in
                Kit.beastFace(&f, head, mood: .calm)
            }
        }
    }

    static func emperorFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let p = emperorLook()
        Kit.faceChip(&context, size, background: 0xEBD9F2) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.22) { f in
                Kit.personHead(&f, p, look: CGPoint(x: 0, y: 0), mouth: .smile)
                wreath(&f)
            }
        }
    }
}

// MARK: - Cover (300 wide, 150…375 high)

extension AndroclesArt {
    /// The thorn moment: Androcles kneeling with the Lion's great paw held out to him, his
    /// fingers on the thorn, the Lion's dark-maned head bent to watch; the cave mouth in warm
    /// ochre rock behind them and a pale gold sky above.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = goldDay()
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let full = CGSize(width: 240, height: frame.hd)
            Kit.sky(&g, full, horizon: H, light: light)
            Kit.sun(&g, 40, H - 40 * k, 8 * k, light: light)
            Kit.ranges(&g, width: 240, horizon: H, scale: 0.5 * k, light: light, seed: 5)
            Kit.ground(&g, width: 240, top: H, bottom: frame.hd, stops: caveGround())
            let s: CGFloat = 0.55 * k
            let feetY: CGFloat = H + 24 * k
            let gx: CGFloat = 120 - 660 * s
            let gy: CGFloat = feetY - 76 * s
            Art.group(&g, x: gx, y: gy, scale: s) { e in
                caveRock(&e, 0)
                caveFriends(&e, 0, paw: 1)
            }
            if frame.hd > 200 {
                let near = CGRect(x: 0, y: feetY + 40 * s, width: 240, height: max(4, frame.hd - feetY - 44 * s))
                Kit.pebbles(&g, in: near, count: 10, seed: 6, color: 0xC9A070)
                Kit.grass(&g, in: near, count: 12, seed: 7, color: Art.color(0xB8935A, 0.7), height: 8)
            }
            Kit.cornerLeaves(&g, size: full, corner: 1, color: Art.color(0x6B5A3A), scale: 0.45 * k, seed: 3)
        }
    }
}
