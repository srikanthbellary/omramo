import SwiftUI
import OmramoCore

// The palette, the lights, the three characters and the story's own parts for
// "Daedalus and Icarus": Bronze Age Crete (the Minoans), not classical Greece.

// MARK: - Palette and light

extension IcarusArt {
    /// Aegean blue and white sunlight, wax gold, Minoan red.
    static let ramp = ArtStyle.Ramp(deep: 0x0F2340, shade: 0x2F6A9A, mid: 0x7FB3D5, light: 0xF6F1E6, glow: 0xE8B84A, accent: 0xB4442E)
    static let limestone: UInt32 = 0xEDE3CF
    static let minoanRed: UInt32 = 0xA8452E
    static let capitalBlack: UInt32 = 0x2C2824
    static let wax: UInt32 = 0xE8B84A
    static let linen: UInt32 = 0xF3EAD6
    static let timber: UInt32 = 0x9A6A44
    static let bronze: UInt32 = 0xB7853F
    static let leather: UInt32 = 0x7A4A2A
    static let darkFeathers: [UInt32] = [0xB4B1AA, 0x9C9993, 0xC9C6BE, 0x8C8984, 0xA8A59F]
    static let paleFeathers: [UInt32] = [0xF6F4EE, 0xE2E0D8, 0xFBFAF5, 0xD5D3CB, 0xECEAE2]

    /// A clear Mediterranean day (the palace, the pictures).
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xC2DBEA), 0),
            (Art.color(0xDCEAF2), 0.45),
            (Art.color(0xF0F3EC), 0.82),
            (Art.color(0xF5E3B6), 1)
        ]
        return Kit.Light(sky: sky, sun: 0xFFFAEC, glow: 0xF2D48C, haze: 0xE5EEF2, far: 0xBACDD7, mid: 0x9CB4C0, near: 0x7B98A8)
    }

    /// Dawn on the tower: pale gold and rose.
    static func dawn() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xF2E6E0), 0),
            (Art.color(0xF6DAD0), 0.42),
            (Art.color(0xFAE3C6), 0.8),
            (Art.color(0xF3CC86), 1)
        ]
        return Kit.Light(sky: sky, sun: 0xFFF5DA, glow: 0xF0BE62, haze: 0xF6DDCC, far: 0xCBB9C0, mid: 0xAE9FAF, near: 0x857F95)
    }

    /// High over the sea at a bright, pale noon.
    static func noon() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0xD0E4F0), 0),
            (Art.color(0xE5F0F5), 0.5),
            (Art.color(0xF4F6F1), 0.86),
            (Art.color(0xF6E9C4), 1)
        ]
        return Kit.Light(sky: sky, sun: 0xFFFFF6, glow: 0xF4DE9E, haze: 0xEAF2F5, far: 0xBFD3DE, mid: 0x9FBCCB, near: 0x7FA0B4)
    }

    /// The Aegean, pale at the horizon, deep toward the viewer.
    static func seaStops() -> Kit.Stops {
        [(Art.color(0x9CC6E0), 0), (Art.color(0x5E9ACB), 0.35), (Art.color(0x3F7FB2), 0.7), (Art.color(0x2F6A9A), 1)]
    }
}

// MARK: - The cast

extension IcarusArt {
    enum Who: Sendable { case daedalus, icarus, minos }

    /// A lean grey-streaked maker of about fifty in a plain short kilt with a patterned belt.
    static func daedalusLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xC48A5E, hair: 0x6A625A, hairStyle: .long, beard: .short, garment: .kilt, cloth: 0xE9DDC4, trim: 0x8A4A00, legs: 0xC48A5E, showsEyeWhite: false)
    }

    /// A boy of about twelve with long dark curls in a blue-and-white kilt, bare feet.
    static func icarusLook() -> Kit.Person {
        Kit.Person(age: .child, skin: 0xD49C6E, hair: 0x2B1D16, hairStyle: .long, garment: .kilt, cloth: 0x3E7FB8, trim: 0xF6F1E6, legs: 0xD49C6E, showsEyeWhite: false)
    }

    /// A tall heavy king with long black locks, a short black beard, a lily-gold band and a
    /// long robe patterned in red and blue.
    static func minosLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xB98058, hair: 0x1C1512, hairStyle: .long, beard: .short, headwear: .circlet, headwearColor: 0xE8B84A, garment: .robe, cloth: 0xB4442E, trim: 0x2F6A9A, legs: 0x7A2E22, showsEyeWhite: false)
    }

    static func look(_ who: Who) -> Kit.Person {
        switch who {
        case .daedalus: return daedalusLook()
        case .icarus: return icarusLook()
        case .minos: return minosLook()
        }
    }

    /// The head of a character with its own signature details (Daedalus's grey streaks,
    /// Icarus's curls on the shoulders, the lily on Minos's band), centred on (0, 0).
    static func head(_ g: inout GraphicsContext, _ who: Who, look gaze: CGPoint = .zero, mouth: Kit.Mouth = .smile, mirrored: Bool = false) {
        let p = look(who)
        if who == .icarus {
            let hair: Color = Kit.personTone(p.hair, 1.0)
            let curls: [(CGFloat, CGFloat, CGFloat)] = [(-30, 40, 6), (-27, 52, 5.5), (30, 40, 6), (27, 52, 5.5), (-33, 26, 5), (33, 26, 5)]
            for c in curls {
                Art.fill(&g, Art.circle(c.0, c.1, c.2), hair)
            }
        }
        Kit.personHead(&g, p, look: gaze, mouth: mouth, closedEyes: false, mirrored: mirrored)
        switch who {
        case .daedalus:
            let streaks = Art.svg("M-21,-22 C-14,-29 -6,-31 3,-30 M-25,-8 C-27,4 -27,14 -25,22 M24,-6 C26,6 26,14 24,22")
            Art.stroke(&g, streaks, Art.color(0xC2BCB2, 0.75), width: 2)
            Art.stroke(&g, Art.svg("M-9,20 C-5,24 5,24 9,20"), Art.color(0xC2BCB2, 0.6), width: 1.6)
        case .icarus:
            let ringlets = Art.svg("M-20,-26 q3,-4 6,0 M-6,-30 q3,-4 6,0 M8,-28 q3,-4 6,0")
            Art.stroke(&g, ringlets, Kit.personTone(p.hair, 1.5), width: 1.4)
        case .minos:
            let lily = Art.svg("M0,-18 C-3,-24 -6,-27 -9,-27 C-6,-24 -4,-21 -2,-18Z M0,-18 C3,-24 6,-27 9,-27 C6,-24 4,-21 2,-18Z M0,-18 C-1,-24 0,-29 0,-30 C0,-29 1,-24 0,-18Z")
            Art.fill(&g, lily, Art.color(0xF6E7B0))
        }
    }

    /// A person on any rig (the kit's poses or our own), origin at the feet, facing LEFT.
    static func figure(
        _ g: inout GraphicsContext,
        _ who: Who,
        rig r: Kit.BodyRig,
        look gaze: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        headTilt: CGFloat = 0,
        mirrored: Bool = false
    ) {
        let p = look(who)
        let f = Kit.bodyFrame(p)
        Art.group(&g, scale: f.k) { b in
            Kit.bodyFigure(&b, p, r, mirrored: mirrored)
            dress(&b, who, rig: r)
        }
        let c = Kit.bodyHeadCentre(f, r)
        let tilt: CGFloat = Kit.deg(headTilt) - Kit.deg(r.lean) * 0.45
        Art.group(&g, x: c.x, y: c.y, rotate: tilt, scale: f.headScale) { h in
            head(&h, who, look: gaze, mouth: mouth, mirrored: mirrored)
        }
    }

    /// A stock pose through `figure`.
    static func person(_ g: inout GraphicsContext, _ who: Who, pose: Kit.Pose, look gaze: CGPoint = .zero, mouth: Kit.Mouth = .smile, mirrored: Bool = false) {
        let r = Kit.bodyRig(look(who), pose)
        figure(&g, who, rig: r, look: gaze, mouth: mouth, mirrored: mirrored)
    }

    /// The garment details the kit lacks, in adult body units over the figure.
    static func dress(_ g: inout GraphicsContext, _ who: Who, rig r: Kit.BodyRig) {
        let upright: Bool = r.hip.y < -50 && abs(r.lean) < 8
        switch who {
        case .icarus:
            if upright {
                let zig = Art.svg("M-15,-40 L-11,-36 L-7,-40 L-3,-36 L1,-40 L5,-36 L9,-40 L13,-36")
                Art.stroke(&g, zig, Art.color(0xF6F1E6, 0.9), width: 2)
            }
        case .daedalus:
            if upright {
                let dots = Art.svg("M-14,-44 L-14,-43 M-6,-44 L-6,-43 M2,-44 L2,-43 M10,-44 L10,-43")
                Art.stroke(&g, dots, Art.color(0x8A4A00, 0.7), width: 2.4)
            }
        case .minos:
            if upright {
                Art.stroke(&g, Art.svg("M-6,-100 C-8,-70 -10,-40 -12,-8"), Art.color(0x2F6A9A, 0.85), width: 5)
                Art.stroke(&g, Art.svg("M-6,-100 C-8,-70 -10,-40 -12,-8"), Art.color(0xF6E7B0, 0.8), width: 1.2, dash: [2, 5])
                let s = Kit.bodyShoulder(r, near: true)
                let ax: CGFloat = s.x + r.nearElbow.x * 0.5
                let ay: CGFloat = s.y + r.nearElbow.y * 0.5
                Kit.solid(&g, Art.ellipse(ax, ay, 6, 3), Art.color(0xE8B84A), light: 0.4, shade: 0.2)
            }
        }
    }
}

// MARK: - Rigs of our own

extension IcarusArt {
    /// Standing at the edge with both arms spread wide in the wings.
    static func spreadRig(lift: CGFloat = 0) -> Kit.BodyRig {
        var r = Kit.BodyRig()
        r.nearElbow = Kit.pt(-22, 2 - lift * 0.5)
        r.nearHand = Kit.pt(-44, -lift)
        r.farElbow = Kit.pt(22, 2 - lift * 0.5)
        r.farHand = Kit.pt(44, -lift)
        return r
    }

    /// Arms half open and low, the wings hanging along them.
    static func lowWingsRig() -> Kit.BodyRig {
        var r = Kit.BodyRig()
        r.nearElbow = Kit.pt(-14, 16)
        r.nearHand = Kit.pt(-28, 30)
        r.farElbow = Kit.pt(14, 16)
        r.farHand = Kit.pt(28, 30)
        return r
    }

    /// Bending toward the boy, one hand out to him.
    static func bendRig() -> Kit.BodyRig {
        var r = Kit.BodyRig()
        r.lean = 10
        r.nearElbow = Kit.pt(-16, 14)
        r.nearHand = Kit.pt(-34, 18)
        r.farElbow = Kit.pt(14, 18)
        r.farHand = Kit.pt(26, 34)
        return r
    }

    /// In flight (drawn inside a group turned about -64°): both arms back and up along the
    /// back, the legs trailing.
    static func flightRig() -> Kit.BodyRig {
        var r = Kit.BodyRig()
        r.nearElbow = Kit.pt(22, -2)
        r.nearHand = Kit.pt(44, -4)
        r.farElbow = Kit.pt(19, -12)
        r.farHand = Kit.pt(38, -23)
        r.nearKnee = Kit.pt(-6, -30)
        r.nearFoot = Kit.pt(-2, -3)
        r.farKnee = Kit.pt(10, -31)
        r.farFoot = Kit.pt(16, -6)
        return r
    }
}

// MARK: - Feathers and wings

extension IcarusArt {
    /// One feather from `base` along the unit direction (dx, dy), `length` long: a vane
    /// fuller on one side, modelled by the light, with its quill.
    static func featherShape(_ g: inout GraphicsContext, base b: CGPoint, dx: CGFloat, dy: CGFloat, length: CGFloat, tone: UInt32) {
        let ex: CGFloat = -dy
        let ey: CGFloat = dx
        let w: CGFloat = min(9, length * 0.17)
        let tip = CGPoint(x: b.x + dx * length, y: b.y + dy * length)
        let midX: CGFloat = b.x + dx * length * 0.5
        let midY: CGFloat = b.y + dy * length * 0.5
        let full: CGFloat = w * 1.3
        var vane = Path()
        vane.move(to: b)
        vane.addQuadCurve(to: tip, control: CGPoint(x: midX + ex * full, y: midY + ey * full))
        vane.addQuadCurve(to: b, control: CGPoint(x: midX - ex * w, y: midY - ey * w))
        vane.closeSubpath()
        Kit.solid(&g, vane, Art.color(tone), light: 0.2, shade: 0.18)
        Art.stroke(&g, Art.line(b.x, b.y, tip.x, tip.y), Kit.personTone(tone, 0.76), width: 0.9)
    }

    /// A loose feather with its base at (x, y); `angle` in degrees, 0 points straight up.
    static func feather(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, length: CGFloat, angle: CGFloat, tone: UInt32) {
        let a: CGFloat = Kit.deg(angle)
        featherShape(&g, base: CGPoint(x: x, y: y), dx: sin(a), dy: -cos(a), length: length, tone: tone)
    }

    /// Rows of feathers laid out on the floor, shortest to longest, like a shepherd's pipes.
    static func featherRows(_ g: inout GraphicsContext, x0: CGFloat, y0: CGFloat, rows: Int, count: Int, scale s: CGFloat) {
        let n: Int = max(2, count)
        for row in 0..<max(1, rows) {
            let y: CGFloat = y0 + CGFloat(row) * 15 * s
            let shift: CGFloat = CGFloat(row) * 7 * s
            let shadowX: CGFloat = x0 + shift + CGFloat(n) * 4.2 * s
            Art.fill(&g, Art.ellipse(shadowX, y + 1.5 * s, CGFloat(n) * 4.8 * s, 2.6 * s), ArtStyle.coolShade.opacity(0.1))
            for i in 0..<n {
                let t: CGFloat = CGFloat(i) / CGFloat(n - 1)
                let x: CGFloat = x0 + shift + CGFloat(i) * 8.5 * s
                let length: CGFloat = (10 + 20 * t) * s
                let tones: [UInt32] = row % 2 == 0 ? paleFeathers : darkFeathers
                feather(&g, x: x, y: y, length: length, angle: -14, tone: tones[i % tones.count])
            }
        }
    }

    /// A wing frame from `s` (the root) to `t` (the outer end): feathers stitched across the
    /// middle with linen thread, set in a bar of yellow wax, shortest at the root and longest at
    /// the tip, trailing away from the side the arm's "down" points to.
    static func wing(_ g: inout GraphicsContext, from s: CGPoint, to t: CGPoint, drop: CGFloat, count: Int, dark: Bool, far: Bool) {
        let n: Int = max(3, count)
        let ax: CGFloat = t.x - s.x
        let ay: CGFloat = t.y - s.y
        let square: CGFloat = ax * ax + ay * ay
        let len: CGFloat = max(1, square.squareRoot())
        let ux: CGFloat = ax / len
        let uy: CGFloat = ay / len
        let flip: Bool = -ux < 0
        let nx: CGFloat = flip ? -uy : uy
        let ny: CGFloat = flip ? ux : -ux
        let tones: [UInt32] = dark ? darkFeathers : paleFeathers
        let k: CGFloat = far ? 0.86 : 1
        var stitch: [CGPoint] = []
        for step in 0..<n {
            let i: Int = n - 1 - step
            let u: CGFloat = CGFloat(i) / CGFloat(n - 1)
            let bx: CGFloat = s.x + ax * u
            let by: CGFloat = s.y + ay * u
            let length: CGFloat = drop * (0.42 + 0.78 * u)
            let sweep: CGFloat = 0.15 + 0.4 * u
            let rx: CGFloat = nx + ux * sweep
            let ry: CGFloat = ny + uy * sweep
            let rl: CGFloat = max(0.001, (rx * rx + ry * ry).squareRoot())
            let dx: CGFloat = rx / rl
            let dy: CGFloat = ry / rl
            let tone: UInt32 = Kit.personToneHex(tones[i % tones.count], k)
            featherShape(&g, base: CGPoint(x: bx, y: by), dx: dx, dy: dy, length: length, tone: tone)
            stitch.append(CGPoint(x: bx + dx * length * 0.45, y: by + dy * length * 0.45))
        }
        Art.stroke(&g, Art.polygon(stitch, closed: false), Art.color(linen, 0.85), width: 1, dash: [3, 2])
        Art.stroke(&g, Art.line(s.x, s.y, t.x, t.y), Art.color(Kit.personToneHex(wax, k)), width: 5)
        Art.stroke(&g, Art.line(s.x, s.y - 1.4, t.x, t.y - 1.4), Art.color(0xFFEBB0, 0.7), width: 1.2)
        let straps: [CGFloat] = [0.22, 0.58]
        for u in straps {
            let px: CGFloat = s.x + ax * u
            let py: CGFloat = s.y + ay * u
            Art.stroke(&g, Art.line(px - nx * 4, py - ny * 4, px + nx * 5, py + ny * 5), Art.color(leather), width: 3)
        }
    }

    /// A wing along one arm: from just off the shoulder `s` to a little past the hand
    /// (`hand` is the kit's offset from the shoulder), in adult body units.
    static func armWing(_ g: inout GraphicsContext, shoulder s: CGPoint, hand: CGPoint, dark: Bool, far: Bool) {
        let start = CGPoint(x: s.x + hand.x * 0.1, y: s.y + hand.y * 0.1)
        let end = CGPoint(x: s.x + hand.x * 1.55, y: s.y + hand.y * 1.55)
        let drop: CGFloat = dark ? 52 : 48
        wing(&g, from: start, to: end, drop: drop, count: dark ? 12 : 11, dark: dark, far: far)
    }

    /// A person standing with the wings strapped along both arms; origin at the feet.
    static func winged(_ g: inout GraphicsContext, _ who: Who, rig r: Kit.BodyRig, look gaze: CGPoint = .zero, mouth: Kit.Mouth = .smile, headTilt: CGFloat = 0) {
        let p = look(who)
        let f = Kit.bodyFrame(p)
        let dark: Bool = who == .daedalus
        let nearS = Kit.bodyShoulder(r, near: true)
        let farS = Kit.bodyShoulder(r, near: false)
        Art.group(&g, scale: f.k) { b in
            armWing(&b, shoulder: farS, hand: r.farHand, dark: dark, far: true)
        }
        figure(&g, who, rig: r, look: gaze, mouth: mouth, headTilt: headTilt)
        Art.group(&g, scale: f.k) { b in
            armWing(&b, shoulder: nearS, hand: r.nearHand, dark: dark, far: false)
        }
    }

    /// A person in flight, origin at the middle of the body, flying LEFT and a little up:
    /// the body is turned by `tilt` degrees, the wings rise along the back, the legs trail.
    static func flyer(_ g: inout GraphicsContext, _ who: Who, tilt: CGFloat = -64, look gaze: CGPoint = .zero, mouth: Kit.Mouth = .smile) {
        let p = look(who)
        let f = Kit.bodyFrame(p)
        let r = flightRig()
        let k: CGFloat = f.k
        let a: CGFloat = Kit.deg(tilt)
        let lift: CGFloat = 80 * k
        let dark: Bool = who == .daedalus
        let nearS = Kit.bodyShoulder(r, near: true)
        let farS = Kit.bodyShoulder(r, near: false)
        Art.group(&g, rotate: a) { b in
            Art.group(&b, y: lift, scale: k) { c in
                armWing(&c, shoulder: farS, hand: r.farHand, dark: dark, far: true)
                Kit.bodyFigure(&c, p, r, mirrored: false)
                dress(&c, who, rig: r)
                armWing(&c, shoulder: nearS, hand: r.nearHand, dark: dark, far: false)
            }
        }
        let centre = Kit.bodyHeadCentre(f, r)
        let hc = Kit.bodyTurn(CGPoint(x: centre.x, y: centre.y + lift), a)
        let turn: CGFloat = a * 0.35
        Art.group(&g, x: hc.x, y: hc.y, rotate: turn, scale: f.headScale) { h in
            head(&h, who, look: gaze, mouth: mouth)
        }
    }
}

// MARK: - Birds of the cliffs

extension IcarusArt {
    /// A gull gliding, seen from the side and a little below; centred on (x, y), about 48
    /// across at scale 1.
    static func gull(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, scale s: CGFloat, up: Bool = true) {
        let wingsUp: String = "M-24,-7 C-16,-15 -8,-10 -2,-1 L2,-1 C8,-10 16,-15 24,-7 C16,-9 9,-5 2,3 L-2,3 C-9,-5 -16,-9 -24,-7Z"
        let wingsFlat: String = "M-25,3 C-16,-3 -8,-3 -2,-1 L2,-1 C8,-3 16,-3 25,3 C16,1 8,2 2,3 L-2,3 C-8,2 -16,1 -25,3Z"
        let tipsUp: String = "M-24,-7 C-22,-9 -20,-11 -17,-12 M24,-7 C22,-9 20,-11 17,-12"
        let tipsFlat: String = "M-25,3 L-19,0.5 M25,3 L19,0.5"
        Art.group(&g, x: x, y: y, scale: s) { b in
            Art.fill(&b, Art.svg(up ? wingsUp : wingsFlat), Art.color(0xF4F3EE))
            Art.stroke(&b, Art.svg(up ? tipsUp : tipsFlat), Art.color(0x5A6470), width: 2)
            Kit.solid(&b, Art.ellipse(0, 1, 7.5, 3.2), Art.color(0xFAFAF6), light: 0.2, shade: 0.25)
            Art.fill(&b, Art.circle(-6.5, -0.2, 2.6), Art.color(0xFAFAF6))
            Art.fill(&b, Art.svg("M-8.8,0 L-12,0.9 L-8.8,1.6Z"), Art.color(0xE8B84A))
        }
    }

    /// A few gulls across a stretch of sky, small and pale.
    static func gulls(_ g: inout GraphicsContext, places: [(CGFloat, CGFloat, CGFloat)]) {
        var index: Int = 0
        for place in places {
            gull(&g, x: place.0, y: place.1, scale: place.2, up: index % 2 == 0)
            index += 1
        }
    }
}

// MARK: - Minoan building parts

extension IcarusArt {
    /// A Minoan column: a red wooden shaft WIDER AT THE TOP than at the foot, a fat round
    /// black cushion capital under a square slab, a low stone base. `width` is the shaft's top.
    static func minoanColumn(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, height h: CGFloat, width w: CGFloat) {
        let slabH: CGFloat = h * 0.05
        let capH: CGFloat = h * 0.1
        let baseH: CGFloat = h * 0.035
        let top: CGFloat = baseY - h
        let shaftTop: CGFloat = top + slabH + capH
        let shaftBottom: CGFloat = baseY - baseH
        let footHalf: CGFloat = w * 0.36
        let headHalf: CGFloat = w * 0.5
        Kit.shadow(&g, cx, baseY, width: w * 1.6)
        let corners: [CGPoint] = [
            CGPoint(x: cx - headHalf, y: shaftTop),
            CGPoint(x: cx + headHalf, y: shaftTop),
            CGPoint(x: cx + footHalf, y: shaftBottom),
            CGPoint(x: cx - footHalf, y: shaftBottom)
        ]
        Kit.solid(&g, Art.polygon(corners), Art.color(minoanRed), light: 0.3, shade: 0.32)
        let litCorners: [CGPoint] = [
            CGPoint(x: cx - headHalf * 0.62, y: shaftTop),
            CGPoint(x: cx - headHalf * 0.3, y: shaftTop),
            CGPoint(x: cx - footHalf * 0.3, y: shaftBottom),
            CGPoint(x: cx - footHalf * 0.62, y: shaftBottom)
        ]
        Art.fill(&g, Art.polygon(litCorners), Art.color(0xFFD9A0, 0.18))
        let cushion = Art.rect(cx - w * 0.7, shaftTop - capH, w * 1.4, capH, radius: capH * 0.5)
        Kit.solid(&g, cushion, Art.color(capitalBlack), light: 0.34, shade: 0.2, rim: 1.4)
        let slab = Art.rect(cx - w * 0.8, top, w * 1.6, slabH + 1, radius: 1.5)
        Kit.solid(&g, slab, Art.color(capitalBlack), light: 0.25, shade: 0.2)
        let foot = Art.rect(cx - footHalf * 1.45, shaftBottom, footHalf * 2.9, baseH, radius: 1.5)
        Kit.solid(&g, foot, Art.color(0xDACBAE), light: 0.3, shade: 0.2)
    }

    /// Horns of consecration: a stone shape like a pair of upturned bull's horns, standing
    /// on (cx, baseY), `size` the half-width.
    static func horns(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, size: CGFloat) {
        let data: String = "M-1,0 L1,0 L1,-0.28 C0.96,-0.55 0.9,-0.85 0.74,-1 C0.62,-0.62 0.42,-0.36 0,-0.36 C-0.42,-0.36 -0.62,-0.62 -0.74,-1 C-0.9,-0.85 -0.96,-0.55 -1,-0.28Z"
        let shape = Kit.placed(data, x: cx, y: baseY, scale: size)
        Kit.solid(&g, shape, Art.color(0xF1E8D6), light: 0.3, shade: 0.26)
    }

    /// A leaping blue dolphin of the wall paintings, facing LEFT, about 48 long at scale 1.
    static func dolphin(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, scale s: CGFloat, rotate: CGFloat = 0) {
        Art.group(&g, x: x, y: y, rotate: Kit.deg(rotate), scale: s) { b in
            let body = Art.svg("M-24,0 C-16,-9 4,-10 15,-4 L23,-9 L21,-1 L25,6 L15,2 C4,8 -12,7 -24,0Z")
            Art.fill(&b, body, Art.color(0x2F6A9A))
            Art.fill(&b, Art.svg("M-2,-7 L3,-14 L6,-6Z"), Art.color(0x2F6A9A))
            Art.fill(&b, Art.svg("M-22,1 C-12,5 2,5 14,2 C4,4 -10,4 -22,1Z"), Art.color(0xF2D27A))
            Art.stroke(&b, Art.svg("M-20,-1 C-10,-4 2,-4 12,-2"), Art.color(0x9CC6E0, 0.8), width: 1)
            Art.fill(&b, Art.circle(-17, -2, 1.1), Art.color(0x0F2340))
        }
    }

    /// A painted frieze: a band of pale ground with blue dolphins, a wavy ochre border and a
    /// row of lilies; drawn into `rect`.
    static func fresco(_ g: inout GraphicsContext, rect: CGRect) {
        let x0: CGFloat = rect.minX
        let y0: CGFloat = rect.minY
        let w: CGFloat = rect.width
        let h: CGFloat = rect.height
        let panel = Art.rect(x0, y0, w, h, radius: 2)
        Kit.solid(&g, panel, Art.color(0xF2EAD8), light: 0.14, shade: 0.12)
        Art.fill(&g, Art.rect(x0, y0, w, h * 0.12), Art.color(0xC9783C))
        Art.fill(&g, Art.rect(x0, y0 + h * 0.88, w, h * 0.12), Art.color(0x3E7FB0))
        let s: CGFloat = h / 70
        let count: Int = max(1, Int(w / (60 * s)))
        for i in 0..<count {
            let t: CGFloat = (CGFloat(i) + 0.5) / CGFloat(count)
            let dy: CGFloat = i % 2 == 0 ? -4 * s : 5 * s
            let turn: CGFloat = i % 2 == 0 ? -10 : 8
            dolphin(&g, x: x0 + w * t, y: y0 + h * 0.5 + dy, scale: s * 0.8, rotate: turn)
        }
        var bubbles = Path()
        for i in 0..<count {
            let t: CGFloat = CGFloat(i) / CGFloat(count)
            bubbles.addEllipse(in: CGRect(x: x0 + w * t + 4 * s, y: y0 + h * 0.72, width: 3 * s, height: 3 * s))
        }
        Art.fill(&g, bubbles, Art.color(0xC9783C, 0.7))
    }

    /// A Minoan ship, bow to the LEFT: a long low hull, a raised curving stern, one mast and
    /// a square sail with red stripes.
    static func minoanShip(_ g: inout GraphicsContext, cx: CGFloat, waterY: CGFloat, length L: CGFloat) {
        let deck: CGFloat = waterY - L * 0.06
        let mastTop: CGFloat = waterY - L * 0.6
        Kit.boat(&g, cx: cx, waterY: waterY, length: L, hull: 0x8A5A3A, sail: nil, style: .rowing)
        var stern = Path()
        stern.move(to: CGPoint(x: cx + L * 0.4, y: deck))
        stern.addQuadCurve(to: CGPoint(x: cx + L * 0.47, y: deck - L * 0.2), control: CGPoint(x: cx + L * 0.55, y: deck - L * 0.08))
        Art.stroke(&g, stern, Art.color(0x7A4A2E), width: max(1, L * 0.035))
        Art.stroke(&g, Art.line(cx, deck, cx, mastTop), Art.color(0x6A4A30), width: max(1, L * 0.02))
        let yardY: CGFloat = mastTop + L * 0.04
        let boomY: CGFloat = deck - L * 0.1
        let midY: CGFloat = (yardY + boomY) * 0.5
        let half: CGFloat = L * 0.24
        var sail = Path()
        sail.move(to: CGPoint(x: cx - half, y: yardY))
        sail.addLine(to: CGPoint(x: cx + half, y: yardY))
        sail.addQuadCurve(to: CGPoint(x: cx + half * 0.96, y: boomY), control: CGPoint(x: cx + half * 1.12, y: midY))
        sail.addLine(to: CGPoint(x: cx - half * 0.96, y: boomY))
        sail.addQuadCurve(to: CGPoint(x: cx - half, y: yardY), control: CGPoint(x: cx - half * 0.9, y: midY))
        sail.closeSubpath()
        Kit.solid(&g, sail, Art.color(linen), light: 0.25, shade: 0.2)
        var stripes = Path()
        let offsets: [CGFloat] = [-0.55, 0, 0.55]
        for o in offsets {
            stripes.move(to: CGPoint(x: cx + half * o, y: yardY))
            stripes.addLine(to: CGPoint(x: cx + half * o * 0.98, y: boomY))
        }
        Art.clipped(&g, to: sail) { c in
            Art.stroke(&c, stripes, Art.color(minoanRed, 0.7), width: max(1, L * 0.03))
        }
        Art.stroke(&g, Art.line(cx - half * 1.08, yardY, cx + half * 1.08, yardY), Art.color(0x5A3A24), width: max(1, L * 0.018))
    }

    /// A small rocky Aegean island sitting on the water at baseY, ringed with pale shallows.
    static func island(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat, seed: UInt32, green: Bool = false) {
        var random = ArtRandom(seed)
        let half: CGFloat = width / 2
        let ringH: CGFloat = max(2, height * 0.16)
        Art.fill(&g, Art.ellipse(cx, baseY + 1, half * 1.16, ringH), Art.color(0xD8EEF2, 0.55))
        var shape = Path()
        shape.move(to: CGPoint(x: cx - half, y: baseY))
        let steps: Int = 8
        let peakAt: CGFloat = 0.32 + Kit.rnd(&random) * 0.3
        let reach: CGFloat = max(peakAt, 1 - peakAt)
        for i in 1..<steps {
            let t: CGFloat = CGFloat(i) / CGFloat(steps)
            let dist: CGFloat = abs(t - peakAt) / reach
            let rise: CGFloat = max(0.08, 1 - dist * dist)
            let jag: CGFloat = 0.84 + Kit.rnd(&random) * 0.26
            let y: CGFloat = baseY - height * rise * jag
            shape.addLine(to: CGPoint(x: cx - half + width * t, y: y))
        }
        shape.addLine(to: CGPoint(x: cx + half, y: baseY))
        shape.closeSubpath()
        let topTone: UInt32 = green ? 0x6F9460 : 0x9C8F6A
        let footTone: UInt32 = green ? 0x4F7450 : 0xA27E5E
        Kit.solid(&g, shape, stops: Kit.stops(topTone, footTone), light: 0.3, shade: 0.3, rim: 1.2)
        Art.stroke(&g, Art.line(cx - half * 0.9, baseY - 0.5, cx + half * 0.92, baseY - 0.5), Color.white.opacity(0.6), width: max(0.8, height * 0.05))
    }
}

// MARK: - The workshop's things

extension IcarusArt {
    /// The long timber bench on two splayed trestles; top at `topY`, feet on `floorY`.
    static func bench(_ g: inout GraphicsContext, x0: CGFloat, x1: CGFloat, topY: CGFloat, floorY: CGFloat) {
        let w: CGFloat = x1 - x0
        let midX: CGFloat = (x0 + x1) * 0.5
        Kit.shadow(&g, midX, floorY, width: w * 1.05, alpha: 0.22)
        let legTone: Color = Art.color(Kit.personToneHex(timber, 0.82))
        let legs: [CGFloat] = [x0 + 26, x1 - 32]
        for lx in legs {
            let leg: [CGPoint] = [
                CGPoint(x: lx - 6, y: topY + 10),
                CGPoint(x: lx + 6, y: topY + 10),
                CGPoint(x: lx + 13, y: floorY),
                CGPoint(x: lx + 3, y: floorY),
                CGPoint(x: lx, y: topY + 30),
                CGPoint(x: lx - 3, y: floorY),
                CGPoint(x: lx - 13, y: floorY)
            ]
            Kit.solid(&g, Art.polygon(leg), legTone, light: 0.2, shade: 0.28)
        }
        let barY: CGFloat = topY + (floorY - topY) * 0.62
        Kit.solid(&g, Art.rect(x0 + 26, barY, w - 58, 6, radius: 2), legTone, light: 0.2, shade: 0.2)
        let top = Art.rect(x0, topY, w, 14, radius: 3)
        Kit.solid(&g, top, Art.color(timber), light: 0.3, shade: 0.24, rim: 1.4)
        Art.stroke(&g, Art.line(x0 + 6, topY + 7, x1 - 8, topY + 7.5), Art.color(Kit.personToneHex(timber, 0.8), 0.6), width: 1)
    }

    /// A beeswax pot kept warm in a dish of hot water, standing on baseY.
    static func waxPot(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, scale s: CGFloat) {
        var dish = Path()
        dish.move(to: CGPoint(x: cx - 34 * s, y: baseY - 12 * s))
        dish.addQuadCurve(to: CGPoint(x: cx + 34 * s, y: baseY - 12 * s), control: CGPoint(x: cx, y: baseY + 10 * s))
        dish.closeSubpath()
        Kit.shadow(&g, cx, baseY, width: 64 * s)
        Kit.solid(&g, dish, Art.color(0xA9744E), light: 0.28, shade: 0.26)
        Art.fill(&g, Art.ellipse(cx, baseY - 12 * s, 34 * s, 4 * s), Art.color(0xC9DCE2))
        Kit.pot(&g, cx: cx, baseY: baseY - 9 * s, width: 34 * s, height: 30 * s, color: 0xB5683A, band: 0x6A3A22)
        let lip: CGFloat = baseY - 39 * s
        Art.fill(&g, Art.ellipse(cx, lip + 2 * s, 10 * s, 2.8 * s), Art.color(wax))
        Art.fill(&g, Art.ellipse(cx - 3 * s, lip + 1.4 * s, 4 * s, 1 * s), Art.color(0xFFF0B8, 0.8))
        var steam = Path()
        steam.move(to: CGPoint(x: cx - 22 * s, y: baseY - 16 * s))
        steam.addCurve(to: CGPoint(x: cx - 26 * s, y: baseY - 44 * s), control1: CGPoint(x: cx - 28 * s, y: baseY - 26 * s), control2: CGPoint(x: cx - 18 * s, y: baseY - 34 * s))
        steam.move(to: CGPoint(x: cx + 24 * s, y: baseY - 16 * s))
        steam.addCurve(to: CGPoint(x: cx + 22 * s, y: baseY - 40 * s), control1: CGPoint(x: cx + 30 * s, y: baseY - 26 * s), control2: CGPoint(x: cx + 18 * s, y: baseY - 32 * s))
        Art.stroke(&g, steam, Color.white.opacity(0.45), width: 1.6 * s)
    }

    /// A candle in a clay holder standing on baseY, its flame a small warm point.
    static func candle(_ g: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height h: CGFloat) {
        let top: CGFloat = baseY - h
        Kit.solid(&g, Art.ellipse(x, baseY - 1, 9, 3), Art.color(0xB5683A), light: 0.3, shade: 0.2)
        Kit.solid(&g, Art.rect(x - 3.5, top, 7, h - 1, radius: 2), Art.color(0xF6EBCF), light: 0.3, shade: 0.25)
        Art.glow(&g, x, top - 8, 28, Art.color(0xFFD27A), alpha: 0.4)
        Art.fill(&g, Kit.propFlame(x, top - 1, 5.5, 13, -0.6), Art.color(0xFFBE45))
        Art.fill(&g, Kit.propFlame(x, top - 1, 2.6, 6.5, -0.3), Art.color(0xFFF4C8))
    }

    /// The maker's tools laid on the bench top at `topY`, starting at x: a bronze saw, a
    /// chisel, a wooden mallet, a bow drill; a plumb line hangs from the bench's front edge.
    static func benchTools(_ g: inout GraphicsContext, x: CGFloat, topY: CGFloat) {
        let metal: Color = Art.color(bronze)
        let wood: Color = Art.color(0x7A5234)
        let saw: [CGPoint] = [
            CGPoint(x: x, y: topY), CGPoint(x: x + 62, y: topY), CGPoint(x: x + 60, y: topY - 8), CGPoint(x: x + 6, y: topY - 12)
        ]
        Kit.solid(&g, Art.polygon(saw), metal, light: 0.4, shade: 0.2)
        var teeth = Path()
        var tx: CGFloat = x + 2
        while tx < x + 60 {
            teeth.move(to: CGPoint(x: tx, y: topY))
            teeth.addLine(to: CGPoint(x: tx + 2, y: topY - 2.5))
            tx += 4
        }
        Art.stroke(&g, teeth, Art.color(0x7A5420), width: 0.8)
        Kit.solid(&g, Art.rect(x - 16, topY - 13, 18, 11, radius: 4), wood, light: 0.3, shade: 0.2)
        let chiselX: CGFloat = x + 74
        Art.stroke(&g, Art.line(chiselX, topY - 2, chiselX + 22, topY - 3), metal, width: 3)
        Kit.solid(&g, Art.rect(chiselX + 20, topY - 6.5, 18, 6, radius: 3), wood, light: 0.3, shade: 0.2)
        var bow = Path()
        bow.move(to: CGPoint(x: x + 120, y: topY - 3))
        bow.addQuadCurve(to: CGPoint(x: x + 170, y: topY - 4), control: CGPoint(x: x + 145, y: topY - 22))
        Art.stroke(&g, bow, wood, width: 2.6)
        Art.stroke(&g, Art.line(x + 120, topY - 3, x + 170, topY - 4), Art.color(linen, 0.9), width: 0.8)
        Art.stroke(&g, Art.line(x + 150, topY - 1, x + 152, topY - 26), wood, width: 2.2)
        let plumbX: CGFloat = x + 120
        Art.stroke(&g, Art.line(plumbX, topY + 12, plumbX + 1, topY + 46), Art.color(0x8A7A62), width: 0.9)
        let bob: [CGPoint] = [
            CGPoint(x: plumbX + 1, y: topY + 44), CGPoint(x: plumbX + 5, y: topY + 52),
            CGPoint(x: plumbX + 1, y: topY + 58), CGPoint(x: plumbX - 3, y: topY + 52)
        ]
        Kit.solid(&g, Art.polygon(bob), metal, light: 0.4, shade: 0.2)
    }

    /// A linen sack spilling feathers, standing on baseY.
    static func featherSack(_ g: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, scale s: CGFloat) {
        Kit.shadow(&g, cx, baseY, width: 76 * s)
        let data: String = "M-30,0 C-37,-18 -32,-42 -17,-52 L-11,-57 L11,-57 L17,-52 C32,-42 37,-18 30,0Z"
        let sack = Kit.placed(data, x: cx, y: baseY, scale: s)
        Kit.solid(&g, sack, Art.color(0xCDB892), light: 0.28, shade: 0.28)
        Art.stroke(&g, Kit.placed("M-14,-50 C-6,-46 6,-46 14,-50 M-20,-30 C-14,-24 -10,-12 -12,-2", x: cx, y: baseY, scale: s), Art.color(0xA89472, 0.8), width: 1.4)
        let tips: [(CGFloat, CGFloat, CGFloat)] = [(-8, -54, -24), (0, -56, -4), (8, -54, 18), (4, -55, 8)]
        var index: Int = 0
        for t in tips {
            let tone: UInt32 = index % 2 == 0 ? paleFeathers[index] : darkFeathers[index]
            feather(&g, x: cx + t.0 * s, y: baseY + t.1 * s, length: 26 * s, angle: t.2, tone: tone)
            index += 1
        }
    }
}
