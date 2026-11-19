import SwiftUI
import OmramoCore

// The cast and the shared parts of "The Tongue-Cut Sparrow": the palette and the two lights,
// the old man, the old woman, the Sparrow and the heron, and the story's own things — the
// thatched farmhouse, the sparrows' little house, the two wicker boxes, the tea tray, the
// firewood, the washtub and the drying board. Every picture of the story calls these, so a
// character and a thing look the same wherever they appear.

extension SparrowArt {
    // MARK: Palette and light

    /// Fresh bamboo greens, a pale washed sky, warm straw, one small note of vermilion.
    static let ramp = ArtStyle.Ramp(deep: 0x1F4A3A, shade: 0x3F7D56, mid: 0x86BD7A, light: 0xDDF1E4, glow: 0xFFE9A8, accent: 0xE8483F)

    static let straw: UInt32 = 0xD2AE62
    static let plaster: UInt32 = 0xEADFC6
    static let oldWood: UInt32 = 0x8A6444
    static let paleWood: UInt32 = 0xE9D3A4
    static let wicker: UInt32 = 0xC89A54
    static let indigo: UInt32 = 0x4A76A8
    static let toadBrown: UInt32 = 0x9A6B3E
    static let riceWhite: UInt32 = 0xFFFDF2

    /// Soft morning: pale blue going to the warm glow on the horizon.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xBFE6EE), 0), (Art.color(0xDDF1E4), 0.55), (Art.color(0xFFE9A8), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6D0, glow: 0xFFE9A8, haze: 0xE6F2DC, far: 0xA9D2B4, mid: 0x7FB884, near: 0x5FA06A)
    }

    /// Early evening: a PALE sky, soft pink near the hills. Never night.
    static func evening() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD9E8F5), 0), (Art.color(0xF2E0EA), 0.5), (Art.color(0xFFD6C4), 0.82), (Art.color(0xFFE9A8), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF3D6, glow: 0xFFD9B0, haze: 0xF6DDD8, far: 0xC6B8CC, mid: 0xA3B096, near: 0x86A277)
    }

    /// The wooded hills: cedar and pine greens.
    static func hillGreens() -> Kit.Greens {
        Kit.greens(0x1F4A3A, 0x2F6B4A, 0x4E9A5B, 0x86BD7A, 0xCFE89A)
    }

    /// Bamboo seen through the air: the hazy back layer of a grove.
    static func farBamboo() -> Kit.Greens {
        Kit.greens(0x7FB596, 0x90C2A0, 0xA4D0AA, 0xBEE0B8, 0xDDF0C8)
    }

    /// The meadow under every day scene.
    static func meadow() -> Kit.Stops {
        [(Art.color(0xA9D484), 0), (Art.color(0x86BD7A), 0.4), (Art.color(0x5FA06A), 1)]
    }

    // MARK: People

    /// The old man: white topknot, faded indigo country cloth, straw sandals.
    static func oldManLook() -> Kit.Person {
        Kit.Person(
            age: .elder,
            skin: 0xEBBB90,
            hair: 0xF4F1EA,
            hairStyle: .topknot,
            beard: .none,
            headwear: .none,
            garment: .kimono,
            cloth: indigo,
            trim: 0x2C4E7C,
            legs: 0xCDAA6A,
            showsEyeWhite: true
        )
    }

    /// The old woman: a plain plum cloth over grey hair, brown country cloth.
    static func oldWomanLook() -> Kit.Person {
        Kit.Person(
            age: .elder,
            skin: 0xE8B58C,
            hair: 0xB9B5B0,
            hairStyle: .bun,
            beard: .none,
            headwear: .kerchief,
            headwearColor: 0x8E4A6E,
            garment: .kimono,
            cloth: 0x9A7452,
            trim: 0x6A4A34,
            legs: 0xCDAA6A,
            showsEyeWhite: true
        )
    }

    /// Any rig in the person's own units, with the head set on it (as `Kit.person`, for the
    /// story's own poses).
    static func figure(
        _ context: inout GraphicsContext,
        _ p: Kit.Person,
        rig r: Kit.BodyRig,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        closedEyes: Bool = false,
        mirrored: Bool = false
    ) {
        let f = Kit.bodyFrame(p)
        Art.group(&context, scale: f.k) { g in
            Kit.bodyFigure(&g, p, r, mirrored: mirrored)
        }
        let c = Kit.bodyHeadCentre(f, r)
        let tilt: CGFloat = -Kit.deg(r.lean) * 0.45
        Art.group(&context, x: c.x, y: c.y, rotate: tilt, scale: f.headScale) { g in
            Kit.personHead(&g, p, look: look, mouth: mouth, closedEyes: closedEyes, mirrored: mirrored)
        }
    }

    /// Where the leading hand of `r` is, in the person's own units.
    static func handPoint(_ p: Kit.Person, _ r: Kit.BodyRig) -> CGPoint {
        let f = Kit.bodyFrame(p)
        let s = Kit.bodyShoulder(r, near: true)
        let x: CGFloat = (s.x + r.nearHand.x) * f.k
        let y: CGFloat = (s.y + r.nearHand.y) * f.k
        return CGPoint(x: x, y: y)
    }

    /// Sitting on the porch edge (the caller draws a seat 34 high), one hand held out.
    static func manSitRig() -> Kit.BodyRig {
        var r = Kit.bodySitRig(oldManLook())
        r.nearElbow = CGPoint(x: -12, y: 18)
        r.nearHand = CGPoint(x: -34, y: 14)
        return r
    }

    /// Walking, with a hand cupped beside his mouth to call.
    static func manCallRig() -> Kit.BodyRig {
        var r = Kit.bodyWalkRig(oldManLook())
        r.nearElbow = CGPoint(x: -20, y: 2)
        r.nearHand = CGPoint(x: -14, y: -24)
        r.openHand = true
        return r
    }

    /// Kneeling, the open hand held out low for the Sparrow.
    static func manKneelRig() -> Kit.BodyRig {
        var r = Kit.bodyKneelRig(oldManLook())
        r.lean = 10
        r.nearElbow = CGPoint(x: -16, y: 16)
        r.nearHand = CGPoint(x: -46, y: 22)
        return r
    }

    /// A few grains of rice lying on a hand at `hand`.
    static func riceGrains(_ context: inout GraphicsContext, at hand: CGPoint, scale: CGFloat = 1) {
        let spots: [(CGFloat, CGFloat)] = [(-2.6, -4.6), (0.8, -5.6), (3.2, -4.2), (-0.4, -3.4)]
        var grains = Path()
        for spot in spots {
            let gx: CGFloat = hand.x + spot.0 * scale
            let gy: CGFloat = hand.y + spot.1 * scale
            grains.addPath(Art.ellipse(gx, gy, 1.9 * scale, 1.2 * scale))
        }
        Art.fill(&context, grains, Art.color(riceWhite))
        Art.stroke(&context, grains, Art.color(0xC9B892, 0.7), width: 0.4 * scale)
    }

    /// The old man, feet on the origin, facing LEFT. `wood` ties the bundle of firewood on his
    /// back; `rice` lays a few grains on his leading hand.
    static func oldMan(
        _ context: inout GraphicsContext,
        rig r: Kit.BodyRig,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .smile,
        wood: Bool = false,
        rice: Bool = false,
        mirrored: Bool = false
    ) {
        let p = oldManLook()
        if wood {
            let lean: CGFloat = -Kit.deg(r.lean)
            Art.group(&context, x: 27 + r.hip.x, y: -62, rotate: lean + 0.08) { g in
                firewood(&g)
            }
        }
        figure(&context, p, rig: r, look: look, mouth: mouth, mirrored: mirrored)
        if wood {
            // The straw rope over the shoulder that holds the bundle.
            let rope = Art.svg("M-15,-103 C-6,-96 8,-84 20,-70")
            Art.stroke(&context, rope, Art.color(straw), width: 2.6)
        }
        if rice {
            riceGrains(&context, at: handPoint(p, r))
        }
    }

    /// The old woman walking bent under the very big wicker box (scene-road), feet on the
    /// origin, facing LEFT. With the box she is about 160 wide (x −55…105) and 185 tall.
    static func oldWomanLoaded(
        _ context: inout GraphicsContext,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .oh,
        mirrored: Bool = false
    ) {
        let p = oldWomanLook()
        var r = Kit.bodyWalkRig(p)
        r.lean = 20
        r.nearElbow = CGPoint(x: -4, y: 16)
        r.nearHand = CGPoint(x: -10, y: 4)
        let rig = r
        let hipY: CGFloat = -58 * 0.93
        Art.group(&context, x: 0, y: hipY, rotate: -Kit.deg(20)) { g in
            tsuzuraBody(&g, cx: 62, baseY: 4, width: 82, height: 100)
        }
        figure(&context, p, rig: rig, look: look, mouth: mouth, mirrored: mirrored)
        Art.group(&context, x: 0, y: hipY, rotate: -Kit.deg(20)) { g in
            // The carrying cords over her shoulder, down to her hand.
            let cords = Art.svg("M24,-58 C10,-60 -6,-54 -16,-40 M24,-52 C12,-52 0,-48 -10,-36")
            Art.stroke(&g, cords, Art.color(ramp.accent), width: 2.2)
        }
    }

    /// The old woman standing or bowing with nothing on her back.
    static func oldWoman(
        _ context: inout GraphicsContext,
        pose: Kit.Pose = .stand,
        look: CGPoint = .zero,
        mouth: Kit.Mouth = .flat,
        mirrored: Bool = false
    ) {
        Kit.person(&context, oldWomanLook(), pose: pose, look: look, mouth: mouth, mirrored: mirrored)
    }
}

// MARK: - Birds

extension SparrowArt {
    /// The Sparrow: a tree sparrow with a warm chestnut cap (the kit draws the white cheek,
    /// the black cheek spot and the bib).
    static func heroLook() -> Kit.Bird {
        var look = Kit.sparrowLook()
        look.body = 0xA65A2E
        look.belly = 0xF1E6D0
        return look
    }

    /// The Sparrow, feet on the origin, facing LEFT, about 44 long and 38 tall. `wings` opens
    /// her wings a little (her polite bow is `pose: .peck` with `wings: true`). A touch of
    /// rim light on her cap keeps her readable when she is small.
    static func sparrow(
        _ context: inout GraphicsContext,
        pose: Kit.BirdPose = .perch,
        look: CGPoint = .zero,
        wings: Bool = false,
        mirrored: Bool = false
    ) {
        let b = heroLook()
        if wings {
            let lifted = Art.svg("M2,-24 C6,-38 18,-46 30,-44 C29,-34 22,-24 10,-18Z")
            Kit.solid(&context, lifted, Kit.birdTone(b.wing, 0.92), light: 0.2, shade: 0.16)
            let quills = Art.svg("M8,-24 C12,-32 19,-38 26,-40 M11,-21 C16,-28 22,-33 28,-36")
            Art.stroke(&context, quills, Kit.birdTone(b.wing, 0.62), width: 1.1)
        }
        Kit.bird(&context, b, pose: pose, look: look, mirrored: mirrored)
        if pose == .perch {
            let front = Art.svg("M-21,-37 C-19,-42 -15,-44 -10,-43.5")
            let back = Art.svg("M-10,-43.5 C-4,-43 2,-40 6,-34.5")
            let rim: Path = mirrored ? back : front
            Art.stroke(&context, rim, ArtStyle.warmLight.opacity(0.8), width: 1.4)
        }
    }

    /// One of the Sparrow's family: the plain kit sparrow, no rim light.
    static func cousin(_ context: inout GraphicsContext, pose: Kit.BirdPose = .perch, mirrored: Bool = false) {
        Kit.bird(&context, Kit.sparrowLook(), pose: pose, look: .zero, mirrored: mirrored)
    }

    /// The white heron (an egret), feet on the origin, facing LEFT, about 110 tall.
    static func heron(_ context: inout GraphicsContext, mirrored: Bool = false) {
        Kit.bird(&context, Kit.heronLook(), pose: .perch, look: .zero, mirrored: mirrored)
    }
}

// MARK: - Things

extension SparrowArt {
    /// A bundle of firewood standing on the origin: about 28 wide and 60 tall, tied twice
    /// with straw rope.
    static func firewood(_ context: inout GraphicsContext) {
        let sticks: [(CGFloat, CGFloat, CGFloat)] = [(-9, 55, 0), (-3, 60, 1), (4, 56, 0), (10, 61, 1), (-6, 50, 1), (6, 52, 0)]
        var ends = Path()
        for stick in sticks {
            let wood: UInt32 = stick.2 < 0.5 ? 0x8A6444 : 0xA67C54
            let topX: CGFloat = stick.0 * 1.12
            Kit.propShaft(&context, stick.0, -3, topX, -stick.1, wood: wood, width: 6)
            ends.addPath(Art.ellipse(topX, -stick.1 - 1, 2.6, 1.6))
        }
        Art.fill(&context, ends, Art.color(0xE6C99A))
        let ties = Art.svg("M-13,-18 Q0,-15 14,-18 M-13.5,-40 Q0,-37 14.5,-40")
        Art.stroke(&context, ties, Art.color(straw), width: 2.6)
        Art.stroke(&context, ties, Art.color(0x9A7A3E, 0.6), width: 0.8)
    }

    /// A lidded wicker box (tsuzura) with its vermilion carrying cord, no contact shadow.
    static func tsuzuraBody(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width w: CGFloat, height h: CGFloat) {
        Kit.propBasketBody(&context, cx: cx, baseY: baseY, width: w, height: h, color: wicker, lid: true, handles: false)
        let cord = Art.color(ramp.accent)
        let lw: CGFloat = max(1.2, w * 0.035)
        let rimY: CGFloat = baseY - h * 0.8
        let beltY: CGFloat = baseY - h * 0.42
        var lines = Path()
        lines.move(to: CGPoint(x: cx, y: baseY - h * 0.96))
        lines.addLine(to: CGPoint(x: cx, y: baseY - 1))
        lines.move(to: CGPoint(x: cx - w * 0.42, y: beltY))
        lines.addQuadCurve(to: CGPoint(x: cx + w * 0.42, y: beltY), control: CGPoint(x: cx, y: beltY + h * 0.05))
        Art.stroke(&context, lines, cord, width: lw, cap: .butt)
        // The bow on the lid.
        var bow = Path()
        bow.addPath(Art.ellipse(cx - w * 0.07, rimY - h * 0.04, w * 0.07, h * 0.035))
        bow.addPath(Art.ellipse(cx + w * 0.07, rimY - h * 0.04, w * 0.07, h * 0.035))
        Art.stroke(&context, bow, cord, width: lw * 0.8)
        Art.fill(&context, Art.circle(cx, rimY - h * 0.035, lw * 1.1), cord)
    }

    /// A lidded wicker box standing on baseY, with its contact shadow.
    static func tsuzura(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) {
        Kit.shadow(&context, cx, baseY, width: width * 0.86)
        tsuzuraBody(&context, cx: cx, baseY: baseY, width: width, height: height)
    }

    /// A low tray with a cup of green tea and round white rice cakes, standing on the origin:
    /// about 58 wide and 26 tall.
    static func teaTray(_ context: inout GraphicsContext) {
        Kit.table(&context, cx: 0, baseY: 0, width: 58, height: 11, color: 0x7A3B2E)
        // The cup, pale glaze, with green tea showing at the lip.
        let cup = Art.svg("M-22,-22 L-8,-22 C-8,-15 -10,-11.5 -12,-11 L-18,-11 C-20,-11.5 -22,-15 -22,-22Z")
        Kit.solid(&context, cup, Art.color(0xE6EEF2), light: 0.3, shade: 0.2)
        Art.fill(&context, Art.ellipse(-15, -22, 6.4, 1.6), Art.color(0x9CC46A))
        // Three rice cakes on a leaf.
        Art.fill(&context, Art.ellipse(9, -11.6, 17, 2.2), Art.color(ramp.shade))
        var cakes = Path()
        cakes.addPath(Art.svg("M-4,-12 C-4,-19 6,-19 6,-12Z"))
        cakes.addPath(Art.svg("M8,-12 C8,-19 18,-19 18,-12Z"))
        cakes.addPath(Art.svg("M2,-18 C2,-25 12,-25 12,-18Z"))
        Kit.solid(&context, cakes, Art.color(riceWhite), light: 0.2, shade: 0.16)
        // Sweet red beans in a tiny dish.
        Art.fill(&context, Art.svg("M19,-14 L27,-14 C27,-11.5 25,-11 23,-11 C21,-11 19,-11.5 19,-14Z"), Art.color(0x3F5E7A))
        Art.fill(&context, Art.ellipse(23, -14.4, 3.4, 1.5), Art.color(0x8E2F3A))
    }

    /// The round wooden washtub with a heap of washing, standing on the origin: 60 wide.
    static func washtub(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 0, 0, width: 66)
        // The washing heaped over the rim.
        let heap = Art.svg("M-22,-24 C-20,-36 -8,-38 -2,-32 C4,-40 18,-38 21,-24Z")
        Kit.solid(&context, heap, Art.color(0xF4F1E6), light: 0.2, shade: 0.2)
        Art.stroke(&context, Art.svg("M-12,-29 C-8,-27 -6,-26 -3,-31 M6,-33 C9,-29 13,-28 16,-29"), Art.color(0xB9C4D6), width: 1.1)
        let tub = Art.svg("M-30,-26 L30,-26 L26,-2 Q26,0 23,0 L-23,0 Q-26,0 -26,-2Z")
        Kit.solid(&context, tub, Art.color(0xC9A46E), light: 0.28, shade: 0.24)
        let staves = Art.svg("M-18,-26 L-16,0 M-6,-26 L-5,0 M6,-26 L5,0 M18,-26 L16,0")
        Art.stroke(&context, staves, Art.color(0x9A7648, 0.7), width: 1.1)
        // Two hoops of split bamboo.
        let hoops = Art.svg("M-29.4,-21 L29.4,-21 M-27,-6 L27,-6")
        Art.stroke(&context, hoops, Art.color(0x6E8A4A), width: 2.4, cap: .butt)
        Art.stroke(&context, Art.line(-29, -25.4, 29, -25.4), ArtStyle.warmLight.opacity(0.7), width: 1.2)
    }

    /// A drying board leaning back with a length of washed cloth stretched flat on it; its
    /// foot on the origin, about 30 wide and 92 tall.
    static func dryingBoard(_ context: inout GraphicsContext, cloth: UInt32) {
        Kit.shadow(&context, 6, 0, width: 30, alpha: 0.2)
        // The prop behind it.
        Kit.propShaft(&context, 22, 0, 8, -70, wood: oldWood, width: 3)
        let board = Art.svg("M-10,0 L8,0 L16,-90 L-2,-90Z")
        Kit.solid(&context, board, Art.color(0xB98E5E), light: 0.26, shade: 0.2)
        let sheet = Art.svg("M-7,-8 L7.6,-8 L14,-84 L-0.6,-84Z")
        Kit.solid(&context, sheet, Art.color(cloth), light: 0.3, shade: 0.12)
        Art.stroke(&context, Art.svg("M-0.4,-84 L-6.8,-8"), ArtStyle.warmLight.opacity(0.7), width: 1)
    }
}

// MARK: - Buildings

extension SparrowArt {
    /// The old couple's farmhouse (minka), seen from the front, standing on the origin (the
    /// ground under the middle of its wall): pale earth-plaster walls between wooden posts, a
    /// thick steep thatch, a sliding wooden door, a slatted window and a narrow raised porch
    /// (engawa) whose deck is 22 above the ground. About 290 wide and 226 tall; the porch edge
    /// runs from x −135 to 135.
    static func minka(_ context: inout GraphicsContext) {
        let deck: CGFloat = 22
        Kit.shadow(&context, 0, 0, width: 280)
        // The dark under the porch.
        Art.fill(&context, Art.rect(-124, -deck + 2, 248, deck - 2), Art.color(0x4A3A44, 0.6))
        Kit.house(&context, cx: 0, baseY: -deck, width: 230, wallHeight: 80, roofHeight: 122, wall: plaster, roof: straw, style: .thatch, door: 0x5A3E2A, windows: 0)
        let wallTop: CGFloat = -deck - 80
        // Posts and a rail: the wooden frame that holds the earth walls.
        let posts: [CGFloat] = [-112, -62, 62, 112]
        for x in posts {
            Kit.propShaft(&context, x, -deck - 2, x, wallTop + 12, wood: oldWood, width: 6)
        }
        Art.stroke(&context, Art.line(-112, -deck - 60, 112, -deck - 60), Art.color(oldWood), width: 4, cap: .butt)
        // The sliding door, half open, beside the dark doorway (the kit's door is 34 wide).
        let panel = Art.rect(15, -deck - 58, 38, 58, radius: 1)
        Kit.solid(&context, panel, Art.color(0xB98E5E), light: 0.22, shade: 0.18)
        let boards = Art.svg("M24.5,-80 L24.5,-22 M34,-80 L34,-22 M43.5,-80 L43.5,-22 M15,-52 L53,-52")
        Art.stroke(&context, boards, Art.color(0x8A6444, 0.75), width: 1.2, cap: .butt)
        // The slatted window.
        let window = Art.rect(-100, -deck - 54, 30, 28, radius: 1)
        Art.fill(&context, window, Art.color(0x4A3A44))
        let slats = Art.svg("M-94,-76 L-94,-48 M-88,-76 L-88,-48 M-82,-76 L-82,-48 M-76,-76 L-76,-48")
        Art.stroke(&context, slats, Art.color(0xB98E5E), width: 2.2, cap: .butt)
        Art.stroke(&context, window, Art.color(oldWood), width: 2.4)
        // The porch: legs, then the deck with its lit edge.
        let legs: [CGFloat] = [-122, -42, 42, 122]
        for x in legs {
            Kit.propShaft(&context, x, -deck + 4, x, -1, wood: oldWood, width: 5)
        }
        let board = Art.rect(-135, -deck - 4, 270, 9, radius: 2)
        Kit.solid(&context, board, Art.color(0xC9A46E), light: 0.3, shade: 0.22)
        Art.stroke(&context, Art.line(-132, -deck - 3.2, 132, -deck - 3.2), ArtStyle.warmLight.opacity(0.7), width: 1.3)
        Art.stroke(&context, Art.svg("M-70,-26 L-70,-17 M0,-26 L0,-17 M70,-26 L70,-17"), Art.color(0x9A7648, 0.6), width: 1)
    }

    /// The sparrows' house: small, neat, of pale new wood, with a board roof and a wide low
    /// porch whose deck is 16 above the ground. Standing on the origin; about 230 wide and
    /// 135 tall; the porch runs from x −112 to 112.
    static func sparrowHouse(_ context: inout GraphicsContext) {
        let deck: CGFloat = 16
        Kit.shadow(&context, 0, 0, width: 230)
        Art.fill(&context, Art.rect(-104, -deck + 2, 208, deck - 2), Art.color(0x4A3A44, 0.5))
        Kit.house(&context, cx: 0, baseY: -deck, width: 150, wallHeight: 60, roofHeight: 56, wall: paleWood, roof: 0xCFAE78, style: .shingle, door: 0x7A5A3E, windows: 0)
        // Upright boards and corner posts.
        let seams = Art.svg("M-56,-72 L-56,-18 M-38,-72 L-38,-18 M38,-72 L38,-18 M56,-72 L56,-18")
        Art.stroke(&context, seams, Art.color(0xC9A46E, 0.8), width: 1.1, cap: .butt)
        Kit.propShaft(&context, -73, -deck - 2, -73, -deck - 52, wood: 0xD9B67E, width: 5)
        Kit.propShaft(&context, 73, -deck - 2, 73, -deck - 52, wood: 0xD9B67E, width: 5)
        // A round window like a rice cake, beside the door.
        Art.fill(&context, Art.circle(-46, -deck - 34, 9), Art.color(0x7A5A3E))
        Art.stroke(&context, Art.circle(-46, -deck - 34, 9), Art.color(0xD9B67E), width: 2.2)
        Art.stroke(&context, Art.svg("M-46,-59 L-46,-41 M-55,-50 L-37,-50"), Art.color(0xD9B67E), width: 1.4, cap: .butt)
        // The porch.
        let legs: [CGFloat] = [-102, -34, 34, 102]
        for x in legs {
            Kit.propShaft(&context, x, -deck + 4, x, -1, wood: 0xC9A46E, width: 4.5)
        }
        let board = Art.rect(-112, -deck - 4, 224, 8, radius: 2)
        Kit.solid(&context, board, Art.color(paleWood), light: 0.3, shade: 0.2)
        Art.stroke(&context, Art.line(-109, -deck - 3.2, 109, -deck - 3.2), Color.white.opacity(0.6), width: 1.2)
    }

    /// The little wicket gate: two short posts and a low leaf of split bamboo, standing on
    /// the origin; 56 wide and 44 tall (posts). The Sparrow perches on the left post, whose
    /// top is at (−26, −45).
    static func wicket(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 0, 0, width: 64, alpha: 0.2)
        var leaf = Path()
        let canes: [CGFloat] = [-18, -11, -4, 3, 10, 17]
        for x in canes {
            leaf.move(to: CGPoint(x: x, y: -2))
            leaf.addLine(to: CGPoint(x: x, y: -34))
        }
        Art.stroke(&context, leaf, Art.color(0xC8B878), width: 3.2)
        Art.stroke(&context, Art.svg("M-23,-12 L23,-12 M-23,-27 L23,-27"), Art.color(0x9A8A4E), width: 2.2, cap: .butt)
        Kit.propShaft(&context, -26, 0, -26, -42, wood: 0xB98E5E, width: 7)
        Kit.propShaft(&context, 26, 0, 26, -42, wood: 0xB98E5E, width: 7)
    }

    // MARK: Shared ground dressing

    /// Grass, a few flowers and pebbles over the ground of an unfolded scene, thicker and
    /// with near tufts when the window is tall, so the foot of the picture is never empty.
    static func dressGround(_ context: inout GraphicsContext, _ st: Kit.Stage, seed: UInt32, flowers petal: UInt32) {
        let top: CGFloat = st.H + 10
        let depth: CGFloat = max(1, st.h - top)
        let field = CGRect(x: 0, y: top, width: st.w, height: depth)
        let many: Int = 70 + Int(st.tall * 120)
        Kit.grass(&context, in: field, count: many, seed: seed, color: Art.color(ramp.shade, 0.55), height: 7 * st.far)
        Kit.grass(&context, in: field, count: many / 2, seed: seed &+ 7, color: Art.color(0xCFE89A, 0.7), height: 6 * st.far)
        let low = CGRect(x: 0, y: top + depth * 0.35, width: st.w, height: depth * 0.6)
        Kit.flowers(&context, in: low, count: 8 + Int(st.tall * 16), seed: seed &+ 3, petal: petal)
        Kit.pebbles(&context, in: low, count: 6 + Int(st.tall * 10), seed: seed &+ 11)
        if st.tall > 0.25 {
            let foot: CGFloat = st.h - 6
            Kit.grassTuft(&context, x: 120, baseY: foot, height: 70 * st.grow, color: ramp.shade, seed: seed &+ 1)
            Kit.grassTuft(&context, x: 300, baseY: foot + 4, height: 54 * st.grow, color: 0x4E9A5B, seed: seed &+ 2)
            Kit.grassTuft(&context, x: 520, baseY: foot + 2, height: 60 * st.grow, color: ramp.shade, seed: seed &+ 4)
            Kit.rock(&context, cx: 214, baseY: foot - 30, width: 70, height: 34, color: 0x9A9A8C, seed: seed &+ 5)
        }
    }
}
