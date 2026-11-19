import SwiftUI
import OmramoCore

// The four folded scenes of "The Woman Who Raised a Bear": each its own composition for the
// picture band at the top of a phone (432 wide, 240…520 high), the subject in the middle.

extension BearWomanArt {
    // MARK: Settlement

    /// The old woman's low house nearest the shore, a kayak on its stand beside it, an iceberg
    /// in the bay behind, pale sky above for the words.
    static func settlementFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 58, H - 18 * u, 8 * u, light: light)
        let coast: Path = Kit.peaks(width: w, y: H - 2, amp: 26 * u, seed: 21, bottom: H + 4, sharp: 0.5)
        Art.fill(&context, coast, light.far.opacity(0.75))
        ArtStyle.atmosphere(&context, width: w, top: H - 46 * u, bottom: H + 4, color: light.haze, alpha: 0.35)
        Kit.ground(&context, width: w, top: H, bottom: size.height, stops: iceStops())
        Art.fill(&context, Art.rect(0, H + 1, w, 2.5), Art.color(0x7FA3BA, 0.45))
        iceberg(&context, x: 104, baseY: H + 8 * u, width: 62 * u, height: 46 * u, sharp: true, seed: 2)
        iceberg(&context, x: 30, baseY: H + 4 * u, width: 40 * u, height: 14 * u, sharp: false, seed: 5)
        var land = Path()
        land.move(to: Kit.pt(150, size.height + 10))
        land.addLine(to: Kit.pt(156, H + 46 * u))
        land.addQuadCurve(to: Kit.pt(440, H + 6 * u), control: Kit.pt(250, H + 10 * u))
        land.addLine(to: Kit.pt(440, size.height + 10))
        land.closeSubpath()
        Kit.solid(&context, land, stops: Kit.stops(0x8E989E, 0x6C777E, 0x5E6A72), light: 0.2, shade: 0.2, rim: 2.4)
        Kit.drift(&context, x0: 170, x1: 300, baseY: H + 60 * u, height: 7 * u, bottom: H + 70 * u, snow: true)
        Kit.grass(&context, in: CGRect(x: 200, y: H + 30 * u, width: 220, height: 40 * u), count: 20, seed: 5, color: Art.color(0x6C6A44), height: 5)
        let k: CGFloat = 1.25 * u
        Art.group(&context, x: 392, y: H + 18 * u, scale: k * 0.6) { g in turfHouse(&g, window: true, seed: 6) }
        Art.group(&context, x: 236, y: H + 40 * u, scale: k) { g in turfHouse(&g, window: true, seed: 7) }
        Art.group(&context, x: 338, y: H + 56 * u, scale: k * 0.55) { g in kayakOnStand(&g) }
        Art.group(&context, x: 140, y: H + 54 * u, scale: 0.36 * u) { g in woman(&g, pose: .stand, mouth: .smile) }
        Kit.rock(&context, cx: 12, baseY: size.height + 4, width: 80, height: 34 * u, color: 0x56626A, seed: 31)
        Kit.rock(&context, cx: 424, baseY: size.height + 6, width: 90, height: 40 * u, color: 0x4E5A62, seed: 33)
        ArtStyle.finish(&context, size)
    }

    // MARK: House

    /// The old woman on the platform by the lamp holding out food to the small white cub,
    /// lamplight on both faces, the pale wall above for the words.
    static func houseFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        houseWalls(&context, size, horizon: H)
        Art.group(&context, x: 216, y: H, scale: u) { g in
            houseFoldedRoom(&g, size: size, u: u)
        }
        ArtStyle.finish(&context, size)
    }

    /// The room of the folded house scene in local units: platform level at y 0, x 0 the
    /// middle of the band.
    static func houseFoldedRoom(_ g: inout GraphicsContext, size: CGSize, u: CGFloat) {
        let reach: CGFloat = 216 / u + 40
        let drop: CGFloat = size.height / u + 20
        Art.glow(&g, -60, -30, 220, Art.color(0xFFD98A), alpha: 0.26)
        Art.glow(&g, -64, -120, 70, Art.color(sootHex), alpha: 0.1)
        Art.fill(&g, Art.rect(-reach, -6, reach * 2, 40), Art.color(0xC9B594))
        skins(&g, x0: -reach, x1: reach, y: -2, depth: 32, seed: 9)
        Kit.solid(&g, Art.rect(-reach, 30, reach * 2, 38), Art.color(0x9C8466), light: 0.2, shade: 0.24)
        Kit.solid(&g, Art.rect(-reach, 28, reach * 2, 6, radius: 3), Art.color(woodHex), light: 0.3, shade: 0.2)
        let floor: Kit.Stops = [(Art.color(0xB9AA90), 0), (Art.color(0x9E8E76), 1)]
        Art.fillLinear(&g, Art.rect(-reach, 68, reach * 2, drop), floor, from: CGPoint(x: 0, y: 68), to: CGPoint(x: 0, y: 68 + 120))
        Art.fill(&g, Art.rect(-reach, 68, reach * 2, 5), ArtStyle.coolShade.opacity(0.12))
        let stand: Path = Art.svg("M-100,70 L-96,32 C-82,28 -54,28 -40,32 L-36,70 Z")
        Kit.solid(&g, stand, Art.color(0x8A867C), light: 0.26, shade: 0.26, rim: 1.6)
        Art.group(&g, x: -68, y: 28) { l in stoneLamp(&l, width: 74) }
        Art.group(&g, x: -68, y: -64) { r in lampRack(&r, width: 90) }
        let look = womanLook()
        let hand: CGPoint = Kit.hand(look, pose: .sit)
        let wx: CGFloat = 70
        let wy: CGFloat = 48
        let hx: CGFloat = wx + hand.x
        let hy: CGFloat = wy + hand.y
        Kit.shadow(&g, wx + 6, 22, width: 90, alpha: 0.2)
        Art.group(&g, x: hx - 50, y: 16, scale: 0.4) { c in
            bearLying(&c, lift: 0.9, collar: false, cub: true, mirrored: true)
        }
        Art.group(&g, x: wx, y: wy) { p in woman(&p, pose: .sit, mouth: .smile) }
        let morsel: Path = Art.ellipse(hx, hy - 2, 4.5, 3.4)
        Kit.solid(&g, morsel, Art.color(0xF2E4C2), light: 0.3, shade: 0.2)
        Art.glow(&g, wx - 30, -40, 90, Art.color(0xFFD98A), alpha: 0.18)
        let post: Path = Art.svg("M\(reach - 44),\(drop) L\(reach - 40),-30 L\(reach),-34 L\(reach),\(drop) Z")
        Kit.solid(&g, post, Art.color(0x5E4A38), light: 0.2, shade: 0.3)
    }

    // MARK: Ice

    /// The bear on the white sea ice in the middle, dragging the seal by its flipper, a pale
    /// sky above.
    static func iceFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 54, H - 16 * u, 8 * u, light: light)
        let shore: Path = Kit.ridge(width: 110, y: H - 4 * u, amp: 3 * u, seed: 8, bottom: H + 2, step: 6, x0: 0)
        Art.fill(&context, shore, light.mid.opacity(0.8))
        iceberg(&context, x: 372, baseY: H + 1, width: 30 * u, height: 16 * u, sharp: true, seed: 6)
        ArtStyle.atmosphere(&context, width: w, top: H - 30 * u, bottom: H + 2, color: light.haze, alpha: 0.4)
        Kit.ground(&context, width: w, top: H, bottom: size.height, stops: iceStops())
        Art.fill(&context, Art.rect(190, H - 1, w, 4), Art.color(0x5F86A3, 0.75))
        Art.group(&context, x: 0, y: H, scale: u) { g in
            pressureRidge(&g, x0: 0, x1: 160, baseY: 20, height: 8, seed: 3)
            pressureRidge(&g, x0: 300, x1: 440, baseY: 14, height: 6, seed: 4)
        }
        Art.group(&context, x: 392, y: H + 8 * u, scale: 0.2 * u) { g in hunter(&g, 0, pose: .stand) }
        Art.group(&context, x: 412, y: H + 7 * u, scale: 0.19 * u) { g in hunter(&g, 1, pose: .walk) }
        let drag: Path = Art.svg("M300,\(H + 46 * u) C340,\(H + 40 * u) 390,\(H + 26 * u) 440,\(H + 18 * u)")
        Art.stroke(&context, drag, Art.color(0x9DB9CC, 0.35), width: 6 * u)
        Art.group(&context, x: 250, y: H + 46 * u, scale: 0.95 * u) { g in
            bear(&g, head: 1, collar: true, soot: false)
            haulSeal(&g)
        }
        let s: CGFloat = u
        Art.group(&context, x: 0, y: size.height, scale: s) { g in
            iceBlock(&g, x: -30, baseY: 8, width: 110, height: 44, seed: 1)
        }
        Art.group(&context, x: w, y: size.height, scale: s) { g in
            iceBlock(&g, x: -90, baseY: 8, width: 120, height: 50, seed: 3)
        }
        ArtStyle.finish(&context, size)
    }

    // MARK: Farewell

    /// The old woman at the edge of the ice in the foreground with her hand raised, the bear
    /// small and white among the icebergs beyond her, pale sky above.
    static func farewellFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let H: CGFloat = band.H
        let w: CGFloat = size.width
        let light = morning()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 60, H - 14 * u, 9 * u, light: light)
        ArtStyle.atmosphere(&context, width: w, top: H - 30 * u, bottom: H + 3, color: light.haze, alpha: 0.4)
        Art.fill(&context, Art.rect(0, H - 1, w, 3), Art.color(0x6F95B0, 0.6))
        Kit.ground(&context, width: w, top: H + 2, bottom: size.height, stops: iceStops())
        iceberg(&context, x: 262, baseY: H + 4 * u, width: 44 * u, height: 26 * u, sharp: true, seed: 11)
        iceberg(&context, x: 380, baseY: H + 3 * u, width: 70 * u, height: 44 * u, sharp: true, seed: 12)
        iceberg(&context, x: 322, baseY: H + 2 * u, width: 40 * u, height: 12 * u, sharp: false, seed: 13)
        let bx: CGFloat = 318
        let by: CGFloat = H + 16 * u
        pawPrints(&context, from: Kit.pt(186, size.height - 40), to: Kit.pt(bx - 14 * u, by + 2), count: 12, size: 4 * u)
        Art.group(&context, x: bx, y: by, scale: 0.26 * u) { g in
            bear(&g, head: 0, collar: true, soot: true, mirrored: true)
        }
        let feet: CGFloat = band.floor - 4
        var shore = Path()
        shore.move(to: Kit.pt(-10, size.height + 10))
        shore.addLine(to: Kit.pt(-10, feet - 10 * u))
        shore.addQuadCurve(to: Kit.pt(230, feet + 4 * u), control: Kit.pt(110, feet - 22 * u))
        shore.addLine(to: Kit.pt(250, size.height + 10))
        shore.closeSubpath()
        Kit.solid(&context, shore, stops: Kit.stops(0x7E8A92, 0x5E6A72, 0x4E5A62), light: 0.2, shade: 0.22, rim: 2.4)
        Kit.drift(&context, x0: 10, x1: 180, baseY: feet + 2, height: 6 * u, bottom: feet + 12, snow: true)
        Art.group(&context, x: 150, y: feet, scale: 0.95 * u) { g in
            woman(&g, pose: .wave, mouth: .flat, mirrored: true, sooty: true)
        }
        Art.group(&context, x: w, y: size.height, scale: u) { g in
            iceBlock(&g, x: -80, baseY: 8, width: 110, height: 40, seed: 49)
        }
        ArtStyle.finish(&context, size)
    }
}
