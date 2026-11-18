import SwiftUI
import OmramoCore

// The smaller pictures of "The Peasant and the Bear": the three tap-to-see pictures, the two
// character-card portraits, the three face chips and the cover.

extension PeasantBearArt {
    // MARK: Tap-to-see pictures (432 × 404)

    /// see-forest: the edge of the great forest — four white birches in light leaf in front
    /// of dark pointed spruces, a strip of grass below. No people, no animals. Card #1E5A3C.
    static func forestPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = 250
        let light = summer()
        Kit.sky(&context, size, horizon: H, light: light)
        // The forest goes on and on behind: a pale far line of spruce tops.
        Kit.farTrees(&context, x0: 0, x1: w, baseY: H + 2, height: 64, count: 15, color: light.far, conifer: true, seed: 4)
        ArtStyle.atmosphere(&context, width: w, top: H - 96, bottom: H + 4, color: light.haze, alpha: 0.5)

        let turf: Kit.Stops = [(Art.color(0xA6D272), 0), (Art.color(0x4F8F45), 0.45), (Art.color(0x1E5A3C), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: turf)

        // Middle: the dark spruces.
        let pines: Kit.Greens = Kit.pineGreens()
        let spruces: [(CGFloat, CGFloat, CGFloat)] = [(112, 258, 150), (176, 254, 196), (246, 256, 214), (312, 254, 186), (368, 260, 150)]
        var seed: UInt32 = 3
        for spruce in spruces {
            Kit.conifer(&context, x: spruce.0, baseY: spruce.1, height: spruce.2, palette: pines, seed: seed)
            seed = seed &+ 2
        }
        // A breath of air between the spruces and the birches.
        ArtStyle.atmosphere(&context, width: w, top: 40, bottom: 262, color: light.haze, alpha: 0.12)

        // The subject's front rank: the birches, white in the light.
        let leaves: Kit.Greens = Kit.springGreens()
        let birches: [(CGFloat, CGFloat, CGFloat)] = [(140, 276, 212), (208, 286, 238), (278, 279, 222), (338, 288, 198)]
        seed = 2
        for birch in birches {
            Kit.birch(&context, x: birch.0, baseY: birch.1, height: birch.2, palette: leaves, seed: seed)
            seed = seed &+ 3
        }
        Kit.bush(&context, x: 94, baseY: 284, width: 70, palette: Kit.summerGreens(), seed: 6)
        Kit.bush(&context, x: 380, baseY: 290, width: 62, palette: Kit.summerGreens(), seed: 9)

        // The strip of grass, with a few small flowers.
        let strip = CGRect(x: 30, y: 266, width: 372, height: 30)
        Kit.grass(&context, in: strip, count: 60, seed: 5, color: Art.color(0x3B7E3A), height: 9)
        Kit.grass(&context, in: strip, count: 40, seed: 6, color: Art.color(0xC4E88A), height: 7)
        Kit.flowers(&context, in: strip, count: 12, seed: 7, petal: 0xFFF3A0)
        Kit.sink(&context, size, card: 0x1E5A3C)
    }

    /// see-turnip: one round, slightly flat turnip, pale yellow-white, with its tuft of fresh
    /// green leaves and a little dark soil still on its thin root tail. Card #3F6B2A.
    static func turnipPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let back: Kit.Stops = [(Art.color(0xFFF6D8), 0), (Art.color(0xE6E6A8), 0.55), (Art.color(0x8FB25E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 320))
        Art.glow(&context, 196, 150, 210, Art.color(0xFFFBE6), alpha: 0.75)

        // The dark earth it was pulled from, low and quiet.
        let soil: Path = Art.svg("M40,330 C110,296 322,296 392,330 C330,344 102,344 40,330Z")
        Kit.solid(&context, soil, Art.color(0x5B3A1E), light: 0.18, shade: 0.2)
        ArtStyle.contactShadow(&context, 224, 314, 104, 11, alpha: 0.3)

        let cx: CGFloat = 216
        let cy: CGFloat = 204
        let r: CGFloat = 88
        // Two outer leaves that droop to the sides, behind the tuft.
        var outer = Path()
        let crown = CGPoint(x: cx, y: cy - r * 0.7)
        Kit.groundLeaf(&outer, base: crown, angle: Kit.deg(-172), length: 112, width: 44)
        Kit.groundLeaf(&outer, base: crown, angle: Kit.deg(-8), length: 108, width: 42)
        Kit.solid(&context, outer, Art.color(0x3B7E3A), light: 0.18, shade: 0.2)
        let veins: Path = Art.svg("M216,142 L128,130 M216,142 L302,130")
        Art.stroke(&context, veins, Art.color(0xB6DE78, 0.7), width: 2)

        turnip(&context, x: cx, y: cy, r: r, tops: true)

        // What the small turnips cannot show: the rings round the shoulder, the fine root
        // hairs, a rim of light, and the soil on the tail.
        let rings: Path = Art.svg("M150,172 C186,184 246,184 282,172 M140,196 C184,210 250,210 292,196")
        Art.stroke(&context, rings, Art.color(0xD9B96A, 0.45), width: ArtStyle.detailLine)
        let hairs: Path = Art.svg("M212,286 l-12,8 M220,292 l12,6 M214,300 l-9,7")
        Art.stroke(&context, hairs, Art.color(0xC9A86A), width: 1.4)
        ArtStyle.rimLight(&context, cx - 8, cy - 6, 78, alpha: 0.3)
        let crumbs = CGRect(x: 200, y: 286, width: 32, height: 30)
        Art.stipple(&context, in: crumbs, count: 26, seed: 8, color: Art.color(0x43291A), alpha: 0.8, size: 1.0...2.6)
        Kit.sink(&context, size, card: 0x3F6B2A)
    }

    /// see-rye: one sheaf of golden rye tied in the middle with a twist of straw, its long
    /// bearded ears nodding at the top. Card #8A5A14.
    static func ryePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let back: Kit.Stops = [(Art.color(0xFFF6D8), 0), (Art.color(0xF6DC9A), 0.6), (Art.color(0xC9963A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 330))
        Art.glow(&context, 190, 150, 220, Art.color(0xFFFBE6), alpha: 0.7)
        // Stubble under it.
        let ground: Kit.Stops = [(Art.color(0xD9B45A), 0), (Art.color(0x8A5A14), 1)]
        Art.fillLinear(&context, Art.rect(0, 292, w, h - 292), ground, from: CGPoint(x: 0, y: 292), to: CGPoint(x: 0, y: h))
        let strip = CGRect(x: 20, y: 296, width: w - 40, height: 20)
        Kit.grass(&context, in: strip, count: 46, seed: 3, color: Art.color(0xF6E2A6, 0.8), height: 6)

        // The nodding ears behind the sheaf's own, then the sheaf, then the ears in front.
        ryeEars(&context, cx: 216, topY: 96, back: true)
        Kit.sheaf(&context, cx: 216, baseY: 300, height: 236, color: ryeHex)
        ryeEars(&context, cx: 216, topY: 96, back: false)
        // The twist of straw that ties it.
        let twist: Path = Art.svg("M196,188 C208,198 224,198 236,188 M197,196 C209,205 223,205 235,196")
        Art.stroke(&context, twist, Art.color(0xF6DC8A), width: 2.4)
        Art.stroke(&context, Art.svg("M236,192 C246,196 250,204 248,214"), Art.color(0xC9982E), width: 2.4)
        Kit.sink(&context, size, card: 0x8A5A14)
    }

    /// The long bearded ears of a big sheaf whose crown is at (cx, topY): each on a stalk that
    /// bends outward and nods, with its awns. `back` draws the darker ones behind.
    static func ryeEars(_ context: inout GraphicsContext, cx: CGFloat, topY: CGFloat, back: Bool) {
        let fans: [CGFloat] = back ? [-1, -0.62, -0.2, 0.3, 0.72, 1] : [-0.82, -0.42, 0.06, 0.5, 0.88]
        var stalks = Path()
        var ears = Path()
        var awns = Path()
        for fan in fans {
            let reach: CGFloat = back ? 96 : 74
            let rise: CGFloat = back ? 58 : 34
            let root = CGPoint(x: cx + fan * 44, y: topY + 14)
            let droop: CGFloat = abs(fan) * 40
            let neck = CGPoint(x: cx + fan * reach, y: topY - rise + droop)
            let bend = CGPoint(x: cx + fan * reach * 0.6, y: topY - rise - 26)
            stalks.move(to: root)
            stalks.addQuadCurve(to: neck, control: bend)
            // The ear hangs from the neck, outward and down.
            let a: CGFloat = Kit.deg(90 - fan * 62)
            Kit.groundLeaf(&ears, base: neck, angle: a, length: 40, width: 13)
            let dx: CGFloat = cos(a)
            let dy: CGFloat = sin(a)
            for step in 0..<4 {
                let t: CGFloat = 10 + 9 * CGFloat(step)
                let from = CGPoint(x: neck.x + dx * t, y: neck.y + dy * t)
                let side: CGFloat = step % 2 == 0 ? 1 : -1
                let ax: CGFloat = from.x + dx * 20 - dy * 9 * side
                let ay: CGFloat = from.y + dy * 20 + dx * 9 * side
                awns.move(to: from)
                awns.addLine(to: CGPoint(x: ax, y: ay))
            }
        }
        let stalkTone: Color = back ? Art.color(0xB8892A) : Art.color(0xC9982E)
        let earTone: Color = back ? Art.color(0xD9A632) : Art.color(0xF0C552)
        Art.stroke(&context, stalks, stalkTone, width: 2.2)
        Art.stroke(&context, awns, Art.color(0xF6DC8A, back ? 0.7 : 0.95), width: 1.1)
        Kit.solid(&context, ears, earTone, light: 0.22, shade: 0.16)
    }

    // MARK: Portraits (432 × 400)

    /// char-peasant: the Peasant to the waist, facing us with a small smile, in his red shirt
    /// and cap, holding a round turnip up by its leaves. Card gold #FFD98A → #E88A4A.
    static func peasantPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let p = peasantLook()
        Kit.portrait(&context, size, top: 0xFFD98A, bottom: 0xE88A4A, halo: 0xFFF6D8, rays: true) { g in
            Art.group(&g, x: 204, y: 150, scale: 2.2) { b in
                Kit.bust(&b, p, look: .zero, mouth: .smile, wave: true)
                // The turnip hangs from his raised fist by its leaves.
                Art.stroke(&b, Art.svg("M69,2 L70,24 M73,2 L72,24"), Art.color(0x3B7E3A), width: 3)
                turnip(&b, x: 71, y: 40, r: 17, tops: false)
                var tuft = Path()
                let grip = CGPoint(x: 71, y: -4)
                Kit.groundLeaf(&tuft, base: grip, angle: Kit.deg(-128), length: 24, width: 11)
                Kit.groundLeaf(&tuft, base: grip, angle: Kit.deg(-90), length: 30, width: 12)
                Kit.groundLeaf(&tuft, base: grip, angle: Kit.deg(-52), length: 24, width: 11)
                Kit.solid(&b, tuft, Art.color(topsHex), light: 0.2, shade: 0.18)
                Art.stroke(&b, Art.svg("M71,-4 L71,-28 M71,-4 L58,-20 M71,-4 L84,-20"), Art.color(0xB6DE78, 0.7), width: 1)
                let fist: Path = Art.circle(71, 0, 10.5)
                Kit.solid(&b, fist, Art.color(p.skin), light: 0.2, shade: 0.18)
                Art.stroke(&b, Art.svg("M64,-2 q7,4 14,0 M65,3 q6,3 12,0"), Kit.personTone(p.skin, 0.72), width: 1)
            }
        }
    }

    /// char-bear: the Bear sitting upright, round and shaggy, a turnip leaf in the corner of
    /// his mouth and his eyebrows up: puzzled. Card green #CFE8B0 → #5E9E5A.
    static func bearPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let spec = bearSpec()
        Kit.portrait(&context, size, top: 0xCFE8B0, bottom: 0x5E9E5A, halo: 0xFFF8DC, rays: true) { g in
            Art.group(&g, x: 216, y: 150, scale: 2.2) { b in
                Kit.beastBust(&b, spec, mood: .surprised, look: CGPoint(x: 0.35, y: -0.3), wave: false)
                // His thick eyebrows, right up.
                Art.stroke(&b, Kit.faceBoth("M-21,-18 q6.5,-7 13.5,-2.5"), Art.color(0x4A2F1C), width: 3.4)
                // A few shaggy tufts on the cheeks and the crown.
                let tufts: Path = Kit.faceBoth("M-29,2 l-6,3 M-28,9 l-6,5 M-6,-29 l-2,-6")
                Art.stroke(&b, tufts, Kit.faceTone(spec.body, 0.8), width: 2)
                Art.group(&b, x: 5, y: 22) { s in
                    leafSprig(&s)
                }
            }
            // His share: green tops in a heap, and one sweet root he has not tasted yet.
            leafHeap(&g, cx: 66, baseY: 410, width: 176, seed: 7)
            turnip(&g, x: 376, y: 356, r: 28, tops: true, tilt: 0.3)
        }
    }

    // MARK: Face chips (100 × 100)

    static func peasantFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let p = peasantLook()
        Kit.faceChip(&context, size, background: 0xFFE3C2) { g in
            Art.group(&g, x: 0, y: 6, scale: 1.2) { f in
                Kit.personHead(&f, p, mouth: .smile)
            }
        }
    }

    static func bearFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let spec = bearSpec()
        Kit.faceChip(&context, size, background: 0xF3DDBE) { g in
            Art.group(&g, x: 0, y: 6, scale: 1.2) { f in
                Kit.beastFace(&f, spec, mood: .happy)
                Art.stroke(&f, Kit.faceBoth("M-21,-16 q6.5,-6 13.5,-2"), Art.color(0x4A2F1C), width: 3.4)
            }
        }
    }

    static func wifeFace(_ context: inout GraphicsContext, _ size: CGSize) {
        let p = wifeLook()
        Kit.faceChip(&context, size, background: 0xD6F0E0) { g in
            Art.group(&g, x: 0, y: -2, scale: 1.12) { f in
                Kit.personHead(&f, p, mouth: .grin)
            }
        }
    }

    // MARK: Cover (300 wide, 150…375 high; drawn in units 240 wide)

    /// A bunch of cut turnip tops held in a paw: the stems meet at (0, 0), the leaves fan up.
    static func leafBunch(_ g: inout GraphicsContext) {
        let fans: [(CGFloat, CGFloat)] = [(-146, 30), (-118, 38), (-90, 42), (-62, 38), (-34, 30)]
        var back = Path()
        var front = Path()
        var index: Int = 0
        for fan in fans {
            let a: CGFloat = Kit.deg(fan.0)
            if index % 2 == 0 {
                Kit.groundLeaf(&back, base: .zero, angle: a, length: fan.1, width: fan.1 * 0.44)
            } else {
                Kit.groundLeaf(&front, base: .zero, angle: a, length: fan.1, width: fan.1 * 0.44)
            }
            index += 1
        }
        Art.stroke(&g, Art.svg("M-2,0 L-3,12 M2,0 L3,12"), Art.color(0x3B7E3A), width: 3)
        Art.fill(&g, back, Art.color(0x3B7E3A))
        Kit.solid(&g, front, Art.color(topsHex), light: 0.2, shade: 0.16)
    }

    /// The cover: the Peasant and the Bear side by side in the autumn field. The Peasant
    /// holds up a round turnip; the Bear holds up a bunch of green leaves and eyes the turnip.
    /// Birches behind, pale sky above for the title.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = autumn()
        let p = peasantLook()
        let hand: CGPoint = Kit.hand(p, pose: .reach)
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            Kit.sky(&g, CGSize(width: 240, height: hd), horizon: H, light: light)
            Kit.farTrees(&g, x0: -4, x1: 244, baseY: H + 1, height: 18 * k, count: 16, color: light.far, conifer: true, seed: 5)
            ArtStyle.atmosphere(&g, width: 240, top: H - 34 * k, bottom: H + 2, color: light.haze, alpha: 0.42)

            let soil: Kit.Stops = [(Art.color(0x9A7442), 0), (Art.color(0x7A5230), 0.55), (Art.color(0x5B3A1E), 1)]
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: soil, seed: 23, tooth: Art.color(0xF2D9A8))
            Kit.furrows(&g, x0: -60, x1: 300, top: H + 3, bottom: hd, color: 0x7A5230, count: 9)

            // Yellow birches and one dark spruce behind them.
            let gold: Kit.Greens = Kit.autumnLeaves()
            Kit.conifer(&g, x: 200, baseY: H + 3 * k, height: 92 * k, palette: Kit.pineGreens(), seed: 5)
            Kit.birch(&g, x: 24, baseY: H + 6 * k, height: 150 * k, palette: gold, seed: 3)
            Kit.birch(&g, x: 218, baseY: H + 8 * k, height: 166 * k, palette: gold, seed: 6)

            let feet: CGFloat = H + 26 * k
            // The Bear, with his bunch of tops.
            Kit.shadow(&g, 172, feet, width: 78 * k)
            Art.group(&g, x: 172, y: feet, scale: 0.62 * k) { b in
                bear(&b, pose: .rear, mood: .calm, look: CGPoint(x: -0.9, y: 0.1), brow: 1)
                Art.group(&b, x: rearPawX, y: rearPawY - 8) { l in
                    leafBunch(&l)
                }
            }
            // The Peasant, with his turnip.
            Kit.shadow(&g, 76, feet + 2 * k, width: 36 * k)
            Art.group(&g, x: 76, y: feet + 2 * k, scale: 0.56 * k, scaleX: -1) { m in
                peasant(&m, pose: .reach, look: CGPoint(x: -0.5, y: -0.2), mouth: .grin, mirrored: true)
                turnip(&m, x: hand.x - 2, y: hand.y - 20, r: 17, tops: true)
            }
            // A few turnips on the soil at their feet, and near leaves in a top corner.
            turnip(&g, x: 118, y: feet + 12 * k, r: 6 * k, tops: true, tilt: -0.8)
            turnip(&g, x: 138, y: feet + 16 * k, r: 7 * k, tops: true, tilt: 0.7)
            Kit.cornerLeaves(&g, size: CGSize(width: 240, height: hd), corner: 1, color: Art.color(0xB4481F), scale: 0.42 * k, seed: 2)
        }
    }
}
