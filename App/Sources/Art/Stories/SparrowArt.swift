import SwiftUI
import OmramoCore

/// Concept art for "The Tongue-Cut Sparrow", drawn in code (round 5; composed from the shared kit).
///
/// The cast and the story's own parts live in `SparrowArt+Cast.swift`; the four folded-phone
/// compositions in `SparrowArt+Folded.swift`; the tap-to-see pictures, the portraits, the
/// faces and the cover in `SparrowArt+Pictures.swift`. This file holds the entry point and the
/// four unfolded scenes.
enum SparrowArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-cottage", .sceneUnfolded): cottageScene(&context, size)
        case ("scene-cottage", .sceneFolded): cottageFolded(&context, size)
        case ("scene-bamboo", .sceneUnfolded): bambooScene(&context, size)
        case ("scene-bamboo", .sceneFolded): bambooFolded(&context, size)
        case ("scene-sparrow-house", .sceneUnfolded): sparrowHouseScene(&context, size)
        case ("scene-sparrow-house", .sceneFolded): sparrowHouseFolded(&context, size)
        case ("scene-road", .sceneUnfolded): roadScene(&context, size)
        case ("scene-road", .sceneFolded): roadFolded(&context, size)
        case ("see-bamboo-grove", .picture): bambooGrovePicture(&context, size)
        case ("see-rice", .picture): ricePicture(&context, size)
        case ("see-guest", .picture): guestPicture(&context, size)
        case ("char-old-man", .portrait): oldManPortrait(&context, size)
        case ("char-sparrow", .portrait): sparrowPortrait(&context, size)
        case ("face-old-man", .face): oldManFace(&context, size)
        case ("face-sparrow", .face): sparrowFace(&context, size)
        case ("face-old-woman", .face): oldWomanFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - scene-cottage

extension SparrowArt {
    /// scene-cottage (unfolded): the thatched farmhouse at the foot of the wooded hills, the
    /// bamboo behind it, the old man sitting on the porch with the Sparrow at his hand; the
    /// washtub and the drying boards at the side. The leading pane is pale morning sky over a
    /// low line of hills.
    static func cottageScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = day()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 96, st.H - 64 * st.far, 24 * st.far, light: light)
        Kit.cloud(&context, 330, 96, scale: 0.8, color: Color.white.opacity(0.6))
        Kit.ranges(&context, width: size.width, horizon: st.H, scale: st.far, light: light, seed: 4)
        Kit.birds(&context, 250, st.H - 58 * st.far, scale: st.far, color: Art.color(0x6E9A8A))
        cottageHill(&context, st)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: meadow())
        dressGround(&context, st, seed: 21, flowers: 0xFFFFFF)

        // The trodden path from the porch toward the reader.
        let earth: Kit.Stops = [(Art.color(0xEAD6A6), 0), (Art.color(0xD9BC84), 1)]
        let reach: CGFloat = st.grow * st.fit
        let doorX: CGFloat = 892 - 292 * st.fit + 76 * reach
        let doorY: CGFloat = st.H + 64 * reach
        Kit.ribbon(&context, nearX: 330, nearY: size.height + 8, nearWidth: 200 * st.far, farX: doorX, farY: doorY, farWidth: 40 * st.far, stops: earth)

        Kit.designSpace(&context, st) { v in
            let Hv: CGFloat = st.Hv
            // Grown about x 600 on a tall window, so the Sparrow stays clear of the hinge.
            Kit.nearSpace(&v, st, anchorX: 600) { n in
                cottageGroup(&n, horizon: Hv)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(ramp.deep), scale: 0.9 * st.far, seed: 6)
        ArtStyle.finish(&context, size)
    }

    /// The wooded hill behind the house, on the trailing side: a soft mound set with cedar
    /// and pine, veiled by the air.
    static func cottageHill(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let rise: CGFloat = 190 * st.far
        let slope: Kit.Stops = [(Art.color(0x9CCFA4), 0), (Art.color(0x77B586), 1)]
        Kit.mound(&context, x0: 420, x1: 1020, baseY: st.H + 4, height: rise, bottom: st.H + 8, stops: slope, crest: 0.62)
        // Trees standing on the slope: (x, how far up the hill 0…1, size).
        let trees: [(CGFloat, CGFloat, CGFloat)] = [
            (760, 0.8, 0.8), (820, 0.76, 0.8), (700, 0.7, 0.85), (870, 0.7, 0.85), (640, 0.62, 0.9),
            (590, 0.48, 0.95), (780, 0.52, 1), (850, 0.46, 1), (690, 0.42, 1), (545, 0.36, 1),
            (610, 0.24, 1.1), (740, 0.26, 1.1), (500, 0.18, 1.05), (830, 0.2, 1.15), (560, 0.12, 1.1),
        ]
        var index: Int = 0
        for tree in trees {
            let footY: CGFloat = st.H - tree.1 * rise
            let tall: CGFloat = 44 * st.far * tree.2
            let pine: Bool = index % 3 != 1
            let tone: Color = tree.1 > 0.5 ? Art.color(0x6BAA84) : Art.color(0x4F9670)
            Kit.farTree(&context, x: tree.0, baseY: footY + 4, height: tall, color: tone, conifer: pine)
            index += 1
        }
        ArtStyle.atmosphere(&context, width: st.w, top: st.H - rise * 1.1, bottom: st.H + 8, color: day().haze, alpha: 0.26)
        Kit.farTrees(&context, x0: 452, x1: 892, baseY: st.H + 3, height: 30 * st.far, count: 12, color: Art.color(0x4F9670), conifer: false, seed: 9)
    }

    /// The trailing ensemble of scene-cottage, in design units: bamboo, the house, the old
    /// man and the Sparrow on the porch, the washing things. The ground at the house is
    /// 62 under the horizon.
    static func cottageGroup(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        let g: CGFloat = Hv + 62
        Kit.bamboo(&n, x: 500, baseY: Hv + 22, width: 400, height: 400, count: 14, palette: Kit.bambooGreens(), seed: 5)
        Art.group(&n, x: 716, y: g, scale: 1.5) { h in
            minka(&h)
        }
        let deckY: CGFloat = g - 39
        // His supper bowl and the bundle he carried home.
        Kit.bowl(&n, cx: 634, baseY: deckY, width: 26, color: 0x3F5E7A, filling: riceWhite)
        Art.group(&n, x: 668, y: g + 8, rotate: 0.1, scale: 1.1) { w in
            Kit.shadow(&w, 4, 0, width: 34, alpha: 0.22)
            firewood(&w)
        }
        // The old man on the porch edge, a few grains of rice in his open hand.
        Kit.shadow(&n, 572, g + 1, width: 56, alpha: 0.24)
        Art.group(&n, x: 590, y: g) { m in
            oldMan(&m, rig: manSitRig(), look: CGPoint(x: -0.7, y: 0.5), mouth: .smile, rice: true)
        }
        // The Sparrow on the porch, reaching up to his hand.
        ArtStyle.contactShadow(&n, 516, deckY + 1, 16, 2.4, alpha: 0.3)
        Art.group(&n, x: 514, y: deckY, scaleX: -1) { s in
            sparrow(&s, pose: .perch, look: CGPoint(x: -0.5, y: -0.6), mirrored: true)
        }
        // Washing day: the tub and the drying boards at the side of the house.
        Art.group(&n, x: 474, y: g + 30, scale: 1.05) { t in
            washtub(&t)
        }
        Art.group(&n, x: 412, y: g + 6) { b in
            dryingBoard(&b, cloth: indigo)
        }
        Art.group(&n, x: 384, y: g + 14, scale: 0.94) { b in
            dryingBoard(&b, cloth: 0xF4F1E6)
        }
        Kit.grassTuft(&n, x: 846, baseY: g + 40, height: 48, color: ramp.shade, seed: 3)
    }
}

// MARK: - scene-bamboo

extension SparrowArt {
    /// A clear shallow stream lying across the whole picture between `top` and `bottom`: soft
    /// winding banks, pale water, ripple marks and a few stones.
    static func stream(_ context: inout GraphicsContext, width w: CGFloat, top: CGFloat, bottom: CGFloat, light: Kit.Light, seed: UInt32) {
        let band: CGFloat = max(1, bottom - top)
        let upper: CGFloat = top + band * 0.1
        let lower: CGFloat = bottom - band * 0.08
        var shape = Path()
        shape.move(to: CGPoint(x: -8, y: upper))
        var x: CGFloat = -8
        var up: Bool = true
        while x < w + 8 {
            let bend: CGFloat = up ? -band * 0.08 : band * 0.16
            shape.addQuadCurve(to: CGPoint(x: x + 112, y: upper), control: CGPoint(x: x + 56, y: upper + bend))
            x += 112
            up.toggle()
        }
        shape.addLine(to: CGPoint(x: x, y: lower))
        while x > -8 {
            let bend: CGFloat = up ? band * 0.12 : -band * 0.14
            shape.addQuadCurve(to: CGPoint(x: x - 140, y: lower), control: CGPoint(x: x - 70, y: lower + bend))
            x -= 140
            up.toggle()
        }
        shape.closeSubpath()
        // The far bank's cut edge, a little above the water.
        let lip = shape.applying(CGAffineTransform(translationX: 0, y: -3.5))
        Art.fill(&context, lip, Art.color(ramp.shade, 0.6))
        let wash: Kit.Stops = [(Art.color(0xD6F2EC), 0), (Art.color(0x9BD8D2), 0.5), (Art.color(0x66B8B8), 1)]
        Art.fillLinear(&context, shape, wash, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: bottom))
        let lie: Kit.Stops = [(light.glow.opacity(0.4), 0), (light.glow.opacity(0), 1)]
        Art.clipped(&context, to: shape) { g in
            Art.fillLinear(&g, Art.rect(0, top, w, band * 0.5), lie, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: top + band * 0.5))
            Kit.rippleMarks(&g, x0: 0, x1: w, y0: top + 4, y1: bottom, count: 46, seed: seed, color: Color.white, alpha: 0.5)
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: top, width: w, height: band), seed: seed &+ 2)
        }
        // Stones in the stream: (x, how far down the band, width).
        let stones: [(CGFloat, CGFloat, CGFloat)] = [(150, 0.62, 40), (318, 0.4, 28), (612, 0.7, 46), (792, 0.46, 32), (402, 0.8, 24)]
        var index: UInt32 = 0
        for stone in stones {
            let sy: CGFloat = top + band * stone.1
            let sw: CGFloat = stone.2 * max(0.7, band / 60)
            Kit.rock(&context, cx: stone.0, baseY: sy, width: sw, height: sw * 0.5, color: 0x9FA39A, seed: seed &+ index)
            Kit.ripples(&context, stone.0, sy + 1, sw * 1.2, count: 2, color: Color.white, opacity: 0.6)
            index += 1
        }
    }

    /// scene-bamboo (unfolded): tall bamboo on the trailing side, the old man walking and
    /// calling on the far bank of a clear stream, the white heron standing in the water. The
    /// leading side opens to pale sky and far hills.
    static func bambooScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = day()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 290, 112, scale: 0.9, color: Color.white.opacity(0.55))
        Kit.ranges(&context, width: size.width, horizon: st.H, scale: st.far, light: light, seed: 11)
        // The grove seen through the air: hazy canes behind everything on the trailing side,
        // and a low clump far off on the leading side.
        Kit.bamboo(&context, x: 468, baseY: st.H + 4, width: 440, height: 300 * st.far, count: 16, palette: farBamboo(), seed: 14)
        Kit.bamboo(&context, x: 24, baseY: st.H + 4, width: 150, height: 60 * st.far, count: 7, palette: farBamboo(), seed: 15)
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 300 * st.far, bottom: st.H + 8, color: light.haze, alpha: 0.2)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: meadow())
        dressGround(&context, st, seed: 33, flowers: 0xFFF3B0)

        let streamTop: CGFloat = st.H + st.depth * 0.34
        let streamBottom: CGFloat = st.H + st.depth * 0.7
        stream(&context, width: size.width, top: streamTop, bottom: streamBottom, light: light, seed: 41)
        Kit.reeds(&context, x: 372, baseY: streamTop + 6, count: 6, height: 38 * st.far, seed: 5, color: 0x4E9A5B)
        Kit.reeds(&context, x: 70, baseY: streamBottom + 4, count: 7, height: 46 * st.far, seed: 9, color: 0x3F7D56)

        Kit.designSpace(&context, st) { v in
            let Hv: CGFloat = st.Hv
            // Depths under the horizon, in design units, that land on the stream when grown.
            let dv: CGFloat = st.depth / st.fit / st.grow
            Kit.nearSpace(&v, st, anchorX: 690) { n in
                bambooGroup(&n, horizon: Hv, depth: dv)
            }
        }
        ArtStyle.finish(&context, size)
    }

    /// The trailing ensemble of scene-bamboo, in design units. `dv` is the depth of the
    /// ground: the far bank is at 0.2 of it, the middle of the stream at 0.52.
    static func bambooGroup(_ n: inout GraphicsContext, horizon Hv: CGFloat, depth dv: CGFloat) {
        let bank: CGFloat = Hv + dv * 0.2
        let wade: CGFloat = Hv + dv * 0.52
        Kit.bamboo(&n, x: 556, baseY: Hv + dv * 0.08, width: 340, height: Hv + 40, count: 9, palette: Kit.bambooGreens(), seed: 2)
        Kit.grass(&n, in: CGRect(x: 540, y: Hv + 4, width: 352, height: dv * 0.2), count: 26, seed: 8, color: Art.color(ramp.shade, 0.7), height: 9)
        // The old man in his straw sandals, a hand to his mouth, calling for his friend.
        Kit.shadow(&n, 694, bank + 1, width: 84, alpha: 0.26)
        Art.group(&n, x: 690, y: bank, scale: 1.25) { m in
            oldMan(&m, rig: manCallRig(), look: CGPoint(x: -0.8, y: -0.2), mouth: .open)
        }
        // The white heron, still as a post in the shallows, one eye on him.
        Art.group(&n, x: 545, y: wade, scaleX: -1) { b in
            heron(&b, mirrored: true)
        }
        Kit.ripples(&n, 545, wade + 1, 40, count: 2, color: Color.white, opacity: 0.7)
        // Near canes on the trailing edge: darker, cropped by the frame.
        Kit.bamboo(&n, x: 836, baseY: Hv + dv * 0.3, width: 76, height: Hv + 130, count: 3, palette: hillGreens(), seed: 12)
        Kit.grassTuft(&n, x: 842, baseY: Hv + dv * 0.32, height: 44, color: ramp.deep, seed: 4)
    }
}

// MARK: - scene-sparrow-house

extension SparrowArt {
    /// scene-sparrow-house (unfolded): the small house of pale new wood among the bamboo, the
    /// Sparrow on the post of her little gate, her family bowing on the porch beside the two
    /// wicker boxes — one big, one small — and a tray of tea. The leading pane is calm pale
    /// sky above low bamboo.
    static func sparrowHouseScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let light = day()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 150, st.H - 40 * st.far, 22 * st.far, light: light)
        Kit.cloud(&context, 260, 104, scale: 0.75, color: Color.white.opacity(0.55))
        Kit.ranges(&context, width: size.width, horizon: st.H, scale: st.far, light: light, seed: 23)
        Kit.bamboo(&context, x: 470, baseY: st.H + 4, width: 430, height: 280 * st.far, count: 15, palette: farBamboo(), seed: 18)
        Kit.bamboo(&context, x: 20, baseY: st.H + 4, width: 230, height: 58 * st.far, count: 10, palette: farBamboo(), seed: 21)
        Kit.bamboo(&context, x: 292, baseY: st.H + 4, width: 120, height: 42 * st.far, count: 6, palette: farBamboo(), seed: 22)
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 280 * st.far, bottom: st.H + 8, color: light.haze, alpha: 0.2)
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: meadow())
        dressGround(&context, st, seed: 52, flowers: 0xFFD9E4)

        // The path through the grass up to the gate.
        let earth: Kit.Stops = [(Art.color(0xEAD6A6), 0), (Art.color(0xD9BC84), 1)]
        let reach: CGFloat = st.grow * st.fit
        let gateX: CGFloat = 892 - 332 * st.fit - 20 * reach
        let gateY: CGFloat = st.H + 86 * reach
        Kit.ribbon(&context, nearX: 250, nearY: size.height + 8, nearWidth: 190 * st.far, farX: gateX, farY: gateY, farWidth: 46 * st.far, stops: earth)

        Kit.designSpace(&context, st) { v in
            let Hv: CGFloat = st.Hv
            Kit.nearSpace(&v, st, anchorX: 560) { n in
                sparrowHouseGroup(&n, horizon: Hv)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(ramp.deep), scale: 0.9 * st.far, seed: 14)
        ArtStyle.finish(&context, size)
    }

    /// The trailing ensemble of scene-sparrow-house, in design units; the ground at the house
    /// is 58 under the horizon and the porch deck 34 above that.
    static func sparrowHouseGroup(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        let g: CGFloat = Hv + 58
        let deckY: CGFloat = g - 34
        Kit.bamboo(&n, x: 520, baseY: Hv + 20, width: 380, height: 420, count: 13, palette: Kit.bambooGreens(), seed: 7)
        Art.group(&n, x: 712, y: g, scale: 1.7) { h in
            sparrowHouse(&h)
        }
        // One of the family keeps watch on the roof; two young ones dance in the air.
        Art.group(&n, x: 742, y: g - 222, scale: 0.8) { b in
            cousin(&b, pose: .sing)
        }
        Art.group(&n, x: 622, y: deckY - 84, rotate: -0.2, scale: 0.75) { b in
            cousin(&b, pose: .fly)
        }
        Art.group(&n, x: 846, y: deckY - 104, rotate: 0.15, scale: 0.7, scaleX: -1) { b in
            cousin(&b, pose: .fly, mirrored: true)
        }
        // The two gifts, side by side on the porch: one big and heavy, one small and light.
        tsuzura(&n, cx: 694, baseY: deckY, width: 98, height: 94)
        tsuzura(&n, cx: 778, baseY: deckY, width: 50, height: 46)
        Art.group(&n, x: 838, y: deckY, scale: 1.05) { t in
            teaTray(&t)
        }
        // The family bowing in a row.
        let row: [CGFloat] = [584, 612]
        for x in row {
            ArtStyle.contactShadow(&n, x + 2, deckY + 1, 13, 2, alpha: 0.28)
            Art.group(&n, x: x, y: deckY, scale: 0.82) { b in
                cousin(&b, pose: .peck)
            }
        }
        // The little gate, and the Sparrow herself on its post: "Come in, dear friend!"
        Art.group(&n, x: 540, y: g + 28, scale: 1.2) { w in
            wicket(&w)
        }
        Art.group(&n, x: 509, y: g - 27, scale: 1.3) { s in
            sparrow(&s, pose: .perch, look: CGPoint(x: -0.6, y: 0), wings: true)
        }
        Kit.grassTuft(&n, x: 470, baseY: g + 36, height: 40, color: ramp.shade, seed: 6)
        Kit.grassTuft(&n, x: 600, baseY: g + 40, height: 34, color: 0x4E9A5B, seed: 9)
    }
}

// MARK: - scene-road

extension SparrowArt {
    /// scene-road (unfolded): the hill road in the early evening under a pale pink sky; the
    /// old woman bent under the very big wicker box, a cloud pine by the road, and — as a hint
    /// of what is inside — a few round bees and one fat toad. Home is a far roof on the
    /// leading side.
    static func roadScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let light = evening()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 176, st.H - 24 * st.far, 20 * st.far, light: light)
        Kit.cloud(&context, 262, 118, scale: 0.8, color: Art.color(0xFFF0F0, 0.7))
        Kit.cloud(&context, 596, 160, scale: 0.6, color: Art.color(0xFFE6E0, 0.6))
        Kit.ranges(&context, width: size.width, horizon: st.H, scale: st.far, light: light, seed: 31)
        // One nearer hill on the trailing side, and home far away on the leading side.
        let slope: Kit.Stops = [(Art.color(0xBCC4A6), 0), (Art.color(0xA4B592), 1)]
        Kit.mound(&context, x0: 500, x1: 1040, baseY: st.H + 4, height: 118 * st.far, bottom: st.H + 8, stops: slope, crest: 0.7)
        Kit.farTrees(&context, x0: 470, x1: 892, baseY: st.H + 3, height: 28 * st.far, count: 10, color: Art.color(0x86A088), conifer: true, seed: 3)
        Kit.farHouse(&context, cx: 118, baseY: st.H + 2, width: 34 * st.far, height: 24 * st.far, wall: Art.color(0xE6D6C4), roof: Art.color(0xC2A27A))
        Kit.farTrees(&context, x0: 60, x1: 180, baseY: st.H + 3, height: 20 * st.far, count: 5, color: Art.color(0x9CB09A), conifer: false, seed: 6)
        ArtStyle.atmosphere(&context, width: size.width, top: st.H - 130 * st.far, bottom: st.H + 8, color: light.haze, alpha: 0.24)
        let field: Kit.Stops = [(Art.color(0xC6D29C), 0), (Art.color(0xA6BC86), 0.4), (Art.color(0x86A277), 1)]
        Kit.ground(&context, width: size.width, top: st.H, bottom: size.height, stops: field)
        dressGround(&context, st, seed: 71, flowers: 0xFFF3B0)

        // The pale earth road winding down toward the reader.
        let earth: Kit.Stops = [(Art.color(0xF0DCC0), 0), (Art.color(0xE2C49A), 0.5), (Art.color(0xD2AE84), 1)]
        let farX: CGFloat = 892 - 92 * st.fit
        Kit.ribbon(&context, nearX: 400, nearY: size.height + 8, nearWidth: 260 * st.far, farX: farX, farY: st.H + 5, farWidth: 24 * st.far, stops: earth)
        let roadside = CGRect(x: 240, y: st.H + st.depth * 0.5, width: 420, height: st.depth * 0.45)
        Kit.pebbles(&context, in: roadside, count: 14, seed: 17, color: 0xB8A892)

        Kit.designSpace(&context, st) { v in
            let Hv: CGFloat = st.Hv
            Kit.nearSpace(&v, st, anchorX: 650) { n in
                roadGroup(&n, horizon: Hv)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x3F6B56), scale: 0.9 * st.far, seed: 31)
        ArtStyle.finish(&context, size)
    }

    /// The trailing ensemble of scene-road, in design units: the pine, the old woman under
    /// her load on the road 74 under the horizon, the bees and the toad.
    static func roadGroup(_ n: inout GraphicsContext, horizon Hv: CGFloat) {
        let g: CGFloat = Hv + 74
        Kit.cloudPine(&n, x: 826, baseY: Hv + 36, height: 330, palette: Kit.pineGreens(), seed: 4)
        Kit.rock(&n, cx: 782, baseY: Hv + 62, width: 52, height: 26, color: 0xA8A090, seed: 8)
        Kit.grassTuft(&n, x: 760, baseY: Hv + 66, height: 36, color: 0x5F8A66, seed: 2)
        // The old woman, puffing along under the big box.
        Kit.shadow(&n, 668, g + 2, width: 170, alpha: 0.26)
        Art.group(&n, x: 640, y: g, scale: 1.2) { w in
            oldWomanLoaded(&w, look: CGPoint(x: -0.6, y: 0.3), mouth: .oh)
        }
        // Her puffs of breath.
        var puffs = Path()
        puffs.addPath(Art.ellipse(562, g - 132, 7, 5))
        puffs.addPath(Art.ellipse(548, g - 140, 5, 3.6))
        puffs.addPath(Art.ellipse(538, g - 147, 3.4, 2.4))
        Art.fill(&n, puffs, Color.white.opacity(0.75))
        // A hint of what is inside: three round bees about the lid …
        let bees: [(CGFloat, CGFloat, CGFloat)] = [(746, 250, 1), (778, 218, -1), (716, 268, 1)]
        for bee in bees {
            Art.group(&n, x: bee.0, y: g - bee.1, scale: 1.5, scaleX: bee.2) { b in
                Kit.critterBee(&b)
            }
        }
        let trails = Art.svg("M756,-240 q8,10 2,18 M786,-208 q-9,8 -4,18")
        Art.stroke(&n, trails.applying(CGAffineTransform(translationX: 0, y: g)), Art.color(0x8A7A6A, 0.5), width: 1, dash: [2, 3])
        // … and one fat brown toad waiting by the roadside.
        Kit.shadow(&n, 550, g + 34, width: 48, alpha: 0.24)
        Art.group(&n, x: 548, y: g + 34, scale: 1.6) { f in
            Kit.critterFrog(&f, body: toadBrown)
        }
        Kit.grassTuft(&n, x: 508, baseY: g + 44, height: 30, color: 0x5F8A66, seed: 7)
    }
}
