import SwiftUI
import OmramoCore

// The cast and the shared parts of "The Herd Boy and the Weaving Maiden": the palette and the
// two lights (deep dusk in the sky country, starlit night everywhere else), Zhinü, Niulang, the
// Old Ox, the magpies and their bridge, the loom, the cloud-silk, the Silver River, the hut and
// the mulberry trees. A DARK story: every picture is night or deep dusk, and the only warm
// light is the rose-gold of the silk (and the lamp in the hut's doorway).

extension WeaverArt {
    // MARK: Palette and light

    static let ramp = ArtStyle.Ramp(deep: 0x0D1236, shade: 0x1D2A63, mid: 0x4A3F8A, light: 0xC9D3F2, glow: 0xF4B58A, accent: 0xE8748F)

    static let rose: UInt32 = 0xE8748F
    static let gold: UInt32 = 0xF4B58A
    static let silver: UInt32 = 0xC9D3F2
    static let magpieBlack: UInt32 = 0x14162A
    static let magpieWhite: UInt32 = 0xE8ECF8
    static let magpieGloss: UInt32 = 0x3FA7A0
    static let oxCoat: UInt32 = 0xC9953F
    static let oxDark: UInt32 = 0x9A6A1F
    static let oxLight: UInt32 = 0xE3BC6E
    static let oxMuzzle: UInt32 = 0xC4BCB2
    static let oxHorn: UInt32 = 0xE8DDC0
    static let rope: UInt32 = 0xD8C89A

    /// Deep dusk in the sky country: night blue above, dark violet below, a low muted rose band.
    static func dusk() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0x10123A), 0), (Art.color(0x1B1642), 0.4), (Art.color(0x3C2560), 0.82), (Art.color(0x5E3468), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xF4E3D0, glow: 0x9A4F78, haze: 0x3C2560, far: 0x2A1F52, mid: 0x231A48, near: 0x15123A, isNight: true)
    }

    /// Starlit night over the meadow and over the Silver River.
    static func night() -> Kit.Light {
        let sky: Kit.Stops = [
            (Art.color(0x0A0E2C), 0), (Art.color(0x0D1236), 0.4), (Art.color(0x18225A), 0.84), (Art.color(0x2A3A78), 1),
        ]
        return Kit.Light(sky: sky, sun: 0xF2ECD8, glow: 0x3F5596, haze: 0x1D2A63, far: 0x141C46, mid: 0x0E1535, near: 0x0A0F28, isNight: true)
    }

    /// Mulberry leaves by starlight.
    static func nightGreens() -> Kit.Greens {
        Kit.greens(0x0C1F2E, 0x143A3A, 0x1F5248, 0x3A7A62, 0x8FC7A8)
    }

    // MARK: People

    static func zhinuLook() -> Kit.Person {
        Kit.Person(
            age: .adult,
            skin: 0xF2CFA8,
            hair: 0x1C1622,
            hairStyle: .bun,
            garment: .robe,
            cloth: 0xF2BCC6,
            trim: 0xC2456E,
            legs: 0xE8A6B2,
            showsEyeWhite: false
        )
    }

    static func niulangLook() -> Kit.Person {
        Kit.Person(
            age: .adult,
            skin: 0xD9A06E,
            hair: 0x1C1622,
            hairStyle: .topknot,
            garment: .tunic,
            cloth: 0x4E78A8,
            trim: 0xD8CDB0,
            legs: 0xCFC2A0,
            showsEyeWhite: false
        )
    }

    /// The one plain pin through Zhinü's high knot, in head units (origin at the head's centre).
    static func zhinuPin(_ context: inout GraphicsContext) {
        Art.stroke(&context, Art.line(-4, -41, 24, -32), Art.color(0x8E96C0), width: 2.6)
        Art.stroke(&context, Art.line(-4, -41.6, 24, -32.6), Art.color(silver), width: 1.2)
        Art.fill(&context, Art.circle(-5, -41.4, 2.4), Art.color(silver))
        Art.fill(&context, Art.circle(-5.6, -42, 0.9), Color.white)
    }

    /// Zhinü, whole figure: origin at her feet, facing LEFT, 168 tall. Her rose-gold scarf
    /// trails behind her from the shoulders (to the right; to the left when mirrored).
    static func zhinu(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false,
        scarf: Bool = true
    ) {
        let spec = zhinuLook()
        let rig = Kit.bodyRig(spec, pose)
        let neck: CGPoint = Kit.bodyNeck(rig)
        if scarf {
            let data: String = "M-18,8 C-4,16 10,12 20,4 C40,-12 56,8 80,0 C96,-5 106,-20 122,-16"
            let ribbon: Path = Kit.placed(data, x: neck.x, y: neck.y)
            silkRibbon(&context, ribbon, width: 7, glow: 0.6)
        }
        Kit.person(&context, spec, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        let centre: CGPoint = Kit.bodyHeadCentre(Kit.bodyFrame(spec), rig)
        Art.group(&context, x: centre.x, y: centre.y) { h in
            zhinuPin(&h)
        }
    }

    /// Niulang, whole figure: origin at his feet, facing LEFT, 168 tall; trousers rolled at
    /// the shin.
    static func niulang(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        mirrored: Bool = false
    ) {
        let spec = niulangLook()
        Kit.person(&context, spec, pose: pose, look: look, mouth: mouth, mirrored: mirrored)
        if pose == .stand || pose == .carry || pose == .reach || pose == .wave {
            // The rolled cuffs of his undyed trousers.
            let cuff: Color = Kit.personTone(spec.legs, 1.12)
            Art.stroke(&context, Art.line(-14, -17, -3, -17), cuff, width: 4)
            Art.stroke(&context, Art.line(3, -17, 14, -17), Kit.personTone(spec.legs, 0.92), width: 4)
        }
    }

    // MARK: Silk

    /// A band of cloud-silk along `path`: rose with a gold edge, glowing softly.
    static func silkRibbon(_ context: inout GraphicsContext, _ path: Path, width: CGFloat, glow: Double = 0.5) {
        if glow > 0 {
            Art.stroke(&context, path, Art.color(rose, 0.14 * glow), width: width * 3.4)
            Art.stroke(&context, path, Art.color(gold, 0.16 * glow), width: width * 1.9)
        }
        Art.stroke(&context, path, Art.color(rose), width: width)
        let lift = CGAffineTransform(translationX: 0, y: -width * 0.26)
        let upper: Path = path.applying(lift)
        Art.stroke(&context, upper, Art.color(gold), width: width * 0.4)
        Art.stroke(&context, upper, Art.color(0xFFE6C8, 0.7), width: max(0.8, width * 0.12))
    }

    /// A loosely twisted skein of rose silk, about 180 wide and 70 tall, centred on the origin.
    static func skein(_ context: inout GraphicsContext) {
        let hank: Path = Art.svg("M-90,0 C-90,-44 -30,-38 0,-9 C30,-38 90,-44 90,0 C90,44 30,38 0,9 C-30,38 -90,44 -90,0Z")
        Art.glow(&context, 0, 0, 120, Art.color(rose), alpha: 0.22)
        Kit.solid(&context, hank, Art.color(rose), light: 0.34, shade: 0.26)
        let strands: Path = Art.svg("M-82,-8 C-70,-30 -30,-28 -4,-4 M-84,4 C-66,-16 -32,-14 -6,4 M-80,16 C-60,2 -34,2 -8,12 M-70,26 C-52,18 -32,20 -12,22 M82,-8 C70,-30 30,-28 4,-4 M84,4 C66,-16 32,-14 6,4 M80,16 C60,2 34,2 8,12 M70,26 C52,18 32,20 12,22")
        Art.clipped(&context, to: hank) { g in
            Art.stroke(&g, strands, Art.color(0xB8486A, 0.75), width: 1.6)
            let sheen: Path = Art.svg("M-78,-18 C-60,-34 -34,-30 -14,-16 M14,-16 C34,-30 60,-34 78,-18")
            Art.stroke(&g, sheen, Art.color(0xFFE6C8, 0.75), width: 2.4)
        }
        // The tie round the twist.
        let tie: Path = Art.rect(-8, -13, 16, 26, radius: 6)
        Kit.solid(&context, tie, Art.color(gold), light: 0.3, shade: 0.24)
        Art.stroke(&context, Art.svg("M-7,-4 L7,-6 M-7,4 L7,2"), Art.color(0xC98A5A), width: 1.4)
    }

    // MARK: Sky things

    /// A bright four-rayed star with a soft halo.
    static func brightStar(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ r: CGFloat, color: UInt32 = 0xFFF6E4) {
        Art.glow(&context, x, y, r * 3.2, Art.color(color), alpha: 0.4)
        Art.fill(&context, Art.spark(x, y, r), Art.color(color))
        Art.fill(&context, Art.circle(x, y, r * 0.3), Color.white)
    }

    /// The Silver River: a broad uneven band of small stars from `p0` to `p1`, `width0` wide at
    /// the start and `width1` at the end, with a pale mist under it (alpha `mist0` → `mist1`),
    /// brighter knots and a darker lane. The stars thin toward `p1`.
    static func silverRiver(
        _ context: inout GraphicsContext,
        from p0: CGPoint,
        to p1: CGPoint,
        width0: CGFloat,
        width1: CGFloat,
        count: Int,
        seed: UInt32,
        mist0: Double,
        mist1: Double
    ) {
        let dx: CGFloat = p1.x - p0.x
        let dy: CGFloat = p1.y - p0.y
        let square: CGFloat = dx * dx + dy * dy
        let length: CGFloat = max(1, square.squareRoot())
        let nx: CGFloat = -dy / length
        let ny: CGFloat = dx / length
        let pale: Color = Art.color(silver)
        let steps: Int = 14
        for i in 0...steps {
            let t: CGFloat = CGFloat(i) / CGFloat(steps)
            let cx: CGFloat = p0.x + dx * t
            let cy: CGFloat = p0.y + dy * t
            let w: CGFloat = Kit.mix(width0, width1, t)
            let a: Double = mist0 + (mist1 - mist0) * Double(t)
            Art.glow(&context, cx, cy, w * 0.62, pale, alpha: a)
            if i % 4 == 1 {
                Art.glow(&context, cx + nx * w * 0.12, cy + ny * w * 0.12, w * 0.26, Color.white, alpha: a * 1.1)
            }
        }
        var random = ArtRandom(seed)
        var dim = Path()
        var bright = Path()
        for index in 0..<max(0, count) {
            let raw: CGFloat = Kit.rnd(&random)
            let t: CGFloat = raw * (0.5 + 0.5 * raw)
            let sum: CGFloat = Kit.rnd(&random) + Kit.rnd(&random) + Kit.rnd(&random)
            let across: CGFloat = sum / 3 - 0.5
            let roll: CGFloat = Kit.rnd(&random)
            let r: CGFloat = 0.5 + Kit.rnd(&random) * 0.9
            let lane: CGFloat = abs(across - 0.05)
            if lane < 0.03 && roll < 0.75 { continue }
            let w: CGFloat = Kit.mix(width0, width1, t)
            let off: CGFloat = across * w * 1.6
            let x: CGFloat = p0.x + dx * t + nx * off
            let y: CGFloat = p0.y + dy * t + ny * off
            let dot = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
            if index % 5 == 0 {
                bright.addEllipse(in: dot)
            } else {
                dim.addEllipse(in: dot)
            }
        }
        Art.fill(&context, dim, Art.color(0xDDE4FA, 0.55))
        Art.fill(&context, bright, Art.color(0xFFFFFF, 0.95))
    }

    /// A bank of dark cloud with a scroll edge: puffs along a line `width` wide whose tops are
    /// about `height` above `y`, filled down to `bottom`; the lit edge is upper-left.
    static func cloudBank(
        _ context: inout GraphicsContext,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        color: UInt32,
        edge: UInt32,
        seed: UInt32,
        bottom: CGFloat
    ) {
        guard width > 0, height > 0 else { return }
        var random = ArtRandom(seed)
        let count: Int = max(3, Int(width / (height * 1.2)))
        let step: CGFloat = width / CGFloat(count)
        var shape = Path()
        var curls = Path()
        for i in 0..<count {
            let t: CGFloat = (CGFloat(i) + 0.5) / CGFloat(count)
            let middle: CGFloat = 1 - abs(t - 0.5) * 1.1
            let ry: CGFloat = height * (0.55 + Kit.rnd(&random) * 0.3) * middle
            let rx: CGFloat = step * (0.72 + Kit.rnd(&random) * 0.2)
            let cx: CGFloat = x - width / 2 + step * (CGFloat(i) + 0.5)
            shape.addEllipse(in: CGRect(x: cx - rx, y: y - ry, width: rx * 2, height: ry * 2))
            if i % 2 == 0 {
                let s: CGFloat = ry * 0.05
                let curl: Path = Kit.placed("M-9,-2 C-8,-12 8,-13 9,-3 C9.6,3 2,5 0.5,0 C0,-3 3,-5 5,-3", x: cx - rx * 0.2, y: y - ry * 0.3, scale: max(0.5, s))
                curls.addPath(curl)
            }
        }
        let base: CGFloat = max(1, bottom - y)
        shape.addPath(Art.rect(x - width / 2, y - 2, width, base + 2, radius: min(18, base / 2)))
        let fade: Kit.Stops = [(Art.color(color), 0), (Kit.personTone(color, 0.7), 1)]
        Art.fillLinear(&context, shape, fade, from: CGPoint(x: x, y: y - height), to: CGPoint(x: x, y: bottom))
        let bounds = CGRect(x: x - width / 2 - step, y: y - height, width: width + step * 2, height: height + base)
        ArtStyle.rimEdge(&context, shape, bounds: bounds, width: 2.4, alpha: 0.3)
        Art.stroke(&context, curls, Art.color(edge, 0.5), width: ArtStyle.detailLine)
    }
}

// MARK: - The Old Ox

extension WeaverArt {
    /// The Old Ox from the side: a Chinese yellow ox with a small shoulder hump, short curved
    /// horns, a soft dewlap, a grey muzzle and a rope halter. Origin on the ground under the
    /// middle of his body; about 170 long and 112 tall; faces LEFT (head centre near (−86, −86)).
    static func ox(_ context: inout GraphicsContext, mirrored: Bool = false) {
        let coat: Color = Art.color(oxCoat)
        let dark: Color = Art.color(oxDark)
        let farTone: Color = Art.color(0x8A5F22)
        let hoof: Color = Art.color(0x4A3A2E)
        // Far legs and the tail.
        Kit.limb(&context, "M-28,-44 L-30,-22 L-28,-5", 12, farTone)
        Kit.limb(&context, "M66,-50 L72,-26 L66,-5", 12, farTone)
        Art.fill(&context, Art.rect(-35, -8, 13, 7, radius: 3), hoof)
        Art.fill(&context, Art.rect(60, -8, 13, 7, radius: 3), hoof)
        Kit.limb(&context, "M76,-80 C88,-70 87,-46 83,-32", 4, dark)
        Art.fill(&context, Art.ellipse(83, -27, 4, 7.5), Art.color(0x5A3A1A))
        // The body: chest, hump, a level back, a bony hip.
        let body: Path = Art.svg("M-62,-70 C-66,-92 -48,-104 -30,-100 C-22,-110 -6,-108 2,-96 C24,-92 44,-96 58,-92 C66,-96 76,-88 76,-78 C82,-64 80,-50 72,-42 C56,-32 20,-34 -10,-36 C-36,-32 -58,-44 -62,-70Z")
        let bounds = CGRect(x: -66, y: -110, width: 148, height: 78)
        Kit.personLit(&context, body, coat, bounds: bounds, mirrored: mirrored, light: 0.3, shade: 0.3)
        Art.clipped(&context, to: body) { g in
            Art.fill(&g, Art.ellipse(4, -38, 52, 10), Art.color(oxLight, 0.35))
            let ribs: Path = Art.svg("M8,-84 C12,-70 12,-58 8,-46 M22,-84 C26,-70 26,-58 22,-46 M36,-82 C39,-70 39,-60 36,-48")
            Art.stroke(&g, ribs, dark.opacity(0.3), width: ArtStyle.detailLine)
            Art.stroke(&g, Art.svg("M56,-88 C63,-83 65,-74 62,-66"), dark.opacity(0.5), width: ArtStyle.detailLine)
        }
        // Near legs.
        Kit.limb(&context, "M-44,-46 L-46,-22 L-44,-5", 13, coat)
        Kit.limb(&context, "M54,-50 L60,-26 L54,-5", 13, coat)
        Art.stroke(&context, Art.svg("M-49,-40 L-50,-12 M49,-44 L54,-24"), Art.color(oxLight, 0.5), width: 2)
        Art.fill(&context, Art.rect(-51, -8, 14, 8, radius: 3), hoof)
        Art.fill(&context, Art.rect(47, -8, 14, 8, radius: 3), hoof)
        // The dewlap under the neck.
        let dewlap: Path = Art.svg("M-58,-78 C-68,-62 -60,-44 -46,-40 C-51,-52 -50,-66 -50,-78Z")
        Art.fill(&context, dewlap, Art.color(oxLight))
        Art.stroke(&context, Art.svg("M-60,-66 C-58,-56 -54,-48 -48,-43"), dark.opacity(0.4), width: ArtStyle.detailLine)
        // The neck, then the head.
        let neck: Path = Art.svg("M-44,-102 C-58,-108 -74,-104 -84,-96 L-80,-66 C-70,-62 -58,-64 -50,-70Z")
        Art.fill(&context, neck, coat)
        Art.group(&context, x: -86, y: -86) { h in
            oxHead(&h, mirrored: mirrored)
        }
    }

    /// The ox's head from the side, facing LEFT; origin at its centre, about 56 across.
    static func oxHead(_ context: inout GraphicsContext, mirrored: Bool) {
        let coat: Color = Art.color(oxCoat)
        let dark: Color = Art.color(oxDark)
        // Far horn and the ear, behind the skull.
        Art.fill(&context, Art.svg("M12,-19 C16,-30 24,-35 31,-33 C25,-28 21,-24 20,-17Z"), Art.color(0xB8AC8C))
        let ear: Path = Art.svg("M14,-11 C24,-20 37,-16 39,-7 C30,-3 20,-3 14,-7Z")
        Art.fill(&context, ear, dark)
        Art.fill(&context, Art.svg("M19,-10 C25,-15 32,-13 34,-8 C28,-6 22,-6 19,-8Z"), Art.color(0xD9A08A, 0.7))
        let skull: Path = Art.svg("M-26,2 C-28,-10 -16,-22 2,-22 C16,-22 24,-12 24,0 C24,12 14,20 2,18 C-6,24 -20,24 -27,16 C-31,10 -30,4 -26,2Z")
        let bounds = CGRect(x: -31, y: -22, width: 55, height: 46)
        Kit.personLit(&context, skull, coat, bounds: bounds, mirrored: mirrored, light: 0.3, shade: 0.26)
        Art.clipped(&context, to: skull) { g in
            Art.fill(&g, Art.ellipse(-22, 13, 12, 10), Art.color(oxMuzzle))
        }
        Art.fill(&context, Art.ellipse(-26.5, 11, 1.8, 1.3), Art.color(0x5A4A4A))
        ArtStyle.smile(&context, -18, 18.5, width: 11, curve: 1.6, color: Art.color(0x6A5648))
        // The near horn: short and curved forward.
        let horn: Path = Art.svg("M3,-20 C1,-32 -8,-39 -17,-37 C-11,-32 -7,-26 -5,-19Z")
        Kit.solid(&context, horn, Art.color(oxHorn), light: 0.3, shade: 0.24)
        // A kind, half-closed eye.
        ArtStyle.cheek(&context, -8, 8, 6, alpha: 0.28)
        ArtStyle.eye(&context, -5, -4, 3.3, look: CGPoint(x: -0.4, y: 0.2), showsWhite: false)
        Art.fill(&context, Art.svg("M-10,-6 C-7,-10 -3,-10 0,-6 C-3,-7.4 -7,-7.4 -10,-6Z"), coat)
        Art.stroke(&context, Art.svg("M-10.5,-5.6 C-7,-9 -3,-9 0.5,-5.6"), dark, width: 1.8)
        // The rope halter.
        let halter: Path = Art.svg("M-15,22 C-12,12 -13,2 -17,-4 M-15,6 C-4,10 10,6 20,-4")
        Art.stroke(&context, halter, Art.color(0x9A8A5A), width: 3.2)
        Art.stroke(&context, halter, Art.color(rope), width: 1.8)
    }

    /// The ox's face from the front, for the chip and the portrait: origin at the head's
    /// centre, 60 across (ears to ±54, horns to y −52, the muzzle down to y 40).
    static func oxFace(_ context: inout GraphicsContext) {
        let coat: Color = Art.color(oxCoat)
        let dark: Color = Art.color(oxDark)
        let ears: Path = Art.svg("M-24,-10 C-40,-18 -52,-10 -54,0 C-44,5 -32,3 -24,-2Z M24,-10 C40,-18 52,-10 54,0 C44,5 32,3 24,-2Z")
        Art.fill(&context, ears, dark)
        let inner: Path = Art.svg("M-30,-8 C-40,-12 -47,-7 -49,-1 C-42,1 -35,0 -30,-3Z M30,-8 C40,-12 47,-7 49,-1 C42,1 35,0 30,-3Z")
        Art.fill(&context, inner, Art.color(0xD9A08A, 0.7))
        let hornL: Path = Art.svg("M-18,-24 C-28,-30 -35,-42 -30,-52 C-25,-44 -17,-37 -8,-31Z")
        let hornR: Path = Art.svg("M18,-24 C28,-30 35,-42 30,-52 C25,-44 17,-37 8,-31Z")
        Kit.solid(&context, hornL, Art.color(oxHorn), light: 0.3, shade: 0.2)
        Kit.solid(&context, hornR, Art.color(0xCFC4A4), light: 0.1, shade: 0.3)
        let skull: Path = Art.svg("M0,-32 C18,-32 28,-20 26,-4 C25,10 20,22 16,30 C12,40 -12,40 -16,30 C-20,22 -25,10 -26,-4 C-28,-20 -18,-32 0,-32Z")
        Kit.solid(&context, skull, coat, light: 0.3, shade: 0.24)
        // The forelock.
        let forelock: Path = Art.svg("M-12,-30 C-8,-38 8,-38 12,-30 C8,-24 4,-27 0,-22 C-4,-27 -8,-24 -12,-30Z")
        Art.fill(&context, forelock, dark)
        // The grey muzzle of an old ox.
        let muzzle: Path = Art.svg("M-16,19 C-16,8 16,8 16,19 C18,34 10,40 0,40 C-10,40 -18,34 -16,19Z")
        Kit.solid(&context, muzzle, Art.color(oxMuzzle), light: 0.24, shade: 0.2)
        var nostrils = Path()
        nostrils.addPath(Art.ellipse(-7, 26, 3, 2.2))
        nostrils.addPath(Art.ellipse(7, 26, 3, 2.2))
        Art.fill(&context, nostrils, Art.color(0x5A4A4A))
        ArtStyle.smile(&context, 0, 32.5, width: 13, curve: 2, color: Art.color(0x6A5648))
        // Kind, half-closed eyes.
        ArtStyle.cheek(&context, -17, 8, 7, alpha: 0.28)
        ArtStyle.cheek(&context, 17, 8, 7, alpha: 0.28)
        ArtStyle.eye(&context, -13, -4, 3.8, showsWhite: false)
        ArtStyle.eye(&context, 13, -4, 3.8, showsWhite: false)
        let lids: Path = Art.svg("M-19,-6 C-16,-11 -10,-11 -7,-6 C-10,-7.6 -16,-7.6 -19,-6Z M7,-6 C10,-11 16,-11 19,-6 C16,-7.6 10,-7.6 7,-6Z")
        Art.fill(&context, lids, coat)
        Art.stroke(&context, Art.svg("M-19.5,-5.6 C-16,-9.4 -10,-9.4 -6.5,-5.6 M6.5,-5.6 C10,-9.4 16,-9.4 19.5,-5.6"), dark, width: 2)
        // The rope halter across the nose.
        let halter: Path = Art.svg("M-18,14 C-8,10 8,10 18,14 M-18,14 L-25,-2 M18,14 L25,-2")
        Art.stroke(&context, halter, Art.color(0x9A8A5A), width: 4)
        Art.stroke(&context, halter, Art.color(rope), width: 2.2)
    }

    /// The ox's neck and shoulders under `oxFace`, for the portrait (down to y +150).
    static func oxNeck(_ context: inout GraphicsContext) {
        let neck: Path = Art.svg("M-30,16 C-42,58 -60,104 -72,150 L72,150 C60,104 42,58 30,16Z")
        Kit.solid(&context, neck, Art.color(oxCoat), light: 0.26, shade: 0.28)
        let dewlap: Path = Art.svg("M-10,40 C-14,76 -8,116 0,150 C8,116 14,76 10,40Z")
        Art.fill(&context, dewlap, Art.color(oxLight, 0.55))
        Art.stroke(&context, Art.svg("M-12,48 C-14,82 -8,118 -2,148"), Art.color(oxDark, 0.5), width: ArtStyle.contourLine)
    }
}

// MARK: - Magpies and their bridge

extension WeaverArt {
    /// One magpie on the wing, from the side, facing LEFT: black head, breast and back, white
    /// belly and shoulder patch, a long wedge tail, a blue-green gloss. Origin at the middle of
    /// the body; about 90 long with the tail, the wings reaching up to y −46.
    static func magpie(_ context: inout GraphicsContext) {
        let black: Color = Art.color(magpieBlack)
        let white: Color = Art.color(magpieWhite)
        let gloss: Color = Art.color(magpieGloss)
        // The long wedge tail.
        let tail: Path = Art.svg("M10,-3 L54,-8 C57,-5 57,0 54,3 L12,6Z")
        Art.fill(&context, tail, black)
        Art.stroke(&context, Art.svg("M16,-2 L50,-5"), gloss.opacity(0.8), width: 1.6)
        // The far wing, raised behind, white toward its tip.
        let farWing: Path = Art.svg("M2,-4 C8,-30 26,-40 42,-38 C36,-26 25,-10 12,-2Z")
        Art.fill(&context, farWing, Art.color(0x1E2240))
        Art.fill(&context, Art.svg("M23,-30 C29,-36 35,-38 42,-38 C38,-31 32,-25 26,-22Z"), white.opacity(0.85))
        // Body, white belly, white shoulder.
        let body: Path = Art.ellipse(0, 0, 17, 10)
        Art.fill(&context, body, black)
        Art.clipped(&context, to: body) { g in
            Art.fill(&g, Art.ellipse(3, 8, 14, 6.5), white)
        }
        Art.fill(&context, Art.ellipse(7, -4, 8, 3.4), white)
        // Head, beak and eye.
        Art.fill(&context, Art.circle(-15, -4, 8), black)
        Art.fill(&context, Art.svg("M-22,-6.5 L-33,-3 L-22,-0.5Z"), Art.color(0x2E3048))
        Art.fill(&context, Art.circle(-17.5, -6, 2.3), Art.color(silver, 0.9))
        Art.fill(&context, Art.circle(-17.6, -6, 1.4), Art.color(0x0A0A14))
        Art.fill(&context, Art.circle(-18.1, -6.6, 0.55), Color.white)
        Art.stroke(&context, Art.svg("M-20,-10 C-16,-13 -11,-12 -8,-9"), gloss.opacity(0.7), width: 1.3)
        // The near wing, lifted, with its white patch and its gloss on the lit edge.
        let nearWing: Path = Art.svg("M-7,-2 C-13,-22 -9,-38 2,-46 C10,-34 12,-16 8,-2Z")
        Art.fill(&context, nearWing, black)
        Art.fill(&context, Art.svg("M-3,-30 C-2,-36 0,-41 2,-46 C6,-40 8,-34 8,-28Z"), white.opacity(0.9))
        Art.stroke(&context, Art.svg("M-8,-6 C-12,-20 -9,-32 -3,-40"), gloss, width: 1.8)
        Art.stroke(&context, Art.svg("M-1,-6 C-2,-14 -1,-22 1,-27 M4,-5 C4,-12 5,-20 6,-25"), Art.color(0x2A3050), width: 1)
    }

    /// One bird of the bridge as a tile: two spread wings with white shoulders, a small body
    /// and head between them. About 50 wide and 16 tall, centred on the origin.
    static func magpieTile(_ context: inout GraphicsContext) {
        let black: Color = Art.color(magpieBlack)
        let white: Color = Art.color(magpieWhite)
        let wings: Path = Art.svg("M-2,0 C-8,-10 -20,-9 -25,-2 C-17,3 -8,5 -2,3Z M2,0 C8,-10 20,-9 25,-2 C17,3 8,5 2,3Z")
        Art.fill(&context, wings, black)
        var patches = Path()
        patches.addPath(Art.ellipse(-13, -3, 5.4, 2.3))
        patches.addPath(Art.ellipse(13, -3, 5.4, 2.3))
        Art.fill(&context, patches, white)
        Art.stroke(&context, Art.svg("M-23,-3 C-17,-8.6 -9,-8.4 -4,-3"), Art.color(magpieGloss, 0.8), width: 1.2)
        Art.fill(&context, Art.ellipse(0, 1.5, 5.4, 5), black)
        Art.fill(&context, Art.ellipse(0, 4, 3.4, 2.4), white)
        Art.fill(&context, Art.circle(0, -4.6, 3.3), black)
    }

    /// A point on the arch: `t` 0 at `x0`, 1 at `x1`; the crown is `rise` above `baseY`.
    static func archPoint(_ t: CGFloat, x0: CGFloat, x1: CGFloat, baseY: CGFloat, rise: CGFloat) -> CGPoint {
        let x: CGFloat = x0 + (x1 - x0) * t
        let bow: CGFloat = 4 * t * (1 - t)
        return CGPoint(x: x, y: baseY - rise * bow)
    }

    /// The bridge of magpies: one clear arch from (`x0`, `baseY`) to (`x1`, `baseY`) whose
    /// walking line is `rise` above the base, built of three rows of birds overlapping wing to
    /// wing like roof tiles, `thick` units deep. A faint silver light lies along its top.
    static func magpieArch(
        _ context: inout GraphicsContext,
        x0: CGFloat,
        x1: CGFloat,
        baseY: CGFloat,
        rise: CGFloat,
        thick: CGFloat
    ) {
        let span: CGFloat = x1 - x0
        guard span > 0, thick > 0 else { return }
        let count: Int = max(8, Int(span / (thick * 0.62)))
        let k: CGFloat = thick / 24
        // A soft dark body under the tiles, so no sky shows between the birds.
        var spine = Path()
        for i in 0...count {
            let t: CGFloat = CGFloat(i) / CGFloat(count)
            let p: CGPoint = archPoint(t, x0: x0, x1: x1, baseY: baseY + thick * 0.5, rise: rise)
            if i == 0 {
                spine.move(to: p)
            } else {
                spine.addLine(to: p)
            }
        }
        Art.stroke(&context, spine, Art.color(magpieBlack), width: thick * 0.8)
        for row in 0..<3 {
            let level: Int = 2 - row
            let drop: CGFloat = (CGFloat(level) - 0.2) * thick * 0.36
            let shift: CGFloat = level == 1 ? 0.5 : 0
            for i in 0...count {
                let t: CGFloat = (CGFloat(i) + shift) / CGFloat(count)
                if t > 1 { continue }
                let p: CGPoint = archPoint(t, x0: x0, x1: x1, baseY: baseY, rise: rise)
                let slope: CGFloat = -rise * 4 * (1 - 2 * t)
                let angle: CGFloat = atan2(slope, span)
                Art.group(&context, x: p.x, y: p.y + drop, rotate: angle, scale: k) { m in
                    magpieTile(&m)
                }
            }
        }
        // Starlight on the walking line.
        var top = Path()
        for i in 0...count {
            let t: CGFloat = CGFloat(i) / CGFloat(count)
            let p: CGPoint = archPoint(t, x0: x0, x1: x1, baseY: baseY - thick * 0.34, rise: rise)
            if i == 0 {
                top.move(to: p)
            } else {
                top.addLine(to: p)
            }
        }
        Art.stroke(&context, top.trimmedPath(from: 0.04, to: 0.6), Art.color(silver, 0.35), width: 1.4)
    }
}

// MARK: - The loom, the hut, the mulberry trees

extension WeaverArt {
    /// Zhinü's loom: a tall wooden frame loom seen a little from the side, with a slanted warp
    /// of many fine threads, a heddle bar hung from the top arms, and the cloth beam by the
    /// weaver. Origin on the ground at the weaver's side (the near front post is at x −12);
    /// the loom reaches left to x −156 and up to y −272. The cloth beam runs from (−12, −70)
    /// to (32, −90).
    static func loom(_ context: inout GraphicsContext) {
        let wood: UInt32 = 0x7A5440
        let far: UInt32 = 0x4E3838
        // The far side of the frame.
        Kit.propShaft(&context, -106, -20, -106, -270, wood: far, width: 8)
        Kit.propShaft(&context, 32, -20, 32, -98, wood: far, width: 7)
        Kit.propShaft(&context, -110, -24, 36, -24, wood: far, width: 6)
        Kit.propShaft(&context, -106, -260, -46, -256, wood: far, width: 5)
        Art.stroke(&context, Art.line(-48, -256, -48, -191), Art.color(rope, 0.6), width: 1)
        // The warp: fine threads from the top beam down to the cloth beam.
        var threads = Path()
        for i in 0...13 {
            let s: CGFloat = CGFloat(i) / 13
            let topX: CGFloat = -150 + 44 * s
            let topY: CGFloat = -244 - 20 * s
            threads.move(to: CGPoint(x: topX, y: topY))
            threads.addLine(to: CGPoint(x: topX + 138, y: topY + 174))
        }
        Art.stroke(&context, threads, Art.color(silver, 0.6), width: 0.9)
        // The woven cloth, nearest the cloth beam: rose shading to gold.
        let cloth: Path = Art.polygon([Kit.pt(-50.6, -118.7), Kit.pt(-6.6, -138.7), Kit.pt(32, -90), Kit.pt(-12, -70)])
        Art.glow(&context, -10, -104, 62, Art.color(rose), alpha: 0.3)
        let weave: Kit.Stops = [(Art.color(gold), 0), (Art.color(rose), 0.55), (Art.color(0xC2456E), 1)]
        Art.fillLinear(&context, cloth, weave, from: CGPoint(x: -30, y: -130), to: CGPoint(x: 10, y: -80))
        Art.stroke(&context, Art.line(-50.6, -118.7, -6.6, -138.7), Art.color(0xFFE6C8, 0.8), width: 1.4)
        // The heddle bar across the warp, hung from the arms.
        Kit.propShaft(&context, -92, -171, -48, -191, wood: wood, width: 5)
        Art.stroke(&context, Art.line(-92, -236, -92, -171), Art.color(rope, 0.8), width: 1)
        // The near side of the frame.
        Kit.propShaft(&context, -150, 0, -150, -250, wood: wood, width: 9)
        Kit.propShaft(&context, -12, 0, -12, -78, wood: wood, width: 8)
        Kit.propShaft(&context, -156, -6, -6, -6, wood: wood, width: 7)
        Kit.propShaft(&context, -150, -124, -12, -74, wood: wood, width: 5)
        Kit.propShaft(&context, -150, -240, -90, -236, wood: wood, width: 5)
        // The two beams: the warp beam on top, the cloth beam with its roll of finished silk.
        Kit.propShaft(&context, -150, -246, -106, -266, wood: wood, width: 11)
        Art.stroke(&context, Art.line(-12, -70, 32, -90), Art.color(0xC2456E), width: 13)
        Art.stroke(&context, Art.line(-13, -73, 31, -93), Art.color(gold, 0.8), width: 3)
        Art.fill(&context, Art.circle(-12, -70, 5), Art.color(wood))
    }

    /// A hand shuttle, about 26 long, centred on the origin, wound with rose thread.
    static func shuttle(_ context: inout GraphicsContext) {
        let boat: Path = Art.svg("M-13,0 C-8,-5 8,-5 13,0 C8,5 -8,5 -13,0Z")
        Kit.solid(&context, boat, Art.color(0x9A7048), light: 0.3, shade: 0.24)
        Art.fill(&context, Art.ellipse(0, 0, 5.5, 2.2), Art.color(rose))
    }

    /// Niulang's hut: earth walls, a thick straw thatch, a low doorway with a faint lamp glow.
    /// Origin on the ground under the middle of the wall; the wall is 116 wide and 58 tall, the
    /// thatch overhangs to ±78 and rises to y −124.
    static func hut(_ context: inout GraphicsContext) {
        let wall: Path = Art.svg("M-58,0 L-56,-58 L56,-58 L58,0Z")
        Kit.solid(&context, wall, Art.color(0x5E4A40), light: 0.2, shade: 0.3)
        Art.fill(&context, Art.rect(-57, -58, 114, 10), ArtStyle.coolShade.opacity(0.35))
        // The doorway and its lamp.
        let door: Path = Art.svg("M-34,0 L-34,-34 C-34,-42 -10,-42 -10,-34 L-10,0Z")
        Art.glow(&context, -22, -18, 46, Art.color(gold), alpha: 0.32)
        let lamp: Kit.Stops = [(Art.color(0xF4B58A), 0), (Art.color(0xC9743F), 0.6), (Art.color(0x6A3A2A), 1)]
        Art.fillRadial(&context, door, lamp, center: CGPoint(x: -22, y: -14), radius: 30)
        Art.fill(&context, Art.ellipse(-26, 6, 30, 5), Art.color(gold, 0.2))
        // The thatch.
        let roof: Path = Art.svg("M-78,-52 C-60,-84 -30,-118 0,-124 C30,-118 60,-84 78,-52 C74,-46 66,-44 60,-48 C40,-56 -40,-56 -60,-48 C-66,-44 -74,-46 -78,-52Z")
        Kit.solid(&context, roof, Art.color(0x8A7C52), light: 0.3, shade: 0.32, rim: 2.4)
        var straws = Path()
        for i in -6...6 {
            let f: CGFloat = CGFloat(i)
            straws.move(to: CGPoint(x: f * 3, y: -120))
            straws.addQuadCurve(to: CGPoint(x: f * 12.5, y: -50), control: CGPoint(x: f * 9, y: -92))
        }
        let lines: Path = straws
        Art.clipped(&context, to: roof) { g in
            Art.stroke(&g, lines, Art.color(0x4E4630, 0.5), width: 1.2)
            Art.stroke(&g, Art.svg("M-66,-60 C-40,-68 40,-68 66,-60"), Art.color(0x4E4630, 0.4), width: 1.4)
        }
        Art.stroke(&context, Art.svg("M-13,-120 C-6,-127 6,-127 13,-120"), Art.color(0xB8A870), width: 4)
    }

    /// A white mulberry: low and round-headed. `x`, `baseY` is the foot of the trunk.
    static func mulberry(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32) {
        let h: CGFloat = max(10, height)
        Kit.shadow(&context, x, baseY, width: h * 0.7, alpha: 0.3)
        let bark: Color = Art.color(0x3A3040)
        let fork: CGFloat = baseY - h * 0.42
        Art.stroke(&context, Art.line(x, baseY, x + h * 0.02, fork), bark, width: h * 0.09)
        var boughs = Path()
        boughs.move(to: CGPoint(x: x, y: fork + h * 0.06))
        boughs.addLine(to: CGPoint(x: x - h * 0.2, y: fork - h * 0.2))
        boughs.move(to: CGPoint(x: x, y: fork + h * 0.04))
        boughs.addLine(to: CGPoint(x: x + h * 0.2, y: fork - h * 0.18))
        Art.stroke(&context, boughs, bark, width: h * 0.05)
        Art.stroke(&context, Art.line(x - h * 0.03, baseY - 2, x - h * 0.02, fork), Art.color(silver, 0.25), width: 1.4)
        let r: CGFloat = h * 0.34
        let cy: CGFloat = baseY - h * 0.66
        let blobs: [Kit.Blob] = [
            (x, cy, r),
            (x - r * 0.72, cy + r * 0.24, r * 0.7),
            (x + r * 0.72, cy + r * 0.28, r * 0.7),
            (x - r * 0.32, cy - r * 0.5, r * 0.62),
            (x + r * 0.36, cy - r * 0.46, r * 0.62),
        ]
        Kit.canopy(&context, blobs, seed: seed, palette: nightGreens(), density: 2)
    }
}
