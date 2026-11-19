import SwiftUI
import OmramoCore

// The Two Sisters: the tap-to-see pictures (432 × 404), the character-card portraits
// (432 × 400), the face chips (100 × 100) and the cover. The landmark picture (the bridge)
// is drawn elsewhere.

extension SistersArt {
    // MARK: Burrard Inlet

    /// One long, calm arm of grey-green sea seen from above the water, steep dark forested
    /// mountains rising from its far shore; no buildings.
    static func inletPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = mist()
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = 214
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 330, 70, scale: 0.8, color: Color.white.opacity(0.45))
        Kit.ranges(&context, width: w, horizon: H - 30, scale: 0.9, light: light, mountains: true, seed: 9)
        let slope: Color = Art.color(0x4A6A62)
        Kit.mountain(&context, cx: 300, baseY: H + 4, width: 300, height: 128, color: slope, snow: nil, seed: 4)
        Kit.mountain(&context, cx: 120, baseY: H + 4, width: 250, height: 96, color: Art.color(0x557670), snow: nil, seed: 8)
        Kit.farTrees(&context, x0: 0, x1: w, baseY: H + 2, height: 16, count: 40, color: Art.color(0x2F4E46, 0.8), conifer: true, seed: 12)
        ArtStyle.atmosphere(&context, width: w, top: H - 140, bottom: H + 4, color: light.haze, alpha: 0.28)
        mistBand(&context, width: w, y: H - 14, height: 26, alpha: 0.5)
        // The arm of the sea narrowing into the distance between the near slopes.
        let sea: Kit.Stops = Kit.stops(0xB4C8C0, 0x7E9E94, 0x46706A)
        Kit.water(&context, width: w, top: H, bottom: h, stops: sea, light: light, ripples: 50, seed: 3)
        Kit.glints(&context, x: 180, top: H, depth: h - H, color: Color.white, count: 24, seed: 4)
        let left = Art.svg("M0,\(h) L0,236 C40,232 80,226 120,222 C150,219 168,218 176,220 C140,240 80,290 40,\(h) Z")
        Kit.solid(&context, left, stops: Kit.stops(0x2F5048, 0x1E3A34), light: 0.18, shade: 0.24)
        Kit.farTrees(&context, x0: 0, x1: 160, baseY: 230, height: 20, count: 12, color: Art.color(0x1E3A34), conifer: true, seed: 15)
        let right = Art.svg("M\(w),\(h) L\(w),230 C380,226 320,222 270,222 C300,236 350,280 380,\(h) Z")
        Kit.solid(&context, right, stops: Kit.stops(0x2A4A42, 0x18302C), light: 0.16, shade: 0.24)
        Kit.farTrees(&context, x0: 280, x1: w, baseY: 230, height: 24, count: 12, color: Art.color(0x18302C), conifer: true, seed: 17)
        let firs = firGreens()
        Kit.conifer(&context, x: 408, baseY: 300, height: 110, palette: firs, seed: 3)
        Kit.conifer(&context, x: 22, baseY: 310, height: 96, palette: firs, seed: 5)
        Kit.birds(&context, 250, 150, scale: 0.8, color: Art.color(0x6E8F86, 0.6))
        Kit.sink(&context, size, card: 0x1F4A4A)
    }

    // MARK: Salmon

    /// A silver salmon facing LEFT, about 100 long at scale 1, centred on its middle.
    static func salmon(_ context: inout GraphicsContext) {
        let tail = Art.svg("M36,-4 C42,-8 47,-14 53,-18 C51,-8 51,6 54,16 C47,12 42,7 36,4 Z")
        Kit.solid(&context, tail, Art.color(0x6A8290), light: 0.24, shade: 0.24)
        let fins = Art.svg("M-4,-15 C0,-24 6,-26 12,-26 C10,-20 10,-16 12,-13 Z M24,-11 L28,-16 L30,-10 Z M-14,13 C-12,20 -6,23 0,22 C-2,18 -4,15 -4,12 Z M14,12 C16,18 20,20 24,19 C22,16 21,13 20,10 Z")
        Art.fill(&context, fins, Art.color(0x5E7684))
        let body = Art.svg("M-50,0 C-46,-9 -32,-15 -12,-16 C8,-16 26,-11 38,-4 L38,4 C26,11 8,15 -12,15 C-32,14 -46,8 -50,0 Z")
        let silver: Kit.Stops = [(Art.color(0x4E6A78), 0), (Art.color(0x9AB0B8), 0.42), (Art.color(0xE8EEEE), 0.62), (Art.color(0xF6F6F2), 1)]
        Kit.solid(&context, body, stops: silver, light: 0.32, shade: 0.18, rim: 1.4)
        Art.clipped(&context, to: body) { g in
            var spots = Path()
            let marks: [(CGFloat, CGFloat)] = [(-20, -11), (-10, -12), (0, -12), (10, -10), (20, -8), (28, -6), (-4, -8), (14, -6)]
            for m in marks {
                spots.addPath(Art.ellipse(m.0, m.1, 1.2, 0.9))
            }
            Art.fill(&g, spots, Art.color(0x2E4250, 0.6))
            Art.stroke(&g, Art.svg("M-36,-1 C-16,-2 10,-1 36,0"), Art.color(0xE6A8A0, 0.45), width: 2.2)
            Art.fill(&g, Art.svg("M-50,0 C-46,-9 -40,-12 -34,-13 C-34,-4 -34,6 -34,11 C-42,8 -48,4 -50,0 Z"), Art.color(0x7A92A0, 0.35))
        }
        Art.stroke(&context, Art.svg("M-34,-12 C-31,-6 -31,4 -34,10"), Art.color(0x5E7684, 0.7), width: 1.2)
        ArtStyle.eye(&context, -41, -3, 2.4, look: CGPoint(x: -0.4, y: 0), iris: Art.color(0x1E2228), showsWhite: false)
        Art.stroke(&context, Art.svg("M-50,1 C-47,3 -44,3.5 -41,3"), Art.color(0x3E5260), width: 1)
    }

    /// One large silver salmon leaping clear of a rushing river, spray from its tail, cedar
    /// shadows behind.
    static func salmonPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let back: Kit.Stops = [(Art.color(0x5E6E5E), 0), (Art.color(0x3E4A40), 0.6), (Art.color(0x3A2E2A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 110, 60, 220, Art.color(0xF3D6A8), alpha: 0.35)
        // Cedar trunks and drooping boughs in shadow behind the river.
        var trunks = Path()
        let stems: [(CGFloat, CGFloat)] = [(84, 22), (150, 16), (300, 26), (380, 18)]
        for stem in stems {
            trunks.addPath(Art.rect(stem.0, 0, stem.1, 270))
        }
        Art.fill(&context, trunks, Art.color(0x4A3A32, 0.7))
        var boughs = Path()
        let drops: [(CGFloat, CGFloat)] = [(60, 70), (140, 40), (310, 60), (392, 110), (20, 150)]
        for d in drops {
            boughs.move(to: CGPoint(x: d.0 - 50, y: d.1))
            boughs.addQuadCurve(to: CGPoint(x: d.0 + 50, y: d.1 + 26), control: CGPoint(x: d.0, y: d.1 - 22))
        }
        Art.stroke(&context, boughs, Art.color(0x2E4A3A, 0.7), width: 9)
        ArtStyle.atmosphere(&context, width: w, top: 0, bottom: 270, color: Art.color(0xC8D4CC), alpha: 0.25)
        // The river, rushing from left to right.
        let river: Kit.Stops = Kit.stops(0x9ABCB6, 0x4E7A74, 0x2E4A48)
        Art.fillLinear(&context, Art.rect(0, 250, w, h - 250), river, from: CGPoint(x: 0, y: 250), to: CGPoint(x: 0, y: h))
        Kit.swells(&context, width: w, top: 254, bottom: 340, rows: 6, crest: Color.white, seed: 21)
        var rush = Path()
        var random = ArtRandom(17)
        for _ in 0..<26 {
            let rx: CGFloat = Kit.rnd(&random) * w
            let ry: CGFloat = 256 + Kit.rnd(&random) * 70
            let len: CGFloat = 18 + Kit.rnd(&random) * 34
            rush.move(to: CGPoint(x: rx, y: ry))
            rush.addLine(to: CGPoint(x: rx + len, y: ry + 1))
        }
        Art.stroke(&context, rush, Color.white.opacity(0.5), width: 1.4)
        Kit.rock(&context, cx: 70, baseY: 290, width: 70, height: 30, color: 0x4A4A44, seed: 3)
        // The leap: spray first, then the fish.
        var spray = Path()
        spray.move(to: CGPoint(x: 300, y: 262))
        spray.addQuadCurve(to: CGPoint(x: 330, y: 200), control: CGPoint(x: 300, y: 226))
        spray.move(to: CGPoint(x: 280, y: 266))
        spray.addQuadCurve(to: CGPoint(x: 296, y: 214), control: CGPoint(x: 278, y: 236))
        spray.move(to: CGPoint(x: 320, y: 264))
        spray.addQuadCurve(to: CGPoint(x: 352, y: 222), control: CGPoint(x: 330, y: 236))
        Art.stroke(&context, spray, Color.white.opacity(0.6), width: 2)
        Kit.flecks(&context, in: CGRect(x: 270, y: 170, width: 110, height: 90), count: 26, seed: 5, color: Color.white, radius: 1...2.6)
        Art.group(&context, x: 214, y: 176, rotate: -0.32, scale: 2.5) { g in
            salmon(&g)
        }
        Kit.ripples(&context, 300, 268, 80, count: 2, color: Color.white, opacity: 0.6)
        Kit.sink(&context, size, card: 0x3A2E2A)
    }

    // MARK: Feast

    /// A long row of carved wooden bowls of salmon and berries on woven cedar mats; no people.
    static func feastPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        // A wall of wide cedar planks in warm firelight.
        let wall: Kit.Stops = Kit.stops(0x8A6248, 0x6A4634, 0x5A3420)
        Art.fillLinear(&context, Art.rect(0, 0, w, h), wall, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        var seams = Path()
        for i in 1..<6 {
            let y: CGFloat = CGFloat(i) * 30
            seams.move(to: CGPoint(x: 0, y: y))
            seams.addLine(to: CGPoint(x: w, y: y + 2))
        }
        Art.stroke(&context, seams, Art.color(0x4A2E22, 0.6), width: 1.4)
        Art.fill(&context, Art.rect(352, 0, 16, 180), Art.color(0x5A3A2C))
        Art.glow(&context, 80, 90, 260, Art.color(0xFFC88A), alpha: 0.32)
        // The mat, running back from the front right toward the back left.
        let mat = Art.polygon([Kit.pt(30, 178), Kit.pt(160, 160), Kit.pt(432, 238), Kit.pt(432, 300), Kit.pt(250, 300)])
        Kit.solid(&context, mat, Art.color(bark), light: 0.24, shade: 0.24)
        Art.clipped(&context, to: mat) { g in
            var weave = Path()
            var x: CGFloat = 0
            while x < 520 {
                weave.move(to: CGPoint(x: x, y: 150))
                weave.addLine(to: CGPoint(x: x + 120, y: 310))
                x += 14
            }
            Art.stroke(&g, weave, Art.color(barkDark, 0.6), width: 1.4, dash: [6, 5])
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: 150, width: 432, height: 160), seed: 9, color: Color.white, alpha: 0.08)
        }
        Art.stroke(&context, Art.svg("M30,178 L250,300"), Art.color(0xD0AE80, 0.6), width: 1.6)
        // The bowls, smallest at the back.
        let bowls: [(CGFloat, CGFloat, CGFloat, Int)] = [(96, 190, 48, 1), (156, 206, 58, 0), (226, 226, 70, 2), (310, 252, 86, 0)]
        for b in bowls {
            feastBowl(&context, cx: b.0, baseY: b.1, width: b.2, filling: b.3)
        }
        Kit.sink(&context, size, card: 0x5A3420)
    }

    /// A plain carved wooden bowl, oblong with raised ends, heaped with salmon (0), salmonberries
    /// (1) or dark huckleberries (2).
    static func feastBowl(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width w: CGFloat, filling: Int) {
        Kit.shadow(&context, cx, baseY, width: w * 1.1, alpha: 0.3)
        let rimY: CGFloat = baseY - w * 0.36
        let heap = Art.svg("M\(cx - w * 0.44),\(rimY + 1) C\(cx - w * 0.3),\(rimY - w * 0.3) \(cx + w * 0.3),\(rimY - w * 0.3) \(cx + w * 0.44),\(rimY + 1) Z")
        switch filling {
        case 1:
            Kit.solid(&context, heap, Art.color(0xE88A3A), light: 0.3, shade: 0.2)
            berries(&context, cx: cx, y: rimY - w * 0.1, w: w, color: 0xF2A040, seed: 3)
        case 2:
            Kit.solid(&context, heap, Art.color(0x3A3456), light: 0.25, shade: 0.2)
            berries(&context, cx: cx, y: rimY - w * 0.1, w: w, color: 0x4E4A78, seed: 5)
        default:
            Kit.solid(&context, heap, Art.color(0xE0704A), light: 0.3, shade: 0.2)
            var flakes = Path()
            flakes.move(to: CGPoint(x: cx - w * 0.3, y: rimY - w * 0.06))
            flakes.addQuadCurve(to: CGPoint(x: cx + w * 0.3, y: rimY - w * 0.06), control: CGPoint(x: cx, y: rimY - w * 0.26))
            Art.stroke(&context, flakes, Art.color(0xF4B48E, 0.8), width: 1.2)
        }
        let s: CGFloat = w / 100
        let body = Kit.placed("M-56,-44 C-50,-38 -46,-36 -40,-36 L40,-36 C46,-36 50,-38 56,-44 C54,-30 46,-8 30,0 L-30,0 C-46,-8 -54,-30 -56,-44 Z", x: cx, y: baseY, scale: s)
        Kit.solid(&context, body, Art.color(0x7A4A2E), light: 0.32, shade: 0.28, rim: 1.2)
        let lip = Kit.placed("M-52,-40 C-46,-36 -42,-35 -38,-35 L38,-35 C42,-35 46,-36 52,-40", x: cx, y: baseY, scale: s)
        Art.stroke(&context, lip, Art.color(0xC48A5E, 0.8), width: 1.2)
        let groove = Kit.placed("M-42,-22 C-20,-18 20,-18 42,-22", x: cx, y: baseY, scale: s)
        Art.stroke(&context, groove, Art.color(0x5A3420, 0.6), width: 1)
    }

    /// A heap of small round berries along the top of a bowl.
    static func berries(_ context: inout GraphicsContext, cx: CGFloat, y: CGFloat, w: CGFloat, color: UInt32, seed: UInt32) {
        var random = ArtRandom(seed)
        var dots = Path()
        var shine = Path()
        for _ in 0..<12 {
            let bx: CGFloat = cx + (Kit.rnd(&random) - 0.5) * w * 0.7
            let by: CGFloat = y + (Kit.rnd(&random) - 0.3) * w * 0.12
            let r: CGFloat = w * 0.045
            dots.addPath(Art.circle(bx, by, r))
            shine.addPath(Art.circle(bx - r * 0.35, by - r * 0.4, r * 0.3))
        }
        Art.fill(&context, dots, Art.color(color))
        Art.fill(&context, shine, Color.white.opacity(0.5))
    }

    // MARK: Cedar canoe

    /// One long red-brown dugout canoe with a raised bow, drawn up on a pebble beach, its
    /// paddles laid inside; no painted designs.
    static func canoePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = mist()
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = 150
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.ranges(&context, width: w, horizon: H, scale: 0.8, light: light, mountains: true, seed: 5)
        mistBand(&context, width: w, y: H - 6, height: 20, alpha: 0.5)
        let sea: Kit.Stops = Kit.stops(0xB4C8C0, 0x86A49A)
        Kit.water(&context, width: w, top: H, bottom: 200, stops: sea, light: light, ripples: 16, seed: 7)
        let beach = Art.svg("M0,\(h) L0,196 C120,190 300,186 432,192 L432,\(h) Z")
        Kit.solid(&context, beach, stops: Kit.stops(0xB6B2A6, 0x8A867A), light: 0.18, shade: 0.2)
        Art.stroke(&context, Art.svg("M0,196 C120,190 300,186 432,192"), Color.white.opacity(0.55), width: 1.6)
        Kit.pebbles(&context, in: CGRect(x: 0, y: 204, width: w, height: 120), count: 60, seed: 11, color: 0x9A9488)
        driftLog(&context, x: 352, y: 206, length: 110, tilt: 0.03)
        // The canoe, bow raised to the left.
        let cx: CGFloat = 214
        let baseY: CGFloat = 236
        canoe(&context, cx: cx, waterY: baseY, length: 300, riders: [], paddlesUp: false, beached: true)
        // Two paddles laid inside, shafts along the hull, blades resting on the far gunwale.
        let paddles = Art.svg("M120,222 L290,218 M150,226 L320,224")
        Art.stroke(&context, paddles, Art.color(plankDark), width: 3)
        let blades = Art.svg("M290,218 C300,214 316,214 330,218 C316,222 300,222 290,218 Z M320,224 C330,220 346,220 358,224 C346,228 330,228 320,224 Z")
        Kit.solid(&context, blades, Art.color(plank), light: 0.3, shade: 0.2)
        Art.stroke(&context, Art.svg("M74,227 C66,224 60,222 54,220"), Art.color(cedarDark, 0.5), width: 1)
        Kit.rock(&context, cx: 60, baseY: 290, width: 50, height: 22, color: 0x7A766C, seed: 3)
        Kit.sink(&context, size, card: 0x4A2A1E)
    }

    // MARK: Portraits

    /// A cedar-bark cape over a bust's shoulders (bust units: the head centre at the origin).
    static func bustCape(_ context: inout GraphicsContext, tone: UInt32) {
        let cape = Art.svg("M-62,112 L-61,64 C-60,46 -40,38 -14,36 L14,36 C40,38 60,46 61,64 L62,112 C30,122 -30,122 -62,112 Z")
        Kit.solid(&context, cape, Art.color(tone), light: 0.26, shade: 0.24)
        var rows = Path()
        let ys: [CGFloat] = [56, 72, 88, 104]
        for y in ys {
            rows.move(to: CGPoint(x: -60, y: y))
            rows.addQuadCurve(to: CGPoint(x: 60, y: y), control: CGPoint(x: 0, y: y + 8))
        }
        Art.stroke(&context, rows, Kit.personTone(tone, 0.74), width: 1.2, dash: [3, 2.2])
        var fringe = Path()
        var fx: CGFloat = -58
        while fx <= 58 {
            let fy: CGFloat = 112 + 8 * (1 - (fx * fx) / 3600)
            fringe.move(to: CGPoint(x: fx, y: fy))
            fringe.addLine(to: CGPoint(x: fx + 1, y: fy + 9))
            fx += 5
        }
        Art.stroke(&context, fringe, Kit.personTone(tone, 0.8), width: 1.6)
    }

    /// The two sisters half figure, side by side, holding hands, in cedar-bark capes, calm;
    /// a pale misty sea behind.
    static func sistersPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xE9EFEE, bottom: 0x3F6A66, halo: 0xF6E6D2, rays: false) { g in
            let far = Kit.peaks(width: 432, y: 236, amp: 40, seed: 5, bottom: 400, sharp: 0.3)
            Art.fill(&g, far, Art.color(0x9DB4AE, 0.55))
            Art.fill(&g, Art.rect(0, 238, 432, 162), Art.color(0x7E9E96, 0.5))
            mistBand(&g, width: 432, y: 236, height: 30, alpha: 0.5)
            Kit.birds(&g, 340, 90, scale: 0.8, color: Art.color(0x6E8F86, 0.5))
            let younger = youngerSisterLook()
            let elder = elderSisterLook()
            Art.group(&g, x: 290, y: 148, scale: 1.45) { b in
                Kit.bust(&b, younger, look: CGPoint(x: -0.2, y: 0), mouth: .smile)
                bustCape(&b, tone: bark)
                Kit.personHead(&b, younger, look: CGPoint(x: -0.2, y: 0), mouth: .smile)
            }
            Art.group(&g, x: 146, y: 138, scale: 1.52) { b in
                Kit.bust(&b, elder, look: CGPoint(x: 0.2, y: 0), mouth: .smile)
                bustCape(&b, tone: 0xA88456)
                Kit.personHead(&b, elder, look: CGPoint(x: 0.2, y: 0), mouth: .smile)
            }
            // Their joined hands at the foot of the frame.
            Art.stroke(&g, Art.svg("M196,330 Q206,352 214,368"), Art.color(elder.cloth), width: 16)
            Art.stroke(&g, Art.svg("M240,334 Q230,354 222,368"), Art.color(younger.cloth), width: 15)
            Kit.solid(&g, Art.ellipse(218, 372, 14, 12), Art.color(skin), light: 0.3, shade: 0.22)
            Art.stroke(&g, Art.svg("M212,366 L224,378"), Kit.personTone(skin, 0.75), width: 1.2)
        }
    }

    /// The chief head and shoulders in his plain cream wool blanket, grey hair, a calm,
    /// weighing look; forested mountains and mist behind.
    static func chiefPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xE6EEE9, bottom: 0x2E5A52, halo: 0xF4E6D0, rays: false) { g in
            Kit.mountain(&g, cx: 90, baseY: 300, width: 260, height: 120, color: Art.color(0x8FA89E, 0.8), snow: nil, seed: 6)
            Kit.mountain(&g, cx: 360, baseY: 300, width: 280, height: 140, color: Art.color(0x7E9A90, 0.8), snow: nil, seed: 9)
            mistBand(&g, width: 432, y: 250, height: 40, alpha: 0.5)
            Kit.farTrees(&g, x0: 0, x1: 432, baseY: 300, height: 40, count: 26, color: Art.color(0x3E5E57, 0.7), conifer: true, seed: 14)
            let p = chiefLook()
            Art.group(&g, x: 216, y: 142, scale: 1.7) { b in
                Kit.bust(&b, p, look: CGPoint(x: -0.15, y: 0.05), mouth: .flat)
                let blanket = Art.svg("M-66,150 L-64,66 C-62,46 -42,38 -16,36 C-4,48 8,60 20,74 C34,60 44,46 50,40 C60,46 64,56 64,68 L66,150 Z")
                Kit.solid(&b, blanket, Art.color(wool), light: 0.28, shade: 0.26)
                var folds = Path()
                folds.move(to: CGPoint(x: -16, y: 38))
                folds.addQuadCurve(to: CGPoint(x: 22, y: 76), control: CGPoint(x: 0, y: 62))
                folds.move(to: CGPoint(x: -40, y: 70))
                folds.addQuadCurve(to: CGPoint(x: -30, y: 140), control: CGPoint(x: -44, y: 104))
                folds.move(to: CGPoint(x: 40, y: 84))
                folds.addQuadCurve(to: CGPoint(x: 46, y: 140), control: CGPoint(x: 48, y: 110))
                Art.stroke(&b, folds, Art.color(0xC4B696), width: 1.6)
                Art.stroke(&b, Art.svg("M-16,36 C-4,48 8,60 20,74 C34,60 44,46 50,40"), Art.color(0x9A7E5A, 0.8), width: 2.4)
                Kit.personHead(&b, p, look: CGPoint(x: -0.15, y: 0.05), mouth: .flat)
            }
        }
    }

    // MARK: Faces

    static func sistersFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFBE1D3) { g in
            Art.group(&g, x: 19, y: 10, scale: 0.78) { f in
                Kit.personHead(&f, youngerSisterLook(), look: CGPoint(x: -0.2, y: 0), mouth: .smile)
            }
            Art.group(&g, x: -17, y: 6, scale: 0.84) { f in
                Kit.personHead(&f, elderSisterLook(), look: CGPoint(x: 0.2, y: 0), mouth: .smile)
            }
        }
    }

    static func chiefFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xDDEFE8) { g in
            Kit.solid(&g, Art.svg("M-46,60 L-44,40 C-40,30 -26,26 -8,26 L8,26 C26,26 40,30 44,40 L46,60 Z"), Art.color(wool), light: 0.26, shade: 0.24)
            Art.group(&g, x: 0, y: 0, scale: 1.2) { f in
                Kit.personHead(&f, chiefLook(), look: .zero, mouth: .flat)
            }
        }
    }

    // MARK: Cover

    /// Dawn on the shore: the two sisters hand in hand at the water's edge, seen from behind,
    /// watching a line of long cedar canoes come in across the misty inlet; high above, the
    /// two rounded snowy peaks side by side.
    static func coverPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let light = mist()
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let area = CGSize(width: 240, height: hd)
            Kit.sky(&g, area, horizon: H, light: light)
            Kit.sun(&g, 52, H - 10 * k, 7 * k, light: light)
            twinPeaks(&g, cx: 150, baseY: H - 30 * k, scale: 0.8 * k, rock: Art.color(0x9DB0B0), snow: Art.color(0xFAF2EA), glow: Art.color(0xFFE6C8), seed: 4)
            let range = Kit.peaks(width: 240, y: H - 20 * k, amp: 26 * k, seed: 13, bottom: H + 4, sharp: 0.3)
            Art.fill(&g, range, light.far.opacity(0.8))
            ArtStyle.atmosphere(&g, width: 240, top: H - 60 * k, bottom: H + 4, color: light.haze, alpha: 0.35)
            let ridge = Kit.ridge(width: 240, y: H - 8 * k, amp: 6 * k, seed: 23, bottom: H + 4)
            Art.fill(&g, ridge, light.mid)
            mistBand(&g, width: 240, y: H - 2, height: 14 * k, alpha: 0.6)
            let sea: Kit.Stops = Kit.stops(0xB8CCC4, 0x7E9E96, 0x4A746C)
            Kit.water(&g, width: 240, top: H, bottom: hd, stops: sea, light: light, ripples: 24, seed: 9)
            Kit.glints(&g, x: 52, top: H, depth: hd - H, color: Color.white, count: 16, seed: 3)
            // The line of canoes coming in.
            let few: [Rider] = [(x: -24, cloth: bark, kind: 0), (x: -4, cloth: wool, kind: 1), (x: 16, cloth: 0x9A7652, kind: 2), (x: 32, cloth: 0x8C6A4A, kind: 0)]
            let line: [(CGFloat, CGFloat, CGFloat)] = [(170, 4, 22), (204, 7, 26), (136, 10, 30), (186, 15, 38)]
            for c in line {
                inboundCanoe(&g, x: c.0, y: H + c.1 * k, length: c.2 * k, riders: few, up: true)
            }
            // The near shore and the two sisters, hand in hand.
            let shoreY: CGFloat = H + 34 * k
            let shore = Art.svg("M-4,\(hd + 4) L-4,\(shoreY) C50,\(shoreY - 6) 120,\(shoreY - 2) 244,\(shoreY + 6) L244,\(hd + 4) Z")
            Kit.solid(&g, shore, stops: Kit.stops(0xA8A498, 0x7A766C), light: 0.18, shade: 0.2)
            Art.stroke(&g, Art.svg("M-4,\(shoreY) C50,\(shoreY - 6) 120,\(shoreY - 2) 244,\(shoreY + 6)"), Color.white.opacity(0.6), width: 1.2)
            Kit.pebbles(&g, in: CGRect(x: 0, y: shoreY + 4, width: 240, height: max(8, hd - shoreY - 4)), count: 20, seed: 5, color: 0x9A9488)
            let feet: CGFloat = min(hd - 6, shoreY + 10 * k)
            Art.group(&g, x: 104, y: feet, scale: 0.42 * k) { s in
                sistersBack(&s)
            }
            Kit.cornerLeaves(&g, size: area, corner: 1, color: Art.color(0x1E3A34), scale: 0.42, seed: 3)
        }
    }
}
