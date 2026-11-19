import SwiftUI
import OmramoCore

/// Concept art for "The Griot’s Apprentice", drawn in code (round 5; composed from the shared kit).
enum GriotArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-compound", .sceneUnfolded): compoundScene(&context, size)
        case ("scene-compound", .sceneFolded): compoundFolded(&context, size)
        case ("scene-river", .sceneUnfolded): riverScene(&context, size)
        case ("scene-river", .sceneFolded): riverFolded(&context, size)
        case ("scene-feast", .sceneUnfolded): feastScene(&context, size)
        case ("scene-feast", .sceneFolded): feastFolded(&context, size)
        case ("scene-dawn", .sceneUnfolded): dawnScene(&context, size)
        case ("scene-dawn", .sceneFolded): dawnFolded(&context, size)
        case ("see-jeli", .picture): jeliPicture(&context, size)
        case ("see-river-niger", .picture): riverNigerPicture(&context, size)
        case ("see-balafon", .picture): balafonPicture(&context, size)
        case ("see-salt-and-gold", .picture): saltAndGoldPicture(&context, size)
        case ("char-apprentice", .portrait): apprenticePortrait(&context, size)
        case ("char-grandfather", .portrait): grandfatherPortrait(&context, size)
        case ("face-apprentice", .face): apprenticeFace(&context, size)
        case ("face-grandfather", .face): grandfatherFace(&context, size)
        case ("face-merchant", .face): merchantFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Scene 1: the compound in the early morning

extension GriotArt {
    /// The far shore of the flood with its doum palms, low under a wide milky sky; the brown
    /// river below it (picture units). The compound scene's far plane.
    static func floodFar(_ context: inout GraphicsContext, _ size: CGSize, _ st: Kit.Stage, light: Kit.Light, waterDepth: CGFloat) {
        let w: CGFloat = size.width
        Kit.farTrees(&context, x0: 0, x1: w, baseY: st.H + 1, height: 15 * st.far, count: 24, color: light.far, seed: 3)
        let palms: [(CGFloat, CGFloat)] = [(96, 34), (138, 28), (602, 30), (812, 38)]
        for palm in palms {
            Kit.palm(&context, x: palm.0, baseY: st.H + 2, height: palm.1 * st.far, lean: 3, fronds: 0xB4B096, trunk: 0xB8A68E, seed: 5)
        }
        ArtStyle.atmosphere(&context, width: w, top: st.H - 50 * st.far, bottom: st.H + 4, color: light.haze, alpha: 0.4)
        let riverStops: Kit.Stops = Kit.stops(0xCFC1A6, 0xB29C7A)
        Kit.water(&context, width: w, top: st.H, bottom: st.H + waterDepth, stops: riverStops, light: light, ripples: 30, seed: 9)
    }

    static func compoundScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = morning()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 168, st.H - 46 * st.far, 15 * st.far, light: light)
        Kit.cloud(&context, 640, 92 * st.fit, scale: 0.8, color: Color.white.opacity(0.5))
        Kit.cloud(&context, 790, 150 * st.fit, scale: 0.5, color: Color.white.opacity(0.4))
        floodFar(&context, size, st, light: light, waterDepth: 60 * st.fit)
        let yard: Kit.Stops = Kit.stops(0xE8D0A6, 0xD2AA76)
        Kit.ground(&context, width: size.width, top: st.H + 50 * st.fit, bottom: size.height, stops: yard, seed: 61)
        Kit.designSpace(&context, st) { v in
            compoundBack(&v, st)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                compoundCast(&n, st)
                if st.tall > 0.25 {
                    compoundFill(&n, st)
                }
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x6A5A2E), scale: 0.7, seed: 4)
        ArtStyle.finish(&context, size)
    }

    /// Behind the courtyard: a fisherman and the moored boat with the striped awning out on the
    /// flood, the low far wall, the rooms, the granary and the baobab (design units).
    static func compoundBack(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        Art.group(&v, x: 112, y: H + 14, scale: 0.34) { b in
            boatman(&b, boatmanLook(0xD8CCB4), poleDown: 40)
        }
        pirogue(&v, cx: 116, waterY: H + 15, length: 96)
        pirogue(&v, cx: 300, waterY: H + 20, length: 150, awning: true)
        mudWall(&v, x0: -260, x1: 1160, baseY: H + 52, height: 22)
        bancoHouse(&v, cx: 498, baseY: H + 56, width: 92, height: 54)
        bancoHouse(&v, cx: 396, baseY: H + 54, width: 64, height: 40, door: false)
        granary(&v, cx: 580, baseY: H + 58, width: 40, height: 64)
        baobab(&v, x: 712, baseY: H + 60, scale: 0.52)
        Kit.pot(&v, cx: 452, baseY: H + 66, width: 18, height: 22, color: 0xB0683A)
        Kit.pot(&v, cx: 470, baseY: H + 68, width: 14, height: 17, color: 0x9A5A32)
    }

    /// Sira singing with her chin up, Lamine at the balafon, Jeli Madi listening on his mat by
    /// the doorway of his room (design units, grown on a tall window).
    static func compoundCast(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        bancoHouse(&n, cx: 862, baseY: H + 72, width: 124, height: 76)
        Kit.pot(&n, cx: 770, baseY: H + 76, width: 22, height: 27, color: 0xB0683A, band: 0x7A3A22)
        mat(&n, cx: 806, baseY: H + 92, width: 74)
        Art.group(&n, x: 806, y: H + 88, scale: 0.86) { g in
            madi(&g, mouth: .flat, look: CGPoint(x: -0.7, y: 0.1))
        }
        Art.group(&n, x: 700, y: H + 92, scale: 0.92) { g in
            lamine(&g)
        }
        Art.group(&n, x: 596, y: H + 94, scale: 1.0) { g in
            sira(&g, pose: .stand, mouth: .open, look: CGPoint(x: -0.3, y: -0.5))
        }
        Kit.grassTuft(&n, x: 540, baseY: H + 96, height: 12, color: 0x8A8A44, seed: 3)
        Kit.grassTuft(&n, x: 660, baseY: H + 100, height: 10, color: 0x8A8A44, seed: 8)
    }

    /// The deeper courtyard of a tall window: a mortar and pestle for the millet, a heap of
    /// jars, sandal prints in the sand, tufts toward the viewer.
    static func compoundFill(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let y0: CGFloat = H + 120 + 20 * st.tall
        mortar(&n, cx: 560, baseY: y0)
        Kit.pot(&n, cx: 760, baseY: y0 + 20, width: 30, height: 36, color: 0xB0683A, band: 0x7A3A22)
        Kit.pot(&n, cx: 790, baseY: y0 + 26, width: 22, height: 26, color: 0x9A5A32)
        Kit.basket(&n, cx: 650, baseY: y0 + 40, width: 34, height: 18, color: 0xC89A54)
        Kit.heap(&n, cx: 650, baseY: y0 + 26, width: 28, count: 6, color: 0xB03A2A, leaf: 0x6A7A3A, seed: 5)
        var prints = Path()
        for i in 0..<6 {
            let t: CGFloat = CGFloat(i)
            let px: CGFloat = 600 - t * 22 + (i % 2 == 0 ? 0 : 8)
            let py: CGFloat = H + 120 + t * 18
            prints.addPath(Art.ellipse(px, py, 3.4, 1.6))
        }
        Art.fill(&n, prints, ArtStyle.coolShade.opacity(0.1))
        Kit.grassTuft(&n, x: 500, baseY: y0 + 70, height: 18, color: 0x7A7A3A, seed: 11)
        Kit.grassTuft(&n, x: 860, baseY: y0 + 90, height: 22, color: 0x6A6A34, seed: 12)
        Kit.rock(&n, cx: 700, baseY: y0 + 96, width: 30, height: 14, color: 0xB89A78, seed: 2)
    }

    /// A wooden mortar with a pestle standing in it, origin at its foot.
    static func mortar(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat) {
        Kit.shadow(&context, cx, baseY, width: 30)
        let body: Path = Art.svg("M-12,0 C-10,-6 -8,-12 -11,-18 C-12,-26 -14,-30 -13,-32 L13,-32 C14,-30 12,-26 11,-18 C8,-12 10,-6 12,0Z").applying(CGAffineTransform(translationX: cx, y: baseY))
        Kit.solid(&context, body, Art.color(0x7A5230), light: 0.3, shade: 0.3, rim: 1.4)
        Kit.propShaft(&context, cx + 2, baseY - 30, cx - 6, baseY - 78, wood: 0xA07A4A, width: 4)
    }
}

// MARK: - Scene 2: the salt boat on the flood

extension GriotArt {
    static func riverScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = afternoon()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 210, st.H - 52 * st.far, 18 * st.far, light: light)
        Kit.cloud(&context, 700, 86 * st.fit, scale: 0.9, color: Color.white.opacity(0.4))
        Kit.farTrees(&context, x0: 0, x1: w, baseY: st.H + 1, height: 10 * st.far, count: 30, color: light.far, seed: 17)
        islandTown(&context, x0: 96, x1: 236, baseY: st.H + 3, height: 14 * st.far, light: light)
        Kit.palm(&context, x: 250, baseY: st.H + 2, height: 30 * st.far, lean: -2, fronds: 0xAEAC92, trunk: 0xB4A28A, seed: 7)
        ArtStyle.atmosphere(&context, width: w, top: st.H - 50 * st.far, bottom: st.H + 4, color: light.haze, alpha: 0.38)
        let flood: Kit.Stops = Kit.stops(0xD6CEB8, 0x9EA18C)
        Kit.water(&context, width: w, top: st.H, bottom: size.height, stops: flood, light: light, ripples: 60, seed: 21)
        Kit.glints(&context, x: 210, top: st.H, depth: 150 * st.fit, color: Color.white, count: 34, seed: 4)
        riceStrips(&context, x0: 0, x1: 420 * st.fit, y: st.H + 8 * st.fit, scale: st.fit)
        Kit.birds(&context, 320, st.H - 26 * st.far, scale: 0.7, color: Art.color(0x9A8E7A))
        Kit.designSpace(&context, st) { v in
            let H: CGFloat = st.Hv
            islandTown(&v, x0: 560, x1: 930, baseY: H + 10, height: 34, light: light)
            landingCrowd(&v, H: H + 12)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                saltBoat(&n, H: H)
                if st.tall > 0.25 {
                    riverFill(&n, st)
                }
            }
        }
        weaverReeds(&context, x: 34, baseY: size.height + 4, height: 120 * st.fit, seed: 7)
        ArtStyle.finish(&context, size)
    }

    /// Green rice standing in the flood: low strips of blades from x0 to x1 (picture units).
    static func riceStrips(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, scale: CGFloat) {
        guard x1 > x0 else { return }
        let rows: [(CGFloat, CGFloat, CGFloat)] = [(0.0, 0.55, 0), (0.25, 0.9, 10), (0.05, 0.4, 22)]
        for row in rows {
            let a: CGFloat = x0 + (x1 - x0) * row.0
            let b: CGFloat = x0 + (x1 - x0) * row.1
            let ry: CGFloat = y + row.2 * scale
            let rect = CGRect(x: a, y: ry - 5 * scale, width: b - a, height: 5 * scale)
            Kit.grass(&context, in: rect, count: Int((b - a) / 3), seed: 31, color: Art.color(0x7E9A4E), height: 6 * scale)
            Art.fill(&context, Art.rect(a, ry, b - a, 1.6 * scale), Art.color(0x6A7E44, 0.4))
        }
    }

    /// The small crowd on Djenné's landing: porters with salt slabs on their heads, a trader
    /// under a matting awning (design units, far away).
    static func landingCrowd(_ v: inout GraphicsContext, H: CGFloat) {
        let awning: Path = Art.svg("M592,-22 L640,-26 L644,-20 L594,-16Z").applying(CGAffineTransform(translationX: 0, y: H))
        Kit.solid(&v, awning, Art.color(0xCDB284), light: 0.2, shade: 0.2)
        Art.stroke(&v, Art.svg("M596,-16 L596,0 M640,-20 L640,0").applying(CGAffineTransform(translationX: 0, y: H)), Art.color(0x7A5A3A), width: 1.2)
        let people: [(CGFloat, UInt32, Bool)] = [(604, 0xEDE6D8, false), (622, 0x3A4A86, true), (660, 0xE6DCC8, true), (684, 0x2F3F86, false), (712, 0xDCCFB8, true)]
        for person in people {
            Art.group(&v, x: person.0, y: H, scale: 0.2) { g in
                let p = manLook(person.1, cap: 0xEDE6D8, beard: .none)
                Kit.shadow(&g, 0, 0, width: 40)
                Kit.person(&g, p, pose: person.2 ? .walk : .stand, mouth: .flat)
                if person.2 {
                    Kit.solid(&g, Art.rect(-22, -186, 44, 16, radius: 3), Art.color(saltGrey), light: 0.3, shade: 0.3)
                }
            }
        }
        ArtStyle.atmosphere(&v, width: 960, top: H - 50, bottom: H + 4, color: Art.color(0xF0E4CA), alpha: 0.25)
    }

    /// The long salt boat, poled toward the town by four boatmen, Lamine beside the wrapped
    /// balafon and Sira in the bow at the right, looking toward Djenné (design units).
    static func saltBoat(_ n: inout GraphicsContext, H: CGFloat) {
        let waterY: CGFloat = H + 72
        let deck: CGFloat = waterY - 17
        let crew: [(CGFloat, CGFloat, UInt32)] = [(540, deck, 0xD8CCB4), (578, deck, 0x2F3F86)]
        for man in crew {
            Art.group(&n, x: man.0, y: man.1, scale: 0.6) { g in
                boatman(&g, boatmanLook(man.2), poleDown: 52 / 0.6)
            }
        }
        pirogue(&n, cx: 700, waterY: waterY, length: 340, salt: true)
        Art.group(&n, x: 682, y: deck - 40, scale: 0.5) { g in
            boatman(&g, boatmanLook(0xE6DCC8), poleDown: 140)
        }
        Art.group(&n, x: 766, y: deck, scale: 0.6) { g in
            Art.group(&g, scaleX: -1) { m in
                boatman(&m, boatmanLook(0x5A4A3A), poleDown: 86)
            }
        }
        balafon(&n, x: 790, baseY: deck, scale: 0.36, wrapped: true)
        Art.group(&n, x: 806, y: deck, scale: 0.82) { g in
            Art.group(&g, scaleX: -1) { m in
                crossLegged(&m, lamineLook(), look: CGPoint(x: 0.4, y: 0), mouth: .smile, mirrored: true)
            }
        }
        Art.group(&n, x: 842, y: deck + 1, scale: 0.84) { g in
            Art.group(&g, scaleX: -1) { m in
                crossLegged(&m, siraLook(), look: CGPoint(x: 0.6, y: -0.6), mouth: .flat, mirrored: true)
            }
        }
        Kit.ripples(&n, 520, waterY + 10, 40, count: 2, color: Color.white, opacity: 0.4)
    }

    /// The deeper flood of a tall window: a fisherman's pirogue nearer the viewer with its
    /// nets heaped, and ripple marks.
    static func riverFill(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let y: CGFloat = st.Hv + 130 + 20 * st.tall
        Art.group(&n, x: 560, y: y - 6, scale: 0.8) { g in
            boatman(&g, boatmanLook(0xC9BBA2), poleDown: 70)
        }
        pirogue(&n, cx: 620, waterY: y, length: 200)
        Kit.heap(&n, cx: 650, baseY: y - 9, width: 40, count: 6, color: 0x8A7A5A, seed: 4)
        Kit.rippleMarks(&n, x0: 460, x1: 900, y0: y + 20, y1: y + 200, count: 30, seed: 5, color: Color.white)
    }
}

// MARK: - Scene 3: the feast in Bakary's courtyard

extension GriotArt {
    /// The guests, by turn: men in white and indigo robes, women in wraps and head-wraps.
    static func guestLook(_ index: Int) -> Kit.Person {
        switch index % 5 {
        case 0: return manLook(cotton, cap: cotton, beard: .short)
        case 1: return womanLook(cotton, wrap: indigo)
        case 2: return manLook(indigo, cap: 0xE8DCC4, beard: .none)
        case 3: return womanLook(indigo, wrap: 0xE8DCC4)
        default: return manLook(0xE6DCC8, cap: indigo, beard: .long)
        }
    }

    /// A row of guests on mats from x0, `step` apart, all turned toward the singer (right).
    static func guestRow(_ v: inout GraphicsContext, x0: CGFloat, y: CGFloat, count: Int, step: CGFloat, scale: CGFloat, first: Int) {
        let matWidth: CGFloat = step * CGFloat(count) + 20
        mat(&v, cx: x0 + matWidth / 2 - step * 0.5 - 10, baseY: y + 4, width: matWidth, color: 0xD4B47C)
        for i in 0..<count {
            let gx: CGFloat = x0 + step * CGFloat(i)
            let look = guestLook(first + i)
            Art.group(&v, x: gx, y: y, scale: scale) { g in
                guest(&g, look, mirrored: true, bowl: i % 2 == 0)
            }
        }
    }

    static func feastScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = evening()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 560, 110 * st.fit, scale: 0.7, color: Color.white.opacity(0.35))
        let roofs: [(CGFloat, CGFloat, CGFloat)] = [(60, 70, 22), (170, 90, 30), (300, 60, 18), (430, 110, 26), (600, 80, 24), (760, 100, 30)]
        for roof in roofs {
            Kit.farHouse(&context, cx: roof.0, baseY: st.H - 28 * st.fit, width: roof.1 * st.far, height: roof.2 * st.far, wall: light.far, roof: light.mid, flat: true)
        }
        ArtStyle.atmosphere(&context, width: w, top: st.H - 70 * st.far, bottom: st.H - 20 * st.fit, color: light.haze, alpha: 0.42)
        let floor: Kit.Stops = Kit.stops(0xE2BE88, 0xC6985E)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: floor, seed: 44)
        mudWall(&context, x0: -30, x1: w + 30, baseY: st.H + 6 * st.fit, height: 38 * st.fit, color: bancoLit)
        let niches: [CGFloat] = [70, 190, 310, 430, 560]
        for nx in niches {
            lampNiche(&context, cx: nx * st.fit + 892 * (1 - st.fit), cy: st.H - 12 * st.fit, scale: st.fit)
        }
        Kit.designSpace(&context, st) { v in
            let H: CGFloat = st.Hv
            gate(&v, x: 866, H: H)
            lampNiche(&v, cx: 700, cy: H - 12)
            guestRow(&v, x0: 40, y: H + 40, count: 7, step: 70, scale: 0.55, first: 0)
            server(&v, x: 536, y: H + 56)
            Kit.nearSpace(&v, st, anchorX: 700) { n in
                feastCast(&n, H: H)
                if st.tall > 0.25 {
                    guestRow(&n, x0: 90, y: H + 150 + 40 * st.tall, count: 3, step: 150, scale: 0.95, first: 3)
                    Kit.bowl(&n, cx: 600, baseY: H + 160 + 40 * st.tall, width: 34, color: 0x7A4A2A, filling: 0xF2E8D2)
                }
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 3, color: Art.color(0x5A3A1E), scale: 0.6, seed: 9)
        ArtStyle.finish(&context, size)
    }

    /// The open gate in the far wall, with the last light outside and Fodé and the girl with
    /// the gourd listening just beyond it (design units).
    static func gate(_ v: inout GraphicsContext, x: CGFloat, H: CGFloat, scale: CGFloat = 1) {
        Art.group(&v, x: x, y: H, scale: scale) { g in
            let opening: Path = Art.rect(-20, -32, 40, 38, radius: 4)
            let outside: Kit.Stops = Kit.stops(0xF8E8C4, 0xEBCB92)
            Art.fillLinear(&g, opening, outside, from: CGPoint(x: 0, y: -32), to: CGPoint(x: 0, y: 6))
            Art.group(&g, x: 0, y: 5, scale: 0.26) { w in
                gateWatchers(&w)
            }
            let posts: Path = Art.svg("M-26,6 L-25,-34 C-24,-38 -18,-38 -17,-34 L-16,6Z M16,6 L17,-34 C18,-38 24,-38 25,-34 L26,6Z")
            Kit.solid(&g, posts, Art.color(banco), light: 0.28, shade: 0.3, rim: 1.4)
        }
    }

    /// A woman in gold earrings carrying a bowl of rice among the guests (design units).
    static func server(_ v: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        let p = womanLook(cotton, wrap: indigo)
        Art.group(&v, x: x, y: y, scale: 0.62) { g in
            Kit.shadow(&g, 0, 0, width: 44)
            Kit.person(&g, p, pose: .carry, look: CGPoint(x: -0.5, y: 0.3), mouth: .smile)
            let h: CGPoint = Kit.hand(p, pose: .carry)
            Kit.bowl(&g, cx: h.x - 8, baseY: h.y + 4, width: 26, color: 0x7A4A2A, filling: 0xF2E8D2)
            Art.fill(&g, Art.circle(-26, -136, 2.4), Art.color(gold))
        }
    }

    /// Bakary on his raised seat, Sira standing in the open space singing, Lamine kneeling at
    /// the balafon turned toward her, cowries at her feet, the front row of guests (design
    /// units, grown on a tall window).
    static func feastCast(_ n: inout GraphicsContext, H: CGFloat) {
        Art.group(&n, x: 786, y: H + 76, scale: 0.72) { g in
            bakary(&g, mouth: .smile, look: CGPoint(x: -0.6, y: 0.1))
        }
        Kit.lamp(&n, cx: 846, cy: H + 60, radius: 3, color: 0xFFC96B)
        Art.group(&n, x: 600, y: H + 104, scale: 0.92) { g in
            Art.group(&g, scaleX: -1) { m in
                lamine(&m, mirrored: true)
            }
        }
        Art.group(&n, x: 676, y: H + 102, scale: 1.0) { g in
            sira(&g, pose: .stand, mouth: .open, look: CGPoint(x: -0.4, y: -0.4))
        }
        cowries(&n, x: 652, y: H + 108)
        guestRow(&n, x0: 30, y: H + 88, count: 6, step: 88, scale: 0.68, first: 2)
    }

    /// A few cowrie shells and a string of them dropped on the ground at (x, y).
    static func cowries(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        let places: [(CGFloat, CGFloat)] = [(0, 0), (7, 2), (13, -1), (-6, 3), (20, 3), (26, 1)]
        for place in places {
            let shell: Path = Art.ellipse(x + place.0, y + place.1, 2.6, 1.8)
            Kit.solid(&context, shell, Art.color(0xF4EEDC), light: 0.4, shade: 0.3)
            Art.stroke(&context, Art.line(x + place.0 - 1.6, y + place.1, x + place.0 + 1.6, y + place.1), Art.color(0xB8A890), width: 0.7)
        }
        Art.stroke(&context, Art.svg("M-2,1 C6,5 16,5 28,2").applying(CGAffineTransform(translationX: x, y: y)), Art.color(0xA8742A, 0.6), width: 0.8)
    }
}

// MARK: - Scene 4: dawn on the riverbank

extension GriotArt {
    static func dawnScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let light = dawn()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 150, st.H - 10 * st.far, 20 * st.far, light: light)
        Kit.cloud(&context, 620, 100 * st.fit, scale: 0.8, color: Art.color(0xFFF4EE, 0.5))
        Kit.cloud(&context, 300, 70 * st.fit, scale: 0.5, color: Art.color(0xFFF4EE, 0.35))
        Kit.farTrees(&context, x0: 0, x1: w, baseY: st.H + 1, height: 12 * st.far, count: 26, color: light.far, seed: 27)
        let palms: [(CGFloat, CGFloat)] = [(250, 30), (290, 24), (690, 32)]
        for palm in palms {
            Kit.palm(&context, x: palm.0, baseY: st.H + 2, height: palm.1 * st.far, lean: 2, fronds: 0xC4AEA6, trunk: 0xC0A89C, seed: 9)
        }
        ArtStyle.atmosphere(&context, width: w, top: st.H - 50 * st.far, bottom: st.H + 4, color: light.haze, alpha: 0.4)
        let still: Kit.Stops = Kit.stops(0xF2DCD0, 0xB4A6A6)
        Kit.water(&context, width: w, top: st.H, bottom: size.height, stops: still, light: light, ripples: 26, seed: 33)
        Kit.glints(&context, x: 150, top: st.H, depth: 200 * st.fit, color: Art.color(0xFFF4E8), count: 46, seed: 12)
        Kit.designSpace(&context, st) { v in
            let H: CGFloat = st.Hv
            Art.group(&v, x: 296, y: H + 22, scale: 0.3) { b in
                boatman(&b, boatmanLook(0xC9BBA2), poleDown: 50)
            }
            pirogue(&v, cx: 300, waterY: H + 24, length: 90)
            Kit.birds(&v, 380, H - 36, scale: 0.8, color: Art.color(0xA08A88))
            Kit.nearSpace(&v, st, anchorX: 720) { n in
                dawnBank(&n, st)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x5A5A3A), scale: 0.7, seed: 6)
        ArtStyle.finish(&context, size)
    }

    /// The bank: a low rise of earth on the trailing side, reeds with weaverbird nests at its
    /// edges, the old man and the girl side by side looking over the river, the cotton bundle
    /// in her lap, the balafon on the ground by Lamine a little apart (design units).
    static func dawnBank(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let earth: Kit.Stops = Kit.stops(0xC09676, 0x7E6048)
        Kit.mound(&n, x0: 468, x1: 1010, baseY: H + 74, height: 28, bottom: st.hv + 60, stops: earth, crest: 0.4)
        Kit.grass(&n, in: CGRect(x: 480, y: H + 44, width: 420, height: 14), count: 60, seed: 3, color: Art.color(0x7A7A44), height: 8)
        weaverReeds(&n, x: 492, baseY: H + 80, height: 74, seed: 15)
        Art.group(&n, x: 560, y: H + 54, scale: 0.84) { g in
            crossLegged(&g, lamineLook(), look: CGPoint(x: -0.6, y: 0), mouth: .smile)
        }
        balafon(&n, x: 604, baseY: H + 56, scale: 0.42)
        Art.group(&n, x: 700, y: H + 50, scale: 0.94) { g in
            crossLegged(&g, siraLook(), look: CGPoint(x: -0.6, y: -0.2), mouth: .smile)
        }
        cottonBundle(&n, x: 694, y: H + 39, scale: 0.9)
        Art.group(&n, x: 760, y: H + 50, scale: 0.92) { g in
            madi(&g, mouth: .smile, look: CGPoint(x: -0.7, y: -0.1))
        }
        weaverReeds(&n, x: 884, baseY: H + 66, height: 96, seed: 19)
        if st.tall > 0.25 {
            let y: CGFloat = H + 120 + 20 * st.tall
            Kit.grassTuft(&n, x: 560, baseY: y, height: 18, color: 0x6A6A3A, seed: 21)
            Kit.grassTuft(&n, x: 820, baseY: y + 40, height: 22, color: 0x5E5E34, seed: 22)
            Kit.pebbles(&n, in: CGRect(x: 600, y: y - 30, width: 200, height: 60), count: 18, seed: 4, color: 0x9A7E66)
            Kit.flowers(&n, in: CGRect(x: 640, y: y + 10, width: 160, height: 40), count: 8, seed: 6, petal: 0xF4E0D6)
        }
    }
}
