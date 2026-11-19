import SwiftUI
import OmramoCore

// The storybook person: how a person looks (`Person`) and the HEAD every person shares.
// The same face for everyone — only skin, hair and dress change. Bodies, poses and the bust
// live in Kit+PeopleBody.swift and are drawn against the same `Person`.

extension Kit {
    /// How a person looks. All colours 0xRRGGBB.
    struct Person: Sendable {
        enum Age: Sendable { case child, adult, elder }
        enum Hair: Sendable { case short, bob, long, bun, topknot, braids, curly, bald, shaved }
        enum Beard: Sendable { case none, short, long, moustache }
        enum Headwear: Sendable { case none, strawCone, turban, headcloth, furHat, cap, hood, headwrap, kerchief, circlet, wideBrim }
        enum Garment: Sendable { case tunic, robe, kimono, kilt, parka, wrapper, shirtTrousers, dress, chiton }
        var age: Age
        var skin: UInt32
        var hair: UInt32
        var hairStyle: Hair
        var beard: Beard
        var headwear: Headwear
        var headwearColor: UInt32
        var garment: Garment
        var cloth: UInt32      // main garment colour
        var trim: UInt32       // sash, collar, hem, cuffs, fur ruff
        var legs: UInt32       // trousers / leggings / boots, or the skin colour for bare legs
        var showsEyeWhite: Bool   // true for Low-tier stories (large friendly eye)

        init(
            age: Age = .adult,
            skin: UInt32,
            hair: UInt32,
            hairStyle: Hair = .short,
            beard: Beard = .none,
            headwear: Headwear = .none,
            headwearColor: UInt32 = 0xFFFFFF,
            garment: Garment = .tunic,
            cloth: UInt32,
            trim: UInt32,
            legs: UInt32,
            showsEyeWhite: Bool = true
        ) {
            self.age = age
            self.skin = skin
            self.hair = hair
            self.hairStyle = hairStyle
            self.beard = beard
            self.headwear = headwear
            self.headwearColor = headwearColor
            self.garment = garment
            self.cloth = cloth
            self.trim = trim
            self.legs = legs
            self.showsEyeWhite = showsEyeWhite
        }
    }

    enum Mouth: Sendable { case smile, grin, open, oh, flat, sad }

    // MARK: Tones and small tools

    /// `hex` with each of red, green and blue scaled by `k` (clamped to 0…255).
    static func personToneHex(_ hex: UInt32, _ k: CGFloat) -> UInt32 {
        let r: CGFloat = CGFloat((hex >> 16) & 0xFF) * k
        let g: CGFloat = CGFloat((hex >> 8) & 0xFF) * k
        let b: CGFloat = CGFloat(hex & 0xFF) * k
        let r8: UInt32 = UInt32(min(255, max(0, r)))
        let g8: UInt32 = UInt32(min(255, max(0, g)))
        let b8: UInt32 = UInt32(min(255, max(0, b)))
        return (r8 << 16) | (g8 << 8) | b8
    }

    /// Lighter (k > 1) or darker (k < 1) tone of a hex colour.
    static func personTone(_ hex: UInt32, _ k: CGFloat) -> Color {
        Art.color(personToneHex(hex, k))
    }

    /// The outline of the adult skull: x −26…26, y −28…28, the jaw a little narrower than the brow.
    static func personSkullPath() -> Path {
        Art.svg("M0,-28 C15,-28 26,-18 26,-3 C26,12 18,28 0,28 C-18,28 -26,12 -26,-3 C-26,-18 -15,-28 0,-28Z")
    }

    /// Round bumps along part of an ellipse (curls, a fur edge, a ruff). Angles in degrees,
    /// 0 pointing right and 270 pointing up.
    static func personScallop(
        cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat,
        from a0: CGFloat, to a1: CGFloat, count: Int, r: CGFloat
    ) -> Path {
        var path = Path()
        let n: Int = max(2, count)
        for i in 0..<n {
            let t: CGFloat = CGFloat(i) / CGFloat(n - 1)
            let a: CGFloat = Kit.deg(a0 + (a1 - a0) * t)
            let x: CGFloat = cx + cos(a) * rx
            let y: CGFloat = cy + sin(a) * ry
            path.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
        }
        return path
    }

    /// Fills `shape` and models it with the one light. When `mirrored` (the caller has flipped
    /// x) the light and the shade swap sides, so they end up right in the final picture.
    static func personLit(
        _ context: inout GraphicsContext, _ shape: Path, _ color: Color, bounds: CGRect,
        mirrored: Bool, light: Double = 0.24, shade: Double = 0.22
    ) {
        Art.fill(&context, shape, color)
        if mirrored {
            let flip = CGAffineTransform(scaleX: -1, y: 1)
            let flipped: Path = shape.applying(flip)
            let box = CGRect(x: -bounds.maxX, y: bounds.minY, width: bounds.width, height: bounds.height)
            Art.group(&context, scaleX: -1) { f in
                ArtStyle.form(&f, flipped, bounds: box, light: light, shade: shade)
            }
        } else {
            ArtStyle.form(&context, shape, bounds: bounds, light: light, shade: shade)
        }
    }

    /// Hair that the headwear hides completely.
    static func personCoversHair(_ headwear: Person.Headwear) -> Bool {
        switch headwear {
        case .turban, .headcloth, .furHat, .hood, .headwrap, .kerchief: return true
        case .none, .strawCone, .cap, .circlet, .wideBrim: return false
        }
    }

    // MARK: The head

    /// The head — skull, ear(s), hair by style, headwear over the hair, beard, face — centred
    /// on (0, 0). The skull is 52 wide and 56 tall for an adult and an elder (x −26…26,
    /// y −28…28), 48 × 50 for a child (the same drawing, scaled); hair and headwear may reach
    /// about 14 units above and to the sides. Faces the reader, turned very slightly LEFT.
    /// `look` moves the irises (−1…1 each axis). `closedEyes` draws sleeping/laughing arcs
    /// instead of eyes. When `mirrored` is true the caller has flipped x: the catchlights and
    /// the lit side are drawn so they end up upper-left in the final picture.
    static func personHead(
        _ context: inout GraphicsContext,
        _ p: Person,
        look: CGPoint = .zero,
        mouth: Mouth = .smile,
        closedEyes: Bool = false,
        mirrored: Bool = false
    ) {
        let isChild: Bool = p.age == .child
        let sy: CGFloat = isChild ? 50.0 / 56.0 : 1
        let sx: CGFloat = isChild ? (48.0 / 52.0) / (50.0 / 56.0) : 1
        Art.group(&context, scale: sy, scaleX: sx) { g in
            personHairBack(&g, p)
            personHeadwearBack(&g, p, mirrored: mirrored)
            personEars(&g, p)
            personSkull(&g, p, mirrored: mirrored)
            personHairTop(&g, p, mirrored: mirrored)
            personBeard(&g, p)
            personFace(&g, p, look: look, closedEyes: closedEyes, mirrored: mirrored)
            personMouth(&g, p, mouth)
            personHeadwear(&g, p, mirrored: mirrored)
        }
    }

    /// Small ears at the sides; the far (right) one a touch smaller, as the head turns left.
    static func personEars(_ g: inout GraphicsContext, _ p: Person) {
        let skin: Color = personTone(p.skin, 0.95)
        let inner: Color = personTone(p.skin, 0.74)
        var ears = Path()
        ears.addPath(Art.ellipse(-26.5, 3, 5, 7))
        ears.addPath(Art.ellipse(26, 3, 4.4, 6.6))
        Art.fill(&g, ears, skin)
        var marks = Path()
        marks.addPath(Art.ellipse(-27, 3.4, 2.4, 3.9))
        marks.addPath(Art.ellipse(26.6, 3.4, 2.1, 3.6))
        Art.fill(&g, marks, inner)
    }

    /// The skull: skin in a soft round gradient, lit from the upper left.
    static func personSkull(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let skull: Path = personSkullPath()
        let side: CGFloat = mirrored ? 1 : -1
        let tone: Kit.Stops = [
            (personTone(p.skin, 1.12), 0), (Art.color(p.skin), 0.48), (personTone(p.skin, 0.86), 1),
        ]
        Art.fillRadial(&g, skull, tone, center: CGPoint(x: 7 * side, y: -12), radius: 52)
        Art.clipped(&g, to: skull) { c in
            // A little indigo under the jaw on the side away from the light.
            Art.fill(&c, Art.ellipse(-20 * side, 20, 12, 13), ArtStyle.coolShade.opacity(0.10))
        }
        if mirrored {
            Art.group(&g, scaleX: -1) { f in
                ArtStyle.rimLight(&f, 0, -2, 28, alpha: 0.22)
            }
        } else {
            ArtStyle.rimLight(&g, 0, -2, 28, alpha: 0.22)
        }
    }

    // MARK: Face

    /// One eye. When `mirrored`, the eye is drawn flipped about its own centre so that the
    /// catchlight ends up upper-left after the caller's flip; the iris stays where `look` puts it.
    static func personEye(
        _ g: inout GraphicsContext, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat,
        look: CGPoint, white: Bool, mirrored: Bool
    ) {
        let iris: Color = Art.color(0x2A1A12)
        if mirrored {
            let flippedLook = CGPoint(x: -look.x, y: look.y)
            Art.group(&g, x: cx, y: cy, scaleX: -1) { e in
                ArtStyle.eye(&e, 0, 0, r, look: flippedLook, iris: iris, showsWhite: white)
            }
        } else {
            ArtStyle.eye(&g, cx, cy, r, look: look, iris: iris, showsWhite: white)
        }
    }

    /// Eyes (or closed-eye arcs), gentle brows, the nose mark, the blush; an elder's soft lines.
    static func personFace(_ g: inout GraphicsContext, _ p: Person, look: CGPoint, closedEyes: Bool, mirrored: Bool) {
        let isElder: Bool = p.age == .elder
        let line: Color = personTone(p.skin, 0.72)
        if closedEyes {
            let lids: Path = Art.svg("M-13.8,2 q4.3,3.6 8.6,0 M5.2,2 q4.3,3.6 8.6,0")
            Art.stroke(&g, lids, Art.color(0x2A1A12), width: 1.9)
        } else {
            let r: CGFloat = p.showsEyeWhite ? 5.2 : 3.2
            if p.showsEyeWhite {
                // A soft lid shadow so the white sits in the face.
                var sockets = Path()
                sockets.addPath(Art.circle(-9.5, 2, r + 0.9))
                sockets.addPath(Art.circle(9.5, 2, r + 0.9))
                Art.fill(&g, sockets, personTone(p.skin, 0.8).opacity(0.55))
            }
            personEye(&g, -9.5, 2, r, look: look, white: p.showsEyeWhite, mirrored: mirrored)
            personEye(&g, 9.5, 2, r, look: look, white: p.showsEyeWhite, mirrored: mirrored)
        }
        // Brows: short, lifted, never angled down toward the nose.
        let brows: Path = Art.svg("M-15.2,-7.6 q5.4,-3.2 10.4,-1 M4.8,-8.6 q5,-2.4 10.4,1")
        let browTone: Color = isElder ? Art.color(p.hair, 0.7) : personTone(p.hair, 0.8).opacity(0.9)
        Art.stroke(&g, brows, browTone, width: isElder ? 2.2 : 1.9)
        // Nose: one short curve, a touch left of centre.
        Art.stroke(&g, Art.svg("M-3.6,8.2 q2.6,2.4 5.2,0"), line, width: ArtStyle.detailLine)
        ArtStyle.cheek(&g, -15.5, 10.5, 6.5, alpha: 0.42)
        ArtStyle.cheek(&g, 14.5, 10.5, 6.2, alpha: 0.42)
        if isElder {
            let lines: Path = Art.svg("M-17.5,9 q-2,3 -1,6.6 M16.5,9 q2,3 1,6.6 M-18.6,-1 q-2,1 -2.8,3 M18.2,-1 q2,1 2.8,3")
            Art.stroke(&g, lines, line.opacity(0.6), width: 1)
        }
    }

    /// The mouth, at about y 15, a touch left of centre.
    static func personMouth(_ g: inout GraphicsContext, _ p: Person, _ mouth: Mouth) {
        let line: Color = personTone(p.skin, 0.42)
        let inside: Color = Art.color(0x7A2E24)
        let mx: CGFloat = -0.5
        switch mouth {
        case .smile:
            ArtStyle.smile(&g, mx, 14.6, width: 13, curve: 2.6, color: line, lineWidth: 2)
        case .grin:
            let shape: Path = Art.svg("M-8.8,13 C-4,14.4 3,14.4 7.8,13 C7,19.4 3.2,22 -0.5,22 C-4.2,22 -8,19.4 -8.8,13Z")
            Art.fill(&g, shape, inside)
            Art.clipped(&g, to: shape) { c in
                Art.fill(&c, Art.rect(-9, 12, 17, 4.6, radius: 1.6), Art.color(0xFFF6E8))
                Art.fill(&c, Art.ellipse(-0.5, 22, 4.2, 2.4), Art.color(0xE8776A))
            }
            Art.stroke(&g, Art.svg("M-8.8,13 C-4,14.4 3,14.4 7.8,13"), line, width: 1.4)
        case .open:
            let shape: Path = Art.svg("M-5.8,13.6 C-2.5,12.6 1.5,12.6 4.8,13.6 C5.2,18 2.6,20.6 -0.5,20.6 C-3.6,20.6 -6.2,18 -5.8,13.6Z")
            Art.fill(&g, shape, inside)
            Art.clipped(&g, to: shape) { c in
                Art.fill(&c, Art.ellipse(-0.5, 20.4, 3.4, 2.2), Art.color(0xE8776A))
            }
        case .oh:
            Art.fill(&g, Art.ellipse(mx, 16, 2.8, 3.4), inside)
            Art.fill(&g, Art.ellipse(mx, 17.4, 1.7, 1.4), Art.color(0xE8776A, 0.7))
        case .flat:
            Art.stroke(&g, Art.line(-6.5, 15.4, 5.5, 15.4), line, width: 2)
        case .sad:
            ArtStyle.smile(&g, mx, 17, width: 11, curve: -2, color: line, lineWidth: 2)
        }
    }
}

// MARK: - Hair and beard

extension Kit {
    /// `path` as drawn, or flipped left to right when the caller has mirrored the head (for
    /// sheens and lit edges, which belong on the picture's upper left).
    static func personSide(_ path: Path, mirrored: Bool) -> Path {
        mirrored ? path.applying(CGAffineTransform(scaleX: -1, y: 1)) : path
    }

    /// Headwear that wraps the whole head, so no hair hangs out behind either.
    static func personHidesBackHair(_ headwear: Person.Headwear) -> Bool {
        switch headwear {
        case .headcloth, .hood, .kerchief: return true
        case .none, .strawCone, .turban, .furHat, .cap, .headwrap, .circlet, .wideBrim: return false
        }
    }

    /// Headwear that leaves the crown free for a bun, a topknot or a round of curls.
    static func personLeavesCrown(_ headwear: Person.Headwear) -> Bool {
        switch headwear {
        case .none, .circlet: return true
        case .strawCone, .turban, .headcloth, .furHat, .cap, .hood, .headwrap, .kerchief, .wideBrim: return false
        }
    }

    /// Hair behind the skull: the fall of a bob or long hair, braids, a bun, a topknot, the
    /// round of curly hair.
    static func personHairBack(_ g: inout GraphicsContext, _ p: Person) {
        let hair: Color = Art.color(p.hair)
        let dark: Color = personTone(p.hair, 0.76)
        let hangs: Bool = !personHidesBackHair(p.headwear)
        let crown: Bool = personLeavesCrown(p.headwear)
        switch p.hairStyle {
        case .short, .bald, .shaved:
            break
        case .bob:
            guard hangs else { return }
            let fall: Path = Art.svg("M-30,-8 C-32,-30 -14,-36 0,-36 C14,-36 32,-30 30,-8 C31.5,6 30.5,18 27,24.5 C23,28 18.5,25 19,18 L-19,18 C-18.5,25 -23,28 -27,24.5 C-30.5,18 -31.5,6 -30,-8Z")
            Art.fill(&g, fall, hair)
            Art.stroke(&g, Art.svg("M28.5,-2 C29.5,8 28.5,17 25.5,23 M-28.5,-2 C-29.5,8 -28.5,17 -25.5,23"), dark, width: 1.2)
        case .long:
            guard hangs else { return }
            let fall: Path = Art.svg("M-29,-8 C-32,-32 -14,-37 0,-37 C14,-37 32,-32 29,-8 C32,14 34.5,36 31,55 C27,59 21,58 18,54 L-18,54 C-21,58 -27,59 -31,55 C-34.5,36 -32,14 -29,-8Z")
            let tone: Kit.Stops = [(hair, 0), (hair, 0.45), (dark, 1)]
            Art.fillLinear(&g, fall, tone, from: CGPoint(x: -20, y: -30), to: CGPoint(x: 24, y: 56))
            let strands: Path = Art.svg("M-29,12 C-31,28 -31,42 -28,54 M29,12 C31,28 31,42 28,54 M-24,30 C-25,40 -24,48 -22,54 M24,30 C25,40 24,48 22,54")
            Art.stroke(&g, strands, dark, width: 1.1)
        case .braids:
            guard hangs else { return }
            personBraids(&g, p)
        case .bun:
            guard crown else { return }
            Art.fill(&g, Art.ellipse(9, -35.5, 9.5, 8), hair)
            Art.fill(&g, Art.ellipse(6.5, -37, 6.5, 5.2), personTone(p.hair, 1.18))
            Art.stroke(&g, Art.svg("M1.5,-31 C6,-28.5 12,-28.5 16.5,-31.5"), dark, width: 1.6)
        case .topknot:
            guard crown else { return }
            Art.fill(&g, Art.rect(-3.4, -35, 6.8, 6, radius: 2), dark)
            Art.fill(&g, Art.ellipse(0, -38, 6.6, 5.4), hair)
            Art.fill(&g, Art.ellipse(-1.6, -39.2, 3.6, 2.6), personTone(p.hair, 1.18))
            Art.stroke(&g, Art.line(-3.6, -33, 3.6, -33), Art.color(p.trim), width: 1.8)
        case .curly:
            guard crown else { return }
            let curls: Path = personScallop(cx: 0, cy: -4, rx: 26.5, ry: 28.5, from: 184, to: 356, count: 11, r: 7)
            Art.fill(&g, curls, hair)
        }
    }

    /// Two braids hanging behind the ears and in front of the shoulders, each tied in `trim`.
    static func personBraids(_ g: inout GraphicsContext, _ p: Person) {
        var plaits = Path()
        var creases = Path()
        var ties = Path()
        let sides: [CGFloat] = [-1, 1]
        for side in sides {
            for i in 0..<5 {
                let t: CGFloat = CGFloat(i)
                let x: CGFloat = side * (27.5 - t * 0.5)
                let y: CGFloat = 12 + t * 8
                plaits.addEllipse(in: CGRect(x: x - 4.8, y: y - 5.2, width: 9.6, height: 10.4))
                creases.move(to: CGPoint(x: x - 3.6, y: y + 2.6))
                creases.addLine(to: CGPoint(x: x + 3.6, y: y + 5))
            }
            let endX: CGFloat = side * 25.5
            plaits.addPath(Art.svg("M-3.4,0 C-3,5 -1.4,8.5 0,10 C1.4,8.5 3,5 3.4,0Z").applying(CGAffineTransform(translationX: endX, y: 49)))
            ties.addPath(Art.rect(endX - 4.2, 47, 8.4, 3.4, radius: 1.6))
        }
        Art.fill(&g, plaits, Art.color(p.hair))
        Art.stroke(&g, creases, personTone(p.hair, 0.7), width: 1)
        Art.fill(&g, ties, Art.color(p.trim))
    }

    /// Hair over the top of the skull: the cap of hair with its hairline, by style.
    static func personHairTop(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        if personCoversHair(p.headwear) { return }
        let hair: Color = Art.color(p.hair)
        let cap: Path = Art.svg("M-26.5,-3 C-29,-26 -13,-34.5 0,-34.5 C13,-34.5 29,-26 26.5,-3 C23,-15 13,-21 0,-21 C-13,-21 -23,-15 -26.5,-3Z")
        var sheen: Bool = true
        switch p.hairStyle {
        case .short, .long, .bun, .topknot, .braids:
            Art.fill(&g, cap, hair)
        case .bob:
            let fringe: Path = Art.svg("M-27.5,8 C-30.5,-24 -13,-35 0,-35 C13,-35 30.5,-24 27.5,8 C26,-5 22.5,-14 14,-19.5 C6,-16 -8,-15.5 -17,-19.5 C-23,-14 -26,-5 -27.5,8Z")
            Art.fill(&g, fringe, hair)
        case .curly:
            Art.fill(&g, cap, hair)
            let edge: Path = personScallop(cx: 0, cy: 2, rx: 24, ry: 22.5, from: 204, to: 336, count: 8, r: 5.2)
            Art.fill(&g, edge, hair)
            let curls: Path = Art.svg("M-15,-26 q3,-3 6,0 M-3,-29 q3,-3 6,0 M9,-26 q3,-3 6,0 M-20,-17 q2.5,-2.5 5,0 M15,-17 q2.5,-2.5 5,0")
            Art.stroke(&g, curls, personTone(p.hair, 0.7), width: 1)
        case .bald:
            sheen = false
            if p.age == .elder {
                // What is left of an elder's hair: a soft fringe above each ear.
                let fringe: Path = Art.svg("M-26.2,-10 C-30.5,-8 -31,3 -26.6,7 C-25,2 -24.6,-5 -26.2,-10Z M26.2,-10 C30.5,-8 31,3 26.6,7 C25,2 24.6,-5 26.2,-10Z")
                Art.fill(&g, fringe, hair)
            }
        case .shaved:
            sheen = false
            Art.clipped(&g, to: personSkullPath()) { c in
                Art.fill(&c, cap, personTone(p.skin, 0.62).opacity(0.5))
            }
        }
        if sheen {
            let shine: Path = Art.svg("M-20,-24 C-14,-29.5 -7,-31.5 0,-31.5")
            Art.stroke(&g, personSide(shine, mirrored: mirrored), ArtStyle.warmLight.opacity(0.3), width: 1.8)
        }
    }

    /// The beard, in a tone of the hair: short along the jaw, long and a little pointed, or a
    /// moustache alone. Drawn under the face, so the mouth stays clear.
    static func personBeard(_ g: inout GraphicsContext, _ p: Person) {
        let tone: Color = personTone(p.hair, 0.94)
        let dark: Color = personTone(p.hair, 0.72)
        let whiskers: Path = Art.svg("M-0.5,11.4 C-3.5,9.6 -9,10.6 -12.5,14.8 C-8.5,14.2 -4,14.6 -0.5,13 C3,14.6 7.5,14.2 11.5,14.8 C8,10.6 2.5,9.6 -0.5,11.4Z")
        switch p.beard {
        case .none:
            break
        case .moustache:
            Art.fill(&g, whiskers, tone)
        case .short:
            let jaw: Path = Art.svg("M-24.5,5 C-24,21 -12,31 0,31 C12,31 24,21 24.5,5 C20,16 12,21.5 6,21.5 C3,19.6 -3,19.6 -6,21.5 C-12,21.5 -20,16 -24.5,5Z")
            Art.fill(&g, jaw, tone)
            Art.stroke(&g, Art.svg("M-14,23 q1,3 3,5 M0,23.5 L0,29 M14,23 q-1,3 -3,5"), dark, width: 1)
        case .long:
            let fall: Path = Art.svg("M-24.5,5 C-25.5,26 -14,42 -3,50.5 C-1,52.6 1,52.6 3,50.5 C14,42 25.5,26 24.5,5 C20,16 12,21.5 6,21.5 C3,19.6 -3,19.6 -6,21.5 C-12,21.5 -20,16 -24.5,5Z")
            let fade: Kit.Stops = [(tone, 0), (tone, 0.5), (dark, 1)]
            Art.fillLinear(&g, fall, fade, from: CGPoint(x: -14, y: 8), to: CGPoint(x: 16, y: 54))
            let strands: Path = Art.svg("M-11,25 C-10,34 -6.5,42 -2.5,47.5 M0,24 L0,47 M11,25 C10,34 6.5,42 2.5,47.5 M-18,20 C-17,28 -14,35 -10,40")
            Art.stroke(&g, strands, dark, width: 1)
            Art.fill(&g, whiskers, tone)
        }
    }
}

// MARK: - Headwear

extension Kit {
    /// The part of the headwear that sits behind the head: the hood, the headcloth's lappets.
    static func personHeadwearBack(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let color: Color = Art.color(p.headwearColor)
        switch p.headwear {
        case .hood:
            let hood: Path = Art.svg("M0,-41 C24,-41 38,-22 38,2 C38,22 29,35 15,40 L-15,40 C-29,35 -38,22 -38,2 C-38,-22 -24,-41 0,-41Z")
            personLit(&g, hood, color, bounds: CGRect(x: -38, y: -41, width: 76, height: 81), mirrored: mirrored)
        case .headcloth:
            let cloth: Path = Art.svg("M-29,-12 C-41,2 -42,26 -38,42 L-17,42 C-19,28 -22,14 -22,0 L22,0 C22,14 19,28 17,42 L38,42 C42,26 41,2 29,-12Z")
            personLit(&g, cloth, color, bounds: CGRect(x: -42, y: -12, width: 84, height: 54), mirrored: mirrored)
            var stripes = Path()
            for i in 0..<6 {
                let y: CGFloat = 2 + CGFloat(i) * 7
                stripes.move(to: CGPoint(x: -43, y: y))
                stripes.addLine(to: CGPoint(x: 43, y: y + 1.5))
            }
            let bands: Path = stripes
            Art.clipped(&g, to: cloth) { c in
                Art.stroke(&c, bands, personTone(p.headwearColor, 0.62), width: 2.6, cap: .butt)
            }
        case .none, .strawCone, .turban, .furHat, .cap, .headwrap, .kerchief, .circlet, .wideBrim:
            break
        }
    }

    /// The headwear in front: over the hair and the brow.
    static func personHeadwear(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        switch p.headwear {
        case .none: break
        case .strawCone: personStrawCone(&g, p, mirrored: mirrored)
        case .turban: personTurban(&g, p, mirrored: mirrored)
        case .headcloth: personHeadclothBrow(&g, p, mirrored: mirrored)
        case .furHat: personFurHat(&g, p, mirrored: mirrored)
        case .cap: personCap(&g, p, mirrored: mirrored)
        case .hood: personHoodRuff(&g, p, mirrored: mirrored)
        case .headwrap: personHeadwrap(&g, p, mirrored: mirrored)
        case .kerchief: personKerchief(&g, p, mirrored: mirrored)
        case .circlet: personCirclet(&g, p, mirrored: mirrored)
        case .wideBrim: personWideBrim(&g, p, mirrored: mirrored)
        }
    }

    /// The soft shadow a brim throws on the brow.
    static func personBrimShade(_ g: inout GraphicsContext, y: CGFloat) {
        Art.clipped(&g, to: personSkullPath()) { c in
            Art.fill(&c, Art.ellipse(0, y, 30, 7), ArtStyle.coolShade.opacity(0.2))
        }
    }

    /// A wide, low cone of woven straw (an East or South-East Asian farmer's hat).
    static func personStrawCone(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        personBrimShade(&g, y: -16)
        let cone: Path = Art.svg("M0,-42 C-4,-42 -30,-23 -40,-14 C-41.5,-12 -40,-10.5 -37.5,-11.5 C-20,-18.5 20,-18.5 37.5,-11.5 C40,-10.5 41.5,-12 40,-14 C30,-23 4,-42 0,-42Z")
        personLit(&g, cone, Art.color(p.headwearColor), bounds: CGRect(x: -41, y: -42, width: 82, height: 31), mirrored: mirrored, light: 0.3, shade: 0.26)
        let weave: Path = Art.svg("M0,-41 L-26,-17 M0,-41 L-13,-18.5 M0,-41 L0,-18 M0,-41 L13,-18.5 M0,-41 L26,-17 M-22,-25.5 C-10,-29 10,-29 22,-25.5")
        Art.stroke(&g, weave, personTone(p.headwearColor, 0.72).opacity(0.7), width: 0.9)
        let edge: Path = Art.svg("M-39,-14.5 C-29,-23.5 -5,-41 0,-41.4")
        Art.stroke(&g, personSide(edge, mirrored: mirrored), ArtStyle.warmLight.opacity(0.55), width: 1.2)
    }

    /// A turban: wound bands that cross above the brow.
    static func personTurban(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let wound: Path = Art.svg("M-28,-7 C-34,-29 -17,-42 0,-42 C17,-42 34,-29 28,-7 C20,-18 7,-22 0,-17 C-7,-22 -20,-18 -28,-7Z")
        personLit(&g, wound, Art.color(p.headwearColor), bounds: CGRect(x: -32, y: -42, width: 64, height: 35), mirrored: mirrored)
        let band: Path = Art.svg("M-28,-7 C-20,-22 -4,-32 14,-36 C20,-34 25,-30 28,-24 C16,-24 6,-22 0,-17 C-7,-22 -20,-18 -28,-7Z")
        Art.fill(&g, band, personTone(p.headwearColor, 1.1).opacity(0.6))
        let folds: Path = Art.svg("M-27,-13 C-17,-27 -2,-35 14,-36 M-21,-31 C-9,-39 8,-40 20,-33 M0,-17 C6,-23 16,-25 28,-24 M27,-15 C20,-19 12,-20 5,-19")
        Art.stroke(&g, folds, personTone(p.headwearColor, 0.7), width: 1.1)
    }

    /// The brow and crown of the striped linen headcloth; its lappets are drawn behind.
    static func personHeadclothBrow(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let crown: Path = Art.svg("M-28.5,-5 C-35,-28 -17,-38 0,-38 C17,-38 35,-28 28.5,-5 C22,-16 11,-19.5 0,-19.5 C-11,-19.5 -22,-16 -28.5,-5Z")
        personLit(&g, crown, Art.color(p.headwearColor), bounds: CGRect(x: -32, y: -38, width: 64, height: 33), mirrored: mirrored)
        let stripes: Path = Art.svg("M0,-38 L0,-20 M-9,-37 C-10,-31 -10,-25 -9,-20 M9,-37 C10,-31 10,-25 9,-20 M-18,-34 C-20,-28 -20,-22 -18.5,-18 M18,-34 C20,-28 20,-22 18.5,-18 M-26,-27 C-28,-21 -27.5,-15 -26,-10 M26,-27 C28,-21 27.5,-15 26,-10")
        Art.clipped(&g, to: crown) { c in
            Art.stroke(&c, stripes, personTone(p.headwearColor, 0.62), width: 2.4, cap: .butt)
        }
        let browBand: Path = Art.svg("M-27.6,-7.5 C-21,-17 -11,-20.5 0,-20.5 C11,-20.5 21,-17 27.6,-7.5")
        Art.stroke(&g, browBand, personTone(p.headwearColor, 0.8), width: 2)
    }

    /// A round fur hat with ear-flaps and a soft, bumpy edge.
    static func personFurHat(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let color: Color = Art.color(p.headwearColor)
        let flaps: Path = Art.svg("M-30,-12 C-34.5,-2 -33.5,12 -28,17 C-24,12 -23.5,-2 -25,-12Z M30,-12 C34.5,-2 33.5,12 28,17 C24,12 23.5,-2 25,-12Z")
        Art.fill(&g, flaps, personTone(p.headwearColor, 0.86))
        let dome: Path = Art.svg("M-29.5,-9 C-34,-32 -17,-42 0,-42 C17,-42 34,-32 29.5,-9 C20,-17 -20,-17 -29.5,-9Z")
        var fur: Path = personScallop(cx: 0, cy: -8, rx: 29, ry: 31, from: 192, to: 348, count: 13, r: 4.6)
        fur.addPath(dome)
        personLit(&g, fur, color, bounds: CGRect(x: -34, y: -44, width: 68, height: 36), mirrored: mirrored)
        // The thick band of fur above the brow.
        let furBand: Path = personScallop(cx: 0, cy: 29, rx: 47, ry: 47, from: 235, to: 305, count: 9, r: 4.8)
        Art.fill(&g, furBand, personTone(p.headwearColor, 1.16))
        let flecks: Color = personTone(p.headwearColor, 0.6)
        Art.clipped(&g, to: dome) { c in
            Art.stipple(&c, in: CGRect(x: -28, y: -40, width: 56, height: 22), count: 36, seed: 31, color: flecks, alpha: 0.35, size: 0.4...0.9)
        }
    }

    /// A soft round cap with a band and a button.
    static func personCap(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let cap: Path = Art.svg("M-27.5,-10 C-31,-30 -15,-39 0,-39 C15,-39 31,-30 27.5,-10 C18,-18.5 -18,-18.5 -27.5,-10Z")
        personLit(&g, cap, Art.color(p.headwearColor), bounds: CGRect(x: -30, y: -39, width: 60, height: 29), mirrored: mirrored)
        let band: Path = Art.svg("M-27,-12 C-18,-20.5 18,-20.5 27,-12")
        Art.stroke(&g, band, personTone(p.headwearColor, 0.74), width: 2.6)
        Art.fill(&g, Art.ellipse(0, -39.4, 3.2, 2), personTone(p.headwearColor, 0.74))
        Art.stroke(&g, Art.svg("M0,-38 C-8,-33 -13,-27 -15,-20 M0,-38 C8,-33 13,-27 15,-20"), personTone(p.headwearColor, 0.8).opacity(0.6), width: 0.9)
    }

    /// The thick fur ruff of a parka hood, framing the face, in the person's trim colour.
    static func personHoodRuff(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let ring: Path = personScallop(cx: 0, cy: 1, rx: 30.5, ry: 33, from: 0, to: 342, count: 20, r: 5.6)
        Art.fill(&g, ring, personTone(p.trim, 0.84))
        let tufts: Path = personScallop(cx: 0, cy: 1, rx: 31.5, ry: 34, from: 9, to: 351, count: 20, r: 4.2)
        Art.fill(&g, tufts, Art.color(p.trim))
        // The lit side of the ruff: the tufts on the upper left again, lighter.
        let start: CGFloat = mirrored ? 280 : 190
        let lit: Path = personScallop(cx: 0, cy: 1, rx: 32, ry: 34.5, from: start, to: start + 70, count: 5, r: 3.4)
        Art.fill(&g, lit, personTone(p.trim, 1.14))
    }

    /// A tall, rounded West African headwrap with one broad fold.
    static func personHeadwrap(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let wrap: Path = Art.svg("M-28,-7 C-36,-26 -27,-44 -3,-46 C21,-48 37,-31 28,-7 C18,-17.5 -18,-17.5 -28,-7Z")
        personLit(&g, wrap, Art.color(p.headwearColor), bounds: CGRect(x: -34, y: -47, width: 68, height: 40), mirrored: mirrored)
        let fold: Path = Art.svg("M-28,-7 C-14,-27 10,-38 31,-30 C32.5,-22 31,-14 28,-7 C18,-17.5 -18,-17.5 -28,-7Z")
        Art.fill(&g, fold, personTone(p.headwearColor, 0.84))
        let creases: Path = Art.svg("M-27,-9 C-13,-28 10,-38.5 31,-30 M-26,-30 C-14,-40 6,-43 22,-39 M-14,-16 C-2,-25 14,-28 29,-22")
        Art.stroke(&g, creases, personTone(p.headwearColor, 0.66), width: 1.1)
        Art.fill(&g, Art.svg("M18,-44 C24,-50 31,-47 30,-40 C27,-38 22,-39 18,-44Z"), personTone(p.headwearColor, 0.92))
    }

    /// A kerchief over the hair and the ears, tied under the chin.
    static func personKerchief(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let scarf: Path = Art.svg("M0,-39 C17,-39 34,-27 29.5,-2 C28.5,14 19,26 4,31 L-4,31 C-19,26 -28.5,14 -29.5,-2 C-34,-27 -17,-39 0,-39Z M0,-20 C-13,-20 -23,-12 -24,2 C-24.5,13 -17,22 -5,26.5 L5,26.5 C17,22 24.5,13 24,2 C23,-12 13,-20 0,-20Z")
        // Even-odd: the second outline is the opening for the face.
        g.fill(scarf, with: .color(Art.color(p.headwearColor)), style: FillStyle(eoFill: true))
        let folds: Path = Art.svg("M-26,-18 C-28,-8 -27,4 -23,14 M26,-18 C28,-8 27,4 23,14 M-12,-36 C-18,-32 -22,-27 -24,-21")
        Art.stroke(&g, folds, personTone(p.headwearColor, 0.72), width: 1.1)
        let shine: Path = Art.svg("M-24,-26 C-18,-33 -10,-36.5 -1,-37")
        Art.stroke(&g, personSide(shine, mirrored: mirrored), ArtStyle.warmLight.opacity(0.4), width: 1.6)
        let knot: Path = Art.svg("M-1,29 C-6,31 -11,36 -12,42 C-8,41 -3,38 0,33 C3,38 8,41 12,42 C11,36 6,31 1,29Z")
        Art.fill(&g, knot, personTone(p.headwearColor, 0.86))
        Art.fill(&g, Art.ellipse(0, 30.5, 3.6, 3), Art.color(p.headwearColor))
    }

    /// A thin band across the brow with one small stone.
    static func personCirclet(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        let band: Path = Art.svg("M-25.6,-13 C-13,-18 13,-18 25.6,-13")
        Art.stroke(&g, band, personTone(p.headwearColor, 0.78), width: 3.4)
        Art.stroke(&g, band, Art.color(p.headwearColor), width: 2)
        let stone: Path = Art.svg("M0,-20.4 L3,-16.8 L0,-13.2 L-3,-16.8Z")
        Art.fill(&g, stone, Art.color(p.trim))
        let dx: CGFloat = mirrored ? 0.8 : -0.8
        Art.fill(&g, Art.circle(dx, -17.6, 0.9), Color.white.opacity(0.8))
    }

    /// A wide-brimmed traveller's hat with a low crown (a petasos, a farmer's hat).
    static func personWideBrim(_ g: inout GraphicsContext, _ p: Person, mirrored: Bool) {
        personBrimShade(&g, y: -15)
        let color: Color = Art.color(p.headwearColor)
        let crown: Path = Art.svg("M-19,-21 C-21.5,-34 -12,-40 0,-40 C12,-40 21.5,-34 19,-21Z")
        personLit(&g, crown, color, bounds: CGRect(x: -21, y: -40, width: 42, height: 19), mirrored: mirrored)
        let brim: Path = Art.svg("M-40,-18.5 C-30,-27 30,-27 40,-18.5 C41,-16.5 39.5,-15 37,-15.5 C22,-19 -22,-19 -37,-15.5 C-39.5,-15 -41,-16.5 -40,-18.5Z")
        personLit(&g, brim, color, bounds: CGRect(x: -41, y: -26, width: 82, height: 12), mirrored: mirrored, light: 0.3, shade: 0.28)
        Art.stroke(&g, Art.svg("M-19.4,-23.5 C-10,-26.5 10,-26.5 19.4,-23.5"), Art.color(p.trim), width: 2.4, cap: .butt)
        let edge: Path = Art.svg("M-39,-19 C-30,-25 -14,-25.6 0,-25.6")
        Art.stroke(&g, personSide(edge, mirrored: mirrored), ArtStyle.warmLight.opacity(0.5), width: 1.1)
    }
}
