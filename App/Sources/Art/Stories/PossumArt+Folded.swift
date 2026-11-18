import SwiftUI
import OmramoCore

// The four folded scenes of "Why the Possum's Tail Is Bare": each is its own composition for
// the picture band at the top of a phone (432 wide, 240…520 high), not a crop of the wide scene.
// Possum's face is kept inside x 86…346, clear of the two top controls and of the wave edge.

// MARK: - Shared

extension PossumArt {
    /// The far plane and the ground of a band: sky, the ridges in mist, a far tree line, grass.
    static func foldedBackdrop(_ context: inout GraphicsContext, _ band: Kit.Band, light: Kit.Light, layers: Int, stops: Kit.Stops, seed: UInt32) {
        let u: CGFloat = band.unit
        Kit.sky(&context, band.size, horizon: band.H, light: light)
        Kit.sun(&context, 62, band.H - 34 * u, 13 * u, light: light)
        ridges(&context, width: band.w, horizon: band.H, scale: u * 0.8, light: light, layers: layers)
        Kit.farTrees(&context, x0: -6, x1: 438, baseY: band.H + 3, height: 34 * u, count: 14, color: Art.color(0x6E9A80), seed: seed)
        ArtStyle.atmosphere(&context, width: band.w, top: band.H - 60 * u, bottom: band.H + 4, color: light.haze, alpha: 0.26)
        Kit.ground(&context, width: band.w, top: band.H, bottom: band.h, stops: stops)
        let area = CGRect(x: 0, y: band.H + 8, width: band.w, height: max(1, band.ground - 8))
        Kit.grass(&context, in: area, count: 40, seed: seed &+ 1, color: Art.color(0x3F7A5A, 0.5), height: 7)
        Kit.grass(&context, in: area, count: 40, seed: seed &+ 2, color: Art.color(0xC9E69A, 0.6), height: 6)
    }

    /// A raccoon from the front, head and chest, with the mask (as `Kit.beastBust`).
    static func raccoonBust(_ context: inout GraphicsContext) {
        Kit.beastBust(&context, raccoonLook(), mood: .happy)
        let mask = Kit.faceBoth("M-3,-4 C-6,-13 -21,-14 -26,-5 C-22,4 -8,5 -3,-4Z")
        Art.fill(&context, mask, Art.color(0x2E2A2E, 0.92))
        ArtStyle.eye(&context, -13, -4, 7)
        ArtStyle.eye(&context, 13, -4, 7)
    }
}

// MARK: - Scene 1 folded: Possum combs his plume on the log

extension PossumArt {
    static func woodsFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = morning()
        let u: CGFloat = band.unit
        foldedBackdrop(&context, band, light: light, layers: 5, stops: grassStops(), seed: 71)
        // Middle: a tall trunk on each side, thinning to the sunny gap behind Possum.
        let greens: Kit.Greens = Kit.summerGreens()
        let tallTree: CGFloat = max(130, band.H - 16)
        Kit.tree(&context, x: 418, baseY: band.H + 12, height: tallTree, spread: 170, palette: greens, bark: 0x6B4E40, seed: 7)
        Kit.tree(&context, x: 14, baseY: band.H + 8, height: tallTree * 0.7, spread: 110, palette: greens, bark: 0x7A5A48, seed: 9)
        // The subject.
        let k: CGFloat = u * 0.95
        let seatY: CGFloat = band.H + band.ground * 0.36
        Art.group(&context, x: 226, y: seatY + 44 * k, scale: k) { g in
            mossyLog(&g, length: 236)
        }
        Art.group(&context, x: 232, y: seatY, scale: k) { g in
            Kit.shadow(&g, 6, 0, width: 96)
            possumCombing(&g)
        }
        // Rabbit's ears poke from the ferns at the side.
        Art.group(&context, x: 70, y: seatY + 40 * k, scale: 0.8 * k, scaleX: -1) { g in
            rabbit(&g, pose: .sit, mood: .calm, look: CGPoint(x: -0.7, y: -0.5), mirrored: true)
        }
        fern(&context, x: 52, baseY: seatY + 62 * k, height: 50 * k, seed: 2)
        fern(&context, x: 116, baseY: seatY + 66 * k, height: 44 * k, color: 0x2F7A4A, seed: 3)
        // Near: ferns and dark grass at the trailing foot.
        fern(&context, x: 398, baseY: seatY + 64 * k, height: 54 * k, color: 0x2F6A4A, seed: 4)
        Kit.grassTuft(&context, x: 330, baseY: seatY + 66 * k, height: 30 * k, color: 0x3F7A5A, seed: 5)
        ArtStyle.finish(&context, size)
    }
}

// MARK: - Scene 2 folded: the sleepy face, the wrapped tail, Cricket

extension PossumArt {
    static func combingFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = afternoon()
        let u: CGFloat = band.unit
        foldedBackdrop(&context, band, light: light, layers: 2, stops: grassStops(), seed: 73)
        let greens: Kit.Greens = Kit.summerGreens()
        let tallTree: CGFloat = max(130, band.H - 10)
        Kit.tree(&context, x: 10, baseY: band.H + 10, height: tallTree, spread: 180, palette: greens, bark: 0x7E5E48, seed: 15)
        let laurel: Kit.Greens = Kit.greens(0x1F4A3A, 0x2F6A4A, 0x3F8A5A, 0x6FAE6A, 0xB9DE8A)
        Kit.bush(&context, x: 392, baseY: band.H + 14, width: 120 * u, palette: laurel, seed: 12)
        Kit.bush(&context, x: 150, baseY: band.H + 8, width: 80 * u, palette: laurel, seed: 13)
        // The subject: Possum stretched out, the tail curving across the band below his face.
        let k: CGFloat = u * 1.05
        let feetY: CGFloat = band.H + band.ground * 0.22
        let tail: [CGPoint] = tailFrom(.sleep, CGPoint(x: 50, y: -6), CGPoint(x: 40, y: 44), CGPoint(x: -80, y: 36))
        Art.group(&context, x: 250, y: feetY, scale: k) { g in
            possumAsleep(&g, tail: tail, cricketScale: 0.7)
            Art.group(&g, x: 120, y: 12, scale: 0.8) { f in
                fluff(&f, count: 5, seed: 9)
            }
        }
        // Near: grass at the corners.
        Kit.grassTuft(&context, x: 40, baseY: band.floor + 8, height: 34 * u, color: 0x3F7A5A, seed: 6)
        Kit.grassTuft(&context, x: 410, baseY: band.floor + 6, height: 30 * u, color: 0x2F6A4A, seed: 7)
        ArtStyle.finish(&context, size)
    }
}

// MARK: - Scene 3 folded: Possum steps into the ring

extension PossumArt {
    static func danceFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = evening()
        let u: CGFloat = band.unit
        foldedBackdrop(&context, band, light: light, layers: 2, stops: eveningGrassStops(), seed: 75)
        Kit.farTrees(&context, x0: -6, x1: 438, baseY: band.H + 5, height: 22 * u, count: 20, color: Art.color(0x5B8A6A), seed: 18)
        let ring = Art.ellipse(216, band.H + band.ground * 0.55, 230, band.ground * 0.4)
        Art.fill(&context, ring, Art.color(0xE6E9B0, 0.28))
        let k: CGFloat = u
        let feetY: CGFloat = band.H + band.ground * 0.42
        // Behind: a curve of animal faces, paler with distance.
        Art.layer(&context, opacity: 0.9) { g in
            Art.group(&g, x: 150, y: band.H + 8, scale: 0.34 * k, scaleX: -1) { s in
                Kit.beast(&s, squirrelLook(), pose: .sit, mood: .happy, mirrored: true)
            }
            Art.group(&g, x: 286, y: band.H + 8, scale: 0.34 * k) { s in
                Kit.beast(&s, squirrelLook(), pose: .sit, mood: .happy)
            }
            Art.group(&g, x: 92, y: feetY - 92 * k, scale: 0.66 * k) { d in
                Kit.beastBust(&d, deerLook(), mood: .happy, look: CGPoint(x: 0.6, y: 0.2))
            }
        }
        Art.group(&context, x: 350, y: feetY - 88 * k, scale: 0.78 * k) { b in
            Kit.beastBust(&b, bearLook(), mood: .happy, look: CGPoint(x: -0.6, y: 0.2))
        }
        // The subject, mid-step, the red-wrapped tail behind him.
        Kit.shadow(&context, 214, feetY, width: 84 * k)
        Art.group(&context, x: 212, y: feetY, scale: k) { g in
            possumDancing(&g)
        }
        // Near: Rabbit and a Raccoon rise from the foot of the band.
        Art.group(&context, x: 44, y: feetY - 18 * k, scale: 0.6 * k) { r in
            Kit.beastBust(&r, rabbitLook(), mood: .sly, look: CGPoint(x: 0.7, y: -0.2))
        }
        Art.group(&context, x: 398, y: feetY - 4 * k, scale: 0.6 * k) { r in
            raccoonBust(&r)
        }
        ArtStyle.finish(&context, size)
    }
}

// MARK: - Scene 4 folded: the upside-down grin

extension PossumArt {
    static func grinFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = evening()
        let u: CGFloat = band.unit
        foldedBackdrop(&context, band, light: light, layers: 2, stops: eveningGrassStops(), seed: 77)
        Kit.farTrees(&context, x0: -6, x1: 438, baseY: band.H + 5, height: 22 * u, count: 20, color: Art.color(0x5B8A6A), seed: 19)
        let s: CGFloat = 1.3 * u
        let cy: CGFloat = band.H + band.ground * 0.2
        // Friendly faces look down from the edges.
        Art.layer(&context, opacity: 0.92) { g in
            Art.group(&g, x: 150, y: cy - 76 * s, scale: 0.5 * s) { d in
                Kit.beastBust(&d, deerLook(), mood: .happy, look: CGPoint(x: 0.5, y: 0.6))
            }
        }
        Art.group(&context, x: 366, y: cy - 58 * s, scale: 0.62 * s) { b in
            Kit.beastBust(&b, bearLook(), mood: .proud)
        }
        Art.group(&context, x: 62, y: cy - 40 * s, scale: 0.6 * s) { r in
            Kit.beastBust(&r, rabbitLook(), mood: .calm, look: CGPoint(x: 0.2, y: -1))
        }
        // The subject: Possum seen from his head end, flat on his back.
        Art.group(&context, x: 216, y: cy, scale: s) { g in
            possumFromHeadEnd(&g)
        }
        Art.group(&context, x: 306, y: cy + 8 * s, scale: 0.7 * s) { f in
            looseString(&f)
        }
        Art.group(&context, x: 120, y: cy + 10 * s, scale: 0.7 * s) { f in
            fluff(&f, count: 5, seed: 5)
        }
        Art.group(&context, x: 412, y: cy + 4 * s, scale: 0.5 * s) { r in
            raccoonBust(&r)
        }
        ArtStyle.finish(&context, size)
    }

    /// Possum on his back seen from the head end: his upside-down grinning face at the origin
    /// (60 across), the round belly behind it, four pink paws in the air and the bare tail in
    /// a curl above. Runs from about y −140 to y +36.
    static func possumFromHeadEnd(_ context: inout GraphicsContext) {
        let spec: Kit.Beast = possumLook()
        Kit.shadow(&context, 2, 26, width: 140)
        let tail: [CGPoint] = tailLine(CGPoint(x: 18, y: -80), CGPoint(x: 70, y: -84), CGPoint(x: 88, y: -134), CGPoint(x: 50, y: -124))
        cord(&context, tail, wrapped: false)
        // The hind paws, farther away.
        let far: Color = Kit.beastTone(spec.body, 0.8)
        Art.stroke(&context, Art.svg("M-40,-66 C-44,-78 -42,-86 -46,-94 M40,-66 C44,-78 42,-86 46,-94"), far, width: 12)
        pinkPaw(&context, -46, -97, 6)
        pinkPaw(&context, 46, -97, 6)
        var torso = Path()
        torso.addEllipse(in: CGRect(x: -58, y: -84, width: 116, height: 76))
        torso.addEllipse(in: CGRect(x: -44, y: -40, width: 88, height: 50))
        Art.fill(&context, torso, Art.color(spec.body))
        let bellyColor: Color = Art.color(spec.belly)
        Art.clipped(&context, to: torso) { g in
            Art.fill(&g, Art.ellipse(0, -58, 40, 26), bellyColor)
        }
        Kit.model(&context, torso, light: 0.24, shade: 0.24)
        // The front paws, curled over his chest.
        let coat: Color = Art.color(spec.body)
        Art.stroke(&context, Art.svg("M-34,-40 C-40,-52 -34,-60 -38,-68 M34,-40 C40,-52 34,-60 38,-68"), coat, width: 13)
        pinkPaw(&context, -38, -71, 7)
        pinkPaw(&context, 38, -71, 7)
        Art.group(&context, rotate: CGFloat.pi) { f in
            possumFace(&f, mood: .happy, grin: true)
        }
    }
}
