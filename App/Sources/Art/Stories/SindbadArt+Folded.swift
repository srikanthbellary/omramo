import SwiftUI
import OmramoCore

// The four folded compositions of "Sindbad's Second Voyage": each its own picture for the band
// at the top of a phone (432 wide, about 240…520 high), the subject's face in x 86…346.

extension SindbadArt {
    /// Sindbad on the gangplank of the moored dhow, a bale on his shoulder, the ship's sewn
    /// planks and slanting yard behind him and date palms against the pale sky.
    static func harbourFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = day()
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = band.H
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 320, H * 0.24, scale: 0.5 * u, color: Color.white.opacity(0.6))
        basraFar(&context, width: w, horizon: H, scale: u, light: light)
        Kit.water(&context, width: w, top: H, bottom: h, stops: riverStops(), light: light, ripples: 18, seed: 33)
        Kit.palm(&context, x: 40, baseY: H + 4, height: 150 * u, lean: 8, fronds: palmGreen, trunk: 0x8A6A4A, seed: 4)
        Kit.palm(&context, x: 404, baseY: H + 4, height: 170 * u, lean: -10, fronds: 0x357A56, trunk: 0x8A6A4A, seed: 9)
        ArtStyle.atmosphere(&context, width: w, top: H - 120 * u, bottom: H + 6, color: light.haze, alpha: 0.14)
        // The moored dhow, her furled sail slanting up behind Sindbad.
        let waterY: CGFloat = H + 18 * u
        Art.group(&context, x: 250, y: waterY, scale: 1.5 * u) { s in
            dhow(&s, full: false)
        }
        Kit.ripples(&context, 110, waterY + 3, 100 * u, count: 2)
        // The quay in front, and the gangplank rising from it to the gunwale.
        quay(&context, x0: 60, edgeY: H + 34 * u, floorY: h + 10)
        let lowX: CGFloat = 330
        let lowY: CGFloat = H + 44 * u
        let highX: CGFloat = 176
        let highY: CGFloat = H - 14 * u
        let thick: CGFloat = 7 * u
        let plank = Art.polygon([
            CGPoint(x: lowX, y: lowY), CGPoint(x: highX, y: highY), CGPoint(x: highX - 2, y: highY + thick), CGPoint(x: lowX - 4, y: lowY + thick),
        ])
        Kit.solid(&context, plank, Art.color(0xB58A5C), light: 0.24, shade: 0.2)
        Art.stroke(&context, Art.line(lowX, lowY, highX, highY), Art.color(0xE9CFA0), width: 1.6)
        // Sindbad, about halfway up the plank.
        let t: CGFloat = (lowX - 262) / (lowX - highX)
        let feetY: CGFloat = lowY + (highY - lowY) * t
        let k: CGFloat = 0.75 * u
        Kit.shadow(&context, 262, feetY, width: 40 * k, alpha: 0.2)
        Art.group(&context, x: 262, y: feetY, scale: k) { s in
            sindbadWithBale(&s, mouth: .grin, look: CGPoint(x: 0.3, y: 0))
        }
        // The cargo still on the quay and a porter coming with the next bale.
        Art.group(&context, x: 70, y: H + 66 * u, scale: 0.5 * u) { s in
            cargo(&s, x: 0, baseY: 0)
        }
        Kit.shadow(&context, 376, H + 60 * u, width: 30 * u)
        Art.group(&context, x: 376, y: H + 60 * u, scale: 0.58 * u) { s in
            porterWithBale(&s, tunic: 0x9FB6A8)
        }
        Kit.reeds(&context, x: 14, baseY: h - 4, count: 5, height: 50 * u, seed: 9, color: 0x4E8A6A)
        ArtStyle.finish(&context, size)
    }

    /// Sindbad, very small in the middle, his head tipped back and the turban cloth in his
    /// hands, beside the curve of the huge smooth egg that fills the right of the band.
    static func eggFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = day()
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = band.H
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 150, H * 0.2, scale: 0.4 * u, color: Color.white.opacity(0.5))
        let seaTop: CGFloat = H - 7 * u
        Art.fill(&context, Art.rect(0, seaTop, w, H - seaTop + 2), Art.color(0x9ED5D3))
        farDhow(&context, x: 56, waterY: H - 2 * u, scale: 0.3 * u)
        Kit.farTrees(&context, x0: 120, x1: w, baseY: H + 2, height: 26 * u, count: 10, color: Art.color(0xA6CDB4), seed: 6)
        ArtStyle.atmosphere(&context, width: w, top: H - 40 * u, bottom: H + 4, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: islandGround(), seed: 43)
        fruitTree(&context, x: 64, baseY: H + 16 * u, height: 130 * u, seed: 3)
        fruitTree(&context, x: 272, baseY: H + 8 * u, height: 100 * u, seed: 5, hazy: true)
        // The egg and the shadow of the wing over it and the grass.
        let groundShade = wingShadow(root: CGPoint(x: 470, y: H + 30 * u), from: 160, to: 200, length: 300 * u, count: 7, squash: 0.22)
        Art.fill(&context, groundShade, ArtStyle.coolShade.opacity(0.14))
        let eggBase: CGFloat = H + 34 * u
        let eggWidth: CGFloat = 280 * u
        Kit.shadow(&context, 420, eggBase, width: eggWidth * 1.1, alpha: 0.3)
        let eggShade = wingShadow(root: CGPoint(x: 470, y: eggBase - 330 * u), from: 120, to: 180, length: 260 * u, count: 7, squash: 1)
        egg(&context, cx: 420, baseY: eggBase, width: eggWidth, height: 420 * u, shade: eggShade)
        Kit.bush(&context, x: 330, baseY: H + 46 * u, width: 60 * u, palette: islandGreens(), seed: 15)
        // Sindbad, turned toward the egg, staring up at it.
        let k: CGFloat = 0.55 * u
        let feetY: CGFloat = H + 40 * u
        Kit.shadow(&context, 196, feetY, width: 44 * k)
        Art.group(&context, x: 196, y: feetY, scale: k, scaleX: -1) { s in
            sindbadWithCloth(&s, mouth: .oh)
        }
        let grassTop: CGFloat = H + 50 * u
        let meadow = CGRect(x: 0, y: grassTop, width: w, height: max(8, band.floor - grassTop))
        Kit.grass(&context, in: meadow, count: 26, seed: 12, color: Art.color(0x5E9A5E), height: 12 * u)
        Kit.flowers(&context, in: meadow, count: 8, seed: 13, petal: 0xFFF3D6)
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x1F5A48), scale: 0.7 * u, seed: 5)
        ArtStyle.finish(&context, size)
    }

    /// The narrow valley for the band: the calm pale walls on both sides, the palest far wall
    /// between them under a strip of sky, and the glittering floor.
    static func valleyBandWalls(_ context: inout GraphicsContext, w: CGFloat, H: CGFloat, u: CGFloat, light: Kit.Light) {
        let backTop: CGFloat = H * 0.34
        let back = Kit.ridge(width: 270, y: backTop, amp: 10 * u, seed: 27, bottom: H + 4, step: 8, x0: 86)
        Art.fill(&context, back, Art.color(0xF0DEC0))
        strata(&context, back, box: CGRect(x: 86, y: backTop - 14, width: 270, height: H - backTop + 18), seed: 37)
        ArtStyle.atmosphere(&context, width: w, top: backTop - 20, bottom: H + 4, color: light.haze, alpha: 0.3)
        let leftPoints: [CGPoint] = [
            CGPoint(x: -10, y: H * 0.05), CGPoint(x: 90, y: H * 0.1), CGPoint(x: 112, y: H * 0.42), CGPoint(x: 140, y: H + 6),
            CGPoint(x: -10, y: H + 6),
        ]
        let left = Art.polygon(leftPoints)
        Art.fillLinear(&context, left, cliffStops(), from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        strata(&context, left, box: CGRect(x: 0, y: H * 0.05, width: 140, height: H * 0.95), seed: 39)
        let shadePoints: [CGPoint] = [
            CGPoint(x: 90, y: H * 0.1), CGPoint(x: 112, y: H * 0.42), CGPoint(x: 140, y: H + 6), CGPoint(x: 116, y: H + 6),
            CGPoint(x: 94, y: H * 0.42), CGPoint(x: 78, y: H * 0.11),
        ]
        Art.fill(&context, Art.polygon(shadePoints), ArtStyle.coolShade.opacity(0.08))
        let rightPoints: [CGPoint] = [
            CGPoint(x: 336, y: -10), CGPoint(x: 316, y: H * 0.3), CGPoint(x: 294, y: H + 6), CGPoint(x: w + 10, y: H + 6),
            CGPoint(x: w + 10, y: -10),
        ]
        let right = Art.polygon(rightPoints)
        let rightTone: Kit.Stops = [(Art.color(0xF1D8B2), 0), (Art.color(0xE2C092), 1)]
        Art.fillLinear(&context, right, rightTone, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        strata(&context, right, box: CGRect(x: 294, y: 0, width: w - 294, height: H), seed: 41)
        ArtStyle.rimEdge(&context, right, bounds: CGRect(x: 294, y: -10, width: w - 284, height: H + 16), width: 3, alpha: 0.45)
    }

    /// Sindbad kneeling in the middle of the glittering floor with a rough diamond as big as
    /// his fist held up to the light, the pale cliffs behind.
    static func valleyFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = day()
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = band.H
        Kit.sky(&context, size, horizon: H, light: light)
        valleyBandWalls(&context, w: w, H: H, u: u, light: light)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: floorStops(), seed: 65)
        let floorRect = CGRect(x: 0, y: H + 6, width: w, height: max(10, band.floor - H))
        stones(&context, in: floorRect, count: 70, seed: 81, size: 3.6 * u)
        Art.glow(&context, 216, H + 10 * u, 160 * u, Art.color(0xFFF3CF), alpha: 0.45)
        let k: CGFloat = 0.8 * u
        let baseY: CGFloat = H + 40 * u
        Kit.shadow(&context, 222, baseY, width: 90 * k)
        Art.group(&context, x: 216, y: baseY, scale: k) { s in
            sindbadWithGem(&s, mouth: .grin)
        }
        // The stones glinting round his knees.
        let knees = CGRect(x: 140, y: baseY - 6 * u, width: 160, height: 22 * u)
        stones(&context, in: knees, count: 18, seed: 83, size: 4 * u)
        crystal(&context, x: 150, y: baseY + 4 * u, r: 5 * u)
        crystal(&context, x: 300, y: baseY + 12 * u, r: 6 * u)
        Kit.rock(&context, cx: w + 4, baseY: h + 6, width: 130 * u, height: 56 * u, color: 0xAD8459, seed: 6)
        Kit.rock(&context, cx: -6, baseY: h + 8, width: 100 * u, height: 40 * u, color: 0xC49A6C, seed: 14)
        ArtStyle.finish(&context, size)
    }

    /// Sindbad sitting up in the nest in the middle, holding out both hands full of diamonds
    /// to the astonished merchant with his stick at the side; the eagle flaps away.
    static func nestFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = morning()
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = band.H
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 300, H * 0.2, scale: 0.5 * u, color: Color.white.opacity(0.6))
        Kit.ranges(&context, width: w, horizon: H, scale: u, light: light, mountains: false, seed: 9)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: plateauStops(), seed: 59)
        let grit = CGRect(x: 0, y: H + 8, width: w, height: max(10, band.floor - H - 8))
        Kit.pebbles(&context, in: grit, count: 24, seed: 4, color: 0xB49A78)
        // The eagle, flapping off over the trailing side.
        Art.group(&context, x: 334, y: H * 0.5, scale: 0.7 * u) { e in
            eagle(&e)
        }
        // The ledge, the nest and Sindbad in it.
        let cx: CGFloat = 262
        let k: CGFloat = 0.6 * u
        let seatY: CGFloat = H + 20 * u
        let nestWidth: CGFloat = 150 + 70 * u
        Kit.rock(&context, cx: cx - 8, baseY: seatY + 32 * u, width: nestWidth * 1.2, height: 24 * u, color: 0xC2A274, seed: 8)
        nest(&context, cx: cx - 8, baseY: seatY + 19 * u, width: nestWidth, seed: 5)
        Art.group(&context, x: cx, y: seatY, scale: k) { s in
            sindbadWithMeat(&s, mouth: .grin, look: CGPoint(x: -0.8, y: 0))
        }
        nestLip(&context, cx: cx - 8, y: seatY - 4 * u, width: nestWidth * 0.92)
        // The merchant, astonished, his stick in his hand.
        let mk: CGFloat = 0.62 * u
        let feetY: CGFloat = H + 50 * u
        Kit.shadow(&context, 100, feetY, width: 46 * mk)
        Art.group(&context, x: 100, y: feetY, scale: mk, scaleX: -1) { s in
            stickMan(&s, merchantLook(), running: false, mouth: .oh, look: .zero, mirrored: true)
        }
        Kit.rock(&context, cx: w + 4, baseY: h + 6, width: 120 * u, height: 50 * u, color: 0x9A7A56, seed: 12)
        ArtStyle.finish(&context, size)
    }
}
