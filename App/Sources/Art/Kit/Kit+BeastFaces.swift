import SwiftUI
import OmramoCore

// The kit's animals from the FRONT (round 5): the head for face chips, the head with chest and
// paws for character-card portraits, and the ready-made looks so every story draws the same
// bear. The side view of the same `Beast` is in `Kit+Beasts.swift`.
//
// The head is drawn round the origin, 60 units across without the ears.

// MARK: - Tones and small tools

extension Kit {
    /// `hex` with each RGB component scaled by `k` (k < 1 darker, k > 1 lighter).
    static func faceTone(_ hex: UInt32, _ k: CGFloat) -> Color {
        let r: CGFloat = CGFloat((hex >> 16) & 0xFF) * k
        let g: CGFloat = CGFloat((hex >> 8) & 0xFF) * k
        let b: CGFloat = CGFloat(hex & 0xFF) * k
        let nr: UInt32 = UInt32(min(255, max(0, r)))
        let ng: UInt32 = UInt32(min(255, max(0, g)))
        let nb: UInt32 = UInt32(min(255, max(0, b)))
        let mixed: UInt32 = (nr << 16) | (ng << 8) | nb
        return Art.color(mixed)
    }

    /// Path data drawn for the left side of the face, plus its mirror image on the right.
    static func faceBoth(_ data: String) -> Path {
        let left = Art.svg(data)
        var both = left
        both.addPath(left.applying(CGAffineTransform(scaleX: -1, y: 1)))
        return both
    }

    /// The warm pink-beige of every inner ear.
    static let faceEarPinkHex: UInt32 = 0xE9B7A0

    /// Where the nose sits, by muzzle.
    static func faceNoseY(_ muzzle: Beast.Muzzle) -> CGFloat {
        switch muzzle {
        case .short: return 10
        case .long: return 23
        case .broad: return 10
        case .pointed: return 17
        }
    }

    /// The size of the nose, by muzzle.
    static func faceNoseScale(_ muzzle: Beast.Muzzle) -> CGFloat {
        switch muzzle {
        case .short: return 0.9
        case .long: return 1.15
        case .broad: return 1.25
        case .pointed: return 0.9
        }
    }

    /// True for the opossum's face: the pale patch covers most of it.
    static func faceFullMask(_ b: Beast) -> Bool {
        b.muzzle == .pointed && b.ears == .small
    }
}

// MARK: - Mane, ears, skull

extension Kit {
    /// The lion's ruff: about 14 lobes round the head in the dark tone, a lighter inner ring.
    static func faceMane(_ context: inout GraphicsContext, _ b: Beast) {
        var ruff = Path()
        ruff.addEllipse(in: CGRect(x: -38, y: -38, width: 76, height: 76))
        let count: Int = 14
        for index in 0..<count {
            let angle: CGFloat = CGFloat(index) / CGFloat(count) * 2 * CGFloat.pi
            let cx: CGFloat = cos(angle) * 38
            let cy: CGFloat = sin(angle) * 37 + 1
            ruff.addEllipse(in: CGRect(x: cx - 11, y: cy - 11, width: 22, height: 22))
        }
        Kit.solid(&context, ruff, Art.color(b.dark), light: 0.2, shade: 0.24)
        let ring = Art.svg("M0,-37 C-20,-37 -36,-22 -36,-2 C-36,18 -22,35 0,35 C22,35 36,18 36,-2 C36,-22 20,-37 0,-37Z")
        Art.fill(&context, ring, faceTone(b.dark, 1.25))
        // A few strands, so the ruff reads as hair.
        let strands = faceBoth("M-33,-16 q-7,-2 -11,-8 M-36,2 q-8,2 -12,-1 M-31,20 q-6,6 -12,6 M-14,-34 q-3,-7 -9,-10 M-16,33 q-3,7 -8,9")
        Art.stroke(&context, strands, faceTone(b.dark, 0.72), width: ArtStyle.detailLine)
    }

    /// Both ears, by kind. Floppy ears hang in front of the skull; the others stand behind it.
    static func faceEars(_ context: inout GraphicsContext, _ b: Beast) {
        let coat: Color = faceTone(b.body, 0.94)
        let pink: Color = Art.color(faceEarPinkHex)
        switch b.ears {
        case .round:
            let outer = faceBoth("M-22,-34 C-29,-34 -34,-29 -34,-22 C-34,-15 -29,-10 -22,-10 C-15,-10 -10,-15 -10,-22 C-10,-29 -15,-34 -22,-34Z")
            Kit.solid(&context, outer, coat, light: 0.2, shade: 0.16)
            Art.fill(&context, faceBoth("M-22,-29 C-26,-29 -29,-26 -29,-22 C-29,-18 -26,-15 -22,-15 C-18,-15 -15,-18 -15,-22 C-15,-26 -18,-29 -22,-29Z"), pink)
        case .pointed, .tufted:
            let outer = faceBoth("M-28,-10 C-30,-26 -28,-40 -23,-46 C-21,-48 -19,-47 -17,-44 C-11,-36 -6,-28 -3,-21Z")
            Kit.solid(&context, outer, coat, light: 0.2, shade: 0.16)
            Art.fill(&context, faceBoth("M-24,-16 C-25,-27 -24,-35 -22,-40 C-17,-34 -13,-28 -10,-22Z"), pink)
            if b.ears == .tufted {
                let tufts = faceBoth("M-23,-45 l-4,-9 M-21,-46 l0,-10 M-19,-45 l4,-8")
                Art.stroke(&context, tufts, faceTone(b.dark, 1.0), width: ArtStyle.detailLine)
            }
        case .long:
            faceLongEars(&context, b)
        case .floppy:
            let flap = faceBoth("M-23,-22 C-33,-24 -40,-12 -40,4 C-40,17 -35,27 -29,25 C-23,23 -24,9 -21,-6Z")
            Kit.solid(&context, flap, faceTone(b.body, 0.78), light: 0.2, shade: 0.2)
            let fold = faceBoth("M-25,-19 C-32,-14 -35,-2 -34,10")
            Art.stroke(&context, fold, faceTone(b.body, 0.6), width: ArtStyle.detailLine)
        case .small:
            let outer = faceBoth("M-23,-30 C-28,-30 -31,-26 -31,-22 C-31,-17 -28,-14 -23,-14 C-18,-14 -15,-17 -15,-22 C-15,-26 -18,-30 -23,-30Z")
            Kit.solid(&context, outer, faceTone(b.dark, 1.15), light: 0.2, shade: 0.14)
            Art.fill(&context, Art.circle(-23, -21, 3.6), pink.opacity(0.8))
            Art.fill(&context, Art.circle(23, -21, 3.6), pink.opacity(0.8))
        }
    }

    /// Tall ears (hare, rabbit, donkey): the left one upright, the right one tilted a little.
    static func faceLongEars(_ context: inout GraphicsContext, _ b: Beast) {
        let outer = Art.svg("M-20,-18 C-26,-40 -23,-64 -14,-75 C-7,-64 -4,-40 -7,-20Z")
        let inner = Art.svg("M-16,-26 C-20,-42 -18,-58 -14,-66 C-10,-58 -9,-42 -11,-27Z")
        let mirror = CGAffineTransform(scaleX: -1, y: 1)
        let tilt = CGAffineTransform(translationX: 13, y: -20).rotated(by: deg(16)).translatedBy(x: -13, y: 20)
        var ears = outer
        ears.addPath(outer.applying(mirror).applying(tilt))
        var pinks = inner
        pinks.addPath(inner.applying(mirror).applying(tilt))
        Kit.solid(&context, ears, faceTone(b.body, 0.94), light: 0.22, shade: 0.16)
        Art.fill(&context, pinks, Art.color(faceEarPinkHex))
    }

    /// The skull: a rounded head a little wider at the cheeks, lit from the upper left.
    static func faceSkullPath() -> Path {
        Art.svg("M0,-29 C-17,-29 -28,-19 -29,-5 C-31,6 -27,17 -19,22 C-12,27 12,27 19,22 C27,17 31,6 29,-5 C28,-19 17,-29 0,-29Z")
    }

    static func faceSkull(_ context: inout GraphicsContext, _ b: Beast) {
        let skull = faceSkullPath()
        let coat: Kit.Stops = [(faceTone(b.body, 1.12), 0), (faceTone(b.body, 0.85), 1)]
        Art.fillRadial(&context, skull, coat, center: CGPoint(x: -9, y: -13), radius: 52)
        ArtStyle.rimEdge(&context, skull, bounds: CGRect(x: -31, y: -29, width: 62, height: 56), width: 2, alpha: 0.42)
        let chin = Art.svg("M-27,8 C-23,21 -11,26 0,26 C11,26 23,21 27,8 C21,23 -21,23 -27,8Z")
        Art.fill(&context, chin, faceTone(b.body, 0.7).opacity(0.35))
    }
}

// MARK: - Muzzle, nose, mouth, eyes

extension Kit {
    /// The pale face patch, by muzzle kind.
    static func faceMuzzle(_ context: inout GraphicsContext, _ b: Beast) {
        let patch: Path
        switch b.muzzle {
        case .short:
            patch = Art.svg("M0,4 C-9,4 -14,9 -14,15 C-14,21 -7,25 0,25 C7,25 14,21 14,15 C14,9 9,4 0,4Z")
        case .long:
            patch = Art.svg("M0,5 C-10,5 -15,13 -15,23 C-15,32 -8,37 0,37 C8,37 15,32 15,23 C15,13 10,5 0,5Z")
        case .broad:
            patch = Art.svg("M0,4 C-12,4 -20,9 -20,16 C-20,23 -10,27 0,27 C10,27 20,23 20,16 C20,9 12,4 0,4Z")
        case .pointed:
            if faceFullMask(b) {
                patch = Art.svg("M0,-19 C-7,-23 -22,-16 -23,-3 C-24,10 -10,24 0,30 C10,24 24,10 23,-3 C22,-16 7,-23 0,-19Z")
            } else {
                patch = Art.svg("M0,-7 C-4,-1 -16,3 -25,8 C-21,18 -9,25 0,30 C9,25 21,18 25,8 C16,3 4,-1 0,-7Z")
            }
        }
        Kit.solid(&context, patch, Art.color(b.belly), light: 0.12, shade: 0.14)
    }

    /// The nose (a rounded triangle with a small highlight) and the short line down to the mouth.
    /// Returns the y of the mouth.
    static func faceNose(_ context: inout GraphicsContext, _ b: Beast) -> CGFloat {
        let y: CGFloat = faceNoseY(b.muzzle)
        let s: CGFloat = faceNoseScale(b.muzzle)
        let mouthY: CGFloat = y + 4 * s + 4
        let line: Color = faceTone(b.dark, 0.8)
        Art.stroke(&context, Art.line(0, y + 3 * s, 0, mouthY), line, width: ArtStyle.detailLine)
        let nose = Kit.placed("M-5,-3 C-5,-5.5 5,-5.5 5,-3 C5,0 2,4 0,4 C-2,4 -5,0 -5,-3Z", x: 0, y: y, scale: s)
        Art.fill(&context, nose, Art.color(b.dark))
        Art.fill(&context, Art.ellipse(-1.8 * s, y - 2.6 * s, 1.8 * s, 1.0 * s), Color.white.opacity(0.55))
        return mouthY
    }

    /// The mouth, by mood. Never teeth.
    static func faceMouth(_ context: inout GraphicsContext, _ b: Beast, mood: BeastMood, y: CGFloat) {
        let line: Color = faceTone(b.dark, 0.8)
        let w: CGFloat = ArtStyle.detailLine
        switch mood {
        case .happy:
            ArtStyle.smile(&context, -4.5, y, width: 9, curve: 2.4, color: line, lineWidth: w)
            ArtStyle.smile(&context, 4.5, y, width: 9, curve: 2.4, color: line, lineWidth: w)
        case .calm:
            ArtStyle.smile(&context, 0, y, width: 11, curve: 1.2, color: line, lineWidth: w)
        case .surprised:
            Art.fill(&context, Art.ellipse(0, y + 2.5, 3.2, 3.8), line)
            Art.fill(&context, Art.ellipse(0, y + 4, 1.8, 1.6), Art.color(0xF2788A))
        case .sly:
            let smirk = Art.svg("M-5,0 Q3,3.5 9,-3")
            Art.stroke(&context, smirk.applying(CGAffineTransform(translationX: 0, y: y)), line, width: w)
        case .sad:
            ArtStyle.smile(&context, 0, y + 2.5, width: 11, curve: -1.8, color: line, lineWidth: w)
        case .proud:
            ArtStyle.smile(&context, -6, y, width: 12, curve: 3.2, color: line, lineWidth: w)
            ArtStyle.smile(&context, 6, y, width: 12, curve: 3.2, color: line, lineWidth: w)
        case .sleepy:
            ArtStyle.smile(&context, 0, y, width: 8, curve: 1.4, color: line, lineWidth: w)
        }
    }

    /// Two eyes at (±13, −4) and the gentle brows above them, by mood.
    static func faceEyes(_ context: inout GraphicsContext, _ b: Beast, mood: BeastMood, look: CGPoint) {
        let r: CGFloat = b.showsEyeWhite ? 7 : 4.2
        let line: Color = Art.color(0x2A1A12)
        let around: UInt32 = faceFullMask(b) ? b.belly : b.body
        switch mood {
        case .proud:
            Art.stroke(&context, faceBoth("M-18.5,-2.5 q5.5,-7 11,0"), line, width: ArtStyle.contourLine)
        case .sleepy:
            Art.stroke(&context, faceBoth("M-18.5,-5 q5.5,5.5 11,0"), line, width: ArtStyle.contourLine)
        case .happy, .calm, .surprised, .sly, .sad:
            let big: CGFloat = mood == .surprised ? r * 1.1 : r
            if b.showsEyeWhite {
                var rings = Art.circle(-13, -4, big + 0.5)
                rings.addPath(Art.circle(13, -4, big + 0.5))
                Art.stroke(&context, rings, faceTone(around, 0.62).opacity(0.55), width: 1.2)
            }
            ArtStyle.eye(&context, -13, -4, big, look: look, iris: line, showsWhite: b.showsEyeWhite)
            ArtStyle.eye(&context, 13, -4, big, look: look, iris: line, showsWhite: b.showsEyeWhite)
            if mood == .sly {
                var sockets = Art.circle(-13, -4, big + 0.7)
                sockets.addPath(Art.circle(13, -4, big + 0.7))
                Art.clipped(&context, to: sockets) { g in
                    Art.fill(&g, Art.rect(-22, -4 - big - 1, 44, big + 0.2), faceTone(around, 0.9))
                }
                Art.stroke(&context, faceBoth("M-19.5,-4.6 h13"), faceTone(around, 0.55), width: 1.2)
            }
        }
        let brow: Color = faceTone(around, 0.58)
        let lift: CGFloat = mood == .surprised ? -3 : 0
        let data: String = mood == .sad ? "M-18,-12.5 q4.5,-3 8.5,-3.5" : "M-18,-13.5 q4.5,-2.6 8.5,-1"
        let brows = faceBoth(data).applying(CGAffineTransform(translationX: 0, y: lift - (r - 4.2) * 0.5))
        Art.stroke(&context, brows, brow, width: ArtStyle.detailLine)
    }

    /// Three fine whiskers each side of the nose.
    static func faceWhiskers(_ context: inout GraphicsContext, _ b: Beast) {
        let y: CGFloat = faceNoseY(b.muzzle) + 3
        let hairs = faceBoth("M-9,0 q-12,-5 -25,-5 M-9,2 q-13,0 -26,2 M-9,4 q-11,4 -23,9")
        let moved = hairs.applying(CGAffineTransform(translationX: 0, y: y))
        Art.stroke(&context, moved, faceTone(b.dark, 0.9).opacity(0.5), width: 0.9)
    }

    /// The tiger's marks: a few dark tapered strokes on the forehead and the cheeks.
    static func faceStripes(_ context: inout GraphicsContext, _ b: Beast) {
        var marks = Art.svg("M-1.6,-30 L0,-16 L1.6,-30Z")
        marks.addPath(faceBoth("M-10,-29 L-6.5,-18 L-5.5,-28Z M-31,-3 L-20,-1 L-30,2.5Z M-30,6 L-21,7 L-28,11.5Z M-26,14 L-19,14 L-23,19Z"))
        Art.clipped(&context, to: faceSkullPath()) { g in
            Art.fill(&g, marks, Art.color(b.dark))
        }
    }
}

// MARK: - The face and the bust

extension Kit {
    /// The animal's head from the FRONT, centred on (0, 0), 60 across without the ears (ears and mane reach further: long ears up to y −75). For face chips (`Kit.faceChip`, then scale about 1.15) and portraits.
    static func beastFace(_ context: inout GraphicsContext, _ b: Beast, mood: BeastMood = .happy, look: CGPoint = .zero) {
        if b.mane {
            faceMane(&context, b)
        }
        if b.ears != .floppy {
            faceEars(&context, b)
        }
        faceSkull(&context, b)
        if b.stripes {
            faceStripes(&context, b)
        }
        if b.ears == .floppy {
            faceEars(&context, b)
        }
        faceMuzzle(&context, b)
        ArtStyle.cheek(&context, -20, 9, 7, alpha: 0.4)
        ArtStyle.cheek(&context, 20, 9, 7, alpha: 0.4)
        if b.whiskers {
            faceWhiskers(&context, b)
        }
        let mouthY: CGFloat = faceNose(&context, b)
        faceMouth(&context, b, mood: mood, y: mouthY)
        faceEyes(&context, b, mood: mood, look: look)
        // Soft light on the brow.
        let tilt = CGAffineTransform(translationX: -11, y: -21).rotated(by: deg(-24))
        Art.fill(&context, Art.ellipse(0, 0, 11, 4.5).applying(tilt), Art.color(0xFFFFFF, 0.14))
    }

    /// One front paw centred on (x, y): a rounded pad shape with two toe lines.
    static func facePaw(_ context: inout GraphicsContext, _ b: Beast, x: CGFloat, y: CGFloat) {
        let pad = Kit.placed("M-12,0 C-12,-9 -6,-13 0,-13 C6,-13 12,-9 12,0 C12,7 7,11 0,11 C-7,11 -12,7 -12,0Z", x: x, y: y)
        Kit.solid(&context, pad, faceTone(b.body, 1.06), light: 0.22, shade: 0.18, rim: 1.5)
        let toes = Kit.placed("M-4,2 v6 M4,2 v6", x: x, y: y)
        Art.stroke(&context, toes, faceTone(b.dark, 1.0).opacity(0.6), width: ArtStyle.detailLine)
    }

    /// Head, chest and front paws from the front, for a character-card portrait. Origin = the centre of the head; the chest and paws run down to about y = +130 at scale 1; `wave` raises one paw beside the head.
    static func beastBust(_ context: inout GraphicsContext, _ b: Beast, mood: BeastMood = .happy, look: CGPoint = .zero, wave: Bool = false) {
        if b.mane {
            Art.group(&context, x: 0, y: 10, scale: 1.18) { g in
                faceMane(&g, b)
            }
        }
        let k: CGFloat = clamp(0.8 + 0.2 * b.bulk, 0.85, 1.15)
        let wide = CGAffineTransform(scaleX: k, y: 1)
        let chest = Art.svg("M-26,12 C-48,24 -60,62 -58,108 C-57,124 -40,130 0,130 C40,130 57,124 58,108 C60,62 48,24 26,12Z").applying(wide)
        Kit.solid(&context, chest, Art.color(b.body), light: 0.24, shade: 0.24, rim: 2)
        let bib = Art.svg("M0,28 C-20,28 -30,60 -28,96 C-27,116 -14,124 0,124 C14,124 27,116 28,96 C30,60 20,28 0,28Z").applying(wide)
        Kit.solid(&context, bib, Art.color(b.belly), light: 0.14, shade: 0.16)
        // The shade the head throws on the chest.
        Art.clipped(&context, to: chest) { g in
            Art.fill(&g, Art.ellipse(4, 30, 34, 12), ArtStyle.coolShade.opacity(0.14))
        }
        let arm: Color = faceTone(b.body, 0.9)
        let armL = Art.svg("M-42,52 C-50,80 -42,104 -26,114").applying(wide)
        Art.stroke(&context, armL, arm, width: 17)
        facePaw(&context, b, x: -24 * k, y: 117)
        if wave {
            let wx: CGFloat = b.mane ? 68 : 58
            let raised = Art.svg("M42,56 C58,50 64,26 \(wx),-4")
            Art.stroke(&context, raised, arm, width: 17)
            facePaw(&context, b, x: wx, y: -12)
        } else {
            let armR = Art.svg("M42,52 C50,80 42,104 26,114").applying(wide)
            Art.stroke(&context, armR, arm, width: 17)
            facePaw(&context, b, x: 24 * k, y: 117)
        }
        beastFace(&context, b, mood: mood, look: look)
    }
}

// MARK: - Ready-made looks

extension Kit {
    /// A brown bear.
    static func bearLook() -> Beast {
        Beast(body: 0x8A5A3A, belly: 0xD9B48A, dark: 0x3E2A1E, ears: .round, tail: .stub, muzzle: .broad, bodyLength: 1.9, legLength: 0.45, bulk: 1.25)
    }

    /// A golden lion with a warm brown mane.
    static func lionLook() -> Beast {
        Beast(body: 0xE8B04A, belly: 0xF7E2B0, dark: 0x9A5A2A, ears: .round, tail: .tufted, muzzle: .broad, bodyLength: 2.1, legLength: 0.8, bulk: 1.0, mane: true)
    }

    /// A sandy brown-grey hare.
    static func hareLook() -> Beast {
        Beast(body: 0xB59A7A, belly: 0xF1E6D2, dark: 0x5A4636, ears: .long, tail: .fluffy, muzzle: .short, bodyLength: 1.3, legLength: 0.6, bulk: 0.8, whiskers: true)
    }

    /// A rabbit: softer, rounder and greyer than the hare.
    static func rabbitLook() -> Beast {
        Beast(body: 0xC4BDB6, belly: 0xF6F1EA, dark: 0x6E625C, ears: .long, tail: .fluffy, muzzle: .short, bodyLength: 1.2, legLength: 0.45, bulk: 0.85, whiskers: true)
    }

    /// A grey Virginia opossum: a pale pointed face, small dark ears, bead eyes.
    static func possumLook() -> Beast {
        Beast(body: 0x9A9AA0, belly: 0xF4F1EA, dark: 0x3A3438, ears: .small, tail: .bushy, muzzle: .pointed, bodyLength: 1.5, legLength: 0.35, bulk: 0.9, whiskers: true, showsEyeWhite: false)
    }

    /// A grey donkey with a pale muzzle and belly.
    static func donkeyLook() -> Beast {
        Beast(body: 0x9C948C, belly: 0xEDE6DA, dark: 0x4A423E, ears: .long, tail: .tufted, muzzle: .long, bodyLength: 1.9, legLength: 1.1, bulk: 0.95)
    }

    /// An old hound: tan with a paler muzzle.
    static func dogLook() -> Beast {
        Beast(body: 0xC69A62, belly: 0xEBD3AC, dark: 0x4E3524, ears: .floppy, tail: .thin, muzzle: .long, bodyLength: 1.7, legLength: 0.8, bulk: 0.85)
    }

    /// A ginger cat.
    static func catLook() -> Beast {
        Beast(body: 0xD98E4A, belly: 0xFBEBD2, dark: 0x6B3E22, ears: .pointed, tail: .thin, muzzle: .short, bodyLength: 1.3, legLength: 0.55, bulk: 0.7, whiskers: true)
    }

    /// A red fox with white cheeks.
    static func foxLook() -> Beast {
        Beast(body: 0xE0702E, belly: 0xFFF3E2, dark: 0x3B2A26, ears: .pointed, tail: .bushy, muzzle: .pointed, bodyLength: 1.5, legLength: 0.6, bulk: 0.75, whiskers: true)
    }

    /// A chestnut horse with a pale muzzle.
    static func horseLook() -> Beast {
        Beast(body: 0x9A5B34, belly: 0xE9CFA8, dark: 0x3A261C, ears: .pointed, tail: .long, muzzle: .long, bodyLength: 2.0, legLength: 1.2, bulk: 1.0)
    }

    /// An orange tiger with dark stripes.
    static func tigerLook() -> Beast {
        Beast(body: 0xF09A3A, belly: 0xFFF1D6, dark: 0x3A2A22, ears: .round, tail: .long, muzzle: .broad, bodyLength: 2.1, legLength: 0.75, bulk: 1.05, stripes: true, whiskers: true)
    }

    /// A slim sandy gazelle (callers add the horns).
    static func gazelleLook() -> Beast {
        Beast(body: 0xD9A866, belly: 0xFBF0DC, dark: 0x5A4030, ears: .pointed, tail: .stub, muzzle: .long, bodyLength: 1.6, legLength: 1.2, bulk: 0.7)
    }
}
