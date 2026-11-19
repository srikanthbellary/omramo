import SwiftUI
import OmramoCore

// The four scenes of "The Bremen Town Musicians" as the picture band at the top of a phone:
// 432 units wide and about 240…520 high. Each is its own composition, not a crop: the faces
// sit inside x 86…346, below the two top controls and above the wave edge; the subject scales
// with `band.unit`.

extension BremenArt {
    // MARK: scene-road

    /// scene-road (folded): the Donkey's head and shoulders in the middle of the band, ears
    /// up, walking right along the road; the blank signpost behind him, the Dog's head at
    /// his side, flat fields with the mill and the far town under a pale sky.
    static func roadFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band: Kit.Band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light: Kit.Light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 168, H - 30 * u, 13 * u, light: light)
        Kit.cloud(&context, 300, H * 0.42, scale: 0.5 * u, color: Art.color(0xFFFFFF, 0.7))

        // Far: the tree line, the mill, Bremen where the road ends.
        Kit.farTrees(&context, x0: 0, x1: 432, baseY: H + 1, height: 11 * u, count: 22, color: light.far, seed: 5)
        Kit.windmill(&context, cx: 52, baseY: H + 1, height: 46 * u, body: 0x9AA8B0, sails: 0xF4F4EC)
        farTown(&context, x: 330, baseY: H + 1, scale: 0.8 * u, color: Art.color(0x9DB8CC))
        ArtStyle.atmosphere(&context, width: 432, top: H - 60 * u, bottom: H + 3, color: light.haze, alpha: 0.3)

        Kit.ground(&context, width: 432, top: H, bottom: size.height, stops: meadowStops())
        Art.fill(&context, Art.rect(0, H + 3 * u, 432, 6 * u), Art.color(0xE9D27C, 0.85))
        Kit.ribbon(&context, nearX: 216, nearY: size.height + 12, nearWidth: 330, farX: 330, farY: H + 2, farWidth: 5, stops: roadStops())

        // Middle: poplars by the road and the finger post.
        poplar(&context, x: 372, baseY: H + 8 * u, height: 66 * u, seed: 14)
        poplar(&context, x: 404, baseY: H + 18 * u, height: 118 * u, seed: 10)
        Kit.signpost(&context, cx: 92, baseY: H + 24 * u, height: 118 * u, color: 0x8A6A4A, boards: 2)
        let grassBand = CGRect(x: 0, y: H + 10 * u, width: 432, height: max(1, band.ground - 10 * u))
        Kit.grass(&context, in: grassBand, count: 26, seed: 21, color: Art.color(0x4F8A4A, 0.55), height: 8 * u)

        // The Donkey, cut at the legs by the wave edge.
        let feet: CGFloat = band.floor + 50 * u
        Art.group(&context, x: 190, y: feet, scale: 1.2 * u, scaleX: -1) { g in
            donkey(&g, pose: .walk, mood: .happy, look: CGPoint(x: -0.5, y: -0.1), mirrored: true)
        }
        // The Dog's head at his side.
        Art.group(&context, x: 100, y: band.floor + 60 * u, scale: u, scaleX: -1) { g in
            dog(&g, pose: .walk, mood: .happy, look: CGPoint(x: -0.4, y: -0.5), mirrored: true, puffing: true)
        }
        Kit.grassTuft(&context, x: 414, baseY: size.height - 18, height: 44 * u, color: 0x4F8A4A, seed: 4)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-forest

    /// scene-forest (folded): the foot of the oak. The Donkey's and the Dog's faces in the
    /// middle, resting side by side; the Cat on a bough above them, her tail hanging; the
    /// small yellow light among the trunks behind; pale dusk sky at the top.
    static func forestFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band: Kit.Band = Kit.band(size, share: 0.32, least: 76, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light: Kit.Light = dusk()
        let greens: Kit.Greens = duskGreens()
        let barkHex: UInt32 = 0x7E6E5E
        Kit.sky(&context, size, horizon: H, light: light)
        forestEdge(&context, x0: -10, x1: 442, baseY: H + 4, height: H * 0.45, seed: 31)
        Art.glow(&context, 64, H - 14 * u, 26 * u, Art.color(0xFFD25A), alpha: 0.5)
        Kit.lamp(&context, cx: 64, cy: H - 14 * u, radius: 3 * u, color: 0xFFD25A)
        Kit.ground(&context, width: 432, top: H, bottom: size.height, stops: forestFloorStops())
        let leafBed = CGRect(x: 0, y: H + 12 * u, width: 432, height: max(1, band.ground - 12 * u))
        Kit.pebbles(&context, in: leafBed, count: 16, seed: 19, color: 0xB07A42)

        // The oak: its trunk on the trailing side, a bough across, leaves along the top.
        let boughY: CGFloat = H - 150 * u
        Kit.shadow(&context, 388, H + 36 * u, width: 150 * u, alpha: 0.24)
        let trunk = Kit.treeTrunk(388, H + 34 * u, 394, -20, 40 * u, 30 * u)
        Kit.treeBark(&context, trunk.shape, trunk.edge, barkHex)
        var bough = Path()
        Kit.treeBough(&bough, 384, boughY + 5 * u, 150, boughY - 5 * u, 24 * u, 8 * u, bend: -6 * u)
        Kit.solid(&context, bough, Kit.treeTone(barkHex, 0.86), light: 0.2, shade: 0.24)
        let crown: [Kit.Blob] = [
            (404, boughY - 62 * u, 60 * u), (326, boughY - 74 * u, 46 * u), (440, boughY - 6 * u, 40 * u),
            (150, boughY - 10 * u, 22 * u), (176, boughY - 24 * u, 16 * u),
        ]
        Kit.canopy(&context, crown, seed: 33, palette: greens, density: 1.8)

        // The Cat lying along the bough, her tail hanging.
        let catX: CGFloat = 244
        let catY: CGFloat = boughY - 8 * u
        let catK: CGFloat = 0.75 * u
        var tail = Path()
        tail.move(to: CGPoint(x: catX + 30 * catK, y: catY - 6 * catK))
        tail.addCurve(
            to: CGPoint(x: catX + 44 * catK, y: catY + 52 * catK),
            control1: CGPoint(x: catX + 52 * catK, y: catY + 2 * catK),
            control2: CGPoint(x: catX + 34 * catK, y: catY + 34 * catK)
        )
        Art.stroke(&context, tail, Art.color(catLook().body), width: 6 * catK)
        Art.group(&context, x: catX, y: catY, scale: catK) { g in
            cat(&g, pose: .sleep)
        }

        // The Donkey and the Dog, resting side by side.
        Kit.shadow(&context, 270, H + 38 * u, width: 230 * u)
        Art.group(&context, x: 274, y: H + 36 * u, scale: 1.25 * u) { g in
            donkey(&g, pose: .sleep)
        }
        Kit.shadow(&context, 314, H + 68 * u, width: 160 * u)
        Art.group(&context, x: 316, y: H + 66 * u, scale: u) { g in
            dog(&g, pose: .sleep)
        }
        Kit.grassTuft(&context, x: 22, baseY: size.height - 20, height: 46 * u, color: 0x355A48, seed: 6)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-window

    /// scene-window (folded): the tower of four upright in the middle of the band, faces lit
    /// gold from the glowing window at the right; pale dusk sky above the forest.
    static func windowFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band: Kit.Band = Kit.band(size, share: 0.26, least: 62, most: 130)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light: Kit.Light = dusk()
        let glowColor: Color = Art.color(0xFFCB6B)
        Kit.sky(&context, size, horizon: H, light: light)
        forestEdge(&context, x0: -10, x1: 442, baseY: H + 4, height: H * 0.5, seed: 17)
        Kit.ground(&context, width: 432, top: H, bottom: size.height, stops: forestFloorStops())
        let leafBed = CGRect(x: 0, y: H + 10 * u, width: 300, height: max(1, band.ground - 10 * u))
        Kit.pebbles(&context, in: leafBed, count: 12, seed: 23, color: 0xB07A42)

        // The whole stack stays between y 50 and the wave edge at every height.
        let feet: CGFloat = band.floor - 6
        let fitted: CGFloat = (feet - 50) / 278
        let s: CGFloat = max(0.3, min(u, fitted))
        let towerX: CGFloat = 180
        // The house, in the tower's own units: its window just in front of the Donkey's nose.
        Art.group(&context, x: towerX, y: feet, scale: s) { g in
            timberHouse(&g, cx: 247, baseY: -18, lit: true)
            Art.glow(&g, 124, -128, 150, glowColor, alpha: 0.22)
        }
        Art.group(&context, x: towerX, y: feet, scale: s, scaleX: -1) { g in
            tower(&g, mirrored: true, singing: true)
        }
        Art.glow(&context, towerX + 86 * s, feet - 132 * s, 64 * s, glowColor, alpha: 0.16)
        Art.glow(&context, towerX + 40 * s, feet - 226 * s, 54 * s, glowColor, alpha: 0.1)
        Kit.grassTuft(&context, x: 24, baseY: size.height - 20, height: 50 * u, color: 0x2F4F40, seed: 2)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-home

    /// scene-home (folded): the Donkey's contented face in the middle, lying on straw, the
    /// Cat curled against him and the Dog beside; the house wall behind and the Rooster on
    /// the roof ridge, under a pale morning sky.
    static func homeFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band: Kit.Band = Kit.band(size, share: 0.3, least: 72, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light: Kit.Light = morning()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 150, H - 34 * u, 14 * u, light: light)
        Kit.cloud(&context, 190, H * 0.36, scale: 0.5 * u, color: Art.color(0xFFFFFF, 0.65))
        Kit.farTrees(&context, x0: 0, x1: 432, baseY: H + 2, height: 24 * u, count: 16, color: Art.color(0xA9CDA4), seed: 4)
        ArtStyle.atmosphere(&context, width: 432, top: H - 60 * u, bottom: H + 3, color: light.haze, alpha: 0.3)
        let yard: Kit.Stops = [(Art.color(0xC6DF8E), 0), (Art.color(0x9CC66A), 0.45), (Art.color(0x6FA052), 1)]
        Kit.ground(&context, width: 432, top: H, bottom: size.height, stops: yard)

        // The house behind, with the Rooster crowing on its ridge.
        let hs: CGFloat = 0.55 * u
        let houseX: CGFloat = 326
        let houseBase: CGFloat = H + 12 * u
        Art.group(&context, x: houseX, y: houseBase, scale: hs) { g in
            timberHouse(&g, cx: 0, baseY: 0, lit: false, smoke: true)
        }
        let ridgeY: CGFloat = houseBase - (houseWall + houseRoof + 2) * hs
        Art.group(&context, x: houseX - 40 * hs, y: ridgeY, scale: 0.62 * u) { g in
            rooster(&g, crowing: true, look: CGPoint(x: -0.3, y: -0.3))
        }

        // The Dog sitting behind his friend, by the house wall.
        Kit.shadow(&context, 368, H + 72 * u, width: 100 * u)
        Art.group(&context, x: 366, y: H + 72 * u, scale: 0.95 * u) { g in
            dog(&g, pose: .sit, mood: .happy, look: CGPoint(x: -0.6, y: 0.3))
        }
        // The Donkey on his straw.
        strawHeap(&context, cx: 250, baseY: H + 60 * u, width: 300 * u, height: 46 * u)
        Art.group(&context, x: 280, y: H + 46 * u, scale: 1.25 * u) { g in
            donkey(&g, pose: .sleep)
        }
        // The Cat curled against his flank.
        Art.group(&context, x: 300, y: H + 68 * u, scale: 0.8 * u) { g in
            cat(&g, pose: .sleep)
        }
        Kit.grassTuft(&context, x: 416, baseY: size.height - 18, height: 40 * u, color: 0x4F8A4A, seed: 9)
        ArtStyle.finish(&context, size)
    }
}
