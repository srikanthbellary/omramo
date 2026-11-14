import SwiftUI
import OmramoCore

// Palace and sea-floor elements (design `roof`, `hall`, `coral`, `kelp`, `fish`, `bubbles`),
// the three tap-to-see pictures, the character portraits, the face chips and the cover.

extension UrashimaArt {
    // MARK: - Palace elements

    struct HallStyle: Sendable {
        let wallTop: Color
        let wallBottom: Color
        let column: Color
        let windowTop: Color
        let windowBottom: Color
        let roofTop: Color
        let roofBottom: Color
        let edge: Color

        /// The design's palace: vermilion walls, lit windows, jade roofs with gold edges.
        static let deep = HallStyle(
            wallTop: Art.color(0xE8473A), wallBottom: Art.color(0xB3261E), column: Art.color(0xB3261E),
            windowTop: Art.color(0xFFF3B8), windowBottom: Art.color(0xFFC24D),
            roofTop: Art.color(0x2FC4B2), roofBottom: Art.color(0x0E7C86), edge: Art.color(0xF4C95A)
        )

        /// The same hall in pearl light: white walls, red columns, paler jade.
        static let pearl = HallStyle(
            wallTop: Art.color(0xFFFDF8), wallBottom: Art.color(0xF0E6DA), column: Art.color(0xD9483C),
            windowTop: Art.color(0xFFF0C4), windowBottom: Art.color(0xFFD98A),
            roofTop: Art.color(0x5CCBB8), roofBottom: Art.color(0x2A9A94), edge: Art.color(0xF4C95A)
        )
    }

    /// The curved roof outline of design `roof`: half-width `w`, height `h`, eaves at y = -5…5.
    static func roofShape(_ w: CGFloat, _ h: CGFloat) -> Path {
        var shape = Path()
        shape.move(to: pt(-w, -5))
        shape.addCurve(to: pt(-w * 0.2, -h), control1: pt(-w * 0.72, 2), control2: pt(-w * 0.46, -h * 0.5))
        shape.addLine(to: pt(w * 0.2, -h))
        shape.addCurve(to: pt(w, -5), control1: pt(w * 0.46, -h * 0.5), control2: pt(w * 0.72, 2))
        shape.addLine(to: pt(w * 0.93, 5))
        shape.addLine(to: pt(-w * 0.93, 5))
        shape.closeSubpath()
        return shape
    }

    /// A jade roof with gold edges (design `roof`).
    static func roof(_ context: inout GraphicsContext, _ w: CGFloat, _ h: CGFloat, style: HallStyle) {
        Art.fillLinear(&context, roofShape(w, h), [(style.roofTop, 0), (style.roofBottom, 1)], from: pt(0, -h), to: pt(0, 5))
        var left = Path()
        left.move(to: pt(-w, -5))
        left.addCurve(to: pt(-w * 0.2, -h), control1: pt(-w * 0.72, 2), control2: pt(-w * 0.46, -h * 0.5))
        Art.stroke(&context, left, style.edge, width: ArtStyle.contourLine, cap: .butt)
        var right = Path()
        right.move(to: pt(w, -5))
        right.addCurve(to: pt(w * 0.2, -h), control1: pt(w * 0.72, 2), control2: pt(w * 0.46, -h * 0.5))
        Art.stroke(&context, right, style.edge, width: ArtStyle.contourLine, cap: .butt)
        Art.stroke(&context, Art.line(-w * 0.93, 5, w * 0.93, 5), style.edge, width: ArtStyle.contourLine)
        Art.stroke(&context, Art.line(-w * 0.2, -h, w * 0.2, -h), style.edge, width: ArtStyle.contourLine)
        Art.fill(&context, Art.circle(-w, -6, 2.4), style.edge)
        Art.fill(&context, Art.circle(w, -6, 2.4), style.edge)
    }

    /// One hall (design `hall`): half-width `w`, wall height `h`, under a roof `roofHeight` tall.
    /// (x, y) is the middle of its base.
    static func hall(
        _ context: inout GraphicsContext,
        _ x: CGFloat,
        _ y: CGFloat,
        _ w: CGFloat,
        _ h: CGFloat,
        _ roofHeight: CGFloat,
        windows: Int,
        style: HallStyle
    ) {
        let count = max(windows, 1)
        let bay = 2 * w / CGFloat(count)
        Art.group(&context, x: x, y: y) { g in
            Art.fillLinear(&g, Art.rect(-w, -h, 2 * w, h), [(style.wallTop, 0), (style.wallBottom, 1)], from: pt(0, -h), to: pt(0, 0))
            let paneWidth = w / CGFloat(count)
            let paneTop = -h * 0.78
            let paneHeight = h * 0.56
            let windowStops: [(Color, CGFloat)] = [(style.windowTop, 0), (style.windowBottom, 1)]
            for i in 0..<count {
                let centre = -w + (CGFloat(i) + 0.5) * bay
                let pane = Art.rect(centre - paneWidth * 0.5, paneTop, paneWidth, paneHeight, radius: 1.5)
                Art.fillLinear(&g, pane, windowStops, from: pt(0, paneTop), to: pt(0, paneTop + paneHeight))
            }
            for i in 0...count {
                let cx = -w + CGFloat(i) * bay
                Art.fill(&g, Art.rect(cx - 2, -h, 4, h), style.column)
            }
            Art.fill(&g, Art.rect(-w - 3, -3, 2 * w + 6, 4), style.edge)
            Art.group(&g, y: -h) { top in
                roof(&top, w * 1.36, roofHeight, style: style)
            }
        }
    }

    /// A branching coral (design `coral`). (x, y) is its foot.
    static func coral(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ s: CGFloat, _ color: Color, seed: UInt32) {
        var random = ArtRandom(seed)
        var limbs: [Path] = [Path(), Path(), Path(), Path(), Path()]
        var tips = Path()
        // (x, y, parent angle, turn, length, depth). The stack walks the branches in the same
        // order as the design's recursion, so the random numbers fall on the same branches.
        var stack: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, Int)] = []
        let rootJitter: CGFloat = (CGFloat(random.next()) - 0.5) * 0.3
        let rootAngle: CGFloat = -CGFloat.pi / 2 + rootJitter
        stack.append((x, y, rootAngle, 0, 20 * s, 4))
        while let item = stack.popLast() {
            var angle = item.2
            if item.3 != 0 {
                let spread = 0.35 + CGFloat(random.next()) * 0.4
                angle += item.3 * spread
            }
            let length = item.4
            let depth = item.5
            let x1 = item.0 + cos(angle) * length
            let y1 = item.1 + sin(angle) * length
            let bend = (CGFloat(random.next()) - 0.5) * 6
            let control = pt((item.0 + x1) / 2 + bend, (item.1 + y1) / 2)
            if depth >= 0, depth < limbs.count {
                limbs[depth].move(to: pt(item.0, item.1))
                limbs[depth].addQuadCurve(to: pt(x1, y1), control: control)
            }
            if depth > 0 {
                stack.append((x1, y1, angle, 1, length * 0.72, depth - 1))
                stack.append((x1, y1, angle, -1, length * 0.72, depth - 1))
            } else {
                let r = 1.6 * s
                tips.addEllipse(in: CGRect(x: x1 - r, y: y1 - r, width: r * 2, height: r * 2))
            }
        }
        for depth in stride(from: limbs.count - 1, through: 0, by: -1) {
            Art.stroke(&context, limbs[depth], color, width: CGFloat(depth) * 1.5 * s + 0.8)
        }
        Art.fill(&context, tips, color)
    }

    /// Three blades of kelp rising from (x, y) (design `kelp`).
    static func kelp(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ height: CGFloat, seed: UInt32, dark: Color, light: Color) {
        var random = ArtRandom(seed)
        for i in 0..<3 {
            let bx = x + CGFloat(i - 1) * 7
            let sway = 8 + CGFloat(random.next()) * 10
            let reach = height * (0.7 + CGFloat(random.next()) * 0.4)
            let width = 4 + CGFloat(random.next()) * 3
            var blade = Path()
            blade.move(to: pt(bx, y))
            let tip: CGPoint = pt(bx - sway * 0.4, y - reach)
            let bendOut: CGPoint = pt(bx - sway, y - reach * 0.3)
            let bendBack: CGPoint = pt(bx + sway, y - reach * 0.6)
            blade.addCurve(to: tip, control1: bendOut, control2: bendBack)
            let tint = i % 2 == 1 ? dark : light
            Art.stroke(&context, blade, tint.opacity(0.9), width: width)
        }
    }

    /// A small fish (design `fish`). `flip: 1` swims left, `flip: -1` swims right.
    static func fish(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ s: CGFloat, _ color: Color, flip: CGFloat, eye: Color) {
        Art.group(&context, x: x, y: y, scale: s, scaleX: flip) { g in
            Art.fill(&g, Art.svg("M-10,0 C-5,-6 5,-6 10,0 C5,6 -5,6 -10,0Z"), color)
            Art.fill(&g, Art.svg("M9,0 l8,-5 v10Z"), color)
            Art.fill(&g, Art.svg("M-3,-4.5 q3,-5 7,-1Z"), color)
            Art.fill(&g, Art.circle(-6, -1, 1.3), eye)
            Art.fill(&g, Art.circle(-6.2, -1, 0.6), Art.color(0x10203A))
        }
    }

    /// Scattered bubbles (design `bubbles`). `strength` multiplies the design's opacities, for
    /// pale water where white bubbles would otherwise vanish.
    static func bubbles(
        _ context: inout GraphicsContext,
        count: Int,
        seed: UInt32,
        x: CGFloat,
        y: CGFloat,
        w: CGFloat,
        h: CGFloat,
        fill: Color,
        ring: Color,
        strength: Double = 1
    ) {
        var random = ArtRandom(seed)
        for _ in 0..<max(0, count) {
            let bx = x + CGFloat(random.next()) * w
            let by = y + CGFloat(random.next()) * h
            let r = 1 + CGFloat(random.next()) * 3.4
            let fillAlpha = min(1, (0.08 + random.next() * 0.12) * strength)
            let ringAlpha = min(1, (0.35 + random.next() * 0.4) * strength)
            let bubble = Art.circle(bx, by, r)
            Art.fill(&context, bubble, fill.opacity(fillAlpha))
            Art.stroke(&context, bubble, ring.opacity(ringAlpha), width: 0.7)
        }
    }

    // MARK: - see-rin-gin (design `palaceScene`, screen 06)

    static func seeRinGin(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        // The palace is the one subject: centred, about 60% of the width.
        let cx = w / 2 + 6
        let gy = h - 78
        let deepWater: [(Color, CGFloat)] = [(Art.color(0x0C5C9A), 0), (Art.color(0x08407C), 0.45), (Art.color(0x051F4D), 1)]
        fillBackground(&context, w, h, deepWater)

        // Faint seigaiha in the water.
        var arcs = Path()
        let radius: CGFloat = 24
        var row = 0
        var arcY: CGFloat = 0
        while arcY < h * 0.66 {
            var arcX: CGFloat = row % 2 == 0 ? 0 : radius
            while arcX <= w + radius {
                addArch(&arcs, arcX, arcY, radius)
                addArch(&arcs, arcX, arcY, radius * 0.5)
                arcX += radius * 2
            }
            row += 1
            arcY += radius / 2
        }
        Art.stroke(&context, arcs, Art.color(0x7FD6F2, 0.08), width: ArtStyle.detailLine)

        // Light rays.
        let rays: [(CGFloat, CGFloat, Double)] = [(60, 60, 0.07), (150, 40, 0.05), (230, 80, 0.08), (330, 50, 0.05), (390, 36, 0.04)]
        for (rx, rw, alpha) in rays {
            let footRight: CGFloat = rx + rw * 1.6 - 90
            let footLeft: CGFloat = rx - rw * 0.6 - 90
            let corners: [CGPoint] = [pt(rx, -10), pt(rx + rw, -10), pt(footRight, h), pt(footLeft, h)]
            let ray = Art.polygon(corners)
            // Warm white, like the key light: the deep water is dark, never cold.
            Art.fill(&context, ray, Art.color(0xFFF1DC, alpha))
        }

        // Far plane: the hills of the sea floor behind the palace, pale with distance.
        let farHills = ridge(w, gy, gy - 40, gy - 72, gy - 54, bump: 26)
        Art.fill(&context, farHills, Art.color(0x1A6AA0, 0.4))
        let midHills = ridge(w, gy, gy - 18, gy - 34, gy - 22, bump: 14)
        Art.fill(&context, midHills, Art.color(0x0B4A80, 0.55))

        // Rocks at either side.
        let rock = Art.color(0x06305F, 0.8)
        var leftRock = Path()
        leftRock.move(to: pt(0, h - 120))
        leftRock.addCurve(to: pt(110, h - 110), control1: pt(40, h - 170), control2: pt(80, h - 150))
        leftRock.addLine(to: pt(110, h))
        leftRock.addLine(to: pt(0, h))
        leftRock.closeSubpath()
        Art.fill(&context, leftRock, rock)
        var rightRock = Path()
        rightRock.move(to: pt(w, h - 150))
        rightRock.addCurve(to: pt(w - 110, h - 100), control1: pt(w - 40, h - 190), control2: pt(w - 90, h - 150))
        rightRock.addLine(to: pt(w - 110, h))
        rightRock.addLine(to: pt(w, h))
        rightRock.closeSubpath()
        Art.fill(&context, rightRock, rock)
        ArtStyle.form(&context, leftRock, bounds: CGRect(x: 0, y: h - 170, width: 110, height: 170), light: 0.14, shade: 0.2)
        ArtStyle.form(&context, rightRock, bounds: CGRect(x: w - 110, y: h - 190, width: 110, height: 190), light: 0.1, shade: 0.24)

        // The palace's glow.
        let warm = Art.color(0xFFD98A)
        let teal = Art.color(0x3FD0D0)
        Art.fillRadial(
            &context, Art.circle(cx, gy - 110, 210),
            [(warm.opacity(0.55), 0), (teal.opacity(0.22), 0.5), (teal.opacity(0), 1)],
            center: pt(cx, gy - 110), radius: 210
        )

        // Stacked halls.
        let style = HallStyle.deep
        hall(&context, cx - 96, gy - 34, 34, 34, 22, windows: 3, style: style)
        hall(&context, cx + 96, gy - 34, 34, 34, 22, windows: 3, style: style)
        hall(&context, cx, gy - 44, 78, 46, 26, windows: 5, style: style)
        hall(&context, cx, gy - 116, 52, 34, 24, windows: 3, style: style)
        hall(&context, cx, gy - 176, 30, 26, 22, windows: 2, style: style)
        Art.stroke(&context, Art.line(cx, gy - 226, cx, gy - 248), gold, width: ArtStyle.contourLine)
        Art.fill(&context, Art.circle(cx, gy - 250, 12), Art.color(0xFFE9A8, 0.25))
        Art.fill(&context, Art.circle(cx, gy - 250, 5), Art.color(0xFFE9A8))

        // The great gate: white arched base, vermilion gatehouse.
        Art.group(&context, x: cx, y: gy) { g in
            Art.fillLinear(
                &g, Art.svg("M-50,0 C-48,-22 -42,-40 -36,-52 L36,-52 C42,-40 48,-22 50,0Z"),
                [(Art.color(0xFFFFFF), 0), (Art.color(0xCFE3F2), 1)], from: pt(0, -52), to: pt(0, 0)
            )
            Art.fill(&g, Art.svg("M-15,0 V-20 C-15,-40 15,-40 15,0Z"), Art.color(0x06305F))
            Art.stroke(&g, Art.svg("M-15,0 V-20 C-15,-40 15,-40 15,0"), gold, width: ArtStyle.contourLine, cap: .butt)
            Art.fill(&g, Art.svg("M-11,0 V-18 C-11,-33 11,-33 11,0Z"), Art.color(0xFFD98A, 0.55))
            Art.fill(&g, Art.rect(-40, -54, 80, 4), gold)
            Art.fillLinear(&g, Art.rect(-30, -74, 60, 20), [(style.wallTop, 0), (style.wallBottom, 1)], from: pt(0, -74), to: pt(0, -54))
            let panes: [CGFloat] = [-18, -6, 6, 18]
            for px in panes {
                Art.fillLinear(
                    &g, Art.rect(px - 4, -70, 8, 12, radius: 1),
                    [(style.windowTop, 0), (style.windowBottom, 1)], from: pt(0, -70), to: pt(0, -58)
                )
            }
            Art.group(&g, y: -74) { top in
                roof(&top, 46, 20, style: style)
            }
        }

        // Sea floor and the pale path to the gate.
        var floor = Path()
        floor.move(to: pt(0, gy - 2))
        floor.addCurve(to: pt(cx - 50, gy), control1: pt(80, gy - 12), control2: pt(150, gy + 4))
        floor.addLine(to: pt(cx + 50, gy))
        floor.addCurve(to: pt(w, gy - 4), control1: pt(300, gy + 6), control2: pt(380, gy - 14))
        floor.addLine(to: pt(w, h))
        floor.addLine(to: pt(0, h))
        floor.closeSubpath()
        Art.fillLinear(&context, floor, [(Art.color(0x0C4A6E), 0), (Art.color(0x062447), 1)], from: pt(0, gy - 12), to: pt(0, h))
        let path = Art.polygon([pt(cx - 14, gy), pt(cx - 60, h), pt(cx + 60, h), pt(cx + 14, gy)])
        Art.fill(&context, path, Art.color(0xCFE3F2, 0.22))
        // The lantern light of the gate pools on the floor in front of it.
        Art.clipped(&context, to: floor) { g in
            Art.glow(&g, cx, gy + 6, 120, Art.color(0xFFD98A), alpha: 0.22)
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: gy - 12, width: w, height: 60), seed: 29, color: Art.color(0xBFE6FF), alpha: 0.08)
        }

        // Kelp, coral, pearls.
        let kelpLight = Art.color(0x2FAE8A)
        kelp(&context, 28, h, 150, seed: 3, dark: Art.color(0x1F8F74), light: kelpLight)
        kelp(&context, 72, h, 96, seed: 9, dark: Art.color(0x1F8F74), light: kelpLight)
        kelp(&context, w - 26, h, 170, seed: 5, dark: Art.color(0x1F8F74), light: kelpLight)
        kelp(&context, w - 70, h, 90, seed: 12, dark: Art.color(0x177A66), light: kelpLight)
        coral(&context, 108, h - 34, 1.25, Art.color(0xFF6B7A), seed: 4)
        coral(&context, 52, h - 20, 0.9, Art.color(0xFFB3BD), seed: 8)
        coral(&context, w - 108, h - 30, 1.3, Art.color(0xFF8A5C), seed: 6)
        coral(&context, w - 50, h - 18, 0.8, Art.color(0xF4F7FB), seed: 10)
        coral(&context, 150, h - 12, 0.7, Art.color(0xF4F7FB), seed: 14)
        let pearls: [(CGFloat, CGFloat)] = [(130, h - 16), (w - 150, h - 14), (190, h - 8)]
        for (px, py) in pearls {
            Art.fill(&context, Art.circle(px, py, 5), Art.color(0xFFFFFF, 0.9))
            Art.fill(&context, Art.circle(px - 1.5, py - 1.5, 1.6), Art.color(0xBFE6FF))
        }

        // Fish schools.
        var random = ArtRandom(77)
        for i in 0..<14 {
            let fx = 40 + CGFloat(random.next()) * 120
            let fy = 60 + CGFloat(random.next()) * 60
            let fs = 0.5 + CGFloat(random.next()) * 0.3
            let tint = i % 3 != 0 ? Art.color(0xFF7A6B) : Art.color(0xFFB3A8)
            fish(&context, fx, fy, fs, tint, flip: -1, eye: white)
        }
        for _ in 0..<9 {
            let fx = 310 + CGFloat(random.next()) * 100
            let fy = 150 + CGFloat(random.next()) * 50
            let fs = 0.45 + CGFloat(random.next()) * 0.3
            fish(&context, fx, fy, fs, Art.color(0xBFD9F2), flip: 1, eye: white)
        }
        fish(&context, 60, 250, 1.3, Art.color(0xE8473A), flip: -1, eye: white)
        fish(&context, 350, 96, 1.2, gold, flip: 1, eye: white)

        // Urashima riding the tortoise toward the palace.
        Art.group(&context, x: 70, y: h - 186, rotate: rad(-12), scale: 0.56) { g in
            rider(&g, seated: false)
        }
        let bubbleFill = Art.color(0xBFF3FF)
        let bubbleRing = Art.color(0xDFFBFF)
        bubbles(&context, count: 8, seed: 5, x: 10, y: h - 230, w: 50, h: 50, fill: bubbleFill, ring: bubbleRing)
        // The bubbles stay out of the bottom quarter, which the card fades into its own colour.
        bubbles(&context, count: 28, seed: 21, x: 0, y: 0, w: w, h: h * 0.78, fill: bubbleFill, ring: bubbleRing)
        // A dark picture: a little less wash, the usual vignette.
        finish(&context, w, h, wash: 0.06, vignette: 0.08)
    }

    // MARK: - see-fishing-boats

    /// A fishing boat under a single square sail. The origin is the centre of the waterline.
    static func sailBoat(_ context: inout GraphicsContext, crew: Bool, net: Bool) {
        let timber = Art.color(0x6A4326)
        Art.stroke(&context, Art.line(4, -8, 4, -130), timber, width: 3, cap: .butt)
        Art.stroke(&context, Art.svg("M-30,-34 L-74,-16 M38,-34 L86,-20"), Art.color(0x8A6A3A, 0.7), width: ArtStyle.detailLine)
        let sail = Art.svg("M-32,-116 L40,-116 C45,-90 45,-60 38,-34 L-30,-34 C-37,-60 -37,-90 -32,-116Z")
        Art.fillLinear(&context, sail, [(Art.color(0xFBF6EA), 0), (Art.color(0xE6DCC4), 1)], from: pt(-36, 0), to: pt(44, 0))
        // The sail bellies toward the light: warm on its upper left, shaded lower right.
        ArtStyle.form(&context, sail, bounds: CGRect(x: -37, y: -116, width: 82, height: 82), light: 0.22, shade: 0.14)
        Art.stroke(
            &context,
            Art.svg("M-14,-116 C-17,-90 -17,-60 -13,-34 M4,-116 V-34 M22,-116 C26,-90 26,-60 21,-34"),
            Art.color(0xCFC3A6, 0.8), width: ArtStyle.detailLine, cap: .butt
        )
        Art.fill(&context, Art.circle(4, -78, 9), Art.color(0xE0453A, 0.85))
        Art.stroke(&context, Art.line(-36, -117, 44, -117), timber, width: ArtStyle.contourLine)
        if crew {
            Art.group(&context, x: -44, y: -8, scale: 0.62) { g in
                urashima(&g, rod: .absent, hat: true)
            }
        }
        boat(&context)
        if net {
            // A net hauled over the bow, trailing into the water.
            let drape = Art.svg("M-84,-20 C-76,-8 -72,6 -78,24 L-34,26 C-38,10 -40,-4 -34,-10Z")
            var mesh = Path()
            for step in 0..<16 {
                let mx = -110 + CGFloat(step) * 6
                mesh.move(to: pt(mx, -24))
                mesh.addLine(to: pt(mx + 50, 28))
                mesh.move(to: pt(mx + 50, -24))
                mesh.addLine(to: pt(mx, 28))
            }
            let meshPath = mesh
            Art.clipped(&context, to: drape) { g in
                Art.fill(&g, drape, Art.color(0xF3E9CC, 0.18))
                Art.stroke(&g, meshPath, Art.color(0xF6EED6, 0.9), width: 0.8, cap: .butt)
            }
            let cork = Art.color(0xE9C877)
            Art.stroke(&context, Art.svg("M-84,-20 C-66,-12 -48,-10 -34,-10"), cork, width: ArtStyle.detailLine)
            Art.fill(&context, Art.circle(-78, -17, 2.2), cork)
            Art.fill(&context, Art.circle(-62, -12.6, 2.2), cork)
            Art.fill(&context, Art.circle(-46, -10.6, 2.2), cork)
        }
    }

    /// Fishing boats on a morning sea, a pine headland behind. The bottom runs into the card's
    /// background colour (#1B4C93, the sixth wave band).
    static func seeFishingBoats(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let low = h * 0.44
        let sea = Sea(low: low)
        fillBackground(&context, w, h, daySky)
        ArtStyle.horizonGlow(&context, width: w, y: low + 2, rise: 110, color: horizonTint, alpha: 0.45)
        sun(&context, w - 84, low - 26, 40)

        // Far plane: a low pine headland, kept clear of the close button (top left) and pale
        // with distance, and one far sail. They are setting; the near boat is the subject.
        let base: CGFloat = low + 3
        Art.layer(&context, opacity: 0.7) { g in
            Art.fill(&g, headland(-30, 196, base, 34, peak: 0.36), Art.color(0x9DC3CF))
            let row: [(CGFloat, CGFloat, CGFloat)] = [(22, 0.8, 0.7), (54, 1, 0.9), (92, 0.9, 0.65), (132, 0.5, 0.55)]
            shorePines(&g, row, base: base, rise: 34, s: 1, color: Art.color(0x7FAAB5))
        }
        ArtStyle.atmosphere(&context, width: w, top: low - 100, bottom: low + 4, color: Art.color(0xFFEDE0), alpha: 0.26)
        let gullTint = Art.color(0x5A7C96)
        gull(&context, 96, low - 92, 0.8, gullTint)
        gull(&context, 120, low - 104, 0.6, gullTint)

        let seaShape = seaBand(&context, sea, 0, fills: dayFills, x1: w, bottom: h)
        seaBand(&context, sea, 1, fills: dayFills, x1: w, bottom: h)
        Art.group(&context, x: 372, y: sea.top(1, 372) + 3, scale: 0.24, opacity: 0.85) { g in
            sailBoat(&g, crew: false, net: false)
        }
        seaBand(&context, sea, 2, fills: dayFills, x1: w, bottom: h)
        seaBand(&context, sea, 3, fills: dayFills, x1: w, bottom: h)
        // The one subject: a boat centred a little above the middle, about 58% of the width,
        // with its shadow on the water.
        let boatX: CGFloat = w / 2 - 4
        let boatY: CGFloat = sea.top(3, boatX) + 14
        ArtStyle.contactShadow(&context, boatX + 12, boatY + 14, 132, 10, alpha: 0.22)
        Art.group(&context, x: boatX, y: boatY, rotate: rad(-3), scale: 1.26) { g in
            sailBoat(&g, crew: true, net: true)
        }
        seaBand(&context, sea, 4, fills: dayFills, x1: w, bottom: h)
        seaBand(&context, sea, 5, fills: dayFills, x1: w, bottom: h)

        Art.clipped(&context, to: seaShape) { g in
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: low - 10, width: w, height: h - low + 10), seed: 13, alpha: 0.12)
        }
        // Run the bottom into the card colour.
        let card = dayFills[5]
        let fade: [(Color, CGFloat)] = [(card.opacity(0), 0), (card.opacity(0.9), 0.75), (card, 1)]
        Art.fillLinear(&context, Art.rect(0, h - 120, w, 120), fade, from: pt(0, h - 120), to: pt(0, h))
        finish(&context, w, h)
    }

    // MARK: - see-tamatebako

    /// The tamate-bako on pale silk with a faint violet glow (design `lacquerBox`).
    static func seeTamatebako(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let card = Art.color(0x2B1E4A)
        Art.fill(&context, Art.rect(0, 0, w, h), card)
        let cx = w / 2
        let baseY = h * 0.62
        Art.fillRadial(
            &context, Art.rect(0, 0, w, h),
            [(Art.color(0x4B3878), 0), (Art.color(0x34265A), 0.6), (card, 1)],
            center: pt(cx, h * 0.46), radius: h * 0.78
        )
        Art.glow(&context, cx, h * 0.48, 180, Art.color(0xB79CFF), alpha: 0.22)
        // The warm key light, from the upper left: the box is a mystery, not a menace.
        Art.glow(&context, cx - 70, h * 0.3, 190, ArtStyle.warmLight, alpha: 0.2)

        // Pale silk: a cloth with a soft, uneven hem rather than a plain oval.
        let cloth = Art.svg("M-186,4 C-156,-24 -72,-36 -4,-33 C76,-37 152,-22 190,7 C158,32 96,40 44,42 C20,50 -30,47 -62,41 C-112,40 -164,28 -186,4Z")
        let silk = cloth.applying(CGAffineTransform(translationX: cx, y: baseY + 6))
        Art.fillLinear(&context, silk, [(Art.color(0xFCF8FD), 0), (Art.color(0xD9CBE6), 1)], from: pt(0, baseY - 34), to: pt(0, baseY + 46))
        ArtStyle.form(&context, silk, bounds: CGRect(x: cx - 188, y: baseY - 30, width: 378, height: 84), light: 0.22, shade: 0.16)
        let folds = Art.svg("M-150,2 C-110,16 -60,22 -10,22 M30,26 C80,26 130,18 164,4 M-170,-6 C-150,-14 -120,-18 -96,-18")
        let foldPath = folds.applying(CGAffineTransform(translationX: cx, y: baseY + 8))
        Art.clipped(&context, to: silk) { g in
            Art.stroke(&g, foldPath, Art.color(0xBFAED2, 0.7), width: ArtStyle.detailLine)
        }

        // A few motes in the glow.
        var random = ArtRandom(41)
        for _ in 0..<9 {
            let mx = cx + random.next(in: -170...170)
            let my = h * 0.08 + random.next(in: 0...150)
            let mr = random.next(in: 1.6...3.4)
            Art.fill(&context, Art.spark(mx, my, mr), Art.color(0xFFEBD2, 0.5))
        }

        // The box: centred, a little above the middle, about 60% of the width.
        Art.group(&context, x: cx, y: baseY, scale: 2.3) { g in
            lacquerBox(&g, wisp: true, wispColor: Art.color(0xE9DEFF))
        }
        finish(&context, w, h, wash: 0.06, vignette: 0.06)
    }

    // MARK: - Portraits

    static func portraitUrashima(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        fillBackground(&context, w, h, daySky)
        sun(&context, w * 0.74, h * 0.4, 62)
        gull(&context, w * 0.16, h * 0.24, 1.1, Art.color(0x5A7C96))
        gull(&context, w * 0.25, h * 0.19, 0.8, Art.color(0x5A7C96))
        let line = h * 0.74
        let far = line - 20
        ArtStyle.horizonGlow(&context, width: w, y: far, rise: 120, color: horizonTint, alpha: 0.45)
        // Far plane: a pale pine headland on the horizon, veiled by the haze.
        Art.layer(&context, opacity: 0.6) { g in
            Art.fill(&g, headland(-30, 190, far + 3, 30, peak: 0.36), Art.color(0x9DC3CF))
            let row: [(CGFloat, CGFloat, CGFloat)] = [(24, 0.8, 0.7), (56, 1, 0.9), (94, 0.9, 0.6)]
            shorePines(&g, row, base: far + 3, rise: 30, s: 1, color: Art.color(0x7FAAB5))
        }
        ArtStyle.atmosphere(&context, width: w, top: far - 90, bottom: far + 4, color: Art.color(0xFFEDE0), alpha: 0.26)
        waveBand(&context, x0: 0, x1: w, bottom: h, amp: 5, length: 44, phase: 6, fill: dayFills[1], foamOpacity: 0.8) { _ in far }
        waveBand(
            &context, x0: 0, x1: w, bottom: h, amp: 9, length: 62, phase: 14,
            fill: dayFills[3], foamOpacity: 0.92, fingers: true, seed: 6, texture: 1, textureDepth: 80
        ) { _ in line }
        // Head, shoulders and coat: the topknot about 45 units from the top, the eyes a little
        // above the middle. (At three heads tall the head is a third of him, so the frame
        // holds him to the sash rather than to the knees.)
        Art.group(&context, x: w * 0.48, y: h + 76, scale: 3.6) { g in
            urashima(&g, rod: .shoulder)
        }
        finish(&context, w, h)
    }

    static func portraitTortoise(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        fillBackground(&context, w, h, daySky)
        gull(&context, w * 0.74, h * 0.2, 1.0, Art.color(0x5A7C96))
        let far = h * 0.55
        let mid = h * 0.61
        let near = h * 0.78
        let front = h * 0.9
        // The shared horizon band, in place of the old loose glow in the sky.
        ArtStyle.horizonGlow(&context, width: w, y: far, rise: 140, color: horizonTint, alpha: 0.55)
        waveBand(&context, x0: 0, x1: w, bottom: h, amp: 4, length: 38, phase: 4, fill: dayFills[0], foamOpacity: 0.7) { _ in far }
        waveBand(
            &context, x0: 0, x1: w, bottom: h, amp: 6, length: 50, phase: 20,
            fill: dayFills[2], foamOpacity: 0.85, texture: 1, textureDepth: 70
        ) { _ in mid }
        Art.group(&context, x: w * 0.46, y: h * 0.66, rotate: rad(-3), scale: 2.3) { g in
            tortoise(&g)
        }
        waveBand(
            &context, x0: 0, x1: w, bottom: h, amp: 9, length: 66, phase: 30,
            fill: dayFills[4], foamOpacity: 0.92, fingers: true, seed: 8, texture: 2, textureDepth: 50
        ) { _ in near }
        waveBand(
            &context, x0: 0, x1: w, bottom: h, amp: 10, length: 78, phase: 8,
            fill: dayFills[5], foamOpacity: 0.92, fingers: true, seed: 9
        ) { _ in front }
        finish(&context, w, h)
    }

    static func portraitOtohime(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        // The card's own colours (story.json: #FFF1F4 over #F9D3DC) with a warm halo, no rays.
        ArtStyle.portraitBackdrop(
            &context, CGSize(width: w, height: h),
            top: Art.color(0xFFF1F4), bottom: Art.color(0xF9D3DC), halo: Art.color(0xFFF6DC), rays: false
        )
        // A hall of the palace, far behind her.
        let hallX = w * 0.78
        let hallY = h * 0.66
        Art.layer(&context, opacity: 0.5) { g in
            hall(&g, hallX, hallY, 58, 42, 24, windows: 3, style: HallStyle.pearl)
            hall(&g, hallX, hallY - 66, 36, 28, 20, windows: 2, style: HallStyle.pearl)
        }
        coral(&context, w * 0.13, h - 6, 2.1, Art.color(0xF6A79C), seed: 4)
        coral(&context, w * 0.27, h + 4, 1.3, Art.color(0xFBD3CB), seed: 8)
        bubbles(&context, count: 14, seed: 27, x: 0, y: 0, w: w, h: h, fill: white, ring: white, strength: 2)
        // Head, shoulders and sleeves: the hair knots about 40 units from the top.
        Art.group(&context, x: w * 0.5, y: h + 77, scale: 3.6) { g in
            otohime(&g)
        }
        finish(&context, w, h)
    }

    // MARK: - Faces

    /// Design `faceUrashima`: the head on #CFE6F7 (viewBox -20 -24 40 40).
    static func faceUrashima(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        Art.fill(&context, Art.rect(0, 0, w, h), Art.color(0xCFE6F7))
        // The face fills about 80% of the chip, eyes near the centre line.
        let k = w / 36
        Art.group(&context, x: 18 * k, y: 19 * k, scale: k) { g in
            urashimaHead(&g, frontal: true)
        }
    }

    /// Design `faceTortoise`: the tortoise's head on #FFE3D3 (viewBox -72 -60 44 44).
    static func faceTortoise(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let frame = Art.rect(0, 0, w, h)
        Art.fill(&context, frame, Art.color(0xFFE3D3))
        let k = w / 44
        Art.clipped(&context, to: frame) { g in
            Art.group(&g, x: 74 * k, y: 64 * k, scale: k) { inner in
                tortoise(&inner, tail: false)
            }
        }
    }

    /// Otohime's head on #FFE1EC.
    static func faceOtohime(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let frame = Art.rect(0, 0, w, h)
        Art.fill(&context, frame, Art.color(0xFFE1EC))
        let k = w / 47.6
        Art.clipped(&context, to: frame) { g in
            Art.group(&g, x: 23.8 * k, y: 27.6 * k, scale: k) { inner in
                // Hair down her back, then her shoulders, then the head.
                Art.fill(&inner, Art.svg("M-13,-4 C-18,10 -18,22 -17,32 L17,32 C18,22 18,10 13,-4Z"), ink)
                Art.fillLinear(
                    &inner, Art.svg("M-19,34 C-17,22 -8,17 0,17 C8,17 17,22 19,34Z"),
                    [(Art.color(0x6CC7B3), 0), (Art.color(0x2E8F86), 1)], from: pt(0, 17), to: pt(0, 34)
                )
                Art.fill(&inner, Art.rect(-3.5, 10, 7, 9), Art.color(0xF2CFB0))
                Art.stroke(&inner, Art.svg("M-6,17 L0,25 L6,17"), Art.color(0xFBF6EE), width: 2.4, cap: .butt, join: .miter)
                otohimeHead(&inner)
            }
        }
    }

    // MARK: - Cover

    /// Urashima in his boat on layered waves under the red sun. The height varies (150…375 at
    /// width 300), so everything is composed around the vertical middle.
    static func cover(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let mid = h / 2
        fillBackground(&context, w, h, daySky)
        ArtStyle.horizonGlow(&context, width: w, y: mid + 9, rise: 70, color: horizonTint, alpha: 0.45)
        sun(&context, w * 0.72, mid - 14, 44)
        let sea = Sea(low: mid + 8, scale: 0.6)
        // Far plane: a pale pine headland on the horizon.
        let base: CGFloat = mid + 10
        Art.layer(&context, opacity: 0.6) { g in
            Art.fill(&g, headland(-20, 120, base, 16, peak: 0.36), Art.color(0x9DC3CF))
            let row: [(CGFloat, CGFloat, CGFloat)] = [(16, 0.8, 0.36), (36, 1, 0.48), (60, 0.9, 0.34)]
            shorePines(&g, row, base: base, rise: 16, s: 1, color: Art.color(0x7FAAB5))
        }
        ArtStyle.atmosphere(&context, width: w, top: mid - 50, bottom: mid + 10, color: Art.color(0xFFEDE0), alpha: 0.26)
        let gullTint = Art.color(0x5A7C96)
        gull(&context, w * 0.36, mid - 30, 0.6, gullTint)
        gull(&context, w * 0.43, mid - 37, 0.45, gullTint)
        let seaShape = seaBand(&context, sea, 0, fills: dayFills, x1: w, bottom: h)
        for index in 1...3 {
            seaBand(&context, sea, index, fills: dayFills, x1: w, bottom: h)
        }
        let boatX = w * 0.6
        let boatY: CGFloat = sea.top(3, boatX) + 3
        ArtStyle.contactShadow(&context, boatX + 6, boatY + 7, 70, 5, alpha: 0.2)
        Art.group(&context, x: boatX, y: boatY, rotate: rad(-5), scale: 0.68) { g in
            boatWithUrashima(&g)
        }
        for index in 4...6 {
            seaBand(&context, sea, index, fills: dayFills, x1: w, bottom: h)
        }
        Art.clipped(&context, to: seaShape) { g in
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: mid, width: w, height: h - mid), seed: 15, alpha: 0.12)
        }
        finish(&context, w, h)
    }
}
