import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the two character-card portraits (432 × 400), the
// three face chips (100 × 100) and the cover of "The Tiger, the Brahman and the Jackal".
// Each tap picture has one subject a little above the middle on a simple ground in the
// story's colours, a quiet top-left corner and a bottom that sinks into the card's colour.

// MARK: - see-punjab

extension TigerArt {
    /// see-punjab: the land of five waters seen from high above. A flat golden plain of small
    /// fields, five pale blue rivers winding side by side across it and coming together
    /// toward the bottom, and the faint white line of the far mountains at the very top.
    static func punjabPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let plain: Kit.Stops = [(Art.color(0xF1E6C0), 0), (Art.color(0xE3C988), 0.35), (Art.color(0xC9A35C), 0.8), (Art.color(0x8A6A3A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), plain, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        // The far mountains: only a faint white line along the top.
        let hills = Kit.peaks(width: w, y: 30, amp: 14, seed: 5, bottom: 40, sharp: 0.7)
        Art.fill(&context, hills, Color.white.opacity(0.5))
        Art.fill(&context, Art.rect(0, 30, w, 12), Art.color(0xF6EED8, 0.7))
        punjabFields(&context, top: 44, bottom: h)
        ArtStyle.atmosphere(&context, width: w, top: 30, bottom: 120, color: Art.color(0xF6EED8), alpha: 0.4)
        // The five rivers, from their spread-out heads to where they meet.
        let heads: [CGFloat] = [60, 136, 214, 292, 370]
        let feet: [CGFloat] = [188, 202, 216, 230, 244]
        for index in 0..<5 {
            let sign: CGFloat = index % 2 == 0 ? 1 : -1
            punjabRiver(&context, top: heads[index], bottom: feet[index], wobble: 16 * sign)
        }
        // Below the meeting: one broad river running on toward the sea.
        var joined = Path()
        joined.move(to: CGPoint(x: 216, y: 296))
        joined.addCurve(to: CGPoint(x: 204, y: h + 4), control1: CGPoint(x: 236, y: 330), control2: CGPoint(x: 186, y: 360))
        Art.stroke(&context, joined, Art.color(0x6E7A48, 0.4), width: 16)
        Art.stroke(&context, joined, Art.color(0xBFE1EC), width: 12)
        Art.stroke(&context, joined, Color.white.opacity(0.55), width: 3)
        Kit.sink(&context, size, card: 0x1F4E5A)
    }

    /// The patchwork of small fields between `top` and `bottom`, rows thinner far away.
    static func punjabFields(_ context: inout GraphicsContext, top: CGFloat, bottom: CGFloat) {
        let tones: [UInt32] = [0xE2C46A, 0xC9B45A, 0xA9BC62, 0xE8CF52, 0xD6BC78, 0x9DB45C]
        var random = ArtRandom(17)
        var lines = Path()
        var y: CGFloat = top
        var row: Int = 0
        while y < bottom && row < 9 {
            let rowH: CGFloat = 12 + CGFloat(row) * 7
            let cols: Int = 9 - row / 2
            let colW: CGFloat = 432 / CGFloat(cols)
            for col in 0..<cols {
                let pick: Int = Int(Kit.rnd(&random) * 5.99)
                let tone: UInt32 = tones[min(5, max(0, pick))]
                let x: CGFloat = CGFloat(col) * colW
                Art.fill(&context, Art.rect(x, y, colW, rowH), Art.color(tone, 0.55))
                lines.move(to: CGPoint(x: x, y: y))
                lines.addLine(to: CGPoint(x: x, y: y + rowH))
            }
            lines.move(to: CGPoint(x: 0, y: y))
            lines.addLine(to: CGPoint(x: 432, y: y))
            y += rowH
            row += 1
        }
        Art.stroke(&context, lines, Art.color(0xB8975A, 0.35), width: 1)
    }

    /// One winding river from its head at (`top`, y 46) to where it meets the others at
    /// (`bottom`, y 296): three bends, wider as it goes, a green bank shadow and a glint.
    static func punjabRiver(_ context: inout GraphicsContext, top x0: CGFloat, bottom x3: CGFloat, wobble: CGFloat) {
        let p0 = CGPoint(x: x0, y: 46)
        let p1 = CGPoint(x: Kit.mix(x0, x3, 0.34) + wobble, y: 130)
        let p2 = CGPoint(x: Kit.mix(x0, x3, 0.68) - wobble, y: 214)
        let p3 = CGPoint(x: x3, y: 296)
        let points: [CGPoint] = [p0, p1, p2, p3]
        let widths: [CGFloat] = [2.2, 3.8, 5.4]
        for index in 0..<3 {
            let a = points[index]
            let b = points[index + 1]
            let turn: CGFloat = index % 2 == 0 ? 18 : -18
            var bend = Path()
            bend.move(to: a)
            bend.addCurve(to: b, control1: CGPoint(x: a.x + turn, y: a.y + 30), control2: CGPoint(x: b.x - turn, y: b.y - 30))
            let width: CGFloat = widths[index]
            Art.stroke(&context, bend, Art.color(0x6E7A48, 0.35), width: width + 4)
            Art.stroke(&context, bend, Art.color(0xBFE1EC), width: width)
            Art.stroke(&context, bend, Color.white.opacity(0.5), width: max(0.8, width * 0.3))
        }
    }
}

// MARK: - see-priest-and-teacher

extension TigerArt {
    /// see-priest-and-teacher: an old hand-written book of long narrow loose pages, tied
    /// with a string through the middle, lying open on its red cloth on a low carved wooden
    /// stand; a reed pen and a small clay inkpot beside it. No figure, no religious image.
    static func priestPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let wall: Kit.Stops = [(Art.color(0x7A4E74), 0), (Art.color(0x5E3A60), 0.6), (Art.color(0x4A2A4E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), wall, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 150, 150, 230, Art.color(0xFFD98A), alpha: 0.22)
        let floor: Kit.Stops = [(Art.color(0x6A4462), 0), (Art.color(0x4A2A4E), 1)]
        Art.fillLinear(&context, Art.rect(0, 262, w, h - 262), floor, from: CGPoint(x: 0, y: 262), to: CGPoint(x: 0, y: h))
        Art.fill(&context, Art.rect(0, 262, w, 3), Art.color(0x8A5E80, 0.6))
        bookStand(&context)
        pothi(&context)
        // The reed pen and the inkpot, to the right on the floor.
        Kit.shadow(&context, 378, 286, width: 34)
        let pot = Art.svg("M366,262 C360,268 360,282 368,286 C374,289 384,289 390,286 C398,282 398,268 392,262Z")
        Kit.solid(&context, pot, Art.color(clayHex), light: 0.3, shade: 0.24, rim: 1.4)
        Art.fill(&context, Art.ellipse(379, 262, 13, 3.6), Art.color(0x2B2038))
        Kit.propShaft(&context, 384, 260, 404, 214, wood: 0xC9A46A, width: 3)
        Kit.sink(&context, size, card: 0x4A2A4E)
    }

    /// The low carved wooden stand: a top board seen a little from above, its front edge,
    /// a scalloped apron and four short turned legs.
    static func bookStand(_ context: inout GraphicsContext) {
        let wood = Art.color(woodHex)
        ArtStyle.contactShadow(&context, 230, 292, 150, 12, alpha: 0.34)
        Kit.propShaft(&context, 124, 244, 124, 274, wood: Kit.propToneHex(woodHex, 0.7), width: 9)
        Kit.propShaft(&context, 316, 244, 316, 274, wood: Kit.propToneHex(woodHex, 0.7), width: 9)
        let top = Art.svg("M96,212 L340,212 L358,236 L78,236Z")
        Kit.solid(&context, top, Kit.propTone(woodHex, 1.15), light: 0.3, shade: 0.18)
        let front = Art.rect(78, 236, 280, 12, radius: 2)
        Kit.solid(&context, front, wood, light: 0.2, shade: 0.24)
        let apron = Art.svg("M96,248 L340,248 L340,256 C330,256 326,264 316,264 C306,264 302,256 292,256 C282,256 278,264 268,264 C258,264 254,256 244,256 C234,256 230,264 220,264 C210,264 206,256 196,256 C186,256 182,264 172,264 C162,264 158,256 148,256 C138,256 134,264 124,264 C114,264 110,256 96,256Z")
        Art.fill(&context, apron, Kit.propTone(woodHex, 0.82))
        let legs: [CGFloat] = [92, 344]
        for x in legs {
            let leg = Art.svg("M-7,0 L7,0 C9,6 4,10 6,16 C9,22 8,30 4,38 L-4,38 C-8,30 -9,22 -6,16 C-4,10 -9,6 -7,0Z")
            let placed = leg.applying(CGAffineTransform(translationX: x, y: 248))
            Kit.solid(&context, placed, wood, light: 0.3, shade: 0.24)
        }
        Art.stroke(&context, Art.line(80, 237, 356, 237), Kit.propTone(woodHex, 1.5).opacity(0.6), width: 1.2)
    }

    /// The pothi: a stack of long narrow pages on a red cloth, the top page written in short
    /// ruled lines on either side of the string hole, red margin lines at both ends.
    static func pothi(_ context: inout GraphicsContext) {
        let cloth = Art.svg("M100,200 L336,200 L350,228 C300,232 140,232 86,228Z")
        Kit.solid(&context, cloth, Art.color(0xB5332F), light: 0.24, shade: 0.2)
        Art.stroke(&context, Art.svg("M92,224 C150,227 290,227 346,224"), Art.color(0xE8B04A, 0.8), width: 1.6)
        let paper = Art.color(0xF3E4BE)
        let edge = Art.color(0xD2B47E)
        for index in 0..<5 {
            let dy: CGFloat = CGFloat(4 - index) * 2.6
            let page = Art.svg("M112,168 L326,168 L338,212 L100,212Z").applying(CGAffineTransform(translationX: 0, y: dy))
            Art.fill(&context, page, index == 4 ? paper : edge)
        }
        let top = Art.svg("M112,168 L326,168 L338,212 L100,212Z")
        Kit.solid(&context, top, paper, light: 0.2, shade: 0.12)
        // Red margins and the writing, in two blocks either side of the hole.
        Art.stroke(&context, Art.svg("M130,170 L122,210 M136,170 L128,210 M306,170 L314,210 M312,170 L320,210"), Art.color(0xB5332F, 0.75), width: 1.2)
        var script = Path()
        for row in 0..<5 {
            let y: CGFloat = 175 + CGFloat(row) * 7.6
            let slant: CGFloat = CGFloat(row) * 1.5
            script.move(to: CGPoint(x: 142 - slant, y: y))
            script.addLine(to: CGPoint(x: 206 - slant * 0.3, y: y))
            script.move(to: CGPoint(x: 232 + slant * 0.3, y: y))
            script.addLine(to: CGPoint(x: 298 + slant, y: y))
        }
        Art.stroke(&context, script, Art.color(0x5A3A2A, 0.75), width: 1.3)
        var marks = Path()
        var random = ArtRandom(23)
        for _ in 0..<70 {
            let row: CGFloat = CGFloat(Int(Kit.rnd(&random) * 4.99))
            let left: Bool = Kit.rnd(&random) < 0.5
            let x: CGFloat = left ? 142 + Kit.rnd(&random) * 62 : 234 + Kit.rnd(&random) * 62
            let y: CGFloat = 175 + row * 7.6
            marks.move(to: CGPoint(x: x, y: y))
            marks.addLine(to: CGPoint(x: x + 1, y: y + 3.6))
        }
        Art.stroke(&context, marks, Art.color(0x5A3A2A, 0.6), width: 1.1)
        // The string hole and the string, hanging over the front edge.
        Art.fill(&context, Art.circle(219, 190, 4), Art.color(0xC9A46A))
        Art.fill(&context, Art.circle(219, 190, 2), Art.color(0x6A4A30))
        Art.stroke(&context, Art.svg("M219,190 C222,204 214,216 220,232 C224,242 218,250 222,258"), Art.color(0xE0661F), width: 1.8)
    }
}

// MARK: - see-pipal-tree

extension TigerArt {
    /// see-pipal-tree: one large heart-shaped pipal leaf with pale veins and its long thin
    /// drip tip, hanging from a short twig on a deep green ground; a drop at the tip.
    static func pipalPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let ground: Kit.Stops = [(Art.color(0x3E7A4E), 0), (Art.color(0x2C6242), 0.55), (Art.color(0x22503A), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), ground, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        Art.glow(&context, 140, 120, 220, Art.color(0xFFE9A8), alpha: 0.18)
        // Soft far leaves out of focus.
        let far: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(380, 60, 60, 20), (60, 250, 54, -14), (392, 230, 50, 10)]
        Art.blurred(&context, radius: 8, opacity: 0.35) { b in
            pipalLeaves(&b, far, dark: 0x4E8A56, light: 0x6FA25E)
        }
        // The twig and the leaf's stalk.
        let bark = Kit.treeTone(pipalBarkHex, 0.86)
        Art.stroke(&context, Art.svg("M150,34 C200,30 260,40 340,30"), bark, width: 6)
        Art.stroke(&context, Art.svg("M152,32 C200,28 260,38 338,28"), Color.white.opacity(0.25), width: 1.6)
        Art.stroke(&context, Art.svg("M232,36 C230,44 224,50 220,58"), Art.color(0x7FA04A), width: 3)
        // The leaf: 176 across, hanging from (220, 58), turned a little.
        let k: CGFloat = 1.76
        let turn: CGFloat = Kit.deg(4)
        let move = CGAffineTransform(translationX: 220, y: 58).rotated(by: turn).scaledBy(x: k, y: k)
        var leaf = Path()
        pipalLeaf(&leaf, x: 0, y: 0, size: 100, angle: 0)
        let shape: Path = leaf.applying(move)
        ArtStyle.contactShadow(&context, 236, 336, 70, 8, alpha: 0.2)
        let green: Kit.Stops = [(Art.color(0x8DC05C), 0), (Art.color(0x5E9A46), 0.6), (Art.color(0x437C3E), 1)]
        Kit.solid(&context, shape, stops: green, light: 0.3, shade: 0.26, rim: 2)
        let veins = Art.svg("M0,0 L0,136 M0,14 Q-20,14 -40,30 M0,26 Q-22,28 -46,46 M0,38 Q-22,42 -45,62 M0,52 Q-18,58 -36,76 M0,66 Q-12,72 -24,88 M0,14 Q20,14 40,30 M0,26 Q22,28 46,46 M0,38 Q22,42 45,62 M0,52 Q18,58 36,76 M0,66 Q12,72 24,88")
        Art.clipped(&context, to: shape) { g in
            Art.stroke(&g, veins.applying(move), Art.color(0xE4F0B4, 0.75), width: 1.6)
            // The far half of the leaf, a little in shadow.
            let half = Art.rect(0, -10, 70, 160).applying(move)
            Art.fill(&g, half, ArtStyle.coolShade.opacity(0.1))
        }
        // A drop of water on the drip tip.
        let tip: CGPoint = CGPoint(x: 0, y: 138).applying(move)
        Kit.solid(&context, Art.ellipse(tip.x, tip.y + 5, 3.6, 4.6), Art.color(0xDDF3F7, 0.9), light: 0.4, shade: 0.2)
        Art.fill(&context, Art.circle(tip.x - 1.2, tip.y + 3.6, 1.1), Color.white)
        Kit.sink(&context, size, card: 0x22503A)
    }
}

// MARK: - see-well-wheel

extension TigerArt {
    /// see-well-wheel: the Persian wheel alone, on its round brick well, the loop of small
    /// red clay pots, the top pots tipping out bright water into the trough; the worn circle
    /// and the flat fields behind. No animal.
    static func wellPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w = size.width
        let h = size.height
        let light = morning()
        let H: CGFloat = 212
        Kit.sky(&context, size, horizon: H, light: light)
        farPlain(&context, width: w, horizon: H, scale: 0.8, light: light, seed: 61)
        let earth: Kit.Stops = [(Art.color(0xD9C08A), 0), (Art.color(0xB98E58), 0.5), (Art.color(0x6B3F22), 1)]
        Kit.ground(&context, width: w, top: H, bottom: h, stops: earth, tooth: Art.color(0xFFF6D8))
        fields(&context, x0: 0, x1: w, top: H, bottom: H + 30, mustardFirst: true, seed: 63)
        ditch(&context, x0: w + 4, y0: 272, x1: 340, y1: 246, near: 9, far: 5)
        // The worn circle round the gear shaft.
        let ring = Art.ellipse(112, 268, 104, 20)
        Art.stroke(&context, ring, Art.color(0x9A7A46, 0.5), width: 12)
        Art.stroke(&context, ring, Art.color(0xF1E0B0, 0.35), width: 4)
        Art.group(&context, x: 222, y: 262, scale: 0.98) { g in
            wellWheel(&g)
        }
        Kit.grassTuft(&context, x: 54, baseY: 290, height: 24, color: 0x8FA64E, seed: 3)
        Kit.grassTuft(&context, x: 392, baseY: 296, height: 22, color: 0x8FA64E, seed: 7)
        Kit.sink(&context, size, card: 0x6B3F22)
    }
}

// MARK: - Portraits

extension TigerArt {
    /// char-brahman: half figure, mild and smiling, in his white shawl over one shoulder with
    /// the sacred thread, the staff in one hand and the cloth bundle on his shoulder; warm
    /// pale gold behind.
    static func brahmanPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xF6E3B4, bottom: 0xC9954A, halo: 0xFFF3CF, rays: false) { g in
            let p = brahmanLook()
            Kit.propShaft(&g, 338, 30, 330, 400, wood: 0x8A6238, width: 11)
            Art.group(&g, x: 216, y: 128, scale: 2.2) { b in
                Kit.bust(&b, p, look: CGPoint(x: 0, y: 0.1), mouth: .smile)
                Art.fill(&b, Art.svg("M21,-14 C24,-22 33,-20 31,-11 C29,-6 23,-8 21,-14Z"), Art.color(p.hair))
                let shawl = Art.svg("M-60,64 C-58,46 -42,38 -24,37 C-8,70 16,112 44,150 L-4,150 C-24,122 -44,98 -60,92Z")
                Kit.solid(&b, shawl, Art.color(p.cloth), light: 0.2, shade: 0.2)
                Art.stroke(&b, Art.svg("M-34,52 C-20,76 -2,104 18,132"), Art.color(0xE3D9C2), width: 1.4)
                Art.stroke(&b, Art.svg("M-6,37 C8,64 30,102 52,140"), Art.color(0xFFFBF0), width: 1.2)
            }
            // His hand round the staff, on the right of the picture.
            Kit.solid(&g, Art.ellipse(332, 316, 22, 18), Art.color(p.skin), light: 0.26, shade: 0.22)
            Art.stroke(&g, Art.svg("M316,310 C324,306 340,306 348,312 M316,320 C324,316 340,316 348,322"), Kit.personTone(p.skin, 0.8), width: 1.6)
            // The bundle on his other shoulder.
            Art.group(&g, x: 104, y: 216, scale: 2.0) { b in
                bundle(&b, mirrored: false)
            }
        }
    }

    /// char-jackal: the Jackal sitting, head tilted, one hind paw raised to scratch his ear,
    /// eyes half shut and a small sly smile; his dark-tipped brush curled round; soft field
    /// green behind, with a few mustard flowers.
    static func jackalPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xDDEBC8, bottom: 0x7FA35C, halo: 0xFBF6DC, rays: false) { g in
            let spec = jackalLook()
            Kit.flowers(&g, in: CGRect(x: 20, y: 300, width: 120, height: 70), count: 10, seed: 3, petal: mustardHex)
            Kit.flowers(&g, in: CGRect(x: 300, y: 310, width: 110, height: 60), count: 9, seed: 5, petal: mustardHex)
            // The brush, curled round in front at the lower left.
            let brush = Art.svg("M150,400 C110,392 74,370 70,340 C68,320 84,312 98,322 C108,346 130,366 168,376Z")
            Kit.solid(&g, brush, Kit.beastTone(spec.body, 0.92), light: 0.24, shade: 0.22)
            Art.clipped(&g, to: brush) { t in
                Art.fill(&t, Art.circle(78, 330, 18), Art.color(spec.dark))
            }
            Art.group(&g, x: 216, y: 150, rotate: -Kit.deg(8), scale: 2.0) { b in
                Kit.beastBust(&b, spec, mood: .sly, look: CGPoint(x: 0.2, y: 0.1))
                // The hind leg, raised behind him so its paw scratches the right ear.
                let leg = Art.svg("M58,128 C80,96 78,46 52,-6")
                Art.stroke(&b, leg, Kit.beastTone(spec.body, 0.86), width: 15)
                Art.stroke(&b, Art.svg("M54,120 C72,92 70,48 48,0"), Kit.beastTone(spec.body, 1.12), width: 3)
                let paw = Art.ellipse(46, -14, 10, 8)
                Kit.solid(&b, paw, Kit.beastTone(spec.body, 0.9), light: 0.24, shade: 0.2)
                Art.stroke(&b, Art.svg("M40,-20 l-3,-4 M46,-22 l-1,-5 M52,-20 l1,-5"), Art.color(spec.dark, 0.7), width: 1.4)
            }
        }
    }
}

// MARK: - Face chips

extension TigerArt {
    /// face-brahman: his mild face, the grey tuft behind, a hint of the white shawl.
    static func brahmanFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xE3EEFA) { g in
            Art.fill(&g, Art.svg("M-46,60 C-40,40 -20,32 0,32 C20,32 40,40 46,60Z"), Art.color(0xF8F4EA))
            Art.group(&g, x: 0, y: 2, scale: 1.25) { f in
                brahmanHead(&f, look: CGPoint(x: 0, y: 0.1), mouth: .smile)
            }
        }
    }

    /// face-jackal: the Jackal's narrow sandy-gold face and big pointed ears, a sly look.
    static func jackalFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE2A8) { g in
            Art.group(&g, x: 0, y: 8, scale: 1.12) { f in
                Kit.beastFace(&f, jackalLook(), mood: .sly)
            }
        }
    }

    /// face-tiger: the Tiger's broad striped face, proud, with the fine white whiskers he is
    /// so vain about.
    static func tigerFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFD9B8) { g in
            Art.group(&g, x: 0, y: 6, scale: 1.18) { f in
                Kit.beastFace(&f, tigerLook(), mood: .proud)
                let whiskers = Art.svg("M-12,14 C-22,12 -32,12 -40,15 M-12,18 C-22,19 -30,22 -36,26 M12,14 C22,12 32,12 40,15 M12,18 C22,19 30,22 36,26")
                Art.stroke(&f, whiskers, Color.white.opacity(0.9), width: 1)
            }
        }
    }
}

// MARK: - Cover

extension TigerArt {
    /// The cover: the moment before the door shuts. The Tiger in the trap glaring out
    /// through the bamboo bars, the Jackal in the middle bowing low with one paw on the
    /// latch and his eyes on the reader, the Brahman a step behind with his staff; kikar
    /// trees, the dusty road and a pale gold sky behind.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.cover(&context, size) { g, frame in
            let hd = frame.hd
            let H = frame.H
            let k = frame.k
            let light = midday()
            Kit.sky(&g, CGSize(width: 240, height: hd), horizon: H, light: light)
            farPlain(&g, width: 240, horizon: H, scale: 0.5 * k, light: light, seed: 71)
            let earth: Kit.Stops = [(Art.color(0xE6D29C), 0), (Art.color(0xD6B87C), 0.5), (Art.color(0xC29A5C), 1)]
            Kit.ground(&g, width: 240, top: H, bottom: hd, stops: earth, tooth: Art.color(0xFFF6D8))
            fields(&g, x0: 0, x1: 240, top: H, bottom: H + 10 * k, mustardFirst: false, seed: 73)
            road(&g, nearX: 120, nearY: hd, nearWidth: 200, farX: 30, farY: H + 2, farWidth: 5)
            Kit.acacia(&g, x: 214, baseY: H + 4, height: 110 * k, spread: 100 * k, palette: kikarGreens(), bark: 0x3E3028)
            Kit.acacia(&g, x: 22, baseY: H + 1, height: 40 * k, spread: 46 * k, palette: kikarGreens(), bark: 0x5A4A38)
            coverEnsemble(&g, horizon: H, scale: k)
            Kit.cornerLeaves(&g, size: CGSize(width: 240, height: hd), corner: 1, color: Art.color(0x6A6A30), scale: 0.5 * k, seed: 2)
        }
    }

    /// The trap, the Jackal and the Brahman on the cover, standing on the horizon `H`.
    static func coverEnsemble(_ g: inout GraphicsContext, horizon H: CGFloat, scale k: CGFloat) {
        // The trap on the right; its lifted latch on its left end.
        let ck: CGFloat = 0.62 * k
        let cageX: CGFloat = 168
        let cageY: CGFloat = H + 14 * k
        Art.group(&g, x: cageX, y: cageY, scale: ck) { c in
            cagedTiger(&c, mood: .proud, look: CGPoint(x: -1, y: 0.2), latched: false)
        }
        let latchX: CGFloat = cageX - 90 * ck
        let latchY: CGFloat = cageY - 168 * 0.56 * ck
        // The Brahman a step behind the Jackal, with his staff.
        let bk: CGFloat = 0.5 * k
        let bx: CGFloat = 32
        let by: CGFloat = H + 12 * k
        Kit.shadow(&g, bx, by, width: 60 * bk)
        Art.group(&g, x: bx, y: by, scale: bk, scaleX: -1) { b in
            brahman(&b, pose: .stand, look: CGPoint(x: -0.6, y: 0), mouth: .smile, mirrored: true)
        }
        // The Jackal, bowing low toward the reader, one forepaw up on the latch.
        let jk: CGFloat = 0.5 * k
        let jx: CGFloat = latchX - 40 * k
        let jy: CGFloat = H + 20 * k
        Kit.shadow(&g, jx, jy, width: 76 * jk)
        Art.group(&g, x: jx, y: jy, rotate: Kit.deg(6), scale: jk, scaleX: -1) { j in
            jackal(&j, pose: .stand, mood: .sly, look: CGPoint(x: 0.6, y: 0.4), mirrored: true)
        }
        let chestX: CGFloat = jx + 46 * jk
        let chestY: CGFloat = jy - 62 * jk
        var paw = Path()
        paw.move(to: CGPoint(x: chestX, y: chestY))
        paw.addQuadCurve(to: CGPoint(x: latchX - 2, y: latchY + 2), control: CGPoint(x: chestX + 4 * k, y: latchY - 6 * k))
        Art.stroke(&g, paw, Art.color(0xD8A858), width: 5 * k)
        Art.fill(&g, Art.circle(latchX - 2, latchY + 2, 3.4 * k), Art.color(0x4E3826))
    }
}
