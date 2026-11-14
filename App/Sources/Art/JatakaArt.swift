import SwiftUI
import OmramoCore

/// Concept art for "The Monkey and the Crocodile", drawn in code.
///
/// Ported and extended from the locked design source (docs/design/source/src/lib/art-jataka.js).
/// The characters and the riverbank parts live in `JatakaArt+Characters.swift` and
/// `JatakaArt+Nature.swift`; the tap-to-see pictures, the portrait, the faces and the cover in
/// `JatakaArt+Pictures.swift`; the four folded-phone compositions in `JatakaArt+Folded.swift`.
/// This file holds the entry point and the four unfolded story scenes.
enum JatakaArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-river", .sceneUnfolded):
            riverScene(&context, size)
        case ("scene-river", .sceneFolded):
            riverFolded(&context, size)
        case ("scene-ride", .sceneUnfolded):
            rideScene(&context, size)
        case ("scene-ride", .sceneFolded):
            rideFolded(&context, size)
        case ("scene-island", .sceneUnfolded):
            islandScene(&context, size)
        case ("scene-island", .sceneFolded):
            islandFolded(&context, size)
        case ("scene-dusk", .sceneUnfolded):
            duskScene(&context, size)
        case ("scene-dusk", .sceneFolded):
            duskFolded(&context, size)
        case ("see-river-bank", .picture):
            riverBankPicture(&context, size)
        case ("see-ripe-fruit", .picture):
            ripeFruitPicture(&context, size)
        case ("char-monkey", .portrait):
            monkeyPortrait(&context, size)
        case ("face-monkey", .face):
            monkeyFace(&context, size)
        case ("face-crocodile", .face):
            crocFace(&context, size, mother: false)
        case ("face-mother-crocodile", .face):
            crocFace(&context, size, mother: true)
        case ("cover", .cover):
            cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - The stage of an unfolded scene

extension JatakaArt {
    /// The few numbers an unfolded scene (892 wide, 400…1300 high) derives from its height.
    ///
    /// - 560…720 high: the scene as designed; the sky between canopy and river stretches.
    /// - Taller (an iPad in portrait): `tall` runs 0…1 and `grow` 1…1.35. The horizon rises
    ///   to about 70% of the height, and the near plane and the subject grow by `grow`.
    /// - Shorter than 560 (a phone in landscape): `fit` falls below 1 and everything on the
    ///   trailing side is drawn smaller about the top trailing corner, so the canopy, the
    ///   subject and the river keep their distances.
    struct Stage {
        let tall: CGFloat
        let grow: CGFloat
        let fit: CGFloat
        /// The horizon line.
        let H: CGFloat
        /// The depth of the river from the horizon to the bottom edge.
        let depth: CGFloat
        /// How much deeper the river is than designed, in the units of the fitted drawing.
        let extra: CGFloat
        /// The scale of the far plane (hills, palms, sun).
        let far: CGFloat
    }

    /// `water` is the designed depth of the river at the reference height (720).
    static func stage(_ size: CGSize, water: CGFloat) -> Stage {
        let h = size.height
        let tall: CGFloat = max(0, min(1, (h - 720) / 470))
        let grow: CGFloat = 1 + 0.35 * tall
        let fit: CGFloat = max(0.6, min(1, h / 560))
        let wanted: CGFloat = max(0, h * 0.30 - water)
        let deep: CGFloat = water * fit + tall * wanted
        let horizon: CGFloat = (h - deep).rounded()
        let depth: CGFloat = h - horizon
        let extra: CGFloat = max(0, depth / fit - water)
        let far: CGFloat = fit * (1 + 0.35 * tall)
        return Stage(tall: tall, grow: grow, fit: fit, H: horizon, depth: depth, extra: extra, far: far)
    }

    /// A low sandbar with a tuft of reeds, out in the river: the middle plane that fills the
    /// deeper water of a tall window.
    static func sandbar(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, width: CGFloat) {
        let half = width / 2
        Art.fill(&context, Art.ellipse(x + 4, y + 6, half * 1.05, 5), ArtStyle.coolShade.opacity(0.16))
        var bar = Path()
        bar.move(to: CGPoint(x: x - half, y: y + 3))
        bar.addQuadCurve(to: CGPoint(x: x + half, y: y + 3), control: CGPoint(x: x - half * 0.2, y: y - 13))
        bar.addQuadCurve(to: CGPoint(x: x - half, y: y + 3), control: CGPoint(x: x, y: y + 9))
        bar.closeSubpath()
        Art.fill(&context, bar, Art.color(0xEFE0A0))
        var lit = Path()
        lit.move(to: CGPoint(x: x - half * 0.8, y: y + 1))
        lit.addQuadCurve(to: CGPoint(x: x + half * 0.1, y: y - 4), control: CGPoint(x: x - half * 0.4, y: y - 6))
        Art.stroke(&context, lit, Art.color(0xFFF7D0, 0.9), width: ArtStyle.detailLine)
        reeds(&context, x + half * 0.3, y + 1, count: 6, seed: 27, height: width * 0.24)
        ripples(&context, x, y + 8, width * 1.1, count: 2, color: .white, opacity: 0.4)
    }
}

// MARK: - The banyan

extension JatakaArt {
    static let banyanBlobs: [Blob] = [
        (835, 60, 95), (720, 50, 80), (610, 78, 70), (520, 60, 62), (440, 46, 50), (386, 30, 34),
        (880, 170, 70), (760, 140, 66), (660, 150, 46), (560, 132, 40), (480, 112, 34), (870, 260, 44),
        (660, 96, 50), (570, 40, 50), (800, 200, 40), (700, 190, 30), (610, 170, 26), (420, 96, 22),
        (392, 70, 18), (520, 150, 22),
    ]

    static let banyanFrontBlobs: [Blob] = [
        (505, 302, 26), (472, 316, 22), (536, 318, 18), (440, 302, 16), (486, 290, 16),
        (760, 236, 30), (726, 252, 22), (800, 262, 26),
    ]

    /// Leaves seen through the air: the hazy back layer of a crown.
    static let hazyGreens: [Color] = [
        Art.color(0x5FA892), Art.color(0x6DB89C), Art.color(0x86C9A6), Art.color(0xA5DBB2), Art.color(0xCDEEB8),
    ]

    /// How far the banyan's crown is lifted for a branch at `branchY` (1 as designed).
    static func banyanLift(branchY: CGFloat) -> CGFloat {
        min(1, max(0.55, (branchY - 60) / 270))
    }

    /// The great banyan: trunk, the Monkey's branch, hanging roots and the crown. The crown
    /// hangs from the top edge, the roots of the trunk stand on the bank at the horizon, and
    /// the trunk between them stretches. The top of the branch is near `branchY − 30`.
    /// `girth` thickens the trunk about the trailing edge and `limb` thickens the branch (both
    /// 1 as designed; larger on a tall window).
    static func banyan(
        _ context: inout GraphicsContext,
        height h: CGFloat,
        horizon H: CGFloat,
        branchY: CGFloat,
        girth: CGFloat = 1,
        limb: CGFloat = 1
    ) {
        let dy = branchY - 330
        let lift = banyanLift(branchY: branchY)
        // The design's trunk runs from y 150 to y 574 (horizon 584); stretch it to this height.
        let s = max(0.2, (H - 160) / 424)
        let edge: CGFloat = 892 * (1 - girth)
        let stretch = CGAffineTransform(a: girth, b: 0, c: 0, d: s, tx: edge, ty: 150 - 150 * s)
        let drop = CGAffineTransform(a: 1, b: 0, c: 0, d: limb, tx: 0, ty: 318 - 318 * limb + dy)
        let ground = CGAffineTransform(a: girth, b: 0, c: 0, d: 1, tx: edge, ty: H - 584)
        let bark: [(Color, CGFloat)] = [
            (Art.color(0x8E5B45), 0), (Art.color(0x6B4138), 0.35), (Art.color(0x3E2532), 1),
        ]
        let trunkLeft: CGFloat = 892 - 140 * girth

        // A hazy back layer of leaves peeps out under the crown: the far side of the tree.
        var backBlobs: [Blob] = []
        for blob in banyanBlobs where blob.0 >= 470 && blob.1 > 90 {
            let back: Blob = (blob.0 - 16, blob.1 * lift + 14, blob.2 * 0.9)
            backBlobs.append(back)
        }
        canopy(&context, backBlobs, seed: 15, palette: hazyGreens, density: 0.4)

        // The branch first, so the trunk covers where it joins.
        let branch = Art.svg(
            "M832,332 C760,326 700,330 640,326 C590,322 540,318 492,316 C470,315 452,312 436,306 L438,298 C470,304 520,304 560,306 C640,308 720,300 832,282Z"
        ).applying(drop)
        Art.fillLinear(&context, branch, bark, from: CGPoint(x: 436, y: 0), to: CGPoint(x: 806, y: 0))
        let branchTop: CGFloat = 318 - 36 * limb + dy
        let branchBounds = CGRect(x: 436, y: branchTop, width: 396, height: 54 * limb)
        ArtStyle.form(&context, branch, bounds: branchBounds, light: 0.22, shade: 0.22)
        let branchLight = Art.svg("M800,286 C720,300 640,308 560,306 C520,304 470,304 438,298").applying(drop)
        Art.stroke(&context, branchLight, Art.color(0xD9A070, 0.75), width: ArtStyle.contourLine)

        ArtStyle.contactShadow(&context, 892 - 70 * girth, H + 2, 110 * girth, 10, alpha: 0.3)
        let trunk = Art.svg(
            "M770,574 C792,470 790,380 800,300 C806,250 800,200 790,150 L880,150 C872,230 878,330 872,420 C868,480 880,520 892,540 L892,604 C850,594 800,590 752,594 C760,588 766,582 770,574Z"
        ).applying(stretch)
        Art.fillLinear(&context, trunk, bark, from: CGPoint(x: trunkLeft, y: 0), to: CGPoint(x: 892, y: 0))
        // The one light on the trunk: a warm edge all the way down its left side, cool shade
        // on its right flank, and tooth so the bark is not computer-flat.
        let trunkRim = Art.svg("M752,594 C760,588 766,582 770,574 C792,470 790,380 800,300 C806,250 800,200 790,150").applying(stretch)
        let trunkTooth = CGRect(x: trunkLeft, y: 150, width: 892 - trunkLeft, height: max(1, H - 120))
        Art.clipped(&context, to: trunk) { lit in
            let flank: [(Color, CGFloat)] = [
                (ArtStyle.coolShade.opacity(0), 0), (ArtStyle.coolShade.opacity(0.26), 1),
            ]
            Art.fillLinear(
                &lit,
                Art.rect(trunkLeft, 0, 892 - trunkLeft, H + 60),
                flank,
                from: CGPoint(x: 892 - 76 * girth, y: 0),
                to: CGPoint(x: 892, y: 0)
            )
            Art.stroke(&lit, trunkRim, ArtStyle.warmLight.opacity(0.2), width: 22 * girth)
            Art.stroke(&lit, trunkRim, ArtStyle.warmLight.opacity(0.42), width: 7)
            ArtStyle.tooth(&lit, in: trunkTooth, seed: 61, color: Art.color(0xFFD9B0), alpha: 0.1)
            // The branch throws a little shade on the trunk under it.
            Art.fill(&lit, Art.ellipse(800, branchY + 14 * limb, 60, 14 * limb), ArtStyle.coolShade.opacity(0.2))
        }

        let furrows = Art.svg(
            "M812,520 C818,420 814,330 822,200 M842,540 C846,430 840,330 850,190 M790,584 C800,500 802,470 806,420"
        ).applying(stretch)
        Art.stroke(&context, furrows, Art.color(0x3E2532, 0.45), width: ArtStyle.detailLine)
        let feet = Art.svg("M770,574 C756,588 740,594 720,598 M800,588 C790,600 780,606 764,612").applying(ground)
        Art.stroke(&context, feet, Art.color(0x5B3B36), width: 7)
        let feetLight = Art.svg("M768,572 C755,585 740,590 722,594").applying(ground)
        Art.stroke(&context, feetLight, Art.color(0xB37A58, 0.6), width: ArtStyle.detailLine)

        // Aerial roots. The last number is 1 for a root that hangs from the branch itself.
        let roots: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (560, 150, 150, 0), (574, 160, 120, 0), (690, 200, 190, 0), (703, 190, 130, 0),
            (800, 250, 120, 0), (650, 180, 90, 0), (742, 286, 140, 1), (520, 150, 100, 0),
        ]
        let rootScale = min(2.4, max(0.55, 1 + dy / 330))
        var random = ArtRandom(21)
        for root in roots {
            let onBranch = root.3 > 0.5
            let x = root.0
            let y0 = onBranch ? root.1 + dy : root.1 * lift
            let length = onBranch ? root.2 : root.2 * rootScale
            let sway = (rnd(&random) - 0.5) * 14
            let width = 1.6 + rnd(&random) * 1.6
            var line = Path()
            line.move(to: CGPoint(x: x, y: y0))
            line.addQuadCurve(to: CGPoint(x: x + sway * 0.4, y: y0 + length), control: CGPoint(x: x + sway, y: y0 + length * 0.5))
            Art.stroke(&context, line, Art.color(0x5B3B36, 0.9), width: width)
        }

        let crown = lifted(stretched(banyanBlobs, height: h, minX: 640), by: lift)
        canopy(&context, crown, seed: 5)
    }
}

// MARK: - Scenes (unfolded)

extension JatakaArt {
    /// scene-river: morning. The banyan on the bank, the Monkey on his branch, the
    /// crocodiles in the water, the fruit island far off. Screen 03 of the designs.
    static func riverScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = stage(size, water: 136)
        let H = st.H
        let tall = st.tall
        let grow = st.grow
        let fit = st.fit
        let mood = morningMood()
        let palms: [CGFloat] = [40, 92, 330, 372, 470, 512, 596]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: 120,
            sunRadius: 38 * st.far,
            hillScale: st.far,
            palms: palms,
            ripples: 110 + Int(130 * tall),
            palmScale: st.far
        )
        let cloudWhite = Art.color(0xFFFFFF, 0.55)
        cloud(&context, 60, 150, scale: 1.1, color: cloudWhite)
        cloud(&context, 300, 96, scale: 0.8, color: cloudWhite)
        birds(&context, 236, H - 38 * st.far, color: Art.color(0x3B6E79))

        // The far island, low on the reading side.
        let islandScale: CGFloat = fit * (1 + 0.2 * tall)
        island(&context, x: 196 - 50 * tall, y: H + 4 + 30 * tall, scale: islandScale, haze: 0.1)

        // Everything on the trailing side, in the units of the design (shrunk on a short
        // window about the top trailing corner).
        let hv: CGFloat = h / fit
        let Hv: CGFloat = H / fit
        let wanted: CGFloat = min(hv * 0.46, hv - 330)
        let branchY: CGFloat = max(250, wanted)
        let dy: CGFloat = branchY - 330
        let limb: CGFloat = 1 + 0.3 * tall
        let monkeyScale: CGFloat = 0.98 * (1 + 0.3 * tall)
        let seatY: CGFloat = 317 - 11 * limb + dy
        let skin = youngCrocSkin()
        let littleScale: CGFloat = 0.42 * (1 + 0.35 * tall)
        let littleY: CGFloat = Hv + 78 + st.extra * 0.5
        Art.group(&context, x: 892 * (1 - fit), y: 0, scale: fit) { v in
            // The near bank and the Mother Crocodile beside it grow together on a tall window.
            Art.group(&v, x: 892 * (1 - grow), y: Hv * (1 - grow), scale: grow) { n in
                nearBank(&n, horizon: Hv, dusk: false)
                reeds(&n, 676, Hv + 34, count: 9, seed: 4, height: 64)
                reeds(&n, 742, Hv + 54, count: 7, seed: 12, height: 52)
                lotusPad(&n, 820, Hv + 106, 30, flower: true)
                lotusPad(&n, 760, Hv + 120, 22)
            }
            banyan(&v, height: hv, horizon: Hv, branchY: branchY, girth: grow, limb: limb)

            // The Monkey on the branch.
            ArtStyle.contactShadow(&v, 609, seatY + 5, 36 * monkeyScale, 5, alpha: 0.32)
            Art.group(&v, x: 606, y: seatY, scale: monkeyScale) { m in
                monkey(&m, pose: .sit, lookX: -2.2, lookY: 2.2, mouth: .smile)
            }
            Art.group(&v, y: dy) { f in
                canopy(&f, banyanFrontBlobs, seed: 9)
            }

            // The crocodiles: the mother near the bank, her little son out in the river.
            Art.group(&v, x: 892 * (1 - grow), y: Hv * (1 - grow), scale: grow) { n in
                Art.group(&n, x: 716, y: Hv + 62, scale: 0.8, scaleX: -1) { c in
                    croc(&c, skin: skin, lid: .sly, lookX: -1, lookY: -2, waterline: 9, water: Art.color(0x1596A0), mirrored: true)
                }
                ripples(&n, 594, Hv + 72, 230, count: 3)
            }
            Art.group(&v, x: 412, y: littleY, scale: littleScale, scaleX: -1) { c in
                croc(&c, skin: skin, lid: .wide, lookX: -1.5, lookY: -1, waterline: 9, water: Art.color(0x2AA9A6), mirrored: true)
            }
            ripples(&v, 412 - 157 * littleScale, littleY + 5, 286 * littleScale, count: 2)
        }

        // Shade under the status bar of the trailing pane.
        let shade: [(Color, CGFloat)] = [(Art.color(0x06302E, 0.55), 0), (Art.color(0x06302E, 0), 1)]
        Art.fillLinear(&context, Art.rect(460, 0, w - 460, 70), shade, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 70))

        lotusPad(&context, 60, h - 24, 34, flower: true)
        lotusPad(&context, 124, h - 4, 26)
        lotusPad(&context, 24, h + 2, 22)
        if tall > 0.25 {
            // The deeper river of a tall window: lily pads drifting in its middle.
            lotusPad(&context, 566, H + st.depth * 0.68, 30 * grow, flower: true)
            lotusPad(&context, 650, H + st.depth * 0.76, 20 * grow)
            lotusPad(&context, 500, H + st.depth * 0.86, 24 * grow)
        }
        cornerLeaves(&context, width: w, height: h, color: Art.color(0x0E5A55), scale: fit * grow)
        dragonfly(&context, 300, H + 30, scale: 1)
        dragonfly(&context, 520, H + 20, scale: 0.8)
        ArtStyle.finish(&context, size)
    }

    /// scene-ride (unfolded): mid-river. The Monkey rides the Crocodile across the trailing
    /// pane toward the fruit island, which lies far ahead under the reading side.
    static func rideScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = stage(size, water: 150)
        let H = st.H
        let tall = st.tall
        let grow = st.grow
        let fit = st.fit
        let mood = morningMood()
        let palms: [CGFloat] = [30, 84, 520, 566, 700, 852]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: 214,
            sunRadius: 40 * st.far,
            hillScale: 0.9 * st.far,
            palms: palms,
            ripples: 130 + Int(140 * tall),
            palmScale: st.far
        )
        let cloudWhite = Art.color(0xFFFFFF, 0.55)
        cloud(&context, 60, 150, scale: 1.1, color: cloudWhite)
        cloud(&context, 300, 96, scale: 0.8, color: cloudWhite)
        cloud(&context, 520, h * 0.3, scale: 1.3, color: cloudWhite)
        cloud(&context, 716, h * 0.44, scale: 1.0, color: cloudWhite)
        birds(&context, 560, H - 118 * fit, color: Art.color(0x3B6E79))

        island(&context, x: 96, y: H - 4, scale: 0.8 * fit * (1 + 0.2 * tall), haze: 0.12)
        if tall > 0.25 {
            // The middle plane of a tall window: a sandbar between the far shore and the riders.
            sandbar(&context, x: 590, y: H + 30 * grow, width: 150 * grow)
        }

        // A few leaves of the home tree still overhang the corner.
        let corner: [Blob] = [(880, 14, 62), (800, -12, 46), (905, 96, 36), (740, -20, 30)]
        let cornerScale: CGFloat = fit * (1 + 0.5 * tall)
        canopy(&context, scaled(corner, by: cornerScale, aboutX: 892), seed: 4)

        // The riders.
        let scale: CGFloat = 1.05 * fit * (1 + 0.2 * tall)
        let k: CGFloat = scale / 1.05
        let crocX: CGFloat = 892 - 410 * fit - 12 * tall
        let crocY: CGFloat = H + 84 * fit + 60 * tall
        let skin = youngCrocSkin()
        Art.group(&context, x: crocX, y: crocY, scale: scale) { g in
            croc(&g, skin: skin, lid: .sleepy, lookX: -1, lookY: 0, waterline: 12, water: Art.color(0x1596A0))
            ArtStyle.contactShadow(&g, 204, -19, 40, 6, alpha: 0.26)
            Art.group(&g, x: 206, y: -26, scale: 1.02) { m in
                monkey(&m, pose: .ride, lookX: -2, lookY: 0, mouth: .grin)
            }
        }
        ripples(&context, crocX + 150 * k, crocY + 14 * k, 320 * k, count: 3)
        let bowWave = placed("M-26,10 q-14,-4 -24,2 M-30,20 q-16,0 -26,8", x: crocX, y: crocY, scale: scale)
        Art.stroke(&context, bowWave, Art.color(0xFFFFFF, 0.8), width: ArtStyle.contourLine)
        let wake = placed("M362,16 q16,-5 30,1 M366,28 q18,-2 30,6", x: crocX, y: crocY, scale: scale)
        Art.stroke(&context, wake, Art.color(0xFFFFFF, 0.6), width: ArtStyle.detailLine)

        lotusPad(&context, 56, h - 28, 30, flower: true)
        lotusPad(&context, 120, h - 12, 22)
        if tall > 0.25 {
            lotusPad(&context, 640, H + st.depth * 0.84, 28 * grow, flower: true)
            lotusPad(&context, 730, H + st.depth * 0.92, 20 * grow)
            lotusPad(&context, 330, H + st.depth * 0.6, 22 * grow)
        }
        dragonfly(&context, 360, H + 44, scale: 0.9)
        cornerLeaves(&context, width: w, height: h, color: Art.color(0x0E5A55), scale: fit * grow)
        ArtStyle.finish(&context, size)
    }

    /// scene-island: a new tree downriver, a stepping-stone rock halfway across, the island
    /// full of fruit, the Monkey in mid-hop and the Crocodile watching, low in the water.
    static func islandScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = stage(size, water: 136)
        let H = st.H
        let tall = st.tall
        let grow = st.grow
        let fit = st.fit
        let mood = morningMood()
        let palms: [CGFloat] = [30, 80, 470, 530, 610]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: 96,
            sunRadius: 36 * st.far,
            hillScale: st.far,
            palms: palms,
            ripples: 110 + Int(130 * tall),
            palmScale: st.far
        )
        let cloudWhite = Art.color(0xFFFFFF, 0.55)
        cloud(&context, 40, 132, scale: 1.0, color: cloudWhite)
        cloud(&context, 280, 84, scale: 0.9, color: cloudWhite)
        birds(&context, 540, H - 76 * fit, color: Art.color(0x3B6E79))

        let islandScale: CGFloat = 1.15 * fit * (1 + 0.1 * tall)
        island(&context, x: 140 - 30 * tall, y: H + 4 + 26 * tall, scale: islandScale, rich: true)

        let hv: CGFloat = h / fit
        let Hv: CGFloat = H / fit
        // The near bank grows a little on a tall window; the rock stays clear of the hinge.
        let zoom: CGFloat = 1 + 0.2 * tall
        let rockY: CGFloat = Hv + 72 * zoom + 20 * tall
        let rockHeight: CGFloat = 46 * zoom
        let hopFrom = CGPoint(x: 892 - 176 * zoom, y: Hv - 34 * zoom)
        let hopTo = CGPoint(x: 576, y: rockY - rockHeight - 4)
        let hopPeak = CGPoint(x: (hopFrom.x + hopTo.x) / 2, y: min(hopFrom.y, hopTo.y) - 150 * zoom)
        let midX: CGFloat = 0.25 * hopFrom.x + 0.5 * hopPeak.x + 0.25 * hopTo.x
        let midY: CGFloat = 0.25 * hopFrom.y + 0.5 * hopPeak.y + 0.25 * hopTo.y
        let monkeyScale: CGFloat = 0.9 * zoom
        let skin = youngCrocSkin()
        let crocScale: CGFloat = 0.46 * (1 + 0.35 * tall)
        let crocY: CGFloat = Hv + 90 + st.extra * 0.55
        Art.group(&context, x: 892 * (1 - fit), y: 0, scale: fit) { v in
            Art.group(&v, x: 892 * (1 - zoom), y: Hv * (1 - zoom), scale: zoom) { n in
                nearBank(&n, horizon: Hv, dusk: false)
                reeds(&n, 690, Hv + 38, count: 6, seed: 6, height: 50)
                lotusPad(&n, 790, Hv + 112, 26, flower: true)
            }
            shoreTree(&v, height: hv, baseY: Hv - 24 * zoom, palette: figGreens, fruit: true, dusk: false, girth: zoom)

            rock(&v, cx: 566, waterY: rockY, width: 132 * zoom, height: rockHeight, flat: false, dusk: false)

            // The hop: from the bank to the rock.
            var arc = Path()
            arc.move(to: hopFrom)
            arc.addQuadCurve(to: hopTo, control: hopPeak)
            Art.stroke(&v, arc, Art.color(0xFFFFFF, 0.75), width: ArtStyle.contourLine, dash: [1, 9])
            // His shadow waits for him on the rock.
            ArtStyle.contactShadow(&v, 572, rockY - rockHeight + 5, 30 * zoom, 4, alpha: 0.22)
            Art.group(&v, x: midX, y: midY + 28 * monkeyScale, rotate: deg(-10), scale: monkeyScale) { m in
                monkey(&m, pose: .ride, lookX: -2, lookY: 2, mouth: .open)
            }

            // The Crocodile, only his eyes and back above the water.
            Art.group(&v, x: 412, y: crocY, scale: crocScale, scaleX: -1) { c in
                croc(&c, skin: skin, lid: .sly, lookX: -1.5, lookY: -2.5, waterline: 0, water: Art.color(0x2AA9A6), waterOpacity: 0.8, mirrored: true)
            }
            ripples(&v, 412 - 143 * crocScale, crocY + 3, 283 * crocScale, count: 2)
        }

        lotusPad(&context, 60, h - 24, 34, flower: true)
        lotusPad(&context, 124, h - 4, 26)
        lotusPad(&context, 24, h + 2, 22)
        if tall > 0.25 {
            lotusPad(&context, 690, H + st.depth * 0.8, 26 * grow, flower: true)
            lotusPad(&context, 610, H + st.depth * 0.9, 20 * grow)
        }
        cornerLeaves(&context, width: w, height: h, color: Art.color(0x0E5A55), scale: fit * grow)
        dragonfly(&context, 470, H + 44, scale: 0.9)
        ArtStyle.finish(&context, size)
    }

    /// scene-dusk: evening. The Crocodile lies very flat on the rock; the Monkey sits at the
    /// water's edge and looks at it. The sky stays pale for the story text.
    static func duskScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let st = stage(size, water: 136)
        let H = st.H
        let tall = st.tall
        let grow = st.grow
        let fit = st.fit
        let mood = duskMood()
        let palms: [CGFloat] = [36, 84, 300, 470, 520, 600]
        backdrop(
            &context,
            size: size,
            horizon: H,
            mood: mood,
            sunX: 128,
            sunRadius: 46 * st.far,
            hillScale: st.far,
            palms: palms,
            ripples: 100 + Int(120 * tall),
            palmScale: st.far
        )
        let cloudWarm = Art.color(0xFFF6EA, 0.6)
        cloud(&context, 70, 160, scale: 1.1, color: cloudWarm)
        cloud(&context, 290, 104, scale: 0.8, color: cloudWarm)
        birds(&context, 560, H - 84 * fit, color: Art.color(0x6A5A86))

        let islandScale: CGFloat = 0.9 * fit * (1 + 0.2 * tall)
        island(&context, x: 214 - 40 * tall, y: H + 2 + 26 * tall, scale: islandScale, dusk: true, haze: 0.1)

        let hv: CGFloat = h / fit
        let Hv: CGFloat = H / fit
        let padColor = Art.color(0x3F8A7A)
        let veinColor = Art.color(0xA9D6A0)
        Art.group(&context, x: 892 * (1 - fit), y: 0, scale: fit) { v in
            // The near bank with the Monkey on it grows on a tall window.
            Art.group(&v, x: 892 * (1 - grow), y: Hv * (1 - grow), scale: grow) { n in
                nearBank(&n, horizon: Hv, dusk: true)
                reeds(
                    &n, 690, Hv + 38,
                    count: 7,
                    seed: 6,
                    height: 54,
                    dark: Art.color(0x3F7A66),
                    light: Art.color(0x6FA07A),
                    head: Art.color(0x5A3A40)
                )
                lotusPad(&n, 800, Hv + 114, 26, flower: true, pad: padColor, vein: veinColor)
            }
            shoreTree(
                &v,
                height: hv,
                baseY: Hv - 24 * grow,
                palette: duskGreens,
                fruit: false,
                dusk: true,
                girth: 1 + 0.3 * tall
            )

            // The rock, and the Crocodile pretending to be part of it.
            sleepingRock(&v, cx: 560 - 20 * tall, waterY: Hv + 76 + 44 * tall, scale: 1 + 0.25 * tall)

            // The Monkey at the water's edge.
            Art.group(&v, x: 892 * (1 - grow), y: Hv * (1 - grow), scale: grow) { n in
                ArtStyle.contactShadow(&n, 708, Hv + 20, 40, 6, alpha: 0.3)
                Art.group(&n, x: 708, y: Hv + 2, scale: 0.9) { m in
                    monkey(&m, pose: .sit, lookX: -3, lookY: 1.2, mouth: .oh)
                }
            }
        }

        lotusPad(&context, 60, h - 24, 34, flower: true, pad: padColor, vein: veinColor)
        lotusPad(&context, 124, h - 4, 26, pad: padColor, vein: veinColor)
        lotusPad(&context, 24, h + 2, 22, pad: padColor, vein: veinColor)
        if tall > 0.25 {
            lotusPad(&context, 330, H + st.depth * 0.62, 24 * grow, flower: true, pad: padColor, vein: veinColor)
            lotusPad(&context, 700, H + st.depth * 0.88, 22 * grow, pad: padColor, vein: veinColor)
        }
        cornerLeaves(&context, width: w, height: h, color: Art.color(0x2A3F5A), scale: fit * grow)

        // Evening warmth over the lower part of the picture.
        let warm: [(Color, CGFloat)] = [(Art.color(0xFF9E7A, 0), 0), (Art.color(0xFF9E7A, 0.1), 1)]
        Art.fillLinear(&context, Art.rect(0, H - 160, w, h - H + 160), warm, from: CGPoint(x: 0, y: H - 160), to: CGPoint(x: 0, y: h))
        // A pale evening picture: a little less of the warm wash.
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.10)
    }
}
