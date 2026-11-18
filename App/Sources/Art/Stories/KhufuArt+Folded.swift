import SwiftUI
import OmramoCore

// The four folded scenes of "King Khufu and the Magician": each its own composition for the
// picture band at the top of a phone (432 wide, 240…520 high), and the two back views of the
// terrace (the king and Dedi seen from behind, looking out at the tomb).

// MARK: - Folded: the hall of columns

extension KhufuArt {
    /// King Khufu on his chair between two painted columns, chin on his fist; Prince Hordedef's
    /// head and shoulder low at the leading side; the pale sky and the river through the open
    /// side above.
    static func courtFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let light = day()
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: band.H, light: light)
        Kit.cloud(&context, 300, band.H - 120 * u, scale: 0.5 * u, color: Color.white.opacity(0.45))
        let sill: CGFloat = band.H - 8 * u
        let bankY: CGFloat = sill - 12 * u
        farBank(&context, width: w, y: bankY, scale: 0.6 * u, light: light, seed: 17)
        Art.fillLinear(&context, Art.rect(0, bankY, w, sill - bankY), waterStops(), from: CGPoint(x: 0, y: bankY), to: CGPoint(x: 0, y: sill))
        Art.fill(&context, Art.rect(0, sill, w, band.H - sill), Art.color(0xEFE3C6))
        Art.fill(&context, Art.rect(0, sill, w, 1.5), Color.white.opacity(0.6))
        hallFloor(&context, size, top: band.H)
        Art.fill(&context, Art.rect(0, 0, w, 12 * u), Art.color(0xE9DBB8))
        Art.fill(&context, Art.rect(0, 12 * u, w, 3), ArtStyle.coolShade.opacity(0.08))
        let colBase: CGFloat = band.H + 16 * u
        let posts: [CGFloat] = [40, 392]
        for x in posts {
            hallColumn(&context, x: x, baseY: colBase, width: 22 * u, height: colBase - 10 * u)
        }
        let k: CGFloat = u * 1.3
        let seat: CGFloat = band.H + 22 * u
        reedMat(&context, cx: 236, y: seat + 2 * k, width: 260 * k, depth: 40 * k)
        Art.group(&context, x: 246, y: seat, scale: k) { g in
            throne(&g)
            king(&g, pose: .chin)
        }
        // The prince, nearer, cut by the foot of the band, turned to his father.
        let pk: CGFloat = k * 1.15
        Art.group(&context, x: 96, y: size.height + 10 * u, scale: pk, scaleX: -1) { g in
            prince(&g, pose: .stand, mouth: .open, mirrored: true)
        }
        ArtStyle.finish(&context, size)
    }
}

// MARK: - Folded: Dedi at his door

extension KhufuArt {
    /// Old Dedi sitting up on his couch of palm sticks before his door, smiling, a servant at
    /// his feet; the prince's boat small on the river at the leading side; pale sky above.
    static func riverFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.34, least: 80, most: 170)
        let light = day()
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = band.H
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 110, H - 130 * u, scale: 0.5 * u, color: Color.white.opacity(0.45))
        farBank(&context, width: w, y: H, scale: 0.7 * u, light: light, seed: 29)
        Kit.water(&context, width: w, top: H, bottom: h, stops: waterStops(), light: light, ripples: 18, seed: 4)
        Art.group(&context, x: 64, y: H + 16 * u, scale: 0.32 * u) { g in
            riverBoat(&g, rowers: 5)
        }
        // The near bank, from the middle of the band to the trailing edge.
        var edge = Path()
        edge.move(to: CGPoint(x: 100, y: h))
        edge.addLine(to: CGPoint(x: 130, y: H + 30 * u))
        edge.addQuadCurve(to: CGPoint(x: 200, y: H + 6 * u), control: CGPoint(x: 146, y: H + 10 * u))
        edge.addLine(to: CGPoint(x: w + 4, y: H + 3 * u))
        var bank: Path = edge
        bank.addLine(to: CGPoint(x: w + 4, y: h))
        bank.closeSubpath()
        let earth: Kit.Stops = [(Art.color(0xD9C192), 0), (Art.color(0xC4A672), 0.4), (Art.color(0xAE8F5E), 1)]
        Art.fillLinear(&context, bank, earth, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: h))
        Art.stroke(&context, edge, Art.color(0x8A7350, 0.8), width: 3)
        let k: CGFloat = u * 1.5
        let base: CGFloat = H + band.ground * 0.42
        Art.group(&context, x: 226, y: base, scale: k) { g in
            Kit.palm(&g, x: -96, baseY: -40, height: 170, lean: -14, fronds: 0x5E8F4E, trunk: 0x8A6A48, seed: 3)
            mudHouse(&g, cx: 32, baseY: -6, width: 200, height: 150)
            couch(&g, length: 120)
            Art.group(&g, x: -10, y: 0) { d in
                dedi(&d, pose: .sit, mouth: .smile)
            }
            Kit.shadow(&g, -78, 5, width: 56)
            Art.group(&g, x: -78, y: 4, scaleX: -1) { s in
                courtier(&s, kind: 0, pose: .kneel, mouth: .smile, mirrored: true)
            }
        }
        Kit.reeds(&context, x: 108, baseY: h - 20, count: 4, height: 60 * u, seed: 7, color: 0x4F7F4A, papyrus: true)
        ArtStyle.finish(&context, size)
    }
}

// MARK: - Folded: the goose made whole

extension KhufuArt {
    /// Dedi in the middle with his staff raised, the whole goose cackling at his feet, and the
    /// astonished king behind his shoulder; the pale sunlit wall above.
    static func magicFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.3, least: 70, most: 150)
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let H: CGFloat = band.H
        let plaster: Kit.Stops = [(Art.color(0xFAF3E2), 0), (Art.color(plasterHex), 0.6), (Art.color(0xEEDFBE), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, H), plaster, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        Art.glow(&context, 90, H * 0.45, 260 * u, Art.color(0xFFF6DE), alpha: 0.55)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: H), seed: 64, alpha: 0.05)
        let fall: Path = Art.polygon([
            CGPoint(x: 56, y: 0), CGPoint(x: 86, y: 0), CGPoint(x: 128, y: H), CGPoint(x: 96, y: H),
        ])
        Art.fill(&context, fall, ArtStyle.coolShade.opacity(0.045))
        dado(&context, x0: 0, x1: w, y: H - 22 * u, height: 22 * u)
        Art.fill(&context, Art.rect(0, 0, w, 12 * u), Art.color(0xE9DBB8))
        Art.fill(&context, Art.rect(0, 12 * u, w, 3), ArtStyle.coolShade.opacity(0.08))
        hallFloor(&context, size, top: H)
        let colBase: CGFloat = H + 14 * u
        hallColumn(&context, x: 404, baseY: colBase, width: 20 * u, height: colBase - 10 * u)
        reedMat(&context, cx: 230, y: H + 10 * u, width: 360 * u, depth: band.ground * 0.6)
        let k: CGFloat = u * 1.2
        Art.group(&context, x: 316, y: H + 12 * u, scale: k) { g in
            throne(&g)
            king(&g, pose: .amazed)
        }
        let dk: CGFloat = k * 1.35
        let feet: CGFloat = H + band.ground * 0.55
        Art.group(&context, x: 96, y: feet + 6 * u, scale: dk) { g in
            linenCloth(&g)
        }
        Kit.shadow(&context, 176, feet + 1, width: 46 * dk)
        Art.group(&context, x: 176, y: feet, scale: dk, scaleX: -1) { g in
            dedi(&g, pose: .cast, mouth: .smile, mirrored: true)
        }
        let gk: CGFloat = dk * 0.78
        let gooseY: CGFloat = H + band.ground * 0.6
        Kit.shadow(&context, 252, gooseY + 1, width: 50 * gk)
        Art.group(&context, x: 252, y: gooseY, scale: gk, scaleX: -1) { g in
            goose(&g, cackling: true, mirrored: true)
        }
        ArtStyle.finish(&context, size, wash: 0.1, vignette: 0.08)
    }
}

// MARK: - Folded: the terrace

extension KhufuArt {
    /// The king and Dedi from behind on the terrace, one tall and broad, one tiny on his staff,
    /// the half-built pyramid small between them beyond the fields; pale-gold sky above.
    static func pyramidFolded(_ context: inout GraphicsContext, _ size: CGSize) {
        let band = Kit.band(size, share: 0.32, least: 76, most: 160)
        let light = afternoon()
        let u: CGFloat = band.unit
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let H: CGFloat = band.H
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 330, H - 140 * u, scale: 0.45 * u, color: Color.white.opacity(0.4))
        cliffs(&context, width: w, baseY: H - 2 * u, height: 14 * u, color: light.far.opacity(0.7), seed: 5)
        let sandTop: CGFloat = H - 4 * u
        let sandBottom: CGFloat = H + 8 * u
        let sand: Kit.Stops = [(Art.color(0xF1DDAE), 0), (Art.color(0xE4C68E), 1)]
        Art.fillLinear(&context, Art.rect(0, sandTop, w, sandBottom - sandTop), sand, from: CGPoint(x: 0, y: sandTop), to: CGPoint(x: 0, y: sandBottom))
        Art.group(&context, x: 196, y: H, scale: 0.55 * u) { g in
            pyramidSite(&g)
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 70 * u, bottom: H + 6 * u, color: light.haze, alpha: 0.28)
        let fieldTop: CGFloat = H + 6 * u
        Kit.ground(&context, width: w, top: fieldTop, bottom: h, stops: fieldStops(), seed: 8)
        Kit.crop(&context, x0: 0, x1: w, baseY: fieldTop + 12 * u, height: 6 * u, tops: false, color: 0xB4B86A, seed: 2)
        // The parapet of the terrace and the whitewashed floor before it.
        let wallTop: CGFloat = H + band.ground * 0.3
        let wallH: CGFloat = 24 * u
        let floorTop: CGFloat = wallTop + wallH
        let white: Kit.Stops = [(Art.color(0xF6ECD4), 0), (Art.color(0xE6D3AA), 1)]
        Art.fillLinear(&context, Art.rect(0, floorTop, w, h - floorTop), white, from: CGPoint(x: 0, y: floorTop), to: CGPoint(x: 0, y: h))
        Kit.wall(&context, rect: CGRect(x: -6, y: wallTop, width: w + 12, height: wallH), color: plasterHex)
        Art.fill(&context, Art.rect(-6, wallTop - 5 * u, w + 12, 7 * u, radius: 2), Art.color(0xFBF4E2))
        Art.fill(&context, Art.rect(-6, wallTop + 2 * u, w + 12, 2), ArtStyle.coolShade.opacity(0.12))
        // The two of them from behind, looking out at the tomb.
        let k: CGFloat = u * 1.05
        let feet: CGFloat = H + band.ground * 0.85
        Kit.shadow(&context, 290, feet + 1, width: 64 * k)
        Art.group(&context, x: 290, y: feet, scale: k) { g in
            kingBack(&g)
        }
        Kit.shadow(&context, 142, feet + 1, width: 44 * k)
        Art.group(&context, x: 142, y: feet, scale: k) { g in
            dediBack(&g)
        }
        ArtStyle.finish(&context, size, wash: 0.12, vignette: 0.08)
    }

    /// A man in a white kilt seen from behind, in adult units: origin on the ground between his
    /// feet, about 134 to the neck. The near (left) arm reaches out to `hand`; the far arm hangs.
    static func backBody(_ context: inout GraphicsContext, skin: UInt32, hand: CGPoint) {
        let skinColor: Color = Art.color(skin)
        let shade: Color = Kit.personTone(skin, 0.82)
        Art.stroke(&context, Art.line(-9, -40, -10, -4), shade, width: 11)
        Art.stroke(&context, Art.line(9, -40, 10, -4), shade, width: 11)
        Art.stroke(&context, Art.svg("M29,-114 Q36,-92 33,-70"), shade, width: 10)
        Art.fill(&context, Art.circle(33, -68, 5.6), shade)
        let mx: CGFloat = (hand.x - 29) / 2
        let my: CGFloat = (hand.y - 114) / 2
        var arm = Path()
        arm.move(to: CGPoint(x: -29, y: -114))
        arm.addQuadCurve(to: hand, control: CGPoint(x: mx - 4, y: my + 6))
        Art.stroke(&context, arm, skinColor, width: 10)
        Art.fill(&context, Art.circle(hand.x, hand.y, 6), skinColor)
        let back: Path = Art.svg("M-31,-112 C-33,-120 -22,-125 0,-125 C22,-125 33,-120 31,-112 C29,-104 24,-96 21,-92 L-21,-92 C-24,-96 -29,-104 -31,-112Z")
        Kit.solid(&context, back, skinColor, light: 0.24, shade: 0.24)
        Art.stroke(&context, Art.line(0, -121, 0, -96), Kit.personTone(skin, 0.78).opacity(0.5), width: 1.2)
        let kilt: Path = Art.svg("M-22,-96 L22,-96 C24,-76 26,-56 28,-38 L-28,-38 C-26,-56 -24,-76 -22,-96Z")
        Kit.solid(&context, kilt, Art.color(linenHex), light: 0.2, shade: 0.24)
        Art.stroke(&context, Art.svg("M-8,-90 L-11,-40 M8,-90 L11,-40"), Art.color(0xDCD3BC), width: 1.1)
        Art.fill(&context, Art.rect(-22.5, -98, 45, 6, radius: 2), Art.color(0xE7DDC4))
        Art.fill(&context, Art.rect(-7, -134, 14, 12, radius: 4), shade)
    }

    /// King Khufu from behind, pointing out with his leading arm: his bead collar on the
    /// shoulders, the striped headcloth with its tail and the thin gold band. About 168 tall.
    static func kingBack(_ context: inout GraphicsContext) {
        backBody(&context, skin: skinHex, hand: CGPoint(x: -66, y: -132))
        Art.stroke(&context, Art.svg("M-27,-119 Q0,-110 27,-119"), Art.color(ramp.accent), width: 4.4)
        Art.stroke(&context, Art.svg("M-25,-116 Q0,-106 25,-116"), Art.color(goldHex), width: 2.4)
        let cloth: Path = Art.svg("M-28,-142 C-28,-170 28,-170 28,-142 C28,-130 23,-122 17,-120 L-17,-120 C-23,-122 -28,-130 -28,-142Z")
        Kit.solid(&context, cloth, Art.color(0xF3E7C6), light: 0.24, shade: 0.22)
        let stripes: Path = Art.svg("M-28,-136 L28,-136 M-27,-128 L27,-128 M-24,-152 L24,-152 M-28,-144 L28,-144")
        Art.clipped(&context, to: cloth) { g in
            Art.stroke(&g, stripes, Art.color(ramp.accent, 0.55), width: 2, cap: .butt)
        }
        let tail: Path = Art.svg("M-6,-122 L6,-122 L5,-104 Q0,-101 -5,-104Z")
        Kit.solid(&context, tail, Art.color(0xEADCB6), light: 0.2, shade: 0.24)
        Art.stroke(&context, Art.svg("M-27.5,-150 C-14,-157 14,-157 27.5,-150"), Art.color(goldHex), width: 2.4)
    }

    /// Dedi from behind, as small as a boy: his short white hair, his plain kilt and his staff,
    /// taller than he is, held in his leading hand. About 116 tall.
    static func dediBack(_ context: inout GraphicsContext) {
        let s: CGFloat = dediScale * 0.93
        let skin: Color = Art.color(oldSkinHex)
        Art.group(&context, scale: s) { g in
            Kit.propShaft(&g, -44, 0, -46, -196, wood: darkWoodHex, width: 5.4)
            backBody(&g, skin: oldSkinHex, hand: CGPoint(x: -42, y: -86))
            var ears = Path()
            ears.addPath(Art.ellipse(-25, -142, 4, 7))
            ears.addPath(Art.ellipse(25, -142, 4, 7))
            Art.fill(&g, ears, skin)
            Art.fill(&g, Art.circle(0, -146, 25), skin)
            let hair: Path = Art.svg("M-25,-146 C-25,-170 25,-170 25,-146 C25,-136 20,-128 14,-126 L-14,-126 C-20,-128 -25,-136 -25,-146Z")
            Kit.solid(&g, hair, Art.color(0xF6F2EA), light: 0.2, shade: 0.24)
        }
    }
}
