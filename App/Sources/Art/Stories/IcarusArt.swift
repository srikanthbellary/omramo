import SwiftUI
import OmramoCore

/// Concept art for "Daedalus and Icarus", drawn in code (round 5; composed from the shared kit).
///
/// An Advanced, light story: the words sit in the top of both panes, so every unfolded scene
/// keeps a low horizon and a pale, calm sky (or pale wall) across the whole width. The cast,
/// the light and the shared parts (wings, feathers, Minoan columns, islands) live in
/// `IcarusArt+Cast.swift`; the folded phone bands in `IcarusArt+Folded.swift`; the tap
/// pictures, portraits, faces and the cover in `IcarusArt+Pictures.swift`.
enum IcarusArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-workshop", .sceneUnfolded): workshopScene(&context, size)
        case ("scene-workshop", .sceneFolded): workshopFolded(&context, size)
        case ("scene-palace", .sceneUnfolded): palaceScene(&context, size)
        case ("scene-palace", .sceneFolded): palaceFolded(&context, size)
        case ("scene-tower", .sceneUnfolded): towerScene(&context, size)
        case ("scene-tower", .sceneFolded): towerFolded(&context, size)
        case ("scene-sea", .sceneUnfolded): seaScene(&context, size)
        case ("scene-sea", .sceneFolded): seaFolded(&context, size)
        case ("see-crete", .picture): cretePicture(&context, size)
        case ("see-labyrinth", .picture): labyrinthPicture(&context, size)
        case ("see-beeswax", .picture): beeswaxPicture(&context, size)
        case ("see-icarian-sea", .picture): icarianSeaPicture(&context, size)
        case ("char-daedalus", .portrait): daedalusPortrait(&context, size)
        case ("char-icarus", .portrait): icarusPortrait(&context, size)
        case ("face-daedalus", .face): daedalusFace(&context, size)
        case ("face-icarus", .face): icarusFace(&context, size)
        case ("face-minos", .face): minosFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - Scene 1: the workshop at the top of the tower

extension IcarusArt {
    /// The top room of the tower in pale morning light: a limestone wall with a wide open
    /// window of white sky and calm sea (the words sit on it), and low on the right the long
    /// bench of tools, the wax pot and candles, the rows of feathers and Icarus kneeling among
    /// them, blowing one small feather up.
    static func workshopScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let wallStops: Kit.Stops = [(Art.color(0xF5EFE2), 0), (Art.color(0xEFE5D2), 0.7), (Art.color(0xE6D7BC), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, st.H), wallStops, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: st.H))
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: st.H), seed: 41, color: Art.color(0xB89A70), alpha: 0.05)
        Kit.ground(&context, width: w, top: st.H, bottom: h, stops: Kit.stops(0xDCC7A2, 0xC9AE86, 0xB8996F), seed: 43)
        Kit.designSpace(&context, st) { v in
            workshopWindow(&v, st)
            workshopFloor(&v, st)
            workshopLeading(&v, st)
            Kit.nearSpace(&v, st) { n in
                workshopBench(&n, st)
            }
            Kit.nearSpace(&v, st, anchorX: 560) { n in
                workshopIcarus(&n, st)
            }
            workshopNear(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    /// The wide window: stone frame, white sky, a calm band of sea with a far headland and a
    /// sail, pale open shutters, the sill. Everything here is pale: the words sit on it.
    static func workshopWindow(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let top: CGFloat = max(56, st.Hv - 430)
        let bottom: CGFloat = st.Hv - 118
        let x0: CGFloat = 300
        let x1: CGFloat = 770
        let ww: CGFloat = x1 - x0
        let wh: CGFloat = max(60, bottom - top)
        let frame = Art.rect(x0 - 18, top - 18, ww + 36, wh + 30, radius: 4)
        Kit.solid(&g, frame, Art.color(0xE3D5BB), light: 0.2, shade: 0.12)
        let seaTop: CGFloat = top + wh * 0.7
        let skyStops: Kit.Stops = [(Art.color(0xFBFBF7), 0), (Art.color(0xF1F5F4), 0.75), (Art.color(0xF7F0DE), 1)]
        Art.fillLinear(&g, Art.rect(x0, top, ww, seaTop - top), skyStops, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: seaTop))
        let seaStops: Kit.Stops = [(Art.color(0xC3DDEB), 0), (Art.color(0xA9CDE2), 1)]
        let seaH: CGFloat = top + wh - seaTop
        Art.fillLinear(&g, Art.rect(x0, seaTop, ww, seaH), seaStops, from: CGPoint(x: 0, y: seaTop), to: CGPoint(x: 0, y: top + wh))
        // A far headland on the right of the window and one far square sail.
        var cape = Path()
        cape.move(to: CGPoint(x: x1 - 170, y: seaTop))
        cape.addQuadCurve(to: CGPoint(x: x1 - 60, y: seaTop - 16), control: CGPoint(x: x1 - 120, y: seaTop - 4))
        cape.addQuadCurve(to: CGPoint(x: x1, y: seaTop - 22), control: CGPoint(x: x1 - 30, y: seaTop - 26))
        cape.addLine(to: CGPoint(x: x1, y: seaTop))
        cape.closeSubpath()
        Art.fill(&g, cape, Art.color(0xCBD8DA))
        let sailX: CGFloat = x0 + ww * 0.34
        let sailY: CGFloat = seaTop + seaH * 0.35
        Art.fill(&g, Art.rect(sailX - 4, sailY - 10, 8, 8), Art.color(0xF4EFE4))
        Art.stroke(&g, Art.line(sailX - 7, sailY, sailX + 6, sailY), Art.color(0x8FA9B8), width: 1.4)
        Kit.ripples(&g, x0 + ww * 0.62, seaTop + seaH * 0.55, 40, count: 2, color: Color.white, opacity: 0.35)
        // The deep reveal on the right (the light comes from the upper left) and the sill.
        Art.fill(&g, Art.rect(x1 - 20, top, 20, wh), ArtStyle.coolShade.opacity(0.09))
        Art.fill(&g, Art.rect(x0, top, ww, 10), ArtStyle.coolShade.opacity(0.06))
        Kit.solid(&g, Art.rect(x0 - 28, top + wh, ww + 56, 14, radius: 3), Art.color(0xDDCDAE), light: 0.3, shade: 0.18)
        shutter(&g, x: x0 - 74, top: top + 4, height: wh - 8)
        shutter(&g, x: x1 + 22, top: top + 4, height: wh - 8)
    }

    /// One open shutter of pale weathered planks.
    static func shutter(_ g: inout GraphicsContext, x: CGFloat, top: CGFloat, height: CGFloat) {
        let board = Art.rect(x, top, 52, height, radius: 3)
        Kit.solid(&g, board, Art.color(0xDCDCD2), light: 0.2, shade: 0.12)
        var planks = Path()
        planks.move(to: CGPoint(x: x + 17, y: top + 4))
        planks.addLine(to: CGPoint(x: x + 17, y: top + height - 4))
        planks.move(to: CGPoint(x: x + 35, y: top + 4))
        planks.addLine(to: CGPoint(x: x + 35, y: top + height - 4))
        planks.move(to: CGPoint(x: x + 4, y: top + height * 0.22))
        planks.addLine(to: CGPoint(x: x + 48, y: top + height * 0.22))
        planks.move(to: CGPoint(x: x + 4, y: top + height * 0.78))
        planks.addLine(to: CGPoint(x: x + 48, y: top + height * 0.78))
        Art.stroke(&g, planks, Art.color(0xB9BDB5, 0.8), width: ArtStyle.detailLine)
    }

    /// The flagstone floor, the shadow along the foot of the wall and the warm patch of
    /// window light lying across the floor toward the lower right.
    static func workshopFloor(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        Art.fill(&g, Art.rect(-200, H - 8, 1300, 10), ArtStyle.coolShade.opacity(0.08))
        Art.fill(&g, Art.rect(-200, H, 1300, 3), Art.color(0xB49A76, 0.5))
        var joints = Path()
        let rows: [CGFloat] = [26, 62, 108, 168, 246, 340, 450]
        var index: Int = 0
        for d in rows {
            let y: CGFloat = H + d
            if y > st.hv { break }
            joints.move(to: CGPoint(x: -200, y: y))
            joints.addLine(to: CGPoint(x: 1100, y: y))
            let step: CGFloat = 90 + d * 0.9
            let shift: CGFloat = index % 2 == 0 ? 0 : step * 0.5
            var x: CGFloat = -40 + shift
            while x < 940 {
                joints.move(to: CGPoint(x: x, y: y))
                joints.addLine(to: CGPoint(x: x - d * 0.12, y: y + 18 + d * 0.4))
                x += step
            }
            index += 1
        }
        Art.stroke(&g, joints, Art.color(0x9C8262, 0.28), width: 1.2)
        var beam = Path()
        beam.move(to: CGPoint(x: 330, y: H + 6))
        beam.addLine(to: CGPoint(x: 790, y: H + 6))
        beam.addLine(to: CGPoint(x: 900, y: H + 170))
        beam.addLine(to: CGPoint(x: 440, y: H + 170))
        beam.closeSubpath()
        let warm: Kit.Stops = [(Art.color(0xFFF3CF, 0.42), 0), (Art.color(0xFFF3CF, 0), 1)]
        Art.fillLinear(&g, beam, warm, from: CGPoint(x: 0, y: H), to: CGPoint(x: 0, y: H + 170))
        Kit.flecks(&g, in: CGRect(x: 380, y: H - 120, width: 360, height: 180), count: 16, seed: 9, color: Color.white, radius: 0.6...1.4)
    }

    /// The leading side, low: a tall storage jar, a sack of feathers, a folding stool.
    static func workshopLeading(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        Kit.pot(&g, cx: 96, baseY: H + 52, width: 56, height: 86, color: 0xC07A4A, band: 0x6A3A22)
        featherSack(&g, cx: 214, baseY: H + 72, scale: 0.9)
        // A folding stool: crossed legs and a leather seat.
        let stoolX: CGFloat = 334
        let foot: CGFloat = H + 60
        Kit.shadow(&g, stoolX, foot, width: 46)
        let legTone: Color = Art.color(0x8A5A3A)
        Art.stroke(&g, Art.line(stoolX - 18, foot, stoolX + 16, foot - 34), legTone, width: 3.2)
        Art.stroke(&g, Art.line(stoolX + 18, foot, stoolX - 16, foot - 34), legTone, width: 3.2)
        var seat = Path()
        seat.move(to: CGPoint(x: stoolX - 20, y: foot - 36))
        seat.addQuadCurve(to: CGPoint(x: stoolX + 20, y: foot - 36), control: CGPoint(x: stoolX, y: foot - 28))
        seat.addLine(to: CGPoint(x: stoolX + 20, y: foot - 39))
        seat.addLine(to: CGPoint(x: stoolX - 20, y: foot - 39))
        seat.closeSubpath()
        Kit.solid(&g, seat, Art.color(leather), light: 0.3, shade: 0.2)
        feather(&g, x: 322, y: foot - 38, length: 22, angle: -78, tone: paleFeathers[0])
        feather(&g, x: 150, y: H + 96, length: 18, angle: -100, tone: darkFeathers[1])
    }

    /// The bench on the trailing side with its tools, the wax pot, two candles and a mallet
    /// on the floor by its leg.
    static func workshopBench(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let topY: CGFloat = H - 8
        bench(&g, x0: 596, x1: 886, topY: topY, floorY: H + 46)
        benchTools(&g, x: 612, topY: topY)
        waxPot(&g, cx: 814, baseY: topY, scale: 0.9)
        candle(&g, x: 852, baseY: topY, height: 26)
        candle(&g, x: 864, baseY: topY + 1, height: 18)
        // A wooden mallet lying on the floor.
        let mx: CGFloat = 676
        let my: CGFloat = H + 66
        Kit.shadow(&g, mx + 10, my + 2, width: 50)
        Art.stroke(&g, Art.line(mx, my - 3, mx + 34, my - 1), Art.color(0x7A5234), width: 3.6)
        Kit.solid(&g, Art.rect(mx - 16, my - 15, 18, 16, radius: 3), Art.color(0x9A6A44), light: 0.3, shade: 0.22)
    }

    /// Icarus kneeling among the rows of feathers, blowing one small feather up into the air.
    static func workshopIcarus(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        featherRows(&g, x0: 468, y0: H + 60, rows: 3, count: 8, scale: 1)
        let fx: CGFloat = 596
        let fy: CGFloat = H + 94
        Kit.shadow(&g, fx + 4, fy, width: 74)
        Art.group(&g, x: fx, y: fy, scale: 1.15) { b in
            person(&b, .icarus, pose: .kneel, look: CGPoint(x: -0.6, y: -0.9), mouth: .oh)
        }
        // His breath and the feather riding it.
        var breath = Path()
        breath.move(to: CGPoint(x: 566, y: H - 4))
        breath.addQuadCurve(to: CGPoint(x: 554, y: H - 22), control: CGPoint(x: 556, y: H - 8))
        breath.move(to: CGPoint(x: 570, y: H - 10))
        breath.addQuadCurve(to: CGPoint(x: 562, y: H - 28), control: CGPoint(x: 562, y: H - 14))
        Art.stroke(&g, breath, Color.white.opacity(0.6), width: 1.2)
        feather(&g, x: 552, y: H - 30, length: 22, angle: -36, tone: 0xFBFAF6)
        feather(&g, x: 520, y: H + 30, length: 14, angle: -70, tone: darkFeathers[2])
    }

    /// The near plane: a dark basket rim cropped by the bottom-left corner, the dark timber
    /// door post on the trailing edge and, on a tall window, shavings and loose feathers
    /// across the deeper floor.
    static func workshopNear(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let bottom: CGFloat = st.hv
        if st.tall > 0.25 {
            var shavings = Path()
            let spots: [(CGFloat, CGFloat)] = [(120, 150), (260, 210), (420, 180), (560, 240), (700, 170), (330, 290), (620, 320)]
            for spot in spots {
                let y: CGFloat = H + spot.1 * (0.6 + st.tall * 0.5)
                if y > bottom - 30 { continue }
                shavings.move(to: CGPoint(x: spot.0, y: y))
                shavings.addCurve(to: CGPoint(x: spot.0 + 14, y: y - 2), control1: CGPoint(x: spot.0 + 2, y: y - 10), control2: CGPoint(x: spot.0 + 12, y: y - 10))
                shavings.addQuadCurve(to: CGPoint(x: spot.0 + 6, y: y + 2), control: CGPoint(x: spot.0 + 14, y: y + 4))
            }
            Art.stroke(&g, shavings, Art.color(0xE6C894), width: 2.2)
            feather(&g, x: 360, y: H + 170, length: 24, angle: -96, tone: paleFeathers[1])
            feather(&g, x: 520, y: H + 230, length: 20, angle: -60, tone: darkFeathers[0])
            feather(&g, x: 180, y: H + 260, length: 26, angle: -110, tone: paleFeathers[3])
        }
        let rim = Art.ellipse(-20, bottom + 24, 150, 74)
        Kit.solid(&g, rim, Art.color(0x6A4A30), light: 0.16, shade: 0.3)
        var weave = Path()
        weave.move(to: CGPoint(x: -20, y: bottom - 44))
        weave.addQuadCurve(to: CGPoint(x: 128, y: bottom + 4), control: CGPoint(x: 90, y: bottom - 40))
        weave.move(to: CGPoint(x: -20, y: bottom - 26))
        weave.addQuadCurve(to: CGPoint(x: 110, y: bottom + 14), control: CGPoint(x: 70, y: bottom - 22))
        Art.stroke(&g, weave, Art.color(0x8A6844, 0.8), width: 2)
        feather(&g, x: 40, y: bottom - 44, length: 34, angle: 20, tone: paleFeathers[0])
        feather(&g, x: 62, y: bottom - 40, length: 30, angle: 42, tone: darkFeathers[3])
        let postTop: CGFloat = H - 70
        let post = Art.rect(878, postTop, 40, bottom - postTop + 10)
        let postStops: Kit.Stops = [(Art.color(0x6A4A32), 0), (Art.color(0x4A3424), 1)]
        Art.fillLinear(&g, post, postStops, from: CGPoint(x: 0, y: postTop), to: CGPoint(x: 0, y: bottom))
        Art.fill(&g, Art.rect(878, postTop, 2, bottom - postTop), Art.color(0xFFD9A0, 0.3))
    }
}

// MARK: - Scene 2: the palace on the hill

extension IcarusArt {
    /// A hillside palace under a wide pale sky: far headland and a strip of sea with a ship;
    /// dry olive slopes on the leading side; low on the right a terrace with red columns
    /// (wider at the top), a dolphin fresco, horns of consecration and broad stairs, where
    /// Minos and Daedalus stand at the parapet looking out to sea.
    static func palaceScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let w: CGFloat = size.width
        let light = day()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 92, st.H - 74 * st.far, 13 * st.far, light: light)
        Kit.cloud(&context, 640, st.H - 250 * st.far, scale: 0.7 * st.far, color: Color.white.opacity(0.55))
        Kit.cloud(&context, 230, st.H - 300 * st.far, scale: 0.5 * st.far, color: Color.white.opacity(0.45))
        let seaLine: CGFloat = st.H - 44 * st.far
        let cape = Kit.peaks(width: 400, y: seaLine, amp: 34 * st.far, seed: 12, bottom: seaLine + 4, sharp: 0.35, x0: -30)
        Art.fill(&context, cape, light.far)
        let seaStrip: Kit.Stops = [(Art.color(0xB9D6E7), 0), (Art.color(0x92BCD8), 1)]
        Art.fillLinear(&context, Art.rect(0, seaLine, w, st.H - seaLine + 6), seaStrip, from: CGPoint(x: 0, y: seaLine), to: CGPoint(x: 0, y: st.H))
        Kit.glints(&context, x: 120, top: seaLine, depth: st.H - seaLine, color: Color.white, count: 22, seed: 5)
        minoanShip(&context, cx: 486, waterY: seaLine + 22 * st.far, length: 44 * st.far)
        ArtStyle.atmosphere(&context, width: w, top: seaLine - 40 * st.far, bottom: st.H, color: light.haze, alpha: 0.3)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: Kit.stops(0xD9C89C, 0xC4AD7E, 0xAE9466), seed: 13)
        Kit.designSpace(&context, st) { v in
            palaceHill(&v, st)
            Kit.nearSpace(&v, st) { n in
                palaceBlock(&n, st)
                palaceTerrace(&n, st)
                palaceFigures(&n, st)
            }
        }
        Kit.cornerLeaves(&context, size: size, corner: 2, color: Art.color(0x4E5E46), scale: 0.9, seed: 6)
        ArtStyle.finish(&context, size)
    }

    /// The dry slope on the leading side: silver-green olives, two cypresses, thyme, and on a
    /// tall window rocks, crocuses and tufts down the deeper hillside.
    static func palaceHill(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let slope: Kit.Stops = Kit.stops(0xD3C192, 0xBEA676)
        Kit.mound(&g, x0: -80, x1: 600, baseY: H + 34, height: 36, bottom: st.hv + 20, stops: slope, crest: 0.3)
        Kit.olive(&g, x: 70, baseY: H + 16, height: 56, seed: 3)
        Kit.olive(&g, x: 196, baseY: H + 8, height: 50, seed: 7)
        Kit.cypress(&g, x: 262, baseY: H + 12, height: 62, color: 0x2E5440)
        Kit.olive(&g, x: 330, baseY: H + 26, height: 54, seed: 11)
        Kit.cypress(&g, x: 410, baseY: H + 22, height: 70, color: 0x2A4E3C)
        let thyme = Kit.oliveGreens()
        Kit.bush(&g, x: 130, baseY: H + 48, width: 34, palette: thyme, seed: 2)
        Kit.bush(&g, x: 262, baseY: H + 60, width: 28, palette: thyme, seed: 5)
        Kit.grass(&g, in: CGRect(x: 0, y: H + 30, width: 460, height: 70), count: 40, seed: 7, color: Art.color(0xA69A62), height: 7)
        if st.tall > 0.25 {
            let deep: CGFloat = st.hv - H
            Kit.rock(&g, cx: 90, baseY: H + deep * 0.55, width: 70, height: 34, color: 0xC8BCA4, seed: 4)
            Kit.rock(&g, cx: 330, baseY: H + deep * 0.72, width: 54, height: 26, color: 0xBFB298, seed: 9)
            Kit.bush(&g, x: 200, baseY: H + deep * 0.62, width: 46, palette: thyme, seed: 8)
            Kit.flowers(&g, in: CGRect(x: 20, y: H + deep * 0.4, width: 420, height: deep * 0.4), count: 18, seed: 3, petal: 0xB79ACC, heart: 0xF2C94A)
            Kit.grassTuft(&g, x: 420, baseY: H + deep * 0.86, height: 40, color: 0x8A8A50, seed: 6)
        }
    }

    /// The palace front behind the terrace: a pale upper storey, the painted wall with its
    /// dolphin frieze and a dark doorway, three red columns, the flat roof with its horns.
    static func palaceBlock(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        Kit.wall(&g, rect: CGRect(x: 720, y: H - 150, width: 200, height: 62), color: 0xEFE6D3)
        Art.fill(&g, Art.rect(720, H - 150, 200, 6), Art.color(0xE0D2B6))
        horns(&g, cx: 770, baseY: H - 150, size: 8)
        horns(&g, cx: 850, baseY: H - 150, size: 8)
        Kit.wall(&g, rect: CGRect(x: 600, y: H - 84, width: 320, height: 138), color: 0xE9DDC6)
        fresco(&g, rect: CGRect(x: 612, y: H - 52, width: 290, height: 40))
        Kit.opening(&g, rect: CGRect(x: 732, y: H - 2, width: 34, height: 54), arched: false, color: 0xD8C8A8)
        Kit.opening(&g, rect: CGRect(x: 828, y: H - 2, width: 30, height: 54), arched: false, color: 0xD8C8A8)
        let columns: [CGFloat] = [690, 792, 888]
        for cx in columns {
            minoanColumn(&g, cx: cx, baseY: H + 54, height: 134, width: 22)
        }
        let roof = Art.rect(592, H - 96, 330, 14, radius: 2)
        Kit.solid(&g, roof, Art.color(0xE6D9BF), light: 0.26, shade: 0.2)
        Art.fill(&g, Art.rect(592, H - 84, 330, 4), Art.color(minoanRed, 0.75))
        var beamEnds = Path()
        var bx: CGFloat = 604
        while bx < 920 {
            beamEnds.addEllipse(in: CGRect(x: bx, y: H - 92, width: 6, height: 6))
            bx += 22
        }
        Art.fill(&g, beamEnds, Art.color(0xC8B08A))
        let hornXs: [CGFloat] = [620, 664, 708]
        for hx in hornXs {
            horns(&g, cx: hx, baseY: H - 96, size: 8)
        }
    }

    /// The paved terrace, its ashlar retaining wall and the broad stairs going down to the
    /// olives on the left.
    static func palaceTerrace(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        for i in 0..<7 {
            let k: CGFloat = CGFloat(i)
            let y: CGFloat = H + 58 + k * 15
            let x1: CGFloat = 486
            let x0: CGFloat = 340 - k * 20
            Art.fill(&g, Art.rect(x0, y, x1 - x0, 6), Art.color(0xF0E6D0))
            Art.fill(&g, Art.rect(x0, y + 6, x1 - x0, 9), Art.color(0xD6C5A4))
            Art.fill(&g, Art.rect(x0, y + 6, x1 - x0, 2), ArtStyle.coolShade.opacity(0.08))
        }
        let cheek: [CGPoint] = [CGPoint(x: 330, y: H + 54), CGPoint(x: 346, y: H + 54), CGPoint(x: 226, y: H + 166), CGPoint(x: 206, y: H + 166)]
        Kit.solid(&g, Art.polygon(cheek), Art.color(0xDCCCAD), light: 0.24, shade: 0.2)
        Art.fill(&g, Art.rect(470, H + 52, 450, 22), Art.color(0xE6D9BE))
        Kit.wall(&g, rect: CGRect(x: 470, y: H + 74, width: 450, height: 120), color: 0xE2D3B6)
        var courses = Path()
        let rows: [CGFloat] = [100, 128, 156]
        var index: Int = 0
        for d in rows {
            courses.move(to: CGPoint(x: 470, y: H + d))
            courses.addLine(to: CGPoint(x: 920, y: H + d))
            var x: CGFloat = index % 2 == 0 ? 500 : 530
            while x < 920 {
                courses.move(to: CGPoint(x: x, y: H + d))
                courses.addLine(to: CGPoint(x: x, y: H + d - 26))
                x += 62
            }
            index += 1
        }
        Art.stroke(&g, courses, Art.color(0xB8A27E, 0.45), width: 1.1)
        Art.fill(&g, Art.rect(470, H + 74, 4, 120), Art.color(0xFFF4DC, 0.4))
    }

    /// Minos (reaching out toward the sea) and Daedalus beside him at the parapet.
    static func palaceFigures(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let feet: CGFloat = H + 62
        Art.group(&g, x: 622, y: feet - 2, scale: 0.82) { b in
            person(&b, .daedalus, pose: .stand, look: CGPoint(x: -0.8, y: 0), mouth: .flat)
        }
        Art.group(&g, x: 552, y: feet, scale: 0.86) { b in
            person(&b, .minos, pose: .reach, look: CGPoint(x: -0.9, y: -0.1), mouth: .smile)
        }
        let parapet = Art.rect(470, H + 30, 236, 34, radius: 2)
        Kit.solid(&g, parapet, Art.color(0xECE1CA), light: 0.28, shade: 0.18)
        Art.fill(&g, Art.rect(468, H + 26, 240, 6, radius: 2), Art.color(0xF4ECDA))
        Art.fill(&g, Art.rect(470, H + 46, 236, 3), Art.color(minoanRed, 0.6))
    }
}

// MARK: - Scene 3: the top of the tower at dawn

extension IcarusArt {
    /// Dawn: a huge pale gold and rose sky over both panes, the rim of the sun coming up out of
    /// the sea on the left, a faint island, a few gulls; low on the right the flat top of the
    /// tower over its white cliff, father and son at its edge with the wings along their arms.
    static func towerScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = dawn()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.cloud(&context, 300, st.H - 280 * st.far, scale: 0.8 * st.far, color: Art.color(0xFBE7DA, 0.6))
        Kit.cloud(&context, 700, st.H - 330 * st.far, scale: 0.6 * st.far, color: Art.color(0xFBEADF, 0.5))
        Kit.sun(&context, 128, st.H + 4, 20 * st.far, light: light)
        let isle = Kit.ridge(width: 150, y: st.H - 6 * st.far, amp: 7 * st.far, seed: 21, bottom: st.H + 2, x0: 300)
        Art.fill(&context, isle, light.far.opacity(0.8))
        let sea: Kit.Stops = [(Art.color(0xE9C9A6), 0), (Art.color(0x9DB4C6), 0.22), (Art.color(0x6A93B4), 0.6), (Art.color(0x4C7BA6), 1)]
        Kit.water(&context, width: w, top: st.H, bottom: h, stops: sea, light: light, ripples: 10, seed: 17)
        Kit.glints(&context, x: 128, top: st.H, depth: h - st.H, color: Art.color(0xFFE7B0), count: 46, seed: 23)
        Kit.swells(&context, width: w, top: st.H + 30, bottom: h, rows: 6, crest: Art.color(0xF6E2C8, 0.4), seed: 15)
        Kit.designSpace(&context, st) { v in
            let places: [(CGFloat, CGFloat, CGFloat)] = [(250, st.Hv - 96, 0.42), (316, st.Hv - 128, 0.34), (470, st.Hv - 70, 0.4)]
            gulls(&v, places: places)
            towerCliff(&v, st)
            Kit.nearSpace(&v, st) { n in
                towerTop(&n, st)
                towerPair(&n, st)
            }
        }
        ArtStyle.finish(&context, size)
    }

    /// The white limestone cliff of Crete dropping into the sea on the leading side, with
    /// thyme on its brow and a gull below its edge: it tells how high the tower stands.
    static func towerCliff(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let bottom: CGFloat = st.hv + 10
        var cliff = Path()
        cliff.move(to: CGPoint(x: -20, y: H + 96))
        cliff.addQuadCurve(to: CGPoint(x: 180, y: H + 120), control: CGPoint(x: 90, y: H + 96))
        cliff.addQuadCurve(to: CGPoint(x: 262, y: H + 168), control: CGPoint(x: 240, y: H + 128))
        cliff.addLine(to: CGPoint(x: 300, y: bottom))
        cliff.addLine(to: CGPoint(x: -20, y: bottom))
        cliff.closeSubpath()
        let rock: Kit.Stops = Kit.stops(0xF1E6D4, 0xD9C7AE, 0xB7A48E)
        Kit.solid(&g, cliff, stops: rock, light: 0.3, shade: 0.34, rim: 2)
        var cracks = Path()
        cracks.move(to: CGPoint(x: 60, y: H + 116))
        cracks.addLine(to: CGPoint(x: 52, y: H + 170))
        cracks.move(to: CGPoint(x: 150, y: H + 124))
        cracks.addLine(to: CGPoint(x: 160, y: H + 196))
        cracks.move(to: CGPoint(x: 220, y: H + 150))
        cracks.addLine(to: CGPoint(x: 236, y: H + 210))
        Art.stroke(&g, cracks, Art.color(0xA8927A, 0.5), width: 1.4)
        Kit.bush(&g, x: 40, baseY: H + 100, width: 30, palette: Kit.oliveGreens(), seed: 3)
        Kit.bush(&g, x: 120, baseY: H + 104, width: 24, palette: Kit.oliveGreens(), seed: 6)
        Kit.ripples(&g, 292, bottom - 18, 60, count: 2, color: Color.white, opacity: 0.4)
        gull(&g, x: 330, y: H + 150, scale: 0.6, up: false)
    }

    /// The tower's flat top and its ashlar flank going down out of the frame, with the open
    /// hatch of the ladder.
    static func towerTop(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let bottom: CGFloat = st.hv + 40
        Kit.wall(&g, rect: CGRect(x: 574, y: H + 70, width: 340, height: bottom - H - 70), color: 0xDCCBAE)
        var courses = Path()
        var y: CGFloat = H + 96
        var row: Int = 0
        while y < bottom {
            courses.move(to: CGPoint(x: 574, y: y))
            courses.addLine(to: CGPoint(x: 914, y: y))
            var x: CGFloat = row % 2 == 0 ? 610 : 640
            while x < 914 {
                courses.move(to: CGPoint(x: x, y: y))
                courses.addLine(to: CGPoint(x: x, y: y - 26))
                x += 64
            }
            y += 26
            row += 1
        }
        Art.stroke(&g, courses, Art.color(0xA8916E, 0.4), width: 1.1)
        Art.fill(&g, Art.rect(574, H + 70, 5, bottom - H - 70), Art.color(0xFFE6C0, 0.45))
        let roof: [CGPoint] = [CGPoint(x: 586, y: H + 44), CGPoint(x: 912, y: H + 44), CGPoint(x: 914, y: H + 70), CGPoint(x: 566, y: H + 70)]
        Kit.solid(&g, Art.polygon(roof), Art.color(0xE9DCC2), light: 0.3, shade: 0.16)
        Art.fill(&g, Art.rect(566, H + 68, 348, 4), Art.color(0xC9B48F))
        let hatch: [CGPoint] = [CGPoint(x: 812, y: H + 50), CGPoint(x: 856, y: H + 50), CGPoint(x: 862, y: H + 62), CGPoint(x: 806, y: H + 62)]
        Art.fill(&g, Art.polygon(hatch), Art.color(0x5A4632))
        Art.stroke(&g, Art.line(820, H + 62, 826, H + 26), Art.color(0x8A6A48), width: 2.4)
        Art.stroke(&g, Art.line(848, H + 62, 844, H + 26), Art.color(0x8A6A48), width: 2.4)
        Art.stroke(&g, Art.line(822, H + 38, 846, H + 38), Art.color(0x8A6A48), width: 2)
    }

    /// Daedalus with the great wings hanging along his half-open arms, looking down at his
    /// son; Icarus a step ahead at the very edge, arms spread wide and lifted, face up.
    static func towerPair(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let feet: CGFloat = H + 56
        Kit.shadow(&g, 724, feet, width: 70)
        Art.group(&g, x: 724, y: feet, scale: 0.8) { b in
            winged(&b, .daedalus, rig: lowWingsRig(), look: CGPoint(x: -0.8, y: 0.5), mouth: .flat, headTilt: -6)
        }
        Kit.shadow(&g, 614, feet + 2, width: 52)
        Art.group(&g, x: 614, y: feet + 2, scale: 0.9) { b in
            winged(&b, .icarus, rig: spreadRig(lift: 12), look: CGPoint(x: -0.4, y: -0.9), mouth: .open, headTilt: 6)
        }
    }
}

// MARK: - Scene 4: over the open sea at noon

extension IcarusArt {
    /// The open Aegean from high in a pale noon haze: islands like stepping stones, one
    /// fishing boat with a square sail; low on the right Daedalus flying on, small, and on the
    /// water beneath him a soft scatter of white and grey feathers. Icarus is not shown.
    static func seaScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 220)
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = noon()
        Kit.sky(&context, size, horizon: st.H, light: light)
        Art.glow(&context, 40, 0, 360, Art.color(0xFFF6DC), alpha: 0.35)
        Kit.cloud(&context, 760, st.H - 300 * st.far, scale: 0.6 * st.far, color: Color.white.opacity(0.5))
        Kit.cloud(&context, 520, st.H - 220 * st.far, scale: 0.45 * st.far, color: Color.white.opacity(0.4))
        Kit.water(&context, width: w, top: st.H, bottom: h, stops: seaStops(), light: light, ripples: 14, seed: 29)
        let farIsles: [(CGFloat, CGFloat, CGFloat, UInt32)] = [(70, 46, 8, 3), (250, 30, 6, 5), (420, 54, 9, 8), (820, 40, 7, 9)]
        for isle in farIsles {
            island(&context, cx: isle.0, baseY: st.H + 3 * st.far, width: isle.1 * st.far, height: isle.2 * st.far, seed: isle.3)
        }
        ArtStyle.atmosphere(&context, width: w, top: st.H - 20 * st.far, bottom: st.H + 30 * st.far, color: light.haze, alpha: 0.4)
        Kit.glints(&context, x: 180, top: st.H, depth: h - st.H, color: Color.white, count: 40, seed: 31)
        Kit.swells(&context, width: w, top: st.H + 24, bottom: h, rows: 7, crest: Color.white.opacity(0.35), seed: 19)
        Kit.designSpace(&context, st) { v in
            seaIslands(&v, st)
            Kit.nearSpace(&v, st, anchorX: 680) { n in
                seaFeathers(&n, st)
                Art.group(&n, x: 700, y: st.Hv + 34, scale: 0.62) { b in
                    flyer(&b, .daedalus, tilt: -70, look: CGPoint(x: 0.7, y: 0.9), mouth: .oh)
                }
                Art.fill(&n, Art.ellipse(708, st.Hv + 170, 54, 6), ArtStyle.coolShade.opacity(0.12))
            }
        }
        ArtStyle.finish(&context, size)
    }

    /// The middle islands (Paros white with marble, little Delos) and the fishing boat; on a
    /// tall window a nearer rocky island cropped by the bottom-left corner.
    static func seaIslands(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        island(&g, cx: 150, baseY: H + 42, width: 130, height: 22, seed: 11)
        Art.fill(&g, Art.ellipse(132, H + 30, 18, 4), Art.color(0xF6F2E8, 0.7))
        island(&g, cx: 380, baseY: H + 26, width: 70, height: 13, seed: 13, green: true)
        island(&g, cx: 540, baseY: H + 58, width: 96, height: 18, seed: 17)
        minoanShip(&g, cx: 286, waterY: H + 86, length: 46)
        Kit.ripples(&g, 286, H + 92, 54, count: 2, color: Color.white, opacity: 0.45)
        let deep: CGFloat = st.hv - H
        if st.tall > 0.25 {
            island(&g, cx: 420, baseY: H + deep * 0.55, width: 150, height: 30, seed: 23, green: true)
        }
        var near = Path()
        near.move(to: CGPoint(x: -30, y: st.hv - 70))
        near.addQuadCurve(to: CGPoint(x: 90, y: st.hv - 50), control: CGPoint(x: 30, y: st.hv - 98))
        near.addQuadCurve(to: CGPoint(x: 170, y: st.hv + 10), control: CGPoint(x: 150, y: st.hv - 40))
        near.addLine(to: CGPoint(x: -30, y: st.hv + 10))
        near.closeSubpath()
        let rock: Kit.Stops = Kit.stops(0x6F6A58, 0x4A4A44)
        Kit.solid(&g, near, stops: rock, light: 0.22, shade: 0.3, rim: 1.6)
        Kit.bush(&g, x: 40, baseY: st.hv - 74, width: 36, palette: Kit.oliveGreens(), seed: 4)
        Kit.ripples(&g, 150, st.hv - 8, 70, count: 2, color: Color.white, opacity: 0.5)
    }

    /// A drift of small grey and white feathers floating on the swell, each with a faint ring.
    static func seaFeathers(_ g: inout GraphicsContext, _ st: Kit.Stage) {
        let H: CGFloat = st.Hv
        let drift: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (600, 120, 16, -80), (628, 132, 13, -110), (652, 116, 15, -64), (676, 140, 12, -96),
            (588, 146, 14, -120), (708, 126, 13, -72), (640, 156, 11, -100), (728, 150, 12, -88),
            (566, 128, 10, -60)
        ]
        var index: Int = 0
        for f in drift {
            let y: CGFloat = H + f.1
            Art.stroke(&g, Art.ellipse(f.0 + 2, y + 2, f.2 * 0.9, f.2 * 0.18), Color.white.opacity(0.35), width: 0.8)
            let tones: [UInt32] = index % 3 == 0 ? darkFeathers : paleFeathers
            feather(&g, x: f.0 - f.2 * 0.5, y: y, length: f.2, angle: f.3, tone: tones[index % tones.count])
            index += 1
        }
    }
}
