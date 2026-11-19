import SwiftUI
import OmramoCore

// The tap-to-see pictures (432 × 404), the two character-card portraits (432 × 400), the
// three face chips (100 × 100) and the cover of "King Khufu and the Magician".

// MARK: - Tap picture: the Nile

extension KhufuArt {
    /// A date palm seen from straight above: a star of fronds over its own soft shadow.
    static func topPalm(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat) {
        Art.fill(&context, Art.circle(x + r * 0.35, y + r * 0.4, r * 0.85), ArtStyle.coolShade.opacity(0.14))
        var fronds = Path()
        var lit = Path()
        for index in 0..<7 {
            let a: CGFloat = Kit.deg(CGFloat(index) * 51.4 + 10)
            let tipX: CGFloat = x + cos(a) * r
            let tipY: CGFloat = y + sin(a) * r
            let midX: CGFloat = x + cos(a) * r * 0.5
            let midY: CGFloat = y + sin(a) * r * 0.5
            let sideX: CGFloat = -sin(a) * r * 0.2
            let sideY: CGFloat = cos(a) * r * 0.2
            var leaf = Path()
            leaf.move(to: CGPoint(x: x, y: y))
            leaf.addQuadCurve(to: CGPoint(x: tipX, y: tipY), control: CGPoint(x: midX + sideX, y: midY + sideY))
            leaf.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: midX - sideX, y: midY - sideY))
            leaf.closeSubpath()
            if index == 3 || index == 4 || index == 5 {
                lit.addPath(leaf)
            } else {
                fronds.addPath(leaf)
            }
        }
        Art.fill(&context, fronds, Art.color(0x4E7F48))
        Art.fill(&context, lit, Art.color(0x7FA85E))
        Art.fill(&context, Art.circle(x, y, r * 0.16), Art.color(0x8A6A48))
    }

    /// Looking down on a curve of the blue-green Nile, a narrow green strip of fields and palms
    /// on each bank, small mud-brick houses at the desert edge and pale desert at both sides.
    static func nilePicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let desert: Kit.Stops = [(Art.color(0xF3E2BA), 0), (Art.color(0xE3C88E), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), desert, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: h), seed: 12, alpha: 0.06)
        let dunes: Path = Art.svg("M340,40 q20,-6 40,0 M356,92 q20,-6 40,0 M370,140 q16,-5 32,0 M18,250 q20,-6 40,0 M30,296 q20,-6 40,0 M20,200 q14,-4 28,0")
        Art.stroke(&context, dunes, Art.color(0xD2B47A, 0.55), width: 1.6)
        // The green strip that follows the river.
        let green: Path = Art.svg("M120,-10 C60,80 60,160 150,220 C230,272 250,330 200,420 L380,420 C420,330 380,250 300,200 C220,150 250,70 300,-10Z")
        Kit.solid(&context, green, Art.color(fieldHex), light: 0.2, shade: 0.16)
        let plots: Path = Art.svg("M70,70 L150,78 M64,128 L156,138 M90,190 L170,204 M300,250 L420,240 M318,300 L420,292 M250,40 L300,44")
        Art.clipped(&context, to: green) { g in
            Art.stroke(&g, plots, Art.color(0x6F9050, 0.5), width: 1.4)
            Art.fill(&g, Art.svg("M60,90 L150,100 L156,138 L64,128Z"), Art.color(0xB7C27A, 0.5))
            Art.fill(&g, Art.svg("M300,250 L420,240 L420,292 L318,300Z"), Art.color(0xC8C484, 0.5))
        }
        // The river and the light on it.
        let river: Path = Art.svg("M196,-10 C140,80 150,150 214,200 C276,246 300,320 268,420 L316,420 C342,320 324,236 258,186 C196,140 196,70 240,-10Z")
        Art.fillLinear(&context, river, waterStops(), from: CGPoint(x: 150, y: 0), to: CGPoint(x: 320, y: h))
        Kit.model(&context, river, light: 0.2, shade: 0.12)
        Art.stroke(&context, Art.svg("M214,-10 C166,80 172,150 232,196 C290,240 312,320 290,420"), Color.white.opacity(0.22), width: 3)
        Art.stroke(&context, river, Art.color(0x6E8F58, 0.5), width: 1.4)
        // Small flat-roofed houses at the edge of the fields.
        let houses: [(CGFloat, CGFloat)] = [(74, 146), (82, 160), (348, 232), (360, 244), (262, 18)]
        for house in houses {
            let block: Path = Art.rect(house.0, house.1, 11, 8, radius: 1)
            Kit.solid(&context, block, Art.color(mudHex), light: 0.3, shade: 0.3)
        }
        // A boat under sail, seen from above, going upstream.
        Art.group(&context, x: 224, y: 150, rotate: Kit.deg(-48)) { g in
            Art.fill(&g, Art.ellipse(3, 3, 6, 15), ArtStyle.coolShade.opacity(0.12))
            let hull: Path = Art.svg("M0,-15 C6,-8 6,8 0,15 C-6,8 -6,-8 0,-15Z")
            Kit.solid(&g, hull, Art.color(0x9A6A3C), light: 0.3, shade: 0.2)
            Art.stroke(&g, Art.line(-8, -2, 8, -2), Art.color(0xF4EAD0), width: 3)
        }
        let palms: [(CGFloat, CGFloat, CGFloat)] = [
            (130, 40, 12), (110, 110, 13), (128, 176, 12), (196, 250, 13),
            (250, 40, 11), (226, 100, 10), (282, 196, 12), (352, 268, 13),
        ]
        for palm in palms {
            topPalm(&context, x: palm.0, y: palm.1, r: palm.2)
        }
        Kit.sink(&context, size, card: 0x1F4F5C)
    }
}

// MARK: - Tap picture: the river boat

extension KhufuArt {
    /// One Old Kingdom river boat in side view on calm water: upturned ends, the two-legged
    /// mast with its tall narrow sail, the row of oars and the steering oar at the stern.
    static func riverBoatPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let light = day()
        let H: CGFloat = 244
        Kit.sky(&context, size, horizon: H, light: light)
        Kit.cloud(&context, 340, 80, scale: 0.6, color: Color.white.opacity(0.5))
        farBank(&context, width: w, y: H, scale: 0.8, light: light, seed: 41)
        Kit.water(&context, width: w, top: H, bottom: h, stops: waterStops(), light: light, ripples: 24, seed: 6)
        // Its reflection, then the boat.
        Art.fill(&context, Art.ellipse(222, 268, 126, 9), Art.color(0x9A6A3C, 0.18))
        Art.fill(&context, Art.rect(200, 270, 40, 40), Art.color(0xF4EAD0, 0.08))
        Art.group(&context, x: 216, y: 258, scale: 1.3) { g in
            riverBoat(&g, rowers: 6)
        }
        Kit.reeds(&context, x: 412, baseY: 300, count: 5, height: 90, seed: 3, color: 0x4F7F4A, papyrus: true)
        Kit.sink(&context, size, card: 0x1B3A5C)
    }
}

// MARK: - Tap picture: the papyrus roll

extension KhufuArt {
    /// A scribe's palette: a narrow wooden slat with a black and a red cake of ink in their
    /// wells, and a reed pen in its slot. Centred on the origin, about 180 long.
    static func inkPalette(_ context: inout GraphicsContext) {
        Art.fill(&context, Art.rect(-86, -4, 180, 20, radius: 3), ArtStyle.coolShade.opacity(0.18))
        let slat: Path = Art.rect(-90, -9, 180, 18, radius: 3)
        Kit.solid(&context, slat, Art.color(0xC9A266), light: 0.3, shade: 0.22)
        Art.fill(&context, Art.rect(-38, -3, 118, 6, radius: 3), Kit.propTone(0xC9A266, 0.72))
        Art.stroke(&context, Art.line(-34, -0.5, 100, -2), Art.color(0xB09A5A), width: 2.6)
        Art.fill(&context, Art.circle(-74, 0, 7), Kit.propTone(0xC9A266, 0.7))
        Art.fill(&context, Art.circle(-56, 0, 7), Kit.propTone(0xC9A266, 0.7))
        Art.fill(&context, Art.circle(-74, 0, 5.4), Art.color(0x2A2420))
        Art.fill(&context, Art.circle(-56, 0, 5.4), Art.color(redHex))
        Art.fill(&context, Art.circle(-76, -2, 1.6), Color.white.opacity(0.3))
        Art.fill(&context, Art.circle(-58, -2, 1.6), Color.white.opacity(0.3))
    }

    /// Rows of small plain marks on the open sheet (never readable signs): black, with the first
    /// marks of some rows in red, as scribes did.
    static func papyrusMarks(_ context: inout GraphicsContext) {
        var random = ArtRandom(57)
        var black = Path()
        var red = Path()
        for row in 0..<6 {
            let y: CGFloat = -40 + CGFloat(row) * 15
            var x: CGFloat = -90
            var count: Int = 0
            while x < 112 {
                let mw: CGFloat = 2.5 + Kit.rnd(&random) * 4
                let mh: CGFloat = 4 + Kit.rnd(&random) * 4
                let mark: Path = Art.rect(x, y - mh / 2, mw, mh, radius: 1)
                if count < 3 && row % 3 == 0 {
                    red.addPath(mark)
                } else {
                    black.addPath(mark)
                }
                x += mw + 3 + Kit.rnd(&random) * 4
                count += 1
            }
        }
        Art.fill(&context, black, Art.color(0x3A2A1A, 0.85))
        Art.fill(&context, red, Art.color(redHex, 0.9))
    }

    /// A half-unrolled papyrus roll on a wooden table: the rolled part with its cord, the open
    /// sheet with rows of small marks, and a scribe's palette lying beside it.
    static func papyrusPicture(_ context: inout GraphicsContext, _ size: CGSize) {
        let w: CGFloat = size.width
        let h: CGFloat = size.height
        let table: Kit.Stops = [(Art.color(0xA4824E), 0), (Art.color(0x7A5C34), 1)]
        Art.fillLinear(&context, Art.rect(0, 0, w, h), table, from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: h))
        let planks: Path = Art.svg("M0,72 L432,66 M0,164 L432,158 M0,256 L432,250 M0,348 L432,342")
        Art.stroke(&context, planks, Art.color(0x5E4426, 0.4), width: 1.4, cap: .butt)
        Art.glow(&context, 90, 60, 300, Art.color(0xFFE2A0), alpha: 0.3)
        ArtStyle.tooth(&context, in: CGRect(x: 0, y: 0, width: w, height: h), seed: 21, alpha: 0.06)
        Art.group(&context, x: 232, y: 172, rotate: Kit.deg(-3)) { g in
            // The shadow of the sheet and the roll on the table.
            Art.fill(&g, Art.rect(-126, -52, 264, 124, radius: 6), ArtStyle.coolShade.opacity(0.2))
            let sheet: Path = Art.rect(-104, -56, 234, 112)
            Kit.solid(&g, sheet, Art.color(papyrusHex), light: 0.22, shade: 0.14)
            var fibres = Path()
            var fy: CGFloat = -52
            while fy < 56 {
                fibres.move(to: CGPoint(x: -104, y: fy))
                fibres.addLine(to: CGPoint(x: 130, y: fy))
                fy += 7
            }
            Art.stroke(&g, fibres, Art.color(0xC9B07A, 0.25), width: 1, cap: .butt)
            Art.stroke(&g, Art.svg("M-20,-56 L-20,56 M60,-56 L60,56"), Art.color(0xC9B07A, 0.3), width: 1.2, cap: .butt)
            papyrusMarks(&g)
            // The free end curls up a little.
            Kit.solid(&g, Art.rect(124, -56, 9, 112, radius: 4), Kit.propTone(papyrusHex, 0.86), light: 0.3, shade: 0.2)
            // The rolled part, standing proud of the table, tied with its cord.
            let roll: Path = Art.rect(-134, -66, 30, 132, radius: 12)
            Kit.solid(&g, roll, Art.color(papyrusHex), light: 0.32, shade: 0.3, rim: 1.4)
            Art.fill(&g, Art.ellipse(-119, -63, 14, 5), Kit.propTone(papyrusHex, 1.06))
            Art.stroke(&g, Art.svg("M-125,-63 Q-119,-60 -113,-63 M-129,-63 Q-119,-56 -109,-63"), Kit.propTone(papyrusHex, 0.75), width: 0.9)
            Art.stroke(&g, Art.line(-134, 4, -104, 4), Art.color(redHex), width: 3.4, cap: .butt)
            Art.stroke(&g, Art.svg("M-122,6 C-128,18 -124,26 -130,34"), Art.color(redHex), width: 2)
        }
        Art.group(&context, x: 238, y: 266, rotate: Kit.deg(-5)) { g in
            inkPalette(&g)
        }
        Kit.sink(&context, size, card: 0x5A4A1C)
    }
}

// MARK: - Portraits

extension KhufuArt {
    /// King Khufu on his chair, leaning forward with his chin on his fist and one heavy brow
    /// up; the bead collar bright on the white linen; the back of his chair behind him.
    static func khufuPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xF6DFA6, bottom: 0xB9822F, halo: 0xFFF1CC, rays: false) { g in
            let back: Path = Art.rect(250, 132, 88, 280, radius: 10)
            Kit.solid(&g, back, Art.color(woodHex), light: 0.28, shade: 0.26)
            Art.stroke(&g, Art.line(258, 156, 330, 156), Art.color(goldHex), width: 3.4, cap: .butt)
            Art.stroke(&g, Art.line(258, 164, 330, 164), Art.color(ramp.accent, 0.8), width: 2, cap: .butt)
            Art.group(&g, x: 212, y: 152, rotate: Kit.deg(-4), scale: 2.2) { b in
                Kit.bust(&b, khufuLook(), look: CGPoint(x: -0.1, y: 0), mouth: .flat)
                kingHead(&b, left: 0, right: 3)
                // Two more rows of the broad bead collar.
                Art.stroke(&b, Art.svg("M-40,48 C-30,84 30,84 40,48"), Art.color(goldHex), width: 3)
                Art.stroke(&b, Art.svg("M-31,45 C-23,72 23,72 31,45"), Art.color(redHex), width: 2.2)
                // The forearm up from his knee, and the fist his chin rests on.
                let skin: Color = Art.color(skinHex)
                Art.stroke(&b, Art.svg("M-54,152 C-48,112 -32,72 -14,46"), skin, width: 17)
                Art.stroke(&b, Art.svg("M-50,130 C-44,104 -32,78 -20,58"), Kit.personTone(skinHex, 0.8).opacity(0.5), width: 3)
                Art.fill(&b, Art.circle(-8, 39, 10.5), skin)
                Art.stroke(&b, Art.svg("M-15,36 q3.5,-2.6 7,0 M-8,36 q3.5,-2.6 7,0"), Kit.personTone(skinHex, 0.72), width: 1.1)
            }
        }
    }

    /// Dedi, tiny and smiling, both hands folded on his tall plain staff, his short white hair
    /// and white brows, a papyrus roll tucked at his side.
    static func dediPortrait(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.portrait(&context, size, top: 0xCFEBDD, bottom: 0x4A9A8A, halo: 0xF4FBEF, rays: false) { g in
            Art.group(&g, x: 208, y: 154, scale: 2.1) { b in
                let p = dediLook()
                Kit.bust(&b, p, look: .zero, mouth: .smile)
                dediHead(&b)
                Art.stroke(&b, Art.svg("M-12,-15.6 q6,-2.4 12,0 M3,-15.6 q6,-2.4 12,0"), Art.color(0xF6F2EA), width: 2.2)
                Art.group(&b, x: -36, y: 112, rotate: Kit.deg(-14)) { r in
                    papyrusRoll(&r, length: 46, thick: 11)
                }
                // The staff, taller than he is, and both hands folded on it.
                Kit.propShaft(&b, 42, 160, 40, -96, wood: darkWoodHex, width: 5.4)
                let skin: Color = Art.color(p.skin)
                Art.stroke(&b, Art.svg("M-50,70 C-30,96 10,98 34,84"), skin, width: 13)
                Art.stroke(&b, Art.svg("M50,68 C54,76 50,82 46,86"), skin, width: 12)
                Art.fill(&b, Art.ellipse(40, 82, 9, 7.5), skin)
                Art.fill(&b, Art.ellipse(43, 90, 8.5, 7), Kit.personTone(p.skin, 0.92))
                Art.stroke(&b, Art.svg("M34,86 q6,2 12,0 M36,94 q5,1.6 11,0"), Kit.personTone(p.skin, 0.72), width: 1)
            }
        }
    }
}

// MARK: - Face chips

extension KhufuArt {
    static func khufuFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xFFE9B8) { g in
            Art.group(&g, x: 0, y: 6, scale: 1.25) { f in
                Kit.personHead(&f, khufuLook(), look: .zero, mouth: .flat)
                kingHead(&f, left: 0, right: 2.6)
            }
        }
    }

    static func dediFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xD9F5E4) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.3) { f in
                Kit.personHead(&f, dediLook(), look: .zero, mouth: .smile)
                dediHead(&f)
                Art.stroke(&f, Art.svg("M-12,-15.6 q6,-2.4 12,0 M3,-15.6 q6,-2.4 12,0"), Art.color(0xF6F2EA), width: 2.2)
            }
        }
    }

    static func princeFace(_ context: inout GraphicsContext, _ size: CGSize) {
        Kit.faceChip(&context, size, background: 0xDCE9FA) { g in
            Art.group(&g, x: 0, y: 4, scale: 1.3) { f in
                Kit.personHead(&f, princeLook(), look: CGPoint(x: -0.2, y: 0), mouth: .smile)
            }
        }
    }
}

// MARK: - Cover

extension KhufuArt {
    /// Tiny Dedi with his staff stands calmly before King Khufu on his chair, and the whole,
    /// cross goose on the mat between them looks up at the king; slim columns, a pale sky and
    /// the river through the open side behind.
    static func cover(_ context: inout GraphicsContext, _ size: CGSize) {
        let light = day()
        Kit.cover(&context, size) { g, frame in
            let H: CGFloat = frame.H
            let k: CGFloat = frame.k
            let area = CGSize(width: 240, height: frame.hd)
            Kit.sky(&g, area, horizon: H, light: light)
            Kit.cloud(&g, 150, H - 70 * k, scale: 0.4 * k, color: Color.white.opacity(0.45))
            let sill: CGFloat = H - 4 * k
            let bankY: CGFloat = sill - 8 * k
            farBank(&g, width: 240, y: bankY, scale: 0.4 * k, light: light, seed: 37)
            Art.fillLinear(&g, Art.rect(0, bankY, 240, sill - bankY), waterStops(), from: CGPoint(x: 0, y: bankY), to: CGPoint(x: 0, y: sill))
            Art.fill(&g, Art.rect(0, sill, 240, H - sill), Art.color(0xEFE3C6))
            hallFloor(&g, area, top: H)
            Art.fill(&g, Art.rect(0, 0, 240, 8), Art.color(0xE9DBB8))
            let colBase: CGFloat = H + 10 * k
            hallColumn(&g, x: 14, baseY: colBase, width: 11 * k, height: colBase - 7)
            hallColumn(&g, x: 228, baseY: colBase, width: 11 * k, height: colBase - 7)
            let s: CGFloat = 0.55 * k
            let base: CGFloat = H + 18 * k
            reedMat(&g, cx: 124, y: base - 12 * k, width: 190 * k, depth: 26 * k)
            Art.group(&g, x: 174, y: base - 12 * s, scale: s) { t in
                throne(&t)
                king(&t, pose: .chin)
            }
            let gooseY: CGFloat = base + 6 * k
            Kit.shadow(&g, 122, gooseY + 1, width: 34 * s)
            Art.group(&g, x: 122, y: gooseY, scale: s * 0.8, scaleX: -1) { t in
                goose(&t, cackling: false, mirrored: true)
            }
            let dediY: CGFloat = base + 4 * k
            Kit.shadow(&g, 72, dediY + 1, width: 40 * s)
            Art.group(&g, x: 72, y: dediY, scale: s, scaleX: -1) { t in
                dedi(&t, pose: .staff, mouth: .smile, mirrored: true)
            }
            Kit.cornerLeaves(&g, size: area, corner: 1, color: Art.color(0x3F6A3E), scale: 0.45 * k, seed: 3)
        }
    }
}
