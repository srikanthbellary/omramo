import SwiftUI
import OmramoCore

// The shared illustration kit: storybook birds and a few small creatures (round 5).
//
// A bird is drawn from the side, facing LEFT, standing on (0, 0) — except the owl, which sits
// upright and faces the reader. `birdFace` and `birdBust` are the same birds for a face chip
// and a character card. The small creatures (`critter…`) are scene dressing.
//
// `look` is always in the bird's own, unmirrored frame: a negative x looks ahead, toward the
// beak. Helper names start with `bird` or `critter`.

// MARK: - Types and tones

extension Kit {
    /// A bird. All colours 0xRRGGBB.
    struct Bird: Sendable {
        enum Kind: Sendable { case songbird, rooster, crow, heron, owl, duck }
        var kind: Kind
        var body: UInt32
        var belly: UInt32
        var wing: UInt32
        var beak: UInt32
        var showsEyeWhite: Bool

        init(kind: Kind, body: UInt32, belly: UInt32, wing: UInt32, beak: UInt32, showsEyeWhite: Bool = true) {
            self.kind = kind
            self.body = body
            self.belly = belly
            self.wing = wing
            self.beak = beak
            self.showsEyeWhite = showsEyeWhite
        }
    }

    enum BirdPose: Sendable { case perch, fly, peck, sing }

    /// How one kind of bird stands, leans and flies.
    struct BirdRig: Sendable {
        /// The hip the body turns about when it sings or pecks.
        var pivot: CGPoint
        /// Degrees the body lifts to sing, and tips forward to peck.
        var sing: CGFloat
        var peck: CGFloat
        /// False for the kinds that are not drawn flying (they fall back to `perch`).
        var flies: Bool
        /// The middle of the body, the shoulder the wings grow from, the size of the wings,
        /// the underside of the belly and the length of the legs trailing in flight.
        var centre: CGPoint
        var shoulder: CGPoint
        var wing: CGFloat
        var belly: CGFloat
        var trail: CGFloat

        init(pivot: CGPoint, sing: CGFloat, peck: CGFloat, flies: Bool, centre: CGPoint = .zero, shoulder: CGPoint = .zero, wing: CGFloat = 1, belly: CGFloat = 0, trail: CGFloat = 6) {
            self.pivot = pivot
            self.sing = sing
            self.peck = peck
            self.flies = flies
            self.centre = centre
            self.shoulder = shoulder
            self.wing = wing
            self.belly = belly
            self.trail = trail
        }
    }

    /// The red of a comb and a wattle.
    static let birdRed: UInt32 = 0xD8362F

    static func birdChannel(_ value: UInt32, _ k: CGFloat) -> UInt32 {
        let scaled: CGFloat = CGFloat(value & 0xFF) * k
        let clamped: CGFloat = min(255, max(0, scaled))
        return UInt32(clamped.rounded())
    }

    /// `birdTone` as a hex value, for the helpers that take 0xRRGGBB.
    static func birdToneHex(_ hex: UInt32, _ k: CGFloat) -> UInt32 {
        let r: UInt32 = birdChannel(hex >> 16, k)
        let g: UInt32 = birdChannel(hex >> 8, k)
        let bl: UInt32 = birdChannel(hex, k)
        return (r << 16) | (g << 8) | bl
    }

    /// Lighter (k > 1) or darker (k < 1) tone of a hex colour.
    static func birdTone(_ hex: UInt32, _ k: CGFloat) -> Color {
        Art.color(birdToneHex(hex, k))
    }
}

// MARK: - Shared parts

extension Kit {
    /// The one light on a filled shape. When the caller mirrors the bird, the light is put on
    /// the drawing's upper right, so it is still on the upper left of the finished picture.
    static func birdModel(_ context: inout GraphicsContext, _ path: Path, mirrored: Bool, light: Double = 0.24, shade: Double = 0.2) {
        if !mirrored {
            Kit.model(&context, path, light: light, shade: shade)
            return
        }
        let box = path.boundingRect
        guard box.width > 0, box.height > 0 else { return }
        let reach: CGFloat = max(box.width, box.height) * 0.75
        let shadeStops: Kit.Stops = [(ArtStyle.coolShade.opacity(0), 0), (ArtStyle.coolShade.opacity(shade), 1)]
        Art.clipped(&context, to: path) { g in
            Art.fillLinear(&g, Path(box), shadeStops, from: CGPoint(x: box.midX, y: box.midY), to: CGPoint(x: box.minX, y: box.maxY))
            Art.glow(&g, box.maxX - box.width * 0.18, box.minY + box.height * 0.12, reach, ArtStyle.warmLight, alpha: light)
        }
    }

    static func birdSolid(_ context: inout GraphicsContext, _ path: Path, _ color: Color, mirrored: Bool) {
        Art.fill(&context, path, color)
        birdModel(&context, path, mirrored: mirrored)
    }

    /// A body in `b.body` with its pale patches (`belly`, clipped to the body) in `b.belly`.
    static func birdCoat(_ context: inout GraphicsContext, _ b: Bird, body: Path, belly: Path, mirrored: Bool) {
        Art.fill(&context, body, Art.color(b.body))
        let pale = Art.color(b.belly)
        Art.clipped(&context, to: body) { g in
            Art.fill(&g, belly, pale)
        }
        birdModel(&context, body, mirrored: mirrored)
    }

    /// A folded wing with its feather lines.
    static func birdFoldedWing(_ context: inout GraphicsContext, _ shape: String, lines: String, fill: UInt32, mirrored: Bool) {
        birdSolid(&context, Art.svg(shape), Art.color(fill), mirrored: mirrored)
        Art.stroke(&context, Art.svg(lines), birdTone(fill, 0.68), width: 1.2)
    }

    /// The shared eye, with its catchlight kept on the upper left of the finished picture.
    static func birdEye(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat, look: CGPoint, white: Bool, mirrored: Bool) {
        let iris = Art.color(0x2A1A12)
        let radius: CGFloat = white ? r : r * 0.61
        if white {
            Art.stroke(&context, Art.circle(x, y, radius), ArtStyle.coolShade.opacity(0.22), width: 0.9)
        }
        if mirrored {
            let turned = CGPoint(x: -look.x, y: look.y)
            Art.group(&context, x: x, y: y, scaleX: -1) { g in
                ArtStyle.eye(&g, 0, 0, radius, look: turned, iris: iris, showsWhite: white)
            }
        } else {
            ArtStyle.eye(&context, x, y, radius, look: look, iris: iris, showsWhite: white)
        }
    }

    /// Length and height of a beak seen from the side.
    static func birdBeakSize(_ kind: Bird.Kind) -> CGSize {
        switch kind {
        case .songbird: return CGSize(width: 8, height: 6.5)
        case .rooster: return CGSize(width: 10, height: 8)
        case .crow: return CGSize(width: 15, height: 9)
        case .heron: return CGSize(width: 20, height: 5.5)
        case .owl: return CGSize(width: 5, height: 5)
        case .duck: return CGSize(width: 13, height: 6.5)
        }
    }

    /// A beak pointing left from its root at (x, y); `open` parts the two halves.
    static func birdBeakSide(_ context: inout GraphicsContext, _ b: Bird, x: CGFloat, y: CGFloat, open: Bool) {
        let size = birdBeakSize(b.kind)
        let length: CGFloat = size.width
        let half: CGFloat = size.height / 2
        var upper = Path()
        upper.move(to: CGPoint(x: 1, y: -half))
        upper.addQuadCurve(to: CGPoint(x: -length, y: 0.4), control: CGPoint(x: -length * 0.55, y: -half * 0.9))
        upper.addLine(to: CGPoint(x: 1, y: 0.4))
        upper.closeSubpath()
        if b.kind == .duck {
            upper.addEllipse(in: CGRect(x: -length - 0.5, y: -half * 0.55, width: 5, height: half * 1.1))
        }
        var lower = Path()
        lower.move(to: CGPoint(x: 1, y: 0))
        lower.addLine(to: CGPoint(x: -length * 0.88, y: 0))
        lower.addQuadCurve(to: CGPoint(x: 1, y: half), control: CGPoint(x: -length * 0.45, y: half * 0.9))
        lower.closeSubpath()
        let gape: CGFloat = open ? deg(16) : 0
        let root = CGAffineTransform(translationX: x, y: y)
        if open {
            let inside: [CGPoint] = [
                CGPoint(x: x + 1, y: y - half * 0.6), CGPoint(x: x - length * 0.6, y: y), CGPoint(x: x + 1, y: y + half * 0.8),
            ]
            Art.fill(&context, Art.polygon(inside), Art.color(0xB5483C))
        }
        Art.fill(&context, lower.applying(root.rotated(by: -gape)), birdTone(b.beak, 0.78))
        Art.fill(&context, upper.applying(root.rotated(by: gape)), Art.color(b.beak))
    }

    /// Beak, eye and blush of a bird seen from the side.
    static func birdFaceSide(_ context: inout GraphicsContext, _ b: Bird, eye: CGPoint, r: CGFloat, beak: CGPoint, look: CGPoint, mirrored: Bool, open: Bool) {
        birdBeakSide(&context, b, x: beak.x, y: beak.y, open: open)
        ArtStyle.cheek(&context, eye.x + r * 0.4, eye.y + r * 1.25, r * 0.85, alpha: 0.5)
        birdEye(&context, eye.x, eye.y, r, look: look, white: b.showsEyeWhite, mirrored: mirrored)
    }

    /// Two legs from (x, top) down to the ground at y = 0, toes forward (left).
    static func birdLegs(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, width: CGFloat, color: Color, spur: Bool = false) {
        var legs = Path()
        let places: [CGFloat] = [x0, x1]
        let knee: CGFloat = top * 0.5
        let toe: CGFloat = 3 + width * 2
        for x in places {
            legs.move(to: CGPoint(x: x + 1, y: top))
            legs.addLine(to: CGPoint(x: x + 1.6, y: knee))
            legs.addLine(to: CGPoint(x: x, y: -0.6))
            legs.move(to: CGPoint(x: x - toe, y: -0.4))
            legs.addLine(to: CGPoint(x: x + toe * 0.6, y: -0.4))
            legs.move(to: CGPoint(x: x, y: -0.8))
            legs.addLine(to: CGPoint(x: x - toe * 0.8, y: -toe * 0.3))
            if spur {
                legs.move(to: CGPoint(x: x + 1.2, y: knee * 0.6))
                legs.addLine(to: CGPoint(x: x + 1.2 + toe * 0.5, y: knee * 0.6 - 1.5))
            }
        }
        Art.stroke(&context, legs, color, width: width)
    }

    /// Draws `body` turned by `angle` (radians) about `pivot`.
    static func birdTurned(_ context: inout GraphicsContext, about pivot: CGPoint, by angle: CGFloat, _ body: (inout GraphicsContext) -> Void) {
        Art.group(&context, x: pivot.x, y: pivot.y, rotate: angle) { g in
            Art.group(&g, x: -pivot.x, y: -pivot.y, body)
        }
    }

    /// What a kind wears on its head: the rooster's comb, the heron's plume. Drawn around the
    /// crown at (x, y); the plume trails to the right (the back of the head).
    static func birdCrest(_ context: inout GraphicsContext, _ b: Bird, x: CGFloat, y: CGFloat, scale: CGFloat) {
        switch b.kind {
        case .rooster:
            let comb = Kit.placed("M-8,3 C-10,-4 -5,-8 -4,-3 C-4,-10 1,-11 1,-4 C2,-10 7,-9 6,-2 C8,-5 11,-1 7,4Z", x: x, y: y, scale: scale)
            Kit.solid(&context, comb, Art.color(birdRed), light: 0.3, shade: 0.16)
        case .heron:
            let plume = Kit.placed("M0,0 C8,-2 16,2 20,10 M0,1 C6,2 11,6 13,13", x: x, y: y, scale: scale)
            Art.stroke(&context, plume, birdTone(b.body, 0.82), width: 1.5 * scale)
        case .songbird, .crow, .owl, .duck:
            break
        }
    }
}

// MARK: - The whole bird

extension Kit {
    static func birdRig(_ kind: Bird.Kind) -> BirdRig {
        switch kind {
        case .songbird:
            return BirdRig(pivot: CGPoint(x: 3, y: -6), sing: 20, peck: 40, flies: true, centre: CGPoint(x: 0, y: -24), shoulder: CGPoint(x: 2, y: -28), wing: 1, belly: -6, trail: 6)
        case .rooster:
            return BirdRig(pivot: CGPoint(x: 2, y: -18), sing: 14, peck: 60, flies: false)
        case .crow:
            return BirdRig(pivot: CGPoint(x: 3, y: -11), sing: 16, peck: 38, flies: true, centre: CGPoint(x: 0, y: -24), shoulder: CGPoint(x: 2, y: -30), wing: 1.25, belly: -9, trail: 7)
        case .heron:
            return BirdRig(pivot: CGPoint(x: 6, y: -56), sing: 10, peck: 40, flies: true, centre: CGPoint(x: 8, y: -62), shoulder: CGPoint(x: 6, y: -66), wing: 1.5, belly: -50, trail: 34)
        case .owl:
            return BirdRig(pivot: CGPoint(x: 0, y: -4), sing: 0, peck: 0, flies: false)
        case .duck:
            return BirdRig(pivot: CGPoint(x: 2, y: -6), sing: 12, peck: 30, flies: true, centre: CGPoint(x: 0, y: -18), shoulder: CGPoint(x: 4, y: -20), wing: 1.15, belly: -5, trail: 6)
        }
    }

    static func birdLegsFor(_ context: inout GraphicsContext, _ b: Bird) {
        switch b.kind {
        case .songbird:
            birdLegs(&context, x0: -3, x1: 5, top: -8, width: 1.4, color: Art.color(0xA9745A))
        case .rooster:
            birdLegs(&context, x0: -5, x1: 6, top: -15, width: 2.6, color: birdTone(b.beak, 0.92), spur: true)
        case .crow:
            birdLegs(&context, x0: -2, x1: 8, top: -11, width: 1.8, color: birdTone(b.beak, 0.8))
        case .heron:
            birdLegs(&context, x0: 1, x1: 9, top: -51, width: 1.8, color: Art.color(0x3A3A48))
        case .duck:
            birdLegs(&context, x0: -2, x1: 8, top: -7, width: 2.2, color: birdTone(b.beak, 0.92))
        case .owl:
            break // The owl's feet are drawn with its body.
        }
    }

    /// Everything but the legs, standing on (0, 0).
    static func birdBody(_ context: inout GraphicsContext, _ b: Bird, look: CGPoint, mirrored: Bool, open: Bool, flying: Bool) {
        switch b.kind {
        case .songbird:
            birdSongbirdBody(&context, b, look: look, mirrored: mirrored, open: open, flying: flying)
        case .rooster:
            birdRoosterBody(&context, b, look: look, mirrored: mirrored, open: open)
        case .crow:
            birdCrowBody(&context, b, look: look, mirrored: mirrored, open: open, flying: flying)
        case .heron:
            birdHeronBody(&context, b, look: look, mirrored: mirrored, open: open, flying: flying)
        case .owl:
            birdOwlBody(&context, b, look: look, mirrored: mirrored)
        case .duck:
            birdDuckBody(&context, b, look: look, mirrored: mirrored, open: open, flying: flying)
        }
    }

    /// A bird seen from the side, facing LEFT. Origin (0, 0) = its feet (for `fly`: the middle
    /// of the body). A songbird's body is about 44 long and 34 tall at scale 1; a rooster about
    /// 60 long and 70 tall with comb and tail; a heron about 46 long and 110 tall on long legs;
    /// a crow 54 long; an owl 40 wide and 54 tall (upright, facing the reader); a duck 56 long.
    /// The caller mirrors with `Art.group(scaleX: -1)` and passes `mirrored: true` (keeps the
    /// catchlight upper-left in the final picture). The rooster and the owl are not drawn
    /// flying: for them `fly` is the perch drawing, standing on (0, 0).
    static func bird(_ context: inout GraphicsContext, _ b: Bird, pose: BirdPose = .perch, look: CGPoint = .zero, mirrored: Bool = false) {
        let rig = birdRig(b.kind)
        var angle: CGFloat = 0
        var flying = false
        switch pose {
        case .perch:
            break
        case .sing:
            angle = deg(rig.sing)
        case .peck:
            angle = -deg(rig.peck)
        case .fly:
            flying = rig.flies
        }
        if flying {
            birdFlying(&context, b, rig: rig, look: look, mirrored: mirrored)
            return
        }
        let open: Bool = pose == .sing
        birdLegsFor(&context, b)
        birdTurned(&context, about: rig.pivot, by: angle) { g in
            birdBody(&g, b, look: look, mirrored: mirrored, open: open, flying: false)
        }
    }

    /// On the wing: the far wing up behind the body, the near wing down in front, legs tucked
    /// (the heron's trail behind). The middle of the body is on (0, 0).
    static func birdFlying(_ context: inout GraphicsContext, _ b: Bird, rig: BirdRig, look: CGPoint, mirrored: Bool) {
        let s = rig.shoulder
        let far = Kit.placed("M-6,0 C-8,-16 0,-30 14,-36 C17,-22 12,-8 6,1Z", x: s.x, y: s.y, scale: rig.wing)
        let near = Kit.placed("M-6,-2 C-4,12 6,24 20,30 C22,16 16,2 7,-4Z", x: s.x, y: s.y, scale: rig.wing)
        let quills = Kit.placed("M0,3 C3,11 9,18 16,23 M3,0 C8,7 13,12 19,17", x: s.x, y: s.y, scale: rig.wing)
        let legX: CGFloat = rig.centre.x + 6
        var legs = Path()
        legs.move(to: CGPoint(x: legX, y: rig.belly - 2))
        legs.addLine(to: CGPoint(x: legX + rig.trail, y: rig.belly + rig.trail * 0.2))
        legs.move(to: CGPoint(x: legX + 3, y: rig.belly - 2.5))
        legs.addLine(to: CGPoint(x: legX + 3 + rig.trail, y: rig.belly - 1 + rig.trail * 0.15))
        let trailing: Path = legs
        let legColor: Color = b.kind == .heron ? Art.color(0x3A3A48) : birdTone(b.beak, 0.85)
        Art.group(&context, x: -rig.centre.x, y: -rig.centre.y) { g in
            Art.stroke(&g, trailing, legColor, width: 1.6)
            Art.fill(&g, far, birdTone(b.wing, 0.8))
            birdBody(&g, b, look: look, mirrored: mirrored, open: false, flying: true)
            birdSolid(&g, near, Art.color(b.wing), mirrored: mirrored)
            Art.stroke(&g, quills, birdTone(b.wing, 0.68), width: 1.2)
        }
    }
}

// MARK: - The six kinds

extension Kit {
    /// Round body and round head as one soft pear; pale belly and cheek, a dark bib and cheek
    /// spot (the tree sparrow's marks), folded wing, short tail, short cone of a beak.
    static func birdSongbirdBody(_ context: inout GraphicsContext, _ b: Bird, look: CGPoint, mirrored: Bool, open: Bool, flying: Bool) {
        let fanned: String = "M14,-24 C24,-28 36,-27 43,-21 L38,-18 L43,-14 L37,-12 L40,-7 C30,-7 20,-10 14,-14Z"
        let folded: String = "M16,-22 C24,-22 32,-19 38,-15 C37,-12 35,-10 33,-9 C26,-11 20,-12 16,-12Z"
        Art.fill(&context, Art.svg(flying ? fanned : folded), birdTone(b.wing, 0.82))
        let body = Art.svg("M-12,-43 C-4,-44 2,-40 6,-34 C14,-30 22,-24 22,-16 C22,-9 12,-6 2,-6 C-10,-6 -19,-12 -20,-22 C-23,-26 -23,-32 -21,-36 C-19,-41 -16,-43 -12,-43Z")
        var belly = Path()
        belly.addEllipse(in: CGRect(x: -23, y: -23, width: 30, height: 20))
        belly.addEllipse(in: CGRect(x: -23, y: -34.5, width: 16, height: 11))
        birdCoat(&context, b, body: body, belly: belly, mirrored: mirrored)
        let mark = birdTone(b.wing, 0.5)
        Art.clipped(&context, to: body) { g in
            Art.fill(&g, Art.svg("M-24,-30 C-20,-28 -17,-25 -15,-21 C-19,-20 -22,-23 -25,-27Z"), mark)
        }
        Art.fill(&context, Art.circle(-10, -30, 1.8), mark.opacity(0.85))
        if !flying {
            birdFoldedWing(
                &context,
                "M-4,-28 C6,-32 18,-26 24,-14 C14,-11 2,-13 -3,-20 C-5,-23 -5,-26 -4,-28Z",
                lines: "M2,-20 C8,-19 14,-17 19,-15 M0,-24 C8,-24 15,-21 21,-17",
                fill: b.wing,
                mirrored: mirrored
            )
        }
        birdFaceSide(&context, b, eye: CGPoint(x: -15, y: -35), r: 4.6, beak: CGPoint(x: -22, y: -32), look: look, mirrored: mirrored, open: open)
    }

    /// Tall chest, an arched tail of five plumes in `b.wing`, red comb and wattle, hackle lines.
    static func birdRoosterBody(_ context: inout GraphicsContext, _ b: Bird, look: CGPoint, mirrored: Bool, open: Bool) {
        let plumes: [String] = [
            "M14,-34 C10,-56 18,-70 28,-70",
            "M16,-32 C16,-54 26,-66 36,-60",
            "M18,-30 C22,-50 34,-56 40,-46",
            "M18,-28 C26,-44 38,-44 42,-32",
            "M18,-26 C28,-36 38,-34 40,-22",
        ]
        for index in 0..<plumes.count {
            let k: CGFloat = index % 2 == 0 ? 1.0 : 1.4
            Art.stroke(&context, Art.svg(plumes[index]), birdTone(b.wing, k), width: 6)
        }
        birdCrest(&context, b, x: -13, y: -67, scale: 1)
        let body = Art.svg("M-14,-68 C-8,-68 -5,-63 -5,-57 C-4,-48 4,-44 12,-42 C22,-40 26,-32 24,-24 C22,-16 12,-13 2,-13 C-12,-13 -22,-22 -22,-34 C-22,-42 -20,-46 -21,-52 C-22,-56 -23,-60 -22,-63 C-20,-67 -17,-68 -14,-68Z")
        var belly = Path()
        belly.addEllipse(in: CGRect(x: -21, y: -31, width: 28, height: 19))
        birdCoat(&context, b, body: body, belly: belly, mirrored: mirrored)
        let hackles = Art.svg("M-18,-48 q2,6 0,11 M-13,-49 q3,7 1,13 M-8,-48 q4,6 3,12 M-3,-45 q4,5 4,10")
        Art.stroke(&context, hackles, birdTone(b.body, 0.7), width: 1.3)
        birdFoldedWing(
            &context,
            "M-2,-38 C8,-40 18,-34 22,-24 C12,-20 2,-22 -3,-29 C-4,-32 -4,-35 -2,-38Z",
            lines: "M2,-29 C8,-28 13,-26 18,-24 M1,-33 C8,-33 14,-30 20,-26",
            fill: birdToneHex(b.body, 0.82),
            mirrored: mirrored
        )
        var wattle = Path()
        wattle.addPath(Art.circle(-18, -51, 4))
        wattle.addPath(Art.circle(-15.5, -48.5, 3))
        birdSolid(&context, wattle, Art.color(birdRed), mirrored: mirrored)
        birdFaceSide(&context, b, eye: CGPoint(x: -15, y: -60), r: 4.2, beak: CGPoint(x: -22, y: -58), look: look, mirrored: mirrored, open: open)
    }

    /// Sleek and low, with a heavy beak and a sheen on the crown.
    static func birdCrowBody(_ context: inout GraphicsContext, _ b: Bird, look: CGPoint, mirrored: Bool, open: Bool, flying: Bool) {
        Art.fill(&context, Art.svg("M20,-25 C30,-24 39,-20 44,-14 L40,-10 C33,-13 26,-14 19,-14Z"), birdTone(b.wing, 0.85))
        let body = Art.svg("M-17,-40 C-10,-41 -5,-37 -1,-33 C10,-32 22,-27 28,-19 C24,-12 14,-9 4,-9 C-8,-9 -18,-13 -22,-21 C-26,-25 -27,-31 -25,-35 C-23,-39 -20,-40 -17,-40Z")
        var belly = Path()
        belly.addEllipse(in: CGRect(x: -22, y: -23, width: 34, height: 16))
        birdCoat(&context, b, body: body, belly: belly, mirrored: mirrored)
        Art.stroke(&context, Art.svg("M-13,-38 C-7,-37 -3,-34 0,-31"), birdTone(b.body, 1.6).opacity(0.5), width: 1.4)
        if !flying {
            birdFoldedWing(
                &context,
                "M-2,-30 C10,-33 24,-27 32,-16 C20,-12 6,-13 -1,-21 C-3,-24 -3,-27 -2,-30Z",
                lines: "M3,-22 C11,-21 19,-19 26,-16 M2,-26 C11,-26 20,-23 28,-18",
                fill: b.wing,
                mirrored: mirrored
            )
        }
        birdFaceSide(&context, b, eye: CGPoint(x: -17, y: -32), r: 4.2, beak: CGPoint(x: -25, y: -31), look: look, mirrored: mirrored, open: open)
    }

    /// An S of a neck, a dagger beak, a head plume, a body like a leaf above long legs.
    static func birdHeronBody(_ context: inout GraphicsContext, _ b: Bird, look: CGPoint, mirrored: Bool, open: Bool, flying: Bool) {
        let neck = Art.svg("M-8,-64 C-22,-70 -20,-84 -10,-88 C-2,-91 -2,-100 -10,-103")
        Art.stroke(&context, neck, Art.color(b.body), width: 7)
        let shadeX: CGFloat = mirrored ? -1.6 : 1.6
        Art.group(&context, x: shadeX, y: 0.6) { g in
            Art.stroke(&g, neck, ArtStyle.coolShade.opacity(0.1), width: 3)
        }
        birdCrest(&context, b, x: -8, y: -107, scale: 1)
        let body = Art.svg("M-12,-66 C-8,-74 6,-76 16,-70 C22,-66 28,-58 32,-52 C24,-50 16,-49 6,-49 C-4,-49 -12,-54 -13,-60 C-13,-62 -13,-64 -12,-66Z")
        var belly = Path()
        belly.addEllipse(in: CGRect(x: -13, y: -59, width: 30, height: 11))
        birdCoat(&context, b, body: body, belly: belly, mirrored: mirrored)
        let head = Art.svg("M-6,-104 C-6,-109 -11,-111 -16,-110 C-21,-109 -23,-105 -21,-102 C-18,-99 -8,-99 -6,-104Z")
        birdSolid(&context, head, Art.color(b.body), mirrored: mirrored)
        if !flying {
            birdFoldedWing(
                &context,
                "M-2,-68 C8,-72 20,-66 28,-54 C18,-52 6,-54 -1,-60 C-3,-63 -3,-66 -2,-68Z",
                lines: "M3,-60 C10,-59 17,-57 23,-55 M2,-64 C10,-64 18,-61 25,-57",
                fill: b.wing,
                mirrored: mirrored
            )
        }
        birdFaceSide(&context, b, eye: CGPoint(x: -14, y: -105.5), r: 3.2, beak: CGPoint(x: -21, y: -104), look: look, mirrored: mirrored, open: open)
    }

    /// A boat of a body with an upturned tail, a round head on a short neck, a flat beak.
    static func birdDuckBody(_ context: inout GraphicsContext, _ b: Bird, look: CGPoint, mirrored: Bool, open: Bool, flying: Bool) {
        let body = Art.svg("M-19,-43 C-13,-43 -10,-39 -10,-34 C-10,-30 -8,-27 -4,-25 C6,-26 16,-25 22,-22 C25,-24 28,-27 31,-28 C31,-20 28,-12 20,-8 C10,-4 -8,-4 -18,-9 C-24,-12 -25,-18 -21,-23 C-19,-26 -20,-28 -24,-30 C-28,-33 -27,-39 -24,-41 C-22,-43 -21,-43 -19,-43Z")
        var belly = Path()
        belly.addEllipse(in: CGRect(x: -23, y: -17, width: 42, height: 14))
        birdCoat(&context, b, body: body, belly: belly, mirrored: mirrored)
        if !flying {
            birdFoldedWing(
                &context,
                "M-4,-21 C8,-24 20,-21 26,-14 C16,-9 2,-10 -4,-15 C-6,-17 -6,-19 -4,-21Z",
                lines: "M2,-14 C9,-13 15,-13 21,-14 M0,-18 C8,-18 16,-17 23,-15",
                fill: b.wing,
                mirrored: mirrored
            )
        }
        birdFaceSide(&context, b, eye: CGPoint(x: -19, y: -36), r: 4, beak: CGPoint(x: -26, y: -34), look: look, mirrored: mirrored, open: open)
    }

    /// Upright and facing the reader: ear tufts, two pale face discs, big eyes that always
    /// show their whites, a small beak, a flecked breast, feet on (0, 0).
    static func birdOwlBody(_ context: inout GraphicsContext, _ b: Bird, look: CGPoint, mirrored: Bool) {
        var feet = Path()
        let toes: [CGFloat] = [-10, -7, -4, 4, 7, 10]
        for x in toes {
            feet.addEllipse(in: CGRect(x: x - 1.8, y: -4, width: 3.6, height: 4.4))
        }
        Art.fill(&context, feet, birdTone(b.beak, 0.9))
        let body = Art.svg("M0,-52 C-6,-52 -10,-50 -14,-52 L-17,-57 C-18,-50 -20,-44 -20,-36 C-20,-18 -14,-4 0,-4 C14,-4 20,-18 20,-36 C20,-44 18,-50 17,-57 L14,-52 C10,-50 6,-52 0,-52Z")
        var pale = Path()
        pale.addEllipse(in: CGRect(x: -12, y: -30, width: 24, height: 26))
        pale.addEllipse(in: CGRect(x: -18.5, y: -48, width: 19, height: 19))
        pale.addEllipse(in: CGRect(x: -0.5, y: -48, width: 19, height: 19))
        birdCoat(&context, b, body: body, belly: pale, mirrored: mirrored)
        let flecks = Art.svg("M-6,-23 q2,3 4,0 M2,-23 q2,3 4,0 M-2,-17 q2,3 4,0 M-7,-12 q2,3 4,0 M3,-12 q2,3 4,0")
        Art.stroke(&context, flecks, birdTone(b.belly, 0.74), width: 1.2)
        let wingLeft = Art.svg("M-20,-36 C-25,-26 -23,-14 -14,-7 C-16,-17 -16,-27 -20,-36Z")
        let wingRight = wingLeft.applying(CGAffineTransform(scaleX: -1, y: 1))
        birdSolid(&context, wingLeft, Art.color(b.wing), mirrored: mirrored)
        birdSolid(&context, wingRight, Art.color(b.wing), mirrored: mirrored)
        Art.fill(&context, Art.svg("M0,-35 C-3,-34 -3.5,-31 0,-27 C3.5,-31 3,-34 0,-35Z"), Art.color(b.beak))
        ArtStyle.cheek(&context, -14, -30, 3.4, alpha: 0.45)
        ArtStyle.cheek(&context, 14, -30, 3.4, alpha: 0.45)
        birdEye(&context, -9, -38.5, 6.4, look: look, white: true, mirrored: mirrored)
        birdEye(&context, 9, -38.5, 6.4, look: look, white: true, mirrored: mirrored)
    }
}

// MARK: - Face chip, portrait, ready-made looks

extension Kit {
    /// A head about 60 across, centred on (0, 0): nearly round, a little fuller at the cheeks.
    static let birdHeadShape: String = "M0,-30 C17,-30 30,-17 30,0 C30,16 18,28 2,29 C-14,30 -30,18 -30,0 C-30,-17 -17,-30 0,-30Z"

    /// Half-width and length of a beak seen from the front.
    static func birdBeakFront(_ kind: Bird.Kind) -> CGSize {
        switch kind {
        case .songbird: return CGSize(width: 5, height: 11)
        case .rooster: return CGSize(width: 5.5, height: 13)
        case .crow: return CGSize(width: 6.5, height: 15)
        case .heron: return CGSize(width: 4.5, height: 26)
        case .owl: return CGSize(width: 4.5, height: 10)
        case .duck: return CGSize(width: 11, height: 10)
        }
    }

    /// The bird's head and chest turned three-quarters toward the reader, for a face chip or a
    /// portrait; centred on (0, 0), the head about 60 across. (The owl faces the reader.)
    static func birdFace(_ context: inout GraphicsContext, _ b: Bird, look: CGPoint = .zero, singing: Bool = false) {
        if b.kind == .owl {
            birdBust(&context, b, look: look, wave: false)
            return
        }
        let chest = Art.svg("M-26,12 C-36,40 -32,70 -22,92 L36,92 C42,62 40,30 27,10Z")
        var bib = Path()
        bib.addEllipse(in: CGRect(x: -30, y: 28, width: 50, height: 72))
        birdCoat(&context, b, body: chest, belly: bib, mirrored: false)
        let isHeron: Bool = b.kind == .heron
        let crestX: CGFloat = isHeron ? 20 : 4
        let crestY: CGFloat = isHeron ? -18 : -29
        birdCrest(&context, b, x: crestX, y: crestY, scale: 2.4)
        let head = Art.svg(birdHeadShape)
        var mask = Path()
        mask.addEllipse(in: CGRect(x: -32, y: 0, width: 48, height: 32))
        birdCoat(&context, b, body: head, belly: mask, mirrored: false)
        ArtStyle.rimLight(&context, 0, 0, 30, alpha: 0.2)
        if b.kind == .rooster {
            var wattle = Path()
            wattle.addPath(Art.circle(-13, 27, 8))
            wattle.addPath(Art.circle(-6, 31, 6))
            Kit.solid(&context, wattle, Art.color(birdRed))
        }
        Art.group(&context, x: -20, y: 10, rotate: deg(-6), scale: 2.1) { g in
            birdBeakSide(&g, b, x: 0, y: 0, open: singing)
        }
        ArtStyle.cheek(&context, 13, 10, 8, alpha: 0.5)
        birdEye(&context, -17, -9, 6.6, look: look, white: b.showsEyeWhite, mirrored: false)
        birdEye(&context, 7, -9, 8.6, look: look, white: b.showsEyeWhite, mirrored: false)
    }

    /// Head, chest and one wing from the front for a character-card portrait; origin = centre
    /// of the head; runs down to about y = +120; `wave` lifts the wing on the right of the picture.
    static func birdBust(_ context: inout GraphicsContext, _ b: Bird, look: CGPoint = .zero, wave: Bool = false) {
        let folded = Art.svg("M-30,36 C-54,54 -58,96 -46,122 L-36,122 C-34,92 -32,62 -30,36Z")
        let wingColor = Art.color(b.wing)
        Kit.solid(&context, folded, wingColor)
        if wave {
            let raised = Art.svg("M26,42 C44,26 60,2 64,-24 C77,-2 71,38 42,68Z")
            Kit.solid(&context, raised, wingColor, rim: 1.6)
            let quills = Art.svg("M40,44 C50,30 58,12 62,-6 M45,54 C56,40 64,22 67,4")
            Art.stroke(&context, quills, birdTone(b.wing, 0.68), width: ArtStyle.detailLine)
        } else {
            Kit.solid(&context, folded.applying(CGAffineTransform(scaleX: -1, y: 1)), wingColor)
        }
        let body = Art.svg("M-24,18 C-42,44 -44,92 -34,122 L34,122 C44,92 42,44 24,18Z")
        var belly = Path()
        belly.addEllipse(in: CGRect(x: -25, y: 40, width: 50, height: 90))
        birdCoat(&context, b, body: body, belly: belly, mirrored: false)
        let flecks = Art.svg("M-10,62 q4,5 8,0 M4,62 q4,5 8,0 M-3,76 q4,5 8,0 M-12,90 q4,5 8,0 M6,90 q4,5 8,0")
        Art.stroke(&context, flecks, birdTone(b.belly, 0.78), width: ArtStyle.detailLine)
        birdBustHead(&context, b, look: look)
    }

    /// The head of `birdBust`, from the front, centred on (0, 0).
    static func birdBustHead(_ context: inout GraphicsContext, _ b: Bird, look: CGPoint) {
        let isOwl: Bool = b.kind == .owl
        let isHeron: Bool = b.kind == .heron
        if isOwl {
            let tufts = Art.svg("M-27,-12 L-30,-41 L-8,-27Z M27,-12 L30,-41 L8,-27Z")
            Kit.solid(&context, tufts, birdTone(b.body, 0.88))
        }
        let crestX: CGFloat = isHeron ? 14 : 0
        let crestY: CGFloat = isHeron ? -22 : -29
        birdCrest(&context, b, x: crestX, y: crestY, scale: 2.4)
        let head = Art.svg(birdHeadShape)
        var mask = Path()
        if isOwl {
            mask.addEllipse(in: CGRect(x: -28, y: -24, width: 30, height: 32))
            mask.addEllipse(in: CGRect(x: -2, y: -24, width: 30, height: 32))
        } else {
            mask.addEllipse(in: CGRect(x: -24, y: 0, width: 48, height: 32))
        }
        birdCoat(&context, b, body: head, belly: mask, mirrored: false)
        ArtStyle.rimLight(&context, 0, 0, 30, alpha: 0.2)
        let size = birdBeakFront(b.kind)
        let hw: CGFloat = size.width
        let len: CGFloat = size.height
        let top: CGFloat = 5
        if b.kind == .rooster {
            var wattle = Path()
            wattle.addPath(Art.circle(-4, top + len + 3, 5.5))
            wattle.addPath(Art.circle(4, top + len + 3, 5.5))
            Kit.solid(&context, wattle, Art.color(birdRed))
        }
        var beak = Path()
        beak.move(to: CGPoint(x: -hw, y: top + 1))
        beak.addQuadCurve(to: CGPoint(x: hw, y: top + 1), control: CGPoint(x: 0, y: top - 4))
        beak.addQuadCurve(to: CGPoint(x: 0, y: top + len), control: CGPoint(x: hw * 0.7, y: top + len * 0.7))
        beak.addQuadCurve(to: CGPoint(x: -hw, y: top + 1), control: CGPoint(x: -hw * 0.7, y: top + len * 0.7))
        beak.closeSubpath()
        Kit.solid(&context, beak, Art.color(b.beak), light: 0.3, shade: 0.18)
        ArtStyle.smile(&context, 0, top + len * 0.42, width: hw * 1.3, curve: 1.2, color: birdTone(b.beak, 0.66), lineWidth: 1.3)
        ArtStyle.cheek(&context, -21, 10, 7, alpha: 0.5)
        ArtStyle.cheek(&context, 21, 10, 7, alpha: 0.5)
        let r: CGFloat = isOwl ? 10.5 : 8.6
        let eyeY: CGFloat = isOwl ? -8 : -6
        let white: Bool = isOwl ? true : b.showsEyeWhite
        birdEye(&context, -12.5, eyeY, r, look: look, white: white, mirrored: false)
        birdEye(&context, 12.5, eyeY, r, look: look, white: white, mirrored: false)
    }

    /// Eurasian tree sparrow: chestnut cap and back, pale grey-buff belly, short dark beak (the
    /// dark cheek spot and bib are drawn on every songbird).
    static func sparrowLook() -> Bird {
        Bird(kind: .songbird, body: 0x9A5B34, belly: 0xE8DCC6, wing: 0x7B4A2B, beak: 0x3B2F2B)
    }

    /// Russet-gold body, dark green-black tail plume (`wing`), yellow beak and legs.
    static func roosterLook() -> Bird {
        Bird(kind: .rooster, body: 0xC8782A, belly: 0xE2A64A, wing: 0x1F3B34, beak: 0xF2C230)
    }

    /// White egret: white body, yellow beak; the legs are always dark.
    static func heronLook() -> Bird {
        Bird(kind: .heron, body: 0xFBFAF4, belly: 0xFFFFFF, wing: 0xECEAE0, beak: 0xF0B92E)
    }

    /// A crow in indigo-black (never pure black), with a slate beak.
    static func crowLook() -> Bird {
        Bird(kind: .crow, body: 0x2E2F45, belly: 0x3B3D5A, wing: 0x232438, beak: 0x4C4C62)
    }
}

// MARK: - Small creatures

extension Kit {
    /// A small fish seen from the side, facing left, about 30 long at scale 1, centred on (0, 0).
    static func critterFish(_ context: inout GraphicsContext, body: UInt32, fin: UInt32) {
        let finColor = Art.color(fin)
        var fins = Path()
        fins.addPath(Art.svg("M-5,-6 C-1,-12 6,-11 7,-4Z"))
        fins.addPath(Art.svg("M8,0 L15,-7 C13.4,-2 13.4,2 15,7Z"))
        Art.fill(&context, fins, finColor)
        let shape = Art.svg("M-15,0 C-10,-8 2,-9 10,-1 L10,1 C2,9 -10,8 -15,0Z")
        Kit.solid(&context, shape, Art.color(body), light: 0.3, shade: 0.2)
        let pale = birdTone(body, 1.35).opacity(0.7)
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, Art.ellipse(-3, 6, 12, 4), pale)
        }
        let scales = Art.svg("M-1,-3 q2.5,2.5 0,5 M3,-2.5 q2.5,2.5 0,5 M1,1 q2.5,2 0,4")
        Art.stroke(&context, scales, birdTone(body, 0.72).opacity(0.7), width: 0.9)
        Art.stroke(&context, Art.svg("M-6,-4.5 q2.4,4.5 0,9"), birdTone(body, 0.7), width: 1)
        Art.fill(&context, Art.svg("M-3,2 C1,2.5 3.5,5 2,8 C-0.5,7 -3,5 -3,2Z"), finColor)
        ArtStyle.cheek(&context, -8, 2.4, 2.6, alpha: 0.45)
        ArtStyle.eye(&context, -9, -1.4, 2.6)
        ArtStyle.smile(&context, -12, 2.4, width: 2.6, curve: 0.7, color: birdTone(body, 0.55), lineWidth: 0.9)
    }

    /// A small crab from the front, about 34 wide, standing on (0, 0).
    static func critterCrab(_ context: inout GraphicsContext, shell: UInt32) {
        let dark = birdTone(shell, 0.72)
        let flip = CGAffineTransform(scaleX: -1, y: 1)
        let legs = Art.svg("M-9,-5 L-15,-3 L-16,0 M-8,-3 L-12,-1 L-12.5,0 M-10,-7 L-17,-7 L-19,-1 M9,-5 L15,-3 L16,0 M8,-3 L12,-1 L12.5,0 M10,-7 L17,-7 L19,-1")
        Art.stroke(&context, legs, dark, width: 1.6)
        let arms = Art.svg("M-10,-11 C-14,-13 -15,-16 -14,-19 M10,-11 C14,-13 15,-16 14,-19")
        Art.stroke(&context, arms, dark, width: 2.2)
        let claw = Art.svg("M-14,-17 C-19,-18 -19,-25 -14,-25 L-14,-21.5 L-10.5,-24 C-9,-21 -11,-17 -14,-17Z")
        var claws = Path()
        claws.addPath(claw)
        claws.addPath(claw.applying(flip))
        Kit.solid(&context, claws, Art.color(shell))
        Art.stroke(&context, Art.svg("M-4,-13 L-5,-20 M4,-13 L5,-20"), dark, width: 1.4)
        let body = Art.svg("M-12,-8 C-12,-16 12,-16 12,-8 C12,-3 6,-1 0,-1 C-6,-1 -12,-3 -12,-8Z")
        Kit.solid(&context, body, Art.color(shell), light: 0.3, shade: 0.22)
        let shine = Art.svg("M-7,-12 q3,-2 6,0 M2,-12.5 q3,-2 6,0")
        Art.stroke(&context, shine, birdTone(shell, 1.35).opacity(0.6), width: 1)
        ArtStyle.cheek(&context, -7.5, -6, 2.6, alpha: 0.4)
        ArtStyle.cheek(&context, 7.5, -6, 2.6, alpha: 0.4)
        ArtStyle.eye(&context, -5, -21, 2.8)
        ArtStyle.eye(&context, 5, -21, 2.8)
        ArtStyle.smile(&context, 0, -6.5, width: 7, curve: 1.3, color: birdTone(shell, 0.5), lineWidth: 1.2)
    }

    /// A frog sitting, about 30 wide, on (0, 0).
    static func critterFrog(_ context: inout GraphicsContext, body: UInt32) {
        let skin = Art.color(body)
        let dark = birdTone(body, 0.6)
        var legs = Path()
        legs.addEllipse(in: CGRect(x: -16, y: -9, width: 12, height: 9))
        legs.addEllipse(in: CGRect(x: 4, y: -9, width: 12, height: 9))
        Kit.solid(&context, legs, birdTone(body, 0.86))
        var bumps = Path()
        bumps.addPath(Art.circle(-6, -19, 4.6))
        bumps.addPath(Art.circle(6, -19, 4.6))
        Art.fill(&context, bumps, skin)
        let shape = Art.svg("M-11,-2 C-15,-12 -9,-21 0,-21 C9,-21 15,-12 11,-2 C6,0 -6,0 -11,-2Z")
        Kit.solid(&context, shape, skin, light: 0.3, shade: 0.2)
        let pale = birdTone(body, 1.45).opacity(0.75)
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, Art.ellipse(0, -3, 8, 6.5), pale)
        }
        let feet = Art.svg("M-8,-1 L-11,0 M-8,-1 L-8,0.4 M-8,-1 L-5.5,0 M8,-1 L11,0 M8,-1 L8,0.4 M8,-1 L5.5,0 M-15,-1 L-18,0 M15,-1 L18,0")
        Art.stroke(&context, feet, dark, width: 1.4)
        ArtStyle.cheek(&context, -9, -10, 3, alpha: 0.45)
        ArtStyle.cheek(&context, 9, -10, 3, alpha: 0.45)
        ArtStyle.eye(&context, -6, -19.5, 3.3)
        ArtStyle.eye(&context, 6, -19.5, 3.3)
        ArtStyle.smile(&context, 0, -11.5, width: 13, curve: 1.8, color: dark, lineWidth: 1.3)
    }

    /// A butterfly with its wings spread, about 24 across, centred on (0, 0).
    static func critterButterfly(_ context: inout GraphicsContext, wing: UInt32) {
        let flip = CGAffineTransform(scaleX: -1, y: 1)
        let upper = Art.svg("M-0.6,-1 C-4,-11 -13,-11 -12,-3 C-11,2 -4,2 -0.6,0Z")
        let lower = Art.svg("M-0.6,0 C-5,1 -9,4 -7,8 C-4,10 -1,5 -0.6,1Z")
        var lowers = Path()
        lowers.addPath(lower)
        lowers.addPath(lower.applying(flip))
        Art.fill(&context, lowers, birdTone(wing, 0.85))
        var uppers = Path()
        uppers.addPath(upper)
        uppers.addPath(upper.applying(flip))
        Kit.solid(&context, uppers, Art.color(wing), light: 0.3, shade: 0.14)
        var spots = Path()
        spots.addPath(Art.circle(-8, -5, 1.8))
        spots.addPath(Art.circle(8, -5, 1.8))
        spots.addPath(Art.circle(-5, 5, 1.1))
        spots.addPath(Art.circle(5, 5, 1.1))
        Art.fill(&context, spots, birdTone(wing, 1.5).opacity(0.85))
        let dark = birdTone(wing, 0.4)
        Art.stroke(&context, Art.line(0, -4, 0, 5), dark, width: 2)
        Art.stroke(&context, Art.svg("M0,-4 q-1,-4 -4,-6 M0,-4 q1,-4 4,-6"), dark, width: 0.8)
    }

    /// A bee on the wing, facing left, about 16 long, centred on (0, 0).
    static func critterBee(_ context: inout GraphicsContext) {
        let brown = Art.color(0x4A3324)
        var wings = Path()
        wings.addEllipse(in: CGRect(x: -3, y: -9, width: 6, height: 8))
        wings.addEllipse(in: CGRect(x: 1.5, y: -8, width: 5.5, height: 7))
        Art.fill(&context, wings, Art.color(0xFFFFFF, 0.72))
        Art.stroke(&context, wings, Art.color(0x9FB7D8, 0.6), width: 0.6)
        Art.fill(&context, Art.svg("M7,-0.8 L9.6,0.4 L7,1.4Z"), brown)
        let body = Art.ellipse(1.5, 0, 6.5, 4.6)
        Kit.solid(&context, body, Art.color(0xF6C12E), light: 0.3, shade: 0.2)
        var stripes = Path()
        stripes.addRect(CGRect(x: 0.4, y: -5, width: 2, height: 10))
        stripes.addRect(CGRect(x: 4, y: -5, width: 2, height: 10))
        Art.clipped(&context, to: body) { g in
            Art.fill(&g, stripes, brown)
        }
        Art.fill(&context, Art.circle(-5, 0, 3.4), brown)
        Art.stroke(&context, Art.svg("M-6,-3 q-2,-2.4 -4,-2.2 M-4.6,-3.2 q-1,-3 -3,-3.6"), brown, width: 0.7)
        ArtStyle.eye(&context, -5.8, -0.4, 1.7)
    }

    /// A lizard basking, seen from above, facing left, about 26 long, centred on (0, 0).
    static func critterLizard(_ context: inout GraphicsContext, body: UInt32) {
        let skin = Art.color(body)
        let dark = birdTone(body, 0.66)
        Art.stroke(&context, Art.svg("M4,0 C8,3 10,-4 14,-1"), skin, width: 2.2)
        let legs = Art.svg("M-7,-2 L-9,-6 L-11,-6 M-7,2 L-9,6 L-11,6 M2,-2 L4,-6 L6,-6.4 M2,2 L4,6 L6,6.4")
        Art.stroke(&context, legs, dark, width: 1.3)
        var shape = Art.svg("M-9,0 C-7,-4.4 3,-4 6,0 C3,4 -7,4.4 -9,0Z")
        shape.addPath(Art.svg("M-13.5,0 C-13.5,-3.2 -9.4,-3.8 -7.6,0 C-9.4,3.8 -13.5,3.2 -13.5,0Z"))
        Kit.solid(&context, shape, skin, light: 0.3, shade: 0.2)
        var spots = Path()
        spots.addPath(Art.circle(-4, 0, 1.1))
        spots.addPath(Art.circle(-0.5, 0, 1.2))
        spots.addPath(Art.circle(3, 0, 0.9))
        Art.fill(&context, spots, birdTone(body, 1.4).opacity(0.7))
        ArtStyle.eye(&context, -11, -2.2, 1.3, showsWhite: false)
        ArtStyle.eye(&context, -11, 2.2, 1.3, showsWhite: false)
    }
}
