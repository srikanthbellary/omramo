import SwiftUI
import OmramoCore

// The Griot's Apprentice: the four folded compositions (432 wide, 240…520 high) for the
// picture band at the top of a phone. Each is its own close composition, not a crop.

extension GriotArt {
    // MARK: Folded 1: under the baobab

    static func compoundFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = morning()
        let H: CGFloat = band.H
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 250, 46 * u, scale: 0.6 * u, color: Color.white.opacity(0.45))
        Kit.farTrees(&context, x0: 0, x1: 432, baseY: H - 18 * u, height: 12 * u, count: 14, color: light.far, seed: 5)
        Kit.palm(&context, x: 120, baseY: H - 17 * u, height: 34 * u, lean: 3, fronds: 0xB4B096, trunk: 0xB8A68E, seed: 3)
        ArtStyle.atmosphere(&context, width: 432, top: H - 60 * u, bottom: H - 14 * u, color: light.haze, alpha: 0.4)
        let yard: Kit.Stops = Kit.stops(0xE8D0A6, 0xD2AA76)
        Kit.ground(&context, width: 432, top: H - 18 * u, bottom: size.height, stops: yard, seed: 8)
        mudWall(&context, x0: -20, x1: 452, baseY: H + 2, height: 22 * u)
        granary(&context, cx: 52, baseY: H + 6 * u, width: 36 * u, height: 58 * u)
        baobab(&context, x: 336, baseY: H + 8 * u, scale: 0.5 * u)
        bancoHouse(&context, cx: 418, baseY: H + 14 * u, width: 90 * u, height: 62 * u)
        let feet: CGFloat = H + 30 * u
        let s: CGFloat = 1.25 * u
        mat(&context, cx: 292, baseY: feet - 4 * u, width: 80 * u)
        Art.group(&context, x: 292, y: feet - 8 * u, scale: 1.02 * u) { g in
            madi(&g, mouth: .flat, look: CGPoint(x: -0.7, y: 0))
        }
        Kit.pot(&context, cx: 344, baseY: feet - 2 * u, width: 20 * u, height: 24 * u, color: 0xB0683A, band: 0x7A3A22)
        Art.group(&context, x: 186, y: feet, scale: s) { g in
            sira(&g, pose: .stand, mouth: .open, look: CGPoint(x: -0.3, y: -0.5))
        }
        Kit.grassTuft(&context, x: 120, baseY: feet + 4 * u, height: 12 * u, color: 0x8A8A44, seed: 4)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x6A5A2E), scale: 0.55 * u, seed: 2)
        ArtStyle.finish(&context, size)
    }

    // MARK: Folded 2: in the bow of the salt boat

    static func riverFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = afternoon()
        let H: CGFloat = band.H - 40 * u
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 70, H - 30 * u, 13 * u, light: light)
        Kit.farTrees(&context, x0: 0, x1: 432, baseY: H + 1, height: 9 * u, count: 16, color: light.far, seed: 9)
        ArtStyle.atmosphere(&context, width: 432, top: H - 40 * u, bottom: H + 4, color: light.haze, alpha: 0.36)
        let flood: Kit.Stops = Kit.stops(0xD6CEB8, 0x9EA18C)
        Kit.water(&context, width: 432, top: H, bottom: size.height, stops: flood, light: light, ripples: 30, seed: 12)
        Kit.glints(&context, x: 70, top: H, depth: 90 * u, color: Color.white, count: 22, seed: 3)
        islandTown(&context, x0: 230, x1: 446, baseY: H + 10 * u, height: 30 * u, light: light)
        let waterY: CGFloat = band.H + 52 * u
        let L: CGFloat = 400 * u
        let cx: CGFloat = 300 - L / 2
        let deck: CGFloat = waterY - L * 0.05
        let sternX: CGFloat = max(40, cx - L * 0.36)
        Art.group(&context, x: sternX, y: deck, scale: 0.7 * u) { g in
            boatman(&g, boatmanLook(0x2F3F86), poleDown: 80)
        }
        pirogue(&context, cx: cx, waterY: waterY, length: L, salt: true)
        balafon(&context, x: cx + L * 0.27, baseY: deck, scale: 0.4 * u, wrapped: true)
        Art.group(&context, x: cx + L * 0.33, y: deck, scale: 1.25 * u) { g in
            Art.group(&g, scaleX: -1) { m in
                crossLegged(&m, lamineLook(), look: CGPoint(x: 0.4, y: 0), mouth: .smile, mirrored: true)
            }
        }
        Art.group(&context, x: cx + L * 0.43, y: deck + 1, scale: 1.4 * u) { g in
            Art.group(&g, scaleX: -1) { m in
                crossLegged(&m, siraLook(), look: CGPoint(x: 0.7, y: -0.5), mouth: .flat, mirrored: true)
            }
        }
        Kit.ripples(&context, cx + L * 0.5, waterY + 6, 40 * u, count: 2, color: Color.white, opacity: 0.45)
        ArtStyle.finish(&context, size)
    }

    // MARK: Folded 3: singing before Bakary

    static func feastFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = evening()
        let H: CGFloat = band.H
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.farHouse(&context, cx: 90, baseY: H - 44 * u, width: 80 * u, height: 26 * u, wall: light.far, roof: light.mid, flat: true)
        Kit.farHouse(&context, cx: 240, baseY: H - 44 * u, width: 100 * u, height: 32 * u, wall: light.far, roof: light.mid, flat: true)
        ArtStyle.atmosphere(&context, width: 432, top: H - 90 * u, bottom: H - 40 * u, color: light.haze, alpha: 0.42)
        let floor: Kit.Stops = Kit.stops(0xE2BE88, 0xC6985E)
        Kit.ground(&context, width: 432, top: H - 10 * u, bottom: size.height, stops: floor, seed: 17)
        mudWall(&context, x0: -20, x1: 452, baseY: H - 6 * u, height: 40 * u, color: bancoLit)
        lampNiche(&context, cx: 60, cy: H - 26 * u, scale: u)
        lampNiche(&context, cx: 196, cy: H - 26 * u, scale: u)
        lampNiche(&context, cx: 380, cy: H - 26 * u, scale: u)
        let feet: CGFloat = H + 30 * u
        Art.group(&context, x: 300, y: feet - 6 * u, scale: 0.8 * u) { g in
            bakary(&g, mouth: .flat, look: CGPoint(x: -0.7, y: 0.1))
        }
        Art.group(&context, x: 60, y: feet + 6 * u, scale: 0.9 * u) { g in
            guest(&g, guestLook(1), mirrored: true, bowl: true)
        }
        Art.group(&context, x: 176, y: feet, scale: 1.25 * u) { g in
            sira(&g, pose: .stand, mouth: .open, look: CGPoint(x: -0.4, y: -0.5))
        }
        cowries(&context, x: 150, y: feet + 4 * u)
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x5A3A1E), scale: 0.5 * u, seed: 5)
        ArtStyle.finish(&context, size)
    }

    // MARK: Folded 4: side by side at dawn

    static func dawnFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let light = dawn()
        let H: CGFloat = band.H - 34 * u
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 96, H - 8 * u, 16 * u, light: light)
        Kit.farTrees(&context, x0: 0, x1: 432, baseY: H + 1, height: 10 * u, count: 16, color: light.far, seed: 31)
        Kit.palm(&context, x: 330, baseY: H + 2, height: 30 * u, lean: 2, fronds: 0xC4AEA6, trunk: 0xC0A89C, seed: 2)
        ArtStyle.atmosphere(&context, width: 432, top: H - 40 * u, bottom: H + 4, color: light.haze, alpha: 0.4)
        let still: Kit.Stops = Kit.stops(0xF2DCD0, 0xB4A6A6)
        Kit.water(&context, width: 432, top: H, bottom: size.height, stops: still, light: light, ripples: 18, seed: 7)
        Kit.glints(&context, x: 96, top: H, depth: 80 * u, color: Art.color(0xFFF4E8), count: 26, seed: 5)
        let base: CGFloat = band.H + 30 * u
        let earth: Kit.Stops = Kit.stops(0xC09676, 0x7E6048)
        Kit.mound(&context, x0: 40, x1: 470, baseY: base + 14 * u, height: 22 * u, bottom: size.height + 4, stops: earth, crest: 0.5)
        weaverReeds(&context, x: 36, baseY: base + 24 * u, height: 90 * u, seed: 8)
        let ss: CGFloat = 1.5 * u
        let sm: CGFloat = 1.4 * u
        let xs: CGFloat = 196
        let xm: CGFloat = 278
        Art.group(&context, x: xs, y: base, scale: ss) { g in
            crossLegged(&g, siraLook(), look: CGPoint(x: -0.5, y: -0.2), mouth: .smile)
        }
        cottonBundle(&context, x: xs - 4 * ss, y: base - 13 * ss, scale: ss)
        Art.group(&context, x: xm, y: base, scale: sm) { g in
            madi(&g, mouth: .smile, look: CGPoint(x: -0.8, y: 0))
        }
        shoulderHand(&context, from: CGPoint(x: xm - 15 * sm, y: base - 55 * sm), to: CGPoint(x: xs + 12 * ss, y: base - 42 * ss), width: 7 * sm)
        Kit.grassTuft(&context, x: 380, baseY: base + 18 * u, height: 16 * u, color: 0x6A6A3A, seed: 3)
        ArtStyle.finish(&context, size)
    }

    /// The old man's arm across to the girl's far shoulder: a white sleeve and a thin hand.
    static func shoulderHand(_ context: inout GraphicsContext, from a: CGPoint, to b: CGPoint, width: CGFloat) {
        var arm = Path()
        arm.move(to: a)
        let control = CGPoint(x: (a.x + b.x) / 2, y: min(a.y, b.y) - width * 1.2)
        arm.addQuadCurve(to: b, control: control)
        Art.stroke(&context, arm, Art.color(0xE6E0D4), width: width)
        Art.stroke(&context, arm, Art.color(0xF6F2EA), width: width * 0.5)
        let hand: Path = Art.ellipse(b.x - width * 0.2, b.y + width * 0.2, width * 0.75, width * 0.55)
        Kit.solid(&context, hand, Art.color(skinOld), light: 0.3, shade: 0.2)
    }
}
