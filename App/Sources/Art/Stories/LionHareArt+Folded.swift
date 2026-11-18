import SwiftUI
import OmramoCore

// The four folded-phone compositions of "The Lion and the Hare": each is its own picture for
// the band at the top of one pane (432 wide, 240…520 high), not a crop of the wide scene.

extension LionHareArt {
    /// The far plane of a folded band: sky, the gold hills and the ground.
    static func foldedFar(_ context: inout GraphicsContext, _ band: Kit.Band, light: Kit.Light, ground: Kit.Stops, seed: UInt32) {
        let u: CGFloat = band.unit
        Kit.sky(&context, band.size, horizon: band.H, light: light)
        farLand(&context, width: band.w, horizon: band.H, scale: u * 0.8, light: light, seed: seed)
        Kit.ground(&context, width: band.w, top: band.H, bottom: band.h, stops: ground)
    }

    // MARK: scene-valley

    /// The Lion roaring on his rock in the middle of the band, the green valley and its
    /// stream falling away below him on the left.
    static func valleyFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = day()
        foldedFar(&context, band, light: light, ground: greenGround(), seed: 4)
        Kit.sun(&context, 70, H - 58 * u, 15 * u, light: light)
        Kit.farTrees(&context, x0: 6, x1: 160, baseY: H + 3, height: 14 * u, count: 5, color: Art.color(0x8DB86A), seed: 6)
        Kit.grass(&context, in: CGRect(x: 0, y: H + 10, width: 432, height: band.ground - 10), count: 30, seed: 21, color: valleyGrass().opacity(0.5), height: 8)
        Kit.ribbon(&context, nearX: 92, nearY: size.height, nearWidth: 92 * u, farX: 62, farY: H + 4, farWidth: 5, stops: streamStops())
        poplar(&context, x: 30, baseY: H + 12 * u, height: 62 * u, seed: 11)
        poplar(&context, x: 122, baseY: H + 8 * u, height: 48 * u, seed: 12)
        valleyFoldedRock(&context, band)
        wildFlowers(&context, in: CGRect(x: 10, y: H + 24 * u, width: 130, height: max(10, band.ground - 60 * u)), count: 5, seed: 14)
        Kit.grassTuft(&context, x: 20, baseY: size.height - 16, height: 40 * u, color: 0x2F6E40, seed: 3)
        Kit.grassTuft(&context, x: 150, baseY: size.height - 12, height: 30 * u, color: 0x2F6E40, seed: 4)
        ArtStyle.finish(&context, size)
    }

    /// The rock ledge coming in from the trailing edge, the den's dark mouth, and the Lion.
    static func valleyFoldedRock(_ context: inout GraphicsContext, _ band: Kit.Band) {
        let u: CGFloat = band.unit
        let top: CGFloat = band.H - 8 * u
        let low: CGFloat = band.h + 4
        var rock = Path()
        rock.move(to: CGPoint(x: 146, y: low))
        rock.addCurve(to: CGPoint(x: 172, y: top + 6), control1: CGPoint(x: 152, y: top + 50 * u), control2: CGPoint(x: 158, y: top + 16))
        rock.addQuadCurve(to: CGPoint(x: 230, y: top), control: CGPoint(x: 188, y: top - 4))
        rock.addLine(to: CGPoint(x: 340, y: top - 4))
        rock.addQuadCurve(to: CGPoint(x: 440, y: top - 10), control: CGPoint(x: 390, y: top))
        rock.addLine(to: CGPoint(x: 440, y: low))
        rock.closeSubpath()
        let rockStops: Kit.Stops = [(Art.color(0xDDB49C), 0), (Art.color(rockHex), 0.5), (Art.color(0xA87C68), 1)]
        Kit.solid(&context, rock, stops: rockStops, light: 0.3, shade: 0.26, rim: 2.4)
        var strata = Path()
        strata.move(to: CGPoint(x: 160, y: top + 26 * u))
        strata.addQuadCurve(to: CGPoint(x: 440, y: top + 18 * u), control: CGPoint(x: 300, y: top + 32 * u))
        strata.move(to: CGPoint(x: 152, y: top + 58 * u))
        strata.addQuadCurve(to: CGPoint(x: 300, y: top + 54 * u), control: CGPoint(x: 220, y: top + 62 * u))
        var den = Path()
        let denTop: CGFloat = top + 34 * u
        den.move(to: CGPoint(x: 318, y: low))
        den.addCurve(to: CGPoint(x: 362, y: denTop), control1: CGPoint(x: 316, y: denTop + 30 * u), control2: CGPoint(x: 334, y: denTop))
        den.addCurve(to: CGPoint(x: 410, y: low), control1: CGPoint(x: 392, y: denTop), control2: CGPoint(x: 412, y: denTop + 30 * u))
        den.closeSubpath()
        let dark: Kit.Stops = [(Art.color(0x6A4438), 0), (Art.color(0x3A2638), 1)]
        Art.clipped(&context, to: rock) { g in
            Art.stroke(&g, strata, Art.color(0x8A5E50, 0.5), width: ArtStyle.detailLine)
            Art.fillLinear(&g, den, dark, from: CGPoint(x: 0, y: denTop), to: CGPoint(x: 0, y: low))
        }
        Art.group(&context, x: 262, y: top - 1, scale: 0.95 * u) { g in
            lion(&g, pose: .stand, roar: true)
        }
    }

    // MARK: scene-council

    /// The Hare sitting up in the long grass, thinking, with the plane tree's pale trunk
    /// behind him, the Gazelle and the Tortoise close by.
    static func councilFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let floor: CGFloat = band.floor
        let light = evening()
        foldedFar(&context, band, light: light, ground: eveningGround(), seed: 23)
        Kit.sun(&context, 56, H - 44 * u, 16 * u, light: light)
        Kit.grass(&context, in: CGRect(x: 0, y: H + 10, width: 432, height: band.ground - 10), count: 34, seed: 27, color: Art.color(0x4E7F3A, 0.5), height: 9)
        ArtStyle.contactShadow(&context, 330, H + 30 * u, 150 * u, 16 * u, alpha: 0.16)
        Kit.greatTree(&context, x: 344, baseY: H + 24 * u, height: 300 * u, spread: 380 * u, palette: planeGreens(), bark: 0xB9AE98, seed: 7)
        Art.group(&context, x: 92, y: H + 34 * u, scale: 0.5 * u, scaleX: -1) { g in
            gazelle(&g, pose: .stand, mood: .calm, mirrored: true)
        }
        Art.group(&context, x: 322, y: floor - 2, scale: 0.62 * u) { g in
            tortoise(&g)
        }
        Kit.grassTuft(&context, x: 236, baseY: floor - 10, height: 40 * u, color: 0x3F7F45, seed: 21)
        Art.group(&context, x: 214, y: floor - 4, scale: 0.9 * u) { g in
            hare(&g, pose: .rear, mood: .calm, look: CGPoint(x: -0.3, y: -0.6))
        }
        Kit.grassTuft(&context, x: 178, baseY: floor + 6, height: 30 * u, color: 0x4E8A45, seed: 22)
        Kit.grassTuft(&context, x: 252, baseY: floor + 8, height: 34 * u, color: 0x4E8A45, seed: 23)
        wildFlowers(&context, in: CGRect(x: 20, y: H + 30 * u, width: 120, height: max(10, band.ground - 70 * u)), count: 5, seed: 33)
        Kit.grassTuft(&context, x: 16, baseY: size.height - 14, height: 40 * u, color: 0x2F6238, seed: 5)
        ArtStyle.finish(&context, size)
    }

    // MARK: scene-hills

    /// The Hare mid-hop on the dusty path, the Lion's big face just behind him, one cypress.
    static func hillsFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let floor: CGFloat = band.floor
        let light = noon()
        foldedFar(&context, band, light: light, ground: dryGround(), seed: 9)
        Kit.ribbon(&context, nearX: 236, nearY: size.height, nearWidth: 290 * u, farX: 120, farY: H + 4, farWidth: 8, stops: pathStops())
        Kit.pebbles(&context, in: CGRect(x: 0, y: H + 14, width: 432, height: band.ground - 14), count: 14, seed: 52, color: stoneHex)
        Kit.cypress(&context, x: 40, baseY: H + 16 * u, height: 160 * u)
        Kit.cypress(&context, x: 96, baseY: H + 8 * u, height: 84 * u)
        Kit.rock(&context, cx: 404, baseY: H + 18 * u, width: 70 * u, height: 40 * u, color: stoneHex, seed: 7)
        dustPuff(&context, 372, floor - 6, scale: 0.36 * u)
        dustPuff(&context, 300, floor - 4, scale: 0.3 * u)
        Art.group(&context, x: 338, y: floor - 8, scale: u) { g in
            lion(&g, pose: .walk, mood: .surprised, look: CGPoint(x: -0.6, y: 0.1))
        }
        dustPuff(&context, 244, floor - 2, scale: 0.22 * u)
        Art.group(&context, x: 196, y: floor - 4, scale: 0.8 * u) { g in
            hare(&g, pose: .run, mood: .happy, look: CGPoint(x: 0.9, y: 0))
        }
        Kit.grassTuft(&context, x: 18, baseY: size.height - 14, height: 34 * u, color: 0xA8843A, seed: 8)
        ArtStyle.finish(&context, size, wash: 0.12, vignette: 0.08)
    }

    // MARK: scene-well

    /// The Lion's face and the Hare's side by side over the ring of stones; the two
    /// reflections small in the dark water at the bottom of the band.
    static func wellFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let light = noon()
        foldedFar(&context, band, light: light, ground: dryGround(), seed: 13)
        Kit.mound(&context, x0: -20, x1: 452, baseY: H + 4, height: 24 * u, bottom: H + 4, stops: dryGround(), crest: 0.6)
        Kit.cypress(&context, x: 40, baseY: H + 12 * u, height: 150 * u)
        Kit.rock(&context, cx: 398, baseY: H + 16 * u, width: 60 * u, height: 34 * u, color: stoneHex, seed: 6)
        Kit.pebbles(&context, in: CGRect(x: 0, y: H + 14, width: 432, height: band.ground - 14), count: 12, seed: 62, color: stoneHex)
        let cy: CGFloat = band.floor - 42 * u
        Art.group(&context, x: 222, y: cy, scale: u) { g in
            wellEnsemble(&g, ry: 40, wall: 26, lionScale: 1.25, hareScale: 0.7, lionMood: .surprised, hareMood: .sly)
        }
        Kit.grassTuft(&context, x: 18, baseY: size.height - 14, height: 34 * u, color: 0xA8843A, seed: 10)
        ArtStyle.finish(&context, size, wash: 0.12, vignette: 0.08)
    }
}
