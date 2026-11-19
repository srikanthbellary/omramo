import SwiftUI
import OmramoCore

// The kit's four-legged animals, seen from the side (round 5).
//
// One parametric storybook beast: a bear, a lion, a hare, a donkey, a fox… are the same
// construction with different proportions, ears, tail and muzzle. The beast faces LEFT; its
// head is 60 units across and (0, 0) is the ground under the middle of its body. Front-view
// faces, busts and ready-made looks are in `Kit+BeastFaces.swift`.
//
// The torso, neck and legs are laid out by a small frame (`BeastFrame`) computed from the spec
// and the pose; every shape is built in the beast's own upright space (never in a turned
// group), so the one light stays in the upper left whatever the pose.

// MARK: - The spec

extension Kit {
    /// A four-legged animal. All colours 0xRRGGBB.
    struct Beast: Sendable {
        enum Ears: Sendable { case round, pointed, long, floppy, tufted, small }
        /// tufted: lion/donkey tuft; bare: a possum's thin bare tail; fluffy: a hare's scut.
        enum Tail: Sendable { case none, stub, bushy, thin, tufted, long, bare, fluffy }
        enum Muzzle: Sendable { case short, long, broad, pointed }

        var body: UInt32          // main coat
        var belly: UInt32         // lighter belly, chest, muzzle
        var dark: UInt32          // paws, ear tips, nose, mane, stripes
        var ears: Ears
        var tail: Tail
        var muzzle: Muzzle
        var bodyLength: CGFloat   // torso length in head-diameters: 1.2 (hare, cat) … 2.2 (horse, lion)
        var legLength: CGFloat    // leg length in head-diameters: 0.35 (bear, possum) … 1.3 (horse, donkey)
        var bulk: CGFloat         // torso thickness in head-diameters: 0.7 (cat) … 1.25 (bear)
        var mane: Bool
        var stripes: Bool
        var whiskers: Bool
        var showsEyeWhite: Bool   // true for Low-tier stories

        init(
            body: UInt32,
            belly: UInt32,
            dark: UInt32,
            ears: Ears,
            tail: Tail,
            muzzle: Muzzle,
            bodyLength: CGFloat,
            legLength: CGFloat,
            bulk: CGFloat,
            mane: Bool = false,
            stripes: Bool = false,
            whiskers: Bool = false,
            showsEyeWhite: Bool = true
        ) {
            self.body = body
            self.belly = belly
            self.dark = dark
            self.ears = ears
            self.tail = tail
            self.muzzle = muzzle
            self.bodyLength = bodyLength
            self.legLength = legLength
            self.bulk = bulk
            self.mane = mane
            self.stripes = stripes
            self.whiskers = whiskers
            self.showsEyeWhite = showsEyeWhite
        }
    }

    /// rear: up on the hind legs (a bear standing, a hare sitting up).
    enum BeastPose: Sendable { case stand, walk, sit, run, sleep, rear }
    enum BeastMood: Sendable { case happy, calm, surprised, sly, sad, proud, sleepy }

    /// Lighter (k > 1) or darker (k < 1) tone of a hex colour.
    static func beastTone(_ hex: UInt32, _ k: CGFloat) -> Color {
        let red: CGFloat = CGFloat((hex >> 16) & 0xFF) * k
        let green: CGFloat = CGFloat((hex >> 8) & 0xFF) * k
        let blue: CGFloat = CGFloat(hex & 0xFF) * k
        let r: UInt32 = UInt32(min(255, max(0, red)))
        let g: UInt32 = UInt32(min(255, max(0, green)))
        let b: UInt32 = UInt32(min(255, max(0, blue)))
        let toned: UInt32 = (r << 16) | (g << 8) | b
        return Art.color(toned)
    }
}

// MARK: - The frame: where everything is, for a spec and a pose

extension Kit {
    /// One leg: where it leaves the body, the bend, and the foot (on the ground when y = 0).
    private struct BeastLeg {
        var hip: CGPoint
        var knee: CGPoint
        var foot: CGPoint
    }

    private struct BeastFrame {
        var length: CGFloat = 100      // torso length L
        var thick: CGFloat = 60        // torso thickness T
        var leg: CGFloat = 40          // leg length G
        var neck: CGFloat = 0          // extra neck for long-legged beasts
        var centre: CGPoint = .zero    // torso centre
        var angle: CGFloat = 0         // torso turn; positive lifts the chest
        var head: CGPoint = .zero      // head centre
        var legWidth: CGFloat = 14
        var shoulder: CGPoint = .zero
        var hip: CGPoint = .zero
        var nearFront = BeastLeg(hip: .zero, knee: .zero, foot: .zero)
        var farFront = BeastLeg(hip: .zero, knee: .zero, foot: .zero)
        var nearHind = BeastLeg(hip: .zero, knee: .zero, foot: .zero)
        var farHind = BeastLeg(hip: .zero, knee: .zero, foot: .zero)
        var haunch: Bool = false       // a folded hind leg shows as a round haunch
        var tailRoot: CGPoint = .zero
        var tailFlipX: Bool = false    // the tail lies forward along the flank (sleep)
        var tailFlipY: Bool = false    // the tail sweeps up instead of hanging (low rumps)

        /// Torso space (chest at −L/2, rump at +L/2, back at −T/2) to the beast's space.
        var transform: CGAffineTransform {
            CGAffineTransform(translationX: centre.x, y: centre.y).rotated(by: angle)
        }

        func at(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: x, y: y).applying(transform)
        }
    }

    private static func beastLeg(_ hip: CGPoint, _ foot: CGPoint, bendX: CGFloat = 0, bendY: CGFloat = 0) -> BeastLeg {
        let kx: CGFloat = (hip.x + foot.x) / 2 + bendX
        let ky: CGFloat = (hip.y + foot.y) / 2 + bendY
        return BeastLeg(hip: hip, knee: CGPoint(x: kx, y: ky), foot: foot)
    }

    /// The torso and the head for the pose; the legs and tail are added by `beastFrameLimbs`.
    private static func beastFrame(_ b: Beast, _ pose: BeastPose) -> BeastFrame {
        var f = BeastFrame()
        let L: CGFloat = max(40, b.bodyLength * 60)
        let T: CGFloat = max(24, b.bulk * 60)
        let G: CGFloat = max(8, b.legLength * 60)
        let neck: CGFloat = max(0, b.legLength - 0.6) * 36
        let half: CGFloat = L / 2
        f.length = L
        f.thick = T
        f.leg = G
        f.neck = neck
        f.legWidth = clamp(T * 0.3, 9, 24)
        // How far the hip sits from the torso centre, along the torso.
        let reach: CGFloat = half - T * 0.4
        switch pose {
        case .stand, .walk:
            f.centre = CGPoint(x: 10, y: -G - T / 2)
            f.head = CGPoint(x: -half - 12 - neck * 0.4, y: -G - T * 0.75 - neck)
        case .run:
            f.angle = deg(4)
            f.centre = CGPoint(x: 10, y: -G * 0.8 - T / 2)
            f.head = CGPoint(x: -half - 18 - neck * 0.5, y: f.centre.y - T * 0.22 - neck * 0.8)
        case .sleep:
            f.centre = CGPoint(x: 10, y: -T * 0.46)
            f.head = CGPoint(x: -half - 14, y: -27)
        case .sit:
            f.angle = deg(50)
            let seatX: CGFloat = L * 0.28
            let seatY: CGFloat = -T * 0.48
            f.centre = CGPoint(x: seatX - reach * cos(f.angle), y: seatY - reach * sin(f.angle))
            let front: CGPoint = f.at(-half, 0)
            f.head = CGPoint(x: front.x - 12 - neck * 0.3, y: front.y - T * 0.28 - neck * 0.6)
        case .rear:
            f.angle = deg(78)
            let standX: CGFloat = L * 0.12
            let standY: CGFloat = -G * 0.85 - T * 0.42
            f.centre = CGPoint(x: standX - reach * cos(f.angle), y: standY - reach * sin(f.angle))
            let top: CGPoint = f.at(-half, 0)
            f.head = CGPoint(x: top.x - 12 - neck * 0.3, y: top.y - T * 0.16 - neck * 0.6)
        }
        f.shoulder = f.at(-half + T * 0.34, T * 0.125)
        f.hip = f.at(half - T * 0.34, T * 0.1)
        beastFrameLimbs(&f, pose)
        return f
    }

    /// The four legs and the tail root for the pose.
    private static func beastFrameLimbs(_ f: inout BeastFrame, _ pose: BeastPose) {
        let T: CGFloat = f.thick
        let G: CGFloat = f.leg
        let half: CGFloat = f.length / 2
        let s: CGPoint = f.shoulder
        let h: CGPoint = f.hip
        let off: CGFloat = T * 0.18
        let sFar = CGPoint(x: s.x - off, y: s.y)
        let hFar = CGPoint(x: h.x - off, y: h.y)
        f.tailRoot = f.at(half * 0.94, -T * 0.2)
        switch pose {
        case .stand:
            f.nearFront = beastLeg(s, CGPoint(x: s.x, y: 0), bendX: -2)
            f.farFront = beastLeg(sFar, CGPoint(x: sFar.x, y: 0), bendX: -2)
            f.nearHind = beastLeg(h, CGPoint(x: h.x + 2, y: 0), bendX: T * 0.08)
            f.farHind = beastLeg(hFar, CGPoint(x: hFar.x + 2, y: 0), bendX: T * 0.08)
        case .walk:
            let step: CGFloat = min(G * 0.4, 22)
            f.nearFront = beastLeg(s, CGPoint(x: s.x - step, y: 0), bendX: -3)
            f.farFront = beastLeg(sFar, CGPoint(x: sFar.x + step, y: -G * 0.08), bendX: -4)
            f.nearHind = beastLeg(h, CGPoint(x: h.x + step, y: 0), bendX: T * 0.06)
            f.farHind = beastLeg(hFar, CGPoint(x: hFar.x - step, y: 0), bendX: T * 0.1)
        case .run:
            let stride: CGFloat = G * 0.85 + 6
            f.nearFront = beastLeg(s, CGPoint(x: s.x - stride, y: -G * 0.3), bendY: -G * 0.1)
            f.farFront = beastLeg(sFar, CGPoint(x: sFar.x - stride * 0.7, y: -G * 0.12), bendY: -G * 0.1)
            f.nearHind = beastLeg(h, CGPoint(x: h.x + stride, y: -G * 0.25), bendY: G * 0.15)
            f.farHind = beastLeg(hFar, CGPoint(x: hFar.x + stride * 0.7, y: -G * 0.08), bendY: G * 0.15)
        case .sit:
            // Front legs straight down; a short-legged beast (a bear) lets its paws hang.
            let drop: CGFloat = min(-s.y, G + T * 0.55)
            f.nearFront = beastLeg(s, CGPoint(x: s.x - 4, y: s.y + drop))
            f.farFront = beastLeg(sFar, CGPoint(x: sFar.x - 4, y: s.y + drop))
            f.nearHind = beastLeg(h, CGPoint(x: h.x - T * 0.6, y: 0), bendX: -T * 0.2, bendY: -T * 0.05)
            f.farHind = beastLeg(hFar, CGPoint(x: hFar.x - T * 0.6, y: 0), bendX: -T * 0.2, bendY: -T * 0.05)
            f.haunch = true
            f.tailRoot = f.at(half * 0.96, 0)
        case .rear:
            f.nearFront = beastLeg(s, CGPoint(x: s.x - T * 0.7, y: s.y - T * 0.02), bendX: 0, bendY: T * 0.3)
            f.farFront = beastLeg(sFar, CGPoint(x: sFar.x - T * 0.6, y: s.y + T * 0.14), bendX: 0, bendY: T * 0.3)
            f.nearHind = beastLeg(h, CGPoint(x: h.x - 4, y: 0), bendX: T * 0.06)
            f.farHind = beastLeg(hFar, CGPoint(x: hFar.x - 4, y: 0), bendX: T * 0.06)
            f.haunch = true
        case .sleep:
            let pawX: CGFloat = -half - 30
            f.nearFront = beastLeg(s, CGPoint(x: pawX, y: 0), bendY: T * 0.1)
            f.farFront = beastLeg(sFar, CGPoint(x: pawX - 9, y: 0), bendY: T * 0.1)
            f.nearHind = beastLeg(h, CGPoint(x: h.x - T * 0.6, y: 0), bendX: 0, bendY: -T * 0.1)
            f.farHind = beastLeg(hFar, CGPoint(x: hFar.x - T * 0.6, y: 0), bendX: 0, bendY: -T * 0.1)
            f.haunch = true
            f.tailRoot = f.at(half * 0.8, -T * 0.05)
            f.tailFlipX = true
        }
        // A rump close to the ground: the tail sweeps up rather than hanging through the floor.
        if pose != .sleep {
            f.tailFlipY = pose == .sit || f.tailRoot.y > -40
        }
    }

    /// The top of the back (for a rider or a load), in the beast's own units for `pose`.
    static func beastBack(_ b: Beast, pose: BeastPose) -> CGPoint {
        let f: BeastFrame = beastFrame(b, pose)
        return f.at(0, -f.thick * 0.48)
    }

    /// The mouth (for something carried), in the beast's own units for `pose`.
    static func beastMouth(_ b: Beast, pose: BeastPose) -> CGPoint {
        let f: BeastFrame = beastFrame(b, pose)
        let snout: BeastSnout = beastSnout(b)
        return CGPoint(x: f.head.x + snout.mouth.x, y: f.head.y + snout.mouth.y)
    }

    /// The centre of the head, in the beast's own units for `pose`.
    static func beastHeadCentre(_ b: Beast, pose: BeastPose) -> CGPoint {
        beastFrame(b, pose).head
    }
}

// MARK: - The body

extension Kit {
    /// Light and shade for a filled shape. As `Kit.model`, but when the caller mirrors the
    /// beast the lit side is the shape's upper RIGHT, so it is upper left in the final picture.
    private static func beastShade(
        _ context: inout GraphicsContext,
        _ path: Path,
        mirrored: Bool,
        light: Double = 0.22,
        shade: Double = 0.2
    ) {
        if !mirrored {
            model(&context, path, light: light, shade: shade)
            return
        }
        let bounds: CGRect = path.boundingRect
        guard bounds.width > 0, bounds.height > 0 else { return }
        let reach: CGFloat = max(bounds.width, bounds.height)
        let cool: Color = ArtStyle.coolShade
        let warm: Color = ArtStyle.warmLight
        let shadeStops: Stops = [(cool.opacity(0), 0), (cool.opacity(shade * 0.5), 0.55), (cool.opacity(shade), 1)]
        let lightStops: Stops = [(warm.opacity(light), 0), (warm.opacity(light * 0.35), 0.5), (warm.opacity(0), 1)]
        let middle = CGPoint(x: bounds.midX, y: bounds.midY)
        let corner = CGPoint(x: bounds.minX, y: bounds.maxY)
        let lit = CGPoint(x: bounds.maxX - bounds.width * 0.18, y: bounds.minY + bounds.height * 0.12)
        Art.clipped(&context, to: path) { g in
            Art.fillLinear(&g, Path(bounds), shadeStops, from: middle, to: corner)
            Art.fillRadial(&g, Path(bounds), lightStops, center: lit, radius: reach * 0.75)
        }
    }

    private static func beastSolid(
        _ context: inout GraphicsContext,
        _ path: Path,
        _ color: Color,
        mirrored: Bool,
        light: Double = 0.22,
        shade: Double = 0.2
    ) {
        Art.fill(&context, path, color)
        beastShade(&context, path, mirrored: mirrored, light: light, shade: shade)
    }

    /// The torso outline: a fuller chest on the left, a rounded rump on the right.
    private static func beastTorsoPath(_ f: BeastFrame) -> Path {
        let h: CGFloat = f.length / 2
        let t: CGFloat = f.thick / 2
        var p = Path()
        p.move(to: pt(-h * 0.55, -t * 0.95))
        p.addCurve(to: pt(h * 0.6, -t * 0.92), control1: pt(-h * 0.1, -t * 1.06), control2: pt(h * 0.3, -t * 0.86))
        p.addCurve(to: pt(h, -t * 0.05), control1: pt(h * 0.9, -t * 0.96), control2: pt(h * 1.02, -t * 0.5))
        p.addCurve(to: pt(h * 0.55, t * 0.86), control1: pt(h, t * 0.45), control2: pt(h * 0.85, t * 0.86))
        p.addCurve(to: pt(-h * 0.5, t), control1: pt(h * 0.1, t * 0.8), control2: pt(-h * 0.2, t * 1.05))
        p.addCurve(to: pt(-h, -t * 0.1), control1: pt(-h * 0.85, t), control2: pt(-h * 1.05, t * 0.45))
        p.addCurve(to: pt(-h * 0.55, -t * 0.95), control1: pt(-h * 0.98, -t * 0.6), control2: pt(-h * 0.8, -t * 0.95))
        p.closeSubpath()
        return p.applying(f.transform)
    }

    private static func beastTorso(_ context: inout GraphicsContext, _ b: Beast, _ f: BeastFrame, mirrored: Bool) {
        let h: CGFloat = f.length / 2
        let t: CGFloat = f.thick / 2
        let torso: Path = beastTorsoPath(f)
        Art.fill(&context, torso, Art.color(b.body))
        // The lighter belly and chest, as one patch clipped to the torso.
        var patch = Path()
        patch.addEllipse(in: CGRect(x: -h, y: t * 0.45, width: h * 1.8, height: t * 1.1))
        patch.addEllipse(in: CGRect(x: -h * 1.15, y: -t * 0.2, width: h * 0.6, height: t * 1.2))
        let bellyPatch: Path = patch.applying(f.transform)
        var marks = Path()
        if b.stripes {
            for index in 0..<6 {
                let x: CGFloat = mix(-h * 0.55, h * 0.75, CGFloat(index) / 5)
                marks.move(to: pt(x, -t * 1.05))
                marks.addQuadCurve(to: pt(x + 4, -t * 0.05), control: pt(x - 6, -t * 0.5))
            }
        }
        let stripeMarks: Path = marks.applying(f.transform)
        let bellyColor: Color = Art.color(b.belly)
        let darkColor: Color = Art.color(b.dark)
        let stripeWidth: CGFloat = max(3, f.thick * 0.07)
        let striped: Bool = b.stripes
        Art.clipped(&context, to: torso) { g in
            Art.fill(&g, bellyPatch, bellyColor)
            if striped {
                Art.stroke(&g, stripeMarks, darkColor, width: stripeWidth)
            }
        }
        beastShade(&context, torso, mirrored: mirrored, light: 0.24, shade: 0.24)
    }

    /// One leg: a round-capped limb from the body to the ground with a paw (or hoof) in
    /// `b.dark`. A far leg is a darker tone and is not modelled.
    private static func beastLimb(
        _ context: inout GraphicsContext,
        _ b: Beast,
        _ leg: BeastLeg,
        width w: CGFloat,
        far: Bool,
        mirrored: Bool
    ) {
        let end = CGPoint(x: leg.foot.x, y: leg.foot.y - w * 0.45)
        var line = Path()
        line.move(to: leg.hip)
        line.addQuadCurve(to: end, control: leg.knee)
        let shape: Path = line.strokedPath(StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round))
        let joint: Path = Art.circle(leg.hip.x, leg.hip.y, w * 0.8)
        let coat: Color = far ? beastTone(b.body, 0.78) : Art.color(b.body)
        Art.fill(&context, joint, coat)
        Art.fill(&context, shape, coat)
        if !far {
            beastShade(&context, shape, mirrored: mirrored, light: 0.16, shade: 0.2)
        }
        let pawColor: Color = far ? beastTone(b.dark, 0.85) : Art.color(b.dark)
        let paw: Path = Art.ellipse(leg.foot.x - w * 0.12, leg.foot.y - w * 0.3, w * 0.66, w * 0.34)
        Art.fill(&context, paw, pawColor)
    }

    /// The neck (it also hides the join of head and torso) and, for a horse or a donkey, the
    /// crest of the mane along it.
    private static func beastNeck(_ context: inout GraphicsContext, _ b: Beast, _ f: BeastFrame, mirrored: Bool) {
        let from: CGPoint = f.at(-f.length * 0.3, -f.thick * 0.08)
        let to = CGPoint(x: f.head.x + 10, y: f.head.y + 10)
        let w: CGFloat = clamp(f.thick * 0.6, 20, 40)
        var line = Path()
        line.move(to: from)
        line.addLine(to: to)
        let shape: Path = line.strokedPath(StrokeStyle(lineWidth: w, lineCap: .round, lineJoin: .round))
        beastSolid(&context, shape, Art.color(b.body), mirrored: mirrored, light: 0.14, shade: 0.16)
        guard b.mane, b.muzzle == .long else { return }
        let top = CGPoint(x: f.head.x + 17, y: f.head.y - 19)
        let low: CGPoint = f.at(-f.length * 0.2, -f.thick * 0.5)
        var crest = Path()
        for index in 0..<7 {
            let k: CGFloat = CGFloat(index) / 6
            let x: CGFloat = mix(top.x, low.x, k) + 3
            let y: CGFloat = mix(top.y, low.y, k) - 2
            let r: CGFloat = 9 - k * 2
            crest.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        }
        Art.fill(&context, crest, Art.color(b.dark))
    }

    /// The tail, by kind. Tails are written hanging to the right of the root; the frame flips
    /// them up (a low rump) or forward along the flank (asleep).
    private static func beastTailDraw(_ context: inout GraphicsContext, _ b: Beast, _ f: BeastFrame) {
        // A thin tail (dog, cat) is written curving up, so it is never flipped up again.
        let up: Bool = b.tail == .thin ? false : f.tailFlipY
        let turn: CGFloat = up ? CGFloat.pi : 0
        let flip: CGFloat = f.tailFlipX != up ? -1 : 1
        let k: CGFloat = clamp(f.thick / 55, 0.75, 1.4)
        let coat: Color = beastTone(b.body, 0.92)
        let dark: Color = Art.color(b.dark)
        let pale: Color = beastTone(b.belly, 1.06)
        Art.group(&context, x: f.tailRoot.x, y: f.tailRoot.y, rotate: turn, scale: k, scaleX: flip) { g in
            switch b.tail {
            case .none:
                break
            case .stub:
                Art.fill(&g, Art.ellipse(5, 0, 10, 8.5), coat)
                Art.fill(&g, Art.ellipse(3, -2, 5, 4), beastTone(b.body, 1.1))
            case .fluffy:
                var puff = Path()
                puff.addEllipse(in: CGRect(x: -3, y: -10, width: 16, height: 16))
                puff.addEllipse(in: CGRect(x: 4, y: -5, width: 13, height: 13))
                puff.addEllipse(in: CGRect(x: -3, y: -3, width: 12, height: 12))
                let under: Path = puff.applying(CGAffineTransform(translationX: 1.5, y: 2))
                Art.fill(&g, under, beastTone(b.belly, 0.84))
                Art.fill(&g, puff, pale)
            case .thin:
                Art.stroke(&g, Art.svg("M-4,0 C12,-2 24,-10 24,-24 C24,-30 19,-32 17,-28"), coat, width: 6)
            case .tufted:
                Art.stroke(&g, Art.svg("M-4,0 C16,0 28,12 24,30"), coat, width: 4.5)
                Art.fill(&g, Art.svg("M24,24 C31,29 31,42 24,47 C17,42 17,29 24,24Z"), dark)
            case .long:
                Art.fill(&g, Art.svg("M-4,-5 C14,-12 26,0 26,18 C26,40 19,56 10,66 C13,50 9,32 5,20 C3,12 0,8 -4,5Z"), dark)
                Art.stroke(&g, Art.svg("M8,2 C16,14 16,36 12,54"), beastTone(b.dark, 1.35), width: ArtStyle.detailLine)
            case .bare:
                let skin: Color = beastTone(b.belly, 0.9)
                Art.stroke(&g, Art.svg("M-4,0 C18,-2 40,6 44,20 C47,32 36,38 30,30 C27,25 32,21 35,24"), skin, width: 4)
            case .bushy:
                let brush: Path = Art.svg("M-4,-7 C18,-16 46,-6 58,12 C63,23 53,27 46,21 C34,11 14,9 -4,7Z")
                Art.fill(&g, brush, coat)
                Art.clipped(&g, to: brush) { tip in
                    Art.fill(&tip, Art.circle(57, 19, 14), pale)
                }
                Art.stroke(&g, Art.svg("M6,-6 C22,-10 40,-4 50,8"), beastTone(b.body, 1.15), width: 2)
            }
        }
    }

    /// The animal, facing LEFT, in side view with the head turned a little toward the reader.
    /// Origin (0, 0) is the ground under the middle of the body. The head is 60 units across
    /// (so a bear is about 190 long and 130 tall; a hare about 130 long). The caller mirrors
    /// with `Art.group(scaleX: -1)` and passes `mirrored: true` so the catchlight and lit side
    /// stay upper-left in the final picture. `look` is in the beast's own space (x < 0 looks
    /// ahead, toward the nose). The beast draws no ground shadow: add `Kit.shadow` under it.
    static func beast(
        _ context: inout GraphicsContext,
        _ b: Beast,
        pose: BeastPose = .stand,
        mood: BeastMood = .happy,
        look: CGPoint = .zero,
        mirrored: Bool = false
    ) {
        let f: BeastFrame = beastFrame(b, pose)
        let asleep: Bool = pose == .sleep
        if !asleep {
            beastTailDraw(&context, b, f)
        }
        beastLimb(&context, b, f.farHind, width: f.legWidth, far: true, mirrored: mirrored)
        beastLimb(&context, b, f.farFront, width: f.legWidth, far: true, mirrored: mirrored)
        beastTorso(&context, b, f, mirrored: mirrored)
        beastLimb(&context, b, f.nearHind, width: f.legWidth, far: false, mirrored: mirrored)
        if f.haunch {
            let r: CGFloat = f.thick * 0.42
            let thigh: Path = Art.ellipse(f.hip.x, f.hip.y - r * 0.1, r * 1.06, r * 0.96)
            beastSolid(&context, thigh, Art.color(b.body), mirrored: mirrored, light: 0.18, shade: 0.2)
        }
        if asleep {
            beastTailDraw(&context, b, f)
        }
        beastNeck(&context, b, f, mirrored: mirrored)
        beastLimb(&context, b, f.nearFront, width: f.legWidth, far: false, mirrored: mirrored)
        let headMood: BeastMood = asleep ? .sleepy : mood
        Art.group(&context, x: f.head.x, y: f.head.y) { g in
            beastHead(&g, b, mood: headMood, look: look, mirrored: mirrored)
        }
    }
}

// MARK: - The head

extension Kit {
    /// The muzzle for a spec, in head units: its shape, the bridge of coat colour that joins it
    /// to the skull, the nose at its tip and the mouth under it.
    private struct BeastSnout {
        var shape: Path
        var bridge: Path
        var hasBridge: Bool
        var centre: CGPoint
        var nose: CGPoint
        var noseSize: CGFloat
        var mouth: CGPoint
        var mouthWidth: CGFloat
    }

    private static func beastSnout(_ b: Beast) -> BeastSnout {
        var cx: CGFloat = -21
        var cy: CGFloat = 9
        var rx: CGFloat = 12
        var ry: CGFloat = 9.5
        var noseSize: CGFloat = 4.6
        switch b.muzzle {
        case .short:
            break
        case .broad:
            cx = -22
            cy = 10
            rx = 17
            ry = 13
            noseSize = 5.6
        case .long:
            cx = -32
            cy = 10
            rx = 23
            ry = 12
            noseSize = 4.4
        case .pointed:
            cx = -28
            cy = 8
            rx = 20
            ry = 11
            noseSize = 4.2
        }
        var shape: Path = Art.ellipse(cx, cy, rx, ry)
        var nose = CGPoint(x: cx - rx * 0.9, y: cy - ry * 0.3)
        if b.muzzle == .pointed {
            shape = Art.svg("M-8,-4 C-22,-4 -38,2 -46,7 C-50,10 -47,14 -42,14 C-30,16 -18,20 -8,20 Z")
            nose = CGPoint(x: -46, y: 9)
        }
        let bridge: Path = Art.ellipse(cx + rx * 0.45, cy - ry * 0.55, rx * 0.85, ry * 0.8)
        let mouth = CGPoint(x: cx - rx * 0.25, y: cy + ry * 0.45)
        return BeastSnout(
            shape: shape,
            bridge: bridge,
            hasBridge: b.muzzle != .short,
            centre: CGPoint(x: cx, y: cy),
            nose: nose,
            noseSize: noseSize,
            mouth: mouth,
            mouthWidth: rx * 0.9
        )
    }

    /// One ear, by kind. The far ear is a darker tone behind the skull; the near ear shows its
    /// pinkish inside.
    private static func beastSideEar(_ context: inout GraphicsContext, _ b: Beast, far: Bool) {
        var data: String = "M-10,2 C-14,-8 -8,-18 0,-18 C8,-18 14,-8 10,2 Z"
        var tip = CGPoint(x: 0, y: 0)
        var tipRadius: CGFloat = 0
        var place: CGPoint = far ? CGPoint(x: -11, y: -24) : CGPoint(x: 11, y: -21)
        var lean: CGFloat = far ? -0.25 : 0.3
        switch b.ears {
        case .round:
            break
        case .small:
            data = "M-6.5,2 C-9,-5 -5,-11 0,-11 C5,-11 9,-5 6.5,2 Z"
        case .pointed, .tufted:
            data = "M-9,3 C-10,-9 -5,-19 2,-25 C8,-17 10,-7 9,3 Z"
            tip = CGPoint(x: 2, y: -25)
            tipRadius = 7
        case .long:
            data = "M-7,3 C-13,-18 -9,-46 0,-55 C9,-46 13,-18 7,3 Z"
            tip = CGPoint(x: 0, y: -55)
            tipRadius = 13
            place = far ? CGPoint(x: -8, y: -24) : CGPoint(x: 9, y: -22)
            lean = far ? 0.12 : 0.42
        case .floppy:
            data = "M-7,-5 C-2,-11 10,-9 12,2 C14,14 11,27 4,29 C-3,27 -7,10 -7,-5 Z"
            place = far ? CGPoint(x: -13, y: -21) : CGPoint(x: 15, y: -15)
            lean = far ? -0.35 : 0
        }
        let size: CGFloat = far ? 0.9 : 1
        let base: CGAffineTransform = CGAffineTransform(translationX: place.x, y: place.y)
        let move: CGAffineTransform = base.rotated(by: lean).scaledBy(x: size, y: size)
        let ear: Path = Art.svg(data).applying(move)
        let coat: Color = far ? beastTone(b.body, 0.78) : Art.color(b.body)
        let dark: Color = far ? beastTone(b.dark, 0.85) : Art.color(b.dark)
        Art.fill(&context, ear, coat)
        if tipRadius > 0 {
            let spot: Path = Art.circle(tip.x, tip.y, tipRadius).applying(move)
            Art.clipped(&context, to: ear) { g in
                Art.fill(&g, spot, dark)
            }
        }
        if !far && b.ears != .floppy {
            let inside: CGAffineTransform = move.translatedBy(x: 0, y: -2.5).scaledBy(x: 0.55, y: 0.55)
            Art.fill(&context, Art.svg(data).applying(inside), Art.color(0xF2A9A0, 0.9))
        }
        if b.ears == .tufted {
            let tuft: Path = Art.svg("M2,-25 L0,-35 M2,-25 L6,-34").applying(move)
            Art.stroke(&context, tuft, dark, width: 2)
        }
    }

    /// A lion's mane: a big scalloped ruff round the head, drawn before the head.
    private static func beastRuff(_ context: inout GraphicsContext, _ b: Beast, mirrored: Bool) {
        let cx: CGFloat = 10
        let cy: CGFloat = 2
        var ruff: Path = Art.circle(cx, cy, 34)
        for index in 0..<12 {
            let a: CGFloat = CGFloat(index) / 12 * 2 * CGFloat.pi
            let x: CGFloat = cx + cos(a) * 33
            let y: CGFloat = cy + sin(a) * 33
            ruff.addEllipse(in: CGRect(x: x - 11, y: y - 11, width: 22, height: 22))
        }
        beastSolid(&context, ruff, Art.color(b.dark), mirrored: mirrored, light: 0.2, shade: 0.24)
        Art.fill(&context, Art.circle(cx - 1, cy - 1, 30), beastTone(b.dark, 1.14))
    }

    /// The skull and cheek as one rounded shape with one gradient, and what grows on it.
    private static func beastSkull(_ context: inout GraphicsContext, _ b: Beast, mirrored: Bool) {
        var skull: Path = Art.ellipse(2, -2, 28, 27)
        skull.addEllipse(in: CGRect(x: -28, y: -12, width: 44, height: 38))
        let coat: Stops = [(beastTone(b.body, 1.16), 0), (Art.color(b.body), 0.55), (beastTone(b.body, 0.82), 1)]
        let lit: CGPoint = mirrored ? CGPoint(x: 12, y: -13) : CGPoint(x: -8, y: -13)
        Art.fillRadial(&context, skull, coat, center: lit, radius: 54)
        let dark: Color = Art.color(b.dark)
        if b.stripes {
            let marks: Path = Art.svg("M2,-29 L2,-19 M-8,-28 L-7,-20 M12,-27 L11,-19 M29,-8 L17,-6 M30,3 L18,2")
            Art.clipped(&context, to: skull) { g in
                Art.stroke(&g, marks, dark, width: 2.8)
            }
        }
        if b.mane && b.muzzle == .long {
            // A horse's or a donkey's forelock.
            let forelock: Path = Art.svg("M-6,-27 C2,-35 15,-31 13,-20 C7,-25 0,-22 -8,-15 C-10,-20 -9,-24 -6,-27Z")
            Art.fill(&context, forelock, dark)
        }
    }

    /// One eye for the mood: open (`ArtStyle.eye`), half-lidded (sly) or a closed arc.
    private static func beastSideEye(
        _ context: inout GraphicsContext,
        _ b: Beast,
        _ x: CGFloat,
        _ y: CGFloat,
        _ r: CGFloat,
        mood: BeastMood,
        look: CGPoint,
        mirrored: Bool
    ) {
        let ink: Color = Art.color(0x2A1A12)
        switch mood {
        case .proud:
            ArtStyle.smile(&context, x, y + r * 0.2, width: r * 1.7, curve: -r * 0.4, color: ink, lineWidth: ArtStyle.contourLine)
        case .sleepy:
            ArtStyle.smile(&context, x, y, width: r * 1.7, curve: r * 0.35, color: ink, lineWidth: ArtStyle.contourLine)
        case .happy, .calm, .surprised, .sly, .sad:
            let size: CGFloat = mood == .surprised ? r * 1.15 : r
            let flip: CGFloat = mirrored ? -1 : 1
            let gazeY: CGFloat = mood == .sad ? max(look.y, 0.35) : look.y
            let gaze = CGPoint(x: look.x * flip, y: gazeY)
            let white: Bool = b.showsEyeWhite
            if white {
                // A thin rim, so the white reads on a pale coat.
                Art.fill(&context, Art.circle(x, y, size + 0.9), beastTone(b.body, 0.7))
            }
            // The eye is flipped back when the beast is mirrored: its catchlight stays upper left.
            Art.group(&context, x: x, y: y, scaleX: flip) { g in
                ArtStyle.eye(&g, 0, 0, size, look: gaze, showsWhite: white)
            }
            if mood == .sly {
                let lid: Path = Art.rect(x - size - 1, y - size - 1.5, size * 2 + 2, size * 0.95 + 1.5)
                let lidColor: Color = beastTone(b.body, 0.9)
                Art.clipped(&context, to: Art.circle(x, y, size + 1)) { g in
                    Art.fill(&g, lid, lidColor)
                }
            }
        }
    }

    /// The mouth under the muzzle, by mood. Never teeth.
    private static func beastSideMouth(_ context: inout GraphicsContext, _ snout: BeastSnout, mood: BeastMood) {
        let ink: Color = Art.color(0x5A2A17)
        let x: CGFloat = snout.mouth.x
        let y: CGFloat = snout.mouth.y
        let w: CGFloat = snout.mouthWidth
        switch mood {
        case .happy:
            ArtStyle.smile(&context, x, y, width: w, curve: 2.6, color: ink)
        case .calm, .sleepy:
            ArtStyle.smile(&context, x, y, width: w * 0.8, curve: 0.9, color: ink)
        case .proud:
            ArtStyle.smile(&context, x, y, width: w * 1.1, curve: 3.6, color: ink, lineWidth: ArtStyle.contourLine)
        case .sad:
            ArtStyle.smile(&context, x, y + 2.5, width: w * 0.8, curve: -2.2, color: ink)
        case .surprised:
            Art.fill(&context, Art.ellipse(x - w * 0.1, y + 1, 3.2, 4.2), ink)
        case .sly:
            var smirk = Path()
            smirk.move(to: CGPoint(x: x - w / 2, y: y + 1))
            smirk.addQuadCurve(to: CGPoint(x: x + w / 2, y: y - 2.5), control: CGPoint(x: x + w * 0.15, y: y + 4))
            Art.stroke(&context, smirk, ink, width: ArtStyle.detailLine)
        }
    }

    /// Eyes, muzzle, nose, cheek, mouth and whiskers.
    private static func beastSideFace(
        _ context: inout GraphicsContext,
        _ b: Beast,
        mood: BeastMood,
        look: CGPoint,
        mirrored: Bool
    ) {
        let snout: BeastSnout = beastSnout(b)
        let r: CGFloat = b.showsEyeWhite ? 6.5 : 4
        // The far eye first: the bridge of a long muzzle hides part of it (three-quarter view).
        beastSideEye(&context, b, -21, -6, r * 0.82, mood: mood, look: look, mirrored: mirrored)
        beastSolid(&context, snout.shape, Art.color(b.belly), mirrored: mirrored, light: 0.12, shade: 0.16)
        if snout.hasBridge {
            Art.fill(&context, snout.bridge, Art.color(b.body))
        }
        let n: CGFloat = snout.noseSize
        let shineX: CGFloat = mirrored ? n * 0.3 : -n * 0.3
        Art.fill(&context, Art.ellipse(snout.nose.x, snout.nose.y, n, n * 0.78), Art.color(b.dark))
        Art.fill(&context, Art.ellipse(snout.nose.x + shineX, snout.nose.y - n * 0.3, n * 0.36, n * 0.24), Art.color(0xFFFFFF, 0.5))
        ArtStyle.cheek(&context, 7, 10, 7.5, alpha: 0.4)
        beastSideEye(&context, b, -3, -5, r, mood: mood, look: look, mirrored: mirrored)
        beastSideMouth(&context, snout, mood: mood)
        if b.whiskers {
            let c: CGPoint = snout.centre
            var hairs = Path()
            let ends: [(CGFloat, CGFloat)] = [(24, -6), (27, 2), (23, 9)]
            for end in ends {
                hairs.move(to: CGPoint(x: c.x + 3, y: c.y + 1))
                hairs.addLine(to: CGPoint(x: c.x + end.0, y: c.y + end.1))
            }
            hairs.move(to: CGPoint(x: c.x - 4, y: c.y + 3))
            hairs.addLine(to: CGPoint(x: c.x - 15, y: c.y + 13))
            hairs.move(to: CGPoint(x: c.x - 6, y: c.y + 2))
            hairs.addLine(to: CGPoint(x: c.x - 20, y: c.y + 9))
            Art.stroke(&context, hairs, Art.color(0xFFFFFF, 0.8), width: 1)
        }
    }

    /// The side-view head alone (as `beast` draws it), centred on (0, 0), 60 across, facing
    /// left — for composing custom bodies. A lion's ruff (`mane` with any muzzle but `.long`)
    /// reaches about 46 units from the centre.
    static func beastHead(
        _ context: inout GraphicsContext,
        _ b: Beast,
        mood: BeastMood = .happy,
        look: CGPoint = .zero,
        mirrored: Bool = false
    ) {
        // Proud: chin up.
        let tilt: CGFloat = mood == .proud ? deg(8) : 0
        Art.group(&context, rotate: tilt) { g in
            if b.mane && b.muzzle != .long {
                beastRuff(&g, b, mirrored: mirrored)
            }
            beastSideEar(&g, b, far: true)
            beastSkull(&g, b, mirrored: mirrored)
            beastSideFace(&g, b, mood: mood, look: look, mirrored: mirrored)
            beastSideEar(&g, b, far: false)
        }
    }
}
