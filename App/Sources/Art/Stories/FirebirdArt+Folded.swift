import SwiftUI
import OmramoCore

// "The Fire-Bird and the Horse of Power": the four folded scenes, each its own composition
// for the dark picture band at the top of a phone (432 wide, 240…520 high). The subject
// glows in the lower middle; the dark sky above holds the words' calm.

extension FirebirdArt {
    // MARK: Forest

    /// The archer leaning from the saddle toward the glowing feather, black spruces behind.
    static func forestFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let light = night()
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.stars(&context, width: w, maxY: band.H - 80 * u, count: 40, seed: 12)
        Kit.farTrees(&context, x0: -10, x1: 440, baseY: band.H + 4, height: 56 * u, count: 26, color: Art.color(0x101E2A), conifer: true, seed: 5)
        ArtStyle.atmosphere(&context, width: w, top: band.H - 50 * u, bottom: band.H + 4, color: light.haze, alpha: 0.35)
        Kit.ground(&context, width: w, top: band.H, bottom: size.height, stops: Kit.stops(0x14221A, 0x0A130E), seed: 22)
        let spruce = nightSpruce()
        Kit.conifer(&context, x: 34, baseY: band.H + 16 * u, height: 210 * u, palette: spruce, seed: 41)
        Kit.conifer(&context, x: 404, baseY: band.H + 20 * u, height: 230 * u, palette: spruce, seed: 43)
        Kit.birch(&context, x: 70, baseY: band.H + 8 * u, height: 110 * u, palette: nightBirch(), seed: 6)
        let path: Kit.Stops = [(Art.color(0x2E2618), 0), (Art.color(0x3A2E1C), 1)]
        Kit.ribbon(&context, nearX: 220, nearY: size.height + 10, nearWidth: 200, farX: 200, farY: band.H + 2, farWidth: 20, stops: path)
        let feetY: CGFloat = band.H + 30 * u
        let k: CGFloat = 0.5 * u
        let featherX: CGFloat = 250 - 190 * k
        Art.glow(&context, featherX, feetY - 30 * u, 150 * u, Art.color(fireAmber), alpha: 0.32)
        Art.group(&context, x: 250, y: feetY, scale: k) { h in
            horse(&h, bend: 12, warm: CGPoint(x: -190, y: -60), warmAlpha: 0.55)
            rider(&h, lean: 30, look: CGPoint(x: -0.6, y: 0.9))
            Art.glow(&h, -45, -232, 40, Art.color(fireAmber), alpha: 0.35)
        }
        Art.group(&context, x: featherX, y: feetY - 3 * u, scale: 0.6 * u) { f in
            feather(&f)
        }
        Kit.grassTuft(&context, x: 30, baseY: band.floor + 10, height: 40 * u, color: 0x1E3A2A, seed: 9)
        Kit.grassTuft(&context, x: 400, baseY: band.floor + 12, height: 46 * u, color: 0x1A3426, seed: 10)
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.16)
    }

    // MARK: Palace

    /// The old tsar on his carved chair gazing into the golden cage, dark beams above.
    static func palaceFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: band.H, light: hall())
        Art.layer(&context, opacity: 0.5) { logs in
            Kit.builtLogs(&logs, rect: CGRect(x: 0, y: 0, width: w, height: band.H), color: logMid)
        }
        let dusk: Kit.Stops = [(Art.color(0x0C0705, 0.94), 0), (Art.color(0x140B07, 0.6), 0.55), (Art.color(0x1A0F0A, 0), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, band.H), dusk, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: band.H))
        var beams = Path()
        beams.addPath(Art.rect(0, 22, w, 12))
        beams.addPath(Art.rect(0, 70, w, 10))
        Art.fill(&context, beams, Art.color(0x0A0604, 0.7))
        let floor: Kit.Stops = [(Art.color(0x4A2C18), 0), (Art.color(0x2A170C), 0.6), (Art.color(0x1A0E08), 1)]
        Kit.ground(&context, width: w, top: band.H, bottom: size.height, stops: floor, seed: 24)
        let floorY: CGFloat = band.H + 20 * u
        let s: CGFloat = 0.7 * u
        Art.group(&context, x: 34, y: band.H + 4, scale: 0.8 * u) { p in
            carvedPost(&p, height: band.H / (0.8 * u) + 10)
        }
        Art.group(&context, x: 418, y: floorY - 4, scale: 0.62 * u) { st in
            stove(&st)
        }
        Art.glow(&context, 170, floorY - 90 * u, 190 * u, Art.color(fireAmber), alpha: 0.34)
        let stand: Path = Art.svg("M-22,0 L-14,-12 L-8,-50 L-26,-58 L26,-58 L8,-50 L14,-12 L22,0Z")
        Art.group(&context, x: 160, y: floorY + 2 * u, scale: s) { c in
            Kit.shadow(&c, 0, 0, width: 60)
            Kit.solid(&c, stand, stops: Kit.stops(0x7A4626, 0x3A2010), light: 0.3, shade: 0.3, rim: 1.2)
            Art.group(&c, x: 0, y: -58) { cg in
                cage(&cg)
            }
        }
        Art.group(&context, x: 268, y: floorY, scale: s * 1.1) { t in
            tsarSeated(&t, look: CGPoint(x: -0.8, y: 0.1), mouth: .oh)
        }
        Kit.lamp(&context, cx: 96, cy: floorY - 70 * u, radius: 2.6 * u, color: 0xFFC96B)
        Art.stroke(&context, Art.line(96, floorY - 62 * u, 96, floorY), Art.color(0x2A2220), width: 2)
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.18)
    }

    // MARK: Sea

    /// The gold-roofed tent and the dark horse on the pale sand, the silver boat small on
    /// the sea behind, grey midnight above.
    static func seaFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let light = whiteNight()
        Kit.sky(&context, size, horizon: band.H, light: light)
        let starY: CGFloat = max(60, band.H - 170 * u)
        Art.glow(&context, 300, starY, 7, Art.color(0xF2EEE2), alpha: 0.35)
        Art.fill(&context, Art.circle(300, starY, 1.2), Art.color(0xF2EEE2, 0.8))
        let sea: Kit.Stops = [(Art.color(0x3A4456), 0), (Art.color(0x222C3C), 0.4), (Art.color(0x141C28), 1)]
        Kit.water(&context, width: w, top: band.H, bottom: size.height, stops: sea, light: light, ripples: 24, seed: 10)
        var sand = Path()
        sand.move(to: CGPoint(x: w, y: band.H + 4 * u))
        sand.addQuadCurve(to: CGPoint(x: 150, y: band.H + 20 * u), control: CGPoint(x: 260, y: band.H + 4 * u))
        sand.addQuadCurve(to: CGPoint(x: 60, y: size.height), control: CGPoint(x: 90, y: band.H + 60 * u))
        sand.addLine(to: CGPoint(x: w, y: size.height))
        sand.closeSubpath()
        Kit.solid(&context, sand, stops: Kit.stops(0xBDB4A2, 0x8E8676, 0x5E584E), light: 0.18, shade: 0.24)
        Art.group(&context, x: 96, y: band.H + 16 * u, scale: 0.42 * u) { b in
            vasilissaBoat(&b)
        }
        Art.group(&context, x: 200, y: band.H + 26 * u, scale: 0.6 * u) { t in
            tent(&t)
        }
        Art.group(&context, x: 334, y: band.H + 36 * u, scale: 0.38 * u) { h in
            horse(&h, bend: 18, warm: CGPoint(x: -220, y: -110), warmAlpha: 0.2)
        }
        Kit.rock(&context, cx: 410, baseY: band.H + 50 * u, width: 50 * u, height: 26 * u, color: 0x3E444C, seed: 25)
        Art.group(&context, x: 120, y: band.floor - 4, scale: 0.22 * u) { c in
            crab(&c)
        }
        ArtStyle.finish(&context, size, wash: 0.04, vignette: 0.14)
    }

    // MARK: Cauldron

    /// The horse bending his head to breathe on the steaming cauldron, the archer beside
    /// him at the rim, torchlight on both.
    static func cauldronFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: band.H, light: courtyard())
        Kit.stars(&context, width: w, maxY: band.H - 120 * u, count: 16, seed: 32, color: Art.color(0xE6DCC8))
        Art.layer(&context, opacity: 0.6) { far in
            Kit.house(&far, cx: 60, baseY: band.H + 4, width: 120 * u, wallHeight: 50 * u, roofHeight: 60 * u, wall: logMid, roof: 0x3A2A22, style: .plank, door: 0x1A0F0A, windows: 1, lit: true, timber: logLit)
            Art.group(&far, x: 392, y: band.H + 6, scale: u) { t in
                woodTower(&t, width: 60, height: 190, roof: 0x3A2A22, lit: false)
            }
        }
        let yard: Kit.Stops = [(Art.color(0x3A2418), 0), (Art.color(0x22140E), 0.5), (Art.color(0x120A08), 1)]
        Kit.ground(&context, width: w, top: band.H, bottom: size.height, stops: yard, seed: 26)
        Art.group(&context, x: 30, y: band.H + 24 * u, scale: 0.5 * u) { t in
            torch(&t, height: 140)
        }
        Art.group(&context, x: 210, y: band.H + 30 * u, scale: 0.55 * u) { c in
            Art.group(&c, scaleX: -1) { m in
                cauldron(&m, steam: 0.75)
            }
        }
        Art.group(&context, x: 118, y: band.H + 34 * u, scale: 0.6 * u) { a in
            Kit.shadow(&a, 0, 0, width: 70)
            Art.group(&a, scaleX: -1) { m in
                archer(&m, pose: .stand, look: CGPoint(x: -0.6, y: 0.3), mouth: .flat, mirrored: true)
            }
            Art.glow(&a, 6, -140, 36, Art.color(0xFF9A3C), alpha: 0.3)
        }
        Art.group(&context, x: 340, y: band.H + 10 * u, scale: 0.5 * u) { h in
            horse(&h, bend: 30, saddled: false, warm: CGPoint(x: -170, y: -100), warmAlpha: 0.45)
        }
        ArtStyle.finish(&context, size, wash: 0.03, vignette: 0.2)
    }
}
