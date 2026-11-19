import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the character-card portraits (432 × 400), the face
// chips (100 × 100) and the cover of "Sadko". A DARK story: every picture is lamplight, night
// or deep water, on the cards' own dark colours.

extension SadkoArt {
    // MARK: see-gusli

    /// The small wing-shaped maple gusli with seven strings, lying flat on a dark oiled board,
    /// seen from above and a little to one side, in warm lamplight from the upper left.
    static func gusliPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let board: Kit.Stops = [(Art.color(0x7A4A2C), 0), (Art.color(0x5A3420), 0.55), (Art.color(0x3A2014), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), board, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        // The grain of the planks, and two seams between them.
        var random = ArtRandom(17)
        var grain = Path()
        for i in 0..<9 {
            let y: CGFloat = 24 + CGFloat(i) * 44 + Kit.rnd(&random) * 10
            let sway: CGFloat = 4 + Kit.rnd(&random) * 6
            grain.move(to: CGPoint(x: -10, y: y))
            grain.addCurve(
                to: CGPoint(x: w + 10, y: y + sway),
                control1: CGPoint(x: w * 0.3, y: y - sway),
                control2: CGPoint(x: w * 0.7, y: y + sway * 2)
            )
        }
        Art.stroke(&context, grain, Art.color(0x2E1A10, 0.45), width: 1.4)
        let seams: Path = Art.svg("M-10,112 C140,106 290,116 442,110 M-10,268 C150,262 300,274 442,266")
        Art.stroke(&context, seams, Art.color(0x24140C, 0.75), width: 2.4)
        let seamLit: Path = seams.applying(CGAffineTransform(translationX: 0, y: 2.4))
        Art.stroke(&context, seamLit, Art.color(0xB07A50, 0.25), width: 1)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: h), seed: 41, color: Art.color(0xFFD9B0), alpha: 0.06)
        // The lamplight pooling from the upper left.
        Art.glow(&context, 130, 100, 300, Art.color(0xFFC65A), alpha: 0.22)
        // The gusli: its edge first (it is a shallow box), then its face.
        let cx: CGFloat = 220
        let cy: CGFloat = 180
        ArtStyle.contactShadow(&context, cx + 18, cy + 34, 150, 30, alpha: 0.5)
        Art.group(&context, x: cx, y: cy, rotate: Kit.deg(-9), scale: 4.1) { g in
            let side: Path = Art.svg("M-28,-10 C-10,-13 14,-9 29,-3 L29,4 C12,9 -12,12 -28,10 C-32,4 -32,-4 -28,-10Z")
            let edge: Path = side.applying(CGAffineTransform(translationX: 0.6, y: 3.2))
            Art.fill(&g, edge, Art.color(0x6E4322))
            Art.fill(&g, edge, ArtStyle.coolShade.opacity(0.25))
            gusli(&g)
            // A carved line along the wide wing, and the warm sheen of the maple.
            let carving: Path = Art.svg("M-25,-7.4 C-10,-10 10,-6.6 21,-2.2 M-25,7.6 C-10,9.4 6,7.4 21,2.8")
            Art.stroke(&g, carving, Art.color(0x8A5A30, 0.55), width: 0.5)
            Art.glow(&g, -12, -6, 16, ArtStyle.warmLight, alpha: 0.2)
        }
        Kit.sink(&context, size, card: 0x5A3420)
    }

    // MARK: see-lake-ilmen

    /// Lake Ilmen at night: wide flat water under many stars, a low far shore of birch and
    /// pine, a low moon on the left, and the one smooth white boulder on the near bank.
    static func lakeIlmenPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = night()
        let H: CGFloat = 176
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.stars(&context, width: w, maxY: H - 14, count: 120, seed: 52)
        Art.glow(&context, 92, H - 34, 64, Art.color(0xBFD3E6), alpha: 0.18)
        Kit.moon(&context, 92, H - 34, 10, color: Art.color(0xE6E0C4))
        // The far shore: a flat dark line of forest.
        Kit.farTrees(&context, x0: 0, x1: w, baseY: H + 2, height: 15, count: 34, color: Art.color(0x0E1A30), conifer: true, seed: 8)
        let shore: Path = Kit.ridge(width: w, y: H - 3, amp: 2.5, seed: 15, bottom: H + 5, step: 6)
        Art.fill(&context, shore, light.far)
        let lake: Kit.Stops = [
            (Art.color(0x1D3F62), 0), (Art.color(0x10294A), 0.3), (Art.color(0x0A1A33), 0.75), (Art.color(0x070E22), 1),
        ]
        Kit.water(&context, width: w, top: H, bottom: h, stops: lake, light: light, ripples: 22, seed: 12)
        Kit.glints(&context, x: 92, top: H + 2, depth: 90, color: Art.color(0xE6E0C4, 0.5), count: 18, seed: 4)
        Kit.swells(&context, width: w, top: H + 8, bottom: h, rows: 5, crest: Art.color(0xBFD3E6), seed: 12)
        // The near bank, low and reedy.
        var bank = Path()
        bank.move(to: CGPoint(x: -10, y: 268))
        bank.addQuadCurve(to: CGPoint(x: 150, y: 250), control: CGPoint(x: 60, y: 252))
        bank.addQuadCurve(to: CGPoint(x: 300, y: 252), control: CGPoint(x: 226, y: 240))
        bank.addQuadCurve(to: CGPoint(x: 442, y: 272), control: CGPoint(x: 380, y: 256))
        bank.addLine(to: CGPoint(x: 442, y: h + 10))
        bank.addLine(to: CGPoint(x: -10, y: h + 10))
        bank.closeSubpath()
        let turf: Kit.Stops = [(Art.color(0x22344A), 0), (Art.color(0x121E2E), 0.35), (Art.color(0x0A1424), 1)]
        Art.fillLinear(&context, bank, turf, from: CGPoint(x: 0, y: 244), to: CGPoint(x: 0, y: h))
        var crest = Path()
        crest.move(to: CGPoint(x: -10, y: 268))
        crest.addQuadCurve(to: CGPoint(x: 150, y: 250), control: CGPoint(x: 60, y: 252))
        crest.addQuadCurve(to: CGPoint(x: 300, y: 252), control: CGPoint(x: 226, y: 240))
        Art.stroke(&context, crest, Art.color(0x7F9AB8, 0.4), width: 1.6)
        let dark: Color = Art.color(0x050A18)
        reedClump(&context, 38, 270, count: 9, height: 62, seed: 7, color: dark)
        reedClump(&context, 118, 256, count: 5, height: 32, seed: 3, color: dark)
        reedClump(&context, 396, 274, count: 8, height: 56, seed: 11, color: dark)
        let pebbles: [(CGFloat, CGFloat, CGFloat)] = [(96, 292, 9), (330, 288, 7), (360, 300, 10), (150, 306, 6)]
        for pebble in pebbles {
            let stone: Path = Art.ellipse(pebble.0, pebble.1, pebble.2, pebble.2 * 0.45)
            Kit.solid(&context, stone, Art.color(0x5E6E88), light: 0.3, shade: 0.3)
        }
        // The white stone: the brightest thing in the picture.
        Art.glow(&context, 216, 222, 120, Art.color(0xBFD3E6), alpha: 0.18)
        Art.group(&context, x: 208, y: 262, scale: 2.1) { g in
            whiteStone(&g)
        }
        Kit.sink(&context, size, card: 0x163B4F)
    }

    // MARK: see-bylina

    /// An old singer with a white beard on a wooden bench in a timber hall, mouth open in
    /// song and one hand raised, a single candle on its stand beside him.
    static func bylinaPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let floorY: CGFloat = 300
        pictureLogWall(&context, width: w, bottom: floorY)
        // The plank floor, its boards running toward the viewer.
        let planks: Kit.Stops = [(Art.color(0x4A2E26), 0), (Art.color(0x2E1A1C), 1)]
        Art.fillLinear(&context, Art.rect(0, floorY, w, h - floorY), planks, from: CGPoint(x: 0, y: floorY), to: CGPoint(x: 0, y: h))
        var boards = Path()
        for i in 0..<9 {
            let x: CGFloat = -64 + CGFloat(i) * 70
            let far: CGFloat = 216 + (x - 216) * 0.6
            boards.move(to: CGPoint(x: far, y: floorY))
            boards.addLine(to: CGPoint(x: x, y: h))
        }
        Art.stroke(&context, boards, Art.color(0x1A0E12, 0.6), width: 1.4)
        Art.fill(&context, Art.rect(0, floorY, w, 4), ArtStyle.coolShade.opacity(0.3))
        // The candle on the left: the one light of the picture.
        Art.glow(&context, 112, 170, 250, Art.color(0xFFC65A), alpha: 0.26)
        pictureCandle(&context, 112, floorY + 6, height: 104)
        // The bench and the singer.
        let p: Kit.Person = singerLook()
        var r = Kit.bodySitRig(p)
        r.nearElbow = Kit.pt(-22, 6)
        r.nearHand = Kit.pt(-30, -22)
        r.openHand = true
        Art.group(&context, x: 246, y: floorY + 4, scale: 1.45) { g in
            Kit.shadow(&g, 22, 1, width: 160, alpha: 0.4)
            pictureBench(&g)
            figure(&g, p, r, look: CGPoint(x: -0.5, y: -0.3), mouth: .open)
        }
        // Candlelight on his raised hand and face.
        Art.glow(&context, 200, 140, 70, Art.color(0xFFC65A), alpha: 0.12)
        Kit.sink(&context, size, card: 0x4A2A45)
    }

    /// The wall of a timber hall: round horizontal logs from the top down to `bottom`, the
    /// round log ends of a notched corner at the right.
    static func pictureLogWall(_ context: inout GraphicsContext, width w: CGFloat, bottom: CGFloat) {
        let logTone: Kit.Stops = [(Art.color(0x5E3E44), 0), (Art.color(0x46303A), 0.45), (Art.color(0x24141E), 1)]
        var seams = Path()
        var ends = Path()
        var rings = Path()
        var y: CGFloat = bottom
        while y > -30 {
            let top: CGFloat = y - 30
            Art.fillLinear(&context, Art.rect(0, top, w, 30), logTone, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: y))
            seams.move(to: CGPoint(x: 0, y: y))
            seams.addLine(to: CGPoint(x: w, y: y))
            ends.addPath(Art.circle(w - 14, top + 15, 14))
            rings.addPath(Art.circle(w - 14, top + 15, 8))
            y = top
        }
        Art.stroke(&context, seams, Art.color(0x1A0E16, 0.8), width: 2.6)
        Kit.solid(&context, ends, Art.color(0x7A5A4E), light: 0.24, shade: 0.3)
        Art.stroke(&context, rings, Art.color(0x4A3036, 0.6), width: 1)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: bottom), seed: 23, color: Art.color(0xFFD9B0), alpha: 0.05)
        // The hall is dim: deeper toward the right, away from the candle.
        let dim: Kit.Stops = [(ArtStyle.coolShade.opacity(0), 0), (ArtStyle.coolShade.opacity(0.35), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, bottom), dim, from: CGPoint(x: 120, y: 0), to: CGPoint(x: w, y: bottom))
    }

    /// A tall turned wooden candle stand standing on (x, baseY), `height` to its dish, with a
    /// beeswax candle and its flame.
    static func pictureCandle(_ context: inout GraphicsContext, _ x: CGFloat, _ baseY: CGFloat, height: CGFloat) {
        let top: CGFloat = baseY - height
        ArtStyle.contactShadow(&context, x + 4, baseY, 26, 5, alpha: 0.4)
        let post: Path = Art.rect(x - 4, top + 6, 8, height - 12, radius: 3)
        Kit.solid(&context, post, Art.color(0x6E4A30), light: 0.34, shade: 0.3)
        let knop: Path = Art.ellipse(x, top + height * 0.45, 7, 5)
        Kit.solid(&context, knop, Art.color(0x7A5436), light: 0.34, shade: 0.3)
        let foot: Path = Kit.placed("M-20,0 C-18,-8 -8,-10 0,-10 C8,-10 18,-8 20,0Z", x: x, y: baseY)
        Kit.solid(&context, foot, Art.color(0x5E3E28), light: 0.3, shade: 0.3)
        let dish: Path = Art.ellipse(x, top + 6, 16, 4.5)
        Kit.solid(&context, dish, Art.color(0x8A6040), light: 0.34, shade: 0.24)
        let wax: Path = Art.rect(x - 5, top - 22, 10, 28, radius: 2)
        Kit.solid(&context, wax, stops: Kit.stops(0xF2DFA8, 0xC9A866), light: 0.3, shade: 0.24)
        Art.glow(&context, x, top - 34, 90, Art.color(0xFFC65A), alpha: 0.4)
        Art.stroke(&context, Art.line(x, top - 22, x, top - 27), Art.color(0x2A1A12), width: 1.2)
        let flame: Path = Kit.placed("M0,-16 C5,-10 6,-5 4,-1 C2,2 -2,2 -4,-1 C-6,-5 -4,-10 0,-16Z", x: x, y: top - 25)
        Art.fill(&context, flame, Art.color(0xFF9A3A))
        Art.fill(&context, Art.ellipse(x, top - 29, 2.2, 4.4), Art.color(0xFFE9A8))
    }

    /// A plain wooden bench seen from the front, its seat 34 high, in person units (origin on
    /// the floor under the sitter), with a wooden bowl standing at its far end.
    static func pictureBench(_ context: inout GraphicsContext) {
        let wood: Kit.Stops = [(Art.color(0x8A6040), 0), (Art.color(0x4A3024), 1)]
        var legs = Path()
        legs.addPath(Art.rect(-38, -26, 7, 26, radius: 2))
        legs.addPath(Art.rect(88, -26, 7, 26, radius: 2))
        Kit.solid(&context, legs, Art.color(0x3A2620), light: 0.2, shade: 0.3)
        let seat: Path = Art.rect(-46, -34, 150, 9, radius: 2)
        Kit.solid(&context, seat, stops: wood, light: 0.32, shade: 0.26, rim: 1)
        let bowl: Path = Art.svg("M70,-46 L102,-46 C102,-38 94,-34 86,-34 C78,-34 70,-38 70,-46Z")
        Kit.solid(&context, bowl, Art.color(0x9A6E44), light: 0.32, shade: 0.28)
        Art.stroke(&context, Art.line(71, -45.4, 101, -45.4), Art.color(0xD9A070, 0.6), width: 1.2)
    }

    // MARK: see-river-roads

    /// One clinker-built river ship with its square red sail and carved prow, loaded with
    /// barrels and tied bundles of fur, on dark river water between forest banks at night.
    static func riverRoadsPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = night()
        let H: CGFloat = 196
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.stars(&context, width: w, maxY: H - 24, count: 90, seed: 64)
        Art.glow(&context, 64, H - 40, 56, Art.color(0xBFD3E6), alpha: 0.16)
        Kit.moon(&context, 64, H - 40, 9, color: Art.color(0xE6E0C4))
        // The forest banks of the river, far and dark.
        Kit.farTrees(&context, x0: 0, x1: w, baseY: H + 2, height: 24, count: 38, color: Art.color(0x0C1830), conifer: true, seed: 21)
        let banks: Path = Kit.ridge(width: w, y: H - 4, amp: 3, seed: 9, bottom: H + 5, step: 6)
        Art.fill(&context, banks, light.far)
        let river: Kit.Stops = [(Art.color(0x1F4A5A), 0), (Art.color(0x14323F), 0.35), (Art.color(0x0B1F2A), 1)]
        Kit.water(&context, width: w, top: H, bottom: h, stops: river, light: light, ripples: 24, seed: 31)
        Kit.glints(&context, x: 64, top: H + 2, depth: 100, color: Art.color(0xE6E0C4, 0.45), count: 16, seed: 6)
        // The sail's red, lying blurred on the water under the ship.
        let waterY: CGFloat = 288
        Art.blurred(&context, radius: 8, opacity: 0.5) { g in
            Art.fill(&g, Art.ellipse(214, waterY + 34, 70, 22), Art.color(0x7E1F26))
        }
        Art.group(&context, x: 222, y: waterY, scale: 0.98) { g in
            shipSail(&g)
            pictureCargo(&g)
            shipHull(&g)
            // A horn lantern on the stern.
            Art.glow(&g, 104, -52, 60, Art.color(0xFFC65A), alpha: 0.35)
            let lantern: Path = Art.rect(100, -58, 8, 11, radius: 2)
            Art.fill(&g, lantern, Art.color(0xFFC65A))
            Art.stroke(&g, lantern, Art.color(0x4A3424), width: 1.2)
            Kit.ripples(&g, 0, 10, 270, count: 3, color: Art.color(0xE9EEF2), opacity: 0.4)
        }
        Kit.sink(&context, size, card: 0x1F4A4A)
    }

    /// The load of a trading ship, in ship units (drawn after the sail, before the hull, so
    /// the gunwale hides the feet of the load): barrels of wax and honey, bundles of fur.
    static func pictureCargo(_ context: inout GraphicsContext) {
        let barrels: [(CGFloat, CGFloat)] = [(-74, -18), (-52, -18), (44, -18)]
        for spot in barrels {
            Art.group(&context, x: spot.0, y: spot.1) { g in
                barrel(&g)
            }
        }
        let furs: [(CGFloat, CGFloat, UInt32)] = [
            (-24, -18, 0x7A5232), (4, -18, 0x5E4030), (-10, -33, 0x8A6A4A), (72, -21, 0x6A4A30), (60, -36, 0x7A5232),
        ]
        for bundle in furs {
            Art.group(&context, x: bundle.0, y: bundle.1) { g in
                furBundle(&g, hex: bundle.2)
            }
        }
    }

    // MARK: Character cards (432 × 400)

    /// char-sadko: Sadko in his Part I tunic with the red embroidered collar, holding the
    /// gusli against his chest, looking a little upward, half smiling, under a night sky.
    static func sadkoPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x2F5C8A, bottom: 0x0E1B33, halo: 0xF3D9A8, rays: false) { g in
            Kit.stars(&g, width: 432, maxY: 230, count: 46, seed: 61)
            Art.glow(&g, 70, 92, 50, Art.color(0xBFD3E6), alpha: 0.2)
            Kit.moon(&g, 70, 92, 13, color: Art.color(0xE6E0C4))
            let p: Kit.Person = sadkoLook()
            Art.group(&g, x: 216, y: 150, scale: 2.2) { b in
                Kit.bust(&b, p, look: CGPoint(x: 0, y: -0.6), mouth: .smile)
                // Gold stitches along the red collar.
                var stitches = Path()
                for i in 0..<7 {
                    let t: CGFloat = CGFloat(i) / 6
                    let u: CGFloat = 1 - t
                    let x: CGFloat = -17 + 34 * t
                    let ends: CGFloat = 34 * u * u + 34 * t * t
                    let dip: CGFloat = 116 * t * u
                    let y: CGFloat = ends + dip
                    stitches.addPath(Art.circle(x, y, 1.3))
                }
                Art.fill(&b, stitches, Art.color(0xF2C46A))
            }
            // The arms come round to hold the gusli against his chest.
            Kit.limb(&g, "M98,300 Q104,356 150,350", 30, Kit.personTone(0xE4DAC2, 0.82))
            Kit.limb(&g, "M336,296 Q330,342 250,326", 30, Art.color(0xE4DAC2))
            Art.group(&g, x: 214, y: 324, rotate: Kit.deg(-14), scale: 2.5) { s in
                gusli(&s)
            }
            let skin: Color = Art.color(skinHex)
            Kit.solid(&g, Art.ellipse(150, 348, 13, 11), skin, light: 0.3, shade: 0.24)
            Kit.solid(&g, Art.ellipse(246, 322, 12, 11), skin, light: 0.3, shade: 0.24)
            var fingers = Path()
            fingers.addPath(Art.circle(233, 314, 4.6))
            fingers.addPath(Art.circle(229, 323, 4.6))
            Art.fill(&g, fingers, skin)
        }
    }

    /// char-sea-tsar: the Sea Tsar laughing, head and shoulders, his coral-and-shell crown
    /// tilted, the green beard spreading out of the frame, small fish swimming through it, in
    /// deep green water with gold light falling from above.
    static func seaTsarPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x1F7A6B, bottom: 0x0A2A33, halo: 0xE6D98A, rays: false) { g in
            lightShafts(&g, x0: 40, x1: 400, bottom: 400)
            bubbles(&g, x: 58, y0: 120, y1: 330, count: 6, seed: 7)
            bubbles(&g, x: 386, y0: 60, y1: 250, count: 5, seed: 19)
            Art.group(&g, x: 216, y: 152, rotate: Kit.deg(-5), scale: 1.4) { t in
                let robe: Path = Art.svg("M-160,240 C-160,96 -96,40 0,40 C96,40 160,96 160,240Z")
                let cloth: Kit.Stops = [(Art.color(0x3BA3A8), 0), (Art.color(robeHex), 0.4), (Art.color(0x174E66), 1)]
                Kit.solid(&t, robe, stops: cloth, light: 0.24, shade: 0.26, rim: 2)
                let waves: Path = Art.svg("M-150,150 C-90,130 -40,170 0,150 C40,130 90,170 150,150 M-156,200 C-90,180 -40,220 0,200 C40,180 90,220 156,200")
                Art.clipped(&t, to: robe) { c in
                    Art.stroke(&c, waves, Art.color(0x8FE3C8, 0.35), width: 3)
                }
                tsarHead(&t, laughing: true)
            }
            // Small gold-finned fish swimming through the beard: (x, y, turn, scale, mirrored).
            let school: [(CGFloat, CGFloat, CGFloat, CGFloat, Bool)] = [
                (92, 318, 14, 1.3, false), (344, 282, -10, 1.1, true), (262, 368, 6, 1, false),
            ]
            for place in school {
                let flip: CGFloat = place.4 ? -1 : 1
                Art.glow(&g, place.0, place.1, 34, Art.color(0xFFC65A), alpha: 0.22)
                Art.group(&g, x: place.0, y: place.1, rotate: Kit.deg(place.2), scale: place.3, scaleX: flip) { f in
                    fish(&f)
                }
            }
        }
    }

    // MARK: Faces (100 × 100)

    /// face-sadko: Sadko's round-cut brown hair and clean-shaven face over his red collar.
    static func sadkoFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xC8452B) { g in
            Art.fill(&g, Art.ellipse(0, 60, 36, 18), Art.color(0xE4DAC2))
            Art.fill(&g, Art.rect(-9, 28, 18, 20, radius: 5), Kit.personTone(skinHex, 0.9))
            Art.stroke(&g, Art.svg("M-15,44 Q0,55 15,44"), Art.color(0x9A2A22), width: 4.5)
            Art.group(&g, x: 0, y: 2, scale: 1.25) { f in
                Kit.personHead(&f, sadkoLook(), look: CGPoint(x: 0, y: -0.2), mouth: .smile)
            }
        }
    }

    /// face-sea-tsar: the broad jolly face, the coral crown and the top of the green beard.
    static func seaTsarFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0x1F7A6B) { g in
            Art.group(&g, x: 0, y: 14, scale: 0.54) { f in
                tsarHead(&f)
            }
        }
    }

    /// face-chernava: long straight dark hair, a calm face, the plain grey gown.
    static func chernavaFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0x55668F) { g in
            Art.fill(&g, Art.ellipse(0, 60, 34, 18), Art.color(0x8E97A8))
            Art.fill(&g, Art.rect(-8, 28, 16, 20, radius: 5), Kit.personTone(0xE6C8AE, 0.9))
            Art.group(&g, x: 0, y: 2, scale: 1.25) { f in
                Kit.personHead(&f, chernavaLook(), look: CGPoint(x: -0.2, y: 0), mouth: .smile)
            }
        }
    }
}

// MARK: - Cover (300 wide, 150…375 tall)

extension SadkoArt {
    /// Night at Lake Ilmen: Sadko on the white stone in the lower middle, playing; the Sea
    /// Tsar's crowned head and green beard rising from the dark water behind him; one
    /// gold-finned fish leaping between them under the stars.
    static func coverArt(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size, wash: 0.04, vignette: 0.14) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let light = night()
            Kit.sky(&g, CGSize(width: 240, height: hd), horizon: H, light: light)
            Kit.stars(&g, width: 240, maxY: H - 8, count: 70, seed: 73)
            let shore: Path = Kit.ridge(width: 240, y: H - 3 * k, amp: 2 * k, seed: 15, bottom: H + 4, step: 5)
            Art.fill(&g, shore, light.far)
            let lake: Kit.Stops = [(Art.color(0x1D3F62), 0), (Art.color(0x10294A), 0.3), (Art.color(0x070E22), 1)]
            Kit.water(&g, width: 240, top: H, bottom: hd, stops: lake, light: light, ripples: 14, seed: 12)
            Kit.swells(&g, width: 240, top: H + 6, bottom: hd, rows: 5, crest: Art.color(0xBFD3E6), seed: 12)
            // The Sea Tsar, risen behind, a little left of the middle.
            let tx: CGFloat = 92
            let ts: CGFloat = 0.46 * k
            Art.glow(&g, tx, H - 50 * k, 100 * k, Art.color(0x4FAE9E), alpha: 0.24)
            Art.group(&g, x: tx, y: H - 100 * ts, scale: ts) { t in
                tsarRising(&t, waterline: 100)
            }
            coverFish(&g, x: 138, y: H - 16 * k, k: k, waterY: H)
            // The near bank, the white stone and Sadko looking up as he plays.
            let gy: CGFloat = H + 44 * k
            var bank = Path()
            bank.move(to: CGPoint(x: 96, y: hd + 2))
            bank.addQuadCurve(to: CGPoint(x: 150, y: gy - 4 * k), control: CGPoint(x: 110, y: gy))
            bank.addLine(to: CGPoint(x: 242, y: gy - 10 * k))
            bank.addLine(to: CGPoint(x: 242, y: hd + 2))
            bank.closeSubpath()
            Art.fill(&g, bank, Art.color(0x0E1828))
            Art.stroke(&g, Art.line(150, gy - 4 * k, 242, gy - 10 * k), Art.color(0x7F9AB8, 0.4), width: 1)
            let sk: CGFloat = 0.4 * k
            Art.glow(&g, 172, gy - 50 * sk, 60 * k, Art.color(0xBFD3E6), alpha: 0.16)
            Art.group(&g, x: 168, y: gy, scale: sk) { s in
                whiteStone(&s)
                sadkoPlaying(&s, look: CGPoint(x: -0.7, y: -0.7), mouth: .oh)
            }
            let dark: Color = Art.color(0x050A18)
            reedClump(&g, 226, gy - 8 * k, count: 5, height: 30 * k, seed: 13, color: dark)
            reedClump(&g, 12, hd + 2, count: 6, height: 34 * k, seed: 7, color: dark)
            coverBough(&g, k: k)
        }
    }

    /// The gold-finned fish leaping out of the lake at (x, y), with drops and rings below.
    static func coverFish(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, k: CGFloat, waterY: CGFloat) {
        Art.glow(&context, x, y, 22 * k, Art.color(0xFFC65A), alpha: 0.35)
        Art.group(&context, x: x, y: y, rotate: Kit.deg(-32), scale: 0.42 * k) { f in
            fish(&f)
        }
        var drops = Path()
        drops.addPath(Art.circle(x + 12 * k, y + 9 * k, 1.4 * k))
        drops.addPath(Art.circle(x + 6 * k, y + 13 * k, 1.1 * k))
        drops.addPath(Art.circle(x + 15 * k, y + 15 * k, 0.9 * k))
        Art.fill(&context, drops, Art.color(0xE9EEF2, 0.7))
        Kit.ripples(&context, x + 8 * k, waterY + 6 * k, 30 * k, count: 2, color: Art.color(0xE9EEF2), opacity: 0.5)
    }

    /// A dark birch bough reaching into the top-right corner of the cover.
    static func coverBough(_ context: inout GraphicsContext, k: CGFloat) {
        let twigs: Path = Kit.placed("M0,0 C-20,10 -44,12 -70,26 M-30,12 C-36,22 -40,30 -38,40", x: 242, y: -2, scale: k)
        Art.stroke(&context, twigs, Art.color(0x08101F), width: 2.4 * k)
        let spots: [(CGFloat, CGFloat)] = [(-12, 6), (-22, 12), (-40, 16), (-58, 24), (-72, 30), (-34, 28), (-40, 41)]
        var leaves = Path()
        for spot in spots {
            let lx: CGFloat = 242 + spot.0 * k
            let ly: CGFloat = -2 + spot.1 * k
            leaves.addPath(Art.ellipse(lx, ly, 5 * k, 3.4 * k))
        }
        Art.fill(&context, leaves, Art.color(0x08101F))
    }
}
