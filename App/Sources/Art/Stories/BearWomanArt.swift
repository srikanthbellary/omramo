import SwiftUI
import OmramoCore

/// Concept art for "The Woman Who Raised a Bear", drawn in code (round 5; composed from the shared kit).
enum BearWomanArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-settlement", .sceneUnfolded): settlementScene(&context, size)
        case ("scene-settlement", .sceneFolded): settlementFolded(&context, size)
        case ("scene-house", .sceneUnfolded): houseScene(&context, size)
        case ("scene-house", .sceneFolded): houseFolded(&context, size)
        case ("scene-ice", .sceneUnfolded): iceScene(&context, size)
        case ("scene-ice", .sceneFolded): iceFolded(&context, size)
        case ("scene-farewell", .sceneUnfolded): farewellScene(&context, size)
        case ("scene-farewell", .sceneFolded): farewellFolded(&context, size)
        case ("see-greenland", .picture): greenlandPicture(&context, size)
        case ("see-polar-bear", .picture): polarBearPicture(&context, size)
        case ("see-kayak", .picture): kayakPicture(&context, size)
        case ("see-sharing-the-catch", .picture): sharingPicture(&context, size)
        case ("char-woman", .portrait): womanPortrait(&context, size)
        case ("char-bear", .portrait): bearPortrait(&context, size)
        case ("face-woman", .face): womanFace(&context, size)
        case ("face-bear", .face): bearFace(&context, size)
        case ("cover", .cover): coverPicture(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Unfolded scenes

extension BearWomanArt {
    // MARK: Scene 1 — the settlement on the shore

    /// Late winter, clear pale light. The bay of sea ice and icebergs low on the left; the
    /// low stone-and-turf houses, kayak, rack, dogs, the young bear and the children on the
    /// rocky shore low on the right. The upper part of both panes is pale sky.
    static func settlementScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = day()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 96, st.H - 30 * st.far, 12, light: light)
        let farCoast: Path = Kit.peaks(width: size.width, y: st.H - 2, amp: 40 * st.far, seed: 21, bottom: st.H + 4, sharp: 0.5)
        Art.fill(&context, farCoast, light.far.opacity(0.75))
        let veilTop: CGFloat = st.H - 70 * st.far
        ArtStyle.atmosphere(&context, width: size.width, top: veilTop, bottom: st.H + 4, color: light.haze, alpha: 0.35)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: iceStops())
        Art.fill(&context, Art.rect(0, st.H + 1, size.width, 3 * st.fit), Art.color(0x7FA3BA, 0.45))
        Kit.designSpace(&context, st) { v in
            settlementBay(&v, st)
            Kit.nearSpace(&v, st) { n in
                settlementShore(&n, st)
                settlementPeople(&n, st)
            }
            settlementForeground(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// The bay: icebergs resting in the sea ice, cracks of blue, a parked sledge.
    static func settlementBay(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        iceberg(&v, x: 118, baseY: H + 14, width: 72, height: 44, sharp: true, seed: 2)
        iceberg(&v, x: 226, baseY: H + 8, width: 92, height: 26, sharp: false, seed: 3)
        iceberg(&v, x: 334, baseY: H + 22, width: 48, height: 34, sharp: true, seed: 4)
        iceberg(&v, x: 40, baseY: H + 6, width: 40, height: 16, sharp: false, seed: 5)
        let cracks: Path = Art.svg("M0,\(H + 46) C80,\(H + 40) 160,\(H + 52) 260,\(H + 44) M120,\(H + 86) C200,\(H + 80) 280,\(H + 92) 360,\(H + 84)")
        Art.stroke(&v, cracks, Art.color(0x8FB4CC, 0.55), width: 1.4)
        Kit.flecks(&v, in: CGRect(x: 0, y: H + 30, width: 380, height: 150), count: 30, seed: 14, color: Color.white, radius: 0.8...1.8)
        sledge(&v, x: 330, y: H + 128, scale: 0.9)
    }

    /// A wooden dog sledge on its runners, parked; origin on the ground under its middle.
    static func sledge(_ v: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat) {
        Art.group(&v, x: x, y: y, scale: scale) { g in
            Kit.shadow(&g, 0, 0, width: 90, alpha: 0.18)
            let runners: Path = Art.svg("M-46,-2 L40,-2 C48,-2 52,-8 50,-14 M-40,-8 L36,-8 C44,-8 48,-14 46,-20")
            Art.stroke(&g, runners, Art.color(0x6E543C), width: 2.6)
            var slats = Path()
            for i in 0..<7 {
                let sx: CGFloat = -38 + CGFloat(i) * 11
                slats.addRoundedRect(in: CGRect(x: sx, y: -14, width: 8, height: 4), cornerSize: CGSize(width: 1.5, height: 1.5))
            }
            Art.fill(&g, slats, Art.color(woodHex))
            Art.stroke(&g, Art.svg("M-36,-12 L-34,-4 M26,-12 L28,-4"), Art.color(0x6E543C), width: 2)
        }
    }

    /// The rocky shore and the houses on it (inside `nearSpace`, anchored on the trailing edge).
    static func settlementShore(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let B: CGFloat = st.hv + 60
        var land = Path()
        land.move(to: Kit.pt(372, B))
        land.addLine(to: Kit.pt(372, H + 100))
        land.addQuadCurve(to: Kit.pt(520, H + 38), control: Kit.pt(420, H + 46))
        land.addQuadCurve(to: Kit.pt(912, H - 8), control: Kit.pt(700, H + 8))
        land.addLine(to: Kit.pt(912, B))
        land.closeSubpath()
        Kit.solid(&n, land, stops: Kit.stops(0x8E989E, 0x6C777E, 0x5E6A72), light: 0.2, shade: 0.2, rim: 2.4)
        Kit.drift(&n, x0: 390, x1: 520, baseY: H + 96, height: 12, bottom: H + 112, snow: true)
        Kit.drift(&n, x0: 640, x1: 780, baseY: H + 92, height: 9, bottom: H + 104, snow: true)
        Kit.drift(&n, x0: 760, x1: 900, baseY: H + 40, height: 8, bottom: H + 52, snow: true)
        Kit.grass(&n, in: CGRect(x: 430, y: H + 44, width: 450, height: 56), count: 34, seed: 5, color: Art.color(0x6C6A44), height: 6)
        Kit.grass(&n, in: CGRect(x: 450, y: H + 56, width: 430, height: 50), count: 22, seed: 8, color: Art.color(0x7E5A48), height: 5)
        Kit.rock(&n, cx: 474, baseY: H + 92, width: 30, height: 15, color: 0x7A848A, seed: 7)
        Kit.rock(&n, cx: 870, baseY: H + 78, width: 26, height: 12, color: 0x7A848A, seed: 12)
        Art.group(&n, x: 845, y: H + 20, scale: 0.66) { g in turfHouse(&g, window: true, seed: 5) }
        Art.group(&n, x: 742, y: H + 36, scale: 0.82) { g in turfHouse(&g, window: true, seed: 6) }
        Art.group(&n, x: 812, y: H + 68, scale: 0.9) { g in dryingRack(&g) }
        Art.group(&n, x: 604, y: H + 64, scale: 1) { g in turfHouse(&g, window: true, seed: 7) }
        Art.group(&n, x: 712, y: H + 90, scale: 0.92) { g in kayakOnStand(&g) }
    }

    /// The old woman at her passage, the young bear in the snow, two children, the dogs.
    static func settlementPeople(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        Art.group(&n, x: 790, y: H + 106, scale: 0.9) { g in restingDog(&g, coat: 0xE4D8C2) }
        Art.group(&n, x: 822, y: H + 112, scale: 0.9) { g in restingDog(&g, coat: 0x4E4038, mirrored: true) }
        Art.group(&n, x: 852, y: H + 104, scale: 0.85) { g in restingDog(&g, coat: 0xC9B79A) }
        Art.group(&n, x: 520, y: H + 108, scale: 0.6) { g in bearLying(&g, lift: 0.45, collar: false, cub: false) }
        Art.group(&n, x: 418, y: H + 116, scale: 0.6) { g in child(&g, 0, pose: .wave, mirrored: true) }
        Art.group(&n, x: 604, y: H + 118, scale: 0.6) { g in child(&g, 1, pose: .walk) }
        Art.group(&n, x: 664, y: H + 100, scale: 0.66) { g in woman(&g, pose: .stand, mouth: .smile) }
        let toy: Path = Art.line(392, H + 112, 404, H + 104)
        Art.stroke(&n, toy, Art.color(0xE6DCC6), width: 2)
    }

    /// The deeper foreground on a tall window and the dark near framing at the bottom corners.
    static func settlementForeground(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let bottom: CGFloat = st.hv
        if st.tall > 0.25 {
            let depthTop: CGFloat = H + 230
            Kit.drift(&v, x0: 60, x1: 360, baseY: depthTop + 40, height: 18, bottom: bottom + 10, snow: true)
            Kit.drift(&v, x0: 500, x1: 892, baseY: depthTop + 70, height: 22, bottom: bottom + 10, snow: true)
            pawPrints(&v, from: Kit.pt(470, bottom - 30), to: Kit.pt(520, H + 150), count: 14, size: 6)
            Kit.pebbles(&v, in: CGRect(x: 560, y: depthTop, width: 300, height: 80), count: 30, seed: 17, color: 0x7A848A)
            Kit.grass(&v, in: CGRect(x: 540, y: depthTop + 20, width: 320, height: 90), count: 26, seed: 19, color: Art.color(0x6C6A44), height: 9)
        }
        Kit.rock(&v, cx: 40, baseY: bottom + 12, width: 120, height: 44, color: 0x56626A, seed: 31)
        Kit.drift(&v, x0: -20, x1: 150, baseY: bottom + 4, height: 16, bottom: bottom + 20, snow: true)
        Kit.rock(&v, cx: 876, baseY: bottom + 14, width: 130, height: 58, color: 0x4E5A62, seed: 33)
    }

    // MARK: Scene 2 — inside the house

    /// Cream lamplight inside the house: the skin-lined roof and the plain turf wall above,
    /// calm for the words; low on the right the sleeping platform, the half-moon lamp under its
    /// drying rack, and the old woman feeding the small cub from her hands.
    static func houseScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        houseWalls(&context, size, horizon: st.H)
        Kit.designSpace(&context, st) { v in
            housePlatform(&v, st)
            Kit.nearSpace(&v, st, anchorX: 600) { n in
                houseHearth(&n, st)
                houseFigures(&n, st)
            }
            houseFloor(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// The skin-lined roof and the turf wall, pale and plain, warmed toward the lamp.
    static func houseWalls(_ context: inout GraphicsContext, _ size: CGSize, horizon H: CGFloat) {
        let w: CGFloat = size.width
        let roofBottom: CGFloat = (H * 0.4).rounded()
        let roof: Kit.Stops = [(Art.color(0xF6EEDF), 0), (Art.color(0xF2E6D0), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, roofBottom + 2), roof, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: roofBottom))
        var seams = Path()
        var sx: CGFloat = 70
        while sx < w {
            seams.move(to: Kit.pt(sx, 0))
            seams.addQuadCurve(to: Kit.pt(sx + 30, roofBottom), control: Kit.pt(sx + 22, roofBottom * 0.5))
            sx += 150
        }
        Art.stroke(&context, seams, Art.color(0xD9C8AA, 0.35), width: 1.2)
        let beam: Path = Art.rect(0, roofBottom - 6, w, 10, radius: 4)
        Art.fill(&context, beam, Art.color(0xC9B08A, 0.55))
        let wall: Kit.Stops = [(Art.color(0xF0E2C8), 0), (Art.color(0xEAD8B8), 1)]
        Art.fillLinear(&context, Art.rect(0, roofBottom + 4, w, H - roofBottom + 40), wall, from: CGPoint(x: 0, y: roofBottom), to: CGPoint(x: 0, y: H))
        var blocks = Path()
        var row: Int = 0
        var by: CGFloat = roofBottom + 30
        while by < H - 10 {
            blocks.move(to: Kit.pt(0, by))
            blocks.addLine(to: Kit.pt(w, by))
            var bx: CGFloat = row % 2 == 0 ? 40 : 100
            while bx < w {
                blocks.move(to: Kit.pt(bx, by))
                blocks.addLine(to: Kit.pt(bx + 2, by + 34))
                bx += 120
            }
            by += 34
            row += 1
        }
        Art.stroke(&context, blocks, Art.color(0xC8B08C, 0.16), width: 1.4)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: H), seed: 41, color: Art.color(0xA08660), alpha: 0.05)
    }

    /// The platform along the back wall, its sealskins, the gut-skin window and the passage mouth.
    static func housePlatform(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let pane: Path = Art.rect(214, H - 72, 64, 34, radius: 6)
        Art.glow(&v, 246, H - 55, 70, Color.white, alpha: 0.35)
        Art.fill(&v, pane, Art.color(0xF8EED4))
        Art.stroke(&v, pane, Art.color(0xCDB48C, 0.8), width: 2)
        Art.stroke(&v, Art.line(246, H - 72, 246, H - 38), Art.color(0xE2D0A8, 0.8), width: 1)
        Art.glow(&v, 560, H - 150, 120, Art.color(sootHex), alpha: 0.1)
        // The platform reaches x −600 so it still meets the left edge when designSpace shrinks.
        let top: Path = Art.rect(-600, H - 6, 1502, 40)
        Art.fill(&v, top, Art.color(0xC9B594))
        skins(&v, x0: -600, x1: 900, y: H - 2, depth: 32, seed: 9)
        let face: Path = Art.rect(-600, H + 30, 1502, 38)
        Kit.solid(&v, face, Art.color(0x9C8466), light: 0.2, shade: 0.24)
        let edge: Path = Art.rect(-600, H + 28, 1502, 6, radius: 3)
        Kit.solid(&v, edge, Art.color(woodHex), light: 0.3, shade: 0.2)
        var stones = Path()
        var fx: CGFloat = -600
        while fx < 900 {
            stones.addRoundedRect(in: CGRect(x: fx, y: H + 38, width: 40, height: 24), cornerSize: CGSize(width: 6, height: 6))
            fx += 44
        }
        Art.stroke(&v, stones, Art.color(0x6E5C48, 0.4), width: 1.2)
        let rolled: Path = Art.svg("M60,\(H + 6) C60,\(H - 16) 120,\(H - 16) 120,\(H + 6) Z")
        Kit.solid(&v, rolled, Art.color(0x8E765C), light: 0.26, shade: 0.24, rim: 1.6)
        let bag: Path = Art.svg("M150,\(H + 8) C146,\(H - 8) 156,\(H - 16) 166,\(H - 16) C176,\(H - 16) 184,\(H - 8) 180,\(H + 8) Z")
        Kit.solid(&v, bag, Art.color(0xA0805E), light: 0.26, shade: 0.24, rim: 1.6)
    }

    /// The lamp on its stone by the platform edge, the rack and hanging pot above it.
    static func houseHearth(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        Art.glow(&n, 520, H, 330, Art.color(0xFFD98A), alpha: 0.22)
        let stand: Path = Art.svg("M488,\(H + 70) L492,\(H + 32) C506,\(H + 28) 534,\(H + 28) 548,\(H + 32) L552,\(H + 70) Z")
        Kit.solid(&n, stand, Art.color(0x8A867C), light: 0.26, shade: 0.26, rim: 1.6)
        Kit.shadow(&n, 520, H + 70, width: 80)
        Art.group(&n, x: 520, y: H + 28) { g in stoneLamp(&g, width: 82) }
        Art.group(&n, x: 520, y: H - 62) { g in lampRack(&g, width: 100) }
        let cords: Path = Art.svg("M506,\(H - 60) L510,\(H - 40) M534,\(H - 60) L530,\(H - 40)")
        Art.stroke(&n, cords, Art.color(0x8A7A62, 0.7), width: 1.2)
        let pot: Path = Art.svg("M504,\(H - 40) L536,\(H - 40) L534,\(H - 22) C530,\(H - 18) 510,\(H - 18) 506,\(H - 22) Z")
        Kit.solid(&n, pot, Art.color(0x8E8C84), light: 0.3, shade: 0.28, rim: 1.4)
    }

    /// The old woman sitting on the platform, holding blubber out to the cub on the skins.
    static func houseFigures(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let look = womanLook()
        let hand: CGPoint = Kit.hand(look, pose: .sit)
        let wx: CGFloat = 664
        let wy: CGFloat = H + 48
        let hx: CGFloat = wx + hand.x
        let hy: CGFloat = wy + hand.y
        Kit.shadow(&n, wx + 6, H + 22, width: 90, alpha: 0.2)
        let cubX: CGFloat = hx - 50
        Art.group(&n, x: cubX, y: H + 16, scale: 0.36) { g in
            bearLying(&g, lift: 0.9, collar: false, cub: true, mirrored: true)
        }
        Art.group(&n, x: wx, y: wy) { g in woman(&g, pose: .sit, mouth: .smile) }
        let morsel: Path = Art.svg("M\(hx - 5),\(hy - 1) C\(hx - 5),\(hy - 6) \(hx + 3),\(hy - 7) \(hx + 4),\(hy - 2) C\(hx + 4),\(hy + 2) \(hx - 4),\(hy + 3) \(hx - 5),\(hy - 1) Z")
        Kit.solid(&n, morsel, Art.color(0xF2E4C2), light: 0.3, shade: 0.2)
        Art.glow(&n, wx - 20, H - 40, 90, Art.color(0xFFD98A), alpha: 0.18)
    }

    /// The floor of flat stones down to the bottom, the passage mouth and the near framing.
    static func houseFloor(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let bottom: CGFloat = st.hv
        let floorTop: CGFloat = H + 68
        let floor: Kit.Stops = [(Art.color(0xB9AA90), 0), (Art.color(0x9E8E76), 1)]
        Art.fillLinear(&v, Art.rect(-600, floorTop, 1502, bottom - floorTop + 20), floor, from: CGPoint(x: 0, y: floorTop), to: CGPoint(x: 0, y: bottom))
        Art.fill(&v, Art.rect(-600, floorTop, 1502, 6), ArtStyle.coolShade.opacity(0.12))
        var random = ArtRandom(23)
        var stones = Path()
        var y: CGFloat = floorTop + 10
        var rowH: CGFloat = 22
        while y < bottom {
            var x: CGFloat = -600 + Kit.rnd(&random) * 30
            while x < 900 {
                let sw: CGFloat = rowH * (2 + Kit.rnd(&random) * 1.4)
                stones.addRoundedRect(in: CGRect(x: x, y: y, width: sw - 6, height: rowH - 5), cornerSize: CGSize(width: 7, height: 7))
                x += sw
            }
            y += rowH
            rowH *= 1.18
        }
        Art.stroke(&v, stones, Art.color(0x6E5E4A, 0.35), width: 1.4)
        Art.glow(&v, 560, floorTop + 20, 260, Art.color(0xFFD98A), alpha: 0.16)
        let mouthY: CGFloat = floorTop + 40
        let mouth: Path = Art.svg("M110,\(mouthY + 14) C110,\(mouthY - 6) 140,\(mouthY - 14) 180,\(mouthY - 14) C220,\(mouthY - 14) 250,\(mouthY - 6) 250,\(mouthY + 14) Z")
        Art.fill(&v, mouth, Art.color(0x4A3A2E, 0.75))
        Art.stroke(&v, mouth, Art.color(0x8A7A62, 0.8), width: 3)
        let post: Path = Art.svg("M862,\(bottom + 10) L866,\(H - 30) L892,\(H - 34) L896,\(bottom + 10) Z")
        Kit.solid(&v, post, Art.color(0x5E4A38), light: 0.2, shade: 0.3)
        Kit.rock(&v, cx: 30, baseY: bottom + 14, width: 110, height: 40, color: 0x6A5E50, seed: 37)
    }

    // MARK: Scene 3 — far out on the sea ice

    /// The flat sea ice under a high pale sky, a blue line of open water at its edge. Low on
    /// the right the grown bear, collar on, hauls a seal home; two hunters and a kayak far
    /// behind; the settlement a tiny mark on the far left shore.
    static func iceScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = day()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 120, st.H - 24 * st.far, 11, light: light)
        iceFarPlane(&context, size, st, light: light)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: iceStops())
        Kit.designSpace(&context, st) { v in
            iceMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 720) { n in
                iceHaul(&n, st)
            }
            iceForeground(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// The far shore with the settlement as a tiny mark, far bergs, the open water line.
    static func iceFarPlane(_ context: inout GraphicsContext, _ size: CGSize, _ st: Kit.Stage, light: Kit.Light) {
        let s: CGFloat = st.far
        let H: CGFloat = st.H
        let shore: Path = Kit.ridge(width: 220 * s, y: H - 5 * s, amp: 4 * s, seed: 8, bottom: H + 2, step: 6, x0: 0)
        Art.fill(&context, shore, light.mid.opacity(0.8))
        var huts = Path()
        let places: [CGFloat] = [92, 104, 118]
        for hx in places {
            huts.addEllipse(in: CGRect(x: hx * s, y: H - 11 * s, width: 7 * s, height: 5 * s))
        }
        Art.fill(&context, huts, light.near.opacity(0.75))
        let bergs: [(CGFloat, CGFloat, CGFloat)] = [(560, 22, 12), (640, 14, 8), (790, 26, 16)]
        for berg in bergs {
            let bx: CGFloat = berg.0 * size.width / 892
            iceberg(&context, x: bx, baseY: H + 1, width: berg.1 * s * 1.6, height: berg.2 * s, sharp: berg.2 > 10, seed: 6)
        }
        ArtStyle.atmosphere(&context, width: size.width, top: H - 40 * s, bottom: H + 2, color: light.haze, alpha: 0.4)
        let lead: Path = Art.rect(380 * size.width / 892, H - 1, size.width, 5 * st.fit)
        Art.fill(&context, lead, Art.color(0x5F86A3, 0.75))
    }

    /// Low pressure ridges, a breathing hole, the two hunters and the kayak far behind, and
    /// the bear's track and drag mark coming from them.
    static func iceMiddle(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        pressureRidge(&v, x0: -300, x1: 520, baseY: H + 34, height: 9, seed: 3)
        pressureRidge(&v, x0: 610, x1: 900, baseY: H + 26, height: 7, seed: 4)
        Art.group(&v, x: 770, y: H + 12, scale: 0.34) { g in kayak(&g, y: -4) }
        Art.group(&v, x: 812, y: H + 22, scale: 0.3) { g in hunter(&g, 0, pose: .stand) }
        Art.group(&v, x: 846, y: H + 20, scale: 0.29) { g in hunter(&g, 1, pose: .walk) }
        let hole: Path = Art.ellipse(470, H + 70, 12, 3.6)
        Art.fill(&v, Art.ellipse(470, H + 69, 20, 6), Color.white)
        Art.fill(&v, hole, Art.color(0x3E5A73, 0.75))
        let drag: Path = Art.svg("M760,\(H + 104) C800,\(H + 96) 850,\(H + 74) 910,\(H + 58)")
        Art.stroke(&v, drag, Art.color(0x9DB9CC, 0.35), width: 8)
        pawPrints(&v, from: Kit.pt(768, H + 108), to: Kit.pt(900, H + 64), count: 12, size: 5)
        let sastrugi: Path = Art.svg("M20,\(H + 60) C80,\(H + 56) 140,\(H + 62) 200,\(H + 58) M240,\(H + 96) C320,\(H + 90) 380,\(H + 100) 440,\(H + 94) M60,\(H + 140) C160,\(H + 132) 260,\(H + 146) 360,\(H + 138)")
        Art.stroke(&v, sastrugi, Art.color(0xA9C4D6, 0.5), width: 1.6)
    }

    /// A low line of broken ice blocks pushed up on the flat ice.
    static func pressureRidge(_ v: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed)
        var x: CGFloat = x0
        var blocks = Path()
        var shades = Path()
        while x < x1 {
            let bw: CGFloat = 10 + Kit.rnd(&random) * 16
            let bh: CGFloat = height * (0.4 + Kit.rnd(&random) * 0.8)
            let tilt: CGFloat = (Kit.rnd(&random) - 0.5) * bw * 0.5
            let pts: [CGPoint] = [Kit.pt(x, baseY), Kit.pt(x + tilt, baseY - bh), Kit.pt(x + bw * 0.7 + tilt, baseY - bh * 1.1), Kit.pt(x + bw, baseY)]
            blocks.addPath(Art.polygon(pts))
            let side: [CGPoint] = [Kit.pt(x + bw * 0.6 + tilt, baseY - bh * 1.05), Kit.pt(x + bw * 0.7 + tilt, baseY - bh * 1.1), Kit.pt(x + bw, baseY), Kit.pt(x + bw * 0.62, baseY)]
            shades.addPath(Art.polygon(side))
            x += bw * 0.8
        }
        Art.fill(&v, Art.rect(x0, baseY - 2, x1 - x0, 5, radius: 2), Art.color(0xA9C4D6, 0.35))
        Art.fill(&v, blocks, Art.color(0xF6FAFC))
        Art.fill(&v, shades, Art.color(0xB7CFDF))
    }

    /// The grown bear, collar on, head low, hauling the whole seal home toward the left.
    static func iceHaul(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        Art.group(&n, x: 720, y: H + 104, scale: 1.15) { g in
            bear(&g, head: 1, collar: true, soot: false)
            haulSeal(&g)
        }
    }

    /// The seal at the bear's chest, its fore flipper in the bear's mouth (bear units).
    static func haulSeal(_ g: inout GraphicsContext) {
        Art.group(&g, x: -66, y: -2, rotate: 0.12) { s in seal(&s) }
        let flipper: Path = Art.svg("M-98,-16 C-104,-22 -112,-27 -118,-29 C-120,-26 -116,-22 -110,-17 C-106,-14 -100,-12 -98,-16 Z")
        Kit.solid(&g, flipper, Art.color(0x6E7780), light: 0.2, shade: 0.2)
    }

    /// Deeper ice on a tall window, and the near framing of ice blocks at the bottom corners.
    static func iceForeground(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let bottom: CGFloat = st.hv
        if st.tall > 0.25 {
            pressureRidge(&v, x0: -300, x1: 420, baseY: H + 250, height: 22, seed: 9)
            let lines: Path = Art.svg("M40,\(H + 300) C200,\(H + 290) 360,\(H + 308) 520,\(H + 296) M480,\(H + 330) C600,\(H + 322) 720,\(H + 336) 880,\(H + 326)")
            Art.stroke(&v, lines, Art.color(0xA9C4D6, 0.5), width: 2)
            Kit.flecks(&v, in: CGRect(x: 0, y: H + 220, width: 892, height: bottom - H - 220), count: 40, seed: 29, color: Color.white, radius: 1...2.4)
        }
        iceBlock(&v, x: -20, baseY: bottom + 8, width: 150, height: 54, seed: 1)
        iceBlock(&v, x: 70, baseY: bottom + 14, width: 90, height: 34, seed: 2)
        iceBlock(&v, x: 820, baseY: bottom + 10, width: 140, height: 62, seed: 3)
    }

    /// A near block of sea ice, darker and bluer than the far ice, cropped by the frame.
    static func iceBlock(_ v: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width w: CGFloat, height h: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed)
        let lean: CGFloat = (Kit.rnd(&random) - 0.5) * w * 0.2
        let pts: [CGPoint] = [Kit.pt(x, baseY), Kit.pt(x + w * 0.08 + lean, baseY - h), Kit.pt(x + w * 0.7 + lean, baseY - h * 1.08), Kit.pt(x + w, baseY - h * 0.2), Kit.pt(x + w, baseY)]
        let block: Path = Art.polygon(pts)
        Kit.solid(&v, block, Art.color(0xA8C3D6), light: 0.3, shade: 0.3, rim: 2.4)
        let top: [CGPoint] = [Kit.pt(x + w * 0.08 + lean, baseY - h), Kit.pt(x + w * 0.7 + lean, baseY - h * 1.08), Kit.pt(x + w * 0.66 + lean, baseY - h * 0.86), Kit.pt(x + w * 0.12 + lean, baseY - h * 0.8)]
        Art.fill(&v, Art.polygon(top), Art.color(0xE6F0F6, 0.9))
    }

    // MARK: Scene 4 — the farewell

    /// A cloudless still morning over the sea ice. Low on the right the great bear walks away
    /// toward the blue-white icebergs, the soot streak on his side; at the lower left of the
    /// right half the old woman stands alone at the ice edge with one hand raised.
    static func farewellScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = morning()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 150, st.H - 20 * st.far, 13, light: light)
        let farBergs: [(CGFloat, CGFloat, CGFloat)] = [(70, 40, 14), (196, 30, 10), (300, 52, 18)]
        for berg in farBergs {
            let bx: CGFloat = berg.0 * size.width / 892
            iceberg(&context, x: bx, baseY: st.H + 2, width: berg.1 * st.far, height: berg.2 * st.far, sharp: berg.2 > 12, seed: 8)
        }
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 40 * st.far, bottom: st.H + 3, color: light.haze, alpha: 0.4)
        Art.fill(&context, Art.rect(0, st.H - 1, size.width, 4 * st.fit), Art.color(0x6F95B0, 0.6))
        Kit.ground(&context, width: size.width, top: st.H + 3, bottom: size.height, stops: iceStops())
        Kit.designSpace(&context, st) { v in
            farewellBergs(&v, st)
            Kit.nearSpace(&v, st, anchorX: 560) { n in
                farewellShore(&n, st)
            }
            farewellForeground(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// The icebergs standing far out on the trailing side, and the bear walking toward them.
    static func farewellBergs(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        iceberg(&v, x: 690, baseY: H + 6, width: 70, height: 40, sharp: true, seed: 11)
        iceberg(&v, x: 846, baseY: H + 4, width: 96, height: 52, sharp: true, seed: 12)
        iceberg(&v, x: 770, baseY: H + 2, width: 60, height: 20, sharp: false, seed: 13)
        iceberg(&v, x: 600, baseY: H + 3, width: 46, height: 16, sharp: false, seed: 14)
        pressureRidge(&v, x0: -300, x1: 380, baseY: H + 30, height: 6, seed: 15)
        let walkX: CGFloat = 770
        let walkY: CGFloat = H + 44
        pawPrints(&v, from: Kit.pt(560, H + 136), to: Kit.pt(walkX - 40, walkY + 2), count: 16, size: 5)
        Art.group(&v, x: walkX, y: walkY, scale: 0.46) { g in
            bear(&g, head: 0, collar: true, soot: true, mirrored: true)
        }
    }

    /// The rocky shore at the ice edge and the old woman on it, her hand raised.
    static func farewellShore(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let B: CGFloat = st.hv + 80
        var shore = Path()
        shore.move(to: Kit.pt(250, B))
        shore.addLine(to: Kit.pt(262, H + 172))
        shore.addQuadCurve(to: Kit.pt(420, H + 146), control: Kit.pt(320, H + 146))
        shore.addQuadCurve(to: Kit.pt(600, H + 150), control: Kit.pt(520, H + 138))
        shore.addQuadCurve(to: Kit.pt(680, B), control: Kit.pt(660, H + 170))
        shore.closeSubpath()
        Kit.solid(&n, shore, stops: Kit.stops(0x7E8A92, 0x5E6A72, 0x4E5A62), light: 0.2, shade: 0.22, rim: 2.4)
        Kit.drift(&n, x0: 270, x1: 470, baseY: H + 156, height: 8, bottom: H + 168, snow: true)
        Kit.drift(&n, x0: 540, x1: 640, baseY: H + 160, height: 6, bottom: H + 170, snow: true)
        let edge: Path = Art.svg("M240,\(H + 176) C340,\(H + 140) 520,\(H + 132) 640,\(H + 146) C700,\(H + 152) 760,\(H + 150) 900,\(H + 140)")
        Art.stroke(&n, edge, Art.color(0x9DB9CC, 0.6), width: 2)
        Kit.grass(&n, in: CGRect(x: 300, y: H + 160, width: 320, height: 40), count: 18, seed: 23, color: Art.color(0x6C6A44), height: 6)
        Kit.rock(&n, cx: 600, baseY: H + 170, width: 36, height: 18, color: 0x6E7A82, seed: 24)
        let wx: CGFloat = 520
        let wy: CGFloat = H + 148
        let long: Path = Art.svg("M\(wx + 6),\(wy) C\(wx + 40),\(wy + 6) \(wx + 80),\(wy + 12) \(wx + 112),\(wy + 14) C\(wx + 80),\(wy + 4) \(wx + 40),\(wy - 2) \(wx + 6),\(wy) Z")
        Art.fill(&n, long, ArtStyle.coolShade.opacity(0.14))
        Art.group(&n, x: wx, y: wy, scale: 0.86) { g in
            woman(&g, pose: .wave, mouth: .flat, mirrored: true, sooty: true)
        }
    }

    /// The deeper shore and ice on a tall window, and the near framing.
    static func farewellForeground(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let bottom: CGFloat = st.hv
        if st.tall > 0.25 {
            Kit.drift(&v, x0: 40, x1: 240, baseY: H + 260, height: 16, bottom: bottom + 10, snow: true)
            Kit.pebbles(&v, in: CGRect(x: 300, y: H + 240, width: 320, height: 90), count: 34, seed: 41, color: 0x7A848A)
            Kit.grass(&v, in: CGRect(x: 280, y: H + 230, width: 360, height: 100), count: 26, seed: 43, color: Art.color(0x7E5A48), height: 9)
            pressureRidge(&v, x0: 680, x1: 900, baseY: H + 280, height: 16, seed: 45)
        }
        Kit.rock(&v, cx: 20, baseY: bottom + 16, width: 140, height: 50, color: 0x4E5A62, seed: 47)
        iceBlock(&v, x: 800, baseY: bottom + 10, width: 130, height: 50, seed: 49)
    }
}
