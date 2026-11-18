import SwiftUI
import OmramoCore

// The five reading scenes of "The Story of Urashima Taro", unfolded: 892 units wide and
// 400…1300 units tall.
//
// Text lies over BOTH panes in this story, so every scene is one place that runs under both:
// a level horizon about 64% of the way down, the far shore and the far, pale bands of the
// patterned sea behind the words (veiled on the leading pane, see `leadingMist`), and the
// stronger forms only in the bottom third. The trailing pane's lower 300 units hold the
// subject. The whole picture block grows with the height (see `Stage`), so an iPad in portrait
// gets a deeper sea, taller pines and larger figures rather than a stretched sky, and a short
// window (400…520) gets a smaller picture in which nothing collides.
//
// The folded scenes are their own compositions, in `UrashimaArt+Folded.swift`.

extension UrashimaArt {
    // MARK: - Shared parts

    /// A row of small far pines standing on a headland drawn with `headland(…, base, rise)`.
    /// Each item is (x, how far up the rise it stands 0…1, size).
    static func shorePines(
        _ context: inout GraphicsContext,
        _ items: [(CGFloat, CGFloat, CGFloat)],
        base: CGFloat,
        rise: CGFloat,
        s: CGFloat,
        color: Color,
        clumps: Int = 5
    ) {
        for item in items {
            let footY: CGFloat = base - rise * item.1 * 0.85
            pine(&context, item.0, footY, item.2 * s, color, clumps: clumps, lit: 0.12)
        }
    }

    /// A ground line across the picture, filled down past the bottom edge: from `y0` at the
    /// left through `y1` in the middle to `y2` at the right, rolling by `bump`.
    static func ridge(_ w: CGFloat, _ h: CGFloat, _ y0: CGFloat, _ y1: CGFloat, _ y2: CGFloat, bump: CGFloat) -> Path {
        var shape = Path()
        shape.move(to: pt(0, y0))
        shape.addCurve(to: pt(w * 0.5, y1), control1: pt(w * 0.17, y0 - bump), control2: pt(w * 0.34, y1 + bump))
        shape.addCurve(to: pt(w, y2), control1: pt(w * 0.66, y1 - bump), control2: pt(w * 0.85, y2 - bump))
        shape.addLine(to: pt(w, h + 4))
        shape.addLine(to: pt(0, h + 4))
        shape.closeSubpath()
        return shape
    }

    /// The sea rocks of the leading pane's lower corner: a larger rock with a leaning pine
    /// and a small one beside it. They stand in the fifth wave band, in the bottom third.
    static func seaRocks(_ context: inout GraphicsContext, _ st: Stage, stone: Color, needles: Color, bark: Color, clumps: Int) {
        let s = st.s
        rock(&context, 176, st.y(96), 44 * s, 22 * s, stone)
        pine(&context, 108, st.y(134), 1.0 * s, needles, trunk: bark, lean: 0.25, clumps: clumps)
        rock(&context, 100, st.y(96), 96 * s, 46 * s, stone)
    }

    // MARK: - scene-sea (design screen 05)

    static func sceneSea(_ context: inout GraphicsContext, h: CGFloat) {
        let w: CGFloat = 892
        let st = Stage(h)
        let s = st.s
        let fig = st.fig
        let sea = Sea(low: st.horizon, scale: s, swell: 30 * s)
        fillBackground(&context, w, h, daySky)
        ArtStyle.horizonGlow(&context, width: w, y: st.horizon + 2, rise: 190 * s, color: horizonTint, alpha: 0.42)
        sun(&context, 800, st.horizon - 10 * s, 44 * s)

        // Far plane: a long low shore behind the words, a nearer headland with pines.
        let base: CGFloat = st.horizon + 3 * s
        let farRise: CGFloat = 22 * s
        let nearRise: CGFloat = 32 * s
        let farTint = Art.color(0x8FB4C0)
        Art.layer(&context, opacity: 0.6) { g in
            Art.fill(&g, headland(-30, 300, base, farRise, peak: 0.3), Art.color(0xBCD8E0))
            let row: [(CGFloat, CGFloat, CGFloat)] = [(34, 0.8, 0.5), (70, 1, 0.62), (104, 0.9, 0.46), (156, 0.62, 0.52), (206, 0.4, 0.4)]
            shorePines(&g, row, base: base, rise: farRise, s: s, color: farTint)
        }
        Art.layer(&context, opacity: 0.72) { g in
            Art.fill(&g, headland(470, 668, base, nearRise, peak: 0.45), Art.color(0x9DC3CF))
            let row: [(CGFloat, CGFloat, CGFloat)] = [(520, 0.72, 0.7), (552, 1, 0.9), (592, 0.84, 0.6), (628, 0.4, 0.5)]
            shorePines(&g, row, base: base, rise: nearRise, s: s, color: Art.color(0x7FAAB5))
        }
        ArtStyle.atmosphere(&context, width: w, top: st.horizon - 90 * s, bottom: st.horizon + 4 * s, color: Art.color(0xFFEDE0), alpha: 0.28)
        let gullTint = Art.color(0x5A7C96)
        gull(&context, 500, st.y(292), 0.8 * s, gullTint)
        gull(&context, 522, st.y(302), 0.6 * s, gullTint)
        gull(&context, 236, st.y(286), 0.5 * s, gullTint.opacity(0.6))

        let seaShape = seaBand(&context, sea, 0, fills: dayFills, bottom: h)
        farSail(&context, 232, sea.top(0, 232) + 5 * s, k: 0.7 * s, alpha: 0.7)
        seaBand(&context, sea, 1, fills: dayFills, bottom: h)
        farSail(&context, 852, sea.top(1, 852) + 6 * s, k: s)
        farSail(&context, 110, sea.top(1, 110) + 6 * s, k: 0.9 * s, alpha: 0.75)
        seaBand(&context, sea, 2, fills: dayFills, bottom: h)
        farSail(&context, 372, sea.top(2, 372) + 8 * s, k: 1.15 * s, alpha: 0.8)
        seaBand(&context, sea, 3, fills: dayFills, bottom: h)

        // Middle plane: the boat on the swell, its shadow on the water.
        // (On a tall canvas the larger boat moves a little right, clear of the tortoise.)
        let boatX: CGFloat = 716 + 40 * (fig - 1)
        let boatY: CGFloat = sea.top(3, boatX) + 4 * s
        ArtStyle.contactShadow(&context, boatX + 8 * fig, boatY + 10 * fig, 100 * fig, 8 * fig, alpha: 0.2)
        Art.group(&context, x: boatX, y: boatY, rotate: rad(-5), scale: fig) { g in
            boatWithUrashima(&g)
        }
        seaBand(&context, sea, 4, fills: dayFills, bottom: h)

        // The tortoise in the waves beside the boat, looking up.
        // Its head stays clear of the hinge strip (x 432…460) at every size.
        let tortoiseScale: CGFloat = 1.05 * min(fig, 1.2)
        let tortoiseX: CGFloat = max(560, boatX - 140 * fig)
        let tortoiseY: CGFloat = sea.top(4, tortoiseX) + 6 * s
        Art.group(&context, x: tortoiseX, y: tortoiseY, rotate: rad(4), scale: tortoiseScale) { g in
            tortoise(&g, lookX: 1, lookY: -1)
        }
        let rippleY: CGFloat = tortoiseY + 6 * tortoiseScale
        let rippleX: CGFloat = tortoiseX - 56 * tortoiseScale
        let step: CGFloat = 38 * tortoiseScale
        var ripple = Path()
        ripple.move(to: pt(rippleX, rippleY))
        ripple.addQuadCurve(to: pt(rippleX + step, rippleY), control: pt(rippleX + step * 0.5, rippleY - 7 * fig))
        ripple.addQuadCurve(to: pt(rippleX + step * 2, rippleY), control: pt(rippleX + step * 1.5, rippleY + 7 * fig))
        ripple.addQuadCurve(to: pt(rippleX + step * 3, rippleY), control: pt(rippleX + step * 2.5, rippleY - 7 * fig))
        Art.stroke(&context, ripple, Art.color(0xFFFFFF, 0.8), width: ArtStyle.detailLine)

        // Near plane: the two darkest bands, with their foam.
        seaBand(&context, sea, 5, fills: dayFills, bottom: h)
        seaBand(&context, sea, 6, fills: dayFills, bottom: h)

        leadingMist(&context, w, h, Art.color(0xF3F9FB), horizon: st.horizon, s: s)
        Art.clipped(&context, to: seaShape) { g in
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: st.horizon - 6, width: w, height: h - st.horizon + 6), seed: 11, alpha: 0.12)
        }
        finish(&context, w, h)
    }

    // MARK: - scene-shore and scene-return

    /// The beach. `later: false` is the evening Urashima frees the tortoise; `later: true` is the
    /// same shore three hundred years on: bare pines, strange roofs, a quieter and cooler sea
    /// that still belongs to the story's blues, under the same warm horizon.
    static func sceneBeach(_ context: inout GraphicsContext, h: CGFloat, later: Bool) {
        let w: CGFloat = 892
        let st = Stage(h)
        let s = st.s
        let fig = st.fig
        let sea = Sea(low: st.horizon, scale: s)
        let fills = later ? laterFills : dayFills
        fillBackground(&context, w, h, later ? laterSky : eveningSky)
        // The warm band at the horizon. It stays on the changed shore too: the ending is quiet
        // and sad, but the light is still warm.
        ArtStyle.horizonGlow(&context, width: w, y: st.horizon + 2, rise: 170 * s, color: horizonTint, alpha: later ? 0.5 : 0.42)
        if later {
            paleSun(&context, 716, st.y(266), 22 * s)
        } else {
            // The evening sun, half set behind the far sea.
            sun(&context, 706, st.horizon - 6 * s, 38 * s)
        }

        // Far plane: a long low shore with a line of pines behind the words; the village
        // headland on the trailing pane.
        let base: CGFloat = st.horizon + 3 * s
        let farRise: CGFloat = 26 * s
        let villageRise: CGFloat = 36 * s
        let farLand = later ? Art.color(0xC5D3DC) : Art.color(0xBFD9DF)
        let farPine = later ? Art.color(0x9DB2C0) : Art.color(0x8FB4C0)
        let landTint = later ? Art.color(0xAEC0CE) : Art.color(0x9DC3CF)
        let wallTint = later ? Art.color(0xD5DFE6) : Art.color(0xC9DEE3)
        let roofTint = later ? Art.color(0x8AA0B4) : Art.color(0x6F9AA6)
        Art.layer(&context, opacity: 0.6) { g in
            Art.fill(&g, headland(-30, 330, base, farRise, peak: 0.3), farLand)
            let row: [(CGFloat, CGFloat, CGFloat)] = [
                (40, 0.8, 0.55), (78, 1, 0.7), (112, 0.9, 0.5), (168, 0.62, 0.6), (214, 0.38, 0.45), (262, 0.18, 0.4),
            ]
            shorePines(&g, row, base: base, rise: farRise, s: s, color: farPine, clumps: later ? 2 : 5)
        }
        Art.layer(&context, opacity: 0.75) { g in
            Art.fill(&g, headland(468, 690, base, villageRise, peak: 0.42), landTint)
            if later {
                tinyHouse(&g, 524, base - villageRise * 0.7, 1.25 * s, wall: wallTint, roof: roofTint, tiers: 2)
                tinyHouse(&g, 566, base - villageRise * 0.88, 0.95 * s, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 604, base - villageRise * 0.62, 1.35 * s, wall: wallTint, roof: roofTint, tiers: 2)
                pine(&g, 546, base - villageRise * 0.8, 0.7 * s, roofTint, clumps: 2, lit: 0.1)
            } else {
                pine(&g, 526, base - villageRise * 0.66, 0.8 * s, roofTint, lit: 0.12)
                pine(&g, 590, base - villageRise * 0.72, 0.7 * s, roofTint, lit: 0.12)
                tinyHouse(&g, 508, base - villageRise * 0.5, 0.9 * s, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 542, base - villageRise * 0.8, 1.1 * s, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 572, base - villageRise * 0.84, 0.85 * s, wall: wallTint, roof: roofTint)
                tinyHouse(&g, 606, base - villageRise * 0.6, 1.0 * s, wall: wallTint, roof: roofTint)
            }
        }
        let haze = later ? Art.color(0xF9E7DD) : Art.color(0xFCE8DC)
        ArtStyle.atmosphere(&context, width: w, top: st.horizon - 90 * s, bottom: st.horizon + 4 * s, color: haze, alpha: 0.28)
        let gullTint = later ? Art.color(0x7F92A6) : Art.color(0x5A7C96)
        gull(&context, 610, st.y(288), 0.7 * s, gullTint)
        if !later {
            gull(&context, 632, st.y(298), 0.55 * s, gullTint)
            gull(&context, 300, st.y(284), 0.5 * s, gullTint.opacity(0.6))
        }

        // The sea, one water under both panes. Far sails only on the first evening.
        let seaShape = seaBand(&context, sea, 0, fills: fills, bottom: h)
        seaBand(&context, sea, 1, fills: fills, bottom: h)
        if !later {
            farSail(&context, 364, sea.top(1, 364) + 6 * s, k: 0.9 * s, alpha: 0.75)
        }
        seaBand(&context, sea, 2, fills: fills, bottom: h)
        seaBand(&context, sea, 3, fills: fills, bottom: h)
        seaBand(&context, sea, 4, fills: fills, bottom: h)
        // Sea rocks with a leaning pine, low in the leading pane's corner.
        if later {
            seaRocks(&context, st, stone: Art.color(0x7C93A8), needles: Art.color(0x7F97A6), bark: Art.color(0x6F6A72), clumps: 2)
        } else {
            seaRocks(&context, st, stone: Art.color(0x6F8FA8), needles: Art.color(0x4E8C7E), bark: Art.color(0x7A5A44), clumps: 5)
        }
        seaBand(&context, sea, 5, fills: fills, bottom: h)
        seaBand(&context, sea, 6, fills: fills, bottom: h)
        leadingMist(&context, w, h, later ? Art.color(0xF2F1F1) : Art.color(0xF6F3EF), horizon: st.horizon, s: s)
        Art.clipped(&context, to: seaShape) { g in
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: st.horizon - 6, width: w, height: h - st.horizon + 6), seed: 17, alpha: 0.12)
        }

        // Sand, with a wet edge and foam lines where the water meets it.
        var sand = Path()
        sand.move(to: pt(486, h + 4))
        sand.addCurve(to: pt(664, st.y(150)), control1: pt(530, st.y(58)), control2: pt(590, st.y(124)))
        sand.addCurve(to: pt(896, st.y(180)), control1: pt(740, st.y(172)), control2: pt(820, st.y(176)))
        sand.addLine(to: pt(896, h + 4))
        sand.closeSubpath()
        let wet = sand.applying(CGAffineTransform(translationX: -18, y: 3))
        Art.fill(&context, wet, later ? Art.color(0xCDCCCB) : Art.color(0xE0D0B2))
        var edge = Path()
        edge.move(to: pt(464, h + 6))
        edge.addCurve(to: pt(640, st.y(146)), control1: pt(508, st.y(54)), control2: pt(566, st.y(120)))
        Art.stroke(&context, edge, Art.color(0xFFFFFF, 0.85), width: ArtStyle.contourLine)
        let outerEdge = edge.applying(CGAffineTransform(translationX: -14, y: -2))
        Art.stroke(&context, outerEdge, Art.color(0xFFFFFF, 0.4), width: ArtStyle.detailLine)
        let sandStops: [(Color, CGFloat)] = later
            ? [(Art.color(0xEFE9E0), 0), (Art.color(0xDDD3C6), 1)]
            : [(Art.color(0xF7EDD9), 0), (Art.color(0xEAD7B6), 1)]
        Art.fillLinear(&context, sand, sandStops, from: pt(0, st.y(184)), to: pt(0, h))
        let sandBounds = CGRect(x: 486, y: st.y(184), width: 410, height: 184 * s)
        ArtStyle.form(&context, sand, bounds: sandBounds, light: later ? 0.14 : 0.2, shade: 0.1)
        let grainTint = later ? Art.color(0x6E6A78) : Art.color(0x9A7A4A)
        let duneTint = later ? Art.color(0xB9AFA6) : Art.color(0xCDB48A)
        var dunes = Path()
        dunes.move(to: pt(660, st.y(104)))
        dunes.addQuadCurve(to: pt(770, st.y(92)), control: pt(712, st.y(112)))
        dunes.move(to: pt(600, st.y(44)))
        dunes.addQuadCurve(to: pt(740, st.y(30)), control: pt(668, st.y(52)))
        let dunePath = dunes
        Art.clipped(&context, to: sand) { g in
            ArtStyle.tooth(&g, in: sandBounds, seed: 5, color: grainTint, alpha: 0.12)
            Art.stroke(&g, dunePath, duneTint.opacity(0.45), width: ArtStyle.detailLine)
        }

        // Pines on the ridge.
        if later {
            let bare = Art.color(0x7F97A6)
            let bark = Art.color(0x6F6A72)
            ArtStyle.contactShadow(&context, 834, st.y(170), 22 * s, 3.5 * s, alpha: 0.16)
            pine(&context, 824, st.y(172), 2.3 * s, bare, trunk: bark, lean: -0.36, clumps: 2, lit: 0.1)
            pine(&context, 872, st.y(176), 1.8 * s, bare, trunk: bark, lean: -0.34, clumps: 1, lit: 0.1)
            // A stump where the third pine stood.
            Art.fill(&context, Art.rect(766, st.y(176), 7 * s, 10 * s, radius: 2), bark)
        } else {
            let bark = Art.color(0x7A5A44)
            ArtStyle.contactShadow(&context, 836, st.y(170), 26 * s, 4 * s, alpha: 0.18)
            pine(&context, 772, st.y(166), 1.2 * s, Art.color(0x5E9A8A), trunk: bark, lean: -0.2)
            pine(&context, 872, st.y(176), 1.8 * s, Art.color(0x3F7F74), trunk: bark, lean: -0.3)
            pine(&context, 824, st.y(172), 2.3 * s, Art.color(0x4E8C7E), trunk: bark, lean: -0.28)
            // His boat, drawn up on the sand.
            ArtStyle.contactShadow(&context, 796, st.y(110), 54 * s, 5 * s)
            Art.group(&context, x: 790, y: st.y(118), rotate: rad(5), scale: 0.5 * s) { g in
                boat(&g)
            }
        }

        if later {
            // A few fallen leaves on the empty sand.
            let leaves: [(CGFloat, CGFloat)] = [(700, 96), (752, 70), (716, 44), (792, 120), (668, 60)]
            var leafPath = Path()
            for (lx, up) in leaves {
                leafPath.addEllipse(in: CGRect(x: lx - 3 * s, y: st.y(up) - 1.4 * s, width: 6 * s, height: 2.8 * s))
            }
            Art.fill(&context, leafPath, Art.color(0xB98A7C, 0.6))

            // Urashima alone, the box in his hands, the first pale mist curling from it.
            let footY: CGFloat = st.y(86)
            ArtStyle.contactShadow(&context, 646, footY + 1, 26 * fig, 4.5 * fig)
            Art.group(&context, x: 640, y: footY, scale: fig) { g in
                urashima(&g, rod: .absent, holdsBox: true)
            }
            // A soft wisp only: pale lilac, thin, nothing that looms.
            let curl = Art.svg("M4,-2 C-8,-14 14,-24 2,-38 C-6,-48 8,-58 3,-72")
            Art.group(&context, x: 640 - 21 * fig, y: footY - 60 * fig, scale: fig) { g in
                Art.blurred(&g, radius: 3, opacity: 0.45) { b in
                    Art.stroke(&b, curl, Art.color(0xC9B6F0), width: 5)
                }
                Art.stroke(&g, curl, Art.color(0xEDE4FF, 0.7), width: ArtStyle.detailLine)
            }
        } else {
            // The tortoise going back into the water; Urashima kneeling to let it go.
            let tortoiseY: CGFloat = st.y(80)
            Art.group(&context, x: 566, y: tortoiseY, rotate: rad(-4), scale: 0.8 * fig) { g in
                tortoise(&g, lookX: 0.5, lookY: 0)
            }
            let rippleX: CGFloat = 566 - 62 * fig
            let rippleY: CGFloat = tortoiseY + 14 * fig
            let step: CGFloat = 24 * fig
            var ripple = Path()
            ripple.move(to: pt(rippleX, rippleY))
            ripple.addQuadCurve(to: pt(rippleX + step, rippleY), control: pt(rippleX + step * 0.5, rippleY - 5 * fig))
            ripple.addQuadCurve(to: pt(rippleX + step * 2, rippleY), control: pt(rippleX + step * 1.5, rippleY + 5 * fig))
            Art.stroke(&context, ripple, Art.color(0xFFFFFF, 0.8), width: ArtStyle.detailLine)
            let footY: CGFloat = st.y(84)
            ArtStyle.contactShadow(&context, 642, footY + 1, 30 * fig, 4.5 * fig)
            Art.group(&context, x: 632, y: footY, scale: fig) { g in
                urashima(&g, rod: .absent, pose: .kneeling)
            }
        }
        finish(&context, w, h)
    }

    // MARK: - scene-deep

    /// Going down: Urashima on the tortoise's back in pale aqua water, the sea floor rising
    /// in three hazy ridges from the lower left to the first far roofs of the palace.
    static func sceneDeep(_ context: inout GraphicsContext, h: CGFloat) {
        let w: CGFloat = 892
        let st = Stage(h)
        let s = st.s
        let fig = st.fig
        let water: [(Color, CGFloat)] = [
            (Art.color(0xE6F6F4), 0), (Art.color(0xDDF3F0), 0.45), (Art.color(0xCDEDEA), 0.75), (Art.color(0xB9E4E0), 1),
        ]
        fillBackground(&context, w, h, water)
        // The same key light as above the water: warm, from the upper left of the surface.
        Art.glow(&context, 140, -60, 460, horizonTint, alpha: 0.5)
        lightShafts(&context, h: h, strength: 1)

        // Far plane: the farthest ridge, far weed, and the palace roofs in their lantern light.
        let far = ridge(w, h, st.y(150), st.y(166), st.y(196), bump: 20 * s)
        Art.fill(&context, far, Art.color(0xC4E9E3))
        let farWeedDark = Art.color(0xA5DACE)
        let farWeedLight = Art.color(0xB4E2D7)
        kelp(&context, 150, st.y(158), 70 * s, seed: 31, dark: farWeedDark, light: farWeedLight)
        kelp(&context, 304, st.y(158), 52 * s, seed: 33, dark: farWeedDark, light: farWeedLight)
        kelp(&context, 690, st.y(180), 64 * s, seed: 35, dark: farWeedDark, light: farWeedLight)
        Art.glow(&context, 792, st.y(256), 170 * s, Art.color(0xFFEFC8), alpha: 0.6)
        Art.layer(&context, opacity: 0.85) { g in
            palaceSilhouette(&g, 792, st.y(190), s, Art.color(0xA3D6D1))
        }
        ArtStyle.atmosphere(&context, width: w, top: st.y(330), bottom: st.y(140), color: Art.color(0xDDF3F0), alpha: 0.3)

        // Middle plane: the second ridge with coral and weed, fish, and the rider above it.
        let mid = ridge(w, h, st.y(92), st.y(104), st.y(128), bump: 18 * s)
        Art.fillLinear(&context, mid, [(Art.color(0xB2E1DA), 0), (Art.color(0xA3D9D1), 1)], from: pt(0, st.y(130)), to: pt(0, st.y(40)))
        let kelpDark = Art.color(0x4FAE98)
        let kelpLight = Art.color(0x74C8B2)
        coral(&context, 236, st.y(94), 1.0 * s, Art.color(0xF7C4BC), seed: 16)
        kelp(&context, 384, st.y(92), 98 * s, seed: 9, dark: kelpDark, light: kelpLight)
        coral(&context, 664, st.y(108), 1.0 * s, Art.color(0xF7BDB4), seed: 6)
        kelp(&context, 742, st.y(112), 84 * s, seed: 12, dark: kelpDark, light: kelpLight)

        let shoal: [(CGFloat, CGFloat, CGFloat)] = [
            (716, 268, 0.7), (742, 256, 0.6), (698, 250, 0.55), (760, 274, 0.6), (730, 238, 0.5),
        ]
        for (fx, up, fs) in shoal {
            fish(&context, fx, st.y(up), fs * s, Art.color(0x7FB5C9), flip: 1, eye: white)
        }
        let lowShoal: [(CGFloat, CGFloat, CGFloat)] = [(150, 130, 0.6), (178, 118, 0.5), (130, 112, 0.5)]
        for (fx, up, fs) in lowShoal {
            fish(&context, fx, st.y(up), fs * s, Art.color(0x8FC3CF), flip: -1, eye: white)
        }
        fish(&context, 520, st.y(140), 0.8 * s, Art.color(0xF0907F), flip: -1, eye: white)
        fish(&context, 548, st.y(124), 0.6 * s, Art.color(0xF5AFA2), flip: -1, eye: white)

        let riderY: CGFloat = st.y(196)
        Art.group(&context, x: 600, y: riderY, rotate: rad(8), scale: 0.9 * fig) { g in
            rider(&g, seated: true)
        }
        bubbles(
            &context, count: 9, seed: 5, x: 600 - 124 * fig, y: riderY - 112 * fig, w: 70 * fig, h: 96 * fig,
            fill: white, ring: white, strength: 2.4
        )

        // Near plane: the nearest ridge, darker, with tall weed framing the edges.
        let near = ridge(w, h, st.y(40), st.y(46), st.y(56), bump: 14 * s)
        Art.fillLinear(&context, near, [(deepFloor, 0), (Art.color(0x78C2B9), 1)], from: pt(0, st.y(60)), to: pt(0, h))
        let nearDark = Art.color(0x3F9E8A)
        let nearLight = Art.color(0x62B8A2)
        kelp(&context, 34, h, 150 * s, seed: 3, dark: nearDark, light: nearLight)
        kelp(&context, 470, h, 110 * s, seed: 5, dark: nearDark, light: nearLight)
        kelp(&context, 874, h, 170 * s, seed: 7, dark: nearDark, light: nearLight)
        coral(&context, 120, st.y(22), 1.1 * s, Art.color(0xF4A9A0), seed: 4)
        coral(&context, 330, st.y(16), 0.8 * s, Art.color(0xFFFFFF), seed: 10)
        coral(&context, 590, st.y(24), 0.9 * s, Art.color(0xF4A9A0), seed: 14)
        Art.clipped(&context, to: mid) { g in
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: st.y(140), width: w, height: 140 * s), seed: 19, alpha: 0.1)
        }

        bubbles(&context, count: 16, seed: 21, x: 0, y: st.y(300), w: w, h: 300 * s, fill: white, ring: white, strength: 1.8)
        finish(&context, w, h)
    }

    /// Soft slanting shafts of light from the surface.
    static func lightShafts(_ context: inout GraphicsContext, h: CGFloat, strength: Double) {
        let shafts: [(CGFloat, CGFloat, Double)] = [
            (120, 70, 0.22), (290, 46, 0.16), (560, 90, 0.24), (740, 56, 0.18), (860, 40, 0.14),
        ]
        let drift = h * 0.21
        for (x, width, alpha) in shafts {
            let footRight: CGFloat = x + width * 1.6 - drift
            let footLeft: CGFloat = x - width * 0.6 - drift
            let corners: [CGPoint] = [pt(x, -10), pt(x + width, -10), pt(footRight, h), pt(footLeft, h)]
            let shaft = Art.polygon(corners)
            // Warm white, like the key light: never a cold beam. Each shaft fades with depth.
            let tint = Art.color(0xFFF6E6)
            let top: Double = alpha * strength
            Art.fillLinear(
                &context, shaft,
                [(tint.opacity(top), 0), (tint.opacity(top * 0.7), 0.5), (tint.opacity(top * 0.25), 1)],
                from: pt(0, 0), to: pt(0, h)
            )
        }
    }

    /// The far palace as one pale shape: three tiers, two wings and a spire. (x, y) is the
    /// middle of its base.
    static func palaceSilhouette(_ context: inout GraphicsContext, _ x: CGFloat, _ y: CGFloat, _ s: CGFloat, _ color: Color) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            let tiers: [(CGFloat, CGFloat, CGFloat)] = [(56, 28, 18), (36, 22, 16), (20, 16, 14)]
            var level: CGFloat = 0
            for (half, body, roofHeight) in tiers {
                let top = level - body
                Art.fill(&g, Art.rect(-half, top, half * 2, body + 2), color)
                let cap = roofShape(half * 1.36, roofHeight).applying(CGAffineTransform(translationX: 0, y: top))
                Art.fill(&g, cap, color)
                level = top - roofHeight
            }
            let sides: [CGFloat] = [-1, 1]
            for side in sides {
                let cx = side * 94
                Art.fill(&g, Art.rect(cx - 22, -18, 44, 20), color)
                let cap = roofShape(31, 12).applying(CGAffineTransform(translationX: cx, y: -18))
                Art.fill(&g, cap, color)
            }
            Art.fill(&g, Art.rect(-1.2, level - 16, 2.4, 18), color)
            Art.fill(&g, Art.circle(0, level - 17, 2.6), color)
            // The sea floor the palace stands on.
            Art.fill(&g, Art.rect(-140, 0, 280, 8, radius: 3), color)
        }
    }

    // MARK: - scene-palace

    /// Rin Gin's gardens: pearl light, a red-and-white hall with jade roofs, coral trees, the four
    /// seasons at once, and Princess Otohime greeting Urashima. Behind the words, the farther
    /// halls of the palace stand in haze, and a pale path winds up from the lower left.
    static func scenePalace(_ context: inout GraphicsContext, h: CGFloat) {
        let w: CGFloat = 892
        let st = Stage(h)
        let s = st.s
        let fig = st.fig
        let light: [(Color, CGFloat)] = [
            (Art.color(0xEEF7F4), 0), (Art.color(0xE6F6F4), 0.4), (Art.color(0xD9F1EC), 0.75), (Art.color(0xCDEDEA), 1),
        ]
        fillBackground(&context, w, h, light)
        Art.glow(&context, 140, -60, 460, horizonTint, alpha: 0.45)
        lightShafts(&context, h: h, strength: 0.7)

        // Far plane: a far garden rise, the farther halls in haze, pale coral trees.
        let far = ridge(w, h, st.y(124), st.y(150), st.y(200), bump: 22 * s)
        Art.fill(&context, far, Art.color(0xD6EEE6))
        Art.layer(&context, opacity: 0.5) { g in
            palaceSilhouette(&g, 206, st.y(138), 1.15 * s, Art.color(0xBFE3DB))
        }
        coral(&context, 52, st.y(128), 1.0 * s, Art.color(0xF4D3CC), seed: 18)
        coral(&context, 356, st.y(142), 0.9 * s, Art.color(0xF6DAD4), seed: 20)
        ArtStyle.atmosphere(&context, width: w, top: st.y(330), bottom: st.y(110), color: Art.color(0xE6F6F4), alpha: 0.32)
        Art.glow(&context, 560, st.y(190), 190 * s, Art.color(0xFFEFC8), alpha: 0.7)

        // Middle plane: the garden floor and the pearl path to the hall.
        let floor = ridge(w, h, st.y(56), st.y(94), st.y(134), bump: 16 * s)
        Art.fillLinear(&context, floor, [(Art.color(0xE6F2E8), 0), (palaceFloor, 1)], from: pt(0, st.y(134)), to: pt(0, st.y(20)))
        var path = Path()
        path.move(to: pt(150, h + 4))
        path.addCurve(to: pt(506, st.y(100)), control1: pt(260, st.y(40)), control2: pt(400, st.y(72)))
        path.addLine(to: pt(548, st.y(100)))
        path.addCurve(to: pt(300, h + 4), control1: pt(478, st.y(62)), control2: pt(376, st.y(30)))
        path.closeSubpath()
        let pearlPath = path
        Art.clipped(&context, to: floor) { g in
            Art.fill(&g, pearlPath, Art.color(0xFFFFFF, 0.4))
            ArtStyle.tooth(&g, in: CGRect(x: 0, y: st.y(140), width: w, height: 140 * s), seed: 23, color: Art.color(0x6FAE9C), alpha: 0.1)
        }

        // The hall on its terrace.
        let hallScale: CGFloat = min(s, 1.4)
        ArtStyle.contactShadow(&context, 568, st.y(118) + 26 * hallScale, 84 * hallScale, 7 * hallScale, alpha: 0.16)
        Art.group(&context, x: 560, y: st.y(118), scale: hallScale) { g in
            Art.fill(&g, Art.rect(-64, -2, 128, 30, radius: 3), Art.color(0xF4F6F1))
            Art.fill(&g, Art.rect(-64, -2, 128, 3), gold.opacity(0.8))
            hall(&g, 0, 0, 50, 34, 20, windows: 4, style: HallStyle.pearl)
            hall(&g, 0, -54, 30, 22, 16, windows: 2, style: HallStyle.pearl)
            Art.stroke(&g, Art.line(0, -92, 0, -108), gold, width: ArtStyle.contourLine)
            Art.fill(&g, Art.circle(0, -110, 3.6), Art.color(0xFFE9A8))
        }

        // The four seasons at once, left to right.
        let bark = Art.color(0x7A5A4E)
        // Spring: cherry blossom.
        seasonTree(
            &context, x: 486, y: st.y(78), s: 1.3 * s, trunk: bark,
            dark: Art.color(0xF4B9C6), light: Art.color(0xFCDDE4), drift: Art.color(0xF4A9BA), seed: 31
        )
        // Summer: green leaves.
        seasonTree(
            &context, x: 634, y: st.y(124), s: 0.95 * s, trunk: bark,
            dark: Art.color(0x4F9F78), light: Art.color(0x7FC29A), drift: nil, seed: 32
        )
        // Autumn: red maple.
        seasonTree(
            &context, x: 806, y: st.y(122), s: 1.1 * s, trunk: bark,
            dark: Art.color(0xD9573F), light: Art.color(0xF0895C), drift: Art.color(0xE0704C), seed: 33
        )
        // Winter: snow on a pine.
        pine(&context, 858, st.y(98), 1.7 * s, Art.color(0x3F7F78), trunk: bark, snow: true)
        var flakes = Path()
        var random = ArtRandom(34)
        for _ in 0..<12 {
            let fx: CGFloat = 812 + random.next(in: 0...78)
            let fy: CGFloat = st.y(204) + random.next(in: 0...90) * s
            flakes.addEllipse(in: CGRect(x: fx - 1.2 * s, y: fy - 1.2 * s, width: 2.4 * s, height: 2.4 * s))
        }
        Art.fill(&context, flakes, Art.color(0xFFFFFF, 0.9))

        // Otohime greeting Urashima.
        let footY: CGFloat = st.y(62)
        ArtStyle.contactShadow(&context, 682, footY + 2, 44 * fig, 6 * fig, alpha: 0.2)
        let guestX: CGFloat = 676 + 74 * fig
        ArtStyle.contactShadow(&context, guestX + 4, footY + 1, 24 * fig, 4.5 * fig, alpha: 0.2)
        Art.group(&context, x: 676, y: footY, scale: fig) { g in
            otohime(&g)
        }
        Art.group(&context, x: guestX, y: footY, scale: fig) { g in
            urashima(&g, rod: .absent)
        }

        // Near plane: coral trees along the bottom edge.
        coral(&context, 70, st.y(26), 1.2 * s, Art.color(0xF6A79C), seed: 4)
        coral(&context, 170, st.y(18), 0.8 * s, Art.color(0xFBD3CB), seed: 8)
        coral(&context, 392, st.y(28), 1.4 * s, Art.color(0xF28E86), seed: 6)
        coral(&context, 596, st.y(22), 0.7 * s, Art.color(0xFFFFFF), seed: 10)

        bubbles(&context, count: 12, seed: 23, x: 0, y: st.y(280), w: w, h: 280 * s, fill: white, ring: white, strength: 1.8)
        finish(&context, w, h)
    }

    /// A woodblock tree: a forked, tapering trunk under cloud-shaped foliage with a broken
    /// edge, in two tones (the lighter on the upper left), with a few drifting petals or
    /// leaves. (x, y) is the foot of the trunk; the tree is about 76 × `s` units tall.
    static func seasonTree(
        _ context: inout GraphicsContext,
        x: CGFloat,
        y: CGFloat,
        s: CGFloat,
        trunk: Color,
        dark: Color,
        light: Color,
        drift: Color?,
        seed: UInt32
    ) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            Art.fill(&g, Art.svg("M-3.4,0 C-2.6,-12 0.4,-24 -2.4,-40 L0.6,-40 C3,-24 1.8,-12 3.6,0Z"), trunk)
            let limbs = Art.svg("M-1,-26 C-8,-34 -14,-36 -20,-46 M0,-30 C8,-38 14,-40 20,-52")
            Art.stroke(&g, limbs, trunk, width: 2.6)
            let masses: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (-20, -48, 18, 8), (18, -54, 20, 8.5), (0, -64, 22, 9), (-6, -41, 14, 6),
            ]
            var darkPath = Path()
            var lightPath = Path()
            for (cx, cy, rx, ry) in masses {
                darkPath.addEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
                darkPath.addEllipse(in: CGRect(x: cx - rx * 0.9, y: cy - ry * 1.5, width: rx * 0.9, height: ry * 1.6))
                darkPath.addEllipse(in: CGRect(x: cx - rx * 0.1, y: cy - ry * 1.7, width: rx * 0.95, height: ry * 1.7))
                let lx = rx * 0.6
                let ly = ry * 0.5
                lightPath.addEllipse(in: CGRect(x: cx - rx * 0.75, y: cy - ry * 1.2, width: lx * 2, height: ly * 2))
            }
            Art.fill(&g, darkPath, dark)
            Art.fill(&g, lightPath, light)
            if let drift {
                var random = ArtRandom(seed)
                var specks = Path()
                for _ in 0..<9 {
                    let px = random.next(in: -34...34)
                    let py = random.next(in: -34...(-2))
                    specks.addEllipse(in: CGRect(x: px - 1.3, y: py - 1, width: 2.6, height: 2))
                }
                Art.fill(&g, specks, drift.opacity(0.85))
            }
        }
    }
}
