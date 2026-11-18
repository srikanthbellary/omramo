import SwiftUI
import OmramoCore

/// Concept art for "King Khufu and the Magician", drawn in code (round 5; composed from the
/// shared kit).
///
/// Old Kingdom Egypt, about 2550 BCE: a whitewashed mud-brick palace with slim painted wooden
/// columns, white linen kilts and bead collars, a river boat with a two-legged mast, and a
/// pyramid that is only half built. This file holds the entry point and the four unfolded
/// scenes; the cast and the shared parts are in `KhufuArt+Cast.swift`, the folded scenes in
/// `KhufuArt+Folded.swift`, the tap pictures, portraits, faces and cover in
/// `KhufuArt+Pictures.swift`.
enum KhufuArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-court", .sceneUnfolded): courtScene(&context, size)
        case ("scene-court", .sceneFolded): courtFolded(&context, size)
        case ("scene-river", .sceneUnfolded): riverScene(&context, size)
        case ("scene-river", .sceneFolded): riverFolded(&context, size)
        case ("scene-magic", .sceneUnfolded): magicScene(&context, size)
        case ("scene-magic", .sceneFolded): magicFolded(&context, size)
        case ("scene-pyramid", .sceneUnfolded): pyramidScene(&context, size)
        case ("scene-pyramid", .sceneFolded): pyramidFolded(&context, size)
        case ("see-nile", .picture): nilePicture(&context, size)
        case ("see-river-boat", .picture): riverBoatPicture(&context, size)
        case ("see-papyrus-roll", .picture): papyrusPicture(&context, size)
        case ("char-khufu", .portrait): khufuPortrait(&context, size)
        case ("char-dedi", .portrait): dediPortrait(&context, size)
        case ("face-khufu", .face): khufuFace(&context, size)
        case ("face-dedi", .face): dediFace(&context, size)
        case ("face-prince", .face): princeFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }

    /// How deep the ground of the near plane is, in the units of `Kit.nearSpace`.
    static func nearDepth(_ st: Kit.Stage) -> CGFloat {
        st.depth / (st.fit * st.grow)
    }
}

// MARK: - Scene: the hall of columns (pages 1–3 and 5)

extension KhufuArt {
    /// The king's hall, open on the leading side to a pale hot sky and the river. On the
    /// trailing side King Khufu sits on his chair, chin on his fist, with a fan-bearer behind
    /// him and his sons before him; Prince Hordedef has stepped forward to speak.
    static func courtScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = day()
        courtHall(&context, size, st, light: light)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 740) { n in
                courtGroup(&n, floorY: st.Hv)
                courtFill(&n, st)
            }
            Kit.nearSpace(&v, st) { n in
                // The near column on the trailing edge, cropped by the frame.
                hallColumn(&n, x: 874, baseY: st.Hv + 150, width: 32, height: st.Hv + 190)
            }
        }
        ArtStyle.finish(&context, size)
    }

    /// A doorway hung with a reed mat, in a plastered wall.
    static func matDoor(_ context: inout GraphicsContext, rect: CGRect) {
        let frame: Path = Art.rect(rect.minX, rect.minY, rect.width, rect.height, radius: 2)
        Kit.solid(&context, frame, Art.color(0xE2D0A6), light: 0.22, shade: 0.16)
        let t: CGFloat = max(2, rect.width * 0.1)
        let inner: CGRect = CGRect(x: rect.minX + t, y: rect.minY + t, width: rect.width - t * 2, height: rect.height - t)
        Art.fill(&context, Path(inner), Art.color(0xCDB278))
        var weave = Path()
        var y: CGFloat = inner.minY + 5
        while y < inner.maxY {
            weave.move(to: CGPoint(x: inner.minX, y: y))
            weave.addLine(to: CGPoint(x: inner.maxX, y: y))
            y += 6
        }
        Art.stroke(&context, weave, Art.color(0xA98E52, 0.6), width: 1, cap: .butt)
        Art.fill(&context, Art.rect(inner.minX, inner.minY, inner.width, t * 1.4), ArtStyle.coolShade.opacity(0.16))
    }

    /// The far and middle planes of the court: sky, the river through the open side, the
    /// plastered back wall of the trailing side, the floor, the beam and two slim columns.
    static func courtHall(_ context: inout GraphicsContext, _ size: CGSize, _ st: Kit.Stage, light: Kit.Light) {
        let f: CGFloat = st.far
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 292, st.H - 150 * f, scale: 0.7 * f, color: Color.white.opacity(0.5))
        // The river and its far bank, seen over the sill of the open side.
        let bankY: CGFloat = st.H - 24 * f
        farBank(&context, width: 470, y: bankY, scale: f, light: light, seed: 11)
        let river: Kit.Stops = waterStops()
        Art.fillLinear(&context, Art.rect(0, bankY, 470, 18 * f), river, from: CGPoint(x: 0, y: bankY), to: CGPoint(x: 0, y: bankY + 18 * f))
        Kit.rippleMarks(&context, x0: 0, x1: 470, y0: bankY + 2, y1: bankY + 16 * f, count: 14, seed: 5, color: Color.white, alpha: 0.4)
        Art.group(&context, x: 214, y: bankY + 9 * f, scale: 0.17 * f) { g in
            riverBoat(&g, rowers: 5)
        }
        Kit.birds(&context, 120, st.H - 52 * f, scale: 0.8 * f, color: Art.color(ramp.shade, 0.45))
        Art.fill(&context, Art.rect(0, st.H - 7 * f, 470, 7 * f + 1), Art.color(0xEFE3C6))
        Art.fill(&context, Art.rect(0, st.H - 7 * f, 470, 1.5), Color.white.opacity(0.6))
        // The back wall of the trailing side, with its painted band and a mat-hung door.
        Kit.wall(&context, rect: CGRect(x: 452, y: -4, width: 446, height: st.H + 4), color: plasterHex)
        dado(&context, x0: 452, x1: w, y: st.H - 30 * f, height: 30 * f)
        matDoor(&context, rect: CGRect(x: 488, y: st.H - 150 * f, width: 62 * f, height: 150 * f))
        hallFloor(&context, size, top: st.H)
        // The roof beam along the top.
        Art.fill(&context, Art.rect(0, 0, w, 16 * f), Art.color(0xE9DBB8))
        Art.fill(&context, Art.rect(0, 16 * f, w, 3), ArtStyle.coolShade.opacity(0.08))
        // The columns' long soft shadows on the floor, then the columns.
        let baseY: CGFloat = st.H + 16 * f
        let reach: CGFloat = size.height - baseY
        let posts: [CGFloat] = [14, 446]
        for x in posts {
            let fall: Path = Art.polygon([
                CGPoint(x: x - 9 * f, y: baseY), CGPoint(x: x + 9 * f, y: baseY),
                CGPoint(x: x + 30 * f + reach * 0.7, y: size.height), CGPoint(x: x - 20 * f + reach * 0.7, y: size.height),
            ])
            Art.fill(&context, fall, ArtStyle.coolShade.opacity(0.06))
        }
        Kit.pot(&context, cx: 84, baseY: st.H + 36 * f, width: 30 * f, height: 46 * f, color: 0xB5603A, band: 0xF1E5C6)
        for x in posts {
            hallColumn(&context, x: x, baseY: baseY, width: 20 * f, height: baseY - 14 * f)
        }
    }

    /// The king on his chair, the fan-bearer, two sons and Prince Hordedef, standing on a
    /// reed mat. `floorY` is the line where the floor meets the wall.
    static func courtGroup(_ context: inout GraphicsContext, floorY H: CGFloat) {
        reedMat(&context, cx: 668, y: H + 48, width: 344, depth: 56)
        Kit.shadow(&context, 796, H + 51, width: 58)
        Art.group(&context, x: 796, y: H + 50) { g in
            fanBearer(&g)
        }
        Kit.shadow(&context, 594, H + 65, width: 56)
        Art.group(&context, x: 594, y: H + 64, scaleX: -1) { g in
            courtier(&g, kind: 2, mirrored: true)
        }
        Kit.shadow(&context, 548, H + 71, width: 56)
        Art.group(&context, x: 548, y: H + 70, scaleX: -1) { g in
            courtier(&g, kind: 1, mouth: .flat, mirrored: true)
        }
        Art.group(&context, x: 730, y: H + 62) { g in
            throne(&g)
            king(&g, pose: .chin)
        }
        Kit.shadow(&context, 640, H + 89, width: 58)
        Art.group(&context, x: 640, y: H + 88, scaleX: -1) { g in
            prince(&g, pose: .stand, mouth: .open, mirrored: true)
        }
    }

    /// What fills the deeper floor of a tall window: a second mat with the bread, beer and
    /// onions of the tale, sized to the room there is.
    static func courtFill(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let depth: CGFloat = nearDepth(st)
        let s: CGFloat = min(1.3, (depth - 150) / 66)
        guard s > 0.5 else { return }
        let baseY: CGFloat = st.Hv + depth - 40
        reedMat(&context, cx: 590, y: baseY - 26 * s, width: 200 * s, depth: 40 * s)
        Art.group(&context, x: 590, y: baseY, scale: s) { g in
            rations(&g)
        }
    }

    /// A small wooden chest of papyrus rolls standing on the origin, about 56 wide and 44 tall,
    /// the tied rolls standing up over its rim.
    static func rollChest(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 2, 1, width: 66)
        let tops: [(CGFloat, CGFloat)] = [(-17, -10), (-6, 6), (6, -4), (17, 8)]
        for top in tops {
            Art.group(&context, x: top.0, y: -34, rotate: Kit.deg(-80 + top.1)) { g in
                papyrusRoll(&g, length: 24, thick: 7.5)
            }
        }
        let box: Path = Art.rect(-28, -30, 56, 28, radius: 2)
        Kit.solid(&context, box, Art.color(woodHex), light: 0.26, shade: 0.24)
        Art.stroke(&context, Art.line(-27, -25, 27, -25), Kit.propTone(woodHex, 0.7), width: 1.2, cap: .butt)
        Art.stroke(&context, Art.line(-27, -8, 27, -8), Kit.propTone(woodHex, 0.7), width: 1.2, cap: .butt)
        var feet = Path()
        feet.addPath(Art.rect(-27, -3, 7, 3))
        feet.addPath(Art.rect(20, -3, 7, 3))
        Art.fill(&context, feet, Art.color(darkWoodHex))
    }
}

// MARK: - Scene: Dedi's door on the river bank (page 4)

extension KhufuArt {
    /// The Nile across both panes under a wide pale sky, the far bank of pale cliffs and palms,
    /// the prince's boat at rest near the hinge. On the trailing bank, before his mud-brick
    /// house, Dedi sits up on his couch of palm sticks and holds out his hands; a servant kneels
    /// at his feet and Prince Hordedef bows low before him.
    static func riverScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 160)
        let light = day()
        let f: CGFloat = st.far
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 650, st.H - 250 * f, scale: 0.8 * f, color: Color.white.opacity(0.55))
        Kit.cloud(&context, 200, st.H - 210 * f, scale: 0.5 * f, color: Color.white.opacity(0.4))
        farBank(&context, width: size.width, y: st.H, scale: f, light: light, seed: 23)
        Kit.water(&context, width: size.width, top: st.H, bottom: size.height, stops: waterStops(), light: light, ripples: 46, seed: 9)
        Kit.birds(&context, 300, st.H - 96 * f, scale: 0.8 * f, color: Art.color(ramp.shade, 0.4))
        Kit.designSpace(&context, st) { v in
            // The prince's boat, moored near the hinge, its crew at rest.
            Art.group(&v, x: 330, y: st.Hv + 46, scale: 0.72) { g in
                riverBoat(&g, rowers: 6)
            }
            Kit.ripples(&v, 330, st.Hv + 50, 170, count: 2, color: Color.white, opacity: 0.4)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                riverBank(&n, floorY: st.Hv)
                riverGroup(&n, floorY: st.Hv)
                riverFill(&n, st)
            }
        }
        // Near framing: a dark clump of papyrus in the water at the bottom-left corner.
        Kit.reeds(&context, x: 14, baseY: size.height + 12, count: 6, height: 120 * f, seed: 19, color: 0x3F6F45, papyrus: true)
        ArtStyle.finish(&context, size)
    }

    /// The near bank of the trailing side: a dark wet edge at the water, the dry bank, two
    /// date palms, Dedi's flat-roofed mud-brick house and a few papyrus stems.
    static func riverBank(_ context: inout GraphicsContext, floorY H: CGFloat) {
        let bottom: CGFloat = H + 700
        var edge = Path()
        edge.move(to: CGPoint(x: 420, y: bottom))
        edge.addLine(to: CGPoint(x: 470, y: H + 74))
        edge.addQuadCurve(to: CGPoint(x: 566, y: H + 16), control: CGPoint(x: 498, y: H + 28))
        edge.addQuadCurve(to: CGPoint(x: 904, y: H + 4), control: CGPoint(x: 700, y: H + 6))
        var bank: Path = edge
        bank.addLine(to: CGPoint(x: 904, y: bottom))
        bank.closeSubpath()
        let earth: Kit.Stops = [(Art.color(0xD9C192), 0), (Art.color(0xC4A672), 0.35), (Art.color(0xAE8F5E), 1)]
        Art.fillLinear(&context, bank, earth, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: H + 260))
        Kit.model(&context, bank, light: 0.12, shade: 0.1)
        Art.stroke(&context, edge, Art.color(0x8A7350, 0.8), width: 4)
        let lip: Path = edge.applying(CGAffineTransform(translationX: 0, y: -2))
        Art.stroke(&context, lip, Art.color(0xF2E4BE, 0.6), width: 1.2)
        let tufts = CGRect(x: 540, y: H + 14, width: 360, height: 120)
        Kit.grass(&context, in: tufts, count: 24, seed: 6, color: Art.color(0x8C9C5A, 0.75), height: 9)
        Kit.palm(&context, x: 636, baseY: H + 26, height: 214, lean: -20, fronds: 0x5E8F4E, trunk: 0x8A6A48, seed: 3)
        Kit.palm(&context, x: 872, baseY: H + 20, height: 252, lean: 16, fronds: 0x557F45, trunk: 0x7E6040, seed: 8)
        mudHouse(&context, cx: 780, baseY: H + 64, width: 150, height: 98)
        Kit.reeds(&context, x: 482, baseY: H + 70, count: 5, height: 70, seed: 12, color: 0x5E8A4E, papyrus: true)
    }

    /// The prince bowing, the kneeling servant, Dedi on his couch, and his chest of rolls.
    static func riverGroup(_ context: inout GraphicsContext, floorY H: CGFloat) {
        Kit.shadow(&context, 566, H + 87, width: 60)
        Art.group(&context, x: 566, y: H + 86, scaleX: -1) { g in
            prince(&g, pose: .bow, mouth: .smile, mirrored: true)
        }
        // "My books come too": the chest of rolls stands ready by the wall.
        Art.group(&context, x: 836, y: H + 80, scale: 0.8) { g in
            rollChest(&g)
        }
        // The couch at the door; Dedi sits up on it and holds out his hands to be pulled up.
        Art.group(&context, x: 716, y: H + 94) { g in
            couch(&g, length: 120)
            Art.group(&g, x: -10, y: 0) { d in
                dedi(&d, pose: .sit, mouth: .smile)
            }
        }
        // A servant kneels at his feet, rubbing the aches out of them.
        Kit.shadow(&context, 652, H + 101, width: 56)
        Art.group(&context, x: 652, y: H + 100, scaleX: -1) { g in
            courtier(&g, kind: 0, pose: .kneel, mouth: .smile, mirrored: true)
        }
    }

    /// What fills the deeper bank of a tall window: a trodden path from the door toward the
    /// viewer, near tufts, a beer jar and a loaf basket.
    static func riverFill(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let depth: CGFloat = nearDepth(st)
        let s: CGFloat = min(1.3, (depth - 150) / 66)
        guard s > 0.5 else { return }
        let H: CGFloat = st.Hv
        let near: CGFloat = H + depth + 10
        let trail: Path = Art.polygon([
            CGPoint(x: 700, y: H + 104), CGPoint(x: 736, y: H + 104),
            CGPoint(x: 800, y: near), CGPoint(x: 650, y: near),
        ])
        Art.fill(&context, trail, Art.color(0xE6D3A6, 0.7))
        Art.stroke(&context, trail, Art.color(0xA88C5C, 0.25), width: 1.2)
        let baseY: CGFloat = H + depth - 36
        Kit.grassTuft(&context, x: 560, baseY: baseY, height: 46 * s, color: 0x6F8F4A, seed: 2)
        Kit.grassTuft(&context, x: 880, baseY: baseY + 8, height: 54 * s, color: 0x5F8044, seed: 7)
        Kit.pot(&context, cx: 612, baseY: baseY - 34 * s, width: 26 * s, height: 50 * s, color: 0xB5603A)
    }
}

// MARK: - Scene: the goose made whole (pages 6–9)

extension KhufuArt {
    /// The hall from the other side: a pale sunlit plastered wall fills the upper left, with one
    /// soft column shadow. On the trailing half tiny Dedi lifts his staff over the whole, cross,
    /// cackling goose on the mat; King Khufu leans forward on his chair, astonished; two of the
    /// court gasp behind their hands. The linen cloth lies folded on the floor.
    static func magicScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        magicHall(&context, size, st)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                magicGroup(&n, floorY: st.Hv)
                courtFill(&n, st)
            }
            Kit.nearSpace(&v, st) { n in
                hallColumn(&n, x: 878, baseY: st.Hv + 150, width: 32, height: st.Hv + 190)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.1, vignette: 0.08)
    }

    /// The plastered wall, lit from an open side out of the frame on the left, with its soft
    /// column shadow, its painted band and a mat-hung door; the beam, the floor and one column.
    static func magicHall(_ context: inout GraphicsContext, _ size: CGSize, _ st: Kit.Stage) {
        let f: CGFloat = st.far
        let w: CGFloat = size.width
        let H: CGFloat = st.H
        let plaster: Kit.Stops = [(Art.color(0xFAF3E2), 0), (Art.color(plasterHex), 0.6), (Art.color(0xEEDFBE), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, H), plaster, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: H))
        Art.glow(&context, 170, H * 0.5, 420 * f, Art.color(0xFFF6DE), alpha: 0.55)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: H), seed: 61, alpha: 0.05)
        // One soft column shadow falling across the wall.
        let fall: Path = Art.polygon([
            CGPoint(x: 236, y: 0), CGPoint(x: 278, y: 0), CGPoint(x: 336, y: H), CGPoint(x: 290, y: H),
        ])
        Art.fill(&context, fall, ArtStyle.coolShade.opacity(0.045))
        let core: Path = Art.polygon([
            CGPoint(x: 248, y: 0), CGPoint(x: 268, y: 0), CGPoint(x: 324, y: H), CGPoint(x: 302, y: H),
        ])
        Art.fill(&context, core, ArtStyle.coolShade.opacity(0.03))
        dado(&context, x0: 0, x1: w, y: H - 34 * f, height: 34 * f)
        matDoor(&context, rect: CGRect(x: 610, y: H - 156 * f, width: 64 * f, height: 156 * f))
        Art.fill(&context, Art.rect(0, 0, w, 16 * f), Art.color(0xE9DBB8))
        Art.fill(&context, Art.rect(0, 16 * f, w, 3), ArtStyle.coolShade.opacity(0.08))
        hallFloor(&context, size, top: H)
        // The sunlight lying on the floor near the open side.
        let pool: Path = Art.polygon([
            CGPoint(x: 0, y: H + 6), CGPoint(x: 300, y: H + 6), CGPoint(x: 430, y: size.height), CGPoint(x: 0, y: size.height),
        ])
        Art.fill(&context, pool, Color.white.opacity(0.12))
        let baseY: CGFloat = H + 18 * f
        let reach: CGFloat = size.height - baseY
        let fallFloor: Path = Art.polygon([
            CGPoint(x: 437, y: baseY), CGPoint(x: 455, y: baseY),
            CGPoint(x: 476 + reach * 0.7, y: size.height), CGPoint(x: 426 + reach * 0.7, y: size.height),
        ])
        Art.fill(&context, fallFloor, ArtStyle.coolShade.opacity(0.06))
        hallColumn(&context, x: 446, baseY: baseY, width: 20 * f, height: baseY - 14 * f)
    }

    /// The court in the moment the goose stands up whole. `floorY` is the line where the floor
    /// meets the wall.
    static func magicGroup(_ context: inout GraphicsContext, floorY H: CGFloat) {
        reedMat(&context, cx: 690, y: H + 46, width: 400, depth: 64)
        Art.group(&context, x: 476, y: H + 40, scale: 0.9) { g in
            rollChest(&g)
        }
        Kit.shadow(&context, 872, H + 47, width: 56)
        Art.group(&context, x: 872, y: H + 46) { g in
            gasper(&g, kind: 1)
        }
        Art.group(&context, x: 792, y: H + 56) { g in
            throne(&g)
            king(&g, pose: .amazed)
        }
        Kit.shadow(&context, 522, H + 65, width: 56)
        Art.group(&context, x: 522, y: H + 64, scaleX: -1) { g in
            gasper(&g, kind: 2, mirrored: true)
        }
        Art.group(&context, x: 552, y: H + 110) { g in
            linenCloth(&g)
        }
        Kit.shadow(&context, 604, H + 91, width: 46)
        Art.group(&context, x: 604, y: H + 90, scaleX: -1) { g in
            dedi(&g, pose: .cast, mouth: .smile, mirrored: true)
        }
        Kit.shadow(&context, 690, H + 101, width: 50)
        Art.group(&context, x: 690, y: H + 100, scale: 0.8, scaleX: -1) { g in
            goose(&g, cackling: true, mirrored: true)
        }
    }
}

// MARK: - Scene: the terrace and the half-built tomb (page 10)

extension KhufuArt {
    /// Barley and flax in the narrow green strip, paler far off.
    static func fieldStops() -> Kit.Stops {
        [(Art.color(0xBFC47E), 0), (Art.color(0xA2B26C), 0.5), (Art.color(0x86A05A), 1)]
    }

    /// A late pale-gold afternoon. Far and low on the leading pane, the half-built pyramid on
    /// the desert edge with its long ramp and tiny crew; then green fields and a harbour basin
    /// with moored boats; on the trailing half the whitewashed terrace, where King Khufu points
    /// out at his tomb and tiny Dedi stands beside him on his staff.
    static func pyramidScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 180)
        let light = afternoon()
        pyramidFar(&context, size, st, light: light)
        Kit.designSpace(&context, st) { v in
            Kit.nearSpace(&v, st) { n in
                terrace(&n, floorY: st.Hv)
            }
            Kit.nearSpace(&v, st, anchorX: 650) { n in
                terraceGroup(&n, floorY: st.Hv)
                terraceFill(&n, st)
            }
        }
        ArtStyle.finish(&context, size, wash: 0.12, vignette: 0.08)
    }

    /// The far and middle planes: sky, the desert edge, the pyramid, the fields and the basin.
    static func pyramidFar(_ context: inout GraphicsContext, _ size: CGSize, _ st: Kit.Stage, light: Kit.Light) {
        let f: CGFloat = st.far
        let w: CGFloat = size.width
        let H: CGFloat = st.H
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 700, H - 270 * f, scale: 0.7 * f, color: Color.white.opacity(0.45))
        Kit.cloud(&context, 520, H - 200 * f, scale: 0.45 * f, color: Color.white.opacity(0.35))
        cliffs(&context, width: w, baseY: H - 4 * f, height: 20 * f, color: light.far.opacity(0.7), seed: 31)
        let sandTop: CGFloat = H - 6 * f
        let sandBottom: CGFloat = H + 12 * f
        let sand: Kit.Stops = [(Art.color(0xF1DDAE), 0), (Art.color(0xE4C68E), 1)]
        Art.fillLinear(&context, Art.rect(0, sandTop, w, sandBottom - sandTop), sand, from: CGPoint(x: 0, y: sandTop), to: CGPoint(x: 0, y: sandBottom))
        Art.group(&context, x: 250, y: H, scale: 0.95 * f) { g in
            pyramidSite(&g)
        }
        ArtStyle.atmosphere(&context, width: w, top: H - 110 * f, bottom: H + 10 * f, color: light.haze, alpha: 0.3)
        // The green fields, from the desert edge toward the viewer.
        let fieldTop: CGFloat = H + 10 * f
        Kit.ground(&context, width: w, top: fieldTop, bottom: size.height, stops: fieldStops(), seed: 52)
        farPalms(&context, x0: 520, x1: w, baseY: fieldTop + 2, height: 30 * f, count: 7, color: Art.color(0x7C9968), seed: 13)
        Kit.crop(&context, x0: 0, x1: w, baseY: fieldTop + 20 * f, height: 7 * f, tops: false, color: 0xB4B86A, seed: 4)
        harbour(&context, top: fieldTop + 28 * f, scale: f)
        Kit.crop(&context, x0: 0, x1: w, baseY: fieldTop + 92 * f, height: 12 * f, tops: false, color: 0xA6B060, seed: 9)
    }

    /// The harbour basin cut into the fields: still water in a pale edge, with moored boats.
    static func harbour(_ context: inout GraphicsContext, top: CGFloat, scale s: CGFloat) {
        let cy: CGFloat = top + 22 * s
        let ry: CGFloat = 20 * s
        Art.fill(&context, Art.ellipse(250, cy + 2, 238, ry + 3), Art.color(0xE6D2A0))
        let basin: Path = Art.ellipse(250, cy, 230, ry)
        Art.fillLinear(&context, basin, waterStops(), from: CGPoint(x: 0, y: cy - ry), to: CGPoint(x: 0, y: cy + ry))
        Art.fill(&context, Art.ellipse(220, cy - ry * 0.3, 160, ry * 0.25), Art.color(0xFFF3CF, 0.35))
        Kit.rippleMarks(&context, x0: 60, x1: 440, y0: cy - ry * 0.6, y1: cy + ry * 0.7, count: 14, seed: 3, color: Color.white, alpha: 0.4)
        let boats: [(CGFloat, CGFloat)] = [(150, 0.11), (300, 0.13), (392, 0.1)]
        for boat in boats {
            Art.group(&context, x: boat.0, y: cy + ry * 0.2, scale: boat.1 * s) { g in
                riverBoat(&g, rowers: 0)
            }
        }
    }

    /// The whitewashed terrace of the trailing side: its floor, its low parapet with coping,
    /// its shaded leading end, and a palm of the garden below cropped by the trailing edge.
    static func terrace(_ context: inout GraphicsContext, floorY H: CGFloat) {
        let bottom: CGFloat = H + 700
        Kit.palm(&context, x: 914, baseY: H + 10, height: 330, lean: -44, fronds: 0x4E7A44, trunk: 0x7A5A40, seed: 5)
        let floor: Path = Art.polygon([
            CGPoint(x: 480, y: H + 40), CGPoint(x: 904, y: H + 40), CGPoint(x: 904, y: bottom), CGPoint(x: 400, y: bottom),
        ])
        let white: Kit.Stops = [(Art.color(0xF6ECD4), 0), (Art.color(0xEAD9B4), 0.5), (Art.color(0xDCC59A), 1)]
        Art.fillLinear(&context, floor, white, from: CGPoint(x: 0, y: H + 40), to: CGPoint(x: 0, y: H + 300))
        Kit.model(&context, floor, light: 0.14, shade: 0.12)
        let side: Path = Art.polygon([
            CGPoint(x: 474, y: H + 40), CGPoint(x: 480, y: H + 40), CGPoint(x: 400, y: bottom), CGPoint(x: 380, y: bottom),
        ])
        Art.fill(&context, side, Art.color(0xCDB48A))
        Kit.wall(&context, rect: CGRect(x: 480, y: H + 4, width: 424, height: 38), color: plasterHex)
        dado(&context, x0: 480, x1: 904, y: H + 28, height: 14)
        Art.fill(&context, Art.rect(474, H - 2, 436, 8, radius: 2), Art.color(0xFBF4E2))
        Art.fill(&context, Art.rect(474, H + 6, 436, 2), ArtStyle.coolShade.opacity(0.12))
        Art.fill(&context, Art.rect(474, H - 2, 8, 44), Art.color(0xE4D2AC))
    }

    /// King Khufu points out at his tomb; Dedi stands beside him, nearer, on his staff. Their
    /// long afternoon shadows fall away from the light.
    static func terraceGroup(_ context: inout GraphicsContext, floorY H: CGFloat) {
        let spots: [(CGFloat, CGFloat, CGFloat)] = [(700, H + 112, 58), (604, H + 118, 40)]
        for spot in spots {
            let x: CGFloat = spot.0
            let y: CGFloat = spot.1
            let half: CGFloat = spot.2 * 0.4
            let reach: CGFloat = spot.2 * 2.4
            let lie: Path = Art.polygon([
                CGPoint(x: x - half, y: y), CGPoint(x: x + half, y: y),
                CGPoint(x: x + reach + half, y: y + 26), CGPoint(x: x + reach - half, y: y + 30),
            ])
            Art.fill(&context, lie, ArtStyle.coolShade.opacity(0.1))
            Kit.shadow(&context, x, y + 1, width: spot.2)
        }
        Art.group(&context, x: 700, y: H + 112) { g in
            king(&g, pose: .point)
        }
        Art.group(&context, x: 604, y: H + 118) { g in
            dedi(&g, pose: .staff, mouth: .smile)
        }
    }

    /// What fills the deeper terrace of a tall window: a mat with the first of Dedi's
    /// thousand loaves, and a tall jar.
    static func terraceFill(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let depth: CGFloat = nearDepth(st)
        let s: CGFloat = min(1.3, (depth - 160) / 66)
        guard s > 0.5 else { return }
        let baseY: CGFloat = st.Hv + depth - 40
        reedMat(&context, cx: 570, y: baseY - 26 * s, width: 200 * s, depth: 40 * s)
        Art.group(&context, x: 570, y: baseY, scale: s) { g in
            rations(&g)
        }
        Kit.pot(&context, cx: 820, baseY: baseY - 10 * s, width: 34 * s, height: 70 * s, color: 0xB5603A, band: 0xF1E5C6)
    }
}
