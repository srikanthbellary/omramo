import SwiftUI
import OmramoCore

// Angkor Wat in the soft warm morning: our own drawing (no photograph, nothing traced).
// Five lotus-bud towers (the middle one tallest) on a stepped, galleried temple of grey-gold
// sandstone, a long stone causeway with a few tiny walkers, the whole temple mirrored in a wide
// pool with lily pads, and sugar palms on either side. Card background #2C3A22.

extension LandmarkArt {
    /// angkor-wat: the five lotus-bud towers over the galleried temple, mirrored in the lily
    /// pool, sugar palms on either side, on a soft hazy morning.
    static func paintAngkor(_ context: inout GraphicsContext) {
        angkorSky(&context)
        angkorFarTrees(&context)
        angkorTemple(&context)
        // Warm morning light lying on the stone, from the upper left.
        Art.glow(&context, 170, 120, 150, Art.color(0xFFE4B4), alpha: 0.16)
        angkorCauseway(&context)
        angkorPool(&context)
        angkorPalms(&context)
        angkorWalkers(&context)
        angkorNear(&context)
        angkorFinish(&context)
    }

    // MARK: Stone

    /// Grey-gold sandstone in the one light: warm on the left, cooler grey to the right.
    /// `roof` gives the darker, weathered stone of the roofs.
    static func angkorStone(_ context: inout GraphicsContext, _ path: Path, roof: Bool = false) {
        let wall: [(Color, CGFloat)] = [(Art.color(0xEEDAB0), 0), (Art.color(0xCFB98F), 0.5), (Art.color(0xA2947F), 1)]
        let weathered: [(Color, CGFloat)] = [(Art.color(0xD8C9AA), 0), (Art.color(0xB2A38D), 0.5), (Art.color(0x877C74), 1)]
        fillHorizontal(&context, path, roof ? weathered : wall, from: 70, to: 362)
    }

    // MARK: Sky and far plane

    static func angkorSky(_ context: inout GraphicsContext) {
        let sky: [(Color, CGFloat)] = [
            (Art.color(0x92BEDA), 0),
            (Art.color(0xCFE0E0), 0.2),
            (Art.color(0xF8E2BC), 0.4),
            (Art.color(0xF8DDB2), 0.5),
            (Art.color(0xF8DDB2), 1),
        ]
        backdrop(&context, sky)
        // The low morning sun, off to the upper left, softened by the haze.
        Art.glow(&context, 96, 150, 130, Art.color(0xFFEAC2), alpha: 0.4)
        var clouds = cloudBand(250, 52, width: 120, height: 10)
        clouds.addPath(cloudBand(330, 78, width: 90, height: 7))
        clouds.addPath(cloudBand(120, 92, width: 70, height: 5))
        Art.fill(&context, clouds, Art.color(0xFFF2DC, 0.45))
    }

    /// The far line of forest behind the temple, veiled with the morning haze.
    static func angkorFarTrees(_ context: inout GraphicsContext) {
        let far = canopy(from: -24, to: 456, baseY: 194, height: 20, bump: 24, depth: 14, seed: 23)
        Art.fill(&context, far, Art.color(0x8FA486))
        let nearer = canopy(from: -24, to: 456, baseY: 200, height: 12, bump: 18, depth: 10, seed: 41)
        Art.fill(&context, nearer, Art.color(0x768F6E))
        haze(&context, top: 150, bottom: 206, hex: 0xF6DDB4, alpha: 0.5)
    }

    // MARK: Parts of the temple

    /// A lotus-bud tower outline standing on `baseY`: straight lower sides, then swelling a
    /// little before curving in to a point.
    static func angkorBud(_ cx: CGFloat, _ baseY: CGFloat, halfWidth hw: CGFloat, height h: CGFloat) -> Path {
        let shoulderY: CGFloat = baseY - h * 0.22
        let topY: CGFloat = baseY - h
        let lowY: CGFloat = baseY - h * 0.62
        let highY: CGFloat = baseY - h * 0.9
        let swell: CGFloat = hw * 1.1
        let neck: CGFloat = hw * 0.35
        var path = Path()
        path.move(to: pt(cx - hw, baseY))
        path.addLine(to: pt(cx - hw, shoulderY))
        path.addCurve(to: pt(cx, topY), control1: pt(cx - swell, lowY), control2: pt(cx - neck, highY))
        path.addCurve(to: pt(cx + hw, shoulderY), control1: pt(cx + neck, highY), control2: pt(cx + swell, lowY))
        path.addLine(to: pt(cx + hw, baseY))
        path.closeSubpath()
        return path
    }

    /// One tower: the bud, modelled, with its stacked tiers and ribs and a small finial.
    static func angkorTower(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, halfWidth hw: CGFloat, height h: CGFloat) {
        let bud = angkorBud(cx, baseY, halfWidth: hw, height: h)
        let stops: [(Color, CGFloat)] = [
            (Art.color(0xF2DEB4), 0),
            (Art.color(0xD4BE96), 0.45),
            (Art.color(0x9C8F82), 1),
        ]
        fillHorizontal(&context, bud, stops, from: cx - hw, to: cx + hw)
        model(&context, bud, light: 0.2, shade: 0.2, rim: 0.5)

        // The tiers of the bud, each a carved band, and the ribs that run up its faces.
        let shoulderY: CGFloat = baseY - h * 0.22
        let span: CGFloat = h * 0.72
        let reach: CGFloat = hw * 1.2
        var tiers = Path()
        var tierLights = Path()
        for index in 0..<8 {
            let y: CGFloat = shoulderY - span * CGFloat(index) / 8
            tiers.move(to: pt(cx - reach, y))
            tiers.addLine(to: pt(cx + reach, y))
            tierLights.move(to: pt(cx - reach, y - 1.2))
            tierLights.addLine(to: pt(cx + reach * 0.2, y - 1.2))
        }
        let topY: CGFloat = baseY - h
        var ribs = Art.line(cx, baseY, cx, topY + h * 0.08)
        ribs.move(to: pt(cx - hw * 0.55, baseY))
        ribs.addQuadCurve(to: pt(cx - hw * 0.12, topY + h * 0.16), control: pt(cx - hw * 0.68, baseY - h * 0.6))
        ribs.move(to: pt(cx + hw * 0.55, baseY))
        ribs.addQuadCurve(to: pt(cx + hw * 0.12, topY + h * 0.16), control: pt(cx + hw * 0.68, baseY - h * 0.6))
        Art.clipped(&context, to: bud) { g in
            Art.stroke(&g, tiers, Art.color(0x7A6C62, 0.45), width: 0.8, cap: .butt)
            Art.stroke(&g, tierLights, Art.color(0xFFE8C0, 0.35), width: 0.6, cap: .butt)
            Art.stroke(&g, ribs, Art.color(0x7A6C62, 0.25), width: 0.7)
        }
        Art.stroke(&context, Art.line(cx, topY, cx, topY - 3), Art.color(0x9C8F82), width: 1)
        // The tower's own little plinth.
        let plinth = Art.rect(cx - hw - 2, baseY - 4, hw * 2 + 4, 4)
        angkorStone(&context, plinth)
        Art.stroke(&context, Art.line(cx - hw - 2, baseY - 3.6, cx + hw + 2, baseY - 3.6), Art.color(0xFFE8C0, 0.6), width: 0.7, cap: .butt)
    }

    /// A long gallery: a wall with its row of dark bays, under a sloping stone roof.
    static func angkorGallery(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, bottom: CGFloat, roof: CGFloat) {
        let width: CGFloat = x1 - x0
        let height: CGFloat = bottom - top
        let wall = Art.rect(x0, top, width, height)
        angkorStone(&context, wall)

        // The colonnade: a dark bay between every pair of pillars.
        var bays = Path()
        let count: Int = max(1, Int(width / 9))
        let step: CGFloat = width / CGFloat(count)
        let bayH: CGFloat = height * 0.62
        let bayY: CGFloat = top + height * 0.22
        let bayW: CGFloat = step * 0.42
        for index in 0..<count {
            let bx: CGFloat = x0 + step * CGFloat(index) + step * 0.29
            bays.addRect(CGRect(x: bx, y: bayY, width: bayW, height: bayH))
        }
        Art.fill(&context, bays, Art.color(0x5A5064, 0.55))
        Art.fill(&context, Art.rect(x0, top, width, 2.4), ArtStyle.coolShade.opacity(0.24))
        Art.stroke(&context, Art.line(x0, bottom - 0.5, x1, bottom - 0.5), Art.color(0x8A7C6A, 0.6), width: 1, cap: .butt)

        // The roof leans back from the wall top; its ridge catches the light.
        let lean: CGFloat = (top - roof) * 0.9
        let corners: [CGPoint] = [pt(x0 - 3, top), pt(x1 + 3, top), pt(x1 - lean, roof), pt(x0 + lean, roof)]
        let roofPath = Art.polygon(corners)
        angkorStone(&context, roofPath, roof: true)
        model(&context, roofPath, light: 0.18, shade: 0.16)
        let midY: CGFloat = (top + roof) / 2
        let ridgeLight = Art.line(x0 + lean, roof + 0.4, x1 - lean, roof + 0.4)
        Art.stroke(&context, ridgeLight, Art.color(0xFFE8C0, 0.7), width: 0.9, cap: .butt)
        Art.stroke(&context, Art.line(x0, midY, x1, midY), Art.color(0x7A6E66, 0.35), width: 0.6, cap: .butt)
    }

    /// A stepped base under a gallery, with a stair climbing its middle.
    static func angkorPlinth(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, bottom: CGFloat, stairWidth: CGFloat) {
        let height: CGFloat = bottom - top
        let body = Art.rect(x0, top, x1 - x0, height)
        angkorStone(&context, body)
        model(&context, body, light: 0.12, shade: 0.14)
        var mouldings = Path()
        for index in 1..<4 {
            let y: CGFloat = top + height * CGFloat(index) / 4
            mouldings.move(to: pt(x0, y))
            mouldings.addLine(to: pt(x1, y))
        }
        Art.stroke(&context, mouldings, Art.color(0x8A7C6A, 0.45), width: 0.7, cap: .butt)
        Art.stroke(&context, Art.line(x0, top + 0.4, x1, top + 0.4), Art.color(0xFFE8C0, 0.7), width: 0.8, cap: .butt)

        // The stair: a little narrower at the top, its treads lit along their edges.
        let cx: CGFloat = (x0 + x1) / 2
        let half: CGFloat = stairWidth / 2
        let narrow: CGFloat = half * 0.78
        let stairCorners: [CGPoint] = [pt(cx - narrow, top), pt(cx + narrow, top), pt(cx + half, bottom), pt(cx - half, bottom)]
        let stair = Art.polygon(stairCorners)
        angkorStone(&context, stair)
        Art.fill(&context, stair, ArtStyle.coolShade.opacity(0.1))
        var treads = Path()
        let count: Int = max(2, Int(height / 2.2))
        for index in 1..<count {
            let y: CGFloat = top + height * CGFloat(index) / CGFloat(count)
            treads.move(to: pt(cx - half, y))
            treads.addLine(to: pt(cx + half, y))
        }
        Art.clipped(&context, to: stair) { g in
            Art.stroke(&g, treads, Art.color(0x7A6C62, 0.5), width: 0.6, cap: .butt)
        }
        var cheeks = Art.line(cx - narrow, top, cx - half, bottom)
        cheeks.move(to: pt(cx + narrow, top))
        cheeks.addLine(to: pt(cx + half, bottom))
        Art.stroke(&context, cheeks, Art.color(0x8A7C6A, 0.6), width: 0.9)
    }

    /// A gate or corner pavilion: a small body with its doorway, three stepped roofs and a
    /// little bud on top.
    static func angkorPavilion(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, halfWidth hw: CGFloat, height h: CGFloat) {
        let bodyH: CGFloat = h * 0.4
        let bodyTop: CGFloat = baseY - bodyH
        let body = Art.rect(cx - hw, bodyTop, hw * 2, bodyH)
        angkorStone(&context, body)
        model(&context, body, light: 0.14, shade: 0.16)
        let door = Art.rect(cx - hw * 0.22, baseY - bodyH * 0.8, hw * 0.44, bodyH * 0.8)
        Art.fill(&context, door, Art.color(0x4E4658, 0.75))

        var roofs = Path()
        for index in 0..<3 {
            let step: CGFloat = CGFloat(index)
            let w: CGFloat = hw * (1.1 - step * 0.25)
            let y0: CGFloat = bodyTop - h * 0.17 * step
            let y1: CGFloat = y0 - h * 0.15
            let corners: [CGPoint] = [pt(cx - w, y0), pt(cx + w, y0), pt(cx + w * 0.8, y1), pt(cx - w * 0.8, y1)]
            roofs.addPath(Art.polygon(corners))
        }
        angkorStone(&context, roofs, roof: true)
        model(&context, roofs, light: 0.2, shade: 0.18)
        let budBase: CGFloat = bodyTop - h * 0.49
        angkorTower(&context, cx: cx, baseY: budBase + 3, halfWidth: hw * 0.3, height: h * 0.16)
    }

    // MARK: The temple

    /// The whole temple, back to front: towers, then the three galleried levels.
    /// Drawn once in place and once mirrored in the pool.
    static func angkorTemple(_ context: inout GraphicsContext) {
        ArtStyle.contactShadow(&context, 216, 202, 160, 5, alpha: 0.22)
        angkorTower(&context, cx: 182, baseY: 114, halfWidth: 12, height: 56)
        angkorTower(&context, cx: 250, baseY: 114, halfWidth: 12, height: 56)
        angkorTower(&context, cx: 154, baseY: 114, halfWidth: 11, height: 48)
        angkorTower(&context, cx: 278, baseY: 114, halfWidth: 11, height: 48)
        angkorTower(&context, cx: 216, baseY: 116, halfWidth: 18, height: 88)

        // The top level, high on its steep base.
        angkorGallery(&context, x0: 140, x1: 292, top: 108, bottom: 118, roof: 102)
        angkorPlinth(&context, x0: 134, x1: 298, top: 118, bottom: 137, stairWidth: 18)

        // The middle level and its corner pavilions.
        angkorGallery(&context, x0: 106, x1: 326, top: 144, bottom: 156, roof: 137)
        angkorPlinth(&context, x0: 100, x1: 332, top: 156, bottom: 170, stairWidth: 22)
        angkorPavilion(&context, cx: 112, baseY: 144, halfWidth: 9, height: 16)
        angkorPavilion(&context, cx: 320, baseY: 144, halfWidth: 9, height: 16)

        // The long outer gallery, its corner pavilions and the great gate in the middle.
        angkorGallery(&context, x0: 72, x1: 360, top: 178, bottom: 192, roof: 170)
        angkorPlinth(&context, x0: 66, x1: 366, top: 192, bottom: 202, stairWidth: 28)
        angkorPavilion(&context, cx: 80, baseY: 178, halfWidth: 10, height: 18)
        angkorPavilion(&context, cx: 352, baseY: 178, halfWidth: 10, height: 18)
        angkorPavilion(&context, cx: 216, baseY: 192, halfWidth: 22, height: 40)
    }

    // MARK: Causeway and pool

    /// The far bank of the pool and the long stone causeway along it, with its low rail.
    static func angkorCauseway(_ context: inout GraphicsContext) {
        let bank = Art.rect(-24, 202, unitWidth + 48, 10)
        let earth: [(Color, CGFloat)] = [
            (Art.color(0xCDBB92), 0),
            (Art.color(0x8E8A62), 1),
        ]
        fillVertical(&context, bank, earth, from: 202, to: 212)
        let deck = Art.rect(30, 203, 372, 4)
        angkorStone(&context, deck)
        let face = Art.rect(30, 207, 372, 4)
        Art.fill(&context, face, Art.color(0xA2947F))
        Art.fill(&context, face, ArtStyle.coolShade.opacity(0.16))
        Art.stroke(&context, Art.line(30, 203.3, 402, 203.3), Art.color(0xFFE8C0, 0.65), width: 0.7, cap: .butt)

        var rail = Art.line(30, 201.4, 402, 201.4)
        var x: CGFloat = 34
        while x < 400 {
            rail.move(to: pt(x, 201.4))
            rail.addLine(to: pt(x, 203))
            x += 12
        }
        Art.stroke(&context, rail, Art.color(0x9C8F82, 0.85), width: 0.8)
        Art.stroke(&context, Art.line(-24, 211.6, 456, 211.6), ArtStyle.coolShade.opacity(0.2), width: 1, cap: .butt)
    }

    /// The wide pool: the temple mirrored in it, ripples, and lily pads.
    static func angkorPool(_ context: inout GraphicsContext) {
        let pool = Art.rect(-24, 212, unitWidth + 48, 124)
        let water: [(Color, CGFloat)] = [
            (Art.color(0xEAE2C8), 0),
            (Art.color(0xB6C6BA), 0.3),
            (Art.color(0x80A08C), 0.7),
            (Art.color(0x5C7C64), 1),
        ]
        fillVertical(&context, pool, water, from: 212, to: 336)
        let veil: [(Color, CGFloat)] = [
            (Art.color(0xEAE2C8, 0.1), 0),
            (Art.color(0x9CB4A4, 0.3), 0.6),
            (Art.color(0x5C7C64, 0.5), 1),
        ]
        Art.clipped(&context, to: pool) { g in
            // Mirrored about y = 207, the foot of the causeway.
            Art.group(&g, y: 414, rotate: CGFloat.pi, scaleX: -1, opacity: 0.42) { m in
                angkorTemple(&m)
            }
            fillVertical(&g, pool, veil, from: 212, to: 336)
            let wide = CGRect(x: 0, y: 216, width: unitWidth, height: 110)
            ripples(&g, in: wide, count: 60, seed: 5, color: Art.color(0xFFF4DC, 0.5), width: 0.8, length: 4...14)
            let low = CGRect(x: 0, y: 270, width: unitWidth, height: 60)
            ripples(&g, in: low, count: 24, seed: 9, color: Art.color(0x46644E, 0.35), width: 0.9, length: 8...18)
        }
        angkorPads(&context)
    }

    /// A lily pad seen low across the water: a flat ellipse with its notch cut out.
    static func angkorPad(_ cx: CGFloat, _ cy: CGFloat, _ rx: CGFloat, _ ry: CGFloat, notch: CGFloat) -> Path {
        var path = Path()
        path.move(to: pt(cx, cy))
        let steps = 18
        let sweep: CGFloat = 2 * CGFloat.pi - 0.7
        for index in 0...steps {
            let t: CGFloat = CGFloat(index) / CGFloat(steps)
            let angle: CGFloat = notch + 0.35 + t * sweep
            let x: CGFloat = cx + cos(angle) * rx
            let y: CGFloat = cy + sin(angle) * ry
            path.addLine(to: pt(x, y))
        }
        path.closeSubpath()
        return path
    }

    static func angkorPads(_ context: inout GraphicsContext) {
        let pads: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (40, 252, 6, 0.4), (58, 258, 7, 2.1), (30, 270, 9, 4.0), (76, 276, 8, 1.2),
            (48, 292, 11, 5.0), (96, 300, 10, 3.0), (22, 314, 13, 0.8), (70, 322, 14, 2.6),
            (330, 262, 7, 3.4), (356, 254, 6, 1.0), (376, 272, 9, 5.5), (344, 286, 10, 0.2),
            (396, 296, 12, 2.2), (318, 310, 12, 4.4), (366, 322, 14, 1.6), (410, 330, 13, 3.8),
            (180, 318, 9, 2.0), (236, 326, 10, 5.2),
        ]
        var undersides = Path()
        var leaves = Path()
        var lights = Path()
        for pad in pads {
            let ry: CGFloat = pad.2 * 0.36
            undersides.addPath(angkorPad(pad.0 + 0.6, pad.1 + 0.9, pad.2, ry, notch: pad.3))
            leaves.addPath(angkorPad(pad.0, pad.1, pad.2, ry, notch: pad.3))
            let lx: CGFloat = pad.0 - pad.2 * 0.2
            let ly: CGFloat = pad.1 - ry * 0.2
            lights.addPath(angkorPad(lx, ly, pad.2 * 0.6, ry * 0.55, notch: pad.3))
        }
        Art.fill(&context, undersides, ArtStyle.coolShade.opacity(0.25))
        Art.fill(&context, leaves, Art.color(0x4E7A40))
        Art.fill(&context, lights, Art.color(0x9CBC6A, 0.45))

        // A few pink lotus flowers held just above their pads.
        let flowers: [(CGFloat, CGFloat)] = [(58, 255), (96, 296), (344, 282), (366, 317), (236, 322)]
        var petals = Path()
        var petalLights = Path()
        let up: CGFloat = -CGFloat.pi / 2
        for flower in flowers {
            petals.addPath(leaf(flower.0, flower.1, length: 5, width: 1.8, angle: up))
            petals.addPath(leaf(flower.0, flower.1, length: 4.2, width: 1.6, angle: up - 0.55))
            petals.addPath(leaf(flower.0, flower.1, length: 4.2, width: 1.6, angle: up + 0.55))
            petalLights.addPath(leaf(flower.0 - 0.3, flower.1, length: 3.6, width: 0.7, angle: up - 0.5))
        }
        Art.fill(&context, petals, Art.color(0xEE9CB0))
        Art.fill(&context, petalLights, Art.color(0xFFDCE2, 0.8))
    }

    // MARK: Sugar palms

    /// One sugar palm: a tall straight trunk and a round crown of fan leaves.
    static func angkorPalm(
        _ context: inout GraphicsContext,
        x: CGFloat,
        baseY: CGFloat,
        height: CGFloat,
        lean: CGFloat,
        size: CGFloat,
        seed: UInt32
    ) {
        let topX: CGFloat = x + lean
        let topY: CGFloat = baseY - height
        let bendX: CGFloat = x + lean * 0.2
        let bendY: CGFloat = baseY - height * 0.5
        var trunk = Path()
        trunk.move(to: pt(x, baseY))
        trunk.addQuadCurve(to: pt(topX, topY), control: pt(bendX, bendY))
        ArtStyle.contactShadow(&context, x + 3, baseY, 9, 1.6, alpha: 0.3)
        Art.stroke(&context, trunk, Art.color(0x5C4E40), width: 3.4)
        Art.group(&context, x: -1) { g in
            Art.stroke(&g, trunk, Art.color(0xC8A878, 0.5), width: 1)
        }

        var random = ArtRandom(seed)
        var blades = Path()
        var lit = Path()
        for index in 0..<16 {
            let turn: CGFloat = CGFloat(index) / 16 * 2 * CGFloat.pi
            let angle: CGFloat = turn + random.next(in: -0.15...0.15)
            let length: CGFloat = size * random.next(in: 0.8...1.05)
            blades.addPath(leaf(topX, topY, length: length, width: length * 0.32, angle: angle))
            // Fronds that reach up and to the left catch the light.
            let facing: CGFloat = -cos(angle) - sin(angle)
            if facing > 0.4 {
                lit.addPath(leaf(topX, topY, length: length * 0.9, width: length * 0.14, angle: angle - 0.08))
            }
        }
        // A few dry fronds hang below the crown.
        var dry = Path()
        dry.addPath(leaf(topX, topY + 2, length: size * 0.8, width: size * 0.18, angle: 1.9))
        dry.addPath(leaf(topX, topY + 2, length: size * 0.7, width: size * 0.16, angle: 1.25))
        Art.fill(&context, dry, Art.color(0x8A7650, 0.85))
        Art.fill(&context, blades, Art.color(0x3E5A34))
        model(&context, blades, light: 0.18, shade: 0.2)
        Art.fill(&context, lit, Art.color(0x8EAE5E, 0.6))
        Art.fill(&context, Art.circle(topX, topY, 2.4), Art.color(0x4A3A2E))
    }

    static func angkorPalms(_ context: inout GraphicsContext) {
        angkorPalm(&context, x: 30, baseY: 210, height: 118, lean: 6, size: 24, seed: 3)
        angkorPalm(&context, x: 60, baseY: 211, height: 96, lean: -4, size: 20, seed: 7)
        angkorPalm(&context, x: 376, baseY: 211, height: 106, lean: 4, size: 21, seed: 11)
        angkorPalm(&context, x: 406, baseY: 210, height: 136, lean: -6, size: 25, seed: 13)
        // Low shrubs at the palms' feet.
        let leftShrub = canopy(from: -24, to: 80, baseY: 210, height: 7, bump: 10, depth: 2, seed: 61)
        let rightShrub = canopy(from: 360, to: 456, baseY: 210, height: 7, bump: 10, depth: 2, seed: 67)
        Kit.solid(&context, leftShrub, Art.color(0x50703E), light: 0.2, shade: 0.2)
        Kit.solid(&context, rightShrub, Art.color(0x50703E), light: 0.2, shade: 0.2)
    }

    // MARK: Walkers

    /// A few tiny visitors on the causeway, two of them monks in saffron.
    static func angkorWalkers(_ context: inout GraphicsContext) {
        let walkers: [(CGFloat, UInt32)] = [
            (126, 0xE8902E), (133, 0xE8902E), (292, 0x3E5E86), (299, 0xB04E3C), (306, 0xEDE2C8),
        ]
        let feet: CGFloat = 203
        for walker in walkers {
            let x: CGFloat = walker.0
            ArtStyle.contactShadow(&context, x + 0.8, feet + 0.2, 2.6, 0.6, alpha: 0.3)
            let corners: [CGPoint] = [pt(x - 1.3, feet), pt(x + 1.3, feet), pt(x + 0.9, feet - 5), pt(x - 0.9, feet - 5)]
            Art.fill(&context, Art.polygon(corners), Art.color(walker.1))
            Art.fill(&context, Art.rect(x - 1.2, feet - 4.6, 0.7, 4.4), Art.color(0xFFE8C0, 0.35))
            Art.fill(&context, Art.circle(x, feet - 6.4, 1.15), Art.color(0x6A4A3A))
        }
    }

    // MARK: The near plane

    /// The near bank: dark grass, reeds and a few broad leaves at the two bottom corners.
    static func angkorNear(_ context: inout GraphicsContext) {
        let bank = Art.svg("M-24,428 L-24,322 C20,316 60,330 110,338 C160,346 200,342 240,346 C290,350 340,336 380,330 C410,326 440,320 456,324 L456,428 Z")
        Kit.solid(&context, bank, stops: Kit.stops(0x4E6A3A, 0x2C3A22), light: 0.1, shade: 0.2)

        var random = ArtRandom(77)
        var reeds = Path()
        for index in 0..<24 {
            let onLeft: Bool = index < 12
            let x: CGFloat = onLeft ? random.next(in: -10...54) : random.next(in: 374...440)
            let h: CGFloat = random.next(in: 30...72)
            let bend: CGFloat = random.next(in: -12...12)
            let rootY: CGFloat = 372
            reeds.move(to: pt(x, rootY))
            reeds.addQuadCurve(to: pt(x + bend, rootY - h), control: pt(x + bend * 0.2, rootY - h * 0.5))
        }
        Art.stroke(&context, reeds, Art.color(0x24321C), width: 2.2)
        Art.group(&context, x: -0.8) { g in
            Art.stroke(&g, reeds, Art.color(0x7E9A52, 0.35), width: 0.7)
        }

        let broad: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (-6, 392, 54, -0.9), (4, 400, 46, -0.35), (438, 394, 52, -2.2), (430, 404, 44, -2.8),
        ]
        var leaves = Path()
        var glints = Path()
        for item in broad {
            leaves.addPath(leaf(item.0, item.1, length: item.2, width: item.2 * 0.28, angle: item.3))
            glints.addPath(leaf(item.0, item.1 - 1, length: item.2 * 0.85, width: item.2 * 0.07, angle: item.3 - 0.06))
        }
        Art.fill(&context, leaves, Art.color(0x203018))
        Art.fill(&context, glints, Art.color(0x6E8A4A, 0.5))
    }

    // MARK: Finish

    static func angkorFinish(_ context: inout GraphicsContext) {
        bottomFade(&context, 0x2C3A22, from: 300, alpha: 0.9)
        tooth(&context, seed: 419, light: 0.06, dark: 0.05)
        finish(&context, wash: 0.10, vignette: 0.10)
    }
}
