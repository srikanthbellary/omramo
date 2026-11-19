import SwiftUI
import OmramoCore

// The four scenes of "The Tiger, the Brahman and the Jackal" as the picture band of a folded
// phone: 432 units wide and about 240…520 high. Each is its own composition for the band, not
// a crop of the wide scene: the subject's face inside x 86…346 and above the wave edge, the
// flat far plain on the band's horizon, a pale sky above for the words. The cast and the
// story's parts come from `TigerArt+Cast.swift`, placed in the band's own units and scaled by
// `band.unit`.

// MARK: - The plain behind every band

extension TigerArt {
    /// Sky, the flat far plain, the earth and a thin strip of far fields, for a band.
    static func bandPlain(_ context: inout GraphicsContext, _ size: CGSize, band: Kit.Band, light: Kit.Light, seed: UInt32) {
        let w = size.width
        let h = size.height
        let u = band.unit
        let H = band.H
        Kit.sky(&context, size, horizon: H, light: light)
        farPlain(&context, width: w, horizon: H, scale: 0.8 * u, light: light, seed: seed)
        let earth: Kit.Stops = [(Art.color(0xE6D49E), 0), (Art.color(0xDABF86), 0.5), (Art.color(0xC9A466), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: earth, tooth: Art.color(0xFFF6D8))
        fields(&context, x0: 0, x1: w, top: H, bottom: H + band.ground * 0.32, mustardFirst: true, seed: seed &+ 7)
    }
}

// MARK: - scene-cage (folded)

extension TigerArt {
    /// scene-cage (folded): the trap close up, the Tiger's broad face behind the bamboo bars
    /// in the middle of the band, and the Brahman at the leading side looking at him; a
    /// kikar behind on the trailing edge, pale cream-gold sky above.
    static func cageFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u = band.unit
        let H = band.H
        let light = midday()
        bandPlain(&context, size, band: band, light: light, seed: 13)
        Kit.cloud(&context, 300, max(40, H - 150 * u), scale: 0.5 * u, color: Art.color(0xFFFCEF, 0.55))
        Kit.acacia(&context, x: 404, baseY: H + 8 * u, height: 210 * u, spread: 190 * u, palette: kikarGreens(), bark: 0x3E3028)
        Kit.acacia(&context, x: 40, baseY: H + 2 * u, height: 70 * u, spread: 80 * u, palette: kikarGreens(), bark: 0x5A4A38)
        let roadTop: CGFloat = H + band.ground * 0.32
        dust(&context, in: CGRect(x: 0, y: roadTop, width: w, height: max(1, band.floor - roadTop)), seed: 15)

        // The trap: its foot a little under the horizon, the Tiger's face at about x 240.
        let k: CGFloat = 1.3 * u
        let cageX: CGFloat = 240 + 30 * k
        let cageY: CGFloat = H + 20 * u
        Art.group(&context, x: cageX, y: cageY, scale: k) { c in
            cagedTiger(&c, mood: .sad, look: CGPoint(x: -0.9, y: 0.1))
        }
        // The Brahman, turned to the Tiger, his face level with the Tiger's.
        let s: CGFloat = 1.25 * u
        let faceY: CGFloat = cageY - 117 * k
        let feetY: CGFloat = min(band.floor + 10, faceY + 140 * s)
        Kit.shadow(&context, 96, feetY, width: 60 * s)
        Art.group(&context, x: 92, y: feetY, scale: s, scaleX: -1) { b in
            brahman(&b, pose: .stand, look: CGPoint(x: -0.8, y: 0), mouth: .flat, mirrored: true)
        }
        Kit.grassTuft(&context, x: 186, baseY: cageY + 4 * u, height: 22 * u, color: 0xA8963F, seed: 4)
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x6A6A30), scale: 0.8 * u, seed: 8)
        ArtStyle.finish(&context, size)
    }
}

// MARK: - scene-pipal (folded)

extension TigerArt {
    /// scene-pipal (folded): the Brahman in the middle with his head tilted up, the pale grey
    /// ribbed trunk on its platform beside him, a fringe of long-tipped heart leaves across
    /// the top of the band with pale morning sky between the leaves.
    static func pipalFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u = band.unit
        let H = band.H
        let light = morning()
        bandPlain(&context, size, band: band, light: light, seed: 19)
        Kit.sun(&context, 60, H - 24 * u, 12 * u, light: light)
        // The trunk on the trailing side, going up out of the band into the crown.
        let girth: CGFloat = 34 * u
        let trunkX: CGFloat = 352
        pipalTrunk(&context, x: trunkX, baseY: H + 22 * u, topY: 40 * u, girth: girth)
        pipalPlatform(&context, x: trunkX, topY: H + 8 * u, width: 190 * u, height: 20 * u)
        // The pool of shade on the bare earth under the tree.
        ArtStyle.contactShadow(&context, 250, H + band.ground * 0.5, 190 * u, 22 * u, alpha: 0.2)
        // The Brahman, small under the tree, looking up into the leaves.
        let s: CGFloat = 1.05 * u
        let feetY: CGFloat = H + band.ground * 0.45
        Kit.shadow(&context, 204, feetY, width: 60 * s)
        Art.group(&context, x: 200, y: feetY, scale: s, scaleX: -1) { b in
            brahman(&b, pose: .stand, look: CGPoint(x: -0.3, y: -1), mouth: .open, mirrored: true)
        }
        pipalFringe(&context, unit: u)
        Kit.grassTuft(&context, x: 120, baseY: feetY + 10 * u, height: 22 * u, color: 0x8FA64E, seed: 6)
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x55783A), scale: 0.75 * u, seed: 3)
        ArtStyle.finish(&context, size)
    }

    /// The crown along the top edge of a band: clumps on the trailing half, a fringe of single
    /// hanging leaves across the whole width (fewer and smaller toward the leading side, so
    /// pale sky shows between them), and a parakeet on a twig.
    static func pipalFringe(_ context: inout GraphicsContext, unit u: CGFloat) {
        let blobs: [Kit.Blob] = [
            (250, -22 * u, 46 * u), (320, -6 * u, 54 * u), (396, -14 * u, 60 * u),
            (440, 30 * u, 44 * u), (190, -34 * u, 40 * u),
        ]
        Kit.canopy(&context, blobs, seed: 9, palette: pipalGreens(), density: 1.6)
        let fringe: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (36, -6 * u, 22 * u, 8), (88, 2 * u, 26 * u, -6), (142, 8 * u, 28 * u, 10),
            (196, 16 * u, 30 * u, -4), (262, 30 * u, 32 * u, 6), (330, 44 * u, 32 * u, -8),
            (396, 64 * u, 30 * u, 4), (230, 4 * u, 26 * u, 12),
        ]
        pipalLeaves(&context, fringe)
        let twigY: CGFloat = 60 * u
        Art.stroke(&context, Art.line(270, twigY - 10 * u, 330, twigY), Kit.treeTone(pipalBarkHex, 0.8), width: 2.4 * u)
        parakeet(&context, x: 300, y: twigY - 4 * u, scale: 0.8 * u)
    }
}

// MARK: - scene-well (folded)

extension TigerArt {
    /// scene-well (folded): the old buffalo's head and swept-back horns in the middle, the
    /// wooden wheel and its clay pots behind her, the Brahman's face at the leading side, the
    /// pale morning sky above.
    static func wellFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u = band.unit
        let H = band.H
        let light = morning()
        bandPlain(&context, size, band: band, light: light, seed: 25)
        Kit.cloud(&context, 110, max(40, H - 160 * u), scale: 0.45 * u, color: Art.color(0xFFFCEF, 0.55))
        ditch(&context, x0: w + 4, y0: H + band.ground * 0.36, x1: -4, y1: H + 8 * u, near: 8 * u, far: 3 * u)
        // The wheel behind her.
        let kw: CGFloat = 1.15 * u
        let wheelY: CGFloat = H + 10 * u
        Art.group(&context, x: 330, y: wheelY, scale: kw) { c in
            wellWheel(&c)
        }
        // The buffalo, her eye at about x 236, her body running off the trailing edge.
        let kb: CGFloat = 1.25 * u
        let bx: CGFloat = 236 + 124 * kb
        let by: CGFloat = H + band.ground * 0.42
        ArtStyle.contactShadow(&context, bx + 30 * kb, by + 2, 130 * kb, 10 * kb, alpha: 0.22)
        Art.group(&context, x: bx, y: by, scale: kb) { b in
            buffalo(&b, look: CGPoint(x: -0.6, y: 0.1))
            yoke(&b, toX: -70, toY: -116)
        }
        // The Brahman at the leading side, turned to her.
        let s: CGFloat = 1.05 * u
        let feetY: CGFloat = min(band.floor + 8, H + band.ground * 0.55)
        Kit.shadow(&context, 96, feetY, width: 60 * s)
        Art.group(&context, x: 92, y: feetY, scale: s, scaleX: -1) { p in
            brahman(&p, pose: .wave, look: CGPoint(x: -0.7, y: 0.1), mouth: .open, mirrored: true)
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x6E7A38), scale: 0.7 * u, seed: 4)
        ArtStyle.finish(&context, size)
    }
}

// MARK: - scene-road (folded)

extension TigerArt {
    /// scene-road (folded): the Jackal in the middle of the pale road looking up with his
    /// head on one side, the Brahman above him at the trailing side, mustard flowers low in
    /// the band, the tiny village far off and a pale gold late-afternoon sky.
    static func roadFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let band = Kit.band(size, share: 0.32, least: 76, most: 160)
        let u = band.unit
        let H = band.H
        let light = afternoon()
        bandPlain(&context, size, band: band, light: light, seed: 31)
        farVillage(&context, x: 80, baseY: H + 1, scale: 0.6 * u, light: light)
        kite(&context, x: 300, y: max(70, H - 170 * u), scale: 0.8 * u)
        let low: CGFloat = H + band.ground * 0.32
        cropField(&context, in: CGRect(x: 0, y: low, width: w, height: max(1, h - low)), mustard: true, seed: 33)
        road(&context, nearX: 230, nearY: h, nearWidth: 300, farX: 250, farY: H + 2, farWidth: 6)
        dust(&context, in: CGRect(x: 120, y: low, width: 240, height: max(1, band.floor - low)), seed: 35)
        // The Brahman, leaning on his staff, looking down at the Jackal.
        let s: CGFloat = 1.15 * u
        let feetY: CGFloat = H + band.ground * 0.5
        ArtStyle.contactShadow(&context, 350, feetY + 2, 50 * s, 5 * s, alpha: 0.18)
        Kit.shadow(&context, 324, feetY, width: 64 * s)
        Art.group(&context, x: 320, y: feetY, scale: s) { b in
            brahman(&b, pose: .stand, look: CGPoint(x: -0.5, y: 0.8), mouth: .smile)
        }
        // The Jackal, his head on one side, looking up at him.
        let kj: CGFloat = 1.0 * u
        let jy: CGFloat = min(band.floor + 4, H + band.ground * 0.56)
        Kit.shadow(&context, 206, jy, width: 100 * kj)
        Art.group(&context, x: 206, y: jy, rotate: Kit.deg(4), scale: kj, scaleX: -1) { j in
            jackal(&j, pose: .stand, mood: .happy, look: CGPoint(x: -0.4, y: -0.9), mirrored: true)
        }
        Kit.flowers(&context, in: CGRect(x: 0, y: band.floor - 40 * u, width: 120, height: 36 * u), count: 10, seed: 37, petal: mustardHex)
        Kit.flowers(&context, in: CGRect(x: 330, y: band.floor - 36 * u, width: 100, height: 32 * u), count: 9, seed: 39, petal: mustardHex)
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x8A7A2E), scale: 0.7 * u, seed: 6)
        ArtStyle.finish(&context, size)
    }
}
