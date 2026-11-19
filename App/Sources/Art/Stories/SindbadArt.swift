import SwiftUI
import OmramoCore

/// Concept art for "Sindbad's Second Voyage", drawn in code (round 5; composed from the shared kit).
///
/// The cast and the story's own parts (the dhow, the egg, the Roc's wing and leg, the stones,
/// the nest) are in `SindbadArt+Cast.swift`; the four folded compositions in
/// `SindbadArt+Folded.swift`; the tap pictures, portraits, faces and cover in
/// `SindbadArt+Pictures.swift`. This file holds the entry point and the four unfolded scenes.
enum SindbadArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-harbour", .sceneUnfolded): harbourScene(&context, size)
        case ("scene-harbour", .sceneFolded): harbourFolded(&context, size)
        case ("scene-egg", .sceneUnfolded): eggScene(&context, size)
        case ("scene-egg", .sceneFolded): eggFolded(&context, size)
        case ("scene-valley", .sceneUnfolded): valleyScene(&context, size)
        case ("scene-valley", .sceneFolded): valleyFolded(&context, size)
        case ("scene-nest", .sceneUnfolded): nestScene(&context, size)
        case ("scene-nest", .sceneFolded): nestFolded(&context, size)
        case ("see-dhow", .picture): dhowPicture(&context, size)
        case ("see-the-nights", .picture): nightsPicture(&context, size)
        case ("see-basra", .picture): basraPicture(&context, size)
        case ("char-sindbad", .portrait): sindbadPortrait(&context, size)
        case ("char-roc", .portrait): rocPortrait(&context, size)
        case ("face-sindbad", .face): sindbadFace(&context, size)
        case ("face-roc", .face): rocFace(&context, size)
        case ("face-merchant", .face): merchantFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Scene 1: the port of Basra

extension SindbadArt {
    /// The wide brown-green river.
    static func riverStops() -> Kit.Stops {
        [(Art.color(0xA9D3C6), 0), (Art.color(0x7DB5A6), 0.5), (Art.color(0x5A948C), 1)]
    }

    /// The brick quay in the near plane: its far edge runs level at `edgeY` from `x0` to past
    /// the trailing edge, and its end slants toward the viewer down to `floorY`.
    static func quay(_ g: inout GraphicsContext, x0: CGFloat, edgeY: CGFloat, floorY: CGFloat) {
        let run: CGFloat = max(1, floorY - edgeY)
        let bx: CGFloat = x0 - run * 0.86
        let top = Art.polygon([
            CGPoint(x: x0, y: edgeY), CGPoint(x: 960, y: edgeY), CGPoint(x: 960, y: floorY), CGPoint(x: bx, y: floorY),
        ])
        let face = Art.polygon([
            CGPoint(x: x0, y: edgeY), CGPoint(x: bx, y: floorY), CGPoint(x: bx - 40, y: floorY), CGPoint(x: x0 - 16, y: edgeY + 14),
        ])
        Art.fill(&g, face, Art.color(0xA9865A))
        Art.fill(&g, face, ArtStyle.coolShade.opacity(0.18))
        let paving: Kit.Stops = [(Art.color(0xEAD3A6), 0), (Art.color(0xD6B682), 1)]
        Art.fillLinear(&g, top, paving, from: CGPoint(x: 0, y: edgeY), to: CGPoint(x: 0, y: floorY))
        let box = CGRect(x: bx, y: edgeY, width: 960 - bx, height: run)
        let courses: Path = Kit.builtCourses(box, seed: 17)
        Art.clipped(&g, to: top) { c in
            Art.stroke(&c, courses, Art.color(0xB08A5C, 0.55), width: 1.2)
            ArtStyle.tooth(&c, in: box, seed: 23, color: Art.color(0xFFF2D0), alpha: 0.08)
        }
        Art.stroke(&g, Art.line(x0, edgeY, 960, edgeY), Art.color(0xF8E9C4), width: 2.4)
        Art.stroke(&g, Art.line(x0, edgeY, bx, floorY), Art.color(0xF8E9C4, 0.8), width: 2)
    }

    /// The far bank of Basra: a low strip of land, flat mud-brick roofs and a line of date
    /// palms, then the veil of air. In the picture's own units.
    static func basraFar(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light) {
        Art.fill(&context, Art.rect(0, H - 7 * s, w, 9 * s), light.far)
        let wall: Color = Art.color(0xDCCBA6)
        let roof: Color = Art.color(0xBFA880)
        let houses: [(CGFloat, CGFloat, CGFloat)] = [
            (0.08, 34, 16), (0.2, 26, 13), (0.36, 40, 15), (0.5, 28, 14), (0.63, 36, 17), (0.78, 30, 13), (0.93, 38, 16),
        ]
        for house in houses {
            Kit.farHouse(&context, cx: w * house.0, baseY: H - 5 * s, width: house.1 * s, height: house.2 * s, wall: wall, roof: roof, flat: true)
        }
        farPalms(&context, x0: 0, x1: w, baseY: H - 4 * s, height: 34 * s, count: 18, color: Art.color(0x7FAF98), seed: 3)
        ArtStyle.atmosphere(&context, width: w, top: H - 60 * s, bottom: H + 4, color: light.haze, alpha: 0.3)
    }

    static func harbourScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = day()
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 650, st.H * 0.2, scale: 0.9 * st.far, color: Color.white.opacity(0.8))
        Kit.cloud(&context, 250, st.H * 0.13, scale: 0.55 * st.far, color: Color.white.opacity(0.5))
        basraFar(&context, width: w, horizon: st.H, scale: st.far, light: light)
        Kit.water(&context, width: w, top: st.H, bottom: h, stops: riverStops(), light: light, ripples: 46, seed: 31)
        farDhow(&context, x: 170, waterY: st.H + 12 * st.far, scale: 1.1 * st.far)
        farDhow(&context, x: 338, waterY: st.H + 5 * st.far, scale: 0.55 * st.far)
        Kit.birds(&context, 300, st.H - 56 * st.far, scale: 0.8, color: Art.color(0x6A8F8A, 0.6))
        if st.tall > 0.25 {
            // The deeper river of a tall window: a rowing boat and reeds on the leading side.
            let boatY: CGFloat = st.H + st.depth * 0.46
            Kit.boat(&context, cx: 190, waterY: boatY, length: 110, hull: hullWood, sail: nil, style: .rowing)
            Kit.ripples(&context, 190, boatY + 2, 120, count: 2)
            Kit.reeds(&context, x: 120, baseY: h - 30, count: 6, height: 84, seed: 12, color: 0x5A9272)
            Kit.swells(&context, width: w, top: st.H + st.depth * 0.3, bottom: h, rows: 5, crest: Color.white, seed: 14)
        }
        let Hv: CGFloat = st.Hv
        let floorY: CGFloat = Hv + st.depth / st.fit + 40
        Kit.designSpace(&context, st) { v in
            // The town behind the ship: warehouses and date palms on the low bank.
            Art.fill(&v, Art.rect(452, Hv - 2, 440, 10), Art.color(0xCDB88C))
            Kit.house(&v, cx: 520, baseY: Hv + 4, width: 84, wallHeight: 42, roofHeight: 8, wall: mudBrick, roof: mudRoof, style: .flat, door: 0x6A4630, windows: 1)
            Kit.house(&v, cx: 846, baseY: Hv + 4, width: 76, wallHeight: 50, roofHeight: 8, wall: 0xE0C292, roof: mudRoof, style: .flat, door: 0x6A4630, windows: 2)
            Kit.palm(&v, x: 474, baseY: Hv + 6, height: 112, lean: -8, fronds: palmGreen, trunk: 0x8A6A4A, seed: 4)
            Kit.palm(&v, x: 584, baseY: Hv + 6, height: 138, lean: 6, fronds: palmGreen, trunk: 0x8A6A4A, seed: 7)
            Kit.palm(&v, x: 880, baseY: Hv + 6, height: 150, lean: -10, fronds: 0x357A56, trunk: 0x8A6A4A, seed: 9)
            ArtStyle.atmosphere(&v, width: 892, top: Hv - 170, bottom: Hv + 8, color: light.haze, alpha: 0.2)
            Kit.nearSpace(&v, st, anchorX: 690) { n in
                harbourNear(&n, Hv: Hv, floorY: floorY)
            }
        }
        Kit.reeds(&context, x: 34, baseY: h - 6, count: 7, height: 58 * st.far, seed: 9, color: 0x4E8A6A)
        ArtStyle.finish(&context, size)
    }

    /// The moored dhow, the quay with its cargo and porters, and Sindbad on the gangplank,
    /// in near-plane units (horizon at `Hv`).
    static func harbourNear(_ n: inout GraphicsContext, Hv: CGFloat, floorY: CGFloat) {
        let waterY: CGFloat = Hv + 62
        Art.group(&n, x: 690, y: waterY, scale: 1.9) { s in
            dhow(&s, full: false)
        }
        Kit.ripples(&n, 520, waterY + 3, 120, count: 2)
        Art.fill(&n, Art.ellipse(680, waterY + 8, 200, 7), ArtStyle.coolShade.opacity(0.16))
        quay(&n, x0: 548, edgeY: Hv + 74, floorY: floorY)
        // The mooring post and its rope to the stem head.
        var line = Path()
        line.move(to: CGPoint(x: 576, y: Hv + 80))
        line.addQuadCurve(to: CGPoint(x: 478, y: Hv - 10), control: CGPoint(x: 540, y: Hv + 62))
        Art.stroke(&n, line, Art.color(0x8A6A48), width: 2)
        Kit.shadow(&n, 578, Hv + 100, width: 26)
        Kit.propShaft(&n, 576, Hv + 100, 576, Hv + 74, wood: sparWood, width: 9)
        // The gangplank from the quay up to the gunwale.
        let plank = Art.polygon([
            CGPoint(x: 846, y: Hv + 104), CGPoint(x: 668, y: Hv + 16), CGPoint(x: 660, y: Hv + 24), CGPoint(x: 832, y: Hv + 114),
        ])
        Kit.solid(&n, plank, Art.color(0xB58A5C), light: 0.24, shade: 0.2)
        Art.stroke(&n, Art.line(846, Hv + 104, 668, Hv + 16), Art.color(0xE9CFA0), width: 1.6)
        Kit.shadow(&n, 756, Hv + 64, width: 46, alpha: 0.2)
        Art.group(&n, x: 754, y: Hv + 60, scale: 0.74) { s in
            sindbadWithBale(&s)
        }
        // On the quay: the waiting cargo and two porters.
        cargo(&n, x: 676, baseY: Hv + 150)
        Kit.shadow(&n, 590, Hv + 152, width: 50)
        Art.group(&n, x: 588, y: Hv + 150, scale: 0.72, scaleX: -1) { s in
            porterWithBale(&s, tunic: 0xC9B79A, mirrored: true)
        }
        Kit.shadow(&n, 848, Hv + 114, width: 46)
        Art.group(&n, x: 846, y: Hv + 112, scale: 0.68) { s in
            porterWithBale(&s, tunic: 0x9FB6A8)
        }
        Kit.basket(&n, cx: 812, baseY: Hv + 176, width: 46, height: 30, color: 0xC89A54, lid: false, handles: true)
        Kit.heap(&n, cx: 812, baseY: Hv + 150, width: 34, count: 7, color: 0x8A4A26, leaf: nil, seed: 3)
    }
}

// MARK: - Scene 2: the egg on the island

extension SindbadArt {
    /// The island's grass from the horizon down.
    static func islandGround() -> Kit.Stops {
        [(Art.color(0xB2D8A0), 0), (Art.color(0x92C482), 0.5), (Art.color(0x72AA6C), 1)]
    }

    /// A round-crowned evergreen fruit tree with ripe fruits in its crown. `hazy` paints it
    /// through the air (the far trees).
    static func fruitTree(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height h: CGFloat, seed: UInt32, hazy: Bool = false) {
        let spread: CGFloat = h * 0.86
        let palette: Kit.Greens = hazy ? hazyGreens() : islandGreens()
        Kit.tree(&context, x: x, baseY: baseY, height: h, spread: spread, palette: palette, bark: 0x6B5040, seed: seed)
        let cy: CGFloat = baseY - h * 0.66
        let rx: CGFloat = spread * 0.36
        let ry: CGFloat = h * 0.22
        let r: CGFloat = max(1.4, h * 0.026)
        var random = ArtRandom(seed &+ 9)
        var fruit = Path()
        var shine = Path()
        for _ in 0..<9 {
            let a: CGFloat = Kit.rnd(&random) * CGFloat.pi * 2
            let d: CGFloat = 0.3 + Kit.rnd(&random) * 0.65
            let fx: CGFloat = x + cos(a) * rx * d
            let fy: CGFloat = cy + sin(a) * ry * d
            fruit.addPath(Art.circle(fx, fy, r))
            shine.addPath(Art.circle(fx - r * 0.35, fy - r * 0.38, r * 0.34))
        }
        let fruitColor: Color = hazy ? Art.color(0xEBC29C) : Art.color(0xE8892E)
        Art.fill(&context, fruit, fruitColor)
        if !hazy {
            Art.fill(&context, shine, Art.color(0xFFE2A0, 0.85))
        }
    }

    /// The clear stream winding out of the trees toward the viewer on the leading side, in
    /// design units; `bottom` is the foot of the picture.
    static func islandStream(_ v: inout GraphicsContext, Hv: CGFloat, bottom: CGFloat) {
        let depth: CGFloat = max(60, bottom - Hv)
        let p0 = CGPoint(x: 340, y: Hv + 6)
        let p1 = CGPoint(x: 150, y: Hv + depth * 0.22)
        let p2 = CGPoint(x: 330, y: Hv + depth * 0.62)
        let p3 = CGPoint(x: 70, y: bottom + 12)
        var left: [CGPoint] = []
        var right: [CGPoint] = []
        var middle: [CGPoint] = []
        for i in 0...16 {
            let t: CGFloat = CGFloat(i) / 16
            let u: CGFloat = 1 - t
            let a: CGFloat = u * u * u
            let b: CGFloat = 3 * u * u * t
            let c: CGFloat = 3 * u * t * t
            let d: CGFloat = t * t * t
            let x: CGFloat = a * p0.x + b * p1.x + c * p2.x + d * p3.x
            let y: CGFloat = a * p0.y + b * p1.y + c * p2.y + d * p3.y
            let half: CGFloat = 3 + t * t * 52
            left.append(CGPoint(x: x - half, y: y))
            right.append(CGPoint(x: x + half, y: y))
            middle.append(CGPoint(x: x - half * 0.3, y: y))
        }
        let banks: [CGPoint] = left + right.reversed()
        let water = Art.polygon(banks)
        let bed: Kit.Stops = [(Art.color(0xD6F1EE), 0), (Art.color(0xA9DCD8), 1)]
        Art.stroke(&v, water, Art.color(0x7FB07A, 0.7), width: 5)
        Art.fillLinear(&v, water, bed, from: CGPoint(x: 0, y: Hv), to: CGPoint(x: 0, y: bottom))
        Art.stroke(&v, Art.polygon(middle, closed: false), Color.white.opacity(0.55), width: 1.6)
        Kit.rippleMarks(&v, x0: 60, x1: 360, y0: Hv + depth * 0.3, y1: bottom, count: 8, seed: 19, color: Color.white, alpha: 0.4)
    }

    static func eggScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = day()
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 620, st.H * 0.26, scale: 0.7 * st.far, color: Color.white.opacity(0.7))
        Kit.cloud(&context, 210, st.H * 0.12, scale: 0.45 * st.far, color: Color.white.opacity(0.45))
        // The thin line of sea, and the dhow far out on it: a white speck.
        let seaTop: CGFloat = st.H - 9 * st.far
        Art.fill(&context, Art.rect(0, seaTop, w, st.H - seaTop + 2), Art.color(0x9ED5D3))
        Art.fill(&context, Art.rect(0, seaTop, w, 1.4), Color.white.opacity(0.6))
        farDhow(&context, x: 96, waterY: st.H - 3 * st.far, scale: 0.42 * st.far)
        Kit.farTrees(&context, x0: 250, x1: w, baseY: st.H + 2, height: 34 * st.far, count: 16, color: Art.color(0xA6CDB4), seed: 6)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 50 * st.far, bottom: st.H + 4, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: w, top: st.H, bottom: h, stops: islandGround(), seed: 41)
        let Hv: CGFloat = st.Hv
        let bottom: CGFloat = st.hv
        Kit.designSpace(&context, st) { v in
            islandStream(&v, Hv: Hv, bottom: bottom)
            Kit.bush(&v, x: 70, baseY: Hv + 16, width: 54, palette: hazyGreens(), seed: 3)
            Kit.bush(&v, x: 392, baseY: Hv + 12, width: 44, palette: hazyGreens(), seed: 8)
            fruitTree(&v, x: 506, baseY: Hv + 8, height: 120, seed: 11, hazy: true)
            ArtStyle.atmosphere(&v, width: 892, top: Hv - 130, bottom: Hv + 10, color: light.haze, alpha: 0.16)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                eggNear(&n, Hv: Hv)
            }
            // The edge of the Roc's wing enters at the top of the trailing corner.
            rocWing(&v, root: CGPoint(x: 950, y: -30), from: 118, to: 172, length: 250, count: 9)
        }
        if st.tall > 0.25 {
            // The deeper meadow of a tall window: grass, small flowers, a near bush.
            let top: CGFloat = st.H + st.depth * 0.45
            let rect = CGRect(x: 330, y: top, width: w - 330, height: max(10, h - top - 24))
            Kit.grass(&context, in: rect, count: 46, seed: 12, color: Art.color(0x5E9A5E), height: 16)
            Kit.flowers(&context, in: rect.insetBy(dx: 20, dy: 16), count: 16, seed: 13, petal: 0xFFF3D6)
            Kit.bush(&context, x: 30, baseY: h - 6, width: 130, palette: islandGreens(), seed: 21)
        }
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x1F5A48), scale: st.far, seed: 5)
        ArtStyle.finish(&context, size)
    }

    /// The trees behind the egg, the egg, the wing's shadow and tiny Sindbad looking up, in
    /// near-plane units (horizon at `Hv`).
    static func eggNear(_ n: inout GraphicsContext, Hv: CGFloat) {
        fruitTree(&n, x: 566, baseY: Hv + 22, height: 170, seed: 4)
        fruitTree(&n, x: 880, baseY: Hv + 26, height: 210, seed: 7)
        let groundShade = wingShadow(root: CGPoint(x: 950, y: Hv + 84), from: 160, to: 200, length: 440, count: 8, squash: 0.22)
        Art.fill(&n, groundShade, ArtStyle.coolShade.opacity(0.14))
        Kit.shadow(&n, 724, Hv + 80, width: 300, alpha: 0.3)
        let eggShade = wingShadow(root: CGPoint(x: 900, y: Hv - 330), from: 115, to: 175, length: 300, count: 8, squash: 1)
        egg(&n, cx: 724, baseY: Hv + 80, width: 270, height: 360, shade: eggShade)
        Kit.grass(&n, in: CGRect(x: 580, y: Hv + 70, width: 300, height: 18), count: 30, seed: 9, color: Art.color(0x5E9A5E), height: 12)
        Kit.bush(&n, x: 620, baseY: Hv + 92, width: 64, palette: islandGreens(), seed: 15)
        Kit.bush(&n, x: 862, baseY: Hv + 100, width: 96, palette: islandGreens(), seed: 17)
        Kit.shadow(&n, 528, Hv + 94, width: 24)
        Art.group(&n, x: 528, y: Hv + 94, scale: 0.3, scaleX: -1) { s in
            sindbadGazing(&s, mouth: .oh, mirrored: true)
        }
        Kit.flowers(&n, in: CGRect(x: 480, y: Hv + 100, width: 120, height: 24), count: 6, seed: 23, petal: 0xFFF3D6)
    }
}

// MARK: - Scene 3: the valley of diamonds

extension SindbadArt {
    /// Pale sunlit sandstone, top to bottom.
    static func cliffStops() -> Kit.Stops {
        [(Art.color(0xF9EBD2), 0), (Art.color(0xF2DDBA), 0.6), (Art.color(0xE8CA9E), 1)]
    }

    /// The valley floor of sand and gravel.
    static func floorStops() -> Kit.Stops {
        [(Art.color(0xEAD4AE), 0), (Art.color(0xDEC194), 0.6), (Art.color(0xCFAA7A), 1)]
    }

    /// Soft bedding lines, a few cracks and tooth over a sandstone wall already filled, kept
    /// inside it. `box` is the wall's rough bounding box.
    static func strata(_ g: inout GraphicsContext, _ wall: Path, box: CGRect, seed: UInt32) {
        var random = ArtRandom(seed)
        var beds = Path()
        var cracks = Path()
        for i in 1...9 {
            let y: CGFloat = box.minY + box.height * CGFloat(i) / 10
            let wobble: CGFloat = (Kit.rnd(&random) - 0.5) * 10
            beds.move(to: CGPoint(x: box.minX, y: y))
            beds.addQuadCurve(to: CGPoint(x: box.maxX, y: y + wobble), control: CGPoint(x: box.midX, y: y - wobble))
        }
        for _ in 0..<5 {
            let x: CGFloat = box.minX + box.width * Kit.rnd(&random)
            let y: CGFloat = box.minY + box.height * Kit.rnd(&random) * 0.8
            let run: CGFloat = box.height * (0.08 + Kit.rnd(&random) * 0.12)
            cracks.move(to: CGPoint(x: x, y: y))
            cracks.addLine(to: CGPoint(x: x + 3, y: y + run * 0.5))
            cracks.addLine(to: CGPoint(x: x - 1, y: y + run))
        }
        let bedLines: Path = beds
        let crackLines: Path = cracks
        Art.clipped(&g, to: wall) { c in
            Art.stroke(&c, bedLines, Art.color(0xD9B98A, 0.32), width: 1.4)
            Art.stroke(&c, crackLines, Art.color(0xB8936A, 0.36), width: 1.2)
            ArtStyle.tooth(&c, in: box, seed: seed &+ 3, color: Color.white, alpha: 0.07)
        }
    }

    /// The walls of the well-deep valley in the picture's own units: the palest far wall at
    /// its end, the calm lit wall behind the words, the trailing wall with its lit face.
    static func valleyWalls(_ context: inout GraphicsContext, w: CGFloat, H: CGFloat, s: CGFloat, light: Kit.Light) {
        let backTop: CGFloat = H * 0.36
        let back = Kit.ridge(width: 470, y: backTop, amp: 18 * s, seed: 27, bottom: H + 4, step: 10, x0: 350)
        Art.fill(&context, back, Art.color(0xF0DEC0))
        strata(&context, back, box: CGRect(x: 350, y: backTop - 24, width: 470, height: H - backTop + 28), seed: 31)
        ArtStyle.atmosphere(&context, width: w, top: backTop - 30, bottom: H + 4, color: light.haze, alpha: 0.32)
        let leadPoints: [CGPoint] = [
            CGPoint(x: -10, y: H * 0.06), CGPoint(x: 120, y: H * 0.04), CGPoint(x: 260, y: H * 0.08), CGPoint(x: 400, y: H * 0.1),
            CGPoint(x: 430, y: H * 0.3), CGPoint(x: 452, y: H * 0.62), CGPoint(x: 482, y: H + 6), CGPoint(x: -10, y: H + 6),
        ]
        let lead = Art.polygon(leadPoints)
        Art.fillLinear(&context, lead, cliffStops(), from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        strata(&context, lead, box: CGRect(x: 0, y: H * 0.04, width: 482, height: H * 0.96), seed: 33)
        let innerPoints: [CGPoint] = [
            CGPoint(x: 400, y: H * 0.1), CGPoint(x: 430, y: H * 0.3), CGPoint(x: 452, y: H * 0.62), CGPoint(x: 482, y: H + 6),
            CGPoint(x: 444, y: H + 6), CGPoint(x: 420, y: H * 0.62), CGPoint(x: 398, y: H * 0.3), CGPoint(x: 382, y: H * 0.11),
        ]
        Art.fill(&context, Art.polygon(innerPoints), ArtStyle.coolShade.opacity(0.08))
        let trailPoints: [CGPoint] = [
            CGPoint(x: 782, y: -10), CGPoint(x: 762, y: H * 0.2), CGPoint(x: 732, y: H * 0.5), CGPoint(x: 700, y: H + 6),
            CGPoint(x: w + 10, y: H + 6), CGPoint(x: w + 10, y: -10),
        ]
        let trail = Art.polygon(trailPoints)
        let trailTone: Kit.Stops = [(Art.color(0xF1D8B2), 0), (Art.color(0xE2C092), 1)]
        Art.fillLinear(&context, trail, trailTone, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        strata(&context, trail, box: CGRect(x: 700, y: 0, width: w - 700, height: H), seed: 35)
        ArtStyle.rimEdge(&context, trail, bounds: CGRect(x: 700, y: -10, width: w - 690, height: H + 16), width: 3, alpha: 0.45)
        Art.fill(&context, Art.rect(0, H - 18 * s, w, 18 * s), ArtStyle.coolShade.opacity(0.05))
    }

    /// Two far serpents slipping into their holes at the foot of the walls: long plain
    /// coils, no heads to be seen.
    static func valleySerpents(_ context: inout GraphicsContext, H: CGFloat, s: CGFloat) {
        let holes: [(CGFloat, CGFloat, CGFloat)] = [(748, H - 20 * s, 1), (600, H - 8 * s, 0.7)]
        for hole in holes {
            let k: CGFloat = s * hole.2
            let hx: CGFloat = hole.0
            let hy: CGFloat = hole.1
            Art.fill(&context, Art.ellipse(hx, hy, 10 * k, 6.5 * k), Art.color(0x8E6A48))
            Art.fill(&context, Art.ellipse(hx + 1 * k, hy + 1 * k, 7 * k, 4.4 * k), Art.color(0x5E4632))
            var body = Path()
            body.move(to: CGPoint(x: hx - 64 * k, y: hy + 22 * k))
            body.addQuadCurve(to: CGPoint(x: hx - 34 * k, y: hy + 10 * k), control: CGPoint(x: hx - 52 * k, y: hy + 4 * k))
            body.addQuadCurve(to: CGPoint(x: hx - 2 * k, y: hy + 1 * k), control: CGPoint(x: hx - 18 * k, y: hy + 18 * k))
            let lit = CGAffineTransform(translationX: -0.6 * k, y: -1.2 * k)
            Kit.shadow(&context, hx - 32 * k, hy + 16 * k, width: 60 * k, alpha: 0.14)
            Art.stroke(&context, body, Art.color(0x8E9A62), width: 4.2 * k)
            Art.stroke(&context, body.applying(lit), Art.color(0xCED39A, 0.7), width: 1.2 * k)
        }
    }

    /// The long serpent hanging from the Roc's claws, in design units (the claws near (816, 200)).
    static func hangingSerpent(_ v: inout GraphicsContext) {
        let upper = Art.svg("M806,192 C772,236 846,286 806,330")
        let lower = Art.svg("M806,330 C780,358 790,388 812,404")
        Art.stroke(&v, upper, Art.color(0x8E9A62), width: 11)
        Art.stroke(&v, lower, Art.color(0x8E9A62), width: 7)
        Art.stroke(&v, upper, Art.color(0x6E7A48, 0.7), width: 5, cap: .butt, dash: [2, 9])
        let lit = CGAffineTransform(translationX: -2.4, y: -1.6)
        Art.stroke(&v, upper.applying(lit), Art.color(0xD3D69A, 0.75), width: 2.4)
        Art.stroke(&v, lower.applying(lit), Art.color(0xD3D69A, 0.7), width: 1.6)
    }

    static func valleyScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = day()
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 600, st.H * 0.12, scale: 0.5 * st.far, color: Color.white.opacity(0.6))
        valleyWalls(&context, w: w, H: st.H, s: st.far, light: light)
        Kit.ground(&context, width: w, top: st.H, bottom: h, stops: floorStops(), seed: 63)
        valleySerpents(&context, H: st.H, s: st.far)
        let Hv: CGFloat = st.Hv
        let bottom: CGFloat = st.hv
        Kit.designSpace(&context, st) { v in
            let floorRect = CGRect(x: 20, y: Hv + 8, width: 420, height: max(20, bottom - Hv - 40))
            stones(&v, in: floorRect, count: 40, seed: 71, size: 3)
            // The Roc lifting away out of the top of the trailing corner, the serpent in its claws.
            rocWing(&v, root: CGPoint(x: 962, y: 30), from: 100, to: 160, length: 280, count: 9)
            hangingSerpent(&v)
            Art.group(&v, x: 820, y: 170, scale: 0.62) { f in
                rocFoot(&f)
            }
            Kit.nearSpace(&v, st, anchorX: 640) { n in
                valleyNear(&n, Hv: Hv)
            }
        }
        if st.tall > 0.25 {
            // The deeper floor of a tall window: larger stones and a few great crystals.
            let top: CGFloat = st.H + st.depth * 0.4
            stones(&context, in: CGRect(x: 0, y: top, width: w, height: max(10, h - top - 30)), count: 80, seed: 77, size: 6.5)
            crystal(&context, x: 300, y: h - 120, r: 11)
            crystal(&context, x: 720, y: h - 170, r: 9)
            Kit.rock(&context, cx: 160, baseY: h - 60, width: 110, height: 50, color: 0xCFA878, seed: 9)
        }
        Kit.rock(&context, cx: 0, baseY: h + 12, width: 170 * st.far, height: 64 * st.far, color: 0xC49A6C, seed: 14)
        ArtStyle.finish(&context, size)
    }

    /// The glittering floor round Sindbad, small among the stones, staring up after the Roc,
    /// in near-plane units (horizon at `Hv`).
    static func valleyNear(_ n: inout GraphicsContext, Hv: CGFloat) {
        Art.glow(&n, 620, Hv + 64, 210, Art.color(0xFFF3CF), alpha: 0.4)
        stones(&n, in: CGRect(x: 460, y: Hv + 10, width: 430, height: 150), count: 90, seed: 73, size: 4.2)
        Kit.rock(&n, cx: 768, baseY: Hv + 60, width: 70, height: 34, color: 0xD9B98A, seed: 3)
        Kit.shadow(&n, 600, Hv + 76, width: 30)
        Art.group(&n, x: 600, y: Hv + 76, scale: 0.36, scaleX: -1) { s in
            sindbadGazing(&s, mouth: .oh, mirrored: true)
        }
        crystal(&n, x: 556, y: Hv + 92, r: 7)
        crystal(&n, x: 668, y: Hv + 104, r: 9)
        crystal(&n, x: 520, y: Hv + 128, r: 6)
        Kit.rock(&n, cx: 904, baseY: Hv + 168, width: 180, height: 96, color: 0xAD8459, seed: 6)
    }
}

// MARK: - Scene 4: the nest on the cliff top

extension SindbadArt {
    /// The far land below the cliffs, seen through the morning air.
    static func lowlandStops() -> Kit.Stops {
        [(Art.color(0xD9DCC0), 0), (Art.color(0xC6CBA6), 0.6), (Art.color(0xB6BC96), 1)]
    }

    /// The rock of the cliff top.
    static func plateauStops() -> Kit.Stops {
        [(Art.color(0xE6D0A6), 0), (Art.color(0xD4B788), 0.6), (Art.color(0xBF9E6E), 1)]
    }

    /// The cliff top in design units: its far edge runs from the brink at x 300 up to the
    /// trailing edge, and its face drops away on the leading side down to `bottom`.
    static func plateau(_ v: inout GraphicsContext, Hv: CGFloat, bottom: CGFloat) {
        let foot: CGFloat = bottom + 20
        var top = Path()
        top.move(to: CGPoint(x: 300, y: Hv + 30))
        top.addQuadCurve(to: CGPoint(x: 960, y: Hv - 12), control: CGPoint(x: 560, y: Hv + 2))
        top.addLine(to: CGPoint(x: 960, y: foot))
        top.addLine(to: CGPoint(x: 236, y: foot))
        top.addQuadCurve(to: CGPoint(x: 300, y: Hv + 30), control: CGPoint(x: 252, y: Hv + 120))
        top.closeSubpath()
        let face = Art.polygon([
            CGPoint(x: 300, y: Hv + 30), CGPoint(x: 252, y: Hv + 120), CGPoint(x: 236, y: foot), CGPoint(x: 196, y: foot),
            CGPoint(x: 226, y: Hv + 120), CGPoint(x: 286, y: Hv + 38),
        ])
        Kit.solid(&v, face, Art.color(0xCDAE80), light: 0.3, shade: 0.24)
        Art.fillLinear(&v, top, plateauStops(), from: CGPoint(x: 0, y: Hv - 12), to: CGPoint(x: 0, y: foot))
        let box = CGRect(x: 236, y: Hv - 12, width: 724, height: foot - Hv + 12)
        ArtStyle.form(&v, top, bounds: box, light: 0.18, shade: 0.14)
        Art.clipped(&v, to: top) { c in
            ArtStyle.tooth(&c, in: box, seed: 57, color: Color.white, alpha: 0.08)
        }
        let brink = Art.svg("M300,0 Q560,-28 960,-42").applying(CGAffineTransform(translationX: 0, y: Hv + 30))
        Art.stroke(&v, brink, Art.color(0xF6E6C4), width: 2.4)
        Kit.pebbles(&v, in: CGRect(x: 360, y: Hv + 24, width: 520, height: 110), count: 30, seed: 4, color: 0xB49A78)
        Kit.grass(&v, in: CGRect(x: 330, y: Hv + 20, width: 200, height: 70), count: 10, seed: 6, color: Art.color(0x9A9A62), height: 12)
    }

    /// A front lip of loose sticks laid over whoever sits in the nest.
    static func nestLip(_ n: inout GraphicsContext, cx: CGFloat, y: CGFloat, width w: CGFloat) {
        var random = ArtRandom(61)
        var sticks = Path()
        var pale = Path()
        for i in 0..<14 {
            let x: CGFloat = cx - w / 2 + w * Kit.rnd(&random)
            let dy: CGFloat = (Kit.rnd(&random) - 0.3) * 10
            let half: CGFloat = w * (0.08 + Kit.rnd(&random) * 0.08)
            let tip: CGFloat = (Kit.rnd(&random) - 0.5) * 8
            if i % 3 == 0 {
                pale.move(to: CGPoint(x: x - half, y: y + dy - tip))
                pale.addLine(to: CGPoint(x: x + half, y: y + dy + tip))
            } else {
                sticks.move(to: CGPoint(x: x - half, y: y + dy - tip))
                sticks.addLine(to: CGPoint(x: x + half, y: y + dy + tip))
            }
        }
        Art.stroke(&n, sticks, Art.color(0x6B4A30), width: 3)
        Art.stroke(&n, pale, Art.color(0xB98F5E), width: 2.4)
    }

    static func nestScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = morning()
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 640, st.H * 0.2, scale: 0.8 * st.far, color: Color.white.opacity(0.7))
        Kit.cloud(&context, 230, st.H * 0.1, scale: 0.5 * st.far, color: Color.white.opacity(0.45))
        Kit.ranges(&context, width: w, horizon: st.H, scale: st.far, light: light, mountains: false, seed: 9)
        Kit.ground(&context, width: w, top: st.H, bottom: h, stops: lowlandStops(), seed: 52)
        Kit.farTrees(&context, x0: 0, x1: 420, baseY: st.H + 22 * st.far, height: 12 * st.far, count: 12, color: Art.color(0xA6B394), seed: 8)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 10, bottom: h, color: light.haze, alpha: 0.3)
        Kit.birds(&context, 150, st.H - 40 * st.far, scale: 0.7, color: Art.color(0x8A8C80, 0.5))
        let Hv: CGFloat = st.Hv
        let bottom: CGFloat = st.hv
        Kit.designSpace(&context, st) { v in
            plateau(&v, Hv: Hv, bottom: bottom)
            Kit.nearSpace(&v, st, anchorX: 720) { n in
                nestNear(&n, Hv: Hv)
            }
        }
        if st.tall > 0.25 {
            // The deeper cliff top of a tall window: stones and dry tufts toward the viewer.
            let top: CGFloat = st.H + st.depth * 0.45
            let rect = CGRect(x: 420, y: top, width: w - 420, height: max(10, h - top - 30))
            Kit.pebbles(&context, in: rect, count: 40, seed: 18, color: 0xA88C68)
            Kit.grass(&context, in: rect, count: 18, seed: 19, color: Art.color(0x8E8E58), height: 18)
            Kit.rock(&context, cx: 560, baseY: h - 50, width: 120, height: 50, color: 0xB89668, seed: 21)
        }
        Kit.rock(&context, cx: w - 10, baseY: h + 8, width: 170 * st.far, height: 64 * st.far, color: 0x9A7A56, seed: 12)
        ArtStyle.finish(&context, size)
    }

    /// The ledge and the nest, Sindbad sitting up in it with the meat on his back, the eagle
    /// flapping off and three merchants running up with their sticks, in near-plane units.
    static func nestNear(_ n: inout GraphicsContext, Hv: CGFloat) {
        // The third merchant, farther off, coming from behind the nest.
        Kit.shadow(&n, 862, Hv + 40, width: 32)
        Art.group(&n, x: 862, y: Hv + 40, scale: 0.42) { s in
            stickMan(&s, fellowLook(cloth: 0xA6452F, sash: 0xE9C46A, turban: 0xFBF6EA), running: true, mouth: .open)
        }
        Kit.rock(&n, cx: 730, baseY: Hv + 98, width: 260, height: 36, color: 0xC2A274, seed: 8)
        nest(&n, cx: 730, baseY: Hv + 80, width: 212, seed: 5)
        Art.group(&n, x: 738, y: Hv + 64, scale: 0.52) { s in
            sindbadWithMeat(&s, mouth: .grin, look: CGPoint(x: -0.7, y: 0))
        }
        nestLip(&n, cx: 730, y: Hv + 60, width: 196)
        // The eagle, an ordinary brown one, flapping away to the right.
        Art.group(&n, x: 800, y: Hv - 150, scale: 1.3) { e in
            eagle(&e)
        }
        // The merchant first at the nest, and a fellow behind him, both running in.
        Kit.shadow(&n, 498, Hv + 66, width: 36)
        Art.group(&n, x: 498, y: Hv + 66, scale: 0.46, scaleX: -1) { s in
            stickMan(&s, fellowLook(cloth: 0x3E5C8A, sash: 0xD9A64A, turban: 0xF2E6CF), running: true, mouth: .oh, mirrored: true)
        }
        Kit.shadow(&n, 586, Hv + 104, width: 46)
        Art.group(&n, x: 586, y: Hv + 104, scale: 0.56, scaleX: -1) { s in
            stickMan(&s, merchantLook(), running: true, mouth: .oh, mirrored: true)
        }
    }
}
