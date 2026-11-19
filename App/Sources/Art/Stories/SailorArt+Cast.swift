import SwiftUI
import OmramoCore

// The cast and the shared parts of "The Shipwrecked Sailor": the palette, the lights, the
// Sailor, the Captain, the townsfolk, the great golden Serpent (the story's bespoke hero),
// the sycomore fig tree and the seagoing ship.
//
// Middle Kingdom Egypt: short white linen kilts, short black hair, no royal headcloths, no
// hieroglyphs. The Serpent is drawn as the papyrus describes him — gold, lapis-blue brows, a
// long narrow plaited beard — and always gentle: large calm eyes, a small smile, no fangs, no
// hood.

extension SailorArt {
    // MARK: Palette

    static let ramp = ArtStyle.Ramp(deep: 0x0E4C7A, shade: 0x1C7FA6, mid: 0x3FA98F, light: 0xCFEAF2, glow: 0xFFE2A0, accent: 0xE8A21C)

    static let gold: UInt32 = 0xE8A21C
    static let goldDark: UInt32 = 0xA9640E
    static let goldLight: UInt32 = 0xFFD45A
    static let lapis: UInt32 = 0x1B4F9C
    static let lapisLight: UInt32 = 0x5A8FE0
    static let linen: UInt32 = 0xFBF6E8
    static let skinHex: UInt32 = 0xA8663C
    static let hairHex: UInt32 = 0x221C1E
    static let hullWood: UInt32 = 0x9A5A30
    static let sailCloth: UInt32 = 0xFBF3DC
    static let sandHex: UInt32 = 0xF4E3B0
    static let mudBrick: UInt32 = 0xD2AA7A
    static let whitewash: UInt32 = 0xF6EEDD
    static let figPurple: UInt32 = 0x8A3A6A

    // MARK: Lights

    /// The bright morning of the island and the open sea.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xBFE3F0), 0), (Art.color(0xDCF0F0), 0.55), (Art.color(0xFFE2A0), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6D8, glow: 0xFFE2A0, haze: 0xE6F2E4, far: 0xA9D4CB, mid: 0x7FC4A6, near: 0x4F9FB0)
    }

    /// The storm seen from far off: a pale silver-lilac sky, never dark.
    static func storm() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD6D8EC), 0), (Art.color(0xE4E3EF), 0.55), (Art.color(0xFFE9C0), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6E0, glow: 0xFFE2A0, haze: 0xE8E6EE, far: 0xB9BBD6, mid: 0x9FA6C8, near: 0x5F8FB0)
    }

    /// The morning of the homecoming on the Nile: pale blue over peach, desert hills far off.
    static func homeMorning() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xCDE6EE), 0), (Art.color(0xF2ECDD), 0.6), (Art.color(0xFFE2A0), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6D8, glow: 0xFFE2A0, haze: 0xF4EBD6, far: 0xE9D2AE, mid: 0xDDBE92, near: 0x6FA08A)
    }

    static func seaStops() -> Kit.Stops {
        [(Art.color(0x56B7CC), 0), (Art.color(0x1C7FA6), 0.5), (Art.color(0x0E4C7A), 1)]
    }

    static func nileStops() -> Kit.Stops {
        [(Art.color(0x7CC6C2), 0), (Art.color(0x3F8E8A), 0.55), (Art.color(0x1F6470), 1)]
    }

    static func sandStops() -> Kit.Stops {
        [(Art.color(0xFBEFC4), 0), (Art.color(0xF4E3B0), 0.5), (Art.color(0xE2C489), 1)]
    }

    static func meadowStops() -> Kit.Stops {
        [(Art.color(0x9BD67E), 0), (Art.color(0x5FB56A), 0.5), (Art.color(0x3C9A6B), 1)]
    }

    static func figGreens() -> Kit.Greens {
        Kit.greens(0x14503C, 0x1F7048, 0x3C9A5A, 0x7CC65E, 0xCDEB7A)
    }

    // MARK: People

    /// The Sailor: a young Egyptian man, short black hair, a short white linen kilt, bare
    /// feet. The kit's collar is drawn in his own skin colour, so only its thin line shows:
    /// that line is his plain cord, and `sailor` hangs the one blue bead on it.
    static func sailorLook() -> Kit.Person {
        Kit.Person(skin: skinHex, hair: hairHex, hairStyle: .short, garment: .kilt, cloth: linen, trim: skinHex, legs: skinHex)
    }

    /// The Captain: older and broader in the face, a little grey in his hair, a wide collar
    /// of plain turquoise beads.
    static func captainLook() -> Kit.Person {
        Kit.Person(skin: 0x96562F, hair: 0x6E6862, hairStyle: .short, garment: .kilt, cloth: linen, trim: 0x2FA39A, legs: 0x96562F)
    }

    /// One of the Sailor's children on the bank.
    static func childLook(_ variant: Int) -> Kit.Person {
        let skin: UInt32 = variant % 2 == 0 ? 0xB0703F : 0xA26238
        return Kit.Person(age: .child, skin: skin, hair: hairHex, hairStyle: .short, garment: .kilt, cloth: linen, trim: skin, legs: skin)
    }

    /// A woman of the town in a long white linen dress.
    static func motherLook() -> Kit.Person {
        Kit.Person(skin: 0xA8663C, hair: hairHex, hairStyle: .bob, garment: .dress, cloth: linen, trim: 0xEFE6D0, legs: 0xA8663C)
    }

    /// The Sailor, whole. Origin at the feet (see `Kit.person`), facing LEFT.
    static func sailor(
        _ context: inout GraphicsContext,
        pose: Kit.Pose,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        let p = sailorLook()
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        if pose == .sleep { return }
        // The blue bead, on the cord at the middle of the chest.
        let rig = Kit.bodyRig(p, pose)
        let turned: CGPoint = Kit.bodyTurn(CGPoint(x: -0.6, y: -41), -Kit.deg(rig.lean))
        let bx: CGFloat = rig.hip.x + turned.x
        let by: CGFloat = rig.hip.y + turned.y
        Art.fill(&context, Art.circle(bx, by, 2.8), Art.color(lapis))
        Art.fill(&context, Art.circle(bx - 0.8, by - 0.9, 0.9), Color.white.opacity(0.8))
    }

    /// The Captain, whole. Origin at the feet, facing LEFT.
    static func captain(
        _ context: inout GraphicsContext,
        pose: Kit.Pose,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .grin,
        mirrored: Bool = false
    ) {
        Kit.person(&context, captainLook(), pose: pose, look: look, mouth: mouth, mirrored: mirrored)
    }
}

// MARK: - The Serpent

extension SailorArt {
    /// Rows of small scale arcs over `rect`, as one path.
    static func serpentScales(in rect: CGRect, step: CGFloat) -> Path {
        var path = Path()
        let area: CGFloat = rect.width * rect.height
        let least: CGFloat = (area / 700).squareRoot()
        let s: CGFloat = max(4, max(step, least))
        var row: Int = 0
        var y: CGFloat = rect.minY
        while y < rect.maxY + s {
            let shift: CGFloat = row % 2 == 0 ? 0 : s / 2
            var x: CGFloat = rect.minX - shift
            while x < rect.maxX {
                path.move(to: CGPoint(x: x, y: y))
                path.addQuadCurve(to: CGPoint(x: x + s, y: y), control: CGPoint(x: x + s / 2, y: y + s * 0.7))
                x += s
            }
            y += s * 0.6
            row += 1
        }
        return path
    }

    /// A stretch of the Serpent's body: `path` is its spine, `width` its thickness. Gold,
    /// with the scale pattern clipped to it, the light along its top and shade under it.
    static func serpentBody(_ context: inout GraphicsContext, _ path: Path, width: CGFloat) {
        let style = StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
        let outline: Path = path.strokedPath(style)
        let bounds: CGRect = outline.boundingRect
        guard bounds.width > 0, bounds.height > 0 else { return }
        Art.fill(&context, outline, Art.color(gold))
        let scales: Path = serpentScales(in: bounds, step: width * 0.26)
        let lit: Path = path.applying(CGAffineTransform(translationX: -width * 0.08, y: -width * 0.27))
        let glint: Path = path.applying(CGAffineTransform(translationX: -width * 0.1, y: -width * 0.33))
        let under: Path = path.applying(CGAffineTransform(translationX: width * 0.08, y: width * 0.32))
        Art.clipped(&context, to: outline) { g in
            Art.stroke(&g, under, Art.color(goldDark, 0.6), width: width * 0.5)
            Art.stroke(&g, under, ArtStyle.coolShade.opacity(0.14), width: width * 0.42)
            Art.stroke(&g, lit, Art.color(goldLight, 0.85), width: width * 0.36)
            Art.stroke(&g, scales, Art.color(goldDark, 0.5), width: max(0.8, width * 0.028))
            Art.stroke(&g, glint, Art.color(0xFFF3C4, 0.6), width: width * 0.09)
        }
        Art.stroke(&context, outline, Art.color(goldDark, 0.55), width: max(0.8, width * 0.03))
    }

    /// The Serpent coiled like a cushion: `turns` flattened coils stacked on `baseY`, the
    /// lowest `width` wide, each `thick` high.
    static func serpentCoils(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, thick: CGFloat, turns: Int) {
        Kit.shadow(&context, cx, baseY, width: width * 1.05)
        for i in 0..<max(1, turns) {
            let t: CGFloat = CGFloat(i)
            let half: CGFloat = max(2, (width - thick) / 2 * (1 - 0.27 * t))
            let cy: CGFloat = baseY - thick / 2 - t * thick * 0.72
            let mx: CGFloat = cx + t * thick * 0.1
            var spine = Path()
            spine.move(to: CGPoint(x: mx - half, y: cy))
            spine.addQuadCurve(to: CGPoint(x: mx + half, y: cy), control: CGPoint(x: mx, y: cy + thick * 0.08))
            if i > 0 {
                // The coil above throws a little shade on the one below.
                Art.fill(&context, Art.ellipse(mx + thick * 0.1, cy + thick * 0.46, half * 1.04, thick * 0.16), ArtStyle.coolShade.opacity(0.2))
            }
            serpentBody(&context, spine, width: thick)
        }
    }

    /// The spine of the neck: from `from` (on the coils) arching `rise` above the higher of
    /// its two ends and down into the back of the head at `head`.
    static func serpentNeck(from: CGPoint, to head: CGPoint, rise: CGFloat) -> Path {
        let top: CGFloat = min(from.y, head.y) - rise
        let dx: CGFloat = from.x - head.x
        var path = Path()
        path.move(to: from)
        path.addCurve(
            to: head,
            control1: CGPoint(x: from.x + dx * 0.12, y: top),
            control2: CGPoint(x: head.x + dx * 0.7, y: top)
        )
        return path
    }

    /// The tapering tail: `width` thick at `from`, a rounded point at `tip`; `lift` raises
    /// (negative) or drops the middle of the curve.
    static func serpentTail(_ context: inout GraphicsContext, from: CGPoint, tip: CGPoint, width: CGFloat, lift: CGFloat = 0) {
        let midX: CGFloat = (from.x + tip.x) / 2
        let midY: CGFloat = (from.y + tip.y) / 2 + lift
        var shape = Path()
        shape.move(to: CGPoint(x: from.x, y: from.y - width / 2))
        shape.addQuadCurve(to: tip, control: CGPoint(x: midX, y: midY - width * 0.42))
        shape.addQuadCurve(to: CGPoint(x: from.x, y: from.y + width / 2), control: CGPoint(x: midX, y: midY + width * 0.36))
        shape.closeSubpath()
        Kit.solid(&context, shape, Art.color(gold), light: 0.3, shade: 0.24)
        let bounds: CGRect = shape.boundingRect
        let scales: Path = serpentScales(in: bounds, step: width * 0.26)
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, scales, Art.color(goldDark, 0.45), width: max(0.8, width * 0.028))
        }
        Art.stroke(&context, shape, Art.color(goldDark, 0.55), width: max(0.8, width * 0.03))
    }

    /// The long narrow plaited beard of lapis and gold, hanging from the chin (drawn before
    /// the head, so the chin covers its root). It curves a little at the tip.
    static func serpentBeard(_ context: inout GraphicsContext) {
        let beard: Path = Art.svg("M-8,38 L8,38 C8,62 7,84 4,98 C2,107 -6,111 -13,106 C-9,103 -6,98 -6,90 C-7,72 -8,56 -8,38Z")
        Kit.solid(&context, beard, Art.color(lapis), light: 0.3, shade: 0.2)
        var plait = Path()
        for i in 0..<6 {
            let y: CGFloat = 50 + CGFloat(i) * 9
            plait.move(to: CGPoint(x: -9, y: y))
            plait.addLine(to: CGPoint(x: 0, y: y + 4))
            plait.addLine(to: CGPoint(x: 9, y: y))
        }
        let bands: Path = plait
        Art.clipped(&context, to: beard) { g in
            Art.stroke(&g, bands, Art.color(goldLight, 0.9), width: 1.5)
        }
        // The gold strap that ties the beard to the chin.
        Art.fill(&context, Art.rect(-9.5, 41, 19, 5, radius: 2), Art.color(goldLight))
    }

    /// The Serpent's head, seen from the front: centred on (0, 0), 120 wide, from y −50 to
    /// the chin at y 46; the beard hangs to y 110. Rounded and friendly: large eyes with
    /// whites, soft lapis brows lifted in the middle, a small smile. `laugh` closes the eyes
    /// into happy arcs and opens the mouth (no teeth).
    static func serpentHead(_ context: inout GraphicsContext, look: CGPoint = .zero, laugh: Bool = false) {
        serpentBeard(&context)
        let head: Path = Art.svg("M0,-50 C30,-50 54,-31 58,-3 C62,24 40,46 0,46 C-40,46 -62,24 -58,-3 C-54,-31 -30,-50 0,-50Z")
        Kit.solid(&context, head, Art.color(gold), light: 0.36, shade: 0.2, rim: 2.4)
        let crown: Path = serpentScales(in: CGRect(x: -46, y: -50, width: 92, height: 22), step: 9)
        Art.clipped(&context, to: head) { g in
            Art.stroke(&g, crown, Art.color(goldDark, 0.4), width: 1.1)
            // The paler muzzle.
            Art.fill(&g, Art.ellipse(0, 26, 42, 24), Art.color(0xFFE596, 0.75))
            Art.fill(&g, Art.ellipse(-16, -34, 26, 10), Art.color(0xFFF3C4, 0.35))
        }
        Art.stroke(&context, head, Art.color(goldDark, 0.6), width: 1.4)
        serpentFace(&context, look: look, laugh: laugh)
    }

    /// Eyes, lapis brows, nostrils, cheeks and mouth of the Serpent.
    static func serpentFace(_ context: inout GraphicsContext, look: CGPoint, laugh: Bool) {
        let line: Color = Art.color(0x7A420A)
        if laugh {
            let lids: Path = Art.svg("M-37,-6 Q-24,-19 -11,-6 M11,-6 Q24,-19 37,-6")
            Art.stroke(&context, lids, Art.color(0x2A1A12), width: 3.4)
        } else {
            var sockets = Path()
            sockets.addPath(Art.circle(-24, -8, 16.6))
            sockets.addPath(Art.circle(24, -8, 16.6))
            Art.fill(&context, sockets, Art.color(goldDark, 0.55))
            ArtStyle.eye(&context, -24, -8, 15, look: look, iris: Art.color(0x2A1A12), showsWhite: true)
            ArtStyle.eye(&context, 24, -8, 15, look: look, iris: Art.color(0x2A1A12), showsWhite: true)
        }
        // Brows of lapis: soft arcs, highest toward the middle of the face — never a frown.
        let brows: Path = Art.svg("M-43,-25 Q-28,-41 -9,-32 M9,-32 Q28,-41 43,-25")
        Art.stroke(&context, brows, Art.color(lapis), width: 6.4)
        let browLight: Path = Art.svg("M-40,-27.5 Q-28,-40 -13,-33.5 M13,-33.5 Q24,-39 34,-33")
        Art.stroke(&context, browLight, Art.color(lapisLight, 0.9), width: 1.6)
        var nostrils = Path()
        nostrils.addPath(Art.ellipse(-6.5, 15, 2.2, 1.6))
        nostrils.addPath(Art.ellipse(6.5, 15, 2.2, 1.6))
        Art.fill(&context, nostrils, line.opacity(0.8))
        ArtStyle.cheek(&context, -40, 15, 11, alpha: 0.45)
        ArtStyle.cheek(&context, 40, 15, 11, alpha: 0.45)
        if laugh {
            let mouth: Path = Art.svg("M-21,24 C-10,28 10,28 21,24 C18,38 8,42 0,42 C-8,42 -18,38 -21,24Z")
            Art.fill(&context, mouth, Art.color(0x7A2E24))
            Art.clipped(&context, to: mouth) { g in
                Art.fill(&g, Art.ellipse(0, 41, 9, 5), Art.color(0xE8776A))
            }
            Art.stroke(&context, Art.svg("M-21,24 C-10,28 10,28 21,24"), line, width: 1.8)
        } else {
            ArtStyle.smile(&context, 0, 26, width: 44, curve: 5, color: line, lineWidth: 2.6)
            var dimples = Path()
            dimples.addPath(Art.circle(-23, 25.4, 1.7))
            dimples.addPath(Art.circle(23, 25.4, 1.7))
            Art.fill(&context, dimples, line)
        }
    }
}

// MARK: - The fig tree and other plants

extension SailorArt {
    /// A sycomore fig: the kit's broadleaf tree with a fuller crown and clusters of small
    /// purple figs on the boughs and on the trunk.
    static func figTree(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, spread: CGFloat, seed: UInt32) {
        let palette: Kit.Greens = figGreens()
        Kit.tree(&context, x: x, baseY: baseY, height: height, spread: spread, palette: palette, bark: 0x8A6A52, seed: seed)
        let ry: CGFloat = height * 0.34
        let rx: CGFloat = spread / 2
        let cy: CGFloat = baseY - height + ry
        let spots: [(CGFloat, CGFloat, CGFloat)] = [
            (-0.62, 0.2, 0.42), (-0.2, -0.3, 0.5), (0.3, -0.25, 0.48), (0.66, 0.15, 0.42),
            (0, 0.3, 0.5), (-0.4, 0.5, 0.32), (0.42, 0.52, 0.32),
        ]
        var blobs: [Kit.Blob] = []
        for spot in spots {
            let blob: Kit.Blob = (x + spot.0 * rx, cy + spot.1 * ry, spot.2 * ry)
            blobs.append(blob)
        }
        Kit.canopy(&context, blobs, seed: seed &+ 5, palette: palette, density: 2)

        var random = ArtRandom(seed &+ 9)
        var fruit = Path()
        var shine = Path()
        let r: CGFloat = max(2, height * 0.017)
        for index in 0..<11 {
            var fx: CGFloat = x + (Kit.rnd(&random) - 0.5) * rx * 1.5
            var fy: CGFloat = cy + (Kit.rnd(&random) - 0.25) * ry * 1.2
            if index >= 9 {
                // Sycomore figs also grow straight from the trunk.
                fx = x + (Kit.rnd(&random) - 0.5) * height * 0.04
                fy = baseY - height * (0.2 + 0.12 * CGFloat(index - 9))
            }
            let offsets: [(CGFloat, CGFloat)] = [(0, 0), (1.5, 0.9), (-0.7, 1.6)]
            for offset in offsets {
                let px: CGFloat = fx + offset.0 * r
                let py: CGFloat = fy + offset.1 * r
                fruit.addEllipse(in: CGRect(x: px - r, y: py - r, width: r * 2, height: r * 2.1))
                shine.addEllipse(in: CGRect(x: px - r * 0.6, y: py - r * 0.7, width: r * 0.7, height: r * 0.7))
            }
        }
        Art.fill(&context, fruit, Art.color(figPurple))
        Art.fill(&context, shine, Art.color(0xE7A6C6, 0.85))
    }

    /// A date palm in the story's colours.
    static func datePalm(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, lean: CGFloat, seed: UInt32) {
        Kit.palm(&context, x: x, baseY: baseY, height: height, lean: lean, fronds: 0x3A8F58, trunk: 0x8A6A4A, seed: seed)
    }

    /// A striped melon lying on the ground with a curl of vine, centred on (x, baseY).
    static func melon(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width: CGFloat) {
        let h: CGFloat = width * 0.68
        Kit.shadow(&context, x, baseY, width: width)
        let vine: Path = Art.svg("M0,0 C-10,-14 -24,-10 -30,-2 C-34,4 -42,2 -44,-6")
        let placed: Path = vine.applying(CGAffineTransform(translationX: x - width * 0.4, y: baseY - h * 0.5).scaledBy(x: width / 44, y: width / 44))
        Art.stroke(&context, placed, Art.color(0x3C9A5A), width: max(1.2, width * 0.05))
        let body: Path = Art.ellipse(x, baseY - h / 2, width / 2, h / 2)
        Kit.solid(&context, body, Art.color(0x4FA450), light: 0.34, shade: 0.26)
        var stripes = Path()
        let offsets: [CGFloat] = [-0.55, -0.2, 0.15, 0.5]
        for offset in offsets {
            let sx: CGFloat = x + offset * width / 2
            stripes.move(to: CGPoint(x: sx, y: baseY - h))
            stripes.addQuadCurve(to: CGPoint(x: sx, y: baseY), control: CGPoint(x: sx + offset * width * 0.3, y: baseY - h / 2))
        }
        let lines: Path = stripes
        Art.clipped(&context, to: body) { g in
            Art.stroke(&g, lines, Art.color(0x2E7A40, 0.8), width: max(1.2, width * 0.06))
        }
    }

    /// The plank that carried the Sailor: a weathered board lying at (x, y), `length` long.
    static func plank(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, length: CGFloat, tilt: CGFloat) {
        Art.group(&context, x: x, y: y, rotate: tilt) { g in
            let half: CGFloat = length / 2
            let depth: CGFloat = max(4, length * 0.13)
            Art.fill(&g, Art.ellipse(3, depth * 0.9, half * 1.02, depth * 0.5), ArtStyle.coolShade.opacity(0.2))
            let board: Path = Art.rect(-half, -depth / 2, length, depth, radius: 2)
            Kit.solid(&g, board, Art.color(0xB98A5A), light: 0.3, shade: 0.24)
            let grain: Path = Art.line(-half * 0.8, 0, half * 0.7, 0)
            Art.stroke(&g, grain, Art.color(0x7A5230, 0.6), width: 1)
            Art.stroke(&g, Art.line(-half * 0.9, -depth * 0.36, half * 0.9, -depth * 0.36), Art.color(0xE8C79A, 0.8), width: 1)
        }
    }
}

// MARK: - The ship

extension SailorArt {
    /// A point on the sheer (the top edge) of the kit's Nile hull: t 0 is the bow (left),
    /// t 1 the stern.
    static func railPoint(_ t: CGFloat, cx: CGFloat, waterY: CGFloat, length L: CGFloat) -> CGPoint {
        let u: CGFloat = 1 - t
        let a: CGFloat = u * u * u
        let b: CGFloat = 3 * u * u * t
        let c: CGFloat = 3 * u * t * t
        let d: CGFloat = t * t * t
        let xFore: CGFloat = -0.5 * a - 0.3 * b
        let xAft: CGFloat = 0.3 * c + 0.5 * d
        let yFore: CGFloat = -0.28 * a + 0.02 * b
        let yAft: CGFloat = 0.02 * c - 0.32 * d
        return CGPoint(x: cx + (xFore + xAft) * L, y: waterY + (yFore + yAft) * L)
    }

    /// Everything above the ship's rail: people drawn clipped to this stand inside the hull.
    static func aboveRail(cx: CGFloat, waterY: CGFloat, length L: CGFloat) -> Path {
        let p0: CGPoint = railPoint(0, cx: cx, waterY: waterY, length: L)
        let p1: CGPoint = railPoint(1, cx: cx, waterY: waterY, length: L)
        var above = Path()
        above.move(to: CGPoint(x: cx - L, y: waterY - L * 2))
        above.addLine(to: CGPoint(x: cx - L, y: p0.y))
        above.addLine(to: p0)
        above.addCurve(
            to: p1,
            control1: CGPoint(x: cx - 0.3 * L, y: waterY + 0.02 * L),
            control2: CGPoint(x: cx + 0.3 * L, y: waterY + 0.02 * L)
        )
        above.addLine(to: CGPoint(x: cx + L, y: p1.y))
        above.addLine(to: CGPoint(x: cx + L, y: waterY - L * 2))
        above.closeSubpath()
        return above
    }

    /// The great seagoing ship, bow to the LEFT, waterline at `waterY`: the kit's Nile boat
    /// with the things the tale's ship has — a second yard at the foot of the wide sail, the
    /// thick rope high along the hull from bow to stern, a row of oars, a second steering
    /// oar — and its people. `sailUp` false furls the sail on the upper yard. `bow`: 0 nobody
    /// stands at the bow, 1 the Sailor (waving), 2 the Sailor and the Captain. `crewSize` is
    /// their height as a share of the hull's length. `heads` adds the rowers' heads along
    /// the rail. `mirrored`: the caller has flipped x (the ship sails to the right).
    static func ship(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        waterY: CGFloat,
        length: CGFloat,
        sailUp: Bool,
        bow: Int,
        crewSize: CGFloat = 0.3,
        heads: Bool = true,
        mirrored: Bool = false
    ) {
        let L: CGFloat = max(40, length)
        let cloth: UInt32? = sailUp ? sailCloth : nil
        Kit.boat(&context, cx: cx, waterY: waterY, length: L, hull: hullWood, sail: cloth, style: .nile)
        shipRig(&context, cx: cx, waterY: waterY, length: L, sailUp: sailUp)
        shipPeople(&context, cx: cx, waterY: waterY, length: L, bow: bow, crewSize: crewSize, heads: heads, mirrored: mirrored)
        shipOars(&context, cx: cx, waterY: waterY, length: L)
        Kit.ripples(&context, cx, waterY + L * 0.05, L * 0.84, count: 2)
        // A little foam where the bow cuts the water.
        let foam: Path = Art.ellipse(cx - L * 0.36, waterY + L * 0.03, L * 0.07, L * 0.012)
        Art.fill(&context, foam, Color.white.opacity(0.6))
    }

    static func shipRig(_ context: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, length L: CGFloat, sailUp: Bool) {
        let woodHex: UInt32 = Kit.propToneHex(hullWood, 0.62)
        let lw: CGFloat = max(1.2, L * 0.018)
        let half: CGFloat = L * 0.31
        let yardY: CGFloat = waterY - L * 0.61
        let footY: CGFloat = waterY - L * 0.24
        if sailUp {
            // The lower yard: the sail hangs between two yards.
            Kit.propShaft(&context, cx - half * 1.02, footY, cx + half * 1.02, footY, wood: woodHex, width: lw * 0.9)
        } else {
            // The sail, furled along the upper yard and tied.
            var roll = Path()
            roll.move(to: CGPoint(x: cx - half, y: yardY + lw * 1.6))
            roll.addQuadCurve(to: CGPoint(x: cx + half, y: yardY + lw * 1.6), control: CGPoint(x: cx, y: yardY + lw * 3.4))
            Art.stroke(&context, roll, Art.color(sailCloth), width: lw * 3)
            Art.stroke(&context, roll, Kit.propTone(sailCloth, 0.8), width: lw * 0.5)
            var ties = Path()
            let offsets: [CGFloat] = [-0.8, -0.4, 0, 0.4, 0.8]
            for offset in offsets {
                let tx: CGFloat = cx + half * offset
                ties.move(to: CGPoint(x: tx, y: yardY))
                ties.addLine(to: CGPoint(x: tx, y: yardY + lw * 4.2))
            }
            Art.stroke(&context, ties, Art.color(woodHex), width: lw * 0.5)
        }
        // The thick rope that runs high along the ship, over two forked posts.
        let postTop: CGFloat = waterY - L * 0.2
        Kit.propShaft(&context, cx - L * 0.24, waterY - L * 0.07, cx - L * 0.24, postTop, wood: woodHex, width: lw * 0.8)
        Kit.propShaft(&context, cx + L * 0.24, waterY - L * 0.07, cx + L * 0.24, postTop, wood: woodHex, width: lw * 0.8)
        let p0: CGPoint = railPoint(0.03, cx: cx, waterY: waterY, length: L)
        let p1: CGPoint = railPoint(0.97, cx: cx, waterY: waterY, length: L)
        var rope = Path()
        rope.move(to: p0)
        rope.addLine(to: CGPoint(x: cx - L * 0.24, y: postTop))
        rope.addQuadCurve(to: CGPoint(x: cx + L * 0.24, y: postTop), control: CGPoint(x: cx, y: postTop + L * 0.02))
        rope.addLine(to: p1)
        Art.stroke(&context, rope, Art.color(0xE2C283), width: max(1.2, L * 0.012))
        // The second steering oar.
        Kit.propShaft(&context, cx + L * 0.27, waterY - L * 0.3, cx + L * 0.4, waterY + L * 0.01, wood: woodHex, width: lw * 0.9)
        let blade: Path = Art.line(cx + L * 0.37, waterY - L * 0.06, cx + L * 0.41, waterY + L * 0.03)
        Art.stroke(&context, blade, Kit.propTone(hullWood, 0.75), width: lw * 2.2)
    }

    static func shipOars(_ context: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, length L: CGFloat) {
        var shafts = Path()
        var blades = Path()
        for i in 0..<7 {
            let t: CGFloat = 0.3 + 0.07 * CGFloat(i)
            let p: CGPoint = railPoint(t, cx: cx, waterY: waterY, length: L)
            let top = CGPoint(x: p.x, y: p.y + L * 0.035)
            let end = CGPoint(x: p.x - L * 0.07, y: waterY + L * 0.08)
            let neck = CGPoint(x: Kit.mix(top.x, end.x, 0.7), y: Kit.mix(top.y, end.y, 0.7))
            shafts.move(to: top)
            shafts.addLine(to: end)
            blades.move(to: neck)
            blades.addLine(to: end)
        }
        Art.stroke(&context, shafts, Kit.propTone(hullWood, 0.6), width: max(1, L * 0.009))
        Art.stroke(&context, blades, Kit.propTone(hullWood, 1.25), width: max(1.6, L * 0.02))
    }

    static func shipPeople(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        waterY: CGFloat,
        length L: CGFloat,
        bow: Int,
        crewSize: CGFloat,
        heads: Bool,
        mirrored: Bool
    ) {
        let above: Path = aboveRail(cx: cx, waterY: waterY, length: L)
        let scale: CGFloat = L * crewSize / 168
        let sailorAt: CGPoint = railPoint(0.2, cx: cx, waterY: waterY, length: L)
        let captainAt: CGPoint = railPoint(0.31, cx: cx, waterY: waterY, length: L)
        let sink: CGFloat = L * crewSize * 0.2
        Art.clipped(&context, to: above) { g in
            if heads {
                var skins = Path()
                var hairs = Path()
                let r: CGFloat = L * 0.021
                for i in 0..<6 {
                    let t: CGFloat = 0.4 + 0.065 * CGFloat(i)
                    let p: CGPoint = railPoint(t, cx: cx, waterY: waterY, length: L)
                    let hy: CGFloat = p.y - r * 0.8
                    skins.addEllipse(in: CGRect(x: p.x - r, y: hy - r, width: r * 2, height: r * 2))
                    skins.addEllipse(in: CGRect(x: p.x - r * 1.5, y: hy + r * 0.8, width: r * 3, height: r * 1.6))
                    hairs.addEllipse(in: CGRect(x: p.x - r * 1.02, y: hy - r * 1.1, width: r * 2.04, height: r * 1.15))
                }
                Art.fill(&g, skins, Art.color(skinHex))
                Art.fill(&g, hairs, Art.color(hairHex))
            }
            if bow >= 2 {
                Art.group(&g, x: captainAt.x, y: captainAt.y + sink, scale: scale) { c in
                    captain(&c, pose: .reach, look: CGPoint(x: -0.5, y: 0), mouth: .grin, mirrored: mirrored)
                }
            }
            if bow >= 1 {
                Art.group(&g, x: sailorAt.x, y: sailorAt.y + sink, scale: scale) { s in
                    sailor(&s, pose: .wave, look: CGPoint(x: -0.5, y: 0), mouth: .grin, mirrored: mirrored)
                }
            }
        }
    }
}
