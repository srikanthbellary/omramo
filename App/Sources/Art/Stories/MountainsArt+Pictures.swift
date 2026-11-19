import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the two character-card portraits (432 × 400), the four
// face chips (100 × 100) and the cover of "The Old Man Who Moved the Mountains".

// MARK: - Tap-to-see pictures

extension MountainsArt {
    /// see-north-china-mountains: a wall of steep grey-blue mountains rising straight from the
    /// flat yellow plain, a small road bending round its foot. No people.
    static func northChinaMountainsPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let H: CGFloat = 252
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 340, 64, scale: 0.55, color: Art.color(0xFFFFFF, 0.7))
        let back = Kit.peaks(width: w, y: H - 6, amp: 58, seed: 12, bottom: H + 4, sharp: 0.6)
        Art.fill(&context, back, light.far.opacity(0.55))

        // The wall: five peaks, back to front. (cx, width, height)
        let rear: [(CGFloat, CGFloat, CGFloat)] = [(140, 124, 122), (302, 132, 134)]
        var seed: UInt32 = 11
        for peak in rear {
            greatPeak(&context, cx: peak.0, baseY: H + 2, width: peak.1, height: peak.2, color: peakBack, seed: seed, pines: false)
            seed += 3
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 140, bottom: H + 2, color: light.haze, alpha: 0.22)
        greatPeak(&context, cx: 180, baseY: H + 2, width: 142, height: 160, color: 0xA9BDC3, seed: 3, pines: true)
        greatPeak(&context, cx: 258, baseY: H + 2, width: 152, height: 182, color: peakFront, seed: 9, pines: true)
        greatPeak(&context, cx: 214, baseY: H + 2, width: 112, height: 108, color: 0x97AEB6, seed: 6, pines: true)
        // Haze on their feet only: here the tops stay clear, they are the subject.
        let foot: Kit.Stops = [(light.haze.opacity(0), 0), (light.haze.opacity(0.8), 1)]
        Art.fillLinear(&context, Art.rect(0, H - 46, w, 48), foot, from: CGPoint(x: 0, y: H - 46), to: CGPoint(x: 0, y: H + 2))

        // The flat plain and the road that has to go round.
        Kit.ground(&context, width: w, top: H, bottom: h, stops: loess())
        Kit.grainField(&context, x0: 0, x1: 132, baseY: H + 17, height: 8, color: milletGreen, seed: 3)
        Kit.grainField(&context, x0: 318, x1: w, baseY: H + 13, height: 7, color: milletGreen, seed: 8)
        Kit.ribbon(
            &context, nearX: 92, nearY: 352, nearWidth: 46,
            farX: 404, farY: H + 9, farWidth: 5, stops: pathStops()
        )
        Kit.farTrees(&context, x0: 30, x1: 96, baseY: H + 5, height: 15, count: 3, color: Art.color(0x9DB58A), seed: 5)
        Kit.grass(&context, in: CGRect(x: 150, y: H + 30, width: 260, height: 50), count: 14, seed: 4, color: Art.color(0xB9A050), height: 7)
        Kit.sink(&context, size, card: 0x2F5D73)
    }

    /// see-big-family: grandfather and grandmother, their two grown sons, a daughter-in-law
    /// and three grandchildren sitting close together in the farmhouse yard.
    static func bigFamilyPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let light = day()
        Kit.sky(&context, size, horizon: 196, light: light)
        let yard: Kit.Stops = [(Art.color(0xF0DDA6), 0), (Art.color(loessMid), 1)]
        Kit.ground(&context, width: w, top: 196, bottom: h, stops: yard)
        peachTree(&context, x: 398, baseY: 222, height: 170, seed: 7)
        farmhouse(&context, x: 216, baseY: 216, scale: 1.25)
        ArtStyle.atmosphere(&context, width: w, top: 0, bottom: 216, color: light.haze, alpha: 0.22)

        let s: CGFloat = 0.62
        let wood = Art.color(0x9A6B3E)
        // Back row: the grown-ups on a long bench.
        ArtStyle.contactShadow(&context, 222, 228, 128, 6, alpha: 0.24)
        Kit.solid(&context, Art.rect(104, 205, 226, 8, radius: 3), wood, light: 0.3, shade: 0.2)
        Art.group(&context, x: 140, y: 226, scale: s, scaleX: -1) { p in
            kin(&p, grownLook(0), pose: .sit, mirrored: true)
        }
        Art.group(&context, x: 218, y: 226, scale: s) { p in
            kin(&p, grownLook(2), pose: .sit)
        }
        Art.group(&context, x: 298, y: 226, scale: s) { p in
            kin(&p, grownLook(1), pose: .sit, mouth: .grin)
        }
        // Middle: the grandparents, turned a little toward each other.
        ArtStyle.contactShadow(&context, 220, 260, 96, 6, alpha: 0.24)
        Kit.solid(&context, Art.rect(148, 237, 140, 8, radius: 3), wood, light: 0.3, shade: 0.2)
        Art.group(&context, x: 180, y: 258, scale: s, scaleX: -1) { p in
            yuGong(&p, pose: .sit, mouth: .smile, mirrored: true)
        }
        Art.group(&context, x: 258, y: 258, scale: s) { p in
            wife(&p, pose: .sit, mouth: .smile)
        }
        // Front: the grandchildren on the warm earth step.
        ArtStyle.contactShadow(&context, 220, 284, 132, 6, alpha: 0.22)
        let step = Art.rect(92, 266, 250, 17, radius: 6)
        Kit.solid(&context, step, Art.color(0xD9B36C), light: 0.24, shade: 0.16)
        Art.group(&context, x: 124, y: 282, scale: s, scaleX: -1) { p in
            kin(&p, grandchildLook(0), pose: .sit, look: CGPoint(x: 0, y: -0.4), mouth: .grin, mirrored: true)
        }
        Art.group(&context, x: 220, y: 282, scale: s) { p in
            kin(&p, grandchildLook(1), pose: .sit, mouth: .smile)
        }
        Art.group(&context, x: 312, y: 282, scale: s) { p in
            kin(&p, grandchildLook(2), pose: .sit, look: CGPoint(x: 0, y: -0.4), mouth: .grin)
        }
        Kit.basket(&context, cx: 62, baseY: 270, width: 34, height: 25, color: wicker)
        Kit.sink(&context, size, card: 0x8A4A2A)
    }

    /// see-carrying-pole: a wooden pole lying across a rock, a woven basket full of earth and
    /// stones on a cord at each end.
    static func carryingPolePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let H: CGFloat = 232
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 96, H - 40, 20, light: light)
        farRanges(&context, width: w, horizon: H, scale: 0.9, light: light)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: loess())
        Art.fill(&context, Art.ellipse(216, 266, 190, 22), Art.color(0xF3E3B4, 0.6))

        Kit.rock(&context, cx: 216, baseY: 264, width: 122, height: 78, color: 0xA9B0A8, seed: 5)
        Kit.shadow(&context, 106, 264, width: 62)
        Kit.shadow(&context, 326, 264, width: 62)
        loadedPole(&context, cx: 216, cy: 182, length: 220, drop: 72)
        // The pole's shadow on the rock.
        Art.fill(&context, Art.ellipse(222, 192, 44, 3.5), ArtStyle.coolShade.opacity(0.18))

        Kit.grassTuft(&context, x: 158, baseY: 266, height: 24, color: 0x93AC64, seed: 5)
        Kit.grassTuft(&context, x: 284, baseY: 268, height: 20, color: 0x7E9A5A, seed: 9)
        Kit.pebbles(&context, in: CGRect(x: 90, y: 268, width: 260, height: 18), count: 8, seed: 13, color: 0xB8A680)
        Kit.sink(&context, size, card: 0x6B4A1F)
    }
}

// MARK: - Portraits

extension MountainsArt {
    /// A head for a portrait or a face chip: the kit's head, then the character's own details
    /// (drawn in head units, at the child's head scale for a child).
    static func head(
        _ context: inout GraphicsContext,
        _ p: Kit.Person,
        mouth: Kit.Mouth,
        closedEyes: Bool = false,
        _ extras: (inout GraphicsContext) -> Void
    ) {
        Kit.personHead(&context, p, look: .zero, mouth: mouth, closedEyes: closedEyes, mirrored: false)
        let isChild: Bool = p.age == .child
        let sy: CGFloat = isChild ? 50.0 / 56.0 : 1
        let sx: CGFloat = isChild ? (48.0 / 52.0) / (50.0 / 56.0) : 1
        Art.group(&context, scale: sy, scaleX: sx) { e in
            extras(&e)
        }
    }

    /// char-yu-gong: half-length, facing us and smiling, the carrying pole across his
    /// shoulders with a basket at each end, the two mountains soft behind him.
    static func yuGongPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFFE08A, bottom: 0xF59A5A, halo: 0xFFF6D8, rays: true) { g in
            Art.layer(&g, opacity: 0.5) { m in
                let pale = Art.color(0xFFF2CC)
                Kit.mountain(&m, cx: 340, baseY: 404, width: 250, height: 226, color: pale, seed: 9)
                Kit.mountain(&m, cx: 92, baseY: 404, width: 270, height: 256, color: pale, seed: 3)
            }
            loadedPole(&g, cx: 216, cy: 236, length: 372, drop: 110)
            Art.group(&g, x: 216, y: 150, scale: 2.1) { b in
                Kit.bust(&b, yuGongLook(), look: .zero, mouth: .smile)
                yuGongTie(&b)
            }
        }
    }

    /// Hanging willow strands from `top`, between x0 and x1: short ones over the picture,
    /// long ones at its edge.
    static func willowStrands(
        _ context: inout GraphicsContext,
        x0: CGFloat,
        x1: CGFloat,
        top: CGFloat,
        count: Int,
        short: CGFloat,
        long: CGFloat,
        longFrom: CGFloat,
        seed: UInt32
    ) {
        var random = ArtRandom(seed)
        var dark = Path()
        var lit = Path()
        let n: Int = max(1, count)
        for i in 0..<n {
            let t: CGFloat = (CGFloat(i) + Kit.rnd(&random)) / CGFloat(n)
            let sx: CGFloat = Kit.mix(x0, x1, t)
            let base: CGFloat = sx >= longFrom ? long : short
            let length: CGFloat = base * (0.7 + Kit.rnd(&random) * 0.5)
            let sway: CGFloat = (Kit.rnd(&random) - 0.5) * 16
            let end = CGPoint(x: sx + sway, y: top + length)
            let control = CGPoint(x: sx + sway * 0.2, y: top + length * 0.5)
            if i % 2 == 0 {
                dark.move(to: CGPoint(x: sx, y: top))
                dark.addQuadCurve(to: end, control: control)
            } else {
                lit.move(to: CGPoint(x: sx, y: top))
                lit.addQuadCurve(to: end, control: control)
            }
        }
        let dash: [CGFloat] = [9, 6]
        Art.stroke(&context, dark, Art.color(0x6B9A52, 0.8), width: 1.2)
        Art.stroke(&context, dark, Art.color(0x6B9A52), width: 5, dash: dash)
        Art.stroke(&context, lit, Art.color(0x8DB85E, 0.8), width: 1.2)
        Art.stroke(&context, lit, Art.color(0xC4DE82), width: 5, dash: dash)
    }

    /// char-zhi-sou: half-length under a willow branch by the river, laughing with one hand
    /// raised.
    static func zhiSouPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xBFE3F2, bottom: 0x5FA3C8, halo: 0xF2FAFF, rays: true) { g in
            // The river low behind him, and a far sandbar.
            let river: Kit.Stops = [(Art.color(0xE6D9A8, 0), 0), (Art.color(0xE6D9A8, 0.55), 0.3), (Art.color(0xD2BC80, 0.7), 1)]
            Art.fillLinear(&g, Art.rect(0, 286, 432, 114), river, from: CGPoint(x: 0, y: 286), to: CGPoint(x: 0, y: 400))
            Kit.rippleMarks(&g, x0: 0, x1: 432, y0: 312, y1: 396, count: 16, seed: 6, color: Color.white, alpha: 0.4)
            Kit.reeds(&g, x: 46, baseY: 372, count: 6, height: 70, seed: 5, color: 0x6F9460)
            // The willow branch from the top trailing corner.
            Kit.propShaft(&g, 262, -8, 440, 20, wood: 0x7A6450, width: 9)
            willowStrands(&g, x0: 286, x1: 430, top: 4, count: 13, short: 76, long: 190, longFrom: 404, seed: 14)
            let p = zhiSouLook()
            Art.group(&g, x: 216, y: 150, scale: 2.1) { b in
                Kit.bust(&b, p, look: .zero, mouth: .grin, wave: true)
                // The same head again with his eyes shut: he is laughing.
                Kit.personHead(&b, p, look: .zero, mouth: .grin, closedEyes: true, mirrored: false)
            }
        }
    }
}

// MARK: - Face chips

extension MountainsArt {
    static func yuGongFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE6B8) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.2) { f in
                head(&f, yuGongLook(), mouth: .smile) { e in
                    yuGongTie(&e)
                }
            }
        }
    }

    static func wifeFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xF8DDEA) { g in
            Art.group(&g, x: -2, y: 6, scale: 1.2) { f in
                head(&f, wifeLook(), mouth: .smile) { e in
                    wifePin(&e)
                }
            }
        }
    }

    static func boyFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD6F2DC) { g in
            Art.group(&g, x: 0, y: 5, scale: 1.38) { f in
                head(&f, boyLook(), mouth: .grin) { e in
                    boyTufts(&e)
                    boyGap(&e)
                }
            }
        }
    }

    static func zhiSouFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD9E8FB) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.2) { f in
                head(&f, zhiSouLook(), mouth: .grin, closedEyes: true) { _ in
                }
            }
        }
    }
}

// MARK: - Cover

extension MountainsArt {
    /// The cover: Yu Gong walking toward us with his carrying pole and two full baskets, the
    /// little boy skipping at his side with a small basket; Taihang and Wangwu rise behind
    /// them under a pale morning sky.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = day()
        Kit.cover(&context, size) { g, frame in
            let hd: CGFloat = frame.hd
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let area = CGSize(width: 240, height: hd)
            Kit.sky(&g, area, horizon: H, light: light)
            Kit.sun(&g, 30, H - 20 * k, 10 * k, light: light)
            let peakH: CGFloat = H * 0.84
            let peakW: CGFloat = min(peakH * 1.3, 150)
            twoMountains(
                &g, width: 240, baseY: H + 2, height: peakH,
                taihangX: 86, wangwuX: 168, peakWidth: peakW, light: light
            )
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: loess())
            Kit.grainField(&g, x0: 0, x1: 240, baseY: H + 8 * k, height: 5 * k, color: milletGreen, seed: 3)
            Kit.ribbon(
                &g, nearX: 124, nearY: hd, nearWidth: 110 * k,
                farX: 150, farY: H + 5, farWidth: 4, stops: pathStops()
            )

            let feet: CGFloat = min(hd - 8, H + 46 * k)
            let s: CGFloat = 0.6 * k
            let boyX: CGFloat = 104 + 140 * s
            Kit.shadow(&g, 104, feet, width: 70 * s)
            Art.group(&g, x: 104, y: feet, scale: s) { p in
                yuGongCarrying(&p, walking: true, look: .zero, mouth: .smile)
            }
            Kit.shadow(&g, boyX, feet + 2 * s, width: 40 * s, alpha: 0.2)
            Art.group(&g, x: boyX, y: feet - 4 * s, scale: s) { p in
                boy(&p, pose: .carry, look: CGPoint(x: -0.5, y: -0.4), mouth: .grin, basket: true)
            }

            // Near plane: a bough in the top trailing corner, grass at the foot.
            Kit.cornerLeaves(&g, size: area, corner: 1, color: Art.color(0x3F6B58), scale: 0.2 + 0.4 * k, seed: 4)
            Kit.grassTuft(&g, x: 12, baseY: hd + 2, height: 22 * k, color: 0x7E9A5A, seed: 3)
            Kit.grassTuft(&g, x: 226, baseY: hd + 3, height: 18 * k, color: 0x93AC64, seed: 8)
        }
    }
}
