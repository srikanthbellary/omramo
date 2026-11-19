import SwiftUI
import OmramoCore

// The cast and the shared parts of "Why the Possum's Tail Is Bare": the palette and the three
// lights (morning, late afternoon, early evening — every sky pale), Possum and his three
// tails (the bushy plume, the plume wrapped in red string, the bare tail), Rabbit, Cricket,
// the animals of the dance, and the Smoky Mountain woods (blue ridges in mist, a mossy log,
// ferns, the hollow tree).
//
// Cultural care (CONTENT_PLAN §1.3, the spec's artBrief): only animals and the forest are
// drawn. No people, no drums, fire, masks, feathers, patterns or lettering of any kind.

// MARK: - Palette and light

extension PossumArt {
    static let ramp = ArtStyle.Ramp(deep: 0x1F4A3A, shade: 0x3F7A5A, mid: 0x7FB08A, light: 0xDCEBD9, glow: 0xFFE7AE, accent: 0xD94F3D)

    /// The one strong colour of the story: the red string.
    static let stringRed: UInt32 = 0xD94F3D
    /// The silver-grey of the bushy tail.
    static let furGrey: UInt32 = 0xB4B5C0
    /// The pinkish grey of the bare tail.
    static let tailSkin: UInt32 = 0xDDB5B0
    static let nosePink: UInt32 = 0xF29AA6
    static let earDark: UInt32 = 0x3A3438

    /// Morning in the mountains: pale blue-green sky, warm at the horizon.
    static func morning() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xC4E4E6), 0), (Art.color(0xDDEFE6), 0.55), (Art.color(0xFFE7AE), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF8DC, glow: 0xFFE7AE, haze: 0xE4F0EA, far: 0xA9C6DA, mid: 0x7FA9C0, near: 0x5F9A80)
    }

    /// Late afternoon: a pale warm sky.
    static func afternoon() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD4EADF), 0), (Art.color(0xECF1D2), 0.5), (Art.color(0xFFE7AE), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF3C8, glow: 0xFFE7AE, haze: 0xF1F0D4, far: 0xAECBCF, mid: 0x8DB79C, near: 0x6E8F4E)
    }

    /// Early evening: still pale — lilac above, peach and cream below. Never night.
    static func evening() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xE6DDEA), 0), (Art.color(0xF6E0CE), 0.5), (Art.color(0xFFE2A6), 1)]
        return Kit.Light(sky: sky, sun: 0xFFE9B8, glow: 0xFFE2A6, haze: 0xF5E4D2, far: 0xA9BBC6, mid: 0x7FA08C, near: 0x5B7C56)
    }

    /// The meadow of the woods and the clearing, top (far) to bottom (near).
    static func grassStops() -> Kit.Stops {
        [(Art.color(0xA9D48E), 0), (Art.color(0x7FB872), 0.45), (Art.color(0x4F8F63), 1)]
    }

    /// The clearing in the evening: the same grass, a little warmer and quieter.
    static func eveningGrassStops() -> Kit.Stops {
        [(Art.color(0xB9CF8E), 0), (Art.color(0x86AE72), 0.45), (Art.color(0x5B7C56), 1)]
    }
}

// MARK: - Looks

extension PossumArt {
    /// Possum: the kit's Virginia opossum. The tail is drawn by this story (`plume`, `cord`),
    /// because it is the star and changes from scene to scene.
    static func possumLook() -> Kit.Beast {
        var look = Kit.possumLook()
        look.tail = .none
        return look
    }

    /// Rabbit: an eastern cottontail, warm brown-grey with a white fluff of a tail.
    static func rabbitLook() -> Kit.Beast {
        var look = Kit.rabbitLook()
        look.body = 0xA98F78
        look.belly = 0xF6EEE2
        look.dark = 0x5E4A3C
        return look
    }

    /// A black bear, drawn warm and round.
    static func bearLook() -> Kit.Beast {
        var look = Kit.bearLook()
        look.body = 0x5A4A44
        look.belly = 0xC9A27A
        look.dark = 0x2E2426
        return look
    }

    /// A white-tailed doe.
    static func deerLook() -> Kit.Beast {
        var look = Kit.gazelleLook()
        look.body = 0xB8804E
        look.belly = 0xF4E6CE
        look.dark = 0x4A3424
        return look
    }

    static func raccoonLook() -> Kit.Beast {
        Kit.Beast(body: 0x8E8A86, belly: 0xECE6DC, dark: 0x2E2A2E, ears: .pointed, tail: .bushy, muzzle: .pointed, bodyLength: 1.3, legLength: 0.4, bulk: 0.9, whiskers: true)
    }

    static func squirrelLook() -> Kit.Beast {
        Kit.Beast(body: 0x9C958E, belly: 0xF4EFE6, dark: 0x4A423E, ears: .small, tail: .bushy, muzzle: .short, bodyLength: 1.1, legLength: 0.35, bulk: 0.8)
    }
}

// MARK: - The tail

extension PossumArt {
    /// Points along a cubic curve from `p0` to `p1`: the centre line of a tail (49 points).
    static func tailLine(_ p0: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ p1: CGPoint) -> [CGPoint] {
        var points: [CGPoint] = []
        let steps: Int = 48
        for index in 0...steps {
            let t: CGFloat = CGFloat(index) / CGFloat(steps)
            let u: CGFloat = 1 - t
            let a: CGFloat = u * u * u
            let b: CGFloat = 3 * u * u * t
            let c: CGFloat = 3 * u * t * t
            let d: CGFloat = t * t * t
            let xNear: CGFloat = a * p0.x + b * c1.x
            let xFar: CGFloat = c * c2.x + d * p1.x
            let yNear: CGFloat = a * p0.y + b * c1.y
            let yFar: CGFloat = c * c2.y + d * p1.y
            points.append(CGPoint(x: xNear + xFar, y: yNear + yFar))
        }
        return points
    }

    /// The unit normal of the line at `index` that points toward the light (upper left).
    static func tailNormal(_ line: [CGPoint], _ index: Int) -> CGPoint {
        let n: Int = line.count
        guard n > 1 else { return CGPoint(x: 0, y: -1) }
        let i: Int = min(n - 1, max(0, index))
        let before: CGPoint = line[max(0, i - 1)]
        let after: CGPoint = line[min(n - 1, i + 1)]
        let dx: CGFloat = after.x - before.x
        let dy: CGFloat = after.y - before.y
        let length: CGFloat = max(0.001, (dx * dx + dy * dy).squareRoot())
        var nx: CGFloat = dy / length
        var ny: CGFloat = -dx / length
        if nx + ny > 0 {
            nx = -nx
            ny = -ny
        }
        return CGPoint(x: nx, y: ny)
    }

    /// The splendid tail: a long, thick, glossy plume along `line`, from the share `start` of
    /// the line (0 = the whole tail) to its tip. Silver-grey, paler at the tip, lit upper left.
    static func plume(_ context: inout GraphicsContext, _ line: [CGPoint], from start: CGFloat = 0) {
        let n: Int = line.count
        guard n > 2, let tip = line.last else { return }
        var shape = Path()
        var gloss = Path()
        var under = Path()
        var open: Bool = false
        for index in 0..<n {
            let t: CGFloat = CGFloat(index) / CGFloat(n - 1)
            if t < start { continue }
            let u: CGFloat = (t - start) / max(0.001, 1 - start)
            let swell: CGFloat = sin(CGFloat.pi * (0.12 + 0.8 * u))
            let r: CGFloat = 6 + 20 * swell
            let p: CGPoint = line[index]
            shape.addEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
            let normal: CGPoint = tailNormal(line, index)
            if index % 4 == 0 {
                // Tufts that break the edge, on alternate sides.
                let side: CGFloat = index % 8 == 0 ? 0.88 : -0.88
                let fx: CGFloat = p.x + normal.x * r * side
                let fy: CGFloat = p.y + normal.y * r * side
                let fr: CGFloat = r * 0.36
                shape.addEllipse(in: CGRect(x: fx - fr, y: fy - fr, width: fr * 2, height: fr * 2))
            }
            if u > 0.1 && u < 0.86 {
                let lit = CGPoint(x: p.x + normal.x * r * 0.5, y: p.y + normal.y * r * 0.5)
                let low = CGPoint(x: p.x - normal.x * r * 0.5, y: p.y - normal.y * r * 0.5)
                if open {
                    gloss.addLine(to: lit)
                    under.addLine(to: low)
                } else {
                    gloss.move(to: lit)
                    under.move(to: low)
                    open = true
                }
            }
        }
        Kit.solid(&context, shape, Art.color(furGrey), light: 0.34, shade: 0.26)
        Art.clipped(&context, to: shape) { g in
            Art.glow(&g, tip.x, tip.y, 34, Color.white, alpha: 0.8)
        }
        Art.stroke(&context, under, Art.color(0x6E6F86, 0.3), width: 2.2)
        Art.stroke(&context, gloss, Art.color(0xFFFFFF, 0.55), width: 3)
    }

    /// The thin tail along `line`, from the root to the share `end` of the line: wrapped round
    /// and round in plain red string (`wrapped`), or bare and pinkish-grey.
    static func cord(_ context: inout GraphicsContext, _ line: [CGPoint], to end: CGFloat = 1, wrapped: Bool) {
        let n: Int = line.count
        guard n > 2 else { return }
        let base: Color = wrapped ? Art.color(stringRed) : Art.color(tailSkin)
        var bands = Path()
        var lit = Path()
        var open: Bool = false
        for index in 0..<(n - 1) {
            let t: CGFloat = CGFloat(index) / CGFloat(n - 1)
            if t > end { break }
            let r: CGFloat = wrapped ? 6 - 1.6 * t : 4.2 - 2.2 * t
            let p: CGPoint = line[index]
            let q: CGPoint = line[index + 1]
            Art.stroke(&context, Art.line(p.x, p.y, q.x, q.y), base, width: r * 2)
            let normal: CGPoint = tailNormal(line, index)
            if index % 2 == 0 {
                // One turn of the string (or one ring of the bare skin), a little aslant.
                let tx: CGFloat = (q.x - p.x) * 0.8
                let ty: CGFloat = (q.y - p.y) * 0.8
                let reach: CGFloat = r * 0.8
                bands.move(to: CGPoint(x: p.x + normal.x * reach - tx, y: p.y + normal.y * reach - ty))
                bands.addLine(to: CGPoint(x: p.x - normal.x * reach + tx, y: p.y - normal.y * reach + ty))
            }
            let lp = CGPoint(x: p.x + normal.x * r * 0.45, y: p.y + normal.y * r * 0.45)
            if open {
                lit.addLine(to: lp)
            } else {
                lit.move(to: lp)
                open = true
            }
        }
        let bandColor: Color = wrapped ? Art.color(0x9E2F22, 0.75) : Art.color(0xB58886, 0.6)
        let bandWidth: CGFloat = wrapped ? 1.5 : 0.9
        Art.stroke(&context, bands, bandColor, width: bandWidth)
        Art.stroke(&context, lit, Art.color(0xFFFFFF, 0.38), width: 1.4)
    }

    /// The loose red string lying on the grass, about 70 units long, from (0, 0) to the right.
    static func looseString(_ context: inout GraphicsContext) {
        let string = Art.svg("M0,0 C10,-12 22,8 32,-2 C42,-12 40,10 52,4 C60,0 62,-8 70,-4")
        Art.stroke(&context, string, Art.color(0x9E2F22, 0.5), width: 4.4)
        Art.stroke(&context, string, Art.color(stringRed), width: 3)
        Art.stroke(&context, Art.svg("M2,-2 C10,-12 20,4 30,-3"), Art.color(0xFFFFFF, 0.35), width: 1)
    }

    /// A drift of loose grey fluff on the grass round (0, 0): what Cricket snipped.
    static func fluff(_ context: inout GraphicsContext, count: Int, seed: UInt32) {
        var random = ArtRandom(seed)
        var tufts = Path()
        var lights = Path()
        for _ in 0..<max(0, count) {
            let x: CGFloat = (Kit.rnd(&random) - 0.5) * 70
            let y: CGFloat = (Kit.rnd(&random) - 0.5) * 16
            let r: CGFloat = 3.5 + Kit.rnd(&random) * 3.5
            tufts.addEllipse(in: CGRect(x: x - r, y: y - r * 0.7, width: r * 2, height: r * 1.4))
            let s: CGFloat = r * 0.5
            lights.addEllipse(in: CGRect(x: x - r * 0.6, y: y - r * 0.7, width: s * 2, height: s * 1.4))
        }
        Art.fill(&context, tufts, Art.color(furGrey))
        Art.fill(&context, lights, Art.color(0xF1F0F4, 0.85))
    }
}

// MARK: - Possum

extension PossumArt {
    /// What the kit's side-view head does not have: the opossum's dark near ear and pink nose,
    /// the open mouth of his song, and the neat row of small teeth of his grin (comic, never
    /// scary). Drawn in the head's own units, on top of `Kit.beastHead`.
    static func possumHeadMarks(_ context: inout GraphicsContext, singing: Bool, grin: Bool) {
        let move: CGAffineTransform = CGAffineTransform(translationX: 11, y: -21).rotated(by: 0.3)
        let earData: String = "M-6.5,2 C-9,-5 -5,-11 0,-11 C5,-11 9,-5 6.5,2 Z"
        Art.fill(&context, Art.svg(earData).applying(move), Art.color(earDark))
        let inside: CGAffineTransform = move.translatedBy(x: 0, y: -2.5).scaledBy(x: 0.5, y: 0.5)
        Art.fill(&context, Art.svg(earData).applying(inside), Art.color(0xD9A0A4, 0.9))
        Art.fill(&context, Art.ellipse(-46, 9, 4.4, 3.5), Art.color(nosePink))
        Art.fill(&context, Art.ellipse(-47.2, 7.8, 1.5, 0.9), Art.color(0xFFFFFF, 0.6))
        if singing {
            Art.fill(&context, Art.ellipse(-35, 15.5, 6, 5), Art.color(0x7A2A30))
            Art.fill(&context, Art.ellipse(-34, 17.5, 3.4, 2.2), Art.color(0xF2788A))
        }
        if grin {
            let teeth = Art.svg("M-41,12.5 C-32,14 -22,16 -13,18.5 L-14,23 C-23,21.5 -32,19 -40,16.5 Z")
            Art.fill(&context, teeth, Art.color(0xFFFDF6))
            Art.stroke(&context, teeth, Art.color(0x5A2A17, 0.7), width: 1)
            let gaps = Art.svg("M-35,13.6 L-34.4,17.8 M-29,15 L-28.4,19.4 M-23,16.4 L-22.6,20.8 M-18,17.6 L-17.8,22")
            Art.stroke(&context, gaps, Art.color(0x5A2A17, 0.5), width: 0.8)
        }
    }

    /// Possum from the side, facing LEFT, origin on the ground under mid-body (as `Kit.beast`),
    /// WITHOUT his tail: the caller draws `plume` or `cord` first, from the pose's tail root.
    static func possum(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose,
        mood: Kit.BeastMood = .happy,
        look: CGPoint = .zero,
        singing: Bool = false,
        mirrored: Bool = false
    ) {
        let spec: Kit.Beast = possumLook()
        Kit.beast(&context, spec, pose: pose, mood: mood, look: look, mirrored: mirrored)
        let head: CGPoint = Kit.beastHeadCentre(spec, pose: pose)
        let tilt: CGFloat = mood == .proud ? Kit.deg(8) : 0
        Art.group(&context, x: head.x, y: head.y, rotate: tilt) { g in
            possumHeadMarks(&g, singing: singing, grin: false)
        }
    }

    /// Where the tail leaves the body, in the possum's own units (measured from `Kit.beast`).
    static func tailRoot(_ pose: Kit.BeastPose) -> CGPoint {
        switch pose {
        case .stand, .walk, .run: return CGPoint(x: 50, y: -56)
        case .sit: return CGPoint(x: 38, y: -12)
        case .rear: return CGPoint(x: 25, y: -24)
        case .sleep: return CGPoint(x: 46, y: -27)
        }
    }

    /// A tail line that starts at the pose's root; the three other points are offsets from it.
    static func tailFrom(_ pose: Kit.BeastPose, _ c1: CGPoint, _ c2: CGPoint, _ end: CGPoint) -> [CGPoint] {
        let root: CGPoint = tailRoot(pose)
        let a = CGPoint(x: root.x + c1.x, y: root.y + c1.y)
        let b = CGPoint(x: root.x + c2.x, y: root.y + c2.y)
        let c = CGPoint(x: root.x + end.x, y: root.y + end.y)
        return tailLine(root, a, b, c)
    }

    /// The high plume of Part I for a sitting or standing Possum: it rises behind him and
    /// curls over at the top, about 150 units above the root.
    static func proudTail(_ pose: Kit.BeastPose) -> [CGPoint] {
        tailFrom(pose, CGPoint(x: 52, y: -8), CGPoint(x: 96, y: -78), CGPoint(x: 58, y: -138))
    }

    /// One pink paw with three toe lines, centred on (x, y).
    static func pinkPaw(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat) {
        let paw = Art.ellipse(x, y, r, r * 0.86)
        Kit.solid(&context, paw, Art.color(0xF2B4B0), light: 0.2, shade: 0.16)
        var toes = Path()
        toes.move(to: CGPoint(x: x - r * 0.4, y: y - r * 0.5))
        toes.addLine(to: CGPoint(x: x - r * 0.4, y: y + r * 0.1))
        toes.move(to: CGPoint(x: x + r * 0.3, y: y - r * 0.5))
        toes.addLine(to: CGPoint(x: x + r * 0.3, y: y + r * 0.1))
        Art.stroke(&context, toes, Art.color(0xB9777A, 0.7), width: 1)
    }

    /// Possum flat on his back, paws up, grinning: head to the LEFT, origin on the ground
    /// under mid-body, about 150 long and 70 high. His thin bare tail lies in a curl behind.
    static func possumOnBack(_ context: inout GraphicsContext) {
        let spec: Kit.Beast = possumLook()
        Kit.shadow(&context, 4, 2, width: 150)
        let tail: [CGPoint] = tailLine(CGPoint(x: 54, y: -12), CGPoint(x: 118, y: 2), CGPoint(x: 132, y: -66), CGPoint(x: 90, y: -52))
        cord(&context, tail, wrapped: false)
        // The far paws, behind the belly.
        let far: Color = Kit.beastTone(spec.body, 0.78)
        Art.stroke(&context, Art.svg("M26,-40 C28,-52 32,-58 30,-66"), far, width: 11)
        Art.stroke(&context, Art.svg("M-10,-42 C-12,-54 -8,-60 -12,-66"), far, width: 11)
        pinkPaw(&context, 30, -68, 5.5)
        pinkPaw(&context, -12, -68, 5.5)
        let torso = Art.svg("M-48,-8 C-58,-30 -32,-50 6,-50 C40,-50 64,-34 58,-12 C56,-2 40,0 6,0 C-26,0 -44,0 -48,-8Z")
        Art.fill(&context, torso, Art.color(spec.body))
        let bellyColor: Color = Art.color(spec.belly)
        Art.clipped(&context, to: torso) { g in
            Art.fill(&g, Art.ellipse(4, -42, 44, 17), bellyColor)
        }
        Kit.model(&context, torso, light: 0.24, shade: 0.24)
        // The near paws, curled in the air.
        let coat: Color = Art.color(spec.body)
        Art.stroke(&context, Art.svg("M40,-36 C46,-48 50,-54 46,-64"), coat, width: 12)
        Art.stroke(&context, Art.svg("M-22,-40 C-28,-52 -24,-58 -30,-64"), coat, width: 12)
        pinkPaw(&context, 46, -66, 6.5)
        pinkPaw(&context, -30, -66, 6.5)
        // The head, upside down: nose in the air, the top of the head on the grass.
        Art.group(&context, x: -64, y: -27, rotate: Kit.deg(-107), scaleX: -1) { h in
            Kit.beastHead(&h, spec, mood: .happy, look: CGPoint(x: 0, y: -0.4), mirrored: true)
            possumHeadMarks(&h, singing: false, grin: true)
        }
    }

    /// Possum's face from the front (origin at the head's centre, 60 across), with his pink nose.
    static func possumFace(_ context: inout GraphicsContext, mood: Kit.BeastMood = .happy, look: CGPoint = .zero, grin: Bool = false) {
        Kit.beastFace(&context, possumLook(), mood: mood, look: look)
        possumNose(&context)
        if grin {
            let teeth = Art.svg("M-10,21.5 Q0,24 10,21.5 Q0,31 -10,21.5Z")
            Art.fill(&context, teeth, Art.color(0xFFFDF6))
            Art.stroke(&context, teeth, Art.color(0x5A2A17, 0.7), width: 1)
            Art.stroke(&context, Art.svg("M-4.5,22.6 L-4,25.6 M0,22.8 L0,26.4 M4.5,22.6 L4,25.6"), Art.color(0x5A2A17, 0.5), width: 0.8)
        }
    }

    /// The pink nose over the kit's dark one, front view.
    static func possumNose(_ context: inout GraphicsContext) {
        let nose = Kit.placed("M-5,-3 C-5,-5.5 5,-5.5 5,-3 C5,0 2,4 0,4 C-2,4 -5,0 -5,-3Z", x: 0, y: 17, scale: 0.9)
        Art.fill(&context, nose, Art.color(nosePink))
        Art.fill(&context, Art.ellipse(-1.6, 14.7, 1.6, 0.9), Art.color(0xFFFFFF, 0.6))
    }
}

// MARK: - The other animals

extension PossumArt {
    /// Rabbit from the side, facing LEFT (as `Kit.beast`).
    static func rabbit(_ context: inout GraphicsContext, pose: Kit.BeastPose, mood: Kit.BeastMood = .happy, look: CGPoint = .zero, mirrored: Bool = false) {
        Kit.beast(&context, rabbitLook(), pose: pose, mood: mood, look: look, mirrored: mirrored)
    }

    /// A raccoon from the side with its dark mask, facing LEFT (as `Kit.beast`).
    static func raccoon(_ context: inout GraphicsContext, pose: Kit.BeastPose, mirrored: Bool = false) {
        let spec: Kit.Beast = raccoonLook()
        Kit.beast(&context, spec, pose: pose, mood: .happy, mirrored: mirrored)
        let head: CGPoint = Kit.beastHeadCentre(spec, pose: pose)
        let flip: CGFloat = mirrored ? -1 : 1
        Art.group(&context, x: head.x, y: head.y) { g in
            Art.fill(&g, Art.ellipse(-12, -5.5, 17, 8.5), Art.color(0x2E2A2E, 0.92))
            Art.group(&g, x: -21, y: -6, scaleX: flip) { e in
                ArtStyle.eye(&e, 0, 0, 5.3)
            }
            Art.group(&g, x: -3, y: -5, scaleX: flip) { e in
                ArtStyle.eye(&e, 0, 0, 6.5)
            }
        }
    }

    /// A raccoon's face from the front, with the mask.
    static func raccoonFace(_ context: inout GraphicsContext) {
        Kit.beastFace(&context, raccoonLook(), mood: .happy)
        let mask = Kit.faceBoth("M-3,-4 C-6,-13 -21,-14 -26,-5 C-22,4 -8,5 -3,-4Z")
        Art.fill(&context, mask, Art.color(0x2E2A2E, 0.92))
        ArtStyle.eye(&context, -13, -4, 7)
        ArtStyle.eye(&context, 13, -4, 7)
    }

    /// Slow old Turtle (a box turtle), facing LEFT, origin on the ground under the shell,
    /// about 80 long and 50 high.
    static func turtle(_ context: inout GraphicsContext) {
        let skin: Color = Art.color(0x9AA85A)
        let skinDark: Color = Art.color(0x76864A)
        Art.fill(&context, Art.rect(-24, -12, 13, 13, radius: 5), skinDark)
        Art.fill(&context, Art.rect(16, -12, 13, 13, radius: 5), skinDark)
        Art.fill(&context, Art.svg("M34,-12 L46,-6 L34,-5Z"), skinDark)
        Art.stroke(&context, Art.line(-24, -15, -38, -24), skin, width: 11)
        let head = Art.ellipse(-41, -26, 10.5, 9)
        Kit.solid(&context, head, skin, light: 0.24, shade: 0.18)
        ArtStyle.eye(&context, -44, -28, 3.6)
        ArtStyle.cheek(&context, -38, -22, 4, alpha: 0.4)
        ArtStyle.smile(&context, -46, -21.5, width: 7, curve: 1.3, color: Art.color(0x4A5A2A))
        let shell = Art.svg("M-32,-9 C-32,-36 -12,-48 4,-48 C24,-48 40,-34 40,-9 Z")
        Kit.solid(&context, shell, Art.color(0x6B5A34), light: 0.3, shade: 0.26, rim: 2)
        let marks = Art.svg("M4,-44 L4,-30 M-12,-40 L-6,-28 M20,-40 L14,-28 M-24,-28 L-14,-20 M32,-28 L22,-20 M-4,-22 L12,-22")
        Art.clipped(&context, to: shell) { g in
            Art.stroke(&g, marks, Art.color(0xE9B64A, 0.85), width: 3)
            Art.fill(&g, Art.rect(-34, -15, 78, 7), Art.color(0x8A7440))
        }
        Art.fill(&context, Art.rect(-12, -9, 13, 10, radius: 5), skin)
        Art.fill(&context, Art.rect(26, -9, 13, 10, radius: 5), skin)
    }

    /// Cricket, facing LEFT, origin on the ground under him: about 70 long, with feelers that
    /// reach 66 units ahead and 70 up. Drawn much larger than life so that he reads.
    /// `natural` gives the real field cricket of the fact picture (a bead eye, no smile);
    /// `comb` puts his tiny wooden comb in his front leg.
    static func cricket(_ context: inout GraphicsContext, natural: Bool = false, comb: Bool = false) {
        let dark: Color = Art.color(0x2E2220)
        let coat: UInt32 = 0x3E2C26
        let limb: Color = Art.color(0x4E382E)
        // Far legs and feelers.
        Art.stroke(&context, Art.svg("M8,-16 L22,-36 L30,-2"), Art.color(0x2A1E1C), width: 2.6)
        Art.stroke(&context, Art.svg("M-26,-27 C-34,-50 -52,-58 -66,-52"), dark, width: 1.3)
        Art.stroke(&context, Art.svg("M-22,-28 C-24,-54 -40,-68 -56,-70"), dark, width: 1.3)
        Art.stroke(&context, Art.svg("M28,-13 L42,-17 M28,-10 L41,-8"), dark, width: 1.4)
        // Abdomen, wing case, thorax, head.
        let abdomen = Art.ellipse(10, -14, 21, 10.5)
        Kit.solid(&context, abdomen, Art.color(coat), light: 0.34, shade: 0.22)
        let wing = Art.svg("M-6,-22 C4,-28 22,-27 31,-17 C22,-15 6,-15 -6,-17Z")
        Kit.solid(&context, wing, Art.color(0x5A4034), light: 0.36, shade: 0.2)
        Art.stroke(&context, Art.svg("M-2,-21 C8,-24 20,-23 28,-18 M0,-18.5 C8,-20 18,-20 26,-17"), Art.color(0x2A1E1C, 0.6), width: 0.9)
        let thorax = Art.ellipse(-10, -16, 10.5, 10.5)
        Kit.solid(&context, thorax, Art.color(coat), light: 0.34, shade: 0.2)
        let head = Art.circle(-22, -18, 10.8)
        Kit.solid(&context, head, Art.color(0x46322A), light: 0.38, shade: 0.2)
        Art.fill(&context, Art.ellipse(-25, -24.5, 4.5, 2), Art.color(0xFFFFFF, 0.28))
        if natural {
            ArtStyle.eye(&context, -26, -20, 3.2, showsWhite: false)
        } else {
            ArtStyle.eye(&context, -26, -20, 5)
            ArtStyle.cheek(&context, -21, -13, 4, alpha: 0.45)
            ArtStyle.smile(&context, -28, -11.5, width: 7, curve: 1.6, color: Art.color(0xF0D2A8))
        }
        // Near legs: two small ones and the big jumping leg.
        Art.stroke(&context, Art.svg("M-14,-10 L-20,-4 L-21,0 M-5,-8 L-4,-3 L-1,0"), limb, width: 2.4)
        let thigh = Art.svg("M12,-10 C14,-22 24,-36 31,-40 C34,-36 30,-20 20,-8Z")
        Kit.solid(&context, thigh, Art.color(0x5A4034), light: 0.34, shade: 0.22)
        Art.stroke(&context, Art.svg("M31,-39 L39,-2 L46,0"), limb, width: 2.6)
        if comb {
            Art.group(&context, x: -24, y: -5, rotate: Kit.deg(-20)) { g in
                Art.fill(&g, Art.rect(-6, -3, 12, 3.2, radius: 1), Art.color(0xC99A5A))
                Art.stroke(&g, Art.svg("M-5,0 v4 M-2.5,0 v4 M0,0 v4 M2.5,0 v4 M5,0 v4"), Art.color(0xA9783E), width: 1)
            }
        }
    }
}

// MARK: - The Smoky Mountain woods

extension PossumArt {
    /// The Great Smoky Mountains: old, rounded ridges in layers, each nearer one darker and
    /// greener, with white mist lying in the hollows between them. `layers` 1…5 (fewer layers
    /// keep the nearer ridges). `s` is the stage's far scale.
    static func ridges(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light, layers: Int = 5) {
        let tones: [UInt32] = [0xC6DBE8, 0xA9C6DC, 0x8BB1CC, 0x6F9DB6, 0x5E947F]
        let lifts: [CGFloat] = [108, 84, 60, 36, 15]
        let amps: [CGFloat] = [20, 22, 22, 18, 12]
        let count: Int = max(1, min(5, layers))
        let first: Int = 5 - count
        for index in first..<5 {
            let y: CGFloat = H - lifts[index] * s
            let amp: CGFloat = amps[index] * s
            let seed: UInt32 = 30 &+ UInt32(index) &* 7
            let shape: Path = Kit.ridge(width: w, y: y, amp: amp, seed: seed, bottom: H + 8, step: 8)
            Art.fill(&context, shape, Art.color(tones[index]))
            // Mist in the hollow at this ridge's foot; the next ridge rises out of it.
            let top: CGFloat = y - 2 * s
            let fall: CGFloat = 44 * s
            let mist: Kit.Stops = [(Color.white.opacity(0), 0), (Color.white.opacity(0.55), 0.6), (Color.white.opacity(0.35), 1)]
            Art.fillLinear(&context, Art.rect(0, top, w, fall), mist, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: top + fall))
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 140 * s, bottom: H + 8, color: light.haze, alpha: 0.2)
    }

    /// A fern: six arching fronds with paired leaflets, growing from (x, baseY).
    static func fern(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32 = 0x3F8A4E, seed: UInt32 = 1) {
        var random = ArtRandom(seed)
        var stems = Path()
        var back = Path()
        var front = Path()
        let base = CGPoint(x: x, y: baseY)
        for index in 0..<6 {
            let spread: CGFloat = CGFloat(index) / 5 - 0.5
            let reach: CGFloat = height * (0.75 + Kit.rnd(&random) * 0.25)
            let droop: CGFloat = 1 - abs(spread) * 0.7
            let tip = CGPoint(x: x + spread * height * 1.5, y: baseY - reach * droop)
            let control = CGPoint(x: x + spread * height * 0.5, y: baseY - reach * 1.05)
            stems.move(to: base)
            stems.addQuadCurve(to: tip, control: control)
            for step in 1..<8 {
                let t: CGFloat = CGFloat(step) / 8
                let p: CGPoint = Kit.groundQuad(base, control, tip, t)
                let q: CGPoint = Kit.groundQuad(base, control, tip, t + 0.05)
                let along: CGFloat = atan2(q.y - p.y, q.x - p.x)
                let size: CGFloat = height * 0.22 * (1.05 - t)
                if index % 2 == 0 {
                    Kit.groundLeaf(&back, base: p, angle: along - 1.15, length: size, width: size * 0.42)
                    Kit.groundLeaf(&back, base: p, angle: along + 1.15, length: size, width: size * 0.42)
                } else {
                    Kit.groundLeaf(&front, base: p, angle: along - 1.15, length: size, width: size * 0.42)
                    Kit.groundLeaf(&front, base: p, angle: along + 1.15, length: size, width: size * 0.42)
                }
            }
        }
        Art.fill(&context, back, Kit.groundTone(color, 0.8))
        Art.fill(&context, front, Art.color(color))
        Art.stroke(&context, stems, Kit.groundTone(color, 0.62), width: max(1, height * 0.025))
    }

    /// A mossy fallen log lying on the ground: origin under its middle, its top at y = −44,
    /// `length` long, the cut end to the LEFT.
    static func mossyLog(_ context: inout GraphicsContext, length: CGFloat) {
        let half: CGFloat = length / 2
        Kit.shadow(&context, 0, 1, width: length * 1.05)
        let body = Art.rect(-half, -44, length, 44, radius: 16)
        let bark: Kit.Stops = [(Art.color(0x9A7456), 0), (Art.color(0x7A5A44), 0.5), (Art.color(0x55392E), 1)]
        Kit.solid(&context, body, stops: bark, light: 0.2, shade: 0.24)
        var random = ArtRandom(41)
        var lines = Path()
        for _ in 0..<9 {
            let x: CGFloat = -half + 26 + (length - 70) * Kit.rnd(&random)
            let y: CGFloat = -32 + 24 * Kit.rnd(&random)
            let run: CGFloat = 14 + 22 * Kit.rnd(&random)
            lines.move(to: CGPoint(x: x, y: y))
            lines.addQuadCurve(to: CGPoint(x: x + run, y: y + 1), control: CGPoint(x: x + run / 2, y: y - 2.5))
        }
        Art.stroke(&context, lines, Art.color(0x4A3028, 0.5), width: ArtStyle.detailLine)
        // A broken stub of a branch on the right.
        let stub = Art.svg("M40,-42 C42,-54 50,-62 58,-64 L62,-58 C56,-54 54,-48 54,-42Z").applying(CGAffineTransform(translationX: half - 110, y: 0))
        Kit.solid(&context, stub, Art.color(0x7A5A44), light: 0.2, shade: 0.2)
        // The cut end, with its rings.
        let cut = Art.ellipse(-half + 5, -22, 11, 21.5)
        Kit.solid(&context, cut, Art.color(0xDDBC8E), light: 0.2, shade: 0.14)
        Art.stroke(&context, Art.ellipse(-half + 5, -22, 6.5, 13.5), Art.color(0xA9825A, 0.8), width: 1.2)
        Art.stroke(&context, Art.ellipse(-half + 5, -22, 2.6, 5.5), Art.color(0xA9825A, 0.8), width: 1.2)
        // Moss along the top.
        var moss = Path()
        var mossX: CGFloat = -half + 24
        while mossX < half - 12 {
            let r: CGFloat = 9 + 7 * Kit.rnd(&random)
            moss.addEllipse(in: CGRect(x: mossX - r, y: -47 - r * 0.4, width: r * 2, height: r * 1.1))
            mossX += r * 1.3
        }
        Kit.solid(&context, moss, Art.color(0x7DB24E), light: 0.32, shade: 0.2)
    }

    /// Possum's hollow tree on the trailing edge: a great old trunk from `top` (above the
    /// frame) down to its roots on `baseY`, with the dark round doorway of the den at its foot.
    /// It stands between x 712 and the trailing edge; the doorway is centred on x 833.
    static func hollowTree(_ context: inout GraphicsContext, baseY: CGFloat, top: CGFloat) {
        Kit.shadow(&context, 820, baseY + 16, width: 230, alpha: 0.24)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 706, y: baseY + 16))
        trunk.addQuadCurve(to: CGPoint(x: 766, y: baseY - 96), control: CGPoint(x: 760, y: baseY - 8))
        trunk.addLine(to: CGPoint(x: 780, y: top))
        trunk.addLine(to: CGPoint(x: 904, y: top))
        trunk.addLine(to: CGPoint(x: 904, y: baseY + 30))
        trunk.addQuadCurve(to: CGPoint(x: 706, y: baseY + 16), control: CGPoint(x: 800, y: baseY + 4))
        trunk.closeSubpath()
        let bark: Kit.Stops = [(Art.color(0xA98262), 0), (Art.color(0x7E5E48), 0.4), (Art.color(0x513A32), 1)]
        Art.fillLinear(&context, trunk, bark, from: CGPoint(x: 720, y: 0), to: CGPoint(x: 904, y: 0))
        var grooves = Path()
        let starts: [CGFloat] = [790, 812, 838, 862, 884]
        for start in starts {
            grooves.move(to: CGPoint(x: start, y: top))
            grooves.addQuadCurve(to: CGPoint(x: start - 14, y: baseY - 110), control: CGPoint(x: start + 6, y: (top + baseY) / 2))
        }
        var doorway = Path()
        doorway.move(to: CGPoint(x: 798, y: baseY + 8))
        doorway.addCurve(to: CGPoint(x: 833, y: baseY - 76), control1: CGPoint(x: 796, y: baseY - 50), control2: CGPoint(x: 810, y: baseY - 76))
        doorway.addCurve(to: CGPoint(x: 868, y: baseY + 12), control1: CGPoint(x: 856, y: baseY - 76), control2: CGPoint(x: 870, y: baseY - 50))
        doorway.closeSubpath()
        let floorY: CGFloat = baseY + 10
        Art.clipped(&context, to: trunk) { g in
            Art.stroke(&g, grooves, Art.color(0x3E2A26, 0.4), width: 2.4)
            Art.stroke(&g, doorway, Art.color(0xB8926E, 0.9), width: 9)
            Art.fill(&g, doorway, Art.color(0x2B1D24))
            // A little warm light on the floor of the den, so the dark holds a warm note.
            Art.glow(&g, 826, floorY, 34, Art.color(0xE9A860), alpha: 0.4)
        }
        var edge = Path()
        edge.move(to: CGPoint(x: 706, y: baseY + 16))
        edge.addQuadCurve(to: CGPoint(x: 766, y: baseY - 96), control: CGPoint(x: 760, y: baseY - 8))
        edge.addLine(to: CGPoint(x: 780, y: top))
        Art.stroke(&context, edge, ArtStyle.warmLight.opacity(0.55), width: 3)
        // Moss on the roots.
        var moss = Path()
        moss.addEllipse(in: CGRect(x: 716, y: baseY - 4, width: 46, height: 20))
        moss.addEllipse(in: CGRect(x: 750, y: baseY - 16, width: 30, height: 18))
        moss.addEllipse(in: CGRect(x: 866, y: baseY + 6, width: 40, height: 20))
        Kit.solid(&context, moss, Art.color(0x7DB24E), light: 0.3, shade: 0.2)
    }

    /// Grass and small flowers over the whole ground of an unfolded scene and, on a tall
    /// window, ferns, tufts and mossy stones along the foot of the picture.
    static func meadow(_ context: inout GraphicsContext, _ st: Kit.Stage, seed: UInt32, flower: UInt32) {
        let top: CGFloat = st.H + 10
        let depth: CGFloat = st.depth - 10
        guard depth > 10 else { return }
        let area = CGRect(x: 0, y: top, width: st.w, height: depth)
        let count: Int = Int(depth * 0.5)
        Kit.grass(&context, in: area, count: count, seed: seed, color: Art.color(0x3F7A5A, 0.5), height: 9 * st.far)
        Kit.grass(&context, in: area, count: count, seed: seed &+ 3, color: Art.color(0xC9E69A, 0.6), height: 7 * st.far)
        Kit.flowers(&context, in: area, count: Int(depth * 0.1), seed: seed &+ 7, petal: flower)
        guard st.tall > 0.25 else { return }
        let h: CGFloat = st.h
        Kit.rock(&context, cx: 210, baseY: h - 96, width: 96, height: 44, color: 0x8E9486, seed: seed &+ 2)
        Kit.rock(&context, cx: 560, baseY: h - 40, width: 70, height: 30, color: 0x8E9486, seed: seed &+ 4)
        fern(&context, x: 90, baseY: h - 70, height: 74, seed: seed &+ 1)
        fern(&context, x: 330, baseY: h - 24, height: 86, color: 0x2F7A4A, seed: seed &+ 5)
        fern(&context, x: 660, baseY: h - 150, height: 60, seed: seed &+ 6)
        Kit.grassTuft(&context, x: 470, baseY: h - 110, height: 46, color: 0x3F7A5A, seed: seed &+ 8)
        Kit.grassTuft(&context, x: 150, baseY: h - 180, height: 38, color: 0x4F8F63, seed: seed &+ 9)
        Kit.grassTuft(&context, x: 780, baseY: h - 20, height: 60, color: 0x2F6A4A, seed: seed &+ 10)
    }
}
