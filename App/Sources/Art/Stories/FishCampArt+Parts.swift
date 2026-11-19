import SwiftUI
import OmramoCore

// The places and things of "The Long Day at Fish Camp" that several pictures share: the far
// shore and the thin clouds, the grassy cut bank with its grey mud, the aluminium skiff, the
// plywood and board cabins, smoke, the cutting table, the tote, the bucket, the mug, the
// kettle, a gull, fireweed and mosquitoes. Present-day summer: no snow anywhere.

// MARK: - Far plane and the bank

extension FishCampArt {
    /// Long thin evening clouds, high and pale, thickest on the trailing side.
    static func cloudStreaks(_ g: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, color: Color) {
        let s: CGFloat = w / 892
        let streaks: [(CGFloat, CGFloat, CGFloat, CGFloat, Double)] = [
            (590, 0.2, 200, 7, 0.5), (690, 0.26, 130, 5, 0.42), (780, 0.4, 160, 6, 0.44), (150, 0.48, 170, 5, 0.3), (320, 0.6, 120, 4, 0.26),
        ]
        for streak in streaks {
            let x: CGFloat = streak.0 * s
            let y: CGFloat = H * streak.1
            let length: CGFloat = streak.2 * s
            let thick: CGFloat = streak.3
            let body = Art.rect(x - length / 2, y - thick / 2, length, thick, radius: thick / 2)
            Art.fill(&g, body, color.opacity(streak.4))
            let underX: CGFloat = x - length * 0.28
            let under = Art.rect(underX, y + thick * 0.2, length * 0.66, thick * 0.6, radius: thick * 0.3)
            Art.fill(&g, under, Art.color(0xF6C9A0, streak.4 * 0.5))
        }
    }

    /// The far shore: a thin low line of green tundra with a few far spruce, veiled by the air.
    static func farShore(_ g: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light, seed: UInt32) {
        let back = Kit.ridge(width: w, y: H - 8 * s, amp: 3 * s, seed: seed &+ 7, bottom: H + 4, step: 12)
        Art.fill(&g, back, light.far.opacity(0.7))
        Kit.farTrees(&g, x0: 520 * w / 892, x1: 870 * w / 892, baseY: H - 6 * s, height: 13 * s, count: 7, color: light.far, conifer: true, seed: seed)
        let front = Kit.ridge(width: w, y: H - 4 * s, amp: 2 * s, seed: seed, bottom: H + 4, step: 10)
        Art.fill(&g, front, light.mid.opacity(0.8))
        ArtStyle.atmosphere(&g, width: w, top: H - 26 * s, bottom: H + 4, color: light.haze, alpha: 0.32)
    }

    /// The grassy cut bank on the trailing side, in design units: its flat top at the horizon
    /// from `x0` to the edge, its leading face running down and out toward the viewer (`run`
    /// 0.4…1 says how far), with grey mud between the bank and the water.
    static func bank(_ g: inout GraphicsContext, _ st: Kit.Stage, x0: CGFloat, run: CGFloat) {
        let Hv: CGFloat = st.Hv
        let foot: CGFloat = st.hv + 12
        let lip: CGFloat = Hv - 3
        let reach: CGFloat = 240 * run
        let mudReach: CGFloat = 340 * run
        let edgeX: CGFloat = x0 - reach
        var flat = Path()
        flat.move(to: CGPoint(x: x0 - 4, y: Hv + 1))
        flat.addQuadCurve(to: CGPoint(x: x0 - mudReach, y: foot), control: CGPoint(x: x0 - mudReach * 0.3, y: Hv + 30))
        flat.addLine(to: CGPoint(x: x0 + 20, y: foot))
        flat.closeSubpath()
        let mudStops: Kit.Stops = [(Art.color(0xA9A294), 0), (Art.color(mud), 0.5), (Art.color(0x857D70), 1)]
        Art.fillLinear(&g, flat, mudStops, from: CGPoint(x: 0, y: Hv), to: CGPoint(x: 0, y: foot))
        var wet = Path()
        wet.move(to: CGPoint(x: x0 - 6, y: Hv + 3))
        wet.addQuadCurve(to: CGPoint(x: x0 - mudReach - 4, y: foot), control: CGPoint(x: x0 - mudReach * 0.3 - 4, y: Hv + 32))
        Art.stroke(&g, wet, Color.white.opacity(0.35), width: 1.6)
        var land = Path()
        land.move(to: CGPoint(x: x0, y: lip))
        land.addQuadCurve(to: CGPoint(x: edgeX, y: foot), control: CGPoint(x: x0 - reach * 0.2, y: Hv + 30))
        land.addLine(to: CGPoint(x: 904, y: foot))
        land.addLine(to: CGPoint(x: 904, y: lip))
        land.closeSubpath()
        Art.fillLinear(&g, land, grassStops(), from: CGPoint(x: 0, y: lip), to: CGPoint(x: 0, y: foot))
        Kit.model(&g, land, light: 0.12, shade: 0.12)
        var face = Path()
        face.move(to: CGPoint(x: x0 - 2, y: lip + 2))
        face.addQuadCurve(to: CGPoint(x: edgeX - 2, y: foot), control: CGPoint(x: x0 - reach * 0.2 - 2, y: Hv + 32))
        Art.stroke(&g, face, Art.color(0x8A7458), width: 7)
        Art.stroke(&g, face, Art.color(0x6E5C46, 0.6), width: 2)
        Art.stroke(&g, Art.line(x0 + 2, lip + 0.5, 904, lip + 0.5), Art.color(0xD4E0A0, 0.7), width: 1.6)
        ArtStyle.tooth(&g, in: CGRect(x: edgeX, y: lip, width: 904 - edgeX, height: foot - lip), seed: 61, alpha: 0.06)
    }
}

// MARK: - The skiff

extension FishCampArt {
    /// An open flat-bottomed aluminium skiff seen from the side, dented and plain, with an
    /// outboard motor on the stern. Origin at the middle of the waterline, bow to the LEFT,
    /// 256 long (x −130…128); the near gunwale is about 30 above the waterline. Draw the
    /// people inside it first: the hull covers their legs.
    static func skiff(_ g: inout GraphicsContext, motor: Bool) {
        let inside: Path = Art.svg("M-130,-31 L-120,-36 L124,-30 L126,-25Z")
        Art.fill(&g, inside, Art.color(0x5E686E))
        Art.stroke(&g, Art.line(-120, -36, 124, -30), Art.color(0x9AA4A8), width: 2.2)
        let hull: Path = Art.svg("M-130,-31 L126,-25 L127,-2 C127,3 123,6 118,6 L-92,6 C-110,4 -124,-14 -130,-31Z")
        let metal: Kit.Stops = [(Art.color(0xDCE3E5), 0), (Art.color(aluminium), 0.45), (Art.color(0x8E9A9F), 1)]
        Kit.solid(&g, hull, stops: metal, light: 0.26, shade: 0.2, rim: 1.2)
        let seams: Path = Art.svg("M-122,-18 L126,-14 M-106,-6 L126,-4")
        let dent: Path = Art.svg("M-30,-20 C-22,-14 -12,-14 -6,-19")
        Art.clipped(&g, to: hull) { c in
            Art.stroke(&c, seams, Art.color(0x7E8A90, 0.7), width: 1)
            Art.stroke(&c, dent, Color.white.opacity(0.5), width: 1.4)
            Art.fill(&c, Art.rect(-130, -1, 260, 8), Art.color(0x6A5E4E, 0.35))
        }
        var rivets = Path()
        var x: CGFloat = -112
        while x < 120 {
            let y: CGFloat = -30.4 + (x + 130) * 0.023
            rivets.addPath(Art.circle(x, y + 4, 0.8))
            x += 12
        }
        Art.fill(&g, rivets, Art.color(0x6E7A80))
        Art.stroke(&g, Art.line(-130, -31, 126, -25), Art.color(0xEEF2F2), width: 3)
        if motor {
            Art.fill(&g, Art.rect(132, -28, 6, 40, radius: 2), Art.color(0x2E343A))
            Art.fill(&g, Art.rect(126, 8, 18, 3, radius: 1.5), Art.color(0x2E343A))
            let cowl: Path = Art.svg("M124,-30 C124,-44 130,-50 140,-50 C148,-50 152,-44 152,-36 C152,-30 148,-26 142,-26 L126,-26Z")
            Kit.solid(&g, cowl, Art.color(0x3A4048), light: 0.3, shade: 0.2, rim: 1)
            Art.stroke(&g, Art.svg("M128,-40 C134,-44 142,-45 148,-42"), Art.color(0xC8442E), width: 1.6)
            Art.stroke(&g, Art.line(124, -38, 108, -40), Art.color(0x2E343A), width: 2.4)
        }
    }
}

// MARK: - Cabins and smoke

extension FishCampArt {
    /// A small plain cabin, gable end to the viewer, its side wall turning away to the right:
    /// `boards` gives weathered vertical boards (else plywood sheets), a tin roof, a plain
    /// door and window, a metal stovepipe. Origin on the ground under the gable's middle.
    static func cabin(
        _ g: inout GraphicsContext,
        width w: CGFloat,
        height h: CGFloat,
        rise: CGFloat,
        wall: UInt32,
        roof: UInt32,
        boards: Bool,
        door: Bool,
        pipe: Bool
    ) {
        let half: CGFloat = w / 2
        let d: CGFloat = w * 0.28
        let top: CGFloat = -h
        let apex: CGFloat = -h - rise
        Kit.shadow(&g, d * 0.5, 0, width: w + d, alpha: 0.22)
        var side = Path()
        side.move(to: CGPoint(x: half, y: 0))
        side.addLine(to: CGPoint(x: half, y: top))
        side.addLine(to: CGPoint(x: half + d, y: top - 4))
        side.addLine(to: CGPoint(x: half + d, y: -3))
        side.closeSubpath()
        Art.fill(&g, side, Kit.personTone(wall, 0.8))
        Art.fill(&g, side, ArtStyle.coolShade.opacity(0.12))
        let ridgeBack = CGPoint(x: d - 2, y: apex - 6)
        let eaveFront = CGPoint(x: half + 7, y: top + 2)
        let eaveBack = CGPoint(x: half + d + 7, y: top - 2)
        var plane = Path()
        plane.move(to: CGPoint(x: -2, y: apex - 2))
        plane.addLine(to: ridgeBack)
        plane.addLine(to: eaveBack)
        plane.addLine(to: eaveFront)
        plane.closeSubpath()
        Kit.solid(&g, plane, Art.color(roof), light: 0.2, shade: 0.2)
        var ribs = Path()
        for i in 1...5 {
            let t: CGFloat = CGFloat(i) / 6
            let rx: CGFloat = -2 + (d) * t
            let ry: CGFloat = apex - 2 - 4 * t
            let ex: CGFloat = half + 7 + d * t
            let ey: CGFloat = top + 2 - 4 * t
            ribs.addPath(Art.line(rx, ry, ex, ey))
        }
        Art.stroke(&g, ribs, Kit.personTone(roof, 0.75), width: 1)
        cabinFront(&g, width: w, height: h, rise: rise, wall: wall, boards: boards)
        var rake = Path()
        rake.move(to: CGPoint(x: -half - 6, y: top + 4))
        rake.addLine(to: CGPoint(x: 0, y: apex - 2))
        rake.addLine(to: eaveFront)
        Art.stroke(&g, rake, Kit.personTone(roof, 0.9), width: 5)
        Art.stroke(&g, rake, Art.color(0xF3E9D2, 0.5), width: 1.2)
        if door {
            cabinOpenings(&g, width: w, height: h, wall: wall)
        }
        if pipe {
            let px: CGFloat = w * 0.24
            let topY: CGFloat = apex - 22
            let slope: CGFloat = (top + 2 - apex) / (half + 7)
            let roofY: CGFloat = apex + slope * px
            Kit.solid(&g, Art.rect(px - 3, topY, 6, roofY - topY + 2), Art.color(0x8E979C), light: 0.3, shade: 0.2)
            Art.fill(&g, Art.rect(px - 4.5, topY - 3, 9, 4, radius: 1), Art.color(0x5E666C))
        }
    }

    /// The gable wall of a cabin: boards or plywood sheets.
    static func cabinFront(_ g: inout GraphicsContext, width w: CGFloat, height h: CGFloat, rise: CGFloat, wall: UInt32, boards: Bool) {
        let half: CGFloat = w / 2
        var front = Path()
        front.move(to: CGPoint(x: -half, y: 0))
        front.addLine(to: CGPoint(x: -half, y: -h))
        front.addLine(to: CGPoint(x: 0, y: -h - rise))
        front.addLine(to: CGPoint(x: half, y: -h))
        front.addLine(to: CGPoint(x: half, y: 0))
        front.closeSubpath()
        Kit.solid(&g, front, Art.color(wall), light: 0.2, shade: 0.14)
        var lines = Path()
        if boards {
            var x: CGFloat = -half + 7
            while x < half {
                lines.addPath(Art.line(x, 0, x, -h - rise))
                x += 7
            }
        } else {
            lines.addPath(Art.line(0, 0, 0, -h - rise))
            lines.addPath(Art.line(-half, -h * 0.5, half, -h * 0.5))
        }
        let seams = lines
        let weather: UInt32 = boards ? 0x6E6C64 : 0x9A8664
        Art.clipped(&g, to: front) { c in
            Art.stroke(&c, seams, Art.color(weather, 0.55), width: 1)
            Art.fill(&c, Art.rect(-half, -10, w, 10), ArtStyle.coolShade.opacity(0.1))
        }
    }

    /// A plain door left of the middle and one small window to the right.
    static func cabinOpenings(_ g: inout GraphicsContext, width w: CGFloat, height h: CGFloat, wall: UInt32) {
        let dw: CGFloat = min(30, w * 0.2)
        let dh: CGFloat = h * 0.72
        let dx: CGFloat = -w * 0.22
        let doorway = Art.rect(dx - dw / 2, -dh, dw, dh, radius: 1)
        Kit.solid(&g, doorway, Kit.personTone(wall, 0.66), light: 0.14, shade: 0.24)
        Art.stroke(&g, doorway, Kit.personTone(wall, 0.5), width: 1)
        Art.fill(&g, Art.circle(dx + dw * 0.3, -dh * 0.48, 1.4), Art.color(0xD8D2C4))
        guard w >= 60 else { return }
        let ww: CGFloat = w * 0.17
        let wh: CGFloat = h * 0.26
        let wx: CGFloat = w * 0.2 - ww / 2
        let wy: CGFloat = -h * 0.78
        let pane = Art.rect(wx, wy, ww, wh, radius: 1)
        Art.fill(&g, pane, Art.color(0x4E5E68))
        let glint: Kit.Stops = [(Art.color(0xF9D9B6, 0.7), 0), (Art.color(0xF9D9B6, 0), 1)]
        Art.fillLinear(&g, pane, glint, from: CGPoint(x: wx, y: wy), to: CGPoint(x: wx + ww, y: wy + wh))
        Art.stroke(&g, pane, Art.color(0xE6DECC), width: 2)
        Art.stroke(&g, Art.line(wx + ww / 2, wy, wx + ww / 2, wy + wh), Art.color(0xE6DECC), width: 1.2)
    }

    /// A wisp of smoke from (x, y), drifting up and to the right in the wind.
    static func smoke(_ g: inout GraphicsContext, x: CGFloat, y: CGFloat, scale s: CGFloat) {
        let puffs: [(CGFloat, CGFloat, CGFloat, Double)] = [
            (0, 0, 5, 0.42), (5, -13, 7, 0.36), (14, -26, 9, 0.3), (27, -38, 11, 0.24), (44, -48, 13, 0.17), (64, -55, 14, 0.1),
        ]
        Art.blurred(&g, radius: 3) { b in
            for puff in puffs {
                let px: CGFloat = x + puff.0 * s
                let py: CGFloat = y + puff.1 * s
                Art.fill(&b, Art.circle(px, py, puff.2 * s), Art.color(0xEFEAE2, puff.3))
            }
        }
    }
}

// MARK: - Table, tote, bucket, can, mug, kettle

extension FishCampArt {
    /// The rough plank cutting table by the water. Origin on the ground under its middle; the
    /// planks' top face is `height` + 3 above the ground.
    static func cuttingTable(_ g: inout GraphicsContext, width w: CGFloat, height h: CGFloat) {
        let half: CGFloat = w / 2
        let wood: UInt32 = 0xB7A07A
        let dark = Kit.personTone(wood, 0.62)
        Kit.shadow(&g, 4, 0, width: w * 1.1, alpha: 0.22)
        var back = Path()
        back.addPath(Art.line(-half + 12, -h, -half + 14, -4))
        back.addPath(Art.line(half - 2, -h, half, -4))
        Art.stroke(&g, back, Kit.personTone(wood, 0.55), width: 4)
        var legs = Path()
        legs.addPath(Art.line(-half + 6, -h, -half + 5, 0))
        legs.addPath(Art.line(half - 8, -h, half - 7, 0))
        Art.stroke(&g, legs, dark, width: 5)
        Art.stroke(&g, Art.line(-half + 6, -h * 0.4, half - 8, -h * 0.4), dark, width: 2.4)
        let edge = Art.rect(-half, -h - 3, w, 7, radius: 1.5)
        Kit.solid(&g, edge, Art.color(wood), light: 0.28, shade: 0.2)
        var cracks = Path()
        cracks.addPath(Art.line(-half + w * 0.36, -h - 3, -half + w * 0.36, -h + 4))
        cracks.addPath(Art.line(-half + w * 0.7, -h - 3, -half + w * 0.7, -h + 4))
        Art.stroke(&g, cracks, Kit.personTone(wood, 0.7), width: 1)
        Art.stroke(&g, Art.line(-half + 1, -h - 2.4, half - 1, -h - 2.4), Art.color(0xF3E6C8, 0.6), width: 1)
    }

    /// A plastic fish tote with two silver tails over the rim. Origin on the ground, 42 wide.
    static func tote(_ g: inout GraphicsContext) {
        Kit.shadow(&g, 2, 0, width: 46, alpha: 0.22)
        let tails: Path = Art.svg("M-8,-21 L-13,-31 L-6,-28 L-3,-31 L-4,-21Z M6,-21 L4,-30 L9,-27 L13,-29 L10,-21Z")
        Kit.solid(&g, tails, Art.color(0xA9BEC2), light: 0.3, shade: 0.16)
        let box: Path = Art.svg("M-21,-22 L21,-22 L19,0 L-19,0Z")
        Kit.solid(&g, box, Art.color(0xDAD8CE), light: 0.24, shade: 0.22)
        Art.stroke(&g, Art.line(-22, -21, 22, -21), Art.color(0xEEECE4), width: 3)
        Art.stroke(&g, Art.svg("M-12,-15 L-12,-6 M0,-15 L0,-6 M12,-15 L12,-6"), Art.color(0xB2B0A6), width: 1.2)
    }

    /// A white bucket, with red strips in it if `strips`. Origin at the middle of its bottom;
    /// the bail's top (where a hand holds it) is about 25 above.
    static func bucket(_ g: inout GraphicsContext, strips red: Bool) {
        Art.stroke(&g, Art.svg("M-8,-16 C-7,-30 7,-30 8,-16"), Art.color(0x8E979C), width: 1.2)
        if red {
            let heap: Path = Art.svg("M-7,-16 C-6,-21 -2,-22 0,-19 C2,-23 7,-21 7,-16Z")
            Kit.solid(&g, heap, Art.color(salmonRed), light: 0.26, shade: 0.16)
            let hanging: Path = Art.svg("M-8,-17 L-10,-9 L-8,-9 L-6.5,-16Z M7,-17 L9.5,-10 L7.6,-10 L5.8,-16Z")
            Art.fill(&g, hanging, Art.color(0xDA5A38))
        }
        let pail: Path = Art.svg("M-8,-17 L8,-17 L6.5,0 L-6.5,0Z")
        Kit.solid(&g, pail, Art.color(0xEAE6DA), light: 0.24, shade: 0.24)
        Art.stroke(&g, Art.line(-8.4, -16.4, 8.4, -16.4), Art.color(0xF6F3EA), width: 1.6)
        Art.stroke(&g, Art.line(-7.6, -12.5, 7.6, -12.5), Art.color(0xC9C4B6), width: 0.8)
    }

    /// A red fuel can. Origin on the ground, 14 wide.
    static func fuelCan(_ g: inout GraphicsContext) {
        Kit.shadow(&g, 1, 0, width: 18, alpha: 0.22)
        let can: Path = Art.svg("M-7,0 L-7,-14 L-3,-18 L7,-18 L7,0Z")
        Kit.solid(&g, can, Art.color(0xC8342A), light: 0.3, shade: 0.2)
        Art.stroke(&g, Art.svg("M-5,-3 L5,-15 M-5,-15 L5,-3"), Art.color(0x9E2620), width: 0.9)
        Art.stroke(&g, Art.svg("M-1,-18 L-1,-21 L5,-21 L5,-18"), Art.color(0x2E343A), width: 1.6)
        Art.stroke(&g, Art.line(-6, -18, -9, -22), Art.color(0x2E343A), width: 1.8)
    }

    /// A white enamel mug with a blue rim, round the origin (13 wide), and its steam.
    static func mug(_ g: inout GraphicsContext, steam: Bool) {
        if steam {
            let wisps: Path = Art.svg("M-2,-10 C-5,-14 1,-17 -2,-22 C-4,-25 0,-28 -1,-31 M3,-10 C1,-13 6,-16 3,-20")
            Art.stroke(&g, wisps, Color.white.opacity(0.6), width: 1.3)
        }
        Art.stroke(&g, Art.svg("M6,-5 C11,-5 11,3 6,3"), Art.color(0xE6E2D8), width: 2)
        let body = Art.rect(-6.5, -9, 13, 15, radius: 2)
        Kit.solid(&g, body, Art.color(0xF1EEE6), light: 0.22, shade: 0.22)
        Art.stroke(&g, Art.line(-6.5, -8.4, 6.5, -8.4), Art.color(0x2F5F9C), width: 1.6)
        Art.fill(&g, Art.circle(-2, -1, 1.4), Art.color(0x2F5F9C, 0.7))
    }

    /// A blue enamel kettle. Origin on the ground, about 28 across with the spout.
    static func kettle(_ g: inout GraphicsContext) {
        Kit.shadow(&g, 1, 0, width: 26, alpha: 0.22)
        Art.stroke(&g, Art.svg("M-6,-15 C-6,-24 6,-24 6,-15"), Art.color(0x2E343A), width: 1.6)
        let spout: Path = Art.svg("M-9,-8 L-17,-15 L-15,-16 L-7,-11Z")
        Kit.solid(&g, spout, Art.color(0x2F5F8C), light: 0.2, shade: 0.2)
        let body: Path = Art.svg("M-11,0 C-13,-6 -12,-13 -7,-15 L7,-15 C12,-13 13,-6 11,0Z")
        Kit.solid(&g, body, Art.color(0x2F5F8C), light: 0.32, shade: 0.2, rim: 1)
        Art.fill(&g, Art.ellipse(0, -15.5, 5, 1.6), Art.color(0x24496C))
        Art.fill(&g, Art.circle(0, -17, 1.4), Art.color(0x2E343A))
        Art.stroke(&g, Art.line(-11.5, -1, 11.5, -1), Art.color(0xE9E4D6), width: 1)
    }
}

// MARK: - A gull, fireweed, mosquitoes

extension FishCampArt {
    /// A gull waiting near the cutting table: feet at the origin, facing LEFT, 34 long.
    static func gull(_ g: inout GraphicsContext) {
        Kit.shadow(&g, 0, 0, width: 18, alpha: 0.2)
        Art.stroke(&g, Art.svg("M-3,-7 L-4,0 M2,-7 L2,0"), Art.color(0xE8A040), width: 1.2)
        let tail: Path = Art.svg("M14,-13 L22,-12 L15,-9Z")
        Art.fill(&g, tail, Art.color(0x2E343A))
        let body: Path = Art.svg("M-12,-15 C-10,-19 -4,-19 0,-17 C6,-15 13,-14 17,-12 C12,-8 4,-6 -2,-7 C-8,-8 -12,-11 -12,-15Z")
        Kit.solid(&g, body, Art.color(0xF6F4EE), light: 0.18, shade: 0.24)
        let wing: Path = Art.svg("M-3,-15 C5,-16 13,-14 19,-11 C12,-10 4,-10 -3,-12Z")
        Kit.solid(&g, wing, Art.color(0x9AA6B0), light: 0.2, shade: 0.16)
        Art.fill(&g, Art.svg("M14,-12.6 L19,-11 L14,-10.4Z"), Art.color(0x2E343A))
        Art.fill(&g, Art.circle(-10, -18, 4.6), Art.color(0xF6F4EE))
        Art.fill(&g, Art.svg("M-14,-18.4 L-19.5,-17.2 L-14,-16.4Z"), Art.color(0xF2C23A))
        ArtStyle.eye(&g, -11.4, -19.2, 0.9, showsWhite: false)
    }

    /// Fireweed: a tall stem with narrow leaves and a spike of magenta-pink flowers just
    /// opening from the bottom, buds above. Origin at the foot of the stem.
    static func fireweed(_ g: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32) {
        guard height > 0 else { return }
        var random = ArtRandom(seed)
        let lean: CGFloat = (Kit.rnd(&random) - 0.5) * height * 0.14
        let topX: CGFloat = x + lean
        let topY: CGFloat = baseY - height
        var stem = Path()
        stem.move(to: CGPoint(x: x, y: baseY))
        stem.addQuadCurve(to: CGPoint(x: topX, y: topY), control: CGPoint(x: x + lean * 0.2, y: baseY - height * 0.5))
        Art.stroke(&g, stem, Art.color(0x7A5A48), width: max(1, height * 0.018))
        var leaves = Path()
        for i in 0..<7 {
            let t: CGFloat = 0.1 + CGFloat(i) * 0.085
            let px: CGFloat = x + lean * t * t
            let py: CGFloat = baseY - height * t
            let up: Bool = i % 2 == 0
            let angle: CGFloat = up ? Kit.deg(-150) : Kit.deg(-30)
            let length: CGFloat = height * (0.2 - 0.014 * CGFloat(i))
            Kit.groundLeaf(&leaves, base: CGPoint(x: px, y: py), angle: angle, length: length, width: length * 0.14)
        }
        Art.fill(&g, leaves, Art.color(0x587848))
        var blooms = Path()
        var buds = Path()
        let r: CGFloat = max(1.2, height * 0.028)
        for i in 0..<9 {
            let t: CGFloat = 0.7 + CGFloat(i) * 0.034
            let px: CGFloat = x + lean * t * t
            let py: CGFloat = baseY - height * t
            let side: CGFloat = i % 2 == 0 ? -1 : 1
            if i < 4 {
                let fx: CGFloat = px + side * r * 1.3
                blooms.addPath(Art.circle(fx - r * 0.5, py, r * 0.75))
                blooms.addPath(Art.circle(fx + r * 0.5, py - r * 0.3, r * 0.75))
                blooms.addPath(Art.circle(fx, py + r * 0.5, r * 0.7))
            } else {
                buds.addPath(Art.ellipse(px + side * r * 0.7, py, r * 0.45, r * 0.75))
            }
        }
        Art.fill(&g, buds, Art.color(0xA0406E))
        Art.fill(&g, blooms, Art.color(0xD8418C))
        Art.fill(&g, Art.circle(topX, topY, r * 0.4), Art.color(0x8A3A5E))
    }

    /// A small cloud of mosquitoes: fine dark dots round (cx, cy).
    static func mosquitoes(_ g: inout GraphicsContext, cx: CGFloat, cy: CGFloat, scale s: CGFloat) {
        var random = ArtRandom(17)
        var dots = Path()
        var wings = Path()
        for _ in 0..<18 {
            let a: CGFloat = Kit.rnd(&random) * CGFloat.pi * 2
            let reach: CGFloat = (6 + Kit.rnd(&random) * 20) * s
            let px: CGFloat = cx + cos(a) * reach
            let py: CGFloat = cy + sin(a) * reach * 0.6
            dots.addPath(Art.circle(px, py, 0.9 * s))
            wings.addPath(Art.line(px - 1.6 * s, py - 1.2 * s, px + 1.6 * s, py - 1.2 * s))
        }
        Art.stroke(&g, wings, Color.white.opacity(0.5), width: 0.6 * s)
        Art.fill(&g, dots, Art.color(0x2E2A30, 0.75))
    }
}
