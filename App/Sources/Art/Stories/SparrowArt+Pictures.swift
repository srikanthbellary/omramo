import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the two character-card portraits (432 × 400), the
// three face chips (100 × 100) and the cover of "The Tongue-Cut Sparrow".

// MARK: - Tap-to-see pictures

extension SparrowArt {
    /// A spray of narrow bamboo leaves on a twig that comes in from the upper right.
    static func leafSpray(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat, color: Color) {
        var leaves = Path()
        let aims: [CGFloat] = [1.8, 2.2, 2.6, 3.0, 3.4]
        for aim in aims {
            Kit.treeLeaf(&leaves, 0, 0, 40, aim, slim: 0.45)
        }
        Kit.treeLeaf(&leaves, 16, -18, 32, 2.5, slim: 0.45)
        Kit.treeLeaf(&leaves, 16, -18, 30, 3.3, slim: 0.45)
        let spray: Path = leaves
        Art.group(&context, x: x, y: y, scale: scale) { g in
            Art.stroke(&g, Art.line(0, 0, 34, -38), color, width: 2.4)
            Art.fill(&g, spray, color)
        }
    }

    /// see-bamboo-grove: one clump of tall slim green bamboo growing close together, light
    /// coming through the leaves, on a deep green ground.
    static func bambooGrovePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let air: Kit.Stops = [(Art.color(0xA6D8A8), 0), (Art.color(0x5FA877), 0.55), (Art.color(0x2A6B4A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), air, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        // The light behind the grove, and two soft shafts of it slanting down.
        Art.glow(&context, 170, 96, 230, Art.color(ramp.glow), alpha: 0.75)
        let shaftA = Art.polygon([CGPoint(x: 150, y: 0), CGPoint(x: 196, y: 0), CGPoint(x: 292, y: 300), CGPoint(x: 226, y: 300)])
        let shaftB = Art.polygon([CGPoint(x: 232, y: 0), CGPoint(x: 258, y: 0), CGPoint(x: 356, y: 300), CGPoint(x: 318, y: 300)])
        Art.fill(&context, shaftA, Art.color(ramp.glow, 0.16))
        Art.fill(&context, shaftB, Art.color(ramp.glow, 0.12))
        // Far canes, seen through the air.
        Kit.bamboo(&context, x: 36, baseY: 296, width: 360, height: 290, count: 13, palette: farBamboo(), seed: 4)
        ArtStyle.atmosphere(&context, width: w, top: 0, bottom: 300, color: Art.color(0xBFE6C0), alpha: 0.22)
        // The deep green ground.
        let soil: Kit.Stops = [(Art.color(0x3F7D56), 0), (Art.color(0x1F5A3C), 1)]
        Kit.mound(&context, x0: -30, x1: 462, baseY: 302, height: 14, bottom: h, stops: soil, crest: 0.42)
        // The clump itself, centred: slim canes close together, then three nearer ones.
        Kit.bamboo(&context, x: 100, baseY: 298, width: 232, height: 300, count: 10, palette: Kit.bambooGreens(), seed: 2)
        Kit.bamboo(&context, x: 146, baseY: 306, width: 140, height: 318, count: 3, palette: Kit.bambooGreens(), seed: 9)
        // A young shoot at the foot, and grass.
        let shoot = Kit.placed("M-9,0 C-8,-14 -3,-24 0,-29 C3,-24 8,-14 9,0Z", x: 306, y: 306, scale: 1.2)
        Kit.solid(&context, shoot, Art.color(0x8A6444), light: 0.3, shade: 0.2)
        let husk = Kit.placed("M-6,-6 L0,-12 L6,-6 M-4,-15 L0,-20 L4,-15", x: 306, y: 306, scale: 1.2)
        Art.stroke(&context, husk, Art.color(0xC9A46E), width: 1.2)
        Kit.grass(&context, in: CGRect(x: 70, y: 296, width: 292, height: 18), count: 26, seed: 3, color: Art.color(0x86BD7A, 0.85), height: 9)
        Kit.flecks(&context, in: CGRect(x: 70, y: 40, width: 300, height: 220), count: 14, seed: 5, color: Art.color(ramp.glow, 0.8), radius: 1.0...2.4, glow: false)
        Kit.sink(&context, size, card: 0x1F5A3C)
    }

    /// see-rice: one plain bowl heaped with white rice, a pair of wooden chopsticks resting
    /// beside it.
    static func ricePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let warm: Kit.Stops = [(Art.color(0xF0C49A), 0), (Art.color(0xCB8A66), 0.6), (Art.color(0x9A5440), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), warm, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 130, 90, 240, Art.color(ramp.glow), alpha: 0.55)
        // The low wooden table: its top seen a little from above, and its front edge.
        let top = Art.polygon([CGPoint(x: 78, y: 232), CGPoint(x: 354, y: 232), CGPoint(x: 392, y: 276), CGPoint(x: 40, y: 276)])
        Kit.solid(&context, top, Art.color(0xB5714E), light: 0.3, shade: 0.2)
        let edge = Art.rect(40, 276, 352, 13, radius: 3)
        Kit.solid(&context, edge, Art.color(0x8A4A34), light: 0.16, shade: 0.24)
        Art.stroke(&context, Art.line(42, 276.6, 390, 276.6), ArtStyle.warmLight.opacity(0.6), width: 1.4)
        Art.stroke(&context, Art.svg("M110,244 L330,244 M92,260 L352,260"), Art.color(0x9A5A3E, 0.5), width: 1)
        // The bowl, heaped.
        Kit.bowl(&context, cx: 192, baseY: 264, width: 196, color: 0x3F5E7A, filling: riceWhite)
        let glaze = Art.svg("M104,196 C140,204 244,204 280,196")
        Art.stroke(&context, glaze, Art.color(0x9CB8D0, 0.7), width: 2.4)
        // Soft steam: the rice is just cooked.
        let steam = Art.svg("M168,116 C158,100 178,90 168,72 M206,110 C198,96 214,86 206,70")
        Art.stroke(&context, steam, Color.white.opacity(0.45), width: 4)
        // The chopsticks on their little rest.
        ArtStyle.contactShadow(&context, 348, 268, 44, 4, alpha: 0.24)
        let rest = Art.rect(308, 256, 18, 10, radius: 4)
        Kit.solid(&context, rest, Art.color(0x3F5E7A), light: 0.3, shade: 0.2)
        Kit.propShaft(&context, 304, 255, 388, 262, wood: 0xD9B67E, width: 4.4)
        Kit.propShaft(&context, 306, 250, 386, 251, wood: 0xD9B67E, width: 4.4)
        // A few grains that fell on the table.
        riceGrains(&context, at: CGPoint(x: 78, y: 268), scale: 2.2)
        Kit.sink(&context, size, card: 0x7A3B2E)
    }

    /// see-guest: a small low tray with a teapot and a single cup of green tea, on a straw mat.
    static func guestPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let room: Kit.Stops = [(Art.color(0x9DB0DE), 0), (Art.color(0x6377B0), 0.55), (Art.color(0x3A4C80), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), room, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 140, 90, 240, Art.color(ramp.glow), alpha: 0.5)
        // The straw mat, seen a little from above, with its woven lines and cloth border.
        let mat = Art.polygon([CGPoint(x: 52, y: 228), CGPoint(x: 380, y: 228), CGPoint(x: 440, y: 306), CGPoint(x: -8, y: 306)])
        Kit.solid(&context, mat, Art.color(0xD6CF8E), light: 0.28, shade: 0.2)
        var weave = Path()
        for row in 0..<9 {
            let t: CGFloat = CGFloat(row) / 9
            let y: CGFloat = 234 + 72 * t * (0.5 + 0.5 * t)
            weave.move(to: CGPoint(x: -8, y: y))
            weave.addLine(to: CGPoint(x: 440, y: y))
        }
        let rows: Path = weave
        Art.clipped(&context, to: mat) { g in
            Art.stroke(&g, rows, Art.color(0xA8A45E, 0.6), width: 1)
            Art.stroke(&g, Art.line(52, 230, 380, 230), Art.color(ramp.shade), width: 7, cap: .butt)
        }
        // The low tray.
        Kit.table(&context, cx: 216, baseY: 270, width: 236, height: 30, color: 0x7A3B2E)
        guestTeapot(&context, x: 178, baseY: 240)
        // The single cup of green tea, and its steam.
        ArtStyle.contactShadow(&context, 284, 240, 22, 3, alpha: 0.26)
        let cup = Kit.placed("M-7,-11 L7,-11 C7,-4 5,-0.5 3,0 L-3,0 C-5,-0.5 -7,-4 -7,-11Z", x: 282, y: 240, scale: 2.7)
        Kit.solid(&context, cup, Art.color(0xEEF2F0), light: 0.3, shade: 0.22)
        Art.fill(&context, Art.ellipse(282, 210.5, 17.6, 3.6), Art.color(0x9CC46A))
        Art.stroke(&context, Art.svg("M266,222 C272,226 292,226 298,222"), Art.color(0x3F5E7A, 0.7), width: 1.6)
        let steam = Art.svg("M278,196 C270,182 288,174 280,158")
        Art.stroke(&context, steam, Color.white.opacity(0.45), width: 3.4)
        Kit.sink(&context, size, card: 0x2E3F6E)
    }

    /// The plain clay teapot with a bamboo handle over its lid, its foot at (x, baseY);
    /// about 120 wide (with the spout) and 96 tall.
    static func guestTeapot(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat) {
        ArtStyle.contactShadow(&context, x + 4, baseY, 50, 5, alpha: 0.28)
        Art.group(&context, x: x, y: baseY) { g in
            // The handle first: an arch of bamboo with two joints.
            let handle = Art.svg("M-30,-50 C-32,-98 32,-98 30,-50")
            Art.stroke(&g, handle, Art.color(0xA8964E), width: 6.5)
            Art.stroke(&g, handle, Art.color(0xD6C67E), width: 3.4)
            Art.stroke(&g, Art.svg("M-23,-74 L-15,-70 M23,-74 L15,-70"), Art.color(0x7A6A34), width: 1.4)
            // The spout, toward the cup.
            let spout = Art.svg("M34,-18 C50,-20 58,-34 64,-46 L56,-50 C52,-40 44,-36 32,-36Z")
            Kit.solid(&g, spout, Art.color(0x8A5A44), light: 0.24, shade: 0.24)
            let body = Art.svg("M-40,-2 C-52,-22 -40,-54 0,-54 C40,-54 52,-22 40,-2 C28,2 -28,2 -40,-2Z")
            Kit.solid(&g, body, Art.color(0x9A664C), light: 0.32, shade: 0.28, rim: 2)
            Art.stroke(&g, Art.svg("M-41,-24 C-20,-18 20,-18 41,-24"), Art.color(0x6E4634, 0.6), width: 1.4)
            // The lid and its knob.
            let lid = Art.svg("M-22,-52 C-18,-60 18,-60 22,-52 C14,-49 -14,-49 -22,-52Z")
            Kit.solid(&g, lid, Art.color(0x7E5240), light: 0.3, shade: 0.2)
            Kit.solid(&g, Art.ellipse(0, -61, 5.4, 4.2), Art.color(0x7E5240), light: 0.34, shade: 0.2)
        }
    }
}

// MARK: - Portraits

extension SparrowArt {
    /// char-old-man: half figure, smiling, in his indigo cloth, holding out an open hand with
    /// a few grains of rice; the firewood he carries shows behind his shoulder; soft blue sky.
    static func oldManPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xBFE3F2, bottom: 0x4E9CC2, halo: 0xFFF4D6, rays: true) { g in
            leafSpray(&g, x: 376, y: 52, scale: 1.5, color: Art.color(ramp.shade, 0.85))
            // The bundle on his back, behind the trailing shoulder.
            Art.group(&g, x: 326, y: 372, rotate: 0.14, scale: 3.2) { w in
                firewood(&w)
            }
            Art.group(&g, x: 222, y: 142, scale: 2.2) { b in
                Kit.bust(&b, oldManLook(), look: CGPoint(x: -0.2, y: 0.1), mouth: .smile, wave: false)
            }
            // The straw rope of the bundle across his chest.
            Art.stroke(&g, Art.svg("M330,236 C300,262 262,300 236,352"), Art.color(straw), width: 7)
            Art.stroke(&g, Art.svg("M330,236 C300,262 262,300 236,352"), Art.color(0x9A7A3E, 0.6), width: 1.4, dash: [5, 5])
            oldManOpenHand(&g)
        }
    }

    /// The old man's open hand at the lower left of his portrait: the wide sleeve, the palm,
    /// and the rice.
    static func oldManOpenHand(_ g: inout GraphicsContext) {
        let p = oldManLook()
        ArtStyle.contactShadow(&g, 168, 356, 60, 9, alpha: 0.2)
        let sleeve = Art.svg("M58,404 C66,366 92,340 126,326 L146,362 C122,372 108,386 104,404Z")
        Kit.solid(&g, sleeve, Art.color(p.cloth), light: 0.24, shade: 0.22)
        Art.stroke(&g, Art.svg("M126,326 L146,362"), Art.color(p.trim), width: 8, cap: .butt)
        // Wrist, palm and fingers as one soft shape; the thumb lifts on the near side.
        var hand = Path()
        hand.addPath(Art.svg("M130,334 L150,326 L160,352 L142,358Z"))
        hand.addPath(Art.ellipse(166, 338, 26, 19))
        hand.addPath(Art.rect(176, 322, 46, 24, radius: 12))
        hand.addPath(Art.ellipse(150, 318, 9, 13))
        Kit.solid(&g, hand, Art.color(p.skin), light: 0.24, shade: 0.2)
        let creases = Art.svg("M196,324 L196,342 M208,325 L208,343 M152,340 C160,348 172,350 182,346")
        Art.stroke(&g, creases, Kit.personTone(p.skin, 0.72), width: ArtStyle.detailLine)
        riceGrains(&g, at: CGPoint(x: 176, y: 344), scale: 3.4)
    }

    /// char-sparrow: the Sparrow on a bamboo stem, bowing her head a little, with her wings
    /// a little open; warm golden light behind.
    static func sparrowPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFFE08A, bottom: 0xE58A45, halo: 0xFFF6D6, rays: true) { g in
            leafSpray(&g, x: 380, y: 56, scale: 1.5, color: Art.color(ramp.shade, 0.9))
            let b = heroLook()
            Art.group(&g, x: 216, y: 150, rotate: 0.07, scale: 2.25) { s in
                // The other wing, lifted a little too (the kit lifts the one on the right).
                let lifted = Art.svg("M-26,42 C-44,26 -60,2 -64,-24 C-77,-2 -71,38 -42,68Z")
                Kit.solid(&s, lifted, Art.color(b.wing), light: 0.26, shade: 0.2, rim: 1.6)
                let quills = Art.svg("M-40,44 C-50,30 -58,12 -62,-6 M-45,54 C-56,40 -64,22 -67,4")
                Art.stroke(&s, quills, Kit.birdTone(b.wing, 0.68), width: ArtStyle.detailLine)
                Kit.birdBust(&s, b, look: CGPoint(x: 0, y: 0.45), wave: true)
            }
            // The bamboo stem she stands on, across the foot of the picture, and her toes.
            let stem = Art.rect(-12, 356, 456, 26, radius: 6)
            Kit.solid(&g, stem, Art.color(0x62A84E), light: 0.3, shade: 0.26)
            Art.stroke(&g, Art.line(0, 361, 432, 361), Art.color(0xD9EE8E, 0.7), width: 2)
            let joints = Art.svg("M96,355 L96,383 M318,355 L318,383")
            Art.stroke(&g, joints, Art.color(0x1F5A3A), width: 3, cap: .butt)
            Art.stroke(&g, Art.svg("M101,356 L101,382 M323,356 L323,382"), Art.color(0xD9EE8E, 0.5), width: 1.4, cap: .butt)
            let toes = Art.svg("M184,358 q4,-9 8,0 M194,358 q4,-9 8,0 M204,358 q4,-9 8,0 M226,358 q4,-9 8,0 M236,358 q4,-9 8,0 M246,358 q4,-9 8,0")
            Art.stroke(&g, toes, Art.color(0x6B4A3A), width: 3.4)
        }
    }
}

// MARK: - Face chips

extension SparrowArt {
    static func oldManFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD6E9F7) { g in
            Art.group(&g, x: 0, y: 7, scale: 1.18) { f in
                Kit.personHead(&f, oldManLook(), look: .zero, mouth: .smile)
            }
        }
    }

    static func sparrowFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE2A8) { g in
            Art.group(&g, x: 2, y: -5, scale: 1.18) { f in
                Kit.birdFace(&f, heroLook(), look: .zero, singing: true)
            }
        }
    }

    static func oldWomanFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xF6DCE7) { g in
            Art.group(&g, x: 0, y: -1, scale: 1.12) { f in
                Kit.personHead(&f, oldWomanLook(), look: .zero, mouth: .flat)
            }
        }
    }
}

// MARK: - Cover

extension SparrowArt {
    /// The cover: the old man kneeling with his open hand held out and the Sparrow hopping
    /// onto his fingers, bamboo stems and pale sky behind.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let full = CGSize(width: 240, height: hd)
            let light = day()
            Kit.sky(&g, full, horizon: H, light: light)
            Kit.sun(&g, 44, H - 24 * k, 11 * k, light: light)
            Kit.ranges(&g, width: 240, horizon: H, scale: 0.5 * k, light: light, seed: 4)
            Kit.bamboo(&g, x: 96, baseY: H + 2, width: 150, height: H * 0.92, count: 9, palette: farBamboo(), seed: 14)
            ArtStyle.atmosphere(&g, width: 240, top: 0, bottom: H + 6, color: light.haze, alpha: 0.18)
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: meadow())
            let lawn = CGRect(x: 0, y: H + 4, width: 240, height: max(1, hd - H - 4))
            Kit.grass(&g, in: lawn, count: 36, seed: 5, color: Art.color(ramp.shade, 0.55), height: 6 * k)
            Kit.flowers(&g, in: lawn, count: 6, seed: 8, petal: 0xFFFFFF)
            // The grove behind him, its tops out of the frame.
            Kit.bamboo(&g, x: 138, baseY: H + 10 * k, width: 104, height: H + 30, count: 5, palette: Kit.bambooGreens(), seed: 2)

            let ms: CGFloat = 0.8 * k
            let fy: CGFloat = H + 34 * k
            Kit.shadow(&g, 152, fy + 1, width: 70 * ms, alpha: 0.26)
            Art.group(&g, x: 150, y: fy, scale: ms) { m in
                let rig = manKneelRig()
                oldMan(&m, rig: rig, look: CGPoint(x: -0.8, y: 0.5), mouth: .smile, rice: true)
                let hand = handPoint(oldManLook(), rig)
                Art.group(&m, x: hand.x - 3, y: hand.y - 5, scale: 1.1, scaleX: -1) { s in
                    sparrow(&s, pose: .perch, look: CGPoint(x: -0.6, y: -0.4), wings: true, mirrored: true)
                }
            }
            Kit.grassTuft(&g, x: 22, baseY: hd - 4, height: 30 * k, color: ramp.deep, seed: 3)
            Kit.cornerLeaves(&g, size: full, corner: 1, color: Art.color(ramp.deep), scale: 0.55 * k, seed: 3)
        }
    }
}
