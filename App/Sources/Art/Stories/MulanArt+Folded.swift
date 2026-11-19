import SwiftUI
import OmramoCore

// The four folded scenes of "The Ballad of Mulan": the picture band at the top of a phone,
// 432 wide and 240…520 high, each its own composition. Everything is placed from the band's
// horizon `band.H` and scaled by `band.unit`, so the subject stands between y 60 and the wavy
// floor at 240 high and fills the band at 520.

extension MulanArt {
    // MARK: - scene-loom

    static func loomFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let H: CGFloat = band.H
        let light = day()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 44, H - 70 * u, 12 * u, light: light)
        loessHills(&context, width: w, horizon: H, scale: 0.8 * u, light: light, seed: 23)
        ArtStyle.atmosphere(&context, width: w, top: H - 90 * u, bottom: H, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: w, top: H, bottom: size.height, stops: Kit.stops(0xE6CB92, 0xD8B67A, 0xC29C62))
        earthWall(&context, x0: -10, x1: 170, baseY: H + 8 * u, height: 26 * u, color: wallTone, seed: 24)
        tileGate(&context, cx: 70, baseY: H + 10 * u, width: 46 * u, height: 48 * u)
        let foot: CGFloat = H + 26 * u
        let wallTop: CGFloat = foot - 190 * u
        let mx: CGFloat = 300 + 24 * u
        Kit.shadow(&context, 300, foot, width: 300)
        Kit.wall(&context, rect: CGRect(x: 160, y: wallTop, width: 290, height: foot - wallTop), color: houseTone)
        earthCourses(&context, CGRect(x: 160, y: wallTop + 6, width: 290, height: foot - wallTop - 10), seed: 25)
        Kit.roof(&context, cx: 310, eaveY: wallTop, width: 320, height: 18 * u, color: tileTone, style: .tile)
        let door = CGRect(x: mx - 130 * u, y: foot - 170 * u, width: 190 * u, height: 170 * u)
        let inside: Kit.Stops = [(Art.color(0x5A3E2A), 0), (Art.color(0x6E4E34), 1)]
        Art.fillLinear(&context, Path(door), inside, from: CGPoint(x: door.minX, y: door.minY), to: CGPoint(x: door.maxX, y: door.maxY))
        Art.glow(&context, door.minX + 40 * u, foot - 50 * u, 110 * u, Art.color(0xF6DFA8), alpha: 0.3)
        var frame = Path()
        frame.addRect(CGRect(x: door.minX - 7 * u, y: door.minY - 6 * u, width: 7 * u, height: door.height + 6 * u))
        frame.addRect(CGRect(x: door.maxX, y: door.minY - 6 * u, width: 7 * u, height: door.height + 6 * u))
        frame.addRect(CGRect(x: door.minX - 11 * u, y: door.minY - 10 * u, width: door.width + 22 * u, height: 7 * u))
        Kit.solid(&context, frame, Art.color(0x7A5A3A), light: 0.3, shade: 0.24)
        loom(&context, x: mx - 32 * u, baseY: foot, scale: 0.86 * u, cloth: 0.55)
        stool(&context, x: mx + 4 * u, baseY: foot, height: 34 * u, width: 34 * u)
        Art.group(&context, x: mx, y: foot, scale: u) { g in
            Kit.person(&g, mulanHomeLook(), pose: .sit, look: CGPoint(x: -0.6, y: 0.4), mouth: .flat)
            hairPins(&g, head: CGPoint(x: 6, y: -128))
            let hand: CGPoint = Kit.hand(mulanHomeLook(), pose: .sit)
            shuttle(&g, x: hand.x - 4, y: hand.y - 2, scale: 1.2)
        }
        Kit.shadow(&context, 110, foot + 6 * u, width: 30 * u)
        Art.group(&context, x: 110, y: foot + 6 * u, scale: 0.5 * u) { g in
            Kit.bird(&g, henLook(), pose: .peck)
        }
        foldedWillowBranch(&context, x0: 120, x1: 250, top: 0, reach: H - 120 * u)
        Kit.grassTuft(&context, x: 20, baseY: size.height, height: 52 * u, color: 0x5E7A3A, seed: 26)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    /// A willow bough hanging into the band from its top edge between x0 and x1, its fronds
    /// reaching down to about `reach`.
    static func foldedWillowBranch(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, top: CGFloat, reach: CGFloat) {
        var random = ArtRandom(27)
        let bough = Art.svg("M\(x0 - 30),\(top - 4) C\(x0 + 20),\(top + 14) \(x1 - 40),\(top + 20) \(x1),\(top + 10)")
        Art.stroke(&context, bough, Art.color(0x5E4E3A), width: 4)
        var dark = Path()
        var lit = Path()
        for index in 0..<16 {
            let t: CGFloat = CGFloat(index) / 15
            let fx: CGFloat = Kit.mix(x0, x1, t)
            let fy: CGFloat = top + 8 + 10 * t
            let length: CGFloat = max(20, (reach - fy) * (0.6 + Kit.rnd(&random) * 0.4))
            var frond = Path()
            frond.move(to: CGPoint(x: fx, y: fy))
            frond.addQuadCurve(to: CGPoint(x: fx + 6, y: fy + length), control: CGPoint(x: fx - 4, y: fy + length * 0.5))
            if index % 2 == 0 {
                lit.addPath(frond)
            } else {
                dark.addPath(frond)
            }
        }
        Art.stroke(&context, dark, Art.color(0x5E7A3A, 0.85), width: 1.8)
        Art.stroke(&context, lit, Art.color(0xA9BE78, 0.9), width: 1.8)
    }

    // MARK: - scene-river

    static func riverFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = band.H
        let light = evening()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 60, H - 58 * u, 14 * u, light: light)
        loessCliffs(&context, width: w, horizon: H, scale: 0.8 * u, light: light)
        ArtStyle.atmosphere(&context, width: w, top: H - 70 * u, bottom: H, color: light.haze, alpha: 0.3)
        let flow: Kit.Stops = [(Art.color(0xCDA866), 0), (Art.color(0xB68C4C), 0.5), (Art.color(0x9A743C), 1)]
        Kit.water(&context, width: w, top: H, bottom: h, stops: flow, light: light, ripples: 30, seed: 35)
        Kit.glints(&context, x: 60, top: H, depth: 60 * u, color: Art.color(0xFFF0C8), count: 18, seed: 36)
        let bank = Art.svg("M-10,\(h + 4) L-10,\(H + 62 * u) C80,\(H + 40 * u) 200,\(H + 16 * u) 300,\(H + 8 * u) L440,\(H + 4 * u) L440,\(h + 4) Z")
        let earth: Kit.Stops = [(Art.color(0xE2C288), 0), (Art.color(0xCDA66C), 0.5), (Art.color(0xAE8650), 1)]
        Kit.solid(&context, bank, stops: earth, light: 0.22, shade: 0.2)
        let lip = Art.svg("M-10,\(H + 62 * u) C80,\(H + 40 * u) 200,\(H + 16 * u) 300,\(H + 8 * u) L440,\(H + 4 * u)")
        Art.stroke(&context, lip, Art.color(0xF4DFAE, 0.8), width: 2)
        let horseY: CGFloat = H + 36 * u
        Kit.shadow(&context, 350, horseY, width: 130 * u)
        Art.group(&context, x: 350, y: horseY, scale: 0.6 * u) { g in
            bayHorse(&g, pose: .stand, mood: .calm, saddled: false)
        }
        let laid = Art.svg("M\(268 * 1),\(H + 58 * u) C\(272),\(H + 48 * u) \(310),\(H + 46 * u) \(322),\(H + 52 * u) L\(318),\(H + 62 * u) C\(300),\(H + 66 * u) \(282),\(H + 66 * u) \(268),\(H + 58 * u) Z")
        Kit.shadow(&context, 296, H + 62 * u, width: 60 * u)
        lamellar(&context, laid, box: CGRect(x: 268, y: H + 46 * u, width: 54, height: 20 * u), row: 5, frost: false)
        let fireX: CGFloat = 150
        let fireY: CGFloat = H + 50 * u
        var smoke = Path()
        smoke.move(to: CGPoint(x: fireX, y: fireY - 30 * u))
        smoke.addCurve(to: CGPoint(x: fireX + 24, y: H - 60 * u), control1: CGPoint(x: fireX - 14, y: H), control2: CGPoint(x: fireX + 30, y: H - 20 * u))
        Art.stroke(&context, smoke, Art.color(0xF6EEDC, 0.5), width: 4)
        Kit.campfire(&context, cx: fireX, baseY: fireY, scale: 0.62 * u)
        let seatY: CGFloat = H + 46 * u
        Kit.rock(&context, cx: 240, baseY: seatY, width: 44 * u, height: 32 * u, color: 0xA88A64, seed: 37)
        Art.group(&context, x: 232, y: seatY, scale: 0.95 * u) { g in
            Kit.person(&g, mulanSoldierLook(), pose: .sit, look: CGPoint(x: -0.7, y: 0.2), mouth: .flat)
        }
        Art.glow(&context, 196, seatY - 70 * u, 60 * u, Art.color(0xFFB45A), alpha: 0.22)
        Kit.reeds(&context, x: 16, baseY: h + 2, count: 5, height: 70 * u, seed: 38, color: 0x6E7A3A)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }

    // MARK: - scene-frontier

    static func frontierFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = band.H
        let light = dawn()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 50, H - 60 * u, 12 * u, light: light)
        let peaks: [(CGFloat, CGFloat, CGFloat, UInt32)] = [(70, 220, 70, 3), (250, 260, 92, 5), (420, 220, 66, 7)]
        for peak in peaks {
            Kit.mountain(&context, cx: peak.0, baseY: H + 2, width: peak.1 * u, height: peak.2 * u, color: light.far, snow: Art.color(0xF4F6F8), seed: peak.3)
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 100 * u, bottom: H, color: light.haze, alpha: 0.4)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: Kit.stops(0xC9CBB4, 0xB4B292, 0x9C9676))
        earthWall(&context, x0: -10, x1: 440, baseY: H + 12 * u, height: 30 * u, color: wallTone, seed: 62)
        watchTower(&context, cx: 92, baseY: H + 16 * u, scale: 0.9 * u, seed: 63)
        let horseX: CGFloat = 236
        let foot: CGFloat = H + 34 * u
        Kit.shadow(&context, horseX, foot, width: 150 * u, alpha: 0.3)
        Art.group(&context, x: horseX, y: foot, scale: 0.6 * u) { g in
            rider(&g, mulanSoldierLook(), pose: .stand, armoured: true, frost: true)
            breath(&g, x: -14, y: -198, scale: 1)
        }
        Kit.flecks(&context, in: CGRect(x: 0, y: H + 4, width: w, height: h - H), count: 30, seed: 64, color: Color.white.opacity(0.6), radius: 0.6...1.4)
        Kit.drift(&context, x0: -30, x1: 130, baseY: h - 10, height: 18 * u, bottom: h + 20, snow: true)
        Kit.drift(&context, x0: 330, x1: 460, baseY: h - 8, height: 14 * u, bottom: h + 20, snow: true)
        ArtStyle.finish(&context, size, wash: 0.07, vignette: 0.08)
    }

    // MARK: - scene-home

    static func homeFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = band.H
        let light = afternoon()
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 340, H - 140 * u, scale: 0.4 * u, color: Color.white.opacity(0.45))
        loessHills(&context, width: w, horizon: H, scale: 0.8 * u, light: light, seed: 65)
        ArtStyle.atmosphere(&context, width: w, top: H - 90 * u, bottom: H, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: w, top: H, bottom: h, stops: Kit.stops(0xC4C892, 0xA6B676, 0x86A062))
        let foot: CGFloat = H + 18 * u
        let top: CGFloat = foot - 170 * u
        Kit.shadow(&context, 250, foot, width: 360)
        Kit.wall(&context, rect: CGRect(x: 70, y: top, width: 370, height: foot - top), color: houseTone)
        earthCourses(&context, CGRect(x: 70, y: top + 6, width: 370, height: foot - top - 10), seed: 66)
        Kit.roof(&context, cx: 260, eaveY: top, width: 410, height: 18 * u, color: tileTone, style: .tile)
        let ww: CGFloat = 150 * u
        let window = CGRect(x: 216 - ww / 2, y: top + 22 * u, width: ww, height: 112 * u)
        windowWithMulan(&context, window)
        willow(&context, x: 34, baseY: foot + 4, height: 150 * u, seed: 67)
        Kit.crop(&context, x0: -10, x1: 440, baseY: foot + 14 * u, height: 12 * u, tops: false, color: 0x7E9A5C, seed: 68)
        Art.group(&context, x: 150, y: foot + 30 * u, scale: 0.4 * u) { g in
            Kit.shadow(&g, 0, 0, width: 90)
            hare(&g)
        }
        Art.group(&context, x: 190, y: foot + 34 * u, scale: 0.4 * u) { g in
            Kit.shadow(&g, 0, 0, width: 90)
            hare(&g)
        }
        Kit.crop(&context, x0: -10, x1: 440, baseY: foot + 40 * u, height: 16 * u, tops: false, color: 0x6E8C50, seed: 69)
        Kit.grassTuft(&context, x: 414, baseY: h, height: 50 * u, color: 0x4E6E3A, seed: 70)
        ArtStyle.finish(&context, size, wash: 0.08, vignette: 0.08)
    }
}
