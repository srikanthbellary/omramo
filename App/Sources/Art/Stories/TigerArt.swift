import SwiftUI
import OmramoCore

/// Concept art for "The Tiger, the Brahman and the Jackal", drawn in code (round 5; composed
/// from the shared kit).
///
/// A Medium, LIGHT story: one long dry day on the dead-flat Punjab plain, from pale morning
/// to a pale gold late afternoon. The sky behind the words is pale in every scene. The cast
/// and the story's own parts are in `TigerArt+Cast.swift`, the folded scenes in
/// `TigerArt+Folded.swift`, the tap pictures, portraits, faces and cover in
/// `TigerArt+Pictures.swift`. This file holds the entry point and the four unfolded scenes.
enum TigerArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-cage", .sceneUnfolded): cageScene(&context, size)
        case ("scene-cage", .sceneFolded): cageFolded(&context, size)
        case ("scene-pipal", .sceneUnfolded): pipalScene(&context, size)
        case ("scene-pipal", .sceneFolded): pipalFolded(&context, size)
        case ("scene-well", .sceneUnfolded): wellScene(&context, size)
        case ("scene-well", .sceneFolded): wellFolded(&context, size)
        case ("scene-road", .sceneUnfolded): roadScene(&context, size)
        case ("scene-road", .sceneFolded): roadFolded(&context, size)
        case ("see-punjab", .picture): punjabPicture(&context, size)
        case ("see-priest-and-teacher", .picture): priestPicture(&context, size)
        case ("see-pipal-tree", .picture): pipalPicture(&context, size)
        case ("see-well-wheel", .picture): wellPicture(&context, size)
        case ("char-brahman", .portrait): brahmanPortrait(&context, size)
        case ("char-jackal", .portrait): jackalPortrait(&context, size)
        case ("face-brahman", .face): brahmanFace(&context, size)
        case ("face-jackal", .face): jackalFace(&context, size)
        case ("face-tiger", .face): tigerFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - scene-cage (unfolded)

extension TigerArt {
    /// The dusty road where it crosses the foreground and runs away to the far left: its far
    /// edge about 50 × `g` under the horizon, its near edge falling to the trailing corner.
    static func sideRoad(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, unit g: CGFloat) {
        var shape = Path()
        shape.move(to: CGPoint(x: -4, y: H + 47 * g))
        shape.addQuadCurve(to: CGPoint(x: w + 4, y: H + 62 * g), control: CGPoint(x: w * 0.5, y: H + 50 * g))
        shape.addLine(to: CGPoint(x: w + 4, y: H + 200 * g))
        shape.addQuadCurve(to: CGPoint(x: -4, y: H + 78 * g), control: CGPoint(x: w * 0.45, y: H + 104 * g))
        shape.closeSubpath()
        let stops: Kit.Stops = [(Art.color(0xF4E6C0), 0), (Art.color(0xECD8A6), 0.4), (Art.color(0xDCBE84), 1)]
        Art.fillLinear(&context, shape, stops, from: CGPoint(x: 0, y: H + 47 * g), to: CGPoint(x: 0, y: H + 200 * g))
        // The low bank along its far edge, and two cart ruts.
        var bank = Path()
        bank.move(to: CGPoint(x: -4, y: H + 47 * g))
        bank.addQuadCurve(to: CGPoint(x: w + 4, y: H + 62 * g), control: CGPoint(x: w * 0.5, y: H + 50 * g))
        Art.stroke(&context, bank, Art.color(0xB9945A, 0.6), width: 2)
        var ruts = Path()
        ruts.move(to: CGPoint(x: -4, y: H + 57 * g))
        ruts.addQuadCurve(to: CGPoint(x: w + 4, y: H + 100 * g), control: CGPoint(x: w * 0.5, y: H + 66 * g))
        ruts.move(to: CGPoint(x: -4, y: H + 67 * g))
        ruts.addQuadCurve(to: CGPoint(x: w + 4, y: H + 152 * g), control: CGPoint(x: w * 0.48, y: H + 86 * g))
        Art.stroke(&context, ruts, Art.color(0xB08A52, 0.42), width: 2.4)
        dust(&context, in: CGRect(x: 0, y: H + 62 * g, width: w, height: 64 * g), seed: 3)
    }

    /// scene-cage: the middle of the day. Pale cream-gold sky over the thin line of fields on
    /// the leading side; on the trailing side the bamboo trap beside the dusty road under the
    /// thorny kikar trees, the Tiger sitting up inside it, the Brahman on the road before him.
    static func cageScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = Kit.stage(size, ground: 150)
        let H = st.H
        let g: CGFloat = st.fit * st.grow
        let light = midday()
        Kit.sky(&context, size, horizon: H, light: light)
        let cloudY: CGFloat = max(70, H - 300 * st.far)
        Kit.cloud(&context, 250, cloudY, scale: 0.8 * st.far, color: Art.color(0xFFFCEF, 0.6))
        farPlain(&context, width: w, horizon: H, scale: st.far, light: light, seed: 11)
        Kit.birds(&context, 340, H - 96 * st.far, scale: 0.7 * st.far, color: Art.color(0x9A8A5E, 0.7))
        let earth: Kit.Stops = [(Art.color(0xE6D29C), 0), (Art.color(0xDDBE82), 0.5), (Art.color(0xC9A262), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: earth, tooth: Art.color(0xFFF6D8))
        fields(&context, x0: 0, x1: w, top: H, bottom: H + 44 * g, mustardFirst: false, seed: 21)
        sideRoad(&context, width: w, horizon: H, unit: g)
        // A small far kikar low on the leading side, so the wide picture is one place.
        Kit.acacia(&context, x: 168, baseY: H + 10 * g, height: 50 * st.far, spread: 56 * st.far, palette: kikarGreens(), bark: 0x5A4A38)
        ArtStyle.atmosphere(&context, width: 432, top: H - 50 * st.far, bottom: H + 12 * g, color: light.haze, alpha: 0.26)

        Kit.designSpace(&context, st) { v in
            Kit.acacia(&v, x: 500, baseY: st.Hv + 28, height: 230, spread: 150, palette: kikarGreens(), bark: 0x3E3028)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                Kit.acacia(&n, x: 828, baseY: st.Hv + 46, height: 330, spread: 250, palette: kikarGreens(), bark: 0x3E3028)
                cageEnsemble(&n, horizon: st.Hv)
            }
        }

        if st.tall > 0.25 {
            let top: CGFloat = H + 150 * g
            dust(&context, in: CGRect(x: 0, y: top, width: w, height: max(1, h - top)), seed: 31)
            Kit.rock(&context, cx: 250, baseY: h - 96, width: 62, height: 26, color: 0xB7A27C, seed: 4)
            Kit.grassTuft(&context, x: 120, baseY: h - 60, height: 58, color: 0xB5A252, seed: 2)
            Kit.grassTuft(&context, x: 392, baseY: h - 28, height: 74, color: 0xA8963F, seed: 7)
            Kit.grassTuft(&context, x: 560, baseY: h - 70, height: 50, color: 0xB5A252, seed: 9)
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x7A7434), scale: 0.9 * st.grow, seed: 3)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x6A6A30), scale: 1.1 * st.grow, seed: 8)
        ArtStyle.finish(&context, size)
    }

    /// The trap, the Tiger and the Brahman, in the designed units (horizon at `Hv`).
    static func cageEnsemble(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        // The kikar's thin shade lies across the road and the trap.
        ArtStyle.contactShadow(&n, 760, Hv + 74, 190, 26, alpha: 0.16)
        Kit.grassTuft(&n, x: 858, baseY: Hv + 66, height: 34, color: 0xB5A252, seed: 3)
        Art.group(&n, x: 716, y: Hv + 64) { c in
            cagedTiger(&c, mood: .sad, look: CGPoint(x: -0.8, y: 0.1))
        }
        Kit.grassTuft(&n, x: 622, baseY: Hv + 70, height: 22, color: 0xA8963F, seed: 5)
        Kit.shadow(&n, 566, Hv + 97, width: 74)
        Art.group(&n, x: 560, y: Hv + 96, scaleX: -1) { b in
            brahman(&b, pose: .stand, look: CGPoint(x: -0.7, y: -0.1), mouth: .smile, mirrored: true)
        }
        // Husks and a few stones on the road.
        Kit.pebbles(&n, in: CGRect(x: 480, y: Hv + 100, width: 380, height: 30), count: 9, seed: 12, color: 0xB7A27C)
    }
}

// MARK: - scene-pipal (unfolded)

extension TigerArt {
    /// scene-pipal: pale morning. The long road across the flat fields on the leading side;
    /// on the trailing side the huge old pipal on its earth platform, its crown going out of
    /// the top of the picture, and the Brahman small in its shade, looking up.
    static func pipalScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = Kit.stage(size, ground: 160)
        let H = st.H
        let light = morning()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 150, H - 30 * st.far, 19 * st.far, light: light)
        farPlain(&context, width: w, horizon: H, scale: st.far, light: light, seed: 5)
        Kit.birds(&context, 300, H - 110 * st.far, scale: 0.7 * st.far, color: Art.color(0x8E9A6E, 0.7))
        let earth: Kit.Stops = [(Art.color(0xE8D7A4), 0), (Art.color(0xDFC48A), 0.5), (Art.color(0xCBA668), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: earth, tooth: Art.color(0xFFF6D8))
        fields(&context, x0: 0, x1: w, top: H, bottom: H + st.depth * 0.6, mustardFirst: true, seed: 33)
        road(&context, nearX: 700, nearY: h, nearWidth: 520, farX: 150, farY: H + 4, farWidth: 10)
        let low: CGFloat = H + st.depth * 0.6
        dust(&context, in: CGRect(x: 0, y: low, width: w, height: max(1, h - low)), seed: 17)

        let crownBottom: CGFloat = max(150, st.Hv * 0.42)
        let girth: CGFloat = 36 * st.grow
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 730) { n in
                // The bare, swept earth under the tree, and its pool of shade over the road.
                Art.fill(&n, Art.ellipse(690, st.Hv + 88, 280, 66), Art.color(0xE3CC98))
                ArtStyle.contactShadow(&n, 706, st.Hv + 92, 268, 56, alpha: 0.24)
            }
            pipalTrunk(&v, x: 730, baseY: st.Hv + 44, topY: crownBottom - 44, girth: girth)
            Kit.nearSpace(&v, st, anchorX: 730) { n in
                pipalPlatform(&n, x: 730, topY: st.Hv + 30, width: 270, height: 28)
            }
            pipalCanopy(&v, bottom: crownBottom)
            Kit.nearSpace(&v, st, anchorX: 600) { n in
                Kit.shadow(&n, 589, st.Hv + 89, width: 66, alpha: 0.2)
                Art.group(&n, x: 585, y: st.Hv + 88, scale: 0.94, scaleX: -1) { b in
                    brahman(&b, pose: .stand, look: CGPoint(x: -0.4, y: -1), mouth: .open, mirrored: true)
                }
                Kit.grassTuft(&n, x: 500, baseY: st.Hv + 116, height: 26, color: 0x8FA64E, seed: 4)
            }
        }

        if st.tall > 0.25 {
            Kit.grassTuft(&context, x: 96, baseY: h - 70, height: 56, color: 0x8FA64E, seed: 2)
            Kit.grassTuft(&context, x: 330, baseY: h - 30, height: 72, color: 0x7E9A46, seed: 6)
            Kit.rock(&context, cx: 470, baseY: h - 110, width: 54, height: 22, color: 0xB7A27C, seed: 3)
            Kit.flowers(&context, in: CGRect(x: 20, y: h - 150, width: 380, height: 110), count: 12, seed: 8, petal: 0xF2D03A)
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x55783A), scale: 0.9 * st.grow, seed: 5)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x44642F), scale: 1.1 * st.grow, seed: 2)
        ArtStyle.finish(&context, size)
    }

    /// The pipal's crown hanging from the top of the picture down to `bottom` (designed
    /// units), its fringe of long-tipped heart leaves, a few leaf tips over the edge of the
    /// leading pane, and two green parakeets.
    static func pipalCanopy(_ v: inout GraphicsContext, bottom: CGFloat) {
        let blobs = pipalCrown(x0: 506, x1: 904, bottom: bottom, slant: 70)
        Kit.canopy(&v, blobs, seed: 5, palette: pipalGreens(), density: 1.6)
        let fringe: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (566, bottom - 8, 34, 6), (612, bottom + 4, 38, -8), (664, bottom - 2, 34, 10),
            (798, bottom + 6, 38, -6), (846, bottom - 4, 34, 8), (540, bottom - 40, 30, -4),
        ]
        pipalLeaves(&v, fringe)
        let tips: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(420, 16, 30, 8), (394, 2, 26, -6), (444, 40, 28, 4), (368, -8, 24, 10)]
        pipalLeaves(&v, tips, dark: 0x5C8A48, light: 0x8DB85C)
        Art.stroke(&v, Art.line(778, bottom + 14, 842, bottom + 24), Kit.treeTone(pipalBarkHex, 0.8), width: 3)
        parakeet(&v, x: 806, y: bottom + 18, scale: 0.9)
        parakeet(&v, x: 826, y: bottom + 21, scale: 0.8)
    }
}

// MARK: - scene-well (unfolded)

extension TigerArt {
    /// The shining earth ditch that carries the wheel's water away through the wheat: a
    /// tapering band from (x0, y0) on the trailing side, `near` wide, to (x1, y1) far off on
    /// the left, `far` wide, with its dark bank above and a glint of sky along it.
    static func ditch(_ context: inout GraphicsContext, x0: CGFloat, y0: CGFloat, x1: CGFloat, y1: CGFloat, near: CGFloat, far: CGFloat) {
        let cx: CGFloat = (x0 + x1) * 0.5
        let cy: CGFloat = max(y0, y1) + near * 0.8
        let mid: CGFloat = (near + far) * 0.5
        var band = Path()
        band.move(to: CGPoint(x: x0, y: y0 - near * 0.5))
        band.addQuadCurve(to: CGPoint(x: x1, y: y1 - far * 0.5), control: CGPoint(x: cx, y: cy - mid * 0.5))
        band.addLine(to: CGPoint(x: x1, y: y1 + far * 0.5))
        band.addQuadCurve(to: CGPoint(x: x0, y: y0 + near * 0.5), control: CGPoint(x: cx, y: cy + mid * 0.5))
        band.closeSubpath()
        let lift = CGAffineTransform(translationX: 0, y: -near * 0.35)
        Art.fill(&context, band.applying(lift), Art.color(0x9A7A46, 0.55))
        let water: Kit.Stops = [(Art.color(0xCFEAEC), 0), (Art.color(0xA9D3DA), 1)]
        Art.fillLinear(&context, band, water, from: CGPoint(x: 0, y: min(y0, y1)), to: CGPoint(x: 0, y: max(y0, y1) + near))
        var glint = Path()
        glint.move(to: CGPoint(x: x0, y: y0 - near * 0.12))
        glint.addQuadCurve(to: CGPoint(x: x1, y: y1 - far * 0.12), control: CGPoint(x: cx, y: cy - mid * 0.12))
        Art.stroke(&context, glint, Color.white.opacity(0.7), width: max(0.8, near * 0.16))
    }

    /// scene-well: pale morning. A flat line of yellow mustard under the pale sky, green wheat
    /// with a shining ditch running through it toward the leading pane; on the trailing side
    /// the Persian wheel over its brick well, the old buffalo yoked to the beam on her worn
    /// circle, and the Brahman beside her with a hand raised in question.
    static func wellScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = Kit.stage(size, ground: 150)
        let H = st.H
        let g: CGFloat = st.fit * st.grow
        let light = morning()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 118, H - 36 * st.far, 17 * st.far, light: light)
        let cloudY: CGFloat = max(84, H - 270 * st.far)
        Kit.cloud(&context, 640, cloudY, scale: 0.7 * st.far, color: Art.color(0xFFFCEF, 0.6))
        farPlain(&context, width: w, horizon: H, scale: st.far, light: light, seed: 23)
        Kit.birds(&context, 284, H - 118 * st.far, scale: 0.6 * st.far, color: Art.color(0x8E9A6E, 0.7))
        let earth: Kit.Stops = [(Art.color(0xE4D6A2), 0), (Art.color(0xD6C08A), 0.5), (Art.color(0xC4A468), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: earth, tooth: Art.color(0xFFF6D8))
        fields(&context, x0: 0, x1: w, top: H, bottom: H + st.depth * 0.72, mustardFirst: true, seed: 45)
        ditch(&context, x0: w + 6, y0: H + 64 * g, x1: -6, y1: H + 20 * g, near: 12 * g, far: 4 * g)
        ArtStyle.atmosphere(&context, width: 432, top: H - 40 * st.far, bottom: H + 10 * g, color: light.haze, alpha: 0.22)

        Kit.designSpace(&context, st) { v in
            Kit.acacia(&v, x: 560, baseY: st.Hv + 12, height: 150, spread: 124, palette: kikarGreens(), bark: 0x4A3A30)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                wellEnsemble(&n, horizon: st.Hv)
            }
        }

        if st.tall > 0.25 {
            let low: CGFloat = H + st.depth * 0.72
            dust(&context, in: CGRect(x: 0, y: low, width: w, height: max(1, h - low)), seed: 27)
            Kit.grassTuft(&context, x: 110, baseY: h - 64, height: 58, color: 0x8FA64E, seed: 3)
            Kit.grassTuft(&context, x: 372, baseY: h - 26, height: 70, color: 0x7E9A46, seed: 8)
            Kit.rock(&context, cx: 236, baseY: h - 112, width: 56, height: 22, color: 0xB7A27C, seed: 6)
            Kit.flowers(&context, in: CGRect(x: 30, y: h - 160, width: 400, height: 120), count: 14, seed: 12, petal: mustardHex)
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x6E7A38), scale: 0.9 * st.grow, seed: 4)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x5A6A30), scale: 1.05 * st.grow, seed: 9)
        ArtStyle.finish(&context, size)
    }

    /// The wheel, the buffalo on her worn circle and the Brahman, in the designed units
    /// (horizon at `Hv`). The wheel stands at (820, Hv + 30) at 0.9, so the top of its gear
    /// shaft is at (719, Hv − 91); the buffalo at (660, Hv + 64) at 0.85 is yoked to it.
    static func wellEnsemble(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        let wheelX: CGFloat = 820
        let wheelY: CGFloat = Hv + 30
        let shaftX: CGFloat = wheelX - 112 * 0.9
        let shaftY: CGFloat = wheelY - 134 * 0.9
        // The worn circle the buffalo walks, round the gear shaft.
        let ring = Art.ellipse(shaftX, wheelY + 6, 150, 30)
        Art.stroke(&n, ring, Art.color(0xB9945A, 0.45), width: 16)
        Art.stroke(&n, ring, Art.color(0xF1E0B0, 0.4), width: 5)
        Art.group(&n, x: wheelX, y: wheelY, scale: 0.9) { c in
            wellWheel(&c)
        }
        // The buffalo, mid-step on the near side of her circle; her long shadow.
        let bx: CGFloat = 660
        let by: CGFloat = Hv + 64
        let k: CGFloat = 0.85
        ArtStyle.contactShadow(&n, bx + 34, by + 3, 132, 11, alpha: 0.22)
        let toX: CGFloat = (shaftX - bx) / k
        let toY: CGFloat = (shaftY - by) / k
        Art.group(&n, x: bx, y: by, scale: k) { b in
            buffalo(&b, look: CGPoint(x: 0.5, y: 0.2))
            yoke(&b, toX: toX, toY: toY)
        }
        // The Brahman by her head, turned to her, one hand raised: "Is that fair?"
        Kit.shadow(&n, 478, Hv + 118, width: 66)
        ArtStyle.contactShadow(&n, 506, Hv + 121, 40, 6, alpha: 0.14)
        Art.group(&n, x: 478, y: Hv + 118, scale: 0.95, scaleX: -1) { p in
            brahman(&p, pose: .wave, look: CGPoint(x: -0.7, y: 0.1), mouth: .open, mirrored: true)
        }
        Kit.grassTuft(&n, x: 560, baseY: Hv + 126, height: 26, color: 0x8FA64E, seed: 11)
        Kit.pebbles(&n, in: CGRect(x: 540, y: Hv + 90, width: 300, height: 30), count: 8, seed: 21, color: 0xB7A27C)
        // Wet earth where the trough's water reaches the ditch.
        Art.fill(&n, Art.ellipse(900, Hv + 34, 40, 6), Art.color(0x8A7048, 0.35))
    }
}

// MARK: - scene-road (unfolded)

extension TigerArt {
    /// One field of young wheat or of flowering mustard filling `rect`: a gradient, fine rows
    /// far away and coarse ones near, each with a low earth bank along its far edge.
    static func cropField(_ context: inout GraphicsContext, in rect: CGRect, mustard: Bool, seed: UInt32) {
        guard rect.width > 0, rect.height > 0 else { return }
        let stops: Kit.Stops
        if mustard {
            stops = Kit.stops(0xEACD52, 0xD6B03C)
        } else {
            stops = Kit.stops(0xA2C068, 0x7E9E48)
        }
        let whole = Art.rect(rect.minX, rect.minY, rect.width, rect.height)
        Art.fillLinear(&context, whole, stops, from: CGPoint(x: 0, y: rect.minY), to: CGPoint(x: 0, y: rect.maxY))
        let cuts: [CGFloat] = [0, 0.18, 0.42, 1]
        for index in 0..<3 {
            let y0: CGFloat = rect.minY + rect.height * cuts[index]
            let y1: CGFloat = rect.minY + rect.height * cuts[index + 1]
            let row = CGRect(x: rect.minX, y: y0 + 2, width: rect.width, height: max(1, y1 - y0 - 2))
            let rowSeed: UInt32 = seed &+ UInt32(index) &* 11
            let coarse: CGFloat = 1 + CGFloat(index) * 0.8
            let area: CGFloat = row.width * row.height
            let count: Int = min(150, max(12, Int(area / (520 * coarse))))
            Art.fill(&context, Art.rect(rect.minX, y0, rect.width, 2), Art.color(0xC7A566, 0.6))
            if mustard {
                let top: Double = 1.6 + Double(index) * 0.9
                Art.stipple(&context, in: row, count: min(260, count * 2), seed: rowSeed, color: Art.color(0xFFF08A), alpha: 0.8, size: 0.8...top)
                Art.stipple(&context, in: row, count: count, seed: rowSeed &+ 1, color: Art.color(0x7E9A3E), alpha: 0.45, size: 0.6...1.4)
            } else {
                let blade: CGFloat = 5 * coarse
                Kit.grass(&context, in: row, count: count, seed: rowSeed, color: Kit.groundTone(wheatHex, 0.78), height: blade)
                Kit.grass(&context, in: row, count: count / 2, seed: rowSeed &+ 2, color: Kit.groundTone(wheatHex, 1.2), height: blade * 0.8)
            }
        }
    }

    /// The fields of scene-road: a thin far strip of both, then wheat to the left of the
    /// road's middle line and mustard to the right of it (the same curve as `road` draws for
    /// nearX 640, near width 420, farX 600).
    static func roadFields(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, bottom h: CGFloat, unit g: CGFloat) {
        let top: CGFloat = H + 16 * g
        fields(&context, x0: 0, x1: w, top: H, bottom: top, mustardFirst: true, seed: 51)
        let rect = CGRect(x: 0, y: top, width: w, height: max(1, h - top))
        cropField(&context, in: rect, mustard: false, seed: 52)
        let rise: CGFloat = H + 3 - h
        var side = Path()
        side.move(to: CGPoint(x: 640, y: h + 4))
        let c1 = CGPoint(x: 640 + 294, y: h + rise * 0.35)
        let c2 = CGPoint(x: 600 - 176.4, y: h + rise * 0.72)
        side.addCurve(to: CGPoint(x: 600, y: H + 3), control1: c1, control2: c2)
        side.addLine(to: CGPoint(x: w + 4, y: H + 3))
        side.addLine(to: CGPoint(x: w + 4, y: h + 4))
        side.closeSubpath()
        Art.clipped(&context, to: side) { c in
            cropField(&c, in: rect, mustard: true, seed: 53)
        }
    }

    /// scene-road: late afternoon, a pale soft-gold sky warming to peach. The mud-brick
    /// village tiny on the leading side, a paper kite far up; on the trailing side the long
    /// pale road between wheat and mustard, the Brahman leaning on his staff and the Jackal
    /// trotting up to him out of the mustard.
    static func roadScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = Kit.stage(size, ground: 150)
        let H = st.H
        let g: CGFloat = st.fit * st.grow
        let light = afternoon()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 96, H - 32 * st.far, 18 * st.far, light: light)
        let cloudY: CGFloat = max(96, H - 250 * st.far)
        Kit.cloud(&context, 724, cloudY, scale: 0.75 * st.far, color: Art.color(0xFFF6E6, 0.6))
        farPlain(&context, width: w, horizon: H, scale: st.far, light: light, seed: 29)
        farVillage(&context, x: 182, baseY: H + 1, scale: st.far, light: light)
        kite(&context, x: 612, y: max(150, H - 330 * st.far), scale: st.far)
        let earth: Kit.Stops = [(Art.color(0xE9D6A6), 0), (Art.color(0xDDC08A), 0.5), (Art.color(0xCBA66A), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: earth, tooth: Art.color(0xFFF6D8))
        roadFields(&context, width: w, horizon: H, bottom: h, unit: g)
        road(&context, nearX: 640, nearY: h, nearWidth: 420, farX: 600, farY: H + 3, farWidth: 8)
        let dustTop: CGFloat = H + 60 * g
        dust(&context, in: CGRect(x: 560, y: dustTop, width: 330, height: max(1, h - dustTop)), seed: 41)
        ArtStyle.atmosphere(&context, width: w, top: H - 30 * st.far, bottom: H + 8 * g, color: light.haze, alpha: 0.2)

        Kit.designSpace(&context, st) { v in
            Kit.acacia(&v, x: 878, baseY: st.Hv + 10, height: 140, spread: 120, palette: kikarGreens(), bark: 0x4A3A30)
            Kit.nearSpace(&v, st, anchorX: 720) { n in
                roadEnsemble(&n, horizon: st.Hv)
            }
        }

        if st.tall > 0.25 {
            Kit.grassTuft(&context, x: 90, baseY: h - 60, height: 60, color: 0x8FA64E, seed: 5)
            Kit.grassTuft(&context, x: 350, baseY: h - 30, height: 74, color: 0x7E9A46, seed: 10)
            Kit.rock(&context, cx: 480, baseY: h - 120, width: 50, height: 20, color: 0xB7A27C, seed: 7)
            Kit.flowers(&context, in: CGRect(x: 760, y: h - 230, width: 120, height: 120), count: 12, seed: 14, petal: mustardHex)
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x7A7434), scale: 0.9 * st.grow, seed: 6)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x8A7A2E), scale: 1.05 * st.grow, seed: 12)
        ArtStyle.finish(&context, size)
    }

    /// The Brahman and the Jackal on the road, in the designed units (horizon at `Hv`).
    static func roadEnsemble(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        // Long late-afternoon shadows, falling to the lower right.
        ArtStyle.contactShadow(&n, 700, Hv + 104, 74, 8, alpha: 0.18)
        ArtStyle.contactShadow(&n, 846, Hv + 96, 66, 7, alpha: 0.18)
        Kit.shadow(&n, 650, Hv + 100, width: 70)
        Art.group(&n, x: 650, y: Hv + 100, scaleX: -1) { b in
            brahman(&b, pose: .stand, look: CGPoint(x: -0.6, y: 0.5), mouth: .sad, mirrored: true)
        }
        Kit.shadow(&n, 800, Hv + 92, width: 92)
        Art.group(&n, x: 800, y: Hv + 92, scale: 0.72) { j in
            jackal(&j, pose: .walk, mood: .happy, look: CGPoint(x: -0.4, y: -0.7))
        }
        // Mustard flowers at the field's edge, and husks and stones on the road.
        Kit.flowers(&n, in: CGRect(x: 846, y: Hv + 66, width: 50, height: 44), count: 8, seed: 6, petal: mustardHex)
        Kit.pebbles(&n, in: CGRect(x: 560, y: Hv + 110, width: 300, height: 26), count: 8, seed: 19, color: 0xB7A27C)
    }
}
