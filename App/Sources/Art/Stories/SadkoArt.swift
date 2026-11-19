import SwiftUI
import OmramoCore

/// Concept art for "Sadko", drawn in code (round 5; composed from the shared kit).
enum SadkoArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-novgorod", .sceneUnfolded): novgorodScene(&context, size)
        case ("scene-novgorod", .sceneFolded): novgorodFolded(&context, size)
        case ("scene-lake", .sceneUnfolded): lakeScene(&context, size)
        case ("scene-lake", .sceneFolded): lakeFolded(&context, size)
        case ("scene-ship", .sceneUnfolded): shipScene(&context, size)
        case ("scene-ship", .sceneFolded): shipFolded(&context, size)
        case ("scene-palace", .sceneUnfolded): palaceScene(&context, size)
        case ("scene-palace", .sceneFolded): palaceFolded(&context, size)
        case ("see-gusli", .picture): gusliPicture(&context, size)
        case ("see-lake-ilmen", .picture): lakeIlmenPicture(&context, size)
        case ("see-bylina", .picture): bylinaPicture(&context, size)
        case ("see-river-roads", .picture): riverRoadsPicture(&context, size)
        case ("char-sadko", .portrait): sadkoPortrait(&context, size)
        case ("char-sea-tsar", .portrait): seaTsarPortrait(&context, size)
        case ("face-sadko", .face): sadkoFace(&context, size)
        case ("face-sea-tsar", .face): seaTsarFace(&context, size)
        case ("face-chernava", .face): chernavaFace(&context, size)
        case ("cover", .cover): coverArt(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - scene-novgorod (unfolded): deep dusk by the Volkhov

extension SadkoArt {
    /// Novgorod at deep dusk: the leading pane is dark sky with the first stars over the far
    /// bank; on the trailing pane the white cathedral behind the old rampart, lamplit log
    /// houses stepping down to the quay, and Sadko on the near bank with his gusli.
    static func novgorodScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        let light = dusk()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: w, maxY: st.H - 120 * st.far, count: 64, seed: 21)
        let forest: Path = Kit.ridge(width: w, y: st.H - 9 * st.far, amp: 7 * st.far, seed: 6, bottom: st.H + 6, step: 6)
        Art.fill(&context, forest, light.far)
        let river: Kit.Stops = [(Art.color(0x2B4468), 0), (Art.color(0x17294A), 0.3), (Art.color(0x0C1730), 1)]
        Kit.water(&context, width: w, top: st.H, bottom: size.height, stops: river, light: light, ripples: 40, seed: 31)
        novgorodLeading(&context, st)
        Kit.designSpace(&context, st) { v in
            novgorodCity(&v, st)
            Kit.nearSpace(&v, st, anchorX: 892) { n in
                novgorodBank(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.05, vignette: 0.14)
    }

    /// The quiet things low on the leading side: one far boat with a lamp, reeds in the corner.
    static func novgorodLeading(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let k: CGFloat = 0.22 * st.far
        let by: CGFloat = st.H + 30 * st.far
        Art.glow(&context, 236, by - 10 * st.far, 30 * st.far, Art.color(0xFFC65A), alpha: 0.3)
        Art.group(&context, x: 240, y: by, scale: k) { g in
            ship(&g, furled: true)
        }
        Art.fill(&context, Art.circle(236, by - 10 * st.far, 1.6 * st.far), Art.color(0xFFE2A0))
        Kit.ripples(&context, 240, by + 3, 60 * st.far, count: 2, color: Art.color(0xE9EEF2), opacity: 0.3)
        let reedColor: Color = Art.color(0x070D1C)
        let tall: CGFloat = 70 * st.grow
        reedClump(&context, 36, st.h + 4, count: 10, height: tall, seed: 5, color: reedColor)
        reedClump(&context, 120, st.h + 4, count: 6, height: tall * 0.6, seed: 9, color: reedColor)
    }

    /// The city on the far bank, in design units: bank, cathedral, rampart and towers, log
    /// houses with lit windows, the quay and two boats with furled sails.
    static func novgorodCity(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let bank: Path = Art.polygon([
            CGPoint(x: 440, y: Hv - 2), CGPoint(x: 520, y: Hv - 10), CGPoint(x: 892, y: Hv - 12),
            CGPoint(x: 892, y: Hv + 18), CGPoint(x: 600, y: Hv + 20), CGPoint(x: 470, y: Hv + 9),
        ])
        Art.fill(&v, bank, Art.color(0x182038))
        Art.glow(&v, 706, Hv - 110, 150, Art.color(0x6F8FC0), alpha: 0.16)
        Art.group(&v, x: 706, y: Hv - 20, scale: 0.92) { g in
            cathedral(&g)
        }
        rampart(&v, x0: 556, x1: 892, y: Hv - 6)
        Art.group(&v, x: 588, y: Hv - 6, scale: 0.8) { g in
            woodTower(&g)
        }
        Art.group(&v, x: 846, y: Hv - 6, scale: 0.86) { g in
            woodTower(&g)
        }
        // Log houses, stepping down to the river: (x, drop below the horizon, scale, lit).
        let houses: [(CGFloat, CGFloat, CGFloat, Bool)] = [
            (500, 7, 0.8, false), (612, 9, 0.88, true), (856, 9, 0.84, true), (548, 13, 1, true), (796, 13, 1.02, true),
        ]
        for house in houses {
            Art.group(&v, x: house.0, y: Hv + house.1, scale: house.2) { g in
                logHouse(&g, w: 52, wall: 30, lit: house.3)
            }
        }
        quay(&v, x0: 468, x1: 668, y: Hv + 23)
        let gold: Color = Art.color(0xFFC65A, 0.55)
        Kit.glints(&v, x: 548, top: Hv + 30, depth: 46, color: gold, count: 9, seed: 3)
        Kit.glints(&v, x: 796, top: Hv + 24, depth: 40, color: gold, count: 8, seed: 14)
        Art.group(&v, x: 528, y: Hv + 33, scale: 0.26) { g in
            ship(&g, furled: true)
        }
        Art.group(&v, x: 622, y: Hv + 37, scale: 0.33) { g in
            ship(&g, furled: true)
        }
        Kit.ripples(&v, 622, Hv + 40, 84, count: 2, color: Art.color(0xE9EEF2), opacity: 0.3)
    }

    /// The near bank on the trailing side, in near-plane units: dark turf falling to the
    /// water, a torch on a post, and Sadko on a log with the gusli on his knees.
    static func novgorodBank(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        var bank = Path()
        bank.move(to: CGPoint(x: 900, y: Hv + 78))
        bank.addLine(to: CGPoint(x: 700, y: Hv + 86))
        bank.addQuadCurve(to: CGPoint(x: 560, y: Hv + 128), control: CGPoint(x: 620, y: Hv + 92))
        bank.addQuadCurve(to: CGPoint(x: 400, y: Hv + 300), control: CGPoint(x: 500, y: Hv + 170))
        bank.addLine(to: CGPoint(x: 400, y: Hv + 900))
        bank.addLine(to: CGPoint(x: 900, y: Hv + 900))
        bank.closeSubpath()
        let turf: Kit.Stops = [(Art.color(0x26383A), 0), (Art.color(0x162028), 0.3), (Art.color(0x0A101C), 1)]
        Art.fillLinear(&n, bank, turf, from: CGPoint(x: 0, y: Hv + 78), to: CGPoint(x: 0, y: Hv + 330))
        let crest: Path = Art.svg("M0,8 L-200,16 Q-280,22 -340,58")
        let lit: Path = crest.applying(CGAffineTransform(translationX: 900, y: Hv + 71))
        Art.stroke(&n, lit, Art.color(0x6F8FA8, 0.45), width: 2)
        let dark: Color = Art.color(0x0A101C)
        reedClump(&n, 578, Hv + 126, count: 7, height: 46, seed: 4, color: dark)
        reedClump(&n, 498, Hv + 190, count: 8, height: 58, seed: 12, color: dark)
        reedClump(&n, 436, Hv + 268, count: 9, height: 66, seed: 17, color: dark)
        // A plank path and a few pale stones on the deep bank of a tall window.
        if st.tall > 0.25 {
            var planks = Path()
            for i in 0..<6 {
                let t: CGFloat = CGFloat(i)
                planks.addPath(Art.rect(640 + t * 14, Hv + 150 + t * 22, 96 + t * 10, 9, radius: 2))
            }
            Art.fill(&n, planks, Art.color(0x3A2E2A))
            Art.fill(&n, Art.ellipse(560, Hv + 220, 16, 7), Art.color(0x4E5A6E))
            Art.fill(&n, Art.ellipse(824, Hv + 196, 12, 5), Art.color(0x4E5A6E))
        }
        Art.group(&n, x: 670, y: Hv + 92, scale: 0.9) { g in
            torch(&g)
        }
        Art.glow(&n, 730, Hv + 40, 120, Art.color(0xFFC65A), alpha: 0.16)
        Art.group(&n, x: 760, y: Hv + 106) { g in
            let seat: Path = Art.rect(-16, -34, 60, 34, radius: 12)
            Kit.shadow(&g, 4, 1, width: 96, alpha: 0.4)
            Kit.solid(&g, seat, stops: Kit.stops(0x7A5A40, 0x3A2A24), light: 0.3, shade: 0.3)
            Art.stroke(&g, Art.ellipse(-8, -17, 6, 13), Art.color(0x2A1E1C, 0.6), width: 1.2)
            sadkoPlaying(&g, look: CGPoint(x: -0.3, y: -0.2))
        }
    }
}

// MARK: - scene-lake (unfolded): night on Lake Ilmen

extension SadkoArt {
    /// Lake Ilmen under many stars: the leading pane is only sky over a flat far shore and
    /// the heaving water; on the trailing pane the Sea Tsar has risen to the chest, and Sadko
    /// plays on the white stone at the water's edge.
    static func lakeScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = night()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: w, maxY: st.H - 24 * st.far, count: 190, seed: 33)
        let shore: Path = Kit.ridge(width: w, y: st.H - 5 * st.far, amp: 4 * st.far, seed: 15, bottom: st.H + 6, step: 6)
        Art.fill(&context, shore, light.far)
        let lake: Kit.Stops = [
            (Art.color(0x1D3F62), 0), (Art.color(0x10294A), 0.25), (Art.color(0x0A1A33), 0.7), (Art.color(0x070E22), 1),
        ]
        Kit.water(&context, width: w, top: st.H, bottom: size.height, stops: lake, light: light, ripples: 26, seed: 12)
        // The lake heaves in long swells with no wind; starlight lies on the wave backs.
        Kit.swells(&context, width: w, top: st.H + 12, bottom: size.height, rows: 9, crest: Art.color(0xBFD3E6), seed: 12)
        let reedColor: Color = Art.color(0x050A18)
        reedClump(&context, 30, st.h + 4, count: 9, height: 64 * st.grow, seed: 7, color: reedColor)
        reedClump(&context, 96, st.h + 4, count: 5, height: 40 * st.grow, seed: 11, color: reedColor)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 640) { n in
                lakeTsar(&n, st)
            }
            Kit.nearSpace(&v, st, anchorX: 892) { n in
                lakeShore(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.14)
    }

    /// The Sea Tsar risen from the lake, water pouring from beard and crown, and three
    /// gold-finned fish glinting round him.
    static func lakeTsar(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.glow(&n, 640, Hv - 90, 250, Art.color(0x4FAE9E), alpha: 0.2)
        Art.group(&n, x: 640, y: Hv - 122, scale: 1.2) { g in
            tsarRising(&g, waterline: 148)
        }
        // (x, y below the horizon, turn in degrees, scale)
        let fishes: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(506, 84, -28, 0.8), (566, 112, 8, 0.7), (748, 96, -14, 0.62)]
        for place in fishes {
            Art.glow(&n, place.0, Hv + place.1, 26, Art.color(0xFFC65A), alpha: 0.25)
            Art.group(&n, x: place.0, y: Hv + place.1, rotate: Kit.deg(place.2), scale: place.3) { g in
                fish(&g)
            }
            Kit.ripples(&n, place.0 + 4, Hv + place.1 + 12, 44, count: 2, color: Art.color(0xE9EEF2), opacity: 0.4)
        }
    }

    /// The near shore: a low dark bank with reeds, the white stone, and Sadko on it, looking
    /// up as he plays.
    static func lakeShore(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        var bank = Path()
        bank.move(to: CGPoint(x: 900, y: Hv + 98))
        bank.addLine(to: CGPoint(x: 776, y: Hv + 106))
        bank.addQuadCurve(to: CGPoint(x: 694, y: Hv + 142), control: CGPoint(x: 724, y: Hv + 110))
        bank.addQuadCurve(to: CGPoint(x: 600, y: Hv + 330), control: CGPoint(x: 660, y: Hv + 204))
        bank.addLine(to: CGPoint(x: 600, y: Hv + 900))
        bank.addLine(to: CGPoint(x: 900, y: Hv + 900))
        bank.closeSubpath()
        let turf: Kit.Stops = [(Art.color(0x1C2C3A), 0), (Art.color(0x101A28), 0.3), (Art.color(0x070C18), 1)]
        Art.fillLinear(&n, bank, turf, from: CGPoint(x: 0, y: Hv + 98), to: CGPoint(x: 0, y: Hv + 340))
        Art.stroke(&n, Art.line(776, Hv + 106, 900, Hv + 98), Art.color(0x7F9AB8, 0.4), width: 1.8)
        let dark: Color = Art.color(0x050A18)
        reedClump(&n, 706, Hv + 140, count: 8, height: 50, seed: 3, color: dark)
        reedClump(&n, 652, Hv + 214, count: 9, height: 62, seed: 8, color: dark)
        reedClump(&n, 884, Hv + 108, count: 5, height: 44, seed: 13, color: dark)
        if st.tall > 0.25 {
            // The deep bank of a tall window: pale pebbles and one more clump of reeds.
            let pebbles: [(CGFloat, CGFloat, CGFloat)] = [(730, 190, 13), (800, 230, 9), (690, 262, 11), (846, 178, 8), (760, 290, 14)]
            for pebble in pebbles {
                let shape: Path = Art.ellipse(pebble.0, Hv + pebble.1, pebble.2, pebble.2 * 0.45)
                Kit.solid(&n, shape, Art.color(0x5E6E88), light: 0.3, shade: 0.3)
            }
            reedClump(&n, 622, Hv + 300, count: 9, height: 70, seed: 21, color: dark)
        }
        Art.glow(&n, 822, Hv + 30, 100, Art.color(0xBFD3E6), alpha: 0.14)
        Art.group(&n, x: 822, y: Hv + 110, scale: 0.95) { g in
            whiteStone(&g)
            sadkoPlaying(&g, look: CGPoint(x: -0.7, y: -0.7), mouth: .oh)
        }
    }
}

// MARK: - scene-ship (unfolded): the ships held still at sea

extension SadkoArt {
    /// Night at sea: a low moon behind thin cloud by the hinge, waves racing past, and on the
    /// trailing pane three red-sailed ships sitting dead still, the oak plank being lowered
    /// from the nearest, Sadko at the rail with his gusli.
    static func shipScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = night()
        let w: CGFloat = size.width
        let f: CGFloat = st.far
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.stars(&context, width: w, maxY: st.H - 110 * f, count: 80, seed: 41)
        // The low moon, in the hinge strip, behind thin cloud.
        let mx: CGFloat = 450
        let my: CGFloat = st.H - 54 * f
        Kit.moon(&context, mx, my, 15 * f, color: Art.color(0xE6E0C4))
        var veil = Path()
        veil.addPath(Art.rect(mx - 78 * f, my - 5 * f, 150 * f, 6 * f, radius: 3 * f))
        veil.addPath(Art.rect(mx - 30 * f, my + 5 * f, 120 * f, 5 * f, radius: 2.5 * f))
        veil.addPath(Art.rect(mx - 96 * f, my - 15 * f, 90 * f, 4 * f, radius: 2 * f))
        Art.fill(&context, veil, Art.color(0x1D3F62, 0.8))
        let sea: Kit.Stops = [
            (Art.color(0x1B2F52), 0), (Art.color(0x12284A), 0.25), (Art.color(0x0B1A33), 0.7), (Art.color(0x070E22), 1),
        ]
        Kit.water(&context, width: w, top: st.H, bottom: size.height, stops: sea, light: light, ripples: 20, seed: 19)
        Kit.glints(&context, x: mx, top: st.H, depth: st.depth, color: Art.color(0xE6E0C4, 0.55), count: 26, seed: 8)
        // Waves racing past, white-topped.
        Kit.swells(&context, width: w, top: st.H + 10, bottom: size.height, rows: 12, crest: Art.color(0xE9EEF2), seed: 5)
        Kit.rippleMarks(&context, x0: 0, x1: w, y0: st.H + 14, y1: size.height, count: 34, seed: 27, color: Art.color(0xE9EEF2), alpha: 0.5)
        // Two more of the thirty, far off on the leading side.
        let farShips: [(CGFloat, CGFloat)] = [(286, 0.1), (352, 0.13)]
        for place in farShips {
            Art.group(&context, x: place.0, y: st.H + 10 * f, scale: place.1 * f, opacity: 0.8) { g in
                ship(&g)
            }
        }
        Kit.designSpace(&context, st) { v in
            shipFleet(&v, st)
            Kit.nearSpace(&v, st, anchorX: 760) { n in
                shipNearest(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.14)
    }

    /// The patch of strangely smooth water and the two ships behind the nearest.
    static func shipFleet(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.blurred(&v, radius: 10, opacity: 0.9) { g in
            Art.fill(&g, Art.ellipse(690, Hv + 62, 220, 50), Art.color(0x0B1A33))
        }
        Art.group(&v, x: 524, y: Hv + 16, scale: 0.3) { g in
            ship(&g)
        }
        Kit.ripples(&v, 524, Hv + 19, 70, count: 1, color: Art.color(0xE9EEF2), opacity: 0.3)
        Art.group(&v, x: 618, y: Hv + 32, scale: 0.47) { g in
            ship(&g)
        }
        Kit.ripples(&v, 618, Hv + 36, 110, count: 1, color: Art.color(0xE9EEF2), opacity: 0.3)
    }

    /// The nearest ship: full red sail, flat still hull, two sailors lowering the oak plank on
    /// ropes, and Sadko in his merchant's coat at the rail.
    static func shipNearest(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.group(&n, x: 756, y: Hv + 80, scale: 0.98) { g in
            shipSail(&g)
            // A horn lantern at the stern lights the deck.
            Art.glow(&g, 4, -56, 84, Art.color(0xFFC65A), alpha: 0.3)
            Art.group(&g, x: 30, y: -12, scale: 0.46) { s in
                Kit.person(&s, sailorLook(), pose: .carry, look: CGPoint(x: -0.2, y: 0.7), mouth: .flat)
            }
            Art.group(&g, x: 76, y: -12, scale: 0.46, scaleX: -1) { s in
                Kit.person(&s, sailorLook(), pose: .carry, look: CGPoint(x: -0.2, y: 0.7), mouth: .oh, mirrored: true)
            }
            Art.group(&g, x: -50, y: -12, scale: 0.5) { s in
                sadkoStanding(&s, look: CGPoint(x: 0.3, y: 0.8), mouth: .flat)
            }
            shipHull(&g)
            // The oak plank, hanging on two ropes against the ship's side.
            Art.stroke(&g, Art.svg("M14,-30 L14,-8 M70,-30 L70,-8"), Art.color(0xC9B79A), width: 1.4)
            let plank: Path = Art.rect(2, -10, 82, 7, radius: 2)
            Kit.solid(&g, plank, Art.color(0xB08A5A), light: 0.34, shade: 0.24)
            Art.stroke(&g, Art.line(6, -6.5, 80, -6.5), Art.color(0x6E4A30, 0.6), width: 0.8)
            Kit.ripples(&g, 0, 8, 250, count: 2, color: Art.color(0xE9EEF2), opacity: 0.35)
        }
        // A dark near wave across the foot of a tall window.
        if st.tall > 0.25 {
            let near: Path = Kit.ridge(width: 700, y: Hv + 236, amp: 10, seed: 44, bottom: Hv + 900, step: 10, x0: 240)
            Art.fill(&n, near, Art.color(0x070E22, 0.8))
            Kit.rippleMarks(&n, x0: 300, x1: 900, y0: Hv + 150, y1: Hv + 230, count: 16, seed: 3, color: Art.color(0xE9EEF2), alpha: 0.4)
        }
    }
}

// MARK: - scene-palace (unfolded): the floor of the sea

extension SadkoArt {
    /// The deep water itself: dark green, with green-gold light falling on the trailing side,
    /// and the sea floor from `floorY` down. Shared by the unfolded and the folded scene.
    static func seaDeep(_ context: inout GraphicsContext, _ size: CGSize, floorY: CGFloat, lightX: CGFloat, spread: CGFloat) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let water: Kit.Stops = [(Art.color(0x10403E), 0), (Art.color(0x0C3238), 0.5), (Art.color(0x0A2A33), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), water, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: max(1, floorY)))
        Art.glow(&context, lightX, 0, spread, Art.color(0xC9D98A), alpha: 0.17)
        let sand: Kit.Stops = [(Art.color(0x24604E), 0), (Art.color(0x12403E), 0.4), (Art.color(0x0A2A33), 1)]
        Kit.ground(&context, width: w, top: floorY, bottom: h, stops: sand, seed: 77, tooth: Art.color(0xBFE6A0))
        Kit.rippleMarks(&context, x0: 0, x1: w, y0: floorY + 8, y1: h, count: 26, seed: 9, color: Art.color(0xBFE6A0), alpha: 0.16)
    }

    /// Under the sea: calm dark green water with a few rising bubbles on the leading pane; on
    /// the trailing pane the palace of white stone and shell, the coral throne, the huge Sea
    /// Tsar in mid-dance among fish and river-maidens, small Sadko playing on a white step,
    /// and Chernava in plain grey beside him.
    static func palaceScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 150)
        seaDeep(&context, size, floorY: st.H, lightX: 700, spread: st.H * 0.8)
        lightShafts(&context, x0: 570, x1: 870, bottom: st.H + 16)
        // The leading side: bubbles, one far fish, weed in the corner.
        bubbles(&context, x: 150, y0: st.H * 0.5, y1: st.H - 16, count: 7, seed: 5)
        bubbles(&context, x: 330, y0: st.H * 0.7, y1: st.H - 10, count: 4, seed: 15)
        Art.group(&context, x: 300, y: st.H - 70 * st.far, scale: 0.6 * st.far, opacity: 0.45) { g in
            fish(&g, gold: false)
        }
        let dark: Color = Art.color(0x061C20)
        weed(&context, 44, st.h + 6, count: 5, height: 120 * st.grow, seed: 3, color: dark)
        weed(&context, 130, st.h + 6, count: 3, height: 70 * st.grow, seed: 8, color: dark)
        if st.tall > 0.25 {
            // The deep floor of a tall window: shells, stones and low weed.
            shell(&context, 250, st.h - 90, scale: 1.8, hex: 0x9FC4B4)
            shell(&context, 560, st.h - 60, scale: 2.2, hex: 0xB4D4C4)
            Art.fill(&context, Art.ellipse(380, st.h - 130, 26, 9), Art.color(0x1C504A))
            weed(&context, 470, st.h - 40, count: 4, height: 60, seed: 19, color: Art.color(0x0E3A34))
        }
        Kit.designSpace(&context, st) { v in
            let Hv: CGFloat = st.Hv
            Art.group(&v, x: 706, y: Hv + 14, scale: 0.98) { g in
                palace(&g)
            }
            Art.group(&v, x: 704, y: Hv - 70, scale: 0.6) { g in
                fish(&g, gold: false)
            }
            Kit.nearSpace(&v, st, anchorX: 660) { n in
                palaceDance(&n, st)
            }
            Kit.nearSpace(&v, st, anchorX: 892) { n in
                palaceStep(&n, st)
            }
        }
        weed(&context, 884, st.h + 6, count: 3, height: 56 * st.grow, seed: 23, color: dark)
        ArtStyle.finish(&context, size, wash: 0.05, vignette: 0.16)
    }

    /// The dance: the throne, two river-maidens, the Sea Tsar with one foot up, and the fish
    /// circling him.
    static func palaceDance(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        Art.group(&n, x: 764, y: Hv + 26, scale: 0.8) { g in
            Kit.shadow(&g, 0, 2, width: 110, alpha: 0.35)
            coralThrone(&g)
        }
        Art.group(&n, x: 728, y: Hv + 40, scale: 0.4) { g in
            Kit.shadow(&g, 0, 1, width: 60, alpha: 0.3)
            Kit.person(&g, maidenLook(1), pose: .walk, mouth: .smile)
        }
        Art.group(&n, x: 502, y: Hv + 56, scale: 0.44, scaleX: -1) { g in
            Kit.shadow(&g, 0, 1, width: 60, alpha: 0.3)
            Kit.person(&g, maidenLook(0), pose: .wave, mouth: .smile, mirrored: true)
        }
        Art.glow(&n, 620, Hv - 90, 250, Art.color(0xC9E6A0), alpha: 0.15)
        Art.group(&n, x: 620, y: Hv + 72, scale: 0.95) { g in
            Kit.shadow(&g, -10, 3, width: 190, alpha: 0.4)
            tsarDancing(&g)
        }
        // Fish circling: (x, y from the floor line, turn in degrees, scale, gold fins, mirrored).
        let ring: [(CGFloat, CGFloat, CGFloat, CGFloat, Bool, Bool)] = [
            (506, -150, 24, 0.7, true, false), (748, -214, -20, 0.6, true, true), (552, -30, -12, 0.55, false, false),
            (716, -96, 16, 0.5, false, true), (486, -66, 30, 0.5, true, false),
        ]
        for place in ring {
            let flip: CGFloat = place.5 ? -1 : 1
            Art.group(&n, x: place.0, y: Hv + place.1, rotate: Kit.deg(place.2), scale: place.3, scaleX: flip) { g in
                fish(&g, gold: place.4)
            }
        }
        bubbles(&n, x: 560, y0: Hv - 250, y1: Hv - 120, count: 5, seed: 31)
    }

    /// The lower right: white steps, Sadko small on them in his merchant's coat, playing, and
    /// Chernava standing a little apart with one hand raised.
    static func palaceStep(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let stone: Kit.Stops = [(Art.color(0xE9EEF2), 0), (Art.color(0x9FC4B4), 0.6), (Art.color(0x5E9488), 1)]
        Art.group(&n, x: 870, y: Hv + 80, scale: 0.5) { g in
            Kit.shadow(&g, 0, 1, width: 60, alpha: 0.35)
            Kit.person(&g, chernavaLook(), pose: .reach, look: CGPoint(x: -0.6, y: 0.3), mouth: .flat)
        }
        Art.group(&n, x: 806, y: Hv + 86, scale: 0.52) { g in
            Kit.shadow(&g, 10, 18, width: 190, alpha: 0.35)
            let lower: Path = Art.rect(-70, 0, 170, 18, radius: 3)
            Kit.solid(&g, lower, stops: stone, light: 0.3, shade: 0.3)
            let upper: Path = Art.rect(-22, -34, 96, 34, radius: 3)
            Kit.solid(&g, upper, stops: stone, light: 0.32, shade: 0.3, rim: 1.6)
            sadkoPlaying(&g, merchant: true, look: CGPoint(x: -0.5, y: -0.6))
        }
    }
}
