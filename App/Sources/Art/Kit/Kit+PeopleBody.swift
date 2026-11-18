import SwiftUI
import OmramoCore

// The storybook person's BODY: poses, garments and the portrait bust. The head, the `Person`
// description and `personTone` live in Kit+People.swift.
//
// A body is drawn in "adult units" (shoulders at y −112, hips at y −58, ground at 0) inside a
// group scaled for the person's age; the head is then set on the neck at its own scale. Each
// pose is a `BodyRig` (joints), and one painter (`bodyFigure`) dresses any rig in any garment.

// MARK: - Public API

extension Kit {
    enum Pose: Sendable { case stand, walk, sit, kneel, reach, carry, wave, bow, sleep }

    /// The whole person, about THREE HEADS tall. Origin (0, 0) is the ground between the feet
    /// (for `sit`: the ground under the seat, the person sits on the ground or on something the
    /// caller draws `seatHeight` high; for `sleep`: the ground under the middle of the lying
    /// body). Faces LEFT: the leading arm is the one on the left. An adult is 168 tall (head
    /// centre at y −140), a child 126 (head centre at y −101), an elder 160 and a little stooped
    /// (head centre at about (−5, −132)). The caller mirrors with `Art.group(scaleX: -1)` and
    /// passes `mirrored: true`. The caller also draws the contact shadow (`Kit.shadow`).
    static func person(
        _ context: inout GraphicsContext,
        _ p: Person,
        pose: Pose = .stand,
        look: CGPoint = .zero,
        mouth: Mouth = .smile,
        mirrored: Bool = false
    ) {
        let f = bodyFrame(p)
        if pose == .sleep {
            Art.group(&context, scale: f.k) { g in
                bodySleep(&g, p, mirrored: mirrored)
            }
            let sx: CGFloat = -26 * f.k - f.headHalf + 8
            let sy: CGFloat = -f.headHalf - 1
            Art.group(&context, x: sx, y: sy, rotate: deg(-14), scale: f.headScale) { g in
                personHead(&g, p, look: look, mouth: mouth, closedEyes: true, mirrored: mirrored)
            }
            return
        }
        let r = bodyRig(p, pose)
        Art.group(&context, scale: f.k) { g in
            bodyFigure(&g, p, r, mirrored: mirrored)
        }
        let c = bodyHeadCentre(f, r)
        let tilt: CGFloat = -deg(r.lean) * 0.45
        Art.group(&context, x: c.x, y: c.y, rotate: tilt, scale: f.headScale) { g in
            personHead(&g, p, look: look, mouth: mouth, closedEyes: false, mirrored: mirrored)
        }
    }

    /// How high above the ground the seat of a sitting adult is (34); a child's is 26.
    static func seatHeight(_ p: Person) -> CGFloat {
        switch p.age {
        case .child: return 26
        case .adult, .elder: return 34
        }
    }

    /// Where the leading hand is for `pose`, in the person's own units (so a story can put a
    /// basket, a staff or a fish in it).
    static func hand(_ p: Person, pose: Pose) -> CGPoint {
        let f = bodyFrame(p)
        if pose == .sleep {
            return pt(14 * f.k, -27 * f.k)
        }
        let r = bodyRig(p, pose)
        let s = bodyShoulder(r, near: true)
        let x: CGFloat = (s.x + r.nearHand.x) * f.k
        let y: CGFloat = (s.y + r.nearHand.y) * f.k
        return pt(x, y)
    }
}

// MARK: - Frame and rig

extension Kit {
    /// The sizes that change with age. `k` scales the body from adult units.
    struct BodyFrame: Sendable {
        var k: CGFloat
        var headHalf: CGFloat
        var headScale: CGFloat
        var stoop: CGFloat

        init(k: CGFloat, headHalf: CGFloat, headScale: CGFloat, stoop: CGFloat) {
            self.k = k
            self.headHalf = headHalf
            self.headScale = headScale
            self.stoop = stoop
        }
    }

    static func bodyFrame(_ p: Person) -> BodyFrame {
        switch p.age {
        case .child: return BodyFrame(k: 0.70, headHalf: 22.5, headScale: 0.9, stoop: 0)
        case .adult: return BodyFrame(k: 1, headHalf: 28, headScale: 1, stoop: 0)
        case .elder: return BodyFrame(k: 0.93, headHalf: 28, headScale: 1, stoop: 4)
        }
    }

    /// The joints of one pose, in adult units. Elbows and hands are offsets from their shoulder.
    /// `lean` is in degrees, forward (to the left) about the hips. The default is `stand`.
    struct BodyRig: Sendable {
        var lean: CGFloat = 0
        var hip: CGPoint = CGPoint(x: 0, y: -58)
        var nearHip: CGPoint = CGPoint(x: -8, y: -58)
        var farHip: CGPoint = CGPoint(x: 8, y: -58)
        var nearKnee: CGPoint = CGPoint(x: -8, y: -30)
        var nearFoot: CGPoint = CGPoint(x: -9, y: -3)
        var farKnee: CGPoint = CGPoint(x: 8, y: -30)
        var farFoot: CGPoint = CGPoint(x: 9, y: -3)
        var nearElbow: CGPoint = CGPoint(x: -5, y: 22)
        var nearHand: CGPoint = CGPoint(x: -6, y: 44)
        var farElbow: CGPoint = CGPoint(x: 6, y: 22)
        var farHand: CGPoint = CGPoint(x: 10, y: 43)
        /// Kneeling: the shins lie back along the ground.
        var feetBack: Bool = false
        var openHand: Bool = false

        init() {}
    }

    static func bodyRig(_ p: Person, _ pose: Pose) -> BodyRig {
        switch pose {
        case .stand, .sleep: return bodyStandRig(p)
        case .walk: return bodyWalkRig(p)
        case .sit: return bodySitRig(p)
        case .kneel: return bodyKneelRig(p)
        case .reach: return bodyReachRig(p)
        case .carry: return bodyCarryRig(p)
        case .wave: return bodyWaveRig(p)
        case .bow: return bodyBowRig(p)
        }
    }

    static func bodyStandRig(_ p: Person) -> BodyRig {
        var r = BodyRig()
        r.lean = bodyFrame(p).stoop
        return r
    }

    /// Mid-stride: the far leg leads, the near arm swings forward.
    static func bodyWalkRig(_ p: Person) -> BodyRig {
        var r = bodyStandRig(p)
        r.lean += 3
        r.farHip = pt(-8, -58)
        r.nearHip = pt(8, -58)
        r.farKnee = pt(-15, -31)
        r.farFoot = pt(-24, -3)
        r.nearKnee = pt(12, -30)
        r.nearFoot = pt(22, -4)
        r.nearElbow = pt(-10, 20)
        r.nearHand = pt(-22, 36)
        r.farElbow = pt(10, 20)
        r.farHand = pt(20, 38)
        return r
    }

    /// Sitting on something `seatHeight` high: thighs forward, hands on the knees.
    static func bodySitRig(_ p: Person) -> BodyRig {
        var r = bodyStandRig(p)
        let seat: CGFloat = seatHeight(p) / bodyFrame(p).k
        let hy: CGFloat = -(seat + 12)
        r.hip = pt(6, hy)
        r.nearHip = pt(14, hy)
        r.farHip = pt(18, hy)
        r.nearKnee = pt(-28, hy - 1)
        r.nearFoot = pt(-30, -3)
        r.farKnee = pt(-23, hy - 1)
        r.farFoot = pt(-21, -3)
        r.nearElbow = pt(0, 20)
        r.nearHand = pt(-14, 32)
        r.farElbow = pt(-14, 22)
        r.farHand = pt(-42, 31)
        return r
    }

    /// On both knees, working at something low in front.
    static func bodyKneelRig(_ p: Person) -> BodyRig {
        var r = bodyStandRig(p)
        r.lean += 12
        r.hip = pt(0, -40)
        r.nearHip = pt(-4, -40)
        r.farHip = pt(4, -40)
        r.nearKnee = pt(-24, -6)
        r.nearFoot = pt(14, -5)
        r.farKnee = pt(-17, -6)
        r.farFoot = pt(21, -5)
        r.feetBack = true
        r.nearElbow = pt(-6, 24)
        r.nearHand = pt(-22, 44)
        r.farElbow = pt(-14, 24)
        r.farHand = pt(-40, 48)
        return r
    }

    static func bodyReachRig(_ p: Person) -> BodyRig {
        var r = bodyStandRig(p)
        r.nearElbow = pt(-16, -10)
        r.nearHand = pt(-34, -34)
        return r
    }

    /// Both forearms forward at chest height; the caller draws the load at `hand`.
    static func bodyCarryRig(_ p: Person) -> BodyRig {
        var r = bodyStandRig(p)
        r.nearElbow = pt(2, 20)
        r.nearHand = pt(-18, 14)
        r.farElbow = pt(-20, 22)
        r.farHand = pt(-50, 10)
        return r
    }

    static func bodyWaveRig(_ p: Person) -> BodyRig {
        var r = bodyStandRig(p)
        r.nearElbow = pt(-22, 6)
        r.nearHand = pt(-30, -22)
        r.openHand = true
        return r
    }

    static func bodyBowRig(_ p: Person) -> BodyRig {
        var r = bodyStandRig(p)
        r.lean += 35
        r.nearElbow = pt(2, 16)
        r.nearHand = pt(-9, 31)
        r.farElbow = pt(-2, 20)
        r.farHand = pt(-16, 36)
        return r
    }
}

// MARK: - Geometry helpers

extension Kit {
    /// `v` turned by `a` radians (screen coordinates: negative turns the top to the left).
    static func bodyTurn(_ v: CGPoint, _ a: CGFloat) -> CGPoint {
        let c: CGFloat = cos(a)
        let s: CGFloat = sin(a)
        let x: CGFloat = v.x * c - v.y * s
        let y: CGFloat = v.x * s + v.y * c
        return pt(x, y)
    }

    static func bodyUnit(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        let dx: CGFloat = b.x - a.x
        let dy: CGFloat = b.y - a.y
        let square: CGFloat = dx * dx + dy * dy
        let length: CGFloat = max(0.001, square.squareRoot())
        return pt(dx / length, dy / length)
    }

    static func bodyMix(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        pt(mix(a.x, b.x, t), mix(a.y, b.y, t))
    }

    /// A shoulder in adult units. The shoulders close up as the body leans (a side view).
    static func bodyShoulder(_ r: BodyRig, near: Bool) -> CGPoint {
        let spread: CGFloat = max(0.3, 1 - r.lean / 50)
        let lx: CGFloat = (near ? -18 : 16) * spread
        let turned = bodyTurn(pt(lx, -47), -deg(r.lean))
        return pt(r.hip.x + turned.x, r.hip.y + turned.y)
    }

    /// The base of the neck in adult units.
    static func bodyNeck(_ r: BodyRig) -> CGPoint {
        let turned = bodyTurn(pt(0, -54), -deg(r.lean))
        return pt(r.hip.x + turned.x, r.hip.y + turned.y)
    }

    /// The head's centre in the person's own units.
    static func bodyHeadCentre(_ f: BodyFrame, _ r: BodyRig) -> CGPoint {
        let neck = bodyNeck(r)
        let up = bodyTurn(pt(0, -f.headHalf), -deg(r.lean) * 0.7)
        return pt(neck.x * f.k + up.x, neck.y * f.k + up.y)
    }

    /// A closed shape through `points` with every corner rounded.
    static func bodyRound(_ points: [CGPoint]) -> Path {
        var path = Path()
        let n: Int = points.count
        guard n > 2 else { return path }
        for i in 0..<n {
            let a = points[(i + n - 1) % n]
            let b = points[i]
            let c = points[(i + 1) % n]
            let entry = bodyMix(b, a, 0.3)
            let exit = bodyMix(b, c, 0.3)
            if i == 0 {
                path.move(to: entry)
            } else {
                path.addLine(to: entry)
            }
            path.addQuadCurve(to: exit, control: b)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Garment facts

extension Kit {
    static let bodyShoe: String = "M5,0 L-9,0 Q-13,-1 -11,-5 Q-6,-9 1,-8 L5,-7Z"

    /// (length, flare): length 1 is a hem at the knee, 2 at the foot; flare widens the hem.
    static func bodyCut(_ garment: Person.Garment) -> (CGFloat, CGFloat) {
        switch garment {
        case .tunic: return (1.0, 1.15)
        case .robe: return (1.9, 1.3)
        case .kimono: return (1.9, 1.1)
        case .kilt: return (0.95, 1.15)
        case .parka: return (0.5, 1.2)
        case .wrapper: return (1.6, 1.05)
        case .shirtTrousers: return (0.3, 1.15)
        case .dress: return (1.85, 1.45)
        case .chiton: return (1.0, 1.2)
        }
    }

    /// The colour of the arms: the cloth for sleeved garments, skin for bare arms.
    static func bodyArmHex(_ p: Person) -> UInt32 {
        switch p.garment {
        case .tunic, .robe, .kimono, .parka, .shirtTrousers, .dress: return p.cloth
        case .kilt, .wrapper, .chiton: return p.skin
        }
    }

    static func bodyLegHex(_ p: Person) -> UInt32 {
        switch p.garment {
        case .wrapper, .chiton: return p.skin
        case .tunic, .robe, .kimono, .kilt, .parka, .shirtTrousers, .dress: return p.legs
        }
    }

    static func bodyBareFeet(_ garment: Person.Garment) -> Bool {
        switch garment {
        case .kilt, .wrapper, .chiton: return true
        case .tunic, .robe, .kimono, .parka, .shirtTrousers, .dress: return false
        }
    }

    /// Bare chest: the torso is skin and the garment lies over it.
    static func bodyBareChest(_ garment: Person.Garment) -> Bool {
        switch garment {
        case .kilt, .wrapper: return true
        case .tunic, .robe, .kimono, .parka, .shirtTrousers, .dress, .chiton: return false
        }
    }
}

// MARK: - The figure

extension Kit {
    /// Any rig in any garment, in adult units, without the head.
    static func bodyFigure(_ context: inout GraphicsContext, _ p: Person, _ r: BodyRig, mirrored: Bool) {
        let nearS = bodyShoulder(r, near: true)
        let farS = bodyShoulder(r, near: false)
        bodyArm(&context, p, from: farS, elbow: r.farElbow, tip: r.farHand, far: true, open: false)
        bodyLeg(&context, p, hip: r.farHip, knee: r.farKnee, foot: r.farFoot, far: true, back: r.feetBack)
        bodyLeg(&context, p, hip: r.nearHip, knee: r.nearKnee, foot: r.nearFoot, far: false, back: r.feetBack)
        bodySkirt(&context, p, r, mirrored: mirrored)
        // The neck, under the collar and the chin.
        let neck = bodyNeck(r)
        let up = bodyTurn(pt(0, -12), -deg(r.lean) * 0.7)
        let neckLine = Art.line(neck.x, neck.y + 3, neck.x + up.x, neck.y + up.y)
        Art.stroke(&context, neckLine, personTone(p.skin, 0.9), width: 13)
        bodyTorso(&context, p, r, mirrored: mirrored)
        bodyArm(&context, p, from: nearS, elbow: r.nearElbow, tip: r.nearHand, far: false, open: r.openHand)
    }

    /// One arm from shoulder `s`, bending through the elbow, with its hand. `elbow` and `tip`
    /// are offsets from the shoulder.
    static func bodyArm(
        _ context: inout GraphicsContext,
        _ p: Person,
        from s: CGPoint,
        elbow: CGPoint,
        tip: CGPoint,
        far: Bool,
        open: Bool
    ) {
        let h = pt(s.x + tip.x, s.y + tip.y)
        // A curve that passes through the elbow.
        let cx: CGFloat = 2 * (s.x + elbow.x) - (s.x + h.x) / 2
        let cy: CGFloat = 2 * (s.y + elbow.y) - (s.y + h.y) / 2
        var arm = Path()
        arm.move(to: s)
        arm.addQuadCurve(to: h, control: pt(cx, cy))
        let dim: CGFloat = far ? 0.82 : 1
        let armColor = personTone(bodyArmHex(p), dim)
        var handColor = personTone(p.skin, dim)
        switch p.garment {
        case .robe, .kimono:
            // Wide sleeves that stop short of the hand.
            Art.stroke(&context, arm, personTone(p.skin, dim), width: 9)
            Art.stroke(&context, arm.trimmedPath(from: 0, to: 0.8), armColor, width: 17, cap: .butt)
            Art.stroke(&context, arm.trimmedPath(from: 0, to: 0.5), armColor, width: 15)
            Art.stroke(&context, arm.trimmedPath(from: 0.74, to: 0.8), personTone(p.trim, dim), width: 17, cap: .butt)
        case .parka:
            Art.stroke(&context, arm, armColor, width: 13)
            Art.stroke(&context, arm.trimmedPath(from: 0.74, to: 0.9), personTone(p.trim, dim), width: 15, cap: .butt)
            handColor = personTone(p.cloth, 0.7 * dim)
        case .tunic, .kilt, .wrapper, .shirtTrousers, .dress, .chiton:
            Art.stroke(&context, arm, armColor, width: 11)
        }
        if !far {
            let lit = arm.applying(CGAffineTransform(translationX: -2, y: -1.5))
            Art.stroke(&context, lit.trimmedPath(from: 0.12, to: 0.7), Art.color(ArtStyle.warmLightHex, 0.22), width: 3)
        }
        bodyHand(&context, h, 5.5, handColor, open: open)
    }

    /// A hand: a round palm, with spread fingers when `open` (waving).
    static func bodyHand(_ context: inout GraphicsContext, _ c: CGPoint, _ r: CGFloat, _ color: Color, open: Bool) {
        if open {
            let spread: [(CGFloat, CGFloat)] = [(-0.95, -0.75), (-0.4, -1.45), (0.2, -1.55), (0.75, -1.3), (1.2, -0.3)]
            var fingers = Path()
            for finger in spread {
                fingers.move(to: c)
                fingers.addLine(to: pt(c.x + finger.0 * r, c.y + finger.1 * r))
            }
            Art.stroke(&context, fingers, color, width: r * 0.62)
        }
        Art.fill(&context, Art.circle(c.x, c.y, r), color)
    }

    /// One leg and its foot. `back`: the foot lies toes-back (kneeling).
    static func bodyLeg(
        _ context: inout GraphicsContext,
        _ p: Person,
        hip: CGPoint,
        knee: CGPoint,
        foot: CGPoint,
        far: Bool,
        back: Bool
    ) {
        let dim: CGFloat = far ? 0.82 : 1
        let leg = Art.polygon([hip, knee, foot], closed: false)
        Art.stroke(&context, leg, personTone(bodyLegHex(p), dim), width: 11)
        let bare: Bool = bodyBareFeet(p.garment)
        let shoeColor: Color = bare ? personTone(p.skin, dim) : personTone(p.legs, 0.7 * dim)
        switch p.garment {
        case .parka, .shirtTrousers:
            // Boots: a shaft up the shin.
            let top = bodyMix(knee, foot, 0.45)
            Art.stroke(&context, Art.line(top.x, top.y, foot.x, foot.y), shoeColor, width: 12.5)
        case .tunic, .robe, .kimono, .kilt, .wrapper, .dress, .chiton:
            break
        }
        let shoe = Art.svg(bodyShoe)
        let strap = personTone(p.skin, 0.6)
        Art.group(&context, x: foot.x, y: foot.y + 3, scaleX: back ? -1 : 1) { g in
            Art.fill(&g, shoe, shoeColor)
            if bare {
                Art.stroke(&g, Art.svg("M-8,-5 L-1,-8 M-3,-1 L-1,-8"), strap, width: 1.4)
            }
        }
    }
}

// MARK: - Skirt (the garment below the hips)

extension Kit {
    /// One edge of the skirt: points beside a leg from the hip down to the hem. `side` −1 is
    /// the front (left) edge, +1 the back edge.
    static func bodyEdge(hip: CGPoint, knee: CGPoint, foot: CGPoint, length: CGFloat, flare: CGFloat, side: CGFloat) -> [CGPoint] {
        let w: CGFloat = 13
        let d1 = bodyUnit(hip, knee)
        let d2 = bodyUnit(knee, foot)
        let n1 = pt(side * d1.y, -side * d1.x)
        let n2 = pt(side * d2.y, -side * d2.x)
        var points: [CGPoint] = [pt(hip.x + n1.x * w, hip.y + n1.y * w)]
        let wide: CGFloat = w * flare
        if length <= 1 {
            let cut = bodyMix(hip, knee, length)
            points.append(pt(cut.x + n1.x * wide, cut.y + n1.y * wide))
            return points
        }
        let bend: CGFloat = w * 0.55
        points.append(pt(knee.x + (n1.x + n2.x) * bend, knee.y + (n1.y + n2.y) * bend))
        let cut = bodyMix(knee, foot, length - 1)
        points.append(pt(cut.x + n2.x * wide, cut.y + n2.y * wide))
        return points
    }

    /// The front and back edges of the skirt for a rig (same number of points in each).
    static func bodySkirtEdges(_ r: BodyRig, length: CGFloat, flare: CGFloat) -> ([CGPoint], [CGPoint]) {
        if r.feetBack && length > 1 {
            // Kneeling in a long garment: a rounded hem that pools on the ground.
            let front: [CGPoint] = [
                pt(r.nearHip.x - 13, r.nearHip.y - 6),
                pt(r.nearKnee.x - 9, r.nearKnee.y - 8),
                pt(r.nearKnee.x - 9, 0),
            ]
            let back: [CGPoint] = [
                pt(r.farHip.x + 13, r.farHip.y - 4),
                pt(r.farFoot.x + 6, r.farFoot.y - 14),
                pt(r.farFoot.x + 10, 0),
            ]
            return (front, back)
        }
        let nearLeads: Bool = r.nearKnee.x <= r.farKnee.x
        let fHip = nearLeads ? r.nearHip : r.farHip
        let fKnee = nearLeads ? r.nearKnee : r.farKnee
        let fFoot = nearLeads ? r.nearFoot : r.farFoot
        let bHip = nearLeads ? r.farHip : r.nearHip
        let bKnee = nearLeads ? r.farKnee : r.nearKnee
        let bFoot = nearLeads ? r.farFoot : r.nearFoot
        let front = bodyEdge(hip: fHip, knee: fKnee, foot: fFoot, length: length, flare: flare, side: -1)
        let back = bodyEdge(hip: bHip, knee: bKnee, foot: bFoot, length: length, flare: flare, side: 1)
        return (front, back)
    }

    /// A line down the skirt, `t` of the way from its front edge to its back edge.
    static func bodyFold(_ front: [CGPoint], _ back: [CGPoint], _ t: CGFloat) -> Path {
        var points: [CGPoint] = []
        let n: Int = min(front.count, back.count)
        for i in 0..<n {
            points.append(bodyMix(front[i], back[i], t))
        }
        return Art.polygon(points, closed: false)
    }

    /// A garment's main shape, lit from the upper left of the final picture even when the
    /// caller has mirrored the person.
    static func bodySolid(_ context: inout GraphicsContext, _ shape: Path, _ hex: UInt32, mirrored: Bool) {
        let bounds: CGRect = shape.boundingRect
        guard bounds.width > 0, bounds.height > 0 else { return }
        personLit(&context, shape, Art.color(hex), bounds: bounds, mirrored: mirrored, light: 0.24, shade: 0.22)
    }

    static func bodySkirt(_ context: inout GraphicsContext, _ p: Person, _ r: BodyRig, mirrored: Bool) {
        let cut = bodyCut(p.garment)
        let edges = bodySkirtEdges(r, length: cut.0, flare: cut.1)
        let front: [CGPoint] = edges.0
        let back: [CGPoint] = edges.1
        var ring: [CGPoint] = front
        for point in back.reversed() {
            ring.append(point)
        }
        let shape = bodyRound(ring)
        bodySolid(&context, shape, p.cloth, mirrored: mirrored)
        guard let hemFront = front.last, let hemBack = back.last else { return }
        let hem = Art.line(hemFront.x, hemFront.y, hemBack.x, hemBack.y)
        let trim = Art.color(p.trim)
        var folds = Path()
        // The stroke width along the hem; half of it falls inside the cloth.
        var hemWidth: CGFloat = 0
        switch p.garment {
        case .tunic:
            folds.addPath(bodyFold(front, back, 0.62))
            hemWidth = 6
        case .robe:
            folds.addPath(bodyFold(front, back, 0.34))
            folds.addPath(bodyFold(front, back, 0.7))
            hemWidth = 9
        case .kimono:
            folds.addPath(bodyFold(front, back, 0.3))
        case .kilt:
            for i in 1...4 {
                folds.addPath(bodyFold(front, back, CGFloat(i) * 0.2))
            }
        case .parka:
            break
        case .wrapper:
            folds.addPath(bodyFold(front, back, 0.5))
            hemWidth = 8
        case .shirtTrousers:
            hemWidth = 8
        case .dress:
            folds.addPath(bodyFold(front, back, 0.86))
        case .chiton:
            for i in 1...3 {
                folds.addPath(bodyFold(front, back, CGFloat(i) * 0.25))
            }
            hemWidth = 4
        }
        let foldLines = folds
        let hemBand: CGFloat = hemWidth
        let apron: Bool = p.garment == .dress
        let foldColor = personTone(p.cloth, 0.8)
        Art.clipped(&context, to: shape) { g in
            if apron {
                Art.stroke(&g, bodyFold(front, back, 0.4), trim, width: 16, cap: .butt)
            }
            Art.stroke(&g, foldLines, foldColor, width: ArtStyle.detailLine)
            if hemBand > 0 {
                Art.stroke(&g, hem, trim, width: hemBand, cap: .butt)
            }
        }
        if p.garment == .parka {
            // The fur ruff along the hem.
            Art.stroke(&context, hem, trim, width: 9)
        }
    }
}

// MARK: - Torso

extension Kit {
    /// The garment from the shoulders to the hips, leaning with the rig, and its trim.
    static func bodyTorso(_ context: inout GraphicsContext, _ p: Person, _ r: BodyRig, mirrored: Bool) {
        let base: UInt32 = bodyBareChest(p.garment) ? p.skin : p.cloth
        let slim: String = "M-22,-46 Q-22,-54 -13,-54 L13,-54 Q22,-54 22,-46 L20,0 Q0,7 -20,0Z"
        let thick: String = "M-25,-44 Q-25,-55 -13,-55 L13,-55 Q25,-55 25,-44 L24,0 Q0,8 -24,0Z"
        let shape = Art.svg(p.garment == .parka ? thick : slim)
        Art.group(&context, x: r.hip.x, y: r.hip.y, rotate: -deg(r.lean)) { g in
            bodySolid(&g, shape, base, mirrored: mirrored)
            bodyTorsoTrim(&g, p)
        }
    }

    /// Collar, belt and folds, in torso units: hips at (0, 0), shoulders at y −54, 44 wide.
    static func bodyTorsoTrim(_ context: inout GraphicsContext, _ p: Person) {
        let trim = Art.color(p.trim)
        let trimDark = personTone(p.trim, 0.78)
        let fold = personTone(p.cloth, 0.8)
        let line: CGFloat = ArtStyle.detailLine
        switch p.garment {
        case .tunic:
            Art.stroke(&context, Art.svg("M-9,-54 Q-2,-45 7,-54"), trim, width: 3)
            Art.stroke(&context, Art.svg("M6,-40 Q8,-28 5,-16"), fold, width: line)
            Art.fill(&context, Art.rect(-20.5, -13, 41, 6, radius: 2), trim)
        case .robe:
            Art.stroke(&context, Art.svg("M-10,-54 L-2,-35 L8,-54"), trim, width: 3.5)
            Art.stroke(&context, Art.svg("M9,-44 Q11,-32 8,-20"), fold, width: line)
            Art.stroke(&context, Art.svg("M-8,-12 L-10,8"), trimDark, width: 4)
            Art.fill(&context, Art.rect(-20.5, -17, 41, 8, radius: 2), trim)
        case .kimono:
            Art.fill(&context, Art.svg("M-8,-54 L-1,-38 L7,-54Z"), Art.color(0xFFFFFF, 0.85))
            Art.stroke(&context, Art.svg("M-10,-54 L-2,-38"), trim, width: 4, cap: .butt)
            Art.stroke(&context, Art.svg("M9,-54 L-7,-24"), trim, width: 4, cap: .butt)
            Art.fill(&context, Art.rect(-20.5, -25, 41, 15, radius: 2), trim)
            Art.stroke(&context, Art.svg("M-20,-17.5 L20,-17.5"), trimDark, width: line, cap: .butt)
        case .kilt:
            Art.fill(&context, Art.svg("M-18,-53 C-14,-34 12,-34 16,-53 L8,-54 C4,-45 -8,-45 -10,-54Z"), trim)
            Art.stroke(&context, Art.svg("M-14,-49 C-9,-39 8,-39 12,-49"), trimDark, width: 1.4)
            Art.fill(&context, Art.rect(-20.5, -9, 41, 11, radius: 2), Art.color(p.cloth))
            Art.stroke(&context, Art.svg("M-20,-8 L20,-8"), trim, width: 2.5, cap: .butt)
        case .parka:
            Art.stroke(&context, Art.svg("M-2,-40 L-2,2"), fold, width: line)
            Art.stroke(&context, Art.svg("M-17,-51 Q-2,-40 15,-51"), trim, width: 10)
        case .wrapper:
            let wrap = Art.svg("M5,-54 L13,-54 Q22,-54 22,-46 L20,0 Q0,7 -20,0 L-21,-24Z")
            Kit.solid(&context, wrap, Art.color(p.cloth), light: 0.24, shade: 0.22)
            Art.stroke(&context, Art.svg("M13,-42 L-12,-13 M18,-32 L-2,-7"), fold, width: line)
            Art.stroke(&context, Art.svg("M5,-54 L-21,-24"), trim, width: 3.5)
        case .shirtTrousers:
            Art.stroke(&context, Art.svg("M-9,-54 Q-2,-46 7,-54"), trim, width: 3.5)
            Art.stroke(&context, Art.svg("M-2,-49 L-2,-33"), trim, width: 4.5, cap: .butt)
            Art.stroke(&context, Art.svg("M-2,-48 L-2,-34"), trimDark, width: 1.4, cap: .butt, dash: [2, 2.5])
            Art.stroke(&context, Art.svg("M8,-42 Q10,-30 7,-18"), fold, width: line)
            Art.stroke(&context, Art.svg("M-20,-8 L20,-8"), personTone(p.legs, 0.75), width: 4, cap: .butt)
        case .dress:
            Art.stroke(&context, Art.svg("M-9,-54 Q-2,-45 7,-54"), trim, width: 3)
            Art.fill(&context, Art.rect(-11, -38, 18, 34, radius: 3), trim)
            Art.stroke(&context, Art.svg("M-20,-8 L20,-8"), trimDark, width: 3, cap: .butt)
        case .chiton:
            Art.stroke(&context, Art.svg("M-15,-52 Q-1,-38 13,-52"), fold, width: line)
            Art.stroke(&context, Art.svg("M-8,-38 L-9,-17 M0,-36 L0,-17 M8,-38 L9,-17"), fold, width: line)
            Art.stroke(&context, Art.svg("M-20,-14 L20,-14"), trim, width: 2.5, cap: .butt)
            var pins = Path()
            pins.addPath(Art.circle(-15, -51, 2.6))
            pins.addPath(Art.circle(13, -51, 2.6))
            Art.fill(&context, pins, trim)
        }
    }
}

// MARK: - Sleep

extension Kit {
    /// The lying body in adult units, head end to the left (the head is drawn by `person`):
    /// a long low shape from x −26 to the feet at about x 80, 36 high.
    static func bodySleep(_ context: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let cut = bodyCut(p.garment)
        let hemX: CGFloat = 8 + 30 * cut.0
        let legColor = personTone(bodyLegHex(p), 0.82)
        Art.stroke(&context, Art.line(12, -18, 70, -15), legColor, width: 11)
        Art.stroke(&context, Art.line(12, -9, 74, -8), personTone(bodyLegHex(p), 1), width: 11)
        // Feet, toes up.
        let bare: Bool = bodyBareFeet(p.garment)
        let shoeColor: Color = bare ? Art.color(p.skin) : personTone(p.legs, 0.7)
        let shoe = Art.svg(bodyShoe)
        Art.group(&context, x: 72, y: -12, rotate: deg(80)) { g in
            Art.fill(&g, shoe, shoeColor)
        }
        Art.group(&context, x: 76, y: -3, rotate: deg(80)) { g in
            Art.fill(&g, shoe, shoeColor)
        }
        Art.stroke(&context, Art.line(-22, -19, -34, -23), personTone(p.skin, 0.9), width: 13)
        var body = Path()
        body.move(to: pt(-26, -6))
        body.addCurve(to: pt(0, -36), control1: pt(-28, -28), control2: pt(-16, -37))
        body.addCurve(to: pt(hemX, -26), control1: pt(18, -35), control2: pt(hemX - 14, -30))
        body.addLine(to: pt(hemX, -4))
        body.addQuadCurve(to: pt(hemX - 6, 0), control: pt(hemX, 0))
        body.addLine(to: pt(-20, 0))
        body.addQuadCurve(to: pt(-26, -6), control: pt(-26, 0))
        body.closeSubpath()
        let shape = body
        bodySolid(&context, shape, p.cloth, mirrored: mirrored)
        let trim = Art.color(p.trim)
        let fold = personTone(p.cloth, 0.8)
        let skin = Art.color(p.skin)
        let garment = p.garment
        var crease = Path()
        crease.move(to: pt(-8, -18))
        crease.addQuadCurve(to: pt(hemX - 6, -13), control: pt(12, -12))
        let creaseLine = crease
        Art.clipped(&context, to: shape) { g in
            if garment == .kilt {
                Art.fill(&g, Art.rect(-30, -40, 36, 44), skin)
            }
            Art.stroke(&g, creaseLine, fold, width: ArtStyle.detailLine)
            if garment != .parka {
                // The belt, sash or waistband.
                Art.stroke(&g, Art.line(7, -40, 6, 2), trim, width: 6, cap: .butt)
            }
            if garment != .parka && garment != .shirtTrousers && garment != .kimono {
                Art.stroke(&g, Art.line(hemX, -30, hemX, 2), trim, width: 6, cap: .butt)
            }
        }
        if garment == .parka {
            Art.stroke(&context, Art.line(hemX, -24, hemX, -5), trim, width: 8)
            Art.stroke(&context, Art.line(-22, -28, -24, -8), trim, width: 9)
        }
        // The near arm, resting across the chest.
        let armColor = Art.color(bodyArmHex(p))
        Art.stroke(&context, Art.svg("M-15,-29 Q2,-45 14,-28"), armColor, width: 11)
        let mitt: Color = garment == .parka ? personTone(p.cloth, 0.7) : skin
        bodyHand(&context, pt(14, -27), 5.5, mitt, open: false)
    }
}

// MARK: - Bust

extension Kit {
    /// Head, neck, shoulders and chest to the waist, facing the reader, for character-card
    /// portraits. Origin (0, 0) is the centre of the head; shoulders about 120 wide at scale 1;
    /// the body runs down to y = +150 (the frame cuts it). `wave` raises the hand on the right
    /// side of the picture beside the head.
    static func bust(
        _ context: inout GraphicsContext,
        _ p: Person,
        look: CGPoint = .zero,
        mouth: Mouth = .smile,
        wave: Bool = false
    ) {
        let skin = Art.color(p.skin)
        if wave {
            let armColor = Art.color(bodyArmHex(p))
            Art.stroke(&context, Art.svg("M50,72 Q96,66 72,6"), armColor, width: 21)
            if p.garment == .parka {
                Art.stroke(&context, Art.svg("M80,30 L75,14"), Art.color(p.trim), width: 25, cap: .butt)
            }
            let palm: Color = p.garment == .parka ? personTone(p.cloth, 0.7) : skin
            bodyHand(&context, pt(71, 0), 10.5, palm, open: true)
        }
        Art.fill(&context, Art.rect(-12, 12, 24, 38, radius: 8), personTone(p.skin, 0.9))
        let shape = Art.svg("M-60,150 L-60,62 C-60,44 -40,36 -14,34 L14,34 C40,36 60,44 60,62 L60,150Z")
        let base: UInt32 = bodyBareChest(p.garment) ? p.skin : p.cloth
        Kit.solid(&context, shape, Art.color(base), light: 0.24, shade: 0.22)
        Art.clipped(&context, to: shape) { g in
            bodyBustTrim(&g, p)
        }
        if p.garment == .parka {
            // The fur ruff rests on the shoulders, outside the body's edge.
            Art.stroke(&context, Art.svg("M-40,42 Q0,76 40,42"), Art.color(p.trim), width: 20)
            Art.stroke(&context, Art.svg("M-36,48 Q0,78 36,48"), personTone(p.trim, 0.82), width: 3)
        }
        personHead(&context, p, look: look, mouth: mouth, closedEyes: false, mirrored: false)
    }

    /// Necklines and trim of the bust, drawn clipped to the shoulders shape.
    static func bodyBustTrim(_ context: inout GraphicsContext, _ p: Person) {
        let skin = Art.color(p.skin)
        let trim = Art.color(p.trim)
        let trimDark = personTone(p.trim, 0.78)
        let fold = personTone(p.cloth, 0.8)
        let line: CGFloat = ArtStyle.contourLine
        let roundNeck = Art.svg("M-17,34 Q0,58 17,34")
        switch p.garment {
        case .tunic:
            Art.fill(&context, roundNeck, skin)
            Art.stroke(&context, roundNeck, trim, width: 6)
            Art.stroke(&context, Art.svg("M26,72 Q30,104 26,140 M-30,84 Q-33,112 -30,140"), fold, width: line)
            Art.fill(&context, Art.rect(-62, 134, 124, 20), trim)
        case .robe:
            Art.fill(&context, Art.svg("M-16,34 L0,72 L16,34Z"), skin)
            Art.stroke(&context, Art.svg("M-17,34 L0,72 L17,34"), trim, width: 7)
            Art.stroke(&context, Art.svg("M0,74 L0,130 M30,76 Q34,104 30,128"), fold, width: line)
            Art.fill(&context, Art.rect(-62, 128, 124, 24), trim)
        case .kimono:
            Art.fill(&context, Art.svg("M-17,34 L0,66 L17,34Z"), Art.color(0xFFFFFF, 0.9))
            Art.fill(&context, Art.svg("M-11,34 L0,54 L11,34Z"), skin)
            Art.stroke(&context, Art.svg("M-19,34 L2,68"), trim, width: 8, cap: .butt)
            Art.stroke(&context, Art.svg("M19,34 L-24,112"), trim, width: 8, cap: .butt)
            Art.fill(&context, Art.rect(-62, 112, 124, 40), trim)
            Art.stroke(&context, Art.svg("M-60,130 L60,130"), trimDark, width: line, cap: .butt)
        case .kilt:
            Art.fill(&context, Art.svg("M-46,42 C-38,96 38,96 46,42 L18,34 C12,58 -12,58 -18,34Z"), trim)
            Art.stroke(&context, Art.svg("M-34,48 C-26,82 26,82 34,48 M-25,44 C-18,68 18,68 25,44"), trimDark, width: 2)
            Art.fill(&context, Art.rect(-62, 136, 124, 16), Art.color(p.cloth))
        case .parka:
            Art.stroke(&context, Art.svg("M0,66 L0,150"), fold, width: line)
        case .wrapper:
            let wrap = Art.svg("M10,34 C40,36 60,44 60,62 L60,150 L-60,150 L-60,104Z")
            Kit.solid(&context, wrap, Art.color(p.cloth), light: 0.24, shade: 0.22)
            Art.stroke(&context, Art.svg("M34,58 L-34,126 M50,82 L-10,144"), fold, width: line)
            Art.stroke(&context, Art.svg("M10,34 L-60,104"), trim, width: 7)
        case .shirtTrousers:
            Art.fill(&context, roundNeck, skin)
            Art.stroke(&context, roundNeck, trim, width: 7)
            Art.stroke(&context, Art.svg("M0,48 L0,98"), trim, width: 10, cap: .butt)
            Art.stroke(&context, Art.svg("M0,52 L0,96"), trimDark, width: 2.4, cap: .butt, dash: [4, 4])
            Art.stroke(&context, Art.svg("M28,74 Q32,104 28,134"), fold, width: line)
            Art.fill(&context, Art.rect(-62, 138, 124, 14), personTone(p.legs, 0.75))
        case .dress:
            Art.fill(&context, roundNeck, skin)
            Art.stroke(&context, roundNeck, trim, width: 5)
            Art.stroke(&context, Art.svg("M-24,38 L-28,84 M24,38 L28,84"), trim, width: 7, cap: .butt)
            Art.fill(&context, Art.rect(-32, 80, 64, 76, radius: 8), trim)
            Art.stroke(&context, Art.svg("M-60,136 L60,136"), trimDark, width: 3, cap: .butt)
        case .chiton:
            let drape = Art.svg("M-32,36 Q0,68 32,36")
            Art.fill(&context, drape, skin)
            Art.stroke(&context, drape, fold, width: line)
            Art.stroke(&context, Art.svg("M-22,72 L-24,128 M0,66 L0,128 M22,72 L24,128"), fold, width: line)
            Art.stroke(&context, Art.svg("M-60,132 L60,132"), trim, width: 5, cap: .butt)
            var pins = Path()
            pins.addPath(Art.circle(-35, 41, 5))
            pins.addPath(Art.circle(35, 41, 5))
            Art.fill(&context, pins, trim)
        }
    }
}
