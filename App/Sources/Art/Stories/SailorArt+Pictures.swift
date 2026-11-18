import SwiftUI
import OmramoCore

// "The Shipwrecked Sailor": the three tap-to-see pictures (432 × 404), the two character
// portraits (432 × 400), the three face chips (100 × 100) and the cover.

// MARK: - Tap-to-see pictures

extension SailorArt {
    /// see-red-sea: a long, narrow blue sea seen from a high place, running away to the
    /// horizon between two dry, sandy shores; one tiny square-sailed ship for scale.
    static func redSeaPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = 122
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        // Far, pale desert mountains on both shores.
        let rangeTone: Color = Art.color(0xDCC4A6, 0.85)
        Art.fill(&context, Kit.peaks(width: 196, y: H, amp: 22, seed: 4, bottom: H + 4, sharp: 0.4, x0: 0), rangeTone)
        Art.fill(&context, Kit.peaks(width: 196, y: H, amp: 18, seed: 9, bottom: H + 4, sharp: 0.4, x0: 240), rangeTone)
        // The dry land.
        let land: Kit.Stops = [(Art.color(0xF2DDB0), 0), (Art.color(0xE6C48C), 0.5), (Art.color(0xD2A56A), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: land, seed: 41, tooth: Art.color(0xA87A44))
        let duneLight: Color = Art.color(0xFBEBC4, 0.6)
        let duneShade: Color = Art.color(0xC79A5E, 0.4)
        Art.fill(&context, Kit.ridge(width: 200, y: H + 46, amp: 9, seed: 3, bottom: H + 62, x0: 0), duneLight)
        Art.fill(&context, Kit.ridge(width: 180, y: H + 110, amp: 12, seed: 6, bottom: H + 132, x0: 0), duneShade)
        Art.fill(&context, Kit.ridge(width: 190, y: H + 40, amp: 8, seed: 8, bottom: H + 54, x0: 250), duneLight)
        Art.fill(&context, Kit.ridge(width: 150, y: H + 120, amp: 12, seed: 11, bottom: H + 144, x0: 290), duneShade)

        // The sea: narrow at the horizon, wide at the viewer's feet.
        var sea = Path()
        sea.move(to: CGPoint(x: 205, y: H))
        sea.addLine(to: CGPoint(x: 229, y: H))
        sea.addCurve(to: CGPoint(x: 346, y: h + 6), control1: CGPoint(x: 246, y: 190), control2: CGPoint(x: 304, y: 290))
        sea.addLine(to: CGPoint(x: 86, y: h + 6))
        sea.addCurve(to: CGPoint(x: 205, y: H), control1: CGPoint(x: 142, y: 290), control2: CGPoint(x: 198, y: 190))
        sea.closeSubpath()
        let shape: Path = sea
        let blue: Kit.Stops = [(Art.color(0x9ADAE0), 0), (Art.color(0x2A8DB0), 0.4), (Art.color(0x0E4C7A), 1)]
        Art.fillLinear(&context, shape, blue, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: h))
        Art.clipped(&context, to: shape) { g in
            // Turquoise shallows along both shores, then ripples and the light on the water.
            Art.stroke(&g, shape, Art.color(0x7FD8CF, 0.7), width: 16)
            Art.stroke(&g, shape, Color.white.opacity(0.7), width: 3)
            Kit.rippleMarks(&g, x0: 90, x1: 340, y0: H + 16, y1: h, count: 46, seed: 3, color: Color.white)
            Kit.glints(&g, x: 214, top: H, depth: 120, color: Art.color(0xFFF3C8), count: 16)
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 24, bottom: H + 60, color: light.haze, alpha: 0.4)
        // A few rocks on the shores, and the tiny ship.
        Kit.rock(&context, cx: 66, baseY: 256, width: 44, height: 22, color: 0xC9A878, seed: 2)
        Kit.rock(&context, cx: 382, baseY: 226, width: 34, height: 18, color: 0xC9A878, seed: 7)
        Kit.pebbles(&context, in: CGRect(x: 10, y: 200, width: 120, height: 70), count: 6, seed: 5, color: 0xB8946A)
        Kit.pebbles(&context, in: CGRect(x: 330, y: 180, width: 96, height: 80), count: 6, seed: 13, color: 0xB8946A)
        Kit.boat(&context, cx: 226, waterY: 232, length: 34, hull: hullWood, sail: sailCloth, style: .nile)
        Kit.sink(&context, size, card: 0x0B4F7A)
    }

    /// see-incense: a small stone bowl of golden-brown lumps of resin, one thin curl of pale
    /// smoke rising, on a plain dark ground.
    static func incensePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let ground: Kit.Stops = [(Art.color(0x7E4E28), 0), (Art.color(0x5A3418), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), ground, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 190, 170, 210, Art.color(0xFFC96B), alpha: 0.3)
        // The table the bowl stands on.
        Art.fill(&context, Art.rect(0, 286, w, h - 286), Art.color(0x4A2A14, 0.55))
        Art.stroke(&context, Art.line(0, 286, w, 286), Art.color(0xA8743E, 0.5), width: 2)
        ArtStyle.contactShadow(&context, 226, 296, 120, 10, alpha: 0.4)

        Art.group(&context, x: 216, y: 206) { g in
            incenseBowl(&g)
        }
        // The curl of smoke: soft, then one finer line inside it.
        let smoke: Path = Kit.placed("M0,0 C-18,-22 18,-42 2,-66 C-12,-88 22,-104 6,-132", x: 220, y: 164)
        Art.blurred(&context, radius: 4, opacity: 0.6) { g in
            Art.stroke(&g, smoke, Art.color(0xFFF3DC), width: 7)
        }
        Art.stroke(&context, smoke, Art.color(0xFFF8E8, 0.55), width: 1.6)
        Kit.sink(&context, size, card: 0x5A3418)
    }

    /// The bowl and its heap of resin, with the middle of the rim at (0, 0).
    static func incenseBowl(_ context: inout GraphicsContext) {
        let stone: UInt32 = 0xBDB5A6
        Art.fill(&context, Art.rect(-36, 70, 72, 16, radius: 5), Art.color(0x9A9284))
        let body: Path = Art.svg("M-96,0 C-92,58 -52,80 0,80 C52,80 92,58 96,0Z")
        Kit.solid(&context, body, Art.color(stone), light: 0.34, shade: 0.3, rim: 2.4)
        Art.clipped(&context, to: body) { g in
            Art.stipple(&g, in: CGRect(x: -96, y: 0, width: 192, height: 80), count: 70, seed: 17, color: Art.color(0x6E665A), alpha: 0.3, size: 0.6...1.6)
        }
        Art.fill(&context, Art.ellipse(0, 0, 96, 14), Art.color(0xD8D1C2))
        Art.fill(&context, Art.ellipse(0, 1.5, 85, 10), Art.color(0x5E564C))
        // The lumps of resin: golden-brown, each catching the light.
        let lumps: [(CGFloat, CGFloat, CGFloat, UInt32)] = [
            (-50, -4, 17, 0xD98A1E), (48, -3, 16, 0xC97A22), (-22, -10, 20, 0xE8A21C), (16, -8, 19, 0xF2BC4A),
            (-36, -26, 15, 0xF2BC4A), (34, -24, 15, 0xE8A21C), (0, -28, 18, 0xD98A1E), (-8, -46, 13, 0xF2BC4A),
        ]
        for lump in lumps {
            let r: CGFloat = lump.2
            let shape: Path = Art.svg("M-1,-0.82 C-0.4,-1.02 0.5,-0.96 0.92,-0.5 C1.12,0 0.9,0.62 0.3,0.8 C-0.3,0.94 -0.96,0.66 -1.06,0.1 C-1.14,-0.3 -1.2,-0.62 -1,-0.82Z")
            let placed: Path = shape.applying(CGAffineTransform(translationX: lump.0, y: lump.1).scaledBy(x: r, y: r))
            Kit.solid(&context, placed, Art.color(lump.3), light: 0.4, shade: 0.3)
            Art.fill(&context, Art.ellipse(lump.0 - r * 0.36, lump.1 - r * 0.4, r * 0.26, r * 0.16), Color.white.opacity(0.55))
        }
        // The near lip of the bowl, over the foot of the heap.
        let lip: Path = Art.svg("M-96,0 C-96,18.6 96,18.6 96,0")
        Art.stroke(&context, lip, Art.color(0xD8D1C2), width: 5)
        Art.stroke(&context, Art.svg("M-90,-2 C-80,-12 -40,-14 -10,-14"), ArtStyle.warmLight.opacity(0.5), width: 1.6)
    }

    /// see-papyrus: a roll of pale brown papyrus, partly open, soft rows of marks on it (not
    /// readable signs), a reed pen and a small ink palette beside it, a papyrus stem behind.
    static func papyrusPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let ground: Kit.Stops = [(Art.color(0x73813E), 0), (Art.color(0x3D4A1E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), ground, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 190, 160, 220, Art.color(0xFFE2A0), alpha: 0.24)
        Kit.reeds(&context, x: 362, baseY: 310, count: 2, height: 250, seed: 3, color: 0x86B85E, papyrus: true)
        ArtStyle.contactShadow(&context, 214, 258, 150, 12, alpha: 0.4)
        Art.group(&context, x: 206, y: 176, rotate: -0.06) { g in
            papyrusRoll(&g)
        }
        // The reed pen.
        Art.stroke(&context, Art.line(124, 272, 262, 256), Art.color(0xD2AE62), width: 4.4)
        Art.stroke(&context, Art.line(128, 270.4, 258, 255.2), Art.color(0xF2DA9A, 0.8), width: 1.2)
        Art.stroke(&context, Art.line(124, 272, 134, 270.8), Art.color(0x2A2026), width: 3.4)
        // The scribe's palette: two cakes of ink, black and red.
        Art.group(&context, x: 316, y: 262, rotate: 0.1) { g in
            let board: Path = Art.rect(-36, -12, 72, 24, radius: 5)
            Kit.solid(&g, board, Art.color(0xA9743E), light: 0.3, shade: 0.26)
            Art.fill(&g, Art.circle(-17, 0, 7), Art.color(0x2A2026))
            Art.fill(&g, Art.circle(3, 0, 7), Art.color(0xB5482A))
            Art.fill(&g, Art.rect(15, -2.5, 16, 5, radius: 2.5), Art.color(0x7A5230))
            Art.fill(&g, Art.circle(-19, -2, 1.8), Color.white.opacity(0.35))
            Art.fill(&g, Art.circle(1, -2, 1.8), Color.white.opacity(0.4))
        }
        Kit.sink(&context, size, card: 0x3D4A1E)
    }

    /// The open papyrus, centred on (0, 0): the sheet, the roll still closed on the left,
    /// the curling end on the right, and the rows of marks.
    static func papyrusRoll(_ context: inout GraphicsContext) {
        let sheet: Path = Art.rect(-112, -62, 204, 124, radius: 2)
        let tone: Kit.Stops = [(Art.color(0xEFDCB0), 0), (Art.color(0xDFC692), 1)]
        Kit.solid(&context, sheet, stops: tone, light: 0.24, shade: 0.16)
        var fibres = Path()
        for i in 0..<20 {
            let y: CGFloat = -58 + CGFloat(i) * 6
            fibres.move(to: CGPoint(x: -112, y: y))
            fibres.addLine(to: CGPoint(x: 92, y: y + 0.6))
        }
        var strips = Path()
        for i in 0..<22 {
            let x: CGFloat = -106 + CGFloat(i) * 9
            strips.move(to: CGPoint(x: x, y: -62))
            strips.addLine(to: CGPoint(x: x, y: 62))
        }
        let across: Path = fibres
        let down: Path = strips
        Art.clipped(&context, to: sheet) { g in
            Art.stroke(&g, across, Art.color(0xC2A66E, 0.5), width: 0.8)
            Art.stroke(&g, down, Art.color(0xC2A66E, 0.28), width: 0.8)
        }
        // Rows of soft marks: writing that cannot be read. The first row is in red ochre.
        let pattern: [CGFloat] = [5, 4, 2, 4, 8, 5, 3, 6]
        for row in 0..<7 {
            let y: CGFloat = -42 + CGFloat(row) * 14
            let x0: CGFloat = -78 + CGFloat(row % 3) * 5
            let x1: CGFloat = row == 6 ? 10 : 72
            let ink: Color = row == 0 ? Art.color(0xB5482A, 0.8) : Art.color(0x3A2A1E, 0.72)
            Art.stroke(&context, Art.line(x0, y, x1, y), ink, width: 2.8, dash: pattern)
        }
        // The closed roll on the left, and the curling end on the right.
        let roll: Path = Art.rect(-134, -68, 32, 136, radius: 14)
        let rollTone: Kit.Stops = [(Art.color(0xF2E0B6), 0), (Art.color(0xD2B682), 1)]
        Kit.solid(&context, roll, stops: rollTone, light: 0.3, shade: 0.26, rim: 2)
        Art.stroke(&context, Art.line(-103, -58, -103, 58), ArtStyle.coolShade.opacity(0.18), width: 4)
        Art.fill(&context, Art.ellipse(-118, -62, 13, 5.5), Art.color(0xC2A66E))
        Art.stroke(&context, Art.ellipse(-118, -62, 7, 2.8), Art.color(0x8A6E40, 0.8), width: 1.2)
        let curl: Path = Art.rect(84, -66, 20, 132, radius: 9)
        Kit.solid(&context, curl, stops: rollTone, light: 0.3, shade: 0.26)
        Art.fill(&context, Art.ellipse(94, -61, 8.5, 4), Art.color(0xC2A66E))
        // A cord tied round the closed roll.
        Art.stroke(&context, Art.line(-134, 6, -102, 8), Art.color(0xB5482A), width: 2.6)
    }
}

// MARK: - Portraits and face chips

extension SailorArt {
    /// char-sailor: the Sailor on the sand, waving, the sea behind him.
    static func sailorPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x8FD3F0, bottom: 0x2F8FC0, halo: 0xFFF3D0, rays: true) { g in
            // The sea and the sand, low behind him.
            let sea: Kit.Stops = [(Art.color(0x56B7CC, 0.9), 0), (Art.color(0x1C7FA6), 1)]
            Art.fillLinear(&g, Art.rect(0, 258, 432, 80), sea, from: CGPoint(x: 0, y: 258), to: CGPoint(x: 0, y: 338))
            Kit.swells(&g, width: 432, top: 262, bottom: 322, rows: 4, crest: Color.white)
            let sand: Path = Art.svg("M-4,326 C80,312 150,318 220,322 C300,326 370,314 436,318 L436,404 L-4,404Z")
            Art.stroke(&g, sand, Color.white.opacity(0.8), width: 3)
            Art.fillLinear(&g, sand, sandStops(), from: CGPoint(x: 0, y: 314), to: CGPoint(x: 0, y: 400))
            plank(&g, x: 70, y: 352, length: 86, tilt: -0.16)
            Kit.pebbles(&g, in: CGRect(x: 300, y: 340, width: 110, height: 40), count: 5, seed: 8, color: 0xF2C6B8)
            Art.group(&g, x: 216, y: 150, scale: 2.2) { b in
                Kit.bust(&b, sailorLook(), mouth: .grin, wave: true)
                // His one blue bead, on the cord.
                Art.fill(&b, Art.circle(0, 62, 4.4), Art.color(lapis))
                Art.fill(&b, Art.circle(-1.3, 60.6, 1.4), Color.white.opacity(0.8))
            }
        }
    }

    /// char-serpent: the Serpent coiled like a big gold cushion, his head raised a little,
    /// smiling; lapis brows and the long beard clear.
    static func serpentPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFFD86B, bottom: 0xE8923A, halo: 0xFFF6D8, rays: true) { g in
            Art.fill(&g, Art.ellipse(216, 408, 270, 44), Art.color(0xFBEFC4, 0.55))
            serpentTail(&g, from: CGPoint(x: 92, y: 330), tip: CGPoint(x: 36, y: 268), width: 42, lift: -6)
            serpentCoils(&g, cx: 216, baseY: 438, width: 400, thick: 88, turns: 2)
            var neck = Path()
            neck.move(to: CGPoint(x: 266, y: 334))
            neck.addCurve(to: CGPoint(x: 216, y: 160), control1: CGPoint(x: 304, y: 262), control2: CGPoint(x: 264, y: 196))
            serpentBody(&g, neck, width: 78)
            Art.group(&g, x: 216, y: 150, scale: 1.5) { h in
                serpentHead(&h)
            }
            Art.fill(&g, Art.spark(78, 124, 9), Color.white.opacity(0.85))
            Art.fill(&g, Art.spark(356, 96, 7), Color.white.opacity(0.8))
            Art.fill(&g, Art.spark(382, 226, 5), Color.white.opacity(0.75))
        }
    }

    /// face-sailor.
    static func sailorChip(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE2A8) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.25) { f in
                Kit.personHead(&f, sailorLook(), mouth: .smile)
            }
        }
    }

    /// face-captain.
    static func captainChip(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xBDEFE0) { g in
            // A glimpse of his bead collar under the chin.
            Art.fill(&g, Art.ellipse(0, 50, 34, 12), Art.color(0x2FA39A))
            Art.group(&g, x: 0, y: 3, scale: 1.25) { f in
                Kit.personHead(&f, captainLook(), mouth: .grin)
            }
        }
    }

    /// face-serpent.
    static func serpentChip(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE7A0) { g in
            Art.glow(&g, 0, 0, 52, Art.color(0xE8923A), alpha: 0.4)
            Art.group(&g, x: 0, y: -7, scale: 0.68) { f in
                serpentHead(&f)
            }
        }
    }
}

// MARK: - Cover

extension SailorArt {
    /// The cover: the Sailor sitting on a loop of the golden Serpent, the two of them side by
    /// side in the middle of the green island, looking out over the blue sea.
    static func coverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let light = day()
            let full = CGSize(width: 240, height: hd)
            Kit.sky(&g, full, horizon: H, light: light)
            Kit.sun(&g, 52, H - 15 * k, 8 * k, light: light)
            Kit.cloud(&g, 186, H - 40 * k, scale: 0.26 * k, color: Color.white.opacity(0.7))
            Kit.water(&g, width: 240, top: H, bottom: hd, stops: seaStops(), light: light, ripples: 12)
            Kit.swells(&g, width: 240, top: H + 3, bottom: H + 30 * k, rows: 3, crest: Color.white)

            // The green island under them.
            let landY: CGFloat = H + 26 * k
            var land = Path()
            land.move(to: CGPoint(x: -4, y: hd + 2))
            land.addLine(to: CGPoint(x: -4, y: landY + 8 * k))
            land.addCurve(to: CGPoint(x: 120, y: landY - 4 * k), control1: CGPoint(x: 40, y: landY + 2 * k), control2: CGPoint(x: 80, y: landY - 6 * k))
            land.addCurve(to: CGPoint(x: 244, y: landY + 4 * k), control1: CGPoint(x: 170, y: landY - 2 * k), control2: CGPoint(x: 210, y: landY - 4 * k))
            land.addLine(to: CGPoint(x: 244, y: hd + 2))
            land.closeSubpath()
            let island: Path = land
            Art.stroke(&g, island, Art.color(0xFBEFC4), width: 5 * k)
            Kit.solid(&g, island, stops: meadowStops(), light: 0.2, shade: 0.16)
            datePalm(&g, x: 26, baseY: landY + 10 * k, height: 88 * k, lean: 8 * k, seed: 4)
            coverPair(&g, horizon: H, scale: k)

            let gy: CGFloat = H + 52 * k
            let room: CGFloat = hd - gy - 22 * k
            if room > 8 {
                let field = CGRect(x: 8, y: gy + 14 * k, width: 224, height: room)
                Kit.grass(&g, in: field, count: 14 + Int(room / 4), seed: 21, color: Art.color(0x2E8A50, 0.8), height: 6)
                Kit.flowers(&g, in: field, count: 4 + Int(room / 12), seed: 9, petal: 0xFFFFFF)
            }
            Kit.cornerLeaves(&g, size: full, corner: 1, color: Art.color(0x14503C), scale: 0.5 * k, seed: 3)
        }
    }

    /// The Serpent and the Sailor of the cover, in cover units: the ground they rest on is
    /// 52 × `k` under the horizon.
    static func coverPair(_ context: inout GraphicsContext, horizon H: CGFloat, scale k: CGFloat) {
        let gy: CGFloat = H + 52 * k
        let tb: CGFloat = 22 * k
        let spineY: CGFloat = gy - tb / 2
        ArtStyle.contactShadow(&context, 110, gy + 1, 70 * k, 4 * k, alpha: 0.24)
        serpentTail(&context, from: CGPoint(x: 72, y: spineY), tip: CGPoint(x: 36, y: gy - 3 * k), width: tb, lift: -3 * k)
        var spine = Path()
        spine.move(to: CGPoint(x: 70, y: spineY))
        spine.addQuadCurve(to: CGPoint(x: 140, y: spineY), control: CGPoint(x: 104, y: spineY + 2 * k))
        serpentBody(&context, spine, width: tb)
        serpentCoils(&context, cx: 152, baseY: gy + 2 * k, width: 104 * k, thick: 26 * k, turns: 2)
        let headAt = CGPoint(x: 150, y: H - 20 * k)
        let neck: Path = serpentNeck(from: CGPoint(x: 164, y: gy - 30 * k), to: headAt, rise: 26 * k)
        serpentBody(&context, neck, width: 23 * k)
        Art.group(&context, x: headAt.x, y: headAt.y, scale: 0.5 * k) { h in
            serpentHead(&h, look: CGPoint(x: -0.75, y: 0))
        }
        // The Sailor, sitting on the golden loop beside him.
        let s: CGFloat = 0.36 * k
        Art.group(&context, x: 96, y: gy - tb + 34 * s, scale: s) { p in
            sailor(&p, pose: .sit, look: CGPoint(x: -0.8, y: -0.1), mouth: .smile)
        }
    }
}
