import SwiftUI
import OmramoCore

// The cast and the shared parts of "Why the Sun and the Moon Live in the Sky" (Efik; Calabar
// and the Cross River). The Sun, the Moon and the Water are PEOPLE in this tale: the Sun and
// the Moon are kit people in plain cloth, each with a quiet glow; the Water is a bespoke
// figure made of water. Plain solid cloth only: no signs, no regalia, no masks, no patterns
// (the spec's artBrief; cultural review by an Efik reader is required and pending).

extension SunMoonArt {
    // MARK: Palette and light

    static let ramp = ArtStyle.Ramp(deep: 0x0E5F66, shade: 0x1E8F96, mid: 0x5FB7C2, light: 0xD9F0F2, glow: 0xFFE9A8, accent: 0xE8742A)
    /// Red earth of the walls.
    static let earth: UInt32 = 0xB5532E
    /// Golden palm thatch.
    static let thatch: UInt32 = 0xE2B24E
    static let wood: UInt32 = 0x7A4A2A
    static let skinTone: UInt32 = 0x6E4028
    static let foam: UInt32 = 0xF4FFFC
    static let palmFronds: UInt32 = 0x2E8F56
    static let palmTrunk: UInt32 = 0x7A5A40

    /// Clear West African daylight under a PALE sky (the ink is dark on every page).
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xCDEDF2), 0), (Art.color(0xE2F4EE), 0.6), (Art.color(0xFFF2C8), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6D8, glow: 0xFFE9A8, haze: 0xE6F4EA, far: 0xA6D4C2, mid: 0x7CC0A0, near: 0x3F9A78)
    }

    static func riverStops() -> Kit.Stops {
        let stops: Kit.Stops = [(Art.color(0xA9E2DC), 0), (Art.color(0x4DB8BC), 0.4), (Art.color(0x1E8F96), 1)]
        return stops
    }

    /// The clear, bright water that fills the yard.
    static func floodStops() -> Kit.Stops {
        let stops: Kit.Stops = [(Art.color(0xB4E8E2), 0), (Art.color(0x5CC2C6), 0.45), (Art.color(0x2A9FAA), 1)]
        return stops
    }

    /// The swept red-earth yard.
    static func yardStops() -> Kit.Stops {
        let stops: Kit.Stops = [(Art.color(0xF0C79A), 0), (Art.color(0xE0A470), 0.45), (Art.color(0xC98150), 1)]
        return stops
    }

    static func mudStops() -> Kit.Stops {
        let stops: Kit.Stops = [(Art.color(0xC79A6C), 0), (Art.color(0x9A6B48), 1)]
        return stops
    }

    static func mangroveGreens() -> Kit.Greens {
        Kit.greens(0x0E4A40, 0x1A6E52, 0x2C9462, 0x62C06A, 0xBFE874)
    }

    // MARK: The Sun and the Moon

    /// The Sun: a big, warm man in a plain orange-gold wrapper.
    static func sunLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: skinTone, hair: 0x1E1512, hairStyle: .short,
            garment: .wrapper, cloth: 0xF2921E, trim: 0xFFD35A, legs: skinTone, showsEyeWhite: true
        )
    }

    /// The Moon: his calm wife in a plain pale blue-white wrapper and head tie.
    static func moonLook() -> Kit.Person {
        Kit.Person(
            age: .adult, skin: skinTone, hair: 0x1E1512, hairStyle: .short,
            headwear: .headwrap, headwearColor: 0xE9EEFC,
            garment: .wrapper, cloth: 0xCBD7F6, trim: 0x8FA3E0, legs: skinTone, showsEyeWhite: true
        )
    }

    /// The Sun's sign: a soft golden glow (no rays, no disc).
    static func sunGlow(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat) {
        Art.glow(&context, x, y, r, Art.color(0xFFD25A), alpha: 0.7)
        Art.glow(&context, x, y, r * 0.62, Art.color(0xFFF3B8), alpha: 0.8)
    }

    /// The Moon's sign: a cool, pale halo with a soft edge.
    static func moonGlow(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat) {
        Art.glow(&context, x, y, r * 1.3, Art.color(0xAEBBF0), alpha: 0.5)
        let disc = Art.circle(x, y, r * 0.74)
        Art.fill(&context, disc, Art.color(0xF6F8FF, 0.82))
        Art.stroke(&context, disc, Art.color(0xBFCAF4, 0.75), width: 2)
        Art.glow(&context, x - r * 0.2, y - r * 0.22, r * 0.6, Color.white, alpha: 0.55)
    }

    /// Where a person's head is for `pose`, in the person's own units.
    static func headCentre(_ p: Kit.Person, _ pose: Kit.Pose) -> CGPoint {
        Kit.bodyHeadCentre(Kit.bodyFrame(p), Kit.bodyRig(p, pose))
    }

    /// The Sun, feet at the origin, facing LEFT, with his glow behind head and shoulders.
    /// `glow` scales the halo (0 = the caller has drawn it).
    static func sunFigure(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false,
        glow: CGFloat = 1
    ) {
        let p = sunLook()
        if glow > 0 {
            let c = headCentre(p, pose)
            sunGlow(&context, c.x, c.y + 12, 92 * glow)
        }
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
    }

    /// The Moon, feet at the origin, facing LEFT, with her pale halo behind her head.
    static func moonFigure(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false,
        glow: CGFloat = 1
    ) {
        let p = moonLook()
        if glow > 0 {
            let c = headCentre(p, pose)
            moonGlow(&context, c.x, c.y - 4, 58 * glow)
        }
        Kit.person(&context, p, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
    }

    /// The two of them in the sky, sitting side by side in a pale cloud, his gold glow and
    /// her silver halo side by side. Origin: the seat between them. About 280 wide; heads
    /// reach y −145, the cloud's foot y +60.
    static func skyPair(_ context: inout GraphicsContext, look: CGPoint) {
        sunGlow(&context, -50, -90, 150)
        moonGlow(&context, 66, -98, 96)
        Kit.cloud(&context, 4, 46, scale: 2.3, color: Art.color(0xFFFFFF, 0.92))
        Art.group(&context, x: -56, y: 34) { p in
            sunFigure(&p, pose: .sit, look: look, mouth: .smile, glow: 0)
        }
        Art.group(&context, x: 60, y: 34) { p in
            moonFigure(&p, pose: .sit, look: look, mouth: .smile, glow: 0)
        }
        Kit.cloud(&context, -8, 60, scale: 1.7, color: Art.color(0xFFFFFF, 0.97))
        Kit.cloud(&context, 100, 54, scale: 0.9, color: Art.color(0xFFFFFF, 0.95))
    }
}

// MARK: - The Water

extension SunMoonArt {
    /// The Water's face, centred on the origin (eyes on y 0, about 100 wide): large gentle
    /// heavy-lidded eyes, a blush, a wide smile (or an open laugh).
    static func waterFaceParts(_ context: inout GraphicsContext, look: CGPoint, laugh: Bool) {
        let deep = Art.color(0x0E5F66)
        let lid = Art.color(0x55C2C8)
        let xs: [CGFloat] = [-19, 19]
        for x in xs {
            ArtStyle.eye(&context, x, 0, 12, look: look, iris: Art.color(0x10343C), showsWhite: true)
            Art.clipped(&context, to: Art.circle(x, 0, 12.5)) { g in
                Art.fill(&g, Art.rect(x - 14, -14, 28, 8.5), lid)
            }
            Art.stroke(&context, Art.line(x - 11, -5.5, x + 11, -5.5), deep.opacity(0.55), width: 1.8)
        }
        let brows = Art.svg("M-31,-18 q11,-7 22,-1 M9,-19 q11,-6 22,1")
        Art.stroke(&context, brows, deep.opacity(0.45), width: 2.6)
        ArtStyle.cheek(&context, -33, 16, 11, color: Art.color(0xFF9E8A), alpha: 0.45)
        ArtStyle.cheek(&context, 33, 16, 11, color: Art.color(0xFF9E8A), alpha: 0.45)
        if laugh {
            let shape = Art.svg("M-22,18 C-10,23 10,23 22,18 C20,36 10,42 0,42 C-10,42 -20,36 -22,18Z")
            Art.fill(&context, shape, Art.color(0x0B4A52))
            Art.clipped(&context, to: shape) { g in
                Art.fill(&g, Art.ellipse(0, 40, 10, 6), Art.color(0xF08A7A))
            }
        } else {
            ArtStyle.smile(&context, 0, 20, width: 46, curve: 9, color: deep, lineWidth: 3.2)
        }
    }

    /// The Water: a great flowing friend made of blue-green water — a rounded wave of a body,
    /// a crest of foam for hair, arms that are curling waves, small silver fish and a crab
    /// riding in him. Origin: the middle of his foot on the waterline; about 176 wide (arms
    /// reach ±116) and 176 tall; his eyes are at y −122. Faces the reader. Never menacing.
    static func waterFigure(
        _ context: inout GraphicsContext,
        look: CGPoint = .zero,
        laugh: Bool = false,
        wave: Bool = true,
        critters: Bool = true
    ) {
        let raised: String = "M-56,-74 C-92,-72 -116,-98 -104,-124 C-98,-136 -82,-132 -86,-118"
        let lowered: String = "M-56,-70 C-90,-62 -110,-42 -102,-22 C-98,-10 -82,-12 -86,-26"
        let leftArm = Art.svg(wave ? raised : lowered)
        let rightArm = Art.svg("M56,-70 C90,-62 110,-42 102,-22 C98,-10 82,-12 86,-26")
        Art.stroke(&context, rightArm, Art.color(0x2793A2), width: 22)
        Art.stroke(&context, leftArm, Art.color(0x2FA3AE), width: 22)
        let sheen = CGAffineTransform(translationX: -3, y: -4)
        Art.stroke(&context, leftArm.applying(sheen), Art.color(0xBFF2EC, 0.6), width: 5)
        Art.stroke(&context, rightArm.applying(sheen), Art.color(0xBFF2EC, 0.4), width: 4)
        // Foam at the curl of each arm.
        let tipX: CGFloat = wave ? -86 : -86
        let tipY: CGFloat = wave ? -118 : -26
        var tips = Path()
        tips.addPath(Art.circle(tipX, tipY, 8))
        tips.addPath(Art.circle(tipX - 9, tipY - 5, 5.5))
        tips.addPath(Art.circle(tipX + 7, tipY - 7, 4.5))
        tips.addPath(Art.circle(86, -26, 8))
        tips.addPath(Art.circle(95, -31, 5.5))
        tips.addPath(Art.circle(79, -33, 4.5))
        Art.fill(&context, tips, Art.color(foam))

        let body = Art.svg("M-80,8 C-88,-40 -74,-78 -54,-96 C-60,-142 -32,-174 4,-174 C40,-174 64,-142 56,-98 C76,-80 88,-40 80,8Z")
        let tone: Kit.Stops = [(Art.color(0x8FE0DC), 0), (Art.color(0x3FB6BE), 0.5), (Art.color(0x1E8F96), 1)]
        Kit.solid(&context, body, stops: tone, light: 0.3, shade: 0.2, rim: 3)
        let lines = Art.svg("M-84,-30 q14,-10 28,0 t28,0 t28,0 t28,0 t28,0 t28,0 M-84,-8 q14,-10 28,0 t28,0 t28,0 t28,0 t28,0 t28,0")
        Art.clipped(&context, to: body) { g in
            Art.glow(&g, -14, -62, 62, Color.white, alpha: 0.2)
            Art.stroke(&g, lines, Color.white.opacity(0.3), width: 2)
            ArtStyle.tooth(&g, in: CGRect(x: -88, y: -176, width: 176, height: 186), seed: 9, alpha: 0.06)
        }
        if critters {
            fish(&context, -38, -48, scale: 0.8)
            fish(&context, 38, -64, scale: 0.7, flip: true)
            crab(&context, 22, -12, scale: 0.75)
        }
        // The crest of foam: his hair.
        var crest: Path = Kit.personScallop(cx: 2, cy: -128, rx: 50, ry: 44, from: 198, to: 342, count: 9, r: 11)
        crest.addPath(Art.svg("M30,-166 C50,-190 80,-172 66,-150 C62,-160 50,-162 42,-154Z"))
        Kit.solid(&context, crest, Art.color(foam), light: 0.1, shade: 0.12)
        Art.group(&context, x: 0, y: -122) { f in
            waterFaceParts(&f, look: look, laugh: laugh)
        }
        // Where he rises from the river: a skirt of foam and two rings.
        let skirt: Path = Kit.personScallop(cx: 0, cy: 8, rx: 84, ry: 5, from: 180, to: 360, count: 9, r: 9)
        Art.fill(&context, skirt, Art.color(foam, 0.92))
        Kit.ripples(&context, 0, 16, 196, count: 2)
    }

    /// The Water's head alone for the face chip: centred on the origin, radius about 40.
    static func waterHead(_ context: inout GraphicsContext) {
        let head = Art.svg("M0,-40 C26,-40 42,-22 41,2 C40,26 24,41 0,41 C-24,41 -40,26 -41,2 C-42,-22 -26,-40 0,-40Z")
        let tone: Kit.Stops = [(Art.color(0x8FE0DC), 0), (Art.color(0x3FB6BE), 0.6), (Art.color(0x1E8F96), 1)]
        Kit.solid(&context, head, stops: tone, light: 0.3, shade: 0.2, rim: 2)
        var crest: Path = Kit.personScallop(cx: 0, cy: -6, rx: 38, ry: 34, from: 200, to: 340, count: 7, r: 9)
        crest.addPath(Art.svg("M20,-36 C34,-52 54,-40 46,-24 C42,-32 34,-34 28,-28Z"))
        Kit.solid(&context, crest, Art.color(foam), light: 0.1, shade: 0.12)
        Art.group(&context, x: 0, y: 0, scale: 0.8) { f in
            waterFaceParts(&f, look: .zero, laugh: false)
        }
    }
}

// MARK: - The compound, the canoe and small things

extension SunMoonArt {
    /// Two courses of palm-leaf mats across a thatch roof (same arguments as `Kit.roof`).
    static func thatchRows(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat) {
        guard width > 0, height > 0 else { return }
        let shape = Kit.builtRoofShape(cx: cx, eaveY: eaveY, width: width, height: height, ridge: 0.4, bow: 0.06, lip: 0)
        let half: CGFloat = width / 2
        var rows = Path()
        for index in 1...2 {
            let y: CGFloat = eaveY - height * CGFloat(index) / 3
            rows.move(to: CGPoint(x: cx - half, y: y))
            rows.addQuadCurve(to: CGPoint(x: cx + half, y: y), control: CGPoint(x: cx, y: y + height * 0.05))
        }
        let courses = rows
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, courses, Kit.builtTone(thatch, 0.62).opacity(0.55), width: 1.8)
        }
    }

    /// A pitched roof of golden palm thatch; `width` includes the overhang.
    static func thatchRoof(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat) {
        Kit.roof(&context, cx: cx, eaveY: eaveY, width: width, height: height, color: thatch, style: .thatch)
        thatchRows(&context, cx: cx, eaveY: eaveY, width: width, height: height)
    }

    /// The roof before the thatch goes on: rafters and two purlins of sticks.
    static func roofFrame(_ context: inout GraphicsContext, cx: CGFloat, eaveY: CGFloat, width: CGFloat, height: CGFloat) {
        let half: CGFloat = width / 2
        let top: CGFloat = eaveY - height
        var sticks = Path()
        for index in 0..<9 {
            let f: CGFloat = CGFloat(index) / 8 * 2 - 1
            sticks.move(to: CGPoint(x: cx + f * half * 0.4, y: top))
            sticks.addLine(to: CGPoint(x: cx + f * half * 0.96, y: eaveY))
        }
        let fractions: [CGFloat] = [0, 0.5, 1]
        for t in fractions {
            let reach: CGFloat = half * Kit.mix(0.4, 0.98, t)
            let y: CGFloat = Kit.mix(top, eaveY, t)
            sticks.move(to: CGPoint(x: cx - reach, y: y))
            sticks.addLine(to: CGPoint(x: cx + reach, y: y))
        }
        Art.stroke(&context, sticks, Kit.propTone(wood, 1.1), width: 3.6)
        let lit = sticks.applying(CGAffineTransform(translationX: -1, y: -1))
        Art.stroke(&context, lit, Kit.propTone(wood, 1.7).opacity(0.5), width: 1)
    }

    /// A rectangular house of red earth with a pitched palm-thatch roof, standing on baseY.
    static func earthHouse(
        _ context: inout GraphicsContext,
        cx: CGFloat,
        baseY: CGFloat,
        width: CGFloat,
        wallHeight: CGFloat,
        roofHeight: CGFloat,
        windows: Int = 1
    ) {
        Kit.house(
            &context, cx: cx, baseY: baseY, width: width, wallHeight: wallHeight, roofHeight: roofHeight,
            wall: earth, roof: thatch, style: .thatch, door: 0x5A3A2A, windows: windows
        )
        thatchRows(&context, cx: cx, eaveY: baseY - wallHeight, width: width * 1.24, height: roofHeight)
    }

    /// An oil palm in the story's greens.
    static func palm(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, lean: CGFloat = 0, seed: UInt32 = 1) {
        Kit.palm(&context, x: x, baseY: baseY, height: height, lean: lean, fronds: palmFronds, trunk: palmTrunk, seed: seed)
    }

    /// A low far shore of forest between x0 and x1, tapering to the water at both ends.
    static func farShore(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, horizon H: CGFloat, height: CGFloat, light: Kit.Light, seed: UInt32) {
        let span: CGFloat = x1 - x0
        guard span > 0, height > 0 else { return }
        var land = Path()
        land.move(to: CGPoint(x: x0, y: H + 2))
        land.addCurve(
            to: CGPoint(x: x1, y: H + 2),
            control1: CGPoint(x: x0 + span * 0.15, y: H - height * 1.2),
            control2: CGPoint(x: x1 - span * 0.15, y: H - height * 1.2)
        )
        land.closeSubpath()
        Art.fill(&context, land, light.far)
        let count: Int = max(3, Int(span / 26))
        Kit.farTrees(&context, x0: x0 + span * 0.12, x1: x1 - span * 0.12, baseY: H - height * 0.7, height: height * 1.5, count: count, color: light.far, seed: seed)
        var low = Path()
        low.move(to: CGPoint(x: x0 + span * 0.04, y: H + 2))
        low.addCurve(
            to: CGPoint(x: x1 - span * 0.04, y: H + 2),
            control1: CGPoint(x: x0 + span * 0.2, y: H - height * 0.6),
            control2: CGPoint(x: x1 - span * 0.2, y: H - height * 0.6)
        )
        low.closeSubpath()
        Art.fill(&context, low, light.mid.opacity(0.8))
    }

    /// A dugout canoe afloat, bow to the left, its waterline at waterY.
    static func canoe(_ context: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, length: CGFloat) {
        Kit.boat(&context, cx: cx, waterY: waterY, length: length, hull: wood, style: .canoe)
        Kit.ripples(&context, cx, waterY + length * 0.05, length * 0.92, count: 2)
    }

    /// A pointed paddle from the grip `a` to the neck of its blade `b`.
    static func paddle(_ context: inout GraphicsContext, from a: CGPoint, to b: CGPoint) {
        Kit.propShaft(&context, a.x, a.y, b.x, b.y, wood: 0x9A6B3E, width: 4)
        let angle: CGFloat = atan2(b.y - a.y, b.x - a.x)
        var blade = Path()
        Kit.treeLeaf(&blade, b.x, b.y, 22, angle, slim: 1.1)
        Kit.solid(&context, blade, Art.color(0xB07C48), light: 0.3, shade: 0.24)
    }

    /// The Sun sitting in his canoe with his paddle. Origin: the middle of the canoe on the
    /// waterline; the canoe is 220 long, his head is at about (20, −116).
    static func sunInCanoe(_ context: inout GraphicsContext, look: CGPoint, mouth: Kit.Mouth) {
        sunGlow(&context, 20, -104, 92)
        Art.clipped(&context, to: Art.rect(-200, -400, 400, 390)) { g in
            Art.group(&g, x: 14, y: 12) { p in
                sunFigure(&p, pose: .sit, look: look, mouth: mouth, glow: 0)
            }
        }
        canoe(&context, cx: 0, waterY: 0, length: 220)
        paddle(&context, from: CGPoint(x: 6, y: -78), to: CGPoint(x: -58, y: 4))
    }

    /// A low carved wooden stool, plain, `w` wide, standing (or floating) on baseY.
    static func stool(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width w: CGFloat) {
        let h: CGFloat = w * 0.5
        let top: CGFloat = baseY - h
        let leftLeg: [CGPoint] = [
            CGPoint(x: cx - w * 0.36, y: top + h * 0.2), CGPoint(x: cx - w * 0.2, y: top + h * 0.2),
            CGPoint(x: cx - w * 0.26, y: baseY - h * 0.16), CGPoint(x: cx - w * 0.4, y: baseY - h * 0.16),
        ]
        let rightLeg: [CGPoint] = [
            CGPoint(x: cx + w * 0.2, y: top + h * 0.2), CGPoint(x: cx + w * 0.36, y: top + h * 0.2),
            CGPoint(x: cx + w * 0.4, y: baseY - h * 0.16), CGPoint(x: cx + w * 0.26, y: baseY - h * 0.16),
        ]
        var legs = Art.polygon(leftLeg)
        legs.addPath(Art.polygon(rightLeg))
        Kit.solid(&context, legs, Kit.propTone(wood, 0.85), light: 0.2, shade: 0.24)
        let foot = Art.rect(cx - w * 0.44, baseY - h * 0.2, w * 0.88, h * 0.2, radius: h * 0.08)
        Kit.solid(&context, foot, Art.color(wood), light: 0.24, shade: 0.24)
        var seat = Path()
        seat.move(to: CGPoint(x: cx - w * 0.5, y: top))
        seat.addQuadCurve(to: CGPoint(x: cx + w * 0.5, y: top), control: CGPoint(x: cx, y: top + h * 0.16))
        seat.addLine(to: CGPoint(x: cx + w * 0.46, y: top + h * 0.26))
        seat.addLine(to: CGPoint(x: cx - w * 0.46, y: top + h * 0.26))
        seat.closeSubpath()
        Kit.solid(&context, seat, Kit.propTone(wood, 1.25), light: 0.3, shade: 0.22)
    }

    /// A ladder of sticks from its foot to its top (the left rail; the other is 26 to the right).
    static func ladder(_ context: inout GraphicsContext, footX: CGFloat, footY: CGFloat, topX: CGFloat, topY: CGFloat) {
        let wide: CGFloat = 26
        let stick: UInt32 = 0x8A5A3A
        var rungs = Path()
        let count: Int = max(3, Int((footY - topY) / 22))
        for index in 1..<count {
            let t: CGFloat = CGFloat(index) / CGFloat(count)
            let x: CGFloat = Kit.mix(footX, topX, t)
            let y: CGFloat = Kit.mix(footY, topY, t)
            rungs.move(to: CGPoint(x: x, y: y))
            rungs.addLine(to: CGPoint(x: x + wide, y: y))
        }
        Art.stroke(&context, rungs, Kit.propTone(stick, 0.8), width: 3.4)
        Kit.propShaft(&context, footX, footY, topX, topY, wood: stick, width: 5)
        Kit.propShaft(&context, footX + wide, footY, topX + wide, topY, wood: stick, width: 5)
    }

    /// A tied bundle of palm leaves lying with its tips to the left: about 66 wide, the tie
    /// near (21, 0).
    static func palmBundle(_ context: inout GraphicsContext) {
        var dark = Path()
        var lit = Path()
        for index in 0..<7 {
            let t: CGFloat = CGFloat(index) / 6 - 0.5
            let a: CGFloat = CGFloat.pi + t * 0.5
            Kit.treeLeaf(&dark, 30, t * 10, 46, a, slim: 0.55)
            Kit.treeLeaf(&lit, 30, t * 10 - 2, 40, a + 0.06, slim: 0.4)
        }
        Art.fill(&context, dark, Art.color(0x2E8F56))
        Art.fill(&context, lit, Art.color(0x8FCB5A))
        Art.stroke(&context, Art.line(24, 0, 36, 0), Art.color(0x2E8F56), width: 7)
        Art.fill(&context, Art.rect(18, -8, 6, 16, radius: 2), Art.color(0xE6D3A4))
    }

    /// Shallow clear water lying over the foot of whatever stands between x0 and x1, from
    /// `y` down `depth`, with a bright line where it laps.
    static func shallows(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, depth: CGFloat) {
        guard x1 > x0, depth > 0 else { return }
        let veil: Kit.Stops = [(Art.color(0x7FD2D0, 0.6), 0), (Art.color(0x3FB0B8, 0.92), 1)]
        Art.fillLinear(&context, Art.rect(x0, y, x1 - x0, depth), veil, from: CGPoint(x: 0, y: y), to: CGPoint(x: 0, y: y + depth))
        var line = Path()
        var x: CGFloat = x0
        line.move(to: CGPoint(x: x0, y: y))
        while x < x1 {
            let next: CGFloat = min(x1, x + 24)
            line.addQuadCurve(to: CGPoint(x: next, y: y), control: CGPoint(x: (x + next) / 2, y: y - 3))
            x += 24
        }
        Art.stroke(&context, line, Color.white.opacity(0.7), width: 1.6)
    }
}

// MARK: - Water people

extension SunMoonArt {
    /// A small silver fish (about 30 long at scale 1), facing left unless `flip`.
    static func fish(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale: CGFloat, flip: Bool = false, rotate: CGFloat = 0) {
        Art.group(&context, x: x, y: y, rotate: rotate, scale: scale, scaleX: flip ? -1 : 1) { f in
            Kit.critterFish(&f, body: 0xE3EEF4, fin: 0x9DB9CC)
        }
    }

    /// A small orange crab standing on (x, y).
    static func crab(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: y, scale: scale) { c in
            Kit.critterCrab(&c, shell: 0xE8742A)
        }
    }

    /// A prawn with long whiskers, about 44 long with them, centred on (x, y), facing left.
    static func prawn(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, scale: CGFloat, flip: Bool = false) {
        Art.group(&context, x: x, y: y, scale: scale, scaleX: flip ? -1 : 1) { g in
            let shell: UInt32 = 0xF29A7A
            let whiskers = Art.svg("M-11,-1 C-18,-8 -25,-8 -31,-3 M-11,0 C-19,-2 -25,3 -29,8")
            Art.stroke(&g, whiskers, Kit.propTone(shell, 0.7), width: 1)
            let body = Art.svg("M-12,0 C-8,-9 6,-9 11,-1 C13,4 9,8 5,5 C4,-1 -4,-3 -12,0Z")
            Kit.solid(&g, body, Art.color(shell), light: 0.3, shade: 0.2)
            let tail = Art.svg("M5,5 L1,11 L6,9 L9,12 L9,6Z")
            Art.fill(&g, tail, Kit.propTone(shell, 1.15))
            Art.stroke(&g, Art.svg("M-4,-6 q1.5,2.5 0,5 M1,-7 q1.5,3 0,6 M6,-5 q1.5,2.5 0,5"), Kit.propTone(shell, 0.72), width: 0.9)
            Art.stroke(&g, Art.svg("M-6,-1 l-2,4 M-2,-1 l-2,4 M2,0 l-1,4"), Kit.propTone(shell, 0.7), width: 0.9)
            ArtStyle.eye(&g, -9.5, -3.6, 2.2)
        }
    }

    /// The Water's people in a stretch of water: silver fish with now and then a prawn or a
    /// crab, larger toward the viewer.
    static func waterPeople(_ context: inout GraphicsContext, in rect: CGRect, count: Int, seed: UInt32, scale: CGFloat = 1) {
        guard rect.width > 0, rect.height > 0 else { return }
        var random = ArtRandom(seed)
        for index in 0..<max(0, count) {
            let t: CGFloat = Kit.rnd(&random)
            let x: CGFloat = rect.minX + rect.width * Kit.rnd(&random)
            let y: CGFloat = rect.minY + rect.height * t
            let s: CGFloat = scale * (0.6 + 0.6 * t)
            let flip: Bool = Kit.rnd(&random) > 0.5
            switch index % 5 {
            case 3:
                crab(&context, x, y + 8 * s, scale: s * 0.9)
            case 4:
                prawn(&context, x, y, scale: s, flip: flip)
            default:
                let tilt: CGFloat = (Kit.rnd(&random) - 0.5) * 0.4
                fish(&context, x, y, scale: s, flip: flip, rotate: tilt)
            }
            Kit.ripples(&context, x, y + 12 * s, 34 * s, count: 1, opacity: 0.4)
        }
    }
}
