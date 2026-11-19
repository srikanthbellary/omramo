import SwiftUI
import OmramoCore

// "The Eloquent Peasant": the tap-to-see pictures (432 × 404), the character portraits
// (432 × 400), the face chips (100 × 100) and the cover (300 wide, 150…375 high).

extension EloquentArt {
    // MARK: Tap pictures

    /// The Salt Field: a shallow lake with a white crust of salt, two date palms beyond.
    static func saltFieldPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = morning()
        let H: CGFloat = 214
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 92, H - 34, 12, light: light)
        Kit.ranges(&context, width: size.width, horizon: H, scale: 1, light: light, mountains: false, seed: 19)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: Kit.stops(0xEFE2C2, sandHex, sandDeepHex), seed: 41)
        Kit.palm(&context, x: 248, baseY: H + 4, height: 132, lean: -14, fronds: palmHex, trunk: palmTrunkHex, seed: 3)
        Kit.palm(&context, x: 286, baseY: H + 2, height: 104, lean: 12, fronds: 0x5A8A52, trunk: palmTrunkHex, seed: 5)
        Kit.reeds(&context, x: 330, baseY: H + 8, count: 4, height: 30, seed: 2, color: 0x7A9458)
        saltLake(&context, x0: -6, x1: 362, top: H + 6, depth: 92, seed: 7)
        // The palms' reflections in the still water.
        var reflections = Path()
        reflections.move(to: CGPoint(x: 248, y: H + 26))
        reflections.addLine(to: CGPoint(x: 244, y: H + 58))
        reflections.move(to: CGPoint(x: 286, y: H + 26))
        reflections.addLine(to: CGPoint(x: 290, y: H + 52))
        Art.stroke(&context, reflections, Art.color(palmTrunkHex, 0.3), width: 4)
        Kit.reeds(&context, x: 30, baseY: H + 40, count: 5, height: 38, seed: 4, color: 0x6F8F4E)
        Kit.pebbles(&context, in: CGRect(x: 40, y: H + 104, width: 360, height: 40), count: 14, seed: 6, color: 0xBBA584)
        Kit.sink(&context, size, card: 0x2E4A5E)
    }

    /// Pack donkeys: one small grey donkey with the dark shoulder stripe, two packs in nets.
    static func donkeyPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = morning()
        let H: CGFloat = 236
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.ranges(&context, width: size.width, horizon: H, scale: 1, light: light, mountains: false, seed: 29)
        farPalm(&context, x: 352, baseY: H + 2, height: 46, color: Art.color(0xA8B496), lean: -3)
        farPalm(&context, x: 374, baseY: H + 2, height: 38, color: Art.color(0xA8B496), lean: 4)
        Kit.ground(&context, width: size.width, top: H, bottom: size.height, stops: Kit.stops(0xEFE2C2, sandHex, sandDeepHex), seed: 45)
        Kit.pebbles(&context, in: CGRect(x: 30, y: H + 20, width: 380, height: 50), count: 18, seed: 9, color: 0xBBA584)
        Art.group(&context, x: 230, y: 292, scale: 1.08) { g in
            donkey(&g, pack: 1, mood: .calm)
        }
        Kit.grassTuft(&context, x: 400, baseY: 318, height: 34, color: 0x8E9A5E, seed: 3)
        Kit.sink(&context, size, card: 0x4A3A28)
    }

    /// Ma'at: one tall ostrich feather standing upright on one pan of a simple balance.
    static func maatPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let back: Kit.Stops = Kit.stops(0x4A6590, 0x34496E, 0x2C3E5A)
        Art.fillLinear(&context, Art.rect(0, 0, w, h), back, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 290, 150, 150, Art.color(ramp.glow), alpha: 0.32)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: h), seed: 12, alpha: 0.05)
        let wood: UInt32 = 0xC08A4E
        // The stand and the beam.
        let plinth = Art.rect(150, 296, 132, 16, radius: 4)
        Kit.solid(&context, plinth, Art.color(Kit.builtHex(wood, 0.8)), light: 0.28, shade: 0.24)
        let post = Art.rect(209, 128, 14, 170, radius: 4)
        Kit.solid(&context, post, Art.color(wood), light: 0.3, shade: 0.26, rim: 1.6)
        let beam = Art.rect(116, 124, 200, 10, radius: 5)
        Kit.solid(&context, beam, Art.color(Kit.builtHex(wood, 1.08)), light: 0.3, shade: 0.24, rim: 1.6)
        Art.fill(&context, Art.circle(216, 129, 7), Art.color(Kit.builtHex(wood, 0.7)))
        // The cords and the two pans.
        var cords = Path()
        let pans: [CGFloat] = [140, 292]
        for px in pans {
            cords.move(to: CGPoint(x: px, y: 132))
            cords.addLine(to: CGPoint(x: px - 34, y: 236))
            cords.move(to: CGPoint(x: px, y: 132))
            cords.addLine(to: CGPoint(x: px + 34, y: 236))
        }
        Art.stroke(&context, cords, Art.color(0xE6D2A6, 0.85), width: 1.4)
        for px in pans {
            let pan: Path = Kit.placed("M-40,0 L40,0 C36,12 20,18 0,18 C-20,18 -36,12 -40,0Z", x: px, y: 236)
            Kit.solid(&context, pan, Art.color(0xD9A860), light: 0.32, shade: 0.28, rim: 1.6)
            Art.fill(&context, Art.ellipse(px, 236, 40, 3), Art.color(0xF0C878))
        }
        maatFeather(&context, x: 292, baseY: 234, height: 150)
        Kit.sink(&context, size, card: 0x2C3E5A)
    }

    /// The feather of Ma'at standing on its quill, its tip curling over.
    static func maatFeather(_ g: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat) {
        let k: CGFloat = height / 150
        Art.group(&g, x: x, y: baseY, scale: k) { f in
            let vane: Path = Art.svg("M0,-4 C-14,-30 -20,-70 -18,-104 C-16,-128 -6,-146 8,-150 C18,-152 22,-142 14,-136 C6,-130 14,-112 18,-94 C24,-66 18,-30 0,-4Z")
            Kit.solid(&f, vane, Art.color(0xF8F3E8), light: 0.3, shade: 0.3, rim: 2)
            var barbs = Path()
            for index in 0..<11 {
                let t: CGFloat = CGFloat(index) / 10
                let y: CGFloat = -14 - 118 * t
                let spine: CGFloat = -2 + 4 * t
                barbs.move(to: CGPoint(x: spine, y: y))
                barbs.addLine(to: CGPoint(x: spine - 16, y: y + 10))
                barbs.move(to: CGPoint(x: spine, y: y))
                barbs.addLine(to: CGPoint(x: spine + 16, y: y + 10))
            }
            let lines: Path = barbs
            Art.clipped(&f, to: vane) { c in
                Art.stroke(&c, lines, Art.color(0xD8CFC0, 0.8), width: 1)
            }
            Art.stroke(&f, Art.svg("M0,2 C-3,-40 -1,-100 6,-138"), Art.color(0xC9BBA4), width: 1.8)
        }
    }

    /// The scribe's palette: a long wooden board with cakes of black and red ink and three
    /// reed pens, lying flat.
    static func scribePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        Art.fillLinear(&context, Art.rect(0, 0, w, h), Kit.stops(0xEDE2C8, 0xD7C49C, 0xA88E62), from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        // The weave of the linen it lies on.
        var weave = Path()
        var y: CGFloat = 6
        while y < h {
            weave.move(to: CGPoint(x: 0, y: y))
            weave.addLine(to: CGPoint(x: w, y: y + 3))
            y += 7
        }
        Art.stroke(&context, weave, Art.color(0xB8A47C, 0.25), width: 1)
        ArtStyle.contactShadow(&context, 224, 214, 170, 22, alpha: 0.3)
        Art.group(&context, x: 216, y: 186, rotate: Kit.deg(-8)) { g in
            let board = Art.rect(-158, -28, 316, 56, radius: 8)
            Kit.solid(&g, board, Art.color(0xB88A52), light: 0.3, shade: 0.28, rim: 2)
            Art.clipped(&g, to: board) { c in
                Art.stroke(&c, Art.svg("M-160,-14 C-60,-18 40,-10 160,-16 M-160,12 C-40,8 60,16 160,10"), Art.color(0x8A6234, 0.45), width: 1.2)
            }
            // The two wells and their cakes of ink.
            let wells: [(CGFloat, UInt32)] = [(-124, inkHex), (-90, redInkHex)]
            for well in wells {
                Art.fill(&g, Art.circle(well.0, 0, 14), Art.color(0x7A5430))
                Kit.solid(&g, Art.circle(well.0, 0, 11), Art.color(well.1), light: 0.22, shade: 0.3)
                Art.fill(&g, Art.ellipse(well.0 - 4, -4, 3.5, 2), Color.white.opacity(0.3))
            }
            // The slot, and three reed pens lying in it.
            let slot = Art.rect(-62, -8, 206, 16, radius: 4)
            Art.fill(&g, slot, Art.color(0x7A5430))
            let pens: [(CGFloat, CGFloat)] = [(-4, 132), (0, 124), (4, 138)]
            for pen in pens {
                Art.stroke(&g, Art.line(-56, pen.0, pen.1, pen.0 - 1), Art.color(0xD8C08A), width: 3.4)
                Art.stroke(&g, Art.line(pen.1 - 10, pen.0 - 0.6, pen.1, pen.0 - 1), Art.color(inkHex), width: 3)
            }
            Art.stroke(&g, Art.line(-56, -6, 140, -7), ArtStyle.warmLight.opacity(0.4), width: 1)
        }
        Kit.sink(&context, size, card: 0x3A3020)
    }

    // MARK: Portraits

    /// Khunanup mid-speech, one hand raised, his stick in the other, a salt lake behind.
    static func khunanupPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xFBF3E2, bottom: 0xD9B77A, halo: 0xFFF4DC, rays: false) { g in
            saltLake(&g, x0: -40, x1: 520, top: 282, depth: 58, seed: 3)
            farPalm(&g, x: 54, baseY: 288, height: 64, color: Art.color(0x9DAA86), lean: -4)
            farPalm(&g, x: 384, baseY: 286, height: 52, color: Art.color(0x9DAA86), lean: 5)
            // The stick in his far hand, on the picture's left.
            Art.stroke(&g, Art.line(78, 404, 104, 150), Art.color(0x8A6440), width: 6)
            Art.stroke(&g, Art.line(76, 400, 102, 156), ArtStyle.warmLight.opacity(0.35), width: 1.6)
            let p = khunanupLook()
            Art.group(&g, x: 216, y: 132, scale: 2.1) { b in
                Kit.bust(&b, p, look: CGPoint(x: 0.1, y: 0), mouth: .open, wave: true)
            }
            Art.stroke(&g, Art.line(76, 360, 104, 318), Art.color(p.skin), width: 22)
            Kit.solid(&g, Art.ellipse(98, 310, 13, 15), Art.color(p.skin), light: 0.24, shade: 0.24)
        }
    }

    /// Rensi seated, hands folded on his staff, broad bead collar, calm closed face,
    /// pale columns behind.
    static func rensiPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xEEF4F6, bottom: 0x8FB8CC, halo: 0xFFF6E6, rays: false) { g in
            budColumn(&g, cx: 52, baseY: 430, width: 36, height: 400, color: 0xEDE1C8, paint: 0.6)
            budColumn(&g, cx: 380, baseY: 430, width: 36, height: 400, color: 0xEDE1C8, paint: 0.6)
            let p = rensiLook()
            Art.group(&g, x: 216, y: 132, scale: 2.1) { b in
                Kit.bust(&b, p, look: .zero, mouth: .flat)
                let rows: Path = Art.svg("M-40,47 C-30,84 30,84 40,47 M-31,48 C-22,74 22,74 31,48")
                Art.stroke(&b, rows, Art.color(0x3FA27A), width: 2.4)
                Art.stroke(&b, Art.svg("M-36,47 C-26,80 26,80 36,47"), Art.color(0xC8553D), width: 2)
                Art.stroke(&b, Art.svg("M-45,43 C-37,94 37,94 45,43"), Art.color(0xE9C46A), width: 1.4)
            }
            // The staff, and his hands folded on it.
            staffOfOffice(&g, x: 186, top: 262)
            let skin: Color = Art.color(p.skin)
            Art.stroke(&g, Art.line(108, 388, 176, 344), skin, width: 24)
            Art.stroke(&g, Art.line(326, 388, 198, 346), Kit.personTone(p.skin, 0.94), width: 24)
            Kit.solid(&g, Art.ellipse(184, 342, 15, 12), skin, light: 0.24, shade: 0.24)
            Kit.solid(&g, Art.ellipse(194, 336, 14, 11), Kit.personTone(p.skin, 1.05), light: 0.24, shade: 0.24)
        }
    }

    // MARK: Face chips

    static func khunanupFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xF6E2BC) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.25) { f in
                Kit.personHead(&f, khunanupLook(), look: .zero, mouth: .smile)
            }
        }
    }

    static func rensiFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD6E8F2) { g in
            Art.stroke(&g, Art.svg("M-30,44 C-20,30 20,30 30,44"), Art.color(0x3E7FB8), width: 9)
            Art.group(&g, x: 0, y: 2, scale: 1.22) { f in
                Kit.personHead(&f, rensiLook(), look: .zero, mouth: .flat)
            }
        }
    }

    static func nemtynakhtFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xEBD3C4) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.25) { f in
                Kit.personHead(&f, nemtyLook(), look: CGPoint(x: -0.5, y: 0), mouth: .smile)
                Art.stroke(&f, Art.svg("M-18,-24 C-10,-30 0,-32 8,-30"), Color.white.opacity(0.6), width: 2)
            }
        }
    }

    // MARK: Cover

    /// Rensi's courtyard: Khunanup speaking, one hand raised; Rensi silent on his chair; the
    /// scribe writing on a roll that spills across the floor; two donkeys waiting by the gate.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size, wash: 0.08, vignette: 0.08) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let light = courtyard()
            Kit.sky(&g, CGSize(width: 240, height: hd), horizon: H, light: light)
            let wallTop: CGFloat = H - 62 * k
            Kit.wall(&g, rect: CGRect(x: -4, y: wallTop, width: 248, height: H - wallTop + 2), color: plasterHex)
            Kit.solid(&g, Art.rect(-4, wallTop - 4 * k, 248, 5 * k, radius: 2), Art.color(plasterShadeHex), light: 0.24, shade: 0.2)
            let dado: [(UInt32, CGFloat)] = [(0xC8553D, 16), (0x2F6F9E, 12), (0x3FA27A, 8)]
            for stripe in dado {
                Art.fill(&g, Art.rect(-4, H - stripe.1 * k, 248, 2.4 * k), Art.color(stripe.0, 0.5))
            }
            Kit.gateway(&g, cx: 214, baseY: H + 1, width: 34 * k, height: 48 * k, color: 0xE6D8BE)
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: Kit.stops(0xEFE3CB, 0xE2D1B0, 0xD2BC96), seed: 47)
            budColumn(&g, cx: 150, baseY: H + 3 * k, width: 11 * k, height: 104 * k, color: 0xEDE1C8, paint: 0.55)
            budColumn(&g, cx: 196, baseY: H + 3 * k, width: 11 * k, height: 104 * k, color: 0xEDE1C8, paint: 0.55)
            let s: CGFloat = 0.42 * k
            let d: CGFloat = s * 0.6
            Art.group(&g, x: 206, y: H + 8 * k, scale: d) { a in donkey(&a, pack: 1) }
            Art.group(&g, x: 230, y: H + 10 * k, scale: d) { a in donkey(&a, pack: 2) }
            Art.group(&g, x: 170, y: H + 24 * k, scale: s) { a in
                rensi(&a, seated: true, mouth: .flat, look: CGPoint(x: -0.6, y: 0))
            }
            Art.group(&g, x: 70, y: H + 30 * k, scale: s, scaleX: -1) { a in
                khunanup(&a, pose: .wave, mouth: .open, look: CGPoint(x: -0.4, y: -0.1), mirrored: true)
            }
            Art.group(&g, x: 122, y: H + 30 * k, scale: s) { a in scribe(&a) }
            papyrusRun(&g, x0: 22, x1: 116, y: H + 34 * k, depth: 4 * k)
            Kit.cornerLeaves(&g, size: CGSize(width: 240, height: hd), corner: 1, color: Art.color(0x4E7F4A), scale: 0.45, seed: 2)
        }
    }
}
