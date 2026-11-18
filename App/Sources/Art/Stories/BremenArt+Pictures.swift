import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the two character-card portraits (432 × 400), the four
// face chips (100 × 100) and the cover of "The Bremen Town Musicians".

// MARK: - Tap-to-see pictures

extension BremenArt {
    /// see-mill: one wooden windmill with four lattice sails on a low green rise, grain sacks
    /// at its door, a wide pale sky behind.
    static func millPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light: Kit.Light = day()
        let H: CGFloat = 250
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 340, 96, scale: 0.7, color: Art.color(0xFFFFFF, 0.75))
        Kit.cloud(&context, 96, 168, scale: 0.45, color: Art.color(0xFFFFFF, 0.55))
        Kit.farTrees(&context, x0: 0, x1: 432, baseY: H + 1, height: 11, count: 22, color: light.far, seed: 5)
        farTown(&context, x: 372, baseY: H + 1, scale: 0.6, color: Art.color(0x9DB8CC))
        ArtStyle.atmosphere(&context, width: 432, top: H - 60, bottom: H + 3, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: 432, top: H, bottom: size.height, stops: meadowStops())
        Art.fill(&context, Art.rect(0, H + 3, 432, 6), Art.color(0xE9D27C, 0.85))

        // The low rise the mill stands on, and the path up to its door.
        let rise: Kit.Stops = [(Art.color(0xBFDD84), 0), (Art.color(0x8DB360), 0.5), (Art.color(0x5F8F4E), 1)]
        Kit.mound(&context, x0: 30, x1: 402, baseY: 268, height: 26, bottom: size.height, stops: rise)
        Kit.ribbon(&context, nearX: 190, nearY: 340, nearWidth: 74, farX: 216, farY: 248, farWidth: 14, stops: roadStops())
        Kit.windmill(&context, cx: 216, baseY: 246, height: 215, body: 0x8A6A52, sails: 0xF2E8D8)

        // Sacks of grain at the door.
        Kit.sack(&context, cx: 258, baseY: 254, width: 26, height: 30)
        Kit.sack(&context, cx: 282, baseY: 258, width: 24, height: 26, color: 0xD9C49A)
        Kit.sack(&context, cx: 172, baseY: 256, width: 24, height: 28, color: 0xBFA67C)
        let turf = CGRect(x: 30, y: 262, width: 372, height: 50)
        Kit.grass(&context, in: turf, count: 30, seed: 21, color: Art.color(0x4F8A4A, 0.55), height: 8)
        Kit.flowers(&context, in: CGRect(x: 60, y: 270, width: 110, height: 30), count: 6, seed: 9, petal: 0xFFFFFF)
        Kit.flowers(&context, in: CGRect(x: 280, y: 272, width: 100, height: 26), count: 5, seed: 12, petal: 0xFFE08A)
        Kit.sink(&context, size, card: 0x2C5A4A)
    }

    /// see-town-musician: the instruments of an old town band on the market cobbles — a lute
    /// leaning on a small drum, a curved horn, the player's soft hat — with a hint of stalls
    /// behind. (No figure: the lead asked for the instruments.)
    static func townMusicianPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let air: Kit.Stops = [(Art.color(0xFFEBCB), 0), (Art.color(0xF8D2A4), 0.6), (Art.color(0xE6A878), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), air, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 260))
        ArtStyle.horizonGlow(&context, width: w, y: 252, rise: 90, color: Art.color(0xFFD98A), alpha: 0.5)
        marketStall(&context, x: 96, baseY: 254, cloth: 0xC8452C)
        marketStall(&context, x: 352, baseY: 254, cloth: 0x5B6E5A)
        ArtStyle.atmosphere(&context, width: w, top: 110, bottom: 256, color: Art.color(0xFBDDB4), alpha: 0.5)

        // The cobbles.
        let stones: Kit.Stops = [(Art.color(0xD2B094), 0), (Art.color(0xAE8A70), 0.5), (Art.color(0x7A4E3C), 1)]
        Kit.ground(&context, width: w, top: 252, bottom: h, stops: stones)
        let cobbles: Path = Kit.builtCourses(CGRect(x: 0, y: 258, width: w, height: 70), seed: 14)
        Art.stroke(&context, cobbles, Art.color(0x7A4E3C, 0.45), width: 1.3)

        bandDrum(&context, cx: 228, baseY: 268)
        bandLute(&context, x: 146, baseY: 270)
        bandHorn(&context)
        bandHat(&context, cx: 84, baseY: 294)
        Kit.sink(&context, size, card: 0x7A3B2A)
    }

    /// A market stall, far and quiet: two posts, a board and a striped awning.
    static func marketStall(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, cloth: UInt32) {
        let wood: Color = Art.color(0x9A7A56)
        Art.fill(&context, Art.rect(x - 58, baseY - 104, 5, 104), wood)
        Art.fill(&context, Art.rect(x + 53, baseY - 104, 5, 104), wood)
        Art.fill(&context, Art.rect(x - 62, baseY - 48, 124, 8, radius: 2), wood)
        let awning: [CGPoint] = [
            CGPoint(x: x - 70, y: baseY - 96), CGPoint(x: x - 56, y: baseY - 128),
            CGPoint(x: x + 56, y: baseY - 128), CGPoint(x: x + 70, y: baseY - 96),
        ]
        let shape: Path = Art.polygon(awning)
        Art.fill(&context, shape, Art.color(0xF6E9D2))
        var stripes = Path()
        for index in 0..<4 {
            let sx: CGFloat = x - 60 + CGFloat(index) * 34
            stripes.addRect(CGRect(x: sx, y: baseY - 130, width: 16, height: 36))
        }
        let striped: Path = stripes
        let dye: Color = Art.color(cloth, 0.8)
        Art.clipped(&context, to: shape) { g in
            Art.fill(&g, striped, dye)
        }
        // A few round things on the board: loaves, cheeses.
        var goods = Path()
        let places: [CGFloat] = [-40, -18, 6, 30]
        for place in places {
            goods.addEllipse(in: CGRect(x: x + place - 9, y: baseY - 60, width: 18, height: 13))
        }
        Art.fill(&context, goods, Art.color(0xD9A45A))
    }

    /// The small drum: a wooden shell with a pale skin, two hoops, zigzag cords and two sticks.
    static func bandDrum(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat) {
        let half: CGFloat = 40
        let top: CGFloat = baseY - 62
        Kit.shadow(&context, cx, baseY + 2, width: 110)
        var shell = Path()
        shell.move(to: CGPoint(x: cx - half, y: top))
        shell.addLine(to: CGPoint(x: cx - half, y: baseY - 8))
        shell.addQuadCurve(to: CGPoint(x: cx + half, y: baseY - 8), control: CGPoint(x: cx, y: baseY + 12))
        shell.addLine(to: CGPoint(x: cx + half, y: top))
        shell.closeSubpath()
        Kit.solid(&context, shell, Art.color(0xB5553A), light: 0.28, shade: 0.26, rim: 2)
        var cords = Path()
        for index in 0..<5 {
            let x0: CGFloat = cx - half + CGFloat(index) * 16
            cords.move(to: CGPoint(x: x0, y: top + 12))
            cords.addLine(to: CGPoint(x: x0 + 8, y: baseY - 12))
            cords.addLine(to: CGPoint(x: x0 + 16, y: top + 12))
        }
        let lacing: Path = cords
        Art.clipped(&context, to: shell) { g in
            Art.stroke(&g, lacing, Art.color(0xF6E9D2, 0.9), width: 1.6)
        }
        // The hoops and the skin.
        var lowHoop = Path()
        lowHoop.move(to: CGPoint(x: cx - half, y: baseY - 14))
        lowHoop.addQuadCurve(to: CGPoint(x: cx + half, y: baseY - 14), control: CGPoint(x: cx, y: baseY + 6))
        Art.stroke(&context, lowHoop, Art.color(0xE0B84A), width: 6)
        let skin: Path = Art.ellipse(cx, top, half, 11)
        Art.fill(&context, Art.ellipse(cx, top + 3, half + 2, 13), Art.color(0xE0B84A))
        Kit.solid(&context, skin, Art.color(0xFBF1DC), light: 0.2, shade: 0.14)
        // Two sticks lying across the skin.
        Kit.propShaft(&context, cx - 34, top - 2, cx + 30, top - 12, wood: 0x8A5A3A, width: 4)
        Kit.propShaft(&context, cx - 22, top - 14, cx + 38, top + 2, wood: 0x8A5A3A, width: 4)
        Art.fill(&context, Art.circle(cx - 34, top - 2, 4), Art.color(0x8A5A3A))
        Art.fill(&context, Art.circle(cx + 38, top + 2, 4), Art.color(0x8A5A3A))
    }

    /// The lute, standing on (x, baseY) and leaning to the right against the drum.
    static func bandLute(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat) {
        Kit.shadow(&context, x + 6, baseY + 2, width: 90)
        Art.group(&context, x: x, y: baseY, rotate: 0.24) { g in
            // Neck and bent-back pegbox first, behind the body.
            let neck: Path = Art.rect(-7, -192, 14, 84, radius: 2)
            Kit.solid(&g, neck, Art.color(0x5A3A2A), light: 0.24, shade: 0.2)
            let pegbox: Path = Art.svg("M-7,-192 L7,-192 L22,-222 L10,-226 Z")
            Kit.solid(&g, pegbox, Art.color(0x4A3528), light: 0.24, shade: 0.2)
            let pegs: Path = Art.svg("M4,-200 l12,4 M8,-208 l12,4 M12,-216 l12,4 M2,-198 l-9,-5 M6,-207 l-9,-5")
            Art.stroke(&g, pegs, Art.color(0x8A5A3A), width: 3)
            let body: Path = Art.svg("M0,0 C-36,0 -46,-40 -32,-72 C-23,-92 -10,-102 -7,-116 L7,-116 C10,-102 23,-92 32,-72 C46,-40 36,0 0,0Z")
            let wood: Kit.Stops = [(Art.color(0xE9B872), 0), (Art.color(0xD49A52), 0.55), (Art.color(0xB5763A), 1)]
            Kit.solid(&g, body, stops: wood, light: 0.26, shade: 0.24, rim: 2)
            // The rose, the bridge and the strings.
            Art.fill(&g, Art.circle(0, -56, 12), Art.color(0x5A3A2A))
            Art.stroke(&g, Art.circle(0, -56, 14), Art.color(0x8A5A3A), width: 1.6)
            Art.stroke(&g, Art.svg("M-8,-56 L8,-56 M0,-64 L0,-48 M-6,-62 L6,-50 M6,-62 L-6,-50"), Art.color(0xE9B872, 0.8), width: 1.2)
            Art.fill(&g, Art.rect(-15, -22, 30, 5, radius: 2), Art.color(0x4A3528))
            let strings: Path = Art.svg("M-4,-20 L-3.5,-190 M-1.3,-20 L-1.2,-190 M1.3,-20 L1.2,-190 M4,-20 L3.5,-190")
            Art.stroke(&g, strings, Art.color(0xFFF6DC, 0.85), width: 0.8)
        }
    }

    /// The curved horn lying on the cobbles at the right, with its red carrying cord.
    static func bandHorn(_ context: inout GraphicsContext) {
        let mouth = CGPoint(x: 276, y: 196)
        let low = CGPoint(x: 302, y: 318)
        let bell = CGPoint(x: 384, y: 214)
        Kit.shadow(&context, 330, 274, width: 120)
        var cord = Path()
        cord.move(to: CGPoint(x: 282, y: 214))
        cord.addQuadCurve(to: CGPoint(x: 372, y: 228), control: CGPoint(x: 318, y: 196))
        Art.stroke(&context, cord, Art.color(0xC8452C), width: 2.6)
        let line: [CGPoint] = Kit.treeCurve(mouth, low, bell, steps: 18)
        let tube = Kit.treeRibbon(line, 6, 30)
        let brass: Kit.Stops = [(Art.color(0xF6D67A), 0), (Art.color(0xD9A441), 0.5), (Art.color(0xA87424), 1)]
        Kit.solid(&context, tube.shape, stops: brass, light: 0.3, shade: 0.24, rim: 2)
        // Two bands round the tube and the flare of the bell.
        let bandA: CGPoint = Kit.groundQuad(mouth, low, bell, 0.3)
        let bandB: CGPoint = Kit.groundQuad(mouth, low, bell, 0.72)
        Art.fill(&context, Art.circle(bandA.x, bandA.y, 6.5), Art.color(0xA87424))
        Art.fill(&context, Art.circle(bandB.x, bandB.y, 12), Art.color(0xA87424, 0.85))
        Art.group(&context, x: bell.x + 2, y: bell.y - 3, rotate: 0.66) { g in
            Kit.solid(&g, Art.ellipse(0, 0, 21, 8), Art.color(0xF6D67A), light: 0.3, shade: 0.2)
            Art.fill(&g, Art.ellipse(0, 0.5, 15, 5), Art.color(0x6B4318))
        }
        Art.fill(&context, Art.circle(mouth.x, mouth.y, 4.5), Art.color(0xF6D67A))
    }

    /// The player's soft hat with a feather, lying on the cobbles.
    static func bandHat(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat) {
        Kit.shadow(&context, cx, baseY + 2, width: 84)
        let brim: Path = Art.ellipse(cx, baseY - 4, 40, 9)
        Kit.solid(&context, brim, Art.color(0x3A4558), light: 0.22, shade: 0.24)
        let crown: Path = Kit.placed("M-24,0 C-28,-18 -14,-30 2,-28 C18,-27 28,-16 24,0 C10,5 -10,5 -24,0Z", x: cx, y: baseY - 6)
        Kit.solid(&context, crown, Art.color(0x4A5568), light: 0.26, shade: 0.24, rim: 1.6)
        let ribbon: Path = Kit.placed("M-24,-2 C-10,4 10,4 24,-2", x: cx, y: baseY - 6)
        Art.stroke(&context, ribbon, Art.color(0xC8452C), width: 4)
        var feather = Path()
        Kit.groundLeaf(&feather, base: CGPoint(x: cx + 16, y: baseY - 12), angle: Kit.deg(-58), length: 44, width: 9)
        Art.fill(&context, feather, Art.color(0xF6E9D2))
        Art.stroke(&context, Art.line(cx + 16, baseY - 12, cx + 38, baseY - 48), Art.color(0xC9B48A), width: 1)
    }

    /// see-timber-house: one small timber-frame house — dark oak beams in squares and
    /// slants, pale plaster, a small-paned window, a thatched roof.
    static func timberHousePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light: Kit.Light = day()
        let H: CGFloat = 266
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 330, 84, scale: 0.6, color: Art.color(0xFFFFFF, 0.7))
        Kit.farTrees(&context, x0: 0, x1: 432, baseY: H + 1, height: 26, count: 14, color: light.far, seed: 6)
        ArtStyle.atmosphere(&context, width: 432, top: H - 70, bottom: H + 3, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: 432, top: H, bottom: size.height, stops: meadowStops())
        Kit.tree(&context, x: 372, baseY: 274, height: 150, spread: 96, palette: Kit.summerGreens(), bark: 0x6B5A48, seed: 5)
        Kit.ribbon(&context, nearX: 236, nearY: 404, nearWidth: 110, farX: 222, farY: 286, farWidth: 34, stops: roadStops())
        Kit.fence(&context, x0: 8, x1: 100, baseY: 292, height: 26, color: 0xA98A62)
        Art.group(&context, x: 222, y: 288, scale: 0.78) { g in
            timberHouse(&g, cx: 0, baseY: 0, lit: false, thatch: true)
        }
        Kit.bush(&context, x: 338, baseY: 294, width: 56, palette: Kit.springGreens(), seed: 4)
        let bed = CGRect(x: 110, y: 290, width: 70, height: 14)
        Kit.flowers(&context, in: bed, count: 7, seed: 6, petal: 0xFFD25A, heart: 0xC8452C)
        let turf = CGRect(x: 0, y: 284, width: 432, height: 40)
        Kit.grass(&context, in: turf, count: 26, seed: 31, color: Art.color(0x4F8A4A, 0.55), height: 8)
        Kit.sink(&context, size, card: 0x4A3528)
    }
}

// MARK: - Portraits and faces

extension BremenArt {
    /// The Donkey's look for the front views. (The kit's front view draws a lion's ruff for
    /// any `mane`, so the crest is switched off here and a forelock is drawn instead.)
    static func donkeyFront() -> Kit.Beast {
        var look = donkeyLook()
        look.mane = false
        return look
    }

    /// The Donkey's own marks on a front-view head (head units, origin at its centre): the
    /// dark forelock between the ears and the rope halter; `singing` opens his mouth.
    static func donkeyFrontMarks(_ context: inout GraphicsContext, singing: Bool) {
        let dark: Color = Art.color(donkeyLook().dark)
        let forelock: Path = Art.svg("M-10,-26 C-7,-36 7,-36 10,-26 C6,-22 3,-20 0,-15 C-3,-20 -6,-22 -10,-26Z")
        Art.fill(&context, forelock, dark)
        let rope: Path = Art.svg("M-15,13 Q0,18 15,13 M-15,13 L-27,-1 M15,13 L27,-1")
        Art.stroke(&context, rope, Art.color(ropeHex), width: 2.6)
        Art.stroke(&context, Art.svg("M-13,12 Q-2,16 8,14.5"), Art.color(0xE8C890, 0.7), width: 0.9)
        if singing {
            openMouth(&context, at: CGPoint(x: 0, y: 33.5), size: 5.2)
        }
    }

    /// char-donkey: the Donkey from the chest up, head lifted, ears straight up, mouth open
    /// mid hee-haw, on the card's warm golden sky; the blank finger post behind him.
    static func donkeyPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFFE08A, bottom: 0xE59A52, halo: 0xFFF6D0, rays: true) { g in
            Kit.signpost(&g, cx: 62, baseY: 404, height: 150, color: 0x8A6A4A, boards: 1)
            poplar(&g, x: 372, baseY: 404, height: 150, seed: 10)
            Art.group(&g, x: 216, y: 153, scale: 1.9) { b in
                Kit.beastBust(&b, donkeyFront(), mood: .surprised, look: CGPoint(x: 0, y: -0.2))
                donkeyFrontMarks(&b, singing: true)
            }
        }
    }

    /// char-rooster: the Rooster on a farm gate, chest out, beak open to the sky, tail
    /// feathers curling, on the card's warm peach sky.
    static func roosterPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFFD9A0, bottom: 0xF0825A, halo: 0xFFF2D6, rays: true) { g in
            // The gate: two posts, two rails and a slanted brace.
            let wood: Color = Art.color(0x9A7A56)
            var brace = Path()
            brace.move(to: CGPoint(x: 70, y: 398))
            brace.addLine(to: CGPoint(x: 362, y: 330))
            Art.stroke(&g, brace, Art.color(0x7A5E40), width: 10, cap: .butt)
            let lowRail: Path = Art.rect(36, 366, 360, 14, radius: 3)
            Kit.solid(&g, lowRail, wood, light: 0.24, shade: 0.2)
            let leftPost: Path = Art.rect(48, 292, 20, 112, radius: 5)
            let rightPost: Path = Art.rect(364, 292, 20, 112, radius: 5)
            Kit.solid(&g, leftPost, Art.color(0x8A6A4A), light: 0.28, shade: 0.22)
            Kit.solid(&g, rightPost, Art.color(0x8A6A4A), light: 0.28, shade: 0.22)
            let topRail: Path = Art.rect(36, 318, 360, 17, radius: 4)
            Kit.solid(&g, topRail, wood, light: 0.28, shade: 0.2, rim: 1.6)
            Art.stroke(&g, Art.line(60, 328, 372, 328), Art.color(0x7A5E40, 0.5), width: 1.2)
            ArtStyle.contactShadow(&g, 228, 319, 50, 5, alpha: 0.28)
            Art.group(&g, x: 222, y: 318, scale: 3.6) { r in
                rooster(&r, crowing: true, look: CGPoint(x: -0.2, y: -0.6))
            }
        }
    }

    /// face-donkey.
    static func donkeyFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xE3E7EE) { g in
            Art.group(&g, x: 0, y: 8, scale: 0.95) { f in
                Kit.beastFace(&f, donkeyFront(), mood: .happy)
                donkeyFrontMarks(&f, singing: false)
            }
        }
    }

    /// face-dog.
    static func dogFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE2C2) { g in
            Art.group(&g, x: 0, y: -4, scale: 1.1) { f in
                Kit.beastFace(&f, dogLook(), mood: .happy)
            }
        }
    }

    /// face-cat.
    static func catFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xEBDDF2) { g in
            Art.group(&g, x: 0, y: 7, scale: 1.2) { f in
                Kit.beastFace(&f, catLook(), mood: .calm)
            }
        }
    }

    /// face-rooster.
    static func roosterFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE0D6) { g in
            Art.group(&g, x: 3, y: 8, scale: 1.0) { f in
                Kit.birdFace(&f, roosterLook())
            }
        }
    }
}

// MARK: - Cover

extension BremenArt {
    /// The cover: the tower of four outside the glowing window at pale dusk, all four with
    /// their mouths open in song.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let hd: CGFloat = frame.hd
            let H: CGFloat = frame.H
            let light: Kit.Light = dusk()
            let glowColor: Color = Art.color(0xFFCB6B)
            let full = CGSize(width: 240, height: hd)
            Kit.sky(&g, full, horizon: H, light: light)
            let wood: CGFloat = max(40, H * 0.62)
            forestEdge(&g, x0: -10, x1: 250, baseY: H + 3, height: wood, seed: 17)
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: forestFloorStops())
            let leafBed = CGRect(x: 0, y: H + 8, width: 150, height: max(1, hd - H - 8))
            Kit.pebbles(&g, in: leafBed, count: 8, seed: 23, color: 0xB07A42)

            // The stack is tall: size it so it holds between the top edge and its feet.
            let feet: CGFloat = min(hd - 8, H + 46 * frame.k)
            let fitted: CGFloat = (feet - 10) / 280
            let s: CGFloat = max(0.2, min(0.8, fitted))
            let towerX: CGFloat = 120 - 35 * s
            Art.group(&g, x: towerX, y: feet, scale: s) { t in
                timberHouse(&t, cx: 247, baseY: -18, lit: true)
                Art.glow(&t, 124, -128, 150, glowColor, alpha: 0.22)
            }
            Art.group(&g, x: towerX, y: feet, scale: s, scaleX: -1) { t in
                tower(&t, mirrored: true, singing: true)
            }
            Art.glow(&g, towerX + 86 * s, feet - 132 * s, 64 * s, glowColor, alpha: 0.16)

            // Near-plane framing: ferns at the foot, leaves in the top trailing corner.
            Kit.grassTuft(&g, x: 12, baseY: hd - 3, height: 30 * frame.k, color: 0x2F4F40, seed: 2)
            Kit.cornerLeaves(&g, size: full, corner: 1, color: Art.color(0x2F4F40), scale: 0.42, seed: 5)
        }
    }
}
