import SwiftUI
import OmramoCore

// The tap-to-see pictures, the character-card portraits, the face chips and the cover of
// "The Lion and the Hare".

// MARK: - Tap-to-see pictures (432 × 404)

extension LionHareArt {
    /// "Persia": a small green valley with a stream and poplars, held between dry golden
    /// hills. No animals, no buildings.
    static func persiaPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = day()
        let H: CGFloat = 196
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 318, 78, scale: 0.6, color: Art.color(0xFFFFFF, 0.6))
        farLand(&context, width: size.width, horizon: H, scale: 1.1, light: light, seed: 4)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: dryGround())
        persiaHills(&context)
        let floor = Art.svg("M196,244 C204,238 228,238 236,244 C290,280 360,300 442,310 L442,404 L-10,404 L-10,316 C70,304 150,280 196,244Z")
        Art.fillLinear(&context, floor, greenGround(), from: CGPoint(x: 0, y: 240), to: CGPoint(x: 0, y: 404))
        Art.clipped(&context, to: floor) { g in
            Kit.grass(&g, in: CGRect(x: 0, y: 262, width: 432, height: 90), count: 40, seed: 21, color: valleyGrass().opacity(0.5), height: 8)
        }
        Kit.ribbon(&context, nearX: 222, nearY: 404, nearWidth: 84, farX: 216, farY: 246, farWidth: 5, stops: streamStops())
        Kit.farTrees(&context, x0: 196, x1: 240, baseY: 252, height: 14, count: 3, color: Art.color(0x7DB060), seed: 3)
        poplar(&context, x: 262, baseY: 276, height: 74, seed: 13)
        poplar(&context, x: 172, baseY: 284, height: 86, seed: 11)
        poplar(&context, x: 296, baseY: 294, height: 62, seed: 14)
        Kit.tree(&context, x: 118, baseY: 304, height: 62, spread: 66, palette: Kit.springGreens(), bark: 0x7A6048, seed: 5)
        poplar(&context, x: 146, baseY: 300, height: 70, seed: 12)
        wildFlowers(&context, in: CGRect(x: 120, y: 292, width: 200, height: 20), count: 8, seed: 14)
        Kit.sink(&context, size, card: 0x1E5C4E)
    }

    /// The two bare, folded hills that hold the valley, with grey outcrops.
    static func persiaHills(_ context: inout GraphicsContext) {
        let left = Art.svg("M-10,116 C60,126 130,190 200,246 L200,404 L-10,404Z")
        let right = Art.svg("M442,96 C370,110 300,180 232,246 L232,404 L442,404Z")
        let shaded: Kit.Stops = [(Art.color(0xDDB56E), 0), (Art.color(0xC9954E), 1)]
        let lit: Kit.Stops = [(Art.color(0xEFD08E), 0), (Art.color(0xD9A85C), 1)]
        Kit.solid(&context, left, stops: shaded, light: 0.2, shade: 0.24, rim: 2)
        Kit.solid(&context, right, stops: lit, light: 0.3, shade: 0.16, rim: 2.4)
        let leftFolds = Art.svg("M20,132 C40,170 44,210 40,260 M76,150 C100,190 108,230 104,280 M132,196 C150,222 156,250 152,290")
        let rightFolds = Art.svg("M410,112 C392,150 388,196 394,250 M350,134 C332,172 326,214 330,270 M292,186 C280,214 276,244 280,290")
        Art.stroke(&context, leftFolds, Art.color(0xA87A3E, 0.4), width: ArtStyle.contourLine)
        Art.stroke(&context, rightFolds, Art.color(0xB8894A, 0.4), width: ArtStyle.contourLine)
        Kit.rock(&context, cx: 62, baseY: 232, width: 50, height: 28, color: stoneHex, seed: 2)
        Kit.rock(&context, cx: 376, baseY: 214, width: 46, height: 26, color: stoneHex, seed: 5)
        Kit.cypress(&context, x: 392, baseY: 168, height: 44)
        Kit.cypress(&context, x: 30, baseY: 180, height: 38)
    }

    /// "The hare": a sandy-brown hare sitting in dry grass, in side view, showing the long
    /// black-tipped ears and the long back legs.
    static func harePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = noon()
        let H: CGFloat = 214
        Kit.sky(&context, size, horizon: H, light: light)
        farLand(&context, width: size.width, horizon: H, scale: 1.0, light: light, seed: 9)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: dryGround())
        Kit.grass(&context, in: CGRect(x: 0, y: H + 12, width: 432, height: 90), count: 34, seed: 51, color: Art.color(0xA8843A, 0.7), height: 12)
        Kit.rock(&context, cx: 356, baseY: 258, width: 70, height: 38, color: stoneHex, seed: 4)
        Kit.grassTuft(&context, x: 112, baseY: 300, height: 72, color: dryGrassHex, seed: 2)
        Kit.grassTuft(&context, x: 318, baseY: 304, height: 82, color: dryGrassHex, seed: 3)
        Art.group(&context, x: 226, y: 300, scale: 1.7) { g in
            hare(&g, pose: .sit, mood: .calm, look: CGPoint(x: -0.3, y: 0))
        }
        Kit.grassTuft(&context, x: 150, baseY: 316, height: 44, color: 0xB8923E, seed: 5)
        Kit.grassTuft(&context, x: 286, baseY: 318, height: 50, color: 0xB8923E, seed: 6)
        Kit.grassTuft(&context, x: 214, baseY: 322, height: 26, color: 0xB8923E, seed: 7)
        Kit.sink(&context, size, card: 0x6A4A22)
    }

    /// "A well": the old well with its low ring of rough stones, seen from above so the dark
    /// water shows far down. No animals (so no reflections here: the card is about the well).
    static func wellPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = noon()
        let H: CGFloat = 132
        Kit.sky(&context, size, horizon: H, light: light)
        farLand(&context, width: size.width, horizon: H, scale: 0.9, light: light, seed: 13)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: dryGround())
        Kit.cypress(&context, x: 376, baseY: 150, height: 66)
        Kit.rock(&context, cx: 52, baseY: 176, width: 54, height: 30, color: stoneHex, seed: 3)
        Kit.grass(&context, in: CGRect(x: 0, y: H + 14, width: 432, height: 150), count: 26, seed: 61, color: Art.color(0xA8843A, 0.7), height: 10)
        Kit.pebbles(&context, in: CGRect(x: 0, y: H + 20, width: 432, height: 150), count: 18, seed: 62, color: stoneHex)
        Art.group(&context, x: 216, y: 196, scale: 0.86) { g in
            well(&g, ry: 96, wall: 30, reflect: false)
        }
        Kit.sink(&context, size, card: 0x274B63)
    }
}

// MARK: - Portraits (432 × 400)

extension LionHareArt {
    /// The little Hare sitting up in the grass, ears raised (one bent at the tip), with a
    /// small knowing look.
    static func harePortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let spec = hareLook()
        Kit.portrait(&context, size, top: 0xBFE6E4, bottom: 0x4FA89A, halo: 0xFFF3C8, rays: true) { g in
            Kit.grassTuft(&g, x: 64, baseY: 404, height: 96, color: 0x3F8A5A, seed: 2)
            Kit.grassTuft(&g, x: 370, baseY: 404, height: 108, color: 0x3F8A5A, seed: 3)
            Art.group(&g, x: 216, y: 172, scale: 1.8) { b in
                Kit.beastBust(&b, spec, mood: .sly, look: CGPoint(x: -0.2, y: 0))
                hareBendFront(&b)
            }
            Kit.grassTuft(&g, x: 128, baseY: 412, height: 60, color: 0x4E9A5E, seed: 4)
            Kit.grassTuft(&g, x: 300, baseY: 412, height: 66, color: 0x4E9A5E, seed: 5)
            Kit.grassTuft(&g, x: 214, baseY: 416, height: 40, color: 0x4E9A5E, seed: 6)
            wildFlowers(&g, in: CGRect(x: 30, y: 340, width: 70, height: 30), count: 3, seed: 8)
            wildFlowers(&g, in: CGRect(x: 336, y: 330, width: 70, height: 30), count: 3, seed: 9)
        }
    }

    /// The Lion on his rock, chest out, mouth wide open in a roar, mane flying.
    static func lionPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        let rockStops: Kit.Stops = [(Art.color(0xDDB49C), 0), (Art.color(rockHex), 0.5), (Art.color(0xA87C68), 1)]
        Kit.portrait(&context, size, top: 0xFFD98A, bottom: 0xE08A3C, halo: 0xFFF6D0, rays: true) { g in
            let roarLeft = Art.svg("M96,150 q-16,22 -6,48 M70,134 q-24,36 -8,80 M44,120 q-30,50 -10,110")
            Art.stroke(&g, roarLeft, Art.color(0xFFF8E4, 0.55), width: 4)
            Art.group(&g, x: 216, y: 158, scale: 1.75) { b in
                lionRoarBust(&b)
            }
            let rock = Art.svg("M-10,410 L-10,388 C60,378 150,384 216,381 C300,378 380,386 442,378 L442,410Z")
            Kit.solid(&g, rock, stops: rockStops, light: 0.3, shade: 0.2, rim: 2.4)
            let cracks = Art.svg("M60,384 l8,14 M330,382 l-6,16 M150,386 l4,10")
            Art.stroke(&g, cracks, Art.color(0x8A5E50, 0.5), width: ArtStyle.detailLine)
        }
    }
}

// MARK: - Face chips (100 × 100)

extension LionHareArt {
    static func hareChip(_ context: inout GraphicsContext, _ size: CGSize) {
        let spec = hareLook()
        Kit.faceChip(&context, size, background: 0xD6ECF7) { g in
            Art.group(&g, x: 0, y: 22, scale: 0.8) { f in
                Kit.beastFace(&f, spec, mood: .happy)
                hareBendFront(&f)
            }
        }
    }

    static func lionChip(_ context: inout GraphicsContext, _ size: CGSize) {
        let spec = lionLook()
        Kit.faceChip(&context, size, background: 0xFFE2A8) { g in
            Art.group(&g, x: 0, y: 2, scale: 0.95) { f in
                Kit.beastFace(&f, spec, mood: .happy)
            }
        }
    }

    static func gazelleChip(_ context: inout GraphicsContext, _ size: CGSize) {
        let spec = gazelleLook()
        Kit.faceChip(&context, size, background: 0xD9F2DC) { g in
            Art.group(&g, x: 0, y: 10, scale: 0.95) { f in
                var horns = Path()
                Kit.treeBough(&horns, -9, -22, -15, -60, 5.5, 1.6, bend: -4)
                Kit.treeBough(&horns, 9, -22, 15, -60, 5.5, 1.6, bend: 4)
                Art.fill(&f, horns, Art.color(spec.dark))
                let rings = Art.svg("M-13.5,-30 h5 M-14.5,-38 h4.6 M-15.5,-46 h4 M8.5,-30 h5 M9.9,-38 h4.6 M11.5,-46 h4")
                Art.stroke(&f, rings, Kit.beastTone(spec.dark, 1.9).opacity(0.7), width: 1)
                Kit.beastFace(&f, spec, mood: .calm)
            }
        }
    }

    static func tortoiseChip(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xEFEBC2) { g in
            Art.group(&g, x: 0, y: 2, scale: 1.25) { f in
                tortoiseFace(&f)
            }
        }
    }
}

// MARK: - Cover (300 wide, 150…375 high)

extension LionHareArt {
    /// The Lion and the little Hare at the rim of the old stone well, looking down; the round
    /// water shows a lion and a hare looking back up. Gold hills and pale sky behind.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = noon()
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let full = CGSize(width: 240, height: frame.hd)
            Kit.sky(&g, full, horizon: H, light: light)
            farLand(&g, width: 240, horizon: H, scale: 0.55 * k + 0.2, light: light, seed: 13)
            Kit.ground(&g, width: 240, top: H, bottom: frame.hd, stops: dryGround())
            Kit.mound(&g, x0: -20, x1: 260, baseY: H + 3, height: 16 * k, bottom: H + 3, stops: dryGround(), crest: 0.6)
            Kit.cypress(&g, x: 32, baseY: H + 8 * k, height: 86 * k)
            Kit.cypress(&g, x: 214, baseY: H + 4 * k, height: 50 * k)
            Kit.pebbles(&g, in: CGRect(x: 0, y: H + 10, width: 240, height: max(4, frame.hd - H - 10)), count: 8, seed: 5, color: stoneHex)
            Art.group(&g, x: 122, y: H + 28 * k, scale: 0.5 * k) { e in
                wellEnsemble(&e, ry: 56, wall: 30, lionScale: 1.5, hareScale: 0.9, lionMood: .surprised, hareMood: .happy, hareGaze: CGPoint(x: 0.2, y: 0.5))
            }
            Kit.cornerLeaves(&g, size: full, corner: 1, color: Art.color(0x24573A), scale: 0.5 * k, seed: 3)
            if frame.hd > 200 {
                Kit.grassTuft(&g, x: 18, baseY: frame.hd + 4, height: 30, color: 0xA8843A, seed: 2)
                Kit.grassTuft(&g, x: 224, baseY: frame.hd + 4, height: 34, color: 0xA8843A, seed: 4)
            }
        }
    }
}
