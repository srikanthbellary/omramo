import SwiftUI
import OmramoCore

// The Griot's Apprentice: the tap-to-see pictures (432 × 404), the character-card portraits
// (432 × 400), the face chips (100 × 100) and the cover.

extension GriotArt {
    // MARK: Tap pictures

    /// A warm backdrop for the pictures: a wall-to-floor gradient and a soft halo.
    static func pictureGround(_ context: inout GraphicsContext, _ size: CGSize, top: UInt32, floor: UInt32, horizon: CGFloat) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let wall: Kit.Stops = Kit.stops(top, Kit.builtHex(top, 0.9))
        Art.fillLinear(&context, Art.rect(0, 0, w, h), wall, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: horizon))
        Art.glow(&context, w * 0.5, horizon * 0.62, w * 0.5, Art.color(0xFFE6B8), alpha: 0.35)
        let ground: Kit.Stops = Kit.stops(Kit.builtHex(floor, 1.15), floor)
        Kit.ground(&context, width: w, top: horizon, bottom: h, stops: ground, seed: 19)
    }

    /// "Jeli": an old singer in a wide white robe and cap, one hand lifted, singing.
    static func jeliPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        pictureGround(&context, size, top: 0xD8A870, floor: 0x9A6638, horizon: 292)
        mudWall(&context, x0: -10, x1: 442, baseY: 292, height: 70, color: 0xC8925C)
        lampNiche(&context, cx: 66, cy: 252, scale: 1.4)
        lampNiche(&context, cx: 372, cy: 252, scale: 1.4)
        let p = madiLook()
        Art.group(&context, x: 220, y: 318, scale: 1.5) { g in
            Kit.shadow(&g, 0, 0, width: 70)
            let robe: Path = Art.svg("M-14,-112 C-44,-90 -52,-40 -46,-4 C-20,2 22,2 44,-4 C48,-40 40,-90 16,-112Z")
            Kit.solid(&g, robe, Art.color(0xF2EEE4), light: 0.26, shade: 0.26)
            Kit.person(&g, p, pose: .wave, look: CGPoint(x: -0.3, y: -0.5), mouth: .open)
            let folds: Path = Art.svg("M-30,-70 C-34,-50 -36,-30 -34,-8 M26,-74 C30,-52 32,-30 30,-8 M-6,-60 C-6,-40 -4,-20 -4,-4")
            Art.stroke(&g, folds, Art.color(0xD8CFC0), width: 1.4)
        }
        Kit.cornerLeaves(&context, size: size, corner: 1, color: Art.color(0x6A4A2A), scale: 0.6, seed: 3)
        Kit.sink(&context, size, card: 0x5A3218)
    }

    /// "The River Niger": a long narrow pirogue poled across a wide, pale brown river under a
    /// hazy sky.
    static func riverNigerPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = afternoon()
        let H: CGFloat = 176
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.sun(&context, 110, H - 40, 16, light: light)
        Kit.farTrees(&context, x0: 0, x1: 432, baseY: H + 1, height: 10, count: 22, color: light.far, seed: 6)
        Kit.palm(&context, x: 330, baseY: H + 2, height: 34, lean: 3, fronds: 0xAEAC92, trunk: 0xB4A28A, seed: 4)
        ArtStyle.atmosphere(&context, width: 432, top: H - 50, bottom: H + 4, color: light.haze, alpha: 0.38)
        let river: Kit.Stops = Kit.stops(0xD2C6AC, 0x7E8A80)
        Kit.water(&context, width: 432, top: H, bottom: size.height, stops: river, light: light, ripples: 40, seed: 2)
        Kit.glints(&context, x: 110, top: H, depth: 120, color: Color.white, count: 30, seed: 7)
        let waterY: CGFloat = 248
        Art.group(&context, x: 270, y: waterY - 13, scale: 0.95) { g in
            boatman(&g, boatmanLook(0xE6DCC8), poleDown: 60)
        }
        pirogue(&context, cx: 214, waterY: waterY, length: 290)
        Kit.heap(&context, cx: 150, baseY: waterY - 14, width: 40, count: 6, color: 0x8A7A5A, seed: 3)
        Kit.sink(&context, size, card: 0x2E4A5A)
    }

    /// "Balafon": seen from the front and a little above, keys on a curved frame, gourds of
    /// graded sizes beneath.
    static func balafonPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        pictureGround(&context, size, top: 0xE8C48E, floor: 0xB07A48, horizon: 214)
        mat(&context, cx: 216, baseY: 296, width: 360, color: 0xD8BC84)
        balafon(&context, x: 216, baseY: 272, scale: 2.6)
        let beaters: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(120, 300, 176, 286), (300, 302, 246, 290)]
        for b in beaters {
            Kit.propShaft(&context, b.0, b.1, b.2, b.3, wood: 0x7A5230, width: 3)
            Kit.solid(&context, Art.circle(b.2, b.3, 6), Art.color(0x3A2A1E), light: 0.3, shade: 0.2)
        }
        Kit.sink(&context, size, card: 0x6A3A1A)
    }

    /// "Salt for gold": two grey-white slabs of rock salt on end beside a small brass
    /// hand-scale holding a pinch of gold dust.
    static func saltAndGoldPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        pictureGround(&context, size, top: 0xD2B08A, floor: 0x8A6A4A, horizon: 250)
        let cloth: Path = Art.svg("M40,300 C90,284 330,284 400,300 L410,318 C330,304 90,304 30,318Z")
        Kit.solid(&context, cloth, Art.color(indigo), light: 0.2, shade: 0.24)
        saltSlab(&context, x: 140, baseY: 300, width: 82, height: 176, tilt: -0.04)
        saltSlab(&context, x: 218, baseY: 302, width: 74, height: 158, tilt: 0.05)
        handScale(&context, x: 326, y: 116)
        Kit.sink(&context, size, card: 0x4A3A2A)
    }

    /// A small brass hand-scale hanging from its cord at (x, y): the beam, two pans, gold dust
    /// in the left pan and two small weights in the right.
    static func handScale(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        let brass: Color = Art.color(0xC8963A)
        let cord: Color = Art.color(0x6A4A2A)
        Art.stroke(&context, Art.line(x, y - 40, x, y), cord, width: 1.4)
        Art.stroke(&context, Art.circle(x, y - 44, 5), brass, width: 2)
        Kit.propShaft(&context, x - 46, y + 2, x + 46, y - 2, wood: 0xC8963A, width: 3.4)
        let strings: Path = Art.svg("M-46,2 L-62,70 M-46,2 L-30,70 M46,-2 L30,66 M46,-2 L62,66").applying(CGAffineTransform(translationX: x, y: y))
        Art.stroke(&context, strings, cord.opacity(0.8), width: 1)
        let leftPan: Path = Art.svg("M-68,70 C-60,82 -32,82 -24,70Z").applying(CGAffineTransform(translationX: x, y: y))
        let rightPan: Path = Art.svg("M24,66 C32,78 60,78 68,66Z").applying(CGAffineTransform(translationX: x, y: y))
        let dust: Path = Art.svg("M-58,70 C-54,62 -38,62 -34,70Z").applying(CGAffineTransform(translationX: x, y: y))
        Kit.solid(&context, dust, Art.color(gold), light: 0.4, shade: 0.2)
        Kit.flecks(&context, in: CGRect(x: x - 58, y: y + 62, width: 24, height: 8), count: 10, seed: 3, color: Art.color(0xFFF0B0), radius: 0.4...1.0, glow: false)
        Kit.solid(&context, leftPan, brass, light: 0.36, shade: 0.3, rim: 1.2)
        Kit.solid(&context, Art.rect(x + 36, y + 58, 9, 8, radius: 1.5), Art.color(0x9A7030), light: 0.3, shade: 0.3)
        Kit.solid(&context, Art.rect(x + 48, y + 61, 6, 5, radius: 1.2), Art.color(0x9A7030), light: 0.3, shade: 0.3)
        Kit.solid(&context, rightPan, brass, light: 0.36, shade: 0.3, rim: 1.2)
        Art.fill(&context, Art.circle(x - 1.4, y - 1.4, 3), Art.color(0xF0C870))
    }
}

// MARK: - Portraits and faces

extension GriotArt {
    /// Sira, chin up, standing very straight against a pale ochre mud wall.
    static func apprenticePortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x3A4A8A, bottom: 0x1A1A38, halo: 0xFFE6C0, rays: false) { g in
            let wall: Path = Art.rect(70, 28, 292, 420, radius: 146)
            Art.fill(&g, wall, Art.color(0xE8C89A))
            Art.clipped(&g, to: wall) { c in
                ArtStyle.form(&c, wall, bounds: CGRect(x: 70, y: 28, width: 292, height: 420), light: 0.3, shade: 0.3)
                ArtStyle.tooth(&c, in: CGRect(x: 70, y: 28, width: 292, height: 380), seed: 8, color: Color.white, alpha: 0.1)
                Art.stroke(&c, Art.svg("M90,300 C160,296 260,298 350,304 M84,210 C150,206 280,208 352,214"), Art.color(0xC8A274, 0.5), width: 1.4)
            }
            Art.group(&g, x: 216, y: 140, scale: 2.0) { b in
                Kit.bust(&b, siraLook(), look: CGPoint(x: 0, y: -0.3), mouth: .flat)
                let upper: Path = Art.svg("M-52,46 C-30,36 30,36 52,46 L58,120 C20,110 -20,110 -58,120Z")
                Kit.solid(&b, upper, Art.color(indigo), light: 0.22, shade: 0.26)
                let folds: Path = Art.svg("M-40,52 C-20,70 0,80 30,86 M-30,90 C-10,96 10,98 36,96")
                Art.stroke(&b, folds, Art.color(indigoDeep), width: 1.4)
                Art.stroke(&b, Art.svg("M-52,46 C-30,36 30,36 52,46"), Art.color(0xF3EEE4), width: 3)
            }
        }
    }

    /// Jeli Madi seated on his mat, eyes half closed as if listening, one thin hand on the
    /// balafon keys.
    static func grandfatherPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0x8A5A2A, bottom: 0x2E1A0C, halo: 0xFFE2B8, rays: false) { g in
            let p = madiLook()
            Art.group(&g, x: 206, y: 140, scale: 2.0) { b in
                Kit.bust(&b, p, look: CGPoint(x: -0.2, y: 0.4), mouth: .smile)
                let lids: Path = Art.svg("M-13.6,-1.8 L-5.4,-1.8 L-5.4,2.4 C-8,3.6 -11,3.6 -13.6,2.4Z M5.4,-1.8 L13.6,-1.8 L13.6,2.4 C11,3.6 8,3.6 5.4,2.4Z")
                Art.fill(&b, lids, Kit.personTone(skinOld, 1.04))
                Art.stroke(&b, Art.svg("M-13.6,2.4 C-11,3.6 -8,3.6 -5.4,2.4 M5.4,2.4 C8,3.6 11,3.6 13.6,2.4"), Art.color(0x2A1A12), width: 1.2)
            }
            balafon(&g, x: 236, baseY: 404, scale: 2.4)
            let arm: Path = Art.svg("M120,300 C130,320 150,330 176,334")
            Art.stroke(&g, arm, Art.color(0xF2EEE4), width: 20)
            Kit.solid(&g, Art.ellipse(184, 336, 13, 7), Art.color(skinOld), light: 0.3, shade: 0.22)
            Art.stroke(&g, Art.svg("M190,332 L200,334 M190,338 L201,340"), Kit.personTone(skinOld, 0.8), width: 2.4)
        }
    }

    static func apprenticeFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xDCE2F7) { g in
            Art.group(&g, x: 0, y: 7, scale: 1.2) { f in
                Kit.personHead(&f, siraLook(), look: CGPoint(x: 0, y: -0.2), mouth: .smile)
            }
        }
    }

    static func grandfatherFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFBE3C4) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.25) { f in
                Kit.personHead(&f, madiLook(), mouth: .smile)
            }
        }
    }

    /// Bakary: the close grey beard and the tall cloth cap with its gold band.
    static func merchantFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xEEDDF3) { g in
            Art.group(&g, x: 0, y: 10, scale: 1.08) { f in
                Kit.personHead(&f, bakaryLook(), mouth: .smile)
                let cap: Path = Art.svg("M-24,-20 C-26,-38 -18,-52 0,-54 C18,-52 26,-38 24,-20 C12,-26 -12,-26 -24,-20Z")
                Kit.solid(&f, cap, Art.color(0x5A2A6E), light: 0.28, shade: 0.24)
                Art.stroke(&f, Art.svg("M-23,-23 C-10,-28 10,-28 23,-23"), Art.color(gold), width: 2.4)
            }
        }
    }
}

// MARK: - Cover

extension GriotArt {
    /// Sira singing with one hand raised in the merchant's courtyard at pale gold evening,
    /// Lamine at the balafon, guests on mats looking up, the porter and the girl at the gate.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let hd: CGFloat = frame.hd
            let light = evening()
            Kit.sky(&g, CGSize(width: 240, height: hd), horizon: H, light: light)
            Kit.farHouse(&g, cx: 60, baseY: H - 22 * k, width: 60 * k, height: 18 * k, wall: light.far, roof: light.mid, flat: true)
            Kit.farHouse(&g, cx: 150, baseY: H - 22 * k, width: 70 * k, height: 22 * k, wall: light.far, roof: light.mid, flat: true)
            ArtStyle.atmosphere(&g, width: 240, top: H - 60 * k, bottom: H - 18 * k, color: light.haze, alpha: 0.4)
            let floor: Kit.Stops = Kit.stops(0xE2BE88, 0xC6985E)
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: floor, seed: 3)
            mudWall(&g, x0: -10, x1: 250, baseY: H + 4 * k, height: 28 * k, color: bancoLit)
            lampNiche(&g, cx: 40, cy: H - 10 * k, scale: 0.7 * k)
            lampNiche(&g, cx: 120, cy: H - 10 * k, scale: 0.7 * k)
            gate(&g, x: 216, H: H - k, scale: 0.875 * k)
            let feet: CGFloat = H + 26 * k
            Art.group(&g, x: 164, y: feet + 2 * k, scale: 0.78 * k) { s in
                lamine(&s)
            }
            Art.group(&g, x: 118, y: feet, scale: 0.9 * k) { s in
                sira(&s, pose: .wave, mouth: .open, look: CGPoint(x: -0.3, y: -0.5))
            }
            cowries(&g, x: 96, y: feet + 2 * k)
            let row: [(CGFloat, Int)] = [(22, 0), (62, 1)]
            for seat in row {
                Art.group(&g, x: seat.0, y: feet + 16 * k, scale: 0.5 * k) { s in
                    guest(&s, guestLook(seat.1), mirrored: true, bowl: seat.1 == 0)
                }
            }
            if hd > 200 {
                let near: [(CGFloat, Int)] = [(34, 3), (196, 4)]
                for seat in near {
                    Art.group(&g, x: seat.0, y: H + 92, scale: 0.72) { s in
                        guest(&s, guestLook(seat.1), mirrored: seat.0 < 120, bowl: true)
                    }
                }
            }
            Kit.cornerLeaves(&g, size: CGSize(width: 240, height: hd), corner: 1, color: Art.color(0x5A3A1E), scale: 0.4, seed: 7)
        }
    }
}
