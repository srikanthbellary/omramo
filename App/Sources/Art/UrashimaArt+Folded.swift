import SwiftUI
import OmramoCore

// The five reading scenes of "The Story of Urashima Taro", folded: the picture band at the top
// of a single pane, 432 units wide and 240…520 units tall.
//
// Each is its own composition for this tall-ish frame, not a crop of the wide scene: the
// subject's face inside the middle 60% of the width (x 86…346), below the top controls (the
// top 110 units) and above the caller's wave cut (the bottom 24…30 units); far, middle and near
// planes; everything anchored to the bottom and scaled with the height (see `FoldedStage`).

extension UrashimaArt {
    // MARK: - scene-shore and scene-return, folded

    /// The beach in the picture band: the village headland far left, the sea in bands, the sand
    /// coming in from the right under leaning pines, and Urashima in the middle.
    static func foldedBeach(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat, later: Bool) {
        let st = FoldedStage(h)
        let s = st.s
        let horizon: CGFloat = st.y(190)
        let sea = Sea(low: horizon, scale: 0.8 * s)
        let fills = later ? laterFills : dayFills
        fillBackground(&context, w, h, later ? laterSky : eveningSky)
        ArtStyle.horizonGlow(&context, width: w, y: horizon + 2, rise: 130 * s, color: horizonTint, alpha: 0.45)
        if later {
            paleSun(&context, 300, st.y(234), 18 * s)
        } else {
            sun(&context, 300, horizon - 5 * s, 32 * s)
        }

        // Far plane: the village on its headland.
        let base: CGFloat = horizon + 3 * s
        let rise: CGFloat = 36 * s
        let landTint = later ? Art.color(0xAEC0CE) : Art.color(0x9DC3CF)
        let wallTint = later ? Art.color(0xD5DFE6) : Art.color(0xC9DEE3)
        let roofTint = later ? Art.color(0x8AA0B4) : Art.color(0x6F9AA6)
        Art.layer(&context, opacity: 0.75) { g in
            Art.fill(&g, headland(-20, 236, base, rise, peak: 0.42), landTint)
            if later {
                tinyHouse(&g, 56, base - rise * 0.64, 1.2 * s, wall: wallTint, roof: roofTint, tiers: 2)
                tinyHouse(&g, 98, base - rise * 0.8, 0.95 * s, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 140, base - rise * 0.56, 1.3 * s, wall: wallTint, roof: roofTint, tiers: 2)
                pine(&g, 78, base - rise * 0.78, 0.7 * s, roofTint, clumps: 2, lit: 0.1)
            } else {
                pine(&g, 58, base - rise * 0.68, 0.8 * s, roofTint, lit: 0.12)
                pine(&g, 124, base - rise * 0.68, 0.7 * s, roofTint, lit: 0.12)
                pine(&g, 182, base - rise * 0.3, 0.55 * s, roofTint, lit: 0.12)
                tinyHouse(&g, 40, base - rise * 0.5, 0.9 * s, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 76, base - rise * 0.8, 1.1 * s, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 104, base - rise * 0.8, 0.85 * s, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 142, base - rise * 0.56, 1.0 * s, wall: wallTint, roof: roofTint)
            }
        }
        let haze = later ? Art.color(0xF9E7DD) : Art.color(0xFCE8DC)
        ArtStyle.atmosphere(&context, width: w, top: horizon - 80 * s, bottom: horizon + 4 * s, color: haze, alpha: 0.28)
        let gullTint = later ? Art.color(0x7F92A6) : Art.color(0x5A7C96)
        gull(&context, 196, st.y(246), 0.7 * s, gullTint)
        if !later {
            gull(&context, 218, st.y(256), 0.55 * s, gullTint)
        }

        // The sea.
        let seaShape = seaBand(&context, sea, 0, fills: fills, x1: w, bottom: h)
        for index in 1...6 {
            seaBand(&context, sea, index, fills: fills, x1: w, bottom: h)
        }
        Art.clipped(&context, to: seaShape) { g in
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: horizon - 6, width: w, height: h - horizon + 6), seed: 17, alpha: 0.12)
        }

        // Sand, with a wet edge and a foam line where the water meets it.
        var sand = Path()
        sand.move(to: pt(120, h + 4))
        sand.addCurve(to: pt(300, st.y(96)), control1: pt(170, st.y(30)), control2: pt(230, st.y(78)))
        sand.addCurve(to: pt(436, st.y(124)), control1: pt(350, st.y(108)), control2: pt(400, st.y(118)))
        sand.addLine(to: pt(436, h + 4))
        sand.closeSubpath()
        let wet = sand.applying(CGAffineTransform(translationX: -16, y: 3))
        Art.fill(&context, wet, later ? Art.color(0xCDCCCB) : Art.color(0xE0D0B2))
        var edge = Path()
        edge.move(to: pt(98, h + 6))
        edge.addCurve(to: pt(278, st.y(92)), control1: pt(148, st.y(28)), control2: pt(208, st.y(74)))
        Art.stroke(&context, edge, Art.color(0xFFFFFF, 0.85), width: ArtStyle.contourLine)
        let sandStops: [(Color, CGFloat)] = later
            ? [(Art.color(0xEFE9E0), 0), (Art.color(0xDDD3C6), 1)]
            : [(Art.color(0xF7EDD9), 0), (Art.color(0xEAD7B6), 1)]
        Art.fillLinear(&context, sand, sandStops, from: pt(0, st.y(128)), to: pt(0, h))
        let sandBounds = CGRect(x: 120, y: st.y(128), width: 316, height: 128 * s + 28)
        ArtStyle.form(&context, sand, bounds: sandBounds, light: later ? 0.14 : 0.2, shade: 0.1)
        let grainTint = later ? Art.color(0x6E6A78) : Art.color(0x9A7A4A)
        Art.clipped(&context, to: sand) { g in
            ArtStyle.tooth(&g, in: sandBounds, seed: 5, color: grainTint, alpha: 0.12)
        }

        // Pines on the ridge, at the right edge.
        if later {
            let bare = Art.color(0x7F97A6)
            let bark = Art.color(0x6F6A72)
            pine(&context, 424, st.y(122), 1.5 * s, bare, trunk: bark, lean: -0.34, clumps: 1, lit: 0.1)
            pine(&context, 392, st.y(118), 2.0 * s, bare, trunk: bark, lean: -0.36, clumps: 2, lit: 0.1)
            Art.fill(&context, Art.rect(346, st.y(118), 7 * s, 10 * s, radius: 2), bark)
        } else {
            let bark = Art.color(0x7A5A44)
            ArtStyle.contactShadow(&context, 402, st.y(116), 24 * s, 3.5 * s, alpha: 0.18)
            pine(&context, 352, st.y(108), 1.1 * s, Art.color(0x5E9A8A), trunk: bark, lean: -0.2)
            pine(&context, 424, st.y(122), 1.5 * s, Art.color(0x3F7F74), trunk: bark, lean: -0.3)
            pine(&context, 392, st.y(118), 2.0 * s, Art.color(0x4E8C7E), trunk: bark, lean: -0.28)
            // His boat, drawn up on the sand.
            ArtStyle.contactShadow(&context, 366, st.y(60), 36 * s, 4 * s)
            Art.group(&context, x: 362, y: st.y(66), rotate: rad(5), scale: 0.34 * s) { g in
                boat(&g)
            }
        }

        if later {
            let leaves: [(CGFloat, CGFloat)] = [(300, 54), (336, 34), (282, 22), (372, 78)]
            var leafPath = Path()
            for (lx, up) in leaves {
                leafPath.addEllipse(in: CGRect(x: lx - 3 * s, y: st.y(up) - 1.4 * s, width: 6 * s, height: 2.8 * s))
            }
            Art.fill(&context, leafPath, Art.color(0xB98A7C, 0.6))

            // Urashima alone, the box in his hands, the first pale mist curling from it.
            let footY: CGFloat = st.y(30)
            let fig: CGFloat = st.figure(1.5, footY: footY, face: 87)
            ArtStyle.contactShadow(&context, 232, footY + 1, 26 * fig, 4.5 * fig)
            Art.group(&context, x: 226, y: footY, scale: fig) { g in
                urashima(&g, rod: .absent, holdsBox: true)
            }
            let curl = Art.svg("M4,-2 C-8,-14 14,-24 2,-38 C-6,-48 8,-58 3,-72")
            Art.group(&context, x: 226 - 21 * fig, y: footY - 60 * fig, scale: fig) { g in
                Art.blurred(&g, radius: 3, opacity: 0.45) { b in
                    Art.stroke(&b, curl, Art.color(0xC9B6F0), width: 5)
                }
                Art.stroke(&g, curl, Art.color(0xEDE4FF, 0.7), width: ArtStyle.detailLine)
            }
        } else {
            // The tortoise going back into the water; Urashima kneeling to let it go.
            let footY: CGFloat = st.y(36)
            let fig: CGFloat = st.figure(1.5, footY: footY, face: 76)
            let tortoiseX: CGFloat = 236 - 57 * fig
            let tortoiseY: CGFloat = footY + 8 * fig
            Art.group(&context, x: tortoiseX, y: tortoiseY, rotate: rad(-4), scale: 0.72 * fig) { g in
                tortoise(&g, lookX: 0.5, lookY: 0)
            }
            ArtStyle.contactShadow(&context, 246, footY + 1, 30 * fig, 4.5 * fig)
            Art.group(&context, x: 236, y: footY, scale: fig) { g in
                urashima(&g, rod: .absent, pose: .kneeling)
            }
        }

        // Near plane: one dark wave lapping across the bottom, where the caller cuts its edge.
        let crestY: CGFloat = st.base - 2
        waveBand(
            &context, x0: 0, x1: w, bottom: h, amp: 6, length: 48, phase: 9,
            fill: fills[6], foamOpacity: 0.85
        ) { _ in crestY }
        finish(&context, w, h)
    }

    // MARK: - scene-sea, folded

    /// The boat in the middle of the band on the patterned sea, the red sun behind its stern,
    /// the tortoise in the near waves.
    static func foldedSea(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let st = FoldedStage(h)
        let s = st.s
        let horizon: CGFloat = st.y(190)
        let sea = Sea(low: horizon, scale: 0.8 * s)
        fillBackground(&context, w, h, daySky)
        ArtStyle.horizonGlow(&context, width: w, y: horizon + 2, rise: 140 * s, color: horizonTint, alpha: 0.45)
        sun(&context, 336, horizon - 16 * s, 38 * s)

        // Far plane: a headland with pines.
        let base: CGFloat = horizon + 3 * s
        let rise: CGFloat = 30 * s
        Art.layer(&context, opacity: 0.68) { g in
            Art.fill(&g, headland(-20, 200, base, rise, peak: 0.4), Art.color(0x9DC3CF))
            let row: [(CGFloat, CGFloat, CGFloat)] = [(36, 0.8, 0.6), (64, 1, 0.8), (98, 0.9, 0.55), (140, 0.5, 0.5)]
            shorePines(&g, row, base: base, rise: rise, s: s, color: Art.color(0x7FAAB5))
        }
        ArtStyle.atmosphere(&context, width: w, top: horizon - 80 * s, bottom: horizon + 4 * s, color: Art.color(0xFFEDE0), alpha: 0.28)
        let gullTint = Art.color(0x5A7C96)
        gull(&context, 150, st.y(250), 0.8 * s, gullTint)
        gull(&context, 174, st.y(262), 0.6 * s, gullTint)

        let seaShape = seaBand(&context, sea, 0, fills: dayFills, x1: w, bottom: h)
        seaBand(&context, sea, 1, fills: dayFills, x1: w, bottom: h)
        farSail(&context, 408, sea.top(1, 408) + 5 * s, k: 0.8 * s)
        seaBand(&context, sea, 2, fills: dayFills, x1: w, bottom: h)
        seaBand(&context, sea, 3, fills: dayFills, x1: w, bottom: h)

        // Middle plane: the boat.
        let boatY: CGFloat = sea.top(4, 236) - 6 * s
        let fig: CGFloat = st.figure(1.15, footY: boatY, face: 94)
        ArtStyle.contactShadow(&context, 236 + 8 * fig, boatY + 10 * fig, 100 * fig, 8 * fig, alpha: 0.2)
        Art.group(&context, x: 236, y: boatY, rotate: rad(-5), scale: fig) { g in
            boatWithUrashima(&g)
        }
        seaBand(&context, sea, 4, fills: dayFills, x1: w, bottom: h)
        seaBand(&context, sea, 5, fills: dayFills, x1: w, bottom: h)

        // The tortoise in the near waves, looking up at him.
        // Its head reaches 66 units left of its centre (at scale 0.8 × fig): keep it on the canvas.
        let tortoiseReach: CGFloat = 74 * 0.8 * fig
        let tortoiseX: CGFloat = max(64, max(tortoiseReach, 236 - 126 * fig))
        let tortoiseY: CGFloat = sea.top(5, tortoiseX) + 5 * s
        Art.group(&context, x: tortoiseX, y: tortoiseY, rotate: rad(4), scale: 0.8 * fig) { g in
            tortoise(&g, lookX: 1, lookY: -1)
        }
        // Near plane: the darkest band, whose lower edge the caller cuts.
        seaBand(&context, sea, 6, fills: dayFills, x1: w, bottom: h)

        Art.clipped(&context, to: seaShape) { g in
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: horizon - 6, width: w, height: h - horizon + 6), seed: 11, alpha: 0.12)
        }
        finish(&context, w, h)
    }

    // MARK: - scene-deep, folded

    /// The rider in the middle of the band, heading down to the right, the far palace in its
    /// lantern light behind, the sea floor in three ridges, tall weed framing the edges.
    static func foldedDeep(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let st = FoldedStage(h)
        let s = st.s
        let water: [(Color, CGFloat)] = [
            (Art.color(0xE6F6F4), 0), (Art.color(0xDDF3F0), 0.45), (Art.color(0xCDEDEA), 0.75), (Art.color(0xB9E4E0), 1),
        ]
        fillBackground(&context, w, h, water)
        Art.glow(&context, 60, -40, 300, horizonTint, alpha: 0.5)
        lightShafts(&context, h: h, strength: 1)

        // Far plane.
        let far = ridge(w, h, st.y(84), st.y(92), st.y(108), bump: 12 * s)
        Art.fill(&context, far, Art.color(0xC4E9E3))
        kelp(&context, 96, st.y(88), 60 * s, seed: 31, dark: Art.color(0xA5DACE), light: Art.color(0xB4E2D7))
        Art.glow(&context, 330, st.y(176), 120 * s, Art.color(0xFFEFC8), alpha: 0.6)
        Art.layer(&context, opacity: 0.85) { g in
            palaceSilhouette(&g, 330, st.y(100), 0.6 * s, Art.color(0xA3D6D1))
        }
        ArtStyle.atmosphere(&context, width: w, top: st.y(270), bottom: st.y(76), color: Art.color(0xDDF3F0), alpha: 0.3)

        // Middle plane.
        let mid = ridge(w, h, st.y(52), st.y(46), st.y(54), bump: 10 * s)
        Art.fillLinear(&context, mid, [(Art.color(0xB2E1DA), 0), (Art.color(0xA3D9D1), 1)], from: pt(0, st.y(60)), to: pt(0, st.y(10)))
        let kelpDark = Art.color(0x4FAE98)
        let kelpLight = Art.color(0x74C8B2)
        coral(&context, 150, st.y(48), 0.9 * s, Art.color(0xF7C4BC), seed: 16)
        kelp(&context, 304, st.y(48), 70 * s, seed: 9, dark: kelpDark, light: kelpLight)
        coral(&context, 262, st.y(46), 0.7 * s, Art.color(0xF7BDB4), seed: 6)

        let shoal: [(CGFloat, CGFloat, CGFloat)] = [(84, 238, 0.6), (108, 226, 0.5), (66, 222, 0.5)]
        for (fx, up, fs) in shoal {
            fish(&context, fx, st.y(up), fs * s, Art.color(0x7FB5C9), flip: -1, eye: white)
        }
        fish(&context, 356, st.y(150), 0.7 * s, Art.color(0xF0907F), flip: 1, eye: white)
        fish(&context, 380, st.y(136), 0.55 * s, Art.color(0xF5AFA2), flip: 1, eye: white)

        let riderY: CGFloat = st.y(112)
        let fig: CGFloat = st.figure(1.25, footY: riderY, face: 90)
        Art.group(&context, x: 212, y: riderY, rotate: rad(6), scale: fig) { g in
            rider(&g, seated: true)
        }
        bubbles(
            &context, count: 8, seed: 5, x: 212 - 130 * fig, y: riderY - 108 * fig, w: 60 * fig, h: 88 * fig,
            fill: white, ring: white, strength: 2.4
        )

        // Near plane.
        let near = ridge(w, h, st.y(18), st.y(22), st.y(26), bump: 8 * s)
        Art.fillLinear(&context, near, [(deepFloor, 0), (Art.color(0x78C2B9), 1)], from: pt(0, st.y(30)), to: pt(0, h))
        let nearDark = Art.color(0x3F9E8A)
        let nearLight = Art.color(0x62B8A2)
        kelp(&context, 20, h, 150 * s, seed: 3, dark: nearDark, light: nearLight)
        kelp(&context, 414, h, 170 * s, seed: 7, dark: nearDark, light: nearLight)
        coral(&context, 72, st.y(8), 1.0 * s, Art.color(0xF4A9A0), seed: 4)
        coral(&context, 362, st.y(10), 0.9 * s, Art.color(0xFFFFFF), seed: 10)

        bubbles(&context, count: 12, seed: 21, x: 0, y: st.y(280), w: w, h: 280 * s, fill: white, ring: white, strength: 1.8)
        finish(&context, w, h)
    }

    // MARK: - scene-palace, folded

    /// Otohime and Urashima side by side in the middle of the band, the hall behind and
    /// between them, a cherry tree and a maple at the edges, coral in the near corners.
    static func foldedPalace(_ context: inout GraphicsContext, w: CGFloat, h: CGFloat) {
        let st = FoldedStage(h)
        let s = st.s
        let light: [(Color, CGFloat)] = [
            (Art.color(0xEEF7F4), 0), (Art.color(0xE6F6F4), 0.4), (Art.color(0xD9F1EC), 0.75), (Art.color(0xCDEDEA), 1),
        ]
        fillBackground(&context, w, h, light)
        Art.glow(&context, 60, -40, 300, horizonTint, alpha: 0.45)
        lightShafts(&context, h: h, strength: 0.7)

        // Far plane.
        let far = ridge(w, h, st.y(100), st.y(112), st.y(128), bump: 12 * s)
        Art.fill(&context, far, Art.color(0xD6EEE6))
        Art.layer(&context, opacity: 0.5) { g in
            palaceSilhouette(&g, 84, st.y(106), 0.5 * s, Art.color(0xBFE3DB))
        }
        ArtStyle.atmosphere(&context, width: w, top: st.y(270), bottom: st.y(90), color: Art.color(0xE6F6F4), alpha: 0.32)
        Art.glow(&context, 216, st.y(170), 150 * s, Art.color(0xFFEFC8), alpha: 0.7)

        // Middle plane: the floor, the pearl path, the hall.
        let floor = ridge(w, h, st.y(70), st.y(78), st.y(86), bump: 8 * s)
        Art.fillLinear(&context, floor, [(Art.color(0xE6F2E8), 0), (palaceFloor, 1)], from: pt(0, st.y(90)), to: pt(0, st.y(10)))
        var path = Path()
        path.move(to: pt(150, h + 4))
        path.addCurve(to: pt(196, st.y(80)), control1: pt(170, st.y(30)), control2: pt(186, st.y(60)))
        path.addLine(to: pt(236, st.y(80)))
        path.addCurve(to: pt(290, h + 4), control1: pt(246, st.y(60)), control2: pt(268, st.y(30)))
        path.closeSubpath()
        let pearlPath = path
        Art.clipped(&context, to: floor) { g in
            Art.fill(&g, pearlPath, Art.color(0xFFFFFF, 0.4))
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: st.y(90), width: w, height: 90 * s + 24), seed: 23, color: Art.color(0x6FAE9C), alpha: 0.1)
        }
        let hallScale: CGFloat = 0.95 * s
        ArtStyle.contactShadow(&context, 222, st.y(96) + 26 * hallScale, 84 * hallScale, 7 * hallScale, alpha: 0.16)
        Art.group(&context, x: 216, y: st.y(96), scale: hallScale) { g in
            Art.fill(&g, Art.rect(-64, -2, 128, 30, radius: 3), Art.color(0xF4F6F1))
            Art.fill(&g, Art.rect(-64, -2, 128, 3), gold.opacity(0.8))
            hall(&g, 0, 0, 50, 34, 20, windows: 4, style: HallStyle.pearl)
            hall(&g, 0, -54, 30, 22, 16, windows: 2, style: HallStyle.pearl)
            Art.stroke(&g, Art.line(0, -92, 0, -108), gold, width: ArtStyle.contourLine)
            Art.fill(&g, Art.circle(0, -110, 3.6), Art.color(0xFFE9A8))
        }

        // Three of the four seasons stand around the hall; winter's snow is on the far pine.
        let bark = Art.color(0x7A5A4E)
        seasonTree(
            &context, x: 58, y: st.y(74), s: 1.25 * s, trunk: bark,
            dark: Art.color(0xF4B9C6), light: Art.color(0xFCDDE4), drift: Art.color(0xF4A9BA), seed: 31
        )
        seasonTree(
            &context, x: 328, y: st.y(86), s: 0.8 * s, trunk: bark,
            dark: Art.color(0x4F9F78), light: Art.color(0x7FC29A), drift: nil, seed: 32
        )
        pine(&context, 418, st.y(92), 1.2 * s, Art.color(0x3F7F78), trunk: bark, snow: true)
        seasonTree(
            &context, x: 384, y: st.y(72), s: 1.15 * s, trunk: bark,
            dark: Art.color(0xD9573F), light: Art.color(0xF0895C), drift: Art.color(0xE0704C), seed: 33
        )

        // Otohime greeting Urashima.
        let footY: CGFloat = st.y(22)
        let fig: CGFloat = st.figure(1.35, footY: footY, face: 87)
        let hostX: CGFloat = 219 - 36 * fig
        let guestX: CGFloat = 219 + 36 * fig
        ArtStyle.contactShadow(&context, hostX + 6, footY + 2, 44 * fig, 6 * fig, alpha: 0.2)
        ArtStyle.contactShadow(&context, guestX + 4, footY + 1, 24 * fig, 4.5 * fig, alpha: 0.2)
        Art.group(&context, x: hostX, y: footY, scale: fig) { g in
            otohime(&g)
        }
        Art.group(&context, x: guestX, y: footY, scale: fig) { g in
            urashima(&g, rod: .absent)
        }

        // Near plane: coral in the corners.
        coral(&context, 26, st.y(6), 1.2 * s, Art.color(0xF6A79C), seed: 4)
        coral(&context, 408, st.y(4), 1.0 * s, Art.color(0xFBD3CB), seed: 8)

        bubbles(&context, count: 10, seed: 23, x: 0, y: st.y(280), w: w, h: 280 * s, fill: white, ring: white, strength: 1.8)
        finish(&context, w, h)
    }
}
