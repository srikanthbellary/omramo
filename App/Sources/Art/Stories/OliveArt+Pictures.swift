import SwiftUI
import OmramoCore

// The small pictures of "The Horse and the Olive": the four tap-to-see pictures (432 × 404,
// each one subject on the card's own deep ground, sunk into the card colour at the foot), the
// two character-card portraits, the three face chips and the cover.

extension OliveArt {
    /// The ground of a tap-to-see picture: the card's colour, a little lighter at the top.
    static func pictureBackdrop(_ context: inout GraphicsContext, _ size: CGSize, top: UInt32, bottom: UInt32) {
        let stops: Kit.Stops = [(Art.color(top), 0), (Art.color(bottom), 1)]
        let full: Path = Art.rect(0, 0, size.width, size.height)
        Art.fillLinear(&context, full, stops, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: size.height))
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: size.width, height: size.height), seed: 17, alpha: 0.05)
    }

    // MARK: see-acropolis

    /// see-acropolis: the high rock alone, as bare nature: one steep, flat-topped outcrop of
    /// pale limestone above a lit oval of dry plain, low hills behind, on a deep blue ground.
    static func acropolisPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        pictureBackdrop(&context, size, top: 0x4F7FA6, bottom: 0x2A4A6B)
        Art.glow(&context, 196, 150, 230, Art.color(0xFBE7B0), alpha: 0.3)
        // Low bare hills behind, blue with distance.
        let hills: Color = Art.color(0x5E86A6)
        bareHill(&context, x0: -20, x1: 170, baseY: 216, height: 24, color: hills)
        bareHill(&context, x0: 270, x1: 452, baseY: 216, height: 28, color: hills)
        ArtStyle.atmosphere(&context, width: size.width, top: 180, bottom: 220, color: Art.color(0x8FB4D0), alpha: 0.3)

        // The plain: a lit oval of dry ground under the rock.
        let plain: Path = Art.svg("M8,232 C70,208 362,208 424,232 C442,264 420,302 360,318 C260,338 172,338 72,318 C12,302 -10,264 8,232Z")
        Kit.solid(&context, plain, stops: plainStops(), light: 0.2, shade: 0.24)
        Kit.grass(&context, in: CGRect(x: 40, y: 262, width: 352, height: 44), count: 26, seed: 4, color: Art.color(strawHex, 0.8), height: 6)
        Kit.pebbles(&context, in: CGRect(x: 50, y: 268, width: 332, height: 40), count: 14, seed: 6, color: 0xBFAE8A)

        // The rock itself.
        Kit.shadow(&context, 226, 252, width: 300, alpha: 0.2)
        Art.group(&context, x: 216, y: 250, scale: 0.66) { r in
            acropolis(&r)
        }
        scrub(&context, x: 92, baseY: 284, width: 34, seed: 8)
        scrub(&context, x: 344, baseY: 290, width: 40, seed: 11)
        Kit.grassTuft(&context, x: 300, baseY: 300, height: 20, color: strawHex, seed: 5)
        Kit.sink(&context, size, card: 0x2A4A6B)
    }

    // MARK: see-greek-gods

    /// see-greek-gods: one tall black-figure jar, orange-red clay with a band of small dark
    /// figures (the sea god with his trident and the goddess with helmet and shield, a little
    /// olive tree between them), on a deep brown ground.
    static func godsJarPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        pictureBackdrop(&context, size, top: 0x7A4A32, bottom: 0x5A3324)
        Art.glow(&context, 196, 166, 210, Art.color(0xFBE0A0), alpha: 0.28)
        // The shelf it stands on.
        Art.fill(&context, Art.rect(0, 302, size.width, size.height - 302), Art.color(0x3E2418, 0.5))
        Art.fill(&context, Art.rect(0, 300, size.width, 3), Art.color(0xFBE0A0, 0.18))
        Kit.shadow(&context, 216, 304, width: 160, alpha: 0.36)
        Art.group(&context, x: 216, y: 186, scale: 1.05) { g in
            blackFigureJar(&g)
        }
        Kit.sink(&context, size, card: 0x5A3324)
    }

    /// A tall two-handled jar in the black-figure manner, origin at the middle of its belly;
    /// lip at y −132, foot at y 112, belly 180 wide.
    static func blackFigureJar(_ g: inout GraphicsContext) {
        let clay: UInt32 = 0xC8642E
        let glaze: Color = Art.color(0x22160F)
        // The handles first, behind the neck.
        let handles: Path = Art.svg("M-20,-110 C-58,-116 -70,-86 -62,-60 M20,-110 C58,-116 70,-86 62,-60")
        Art.stroke(&g, handles, glaze, width: 9)
        Art.stroke(&g, Art.svg("M-22,-113 C-54,-118 -66,-92 -64,-70"), Art.color(0xFFF2D8, 0.25), width: 2)
        let foot: Path = Art.svg("M-26,94 L26,94 L40,112 L-40,112Z")
        Kit.solid(&g, foot, glaze, light: 0.2, shade: 0.2)

        let body: Path = Art.svg("M-22,-118 L22,-118 L22,-84 C60,-74 90,-46 90,-8 C90,40 56,80 26,96 L-26,96 C-56,80 -90,40 -90,-8 C-90,-46 -60,-74 -22,-84Z")
        Kit.solid(&g, body, Art.color(clay), light: 0.3, shade: 0.3)
        Art.clipped(&g, to: body) { c in
            // A black neck, a row of tongues on the shoulder, two thin lines round the frieze.
            Art.fill(&c, Art.rect(-100, -130, 200, 50), glaze)
            var tongues = Path()
            for i in 0..<11 {
                let x: CGFloat = -60 + CGFloat(i) * 12
                tongues.addPath(Art.ellipse(x, -73, 4, 5.5))
            }
            Art.fill(&c, tongues, glaze)
            Art.fill(&c, Art.rect(-100, -62, 200, 4), glaze)
            Art.fill(&c, Art.rect(-100, 26, 200, 3), glaze)
            // Black rays rising from a black band at the foot.
            Art.fill(&c, Art.rect(-100, 84, 200, 20), glaze)
            var rays = Path()
            for i in 0..<9 {
                let x: CGFloat = -64 + CGFloat(i) * 16
                rays.move(to: CGPoint(x: x - 6, y: 86))
                rays.addLine(to: CGPoint(x: x, y: 42))
                rays.addLine(to: CGPoint(x: x + 6, y: 86))
                rays.closeSubpath()
            }
            Art.fill(&c, rays, glaze)
            jarFrieze(&c, glaze: glaze, clay: clay)
            ArtStyle.form(&c, body, bounds: body.boundingRect, light: 0.2, shade: 0.32)
        }
        // The shine of the glaze on the lit shoulder.
        Art.stroke(&g, Art.svg("M-64,-40 C-74,-18 -72,10 -62,30"), Art.color(0xFFF2D8, 0.45), width: 4)
        let lip: Path = Art.rect(-32, -132, 64, 14, radius: 4)
        Kit.solid(&g, lip, glaze, light: 0.24, shade: 0.2)
        Art.stroke(&g, Art.line(-28, -129, 10, -129), Art.color(0xFFF2D8, 0.35), width: 1.4)
    }

    /// The frieze of the jar: the two gods face to face as small dark figures, lines scratched
    /// through to the clay, the sea god's added-red cloak and the goddess's red crest.
    static func jarFrieze(_ c: inout GraphicsContext, glaze: Color, clay: UInt32) {
        let scratch: Color = Art.color(clay, 0.9)
        let red: Color = Art.color(0x7A2418)
        // The little olive tree between them.
        Art.stroke(&c, Art.svg("M0,24 C-3,10 3,0 0,-16 M0,-6 C-6,-12 -10,-16 -14,-24 M0,-12 C6,-18 10,-22 12,-30"), glaze, width: 2.6)
        var leaves = Path()
        let spots: [(CGFloat, CGFloat, CGFloat)] = [(-14, -24, 230), (-10, -18, 200), (12, -30, 300), (8, -22, 330), (0, -16, 270), (-4, -28, 250), (5, -34, 285)]
        for s in spots {
            Kit.groundLeaf(&leaves, base: CGPoint(x: s.0, y: s.1), angle: Kit.deg(s.2), length: 9, width: 2.6)
        }
        Art.fill(&c, leaves, glaze)

        // The sea god on the left, facing right, his trident up.
        Art.group(&c, x: -46, y: 24) { f in
            Art.fill(&f, Art.circle(2, -60, 7), glaze)
            Art.fill(&f, Art.svg("M-2,-58 C-4,-50 2,-45 9,-49 L7,-56Z"), glaze)
            let robe: Path = Art.svg("M-6,-52 L8,-52 C12,-40 12,-28 16,0 L-12,0 C-10,-24 -10,-40 -6,-52Z")
            Art.fill(&f, robe, glaze)
            Art.fill(&f, Art.svg("M-7,-50 L2,-50 L-4,-20 L-12,-14Z"), red)
            Art.stroke(&f, Art.svg("M4,-46 L20,-42"), glaze, width: 4)
            Art.stroke(&f, Art.line(22, 2, 22, -74), glaze, width: 2)
            Art.stroke(&f, Art.svg("M16,-66 L16,-77 M22,-68 L22,-82 M28,-66 L28,-77 M16,-66 L28,-66"), glaze, width: 2)
            Art.stroke(&f, Art.svg("M0,-38 L-2,-4 M6,-38 L8,-4 M-1,-61 L5,-61"), scratch, width: 0.9)
        }
        // The goddess on the right, facing left: crested helmet, round shield, spear.
        Art.group(&c, x: 46, y: 24, scaleX: -1) { f in
            Art.fill(&f, Art.circle(2, -60, 7), glaze)
            Art.stroke(&f, Art.svg("M-5,-66 C-1,-79 12,-78 15,-64"), red, width: 3.4)
            Art.fill(&f, Art.svg("M-6,-62 C-6,-70 10,-70 10,-62Z"), glaze)
            let robe: Path = Art.svg("M-6,-52 L8,-52 C10,-38 12,-24 14,0 L-12,0 C-10,-24 -9,-40 -6,-52Z")
            Art.fill(&f, robe, glaze)
            Art.stroke(&f, Art.line(-10, 4, -10, -74), glaze, width: 2)
            Art.fill(&f, Art.svg("M-10,-86 C-7,-80 -7,-76 -10,-72 C-13,-76 -13,-80 -10,-86Z"), glaze)
            Art.stroke(&f, Art.svg("M-2,-46 L-10,-40"), glaze, width: 4)
            Art.fill(&f, Art.circle(12, -30, 13), glaze)
            Art.stroke(&f, Art.circle(12, -30, 9), scratch, width: 0.9)
            Art.stroke(&f, Art.svg("M0,-36 L-2,-4 M-1,-61 L5,-61"), scratch, width: 0.9)
        }
    }

    // MARK: see-olive-oil

    /// see-olive-oil: a small clay jug tipped to pour a thin stream of golden oil into a
    /// shallow clay bowl on a stone slab, a twig and two olives beside it, on deep olive green.
    static func oilPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        pictureBackdrop(&context, size, top: 0x6A7436, bottom: 0x4A5320)
        Art.glow(&context, 190, 160, 220, Art.color(0xFBE7B0), alpha: 0.3)
        // The stone slab.
        let slab: Path = Art.svg("M-10,262 C80,250 352,250 442,262 L442,404 L-10,404Z")
        Kit.solid(&context, slab, Art.color(0x7A7444), light: 0.2, shade: 0.3)
        Art.stroke(&context, Art.svg("M-10,262 C80,250 352,250 442,262"), Art.color(0xFFF2C8, 0.3), width: 2)

        let bowlX: CGFloat = 246
        let bowlY: CGFloat = 262
        let bowlW: CGFloat = 176
        shallowBowl(&context, cx: bowlX, cy: bowlY, width: bowlW)

        // The jug, tipped forward; its spout follows the same turn.
        let jx: CGFloat = 140
        let jy: CGFloat = 150
        let turn: CGFloat = 0.7
        Art.group(&context, x: jx, y: jy, rotate: turn) { g in
            oilJug(&g)
        }
        let sx: CGFloat = jx + 36 * cos(turn) + 66 * sin(turn)
        let sy: CGFloat = jy + 36 * sin(turn) - 66 * cos(turn)
        let oilY: CGFloat = bowlY + bowlW * 0.13 * 0.3
        var stream = Path()
        stream.move(to: CGPoint(x: sx, y: sy))
        stream.addQuadCurve(to: CGPoint(x: sx + 18, y: oilY), control: CGPoint(x: sx + 14, y: sy + 30))
        Art.stroke(&context, stream, Art.color(0xE8B43A), width: 3.4)
        Art.stroke(&context, stream, Art.color(0xFFF0B0, 0.8), width: 1.1)
        Art.stroke(&context, Art.ellipse(sx + 18, oilY, 12, 3), Art.color(0xFFF0B0, 0.7), width: 1.2)
        Art.stroke(&context, Art.ellipse(sx + 18, oilY, 22, 5.5), Art.color(0xFFF0B0, 0.35), width: 1)

        // A twig of olive and two olives on the slab.
        oliveTwig(&context, x: 70, y: 304, angle: Kit.deg(-16), length: 66)
        olive(&context, x: 118, y: 322, r: 6.5, ripe: true)
        olive(&context, x: 140, y: 328, r: 6.5, ripe: false)
        Kit.shadow(&context, 130, 334, width: 50, alpha: 0.22)
        Kit.sink(&context, size, card: 0x4A5320)
    }

    /// The small clay jug (a trefoil-mouthed oinochoe), upright, origin at its belly; the spout's
    /// tip is at (36, −66).
    static func oilJug(_ g: inout GraphicsContext) {
        let clay: UInt32 = 0xC47A4A
        Art.stroke(&g, Art.svg("M-14,-58 C-44,-66 -54,-30 -38,-10"), Kit.personTone(clay, 0.8), width: 7)
        Art.fill(&g, Art.rect(-18, 54, 36, 6, radius: 2), Kit.personTone(clay, 0.7))
        let body: Path = Art.svg("M-14,-50 C-14,-40 -42,-30 -42,4 C-42,34 -24,52 -16,56 L16,56 C24,52 42,34 42,4 C42,-30 14,-40 14,-50Z")
        Kit.solid(&g, body, Art.color(clay), light: 0.32, shade: 0.3, rim: 1.4)
        Art.clipped(&g, to: body) { c in
            Art.fill(&c, Art.rect(-50, -6, 100, 8), Art.color(0x3A2418, 0.9))
            Art.fill(&c, Art.rect(-50, 8, 100, 2.5), Art.color(0x3A2418, 0.8))
        }
        let mouth: Path = Art.svg("M-16,-50 L16,-50 L36,-66 C30,-72 18,-74 6,-70 C-4,-74 -14,-72 -18,-64Z")
        Kit.solid(&g, mouth, Kit.personTone(clay, 1.08), light: 0.3, shade: 0.24)
        Art.stroke(&g, Art.svg("M-14,-64 C-4,-70 8,-68 30,-66"), Art.color(0x5A3020, 0.6), width: 1.4)
        Art.fill(&g, Art.circle(34, -64, 2.6), Art.color(0xE8B43A))
        Art.stroke(&g, Art.svg("M-34,-22 C-38,-8 -37,8 -30,22"), Art.color(0xFFF2D8, 0.4), width: 3)
    }

    /// A shallow clay bowl seen a little from above: rim centred on (cx, cy), `width` across,
    /// full of golden oil.
    static func shallowBowl(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat, width W: CGFloat) {
        let half: CGFloat = W * 0.5
        let depth: CGFloat = W * 0.2
        let ry: CGFloat = W * 0.13
        let clay: UInt32 = 0xB8683C
        Kit.shadow(&context, cx, cy + depth + 4, width: W * 0.9, alpha: 0.32)
        Art.fill(&context, Art.ellipse(cx, cy + depth, W * 0.16, W * 0.04), Kit.personTone(clay, 0.7))
        var body = Path()
        body.move(to: CGPoint(x: cx - half, y: cy))
        let low: CGFloat = cy + depth * 1.3
        body.addCurve(to: CGPoint(x: cx + half, y: cy), control1: CGPoint(x: cx - half * 0.9, y: low), control2: CGPoint(x: cx + half * 0.9, y: low))
        body.closeSubpath()
        Kit.solid(&context, body, Art.color(clay), light: 0.3, shade: 0.32)
        let band: Path = Art.svg("M0,0 C20,14 60,14 80,0").applying(CGAffineTransform(translationX: cx - 40, y: cy + depth * 0.55))
        Art.stroke(&context, band, Art.color(0x3A2418, 0.7), width: 2.4)
        Art.fill(&context, Art.ellipse(cx, cy, half, ry), Kit.personTone(clay, 1.15))
        Art.fill(&context, Art.ellipse(cx, cy + 1, half - 5, ry - 3.5), Art.color(0x8A4A2A))
        let oil: Path = Art.ellipse(cx + 2, cy + ry * 0.3, half * 0.8, ry * 0.6)
        let honey: Kit.Stops = [(Art.color(0xF6D36A), 0), (Art.color(0xC9922A), 1)]
        Art.fillLinear(&context, oil, honey, from: CGPoint(x: cx - half * 0.6, y: cy - ry), to: CGPoint(x: cx + half * 0.6, y: cy + ry))
        Art.fill(&context, Art.ellipse(cx - half * 0.32, cy + ry * 0.1, half * 0.22, ry * 0.18), Art.color(0xFFF4C8, 0.6))
    }

    // MARK: see-olive-wreath

    /// see-olive-wreath: one crown of grey-green olive leaves with a few small olives, two
    /// branches bent into a ring and tied at the foot, seen from the front, on deep green.
    static func wreathPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        pictureBackdrop(&context, size, top: 0x46664F, bottom: 0x2F4A3A)
        Art.glow(&context, 206, 170, 190, Art.color(0xFBE7B0), alpha: 0.26)
        ArtStyle.contactShadow(&context, 224, 312, 110, 10, alpha: 0.3)
        oliveWreath(&context, cx: 216, cy: 180, r: 92)
        Kit.sink(&context, size, card: 0x2F4A3A)
    }

    /// A crown of olive: two branches rising from a tie at the foot of a ring of radius `r`,
    /// their leaves pointing up round both sides, dark above and silver beneath.
    static func oliveWreath(_ context: inout GraphicsContext, cx: CGFloat, cy: CGFloat, r: CGFloat) {
        var dark = Path()
        var pale = Path()
        var stems = Path()
        var ring = Path()
        let steps: Int = 13
        for side in 0..<2 {
            let dir: CGFloat = side == 0 ? 1 : -1
            for i in 0...steps {
                let t: CGFloat = CGFloat(i) / CGFloat(steps)
                let turn: CGFloat = 90 + dir * (8 + 164 * t)
                let a: CGFloat = Kit.deg(turn)
                let p = CGPoint(x: cx + cos(a) * r, y: cy + sin(a) * r)
                if i == 0 {
                    ring.move(to: p)
                } else {
                    ring.addLine(to: p)
                }
                let wobble: CGFloat = i % 2 == 0 ? 0.35 : -0.35
                let along: CGFloat = a + dir * CGFloat.pi / 2 + wobble
                oliveSpray(&dark, &pale, &stems, from: p, angle: along, length: 24, leaf: 15, pairs: 2)
            }
        }
        Art.stroke(&context, ring, Art.color(0x6E6450), width: 4)
        Art.stroke(&context, ring, Art.color(0xB8AE96, 0.5), width: 1.2)
        Art.stroke(&context, stems, Art.color(0x7A7260), width: 1.4)
        Art.fill(&context, pale, Art.color(0xC9D8BE))
        Art.fill(&context, dark, Art.color(0x4E6A48))
        ArtStyle.form(&context, dark, bounds: dark.boundingRect, light: 0.24, shade: 0.22)

        // A few small olives tucked inside the ring.
        let fruit: [(CGFloat, Bool)] = [(124, true), (166, false), (212, true), (246, false), (56, false), (16, true), (-28, false), (-64, true)]
        for f in fruit {
            let a: CGFloat = Kit.deg(f.0)
            let fx: CGFloat = cx + cos(a) * (r - 12)
            let fy: CGFloat = cy + sin(a) * (r - 12)
            olive(&context, x: fx, y: fy, r: 5.6, ripe: f.1)
        }
        // The twine tie where the two branches meet.
        let knotY: CGFloat = cy + r
        Art.stroke(&context, Art.svg("M-9,-4 L9,4 M-9,4 L9,-4").applying(CGAffineTransform(translationX: cx, y: knotY)), Art.color(0xC9B45A), width: 3)
        Art.stroke(&context, Art.svg("M2,4 C4,14 0,22 4,30 M-2,4 C-6,12 -4,20 -8,26").applying(CGAffineTransform(translationX: cx, y: knotY)), Art.color(0xC9B45A), width: 2)
    }
}

// MARK: - Portraits and face chips

extension OliveArt {
    /// char-athena: half figure, calm and almost smiling, helmet pushed back, one small twig of
    /// olive held up beside her face; soft silver-green light behind and the owl at her side.
    static func athenaPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xE4EDD0, bottom: 0x8FA66B, halo: 0xF6F8EA, rays: false) { g in
            // Silver-green leaves drifting behind her.
            var dark = Path()
            var pale = Path()
            var stems = Path()
            oliveSpray(&dark, &pale, &stems, from: CGPoint(x: -6, y: 250), angle: Kit.deg(-30), length: 70, leaf: 22, pairs: 4)
            oliveSpray(&dark, &pale, &stems, from: CGPoint(x: 438, y: 300), angle: Kit.deg(-150), length: 60, leaf: 20, pairs: 3)
            Art.stroke(&g, stems, Art.color(0x7A7260, 0.7), width: 1.6)
            Art.fill(&g, dark, Art.color(0x5E7A52, 0.7))
            Art.fill(&g, pale, Art.color(0xEEF4E6, 0.8))

            let p = athenaLook()
            Art.group(&g, x: 216, y: 150, scale: 2.2) { b in
                Kit.bust(&b, p, look: CGPoint(x: -0.1, y: 0), mouth: .smile, wave: true)
                helmet(&b)
                oliveTwig(&b, x: 71, y: -4, angle: Kit.deg(-82), length: 40)
                let fist: Path = Art.ellipse(71, 1, 9.5, 9)
                Kit.solid(&b, fist, Art.color(p.skin), light: 0.28, shade: 0.24)
            }
            // The small owl, once, on a ledge at her side.
            Kit.rock(&g, cx: 58, baseY: 404, width: 100, height: 34, color: 0xC4B592, seed: 3)
            Art.group(&g, x: 58, y: 376, scale: 1.1) { o in
                Kit.bird(&o, owlLook(), pose: .perch, look: CGPoint(x: 0.3, y: -0.2))
            }
        }
    }

    /// char-poseidon: half figure, chest out and beard blowing, the trident upright in his
    /// raised fist, white spray and pale sea blue behind.
    static func poseidonPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xCFE8F5, bottom: 0x4E9CC2, halo: 0xF2FAFF, rays: false) { g in
            // Pale sea and breaking crests behind him.
            Art.fill(&g, Art.rect(0, 300, size.width, 100), Art.color(0x3E7FB4, 0.3))
            let crests: Path = Art.svg("M0,330 C20,318 40,318 60,330 C80,342 100,342 120,330 M312,318 C332,306 352,306 372,318 C392,330 412,330 432,318 M0,368 C24,356 48,356 72,368 M340,360 C364,348 388,348 412,360")
            Art.stroke(&g, crests, Art.color(0xFFFFFF, 0.7), width: 3)
            spray(&g, in: CGRect(x: 34, y: 44, width: 120, height: 120), seed: 51)
            spray(&g, in: CGRect(x: 30, y: 210, width: 100, height: 90), seed: 57)

            // The trident stands upright behind his raised fist (x 216 + 71 × 2.2).
            Art.group(&g, x: 372, y: 430, scale: 1.6) { t in
                trident(&t, x: 0, y: 0, length: 190)
            }
            let p = poseidonLook()
            Art.group(&g, x: 216, y: 150, scale: 2.2) { b in
                Kit.bust(&b, p, look: CGPoint(x: -0.1, y: 0), mouth: .grin, wave: true)
                poseidonHead(&b)
                let fist: Path = Art.ellipse(71, 1, 10, 9.5)
                Kit.solid(&b, fist, Art.color(p.skin), light: 0.28, shade: 0.24)
            }
            spray(&g, in: CGRect(x: 320, y: 60, width: 100, height: 110), seed: 63)
        }
    }

    /// face-athena: her calm face under the helmet pushed back.
    static func athenaFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xE8EED2) { g in
            Art.group(&g, x: 0, y: 12, scale: 1.15) { f in
                Kit.personHead(&f, athenaLook(), look: .zero, mouth: .smile)
                helmet(&f)
            }
        }
    }

    /// face-poseidon: the big brows, sea-blue beard and weed-wet hair.
    static func poseidonFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD6E9F7) { g in
            Art.group(&g, x: 0, y: 0, scale: 1.2) { f in
                Kit.personHead(&f, poseidonLook(), look: .zero, mouth: .grin)
                poseidonHead(&f)
            }
        }
    }

    /// face-cecrops: the lean grey king with his plain cloth band.
    static func cecropsFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE9B8) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.3) { f in
                Kit.personHead(&f, cecropsLook(), look: .zero, mouth: .smile)
                headband(&f)
            }
        }
    }
}

// MARK: - Cover

extension OliveArt {
    /// cover: the bare hilltop in bright daylight: the white horse rearing on the right, the
    /// small grey-green olive tree on the left, and a small girl between them looking up at the
    /// tree; pale sky and the thin band of blue sea behind; olive leaves in the top-right corner.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let w: CGFloat = frame.w
            let hd: CGFloat = frame.hd
            let area = CGSize(width: w, height: hd)
            farPlane(&g, area, horizon: H, far: 0.55 * k, light: day(), seed: 3)
            Kit.cloud(&g, 150, H * 0.3, scale: 0.35 * k, color: Art.color(0xFFFFFF, 0.6))
            Kit.ground(&g, width: w, top: H, bottom: hd, stops: rockStops(), seed: 9, tooth: Art.color(0xFFF6DC))
            rockCracks(&g, x0: -10, x1: w, top: H + 3, bottom: hd, count: 9, seed: 4, scale: 0.5 * k)
            let field = CGRect(x: 0, y: H + 4, width: w, height: max(6, hd - H - 8))
            Kit.pebbles(&g, in: field, count: 10, seed: 5, color: 0xCDBE9C)
            if hd > 200 {
                // A tall cover: the rock runs on toward the reader.
                let lowY: CGFloat = H + (hd - H) * 0.6
                scrub(&g, x: 36, baseY: lowY, width: 34, seed: 7)
                Kit.grassTuft(&g, x: 206, baseY: lowY + 10, height: 24, color: strawHex, seed: 2)
                Kit.rock(&g, cx: 150, baseY: hd - 10, width: 60, height: 24, color: 0xC4B592, seed: 9)
            }

            let feet: CGFloat = H + 12 * k
            // The olive tree on the left.
            Art.group(&g, x: 58, y: feet, scale: 0.6 * k) { t in
                oliveTree(&t, fruit: true, seed: 5)
            }
            // The white horse rearing on the right, spray about his hooves.
            Kit.shadow(&g, 178, feet + 2 * k, width: 60 * k, alpha: 0.2)
            Art.group(&g, x: 176, y: feet + 2 * k, scale: 0.56 * k) { a in
                horse(&a, pose: .rear, mood: .happy, look: CGPoint(x: -0.5, y: 0))
            }
            let foam = CGRect(x: 176 - 42 * k, y: feet - 36 * k, width: 84 * k, height: 34 * k)
            Kit.flecks(&g, in: foam, count: 14, seed: 13, color: Art.color(0xFFFFFF, 0.95), radius: 0.6...1.6)
            // The small girl between them, looking up at the tree.
            Kit.shadow(&g, 112, feet + 6 * k, width: 22 * k)
            Art.group(&g, x: 112, y: feet + 6 * k, scale: 0.5 * k) { p in
                folk(&p, 3, pose: .stand, look: CGPoint(x: -0.7, y: -0.8), mouth: .smile)
            }

            // Near framing: a spray of olive reaching in from the top-right corner.
            var dark = Path()
            var pale = Path()
            var stems = Path()
            oliveSpray(&dark, &pale, &stems, from: CGPoint(x: 246, y: -4), angle: Kit.deg(140), length: 40, leaf: 15, pairs: 3)
            oliveSpray(&dark, &pale, &stems, from: CGPoint(x: 248, y: 16), angle: Kit.deg(170), length: 30, leaf: 13, pairs: 2)
            Art.stroke(&g, stems, Art.color(0x5A5446), width: 1.6)
            Art.fill(&g, pale, Art.color(0xB9C8AE))
            Art.fill(&g, dark, Art.color(0x3A5038))
        }
    }
}
