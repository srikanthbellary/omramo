import SwiftUI
import OmramoCore

// The palette, the four lights, the people and the story's own parts for "The Ballad of Mulan":
// Northern China about 500 CE, a loess farming village near the Yellow River, and the earth
// walls of the northern frontier. Everything here is drawn by several pictures.

extension MulanArt {
    // MARK: - Palette

    static let ramp = ArtStyle.Ramp(deep: 0x1A1F2E, shade: 0x4A4E52, mid: 0x7E9A5C, light: 0xF4EEDC, glow: 0xE8C878, accent: 0xC8352B)

    /// Rammed earth of courtyard and frontier walls.
    static let wallTone: UInt32 = 0xD2B07A
    /// The house's mud-plastered wall, a touch paler.
    static let houseTone: UInt32 = 0xDCBF8A
    /// Grey roof tiles.
    static let tileTone: UInt32 = 0x7C8086
    /// Iron of the lamellar armour, its dark and its rust.
    static let ironHex: UInt32 = 0x50555C
    static let ironDarkHex: UInt32 = 0x2E3238
    static let rustHex: UInt32 = 0x8A4A2A
    static let laceHex: UInt32 = 0x7A4426
    /// Vermilion for banners and the sister's skirt.
    static let vermilion: UInt32 = 0xC8352B

    static func willowGreens() -> Kit.Greens { Kit.greens(0x3E5A2E, 0x5E7A3A, 0x7E9A5C, 0xA9BE78, 0xDCE5A8) }
    static func milletGreens() -> Kit.Greens { Kit.greens(0x405E2C, 0x5C7E36, 0x7E9A5C, 0xA6BE6A, 0xD6E29A) }

    // MARK: - Lights (one per time of day; every sky stays pale behind the dark words)

    /// Spring morning in the village.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD4E2E8), 0), (Art.color(0xE8EEE8), 0.45), (Art.color(0xF5EED8), 0.8), (Art.color(0xF0DCA2), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF6DC, glow: 0xE8C878, haze: 0xF2EBD8, far: 0xD6CCAE, mid: 0xB8B08A, near: 0x9A9A6A)
    }

    /// Pale gold evening at the Yellow River.
    static func evening() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xEFE4CC), 0), (Art.color(0xF6E8C6), 0.5), (Art.color(0xF6DCA6), 0.85), (Art.color(0xEEC87A), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF0C8, glow: 0xE8C878, haze: 0xF4E4BE, far: 0xDCC496, mid: 0xC8A66C, near: 0xA8844E)
    }

    /// White-blue winter dawn on the frontier.
    static func dawn() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD8E4EC), 0), (Art.color(0xE8EFF2), 0.5), (Art.color(0xF3EEE8), 0.85), (Art.color(0xF0D8B8), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF4E4, glow: 0xEFCFA0, haze: 0xE9EEF0, far: 0xC6D0D8, mid: 0xA4AEB6, near: 0x7E868C)
    }

    /// Soft late-spring afternoon at home.
    static func afternoon() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xDAE6E4), 0), (Art.color(0xEEF0E2), 0.5), (Art.color(0xF6EED4), 0.85), (Art.color(0xEDD69C), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF4D8, glow: 0xE8C878, haze: 0xF2EDDA, far: 0xCFCDA8, mid: 0xA8B080, near: 0x8A9A62)
    }

    // MARK: - People (plain eyes: Advanced tier)

    static let skinHex: UInt32 = 0xDCA478
    static let hairHex: UInt32 = 0x2A1E1A

    /// Mulan at home in Part I: hair up in loops, ochre jacket and dress with rust trim.
    static func mulanHomeLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: skinHex, hair: hairHex, hairStyle: .bun, garment: .dress,
                   cloth: 0xC98E3E, trim: 0xA8442C, legs: 0xA8442C, showsEyeWhite: false)
    }

    /// Mulan the soldier: a narrow-sleeved belted tunic, trousers, boots, one plain topknot.
    static func mulanSoldierLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xC99468, hair: hairHex, hairStyle: .topknot, garment: .tunic,
                   cloth: 0x6A4E3A, trim: 0x3A2A22, legs: 0x3E3430, showsEyeWhite: false)
    }

    /// Mulan at the end: a soft red jacket and long skirt, her hair long and loose.
    static func mulanFeastLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xC99468, hair: hairHex, hairStyle: .long, garment: .dress,
                   cloth: 0xC8503A, trim: 0xE8C878, legs: 0xA83A2C, showsEyeWhite: false)
    }

    /// Father: thin grey beard, cloth cap, a plain dark blue-grey belted tunic.
    static func fatherLook() -> Kit.Person {
        Kit.Person(age: .elder, skin: 0xD49E76, hair: 0xB4AEA4, hairStyle: .short, beard: .long,
                   headwear: .cap, headwearColor: 0x34424E, garment: .tunic,
                   cloth: 0x3D5A6E, trim: 0x26343E, legs: 0x2E3A44, showsEyeWhite: false)
    }

    static func motherLook() -> Kit.Person {
        Kit.Person(age: .elder, skin: 0xD8A27A, hair: 0x6A5E58, hairStyle: .bun, garment: .dress,
                   cloth: 0x6E7E8C, trim: 0x4A5866, legs: 0x4A5866, showsEyeWhite: false)
    }

    static func sisterLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: skinHex, hair: hairHex, hairStyle: .bun, garment: .dress,
                   cloth: vermilion, trim: 0xE8C878, legs: 0xA82A22, showsEyeWhite: false)
    }

    static func brotherLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xD09A70, hair: hairHex, hairStyle: .topknot, garment: .tunic,
                   cloth: 0x8A6A44, trim: 0x4A3A2E, legs: 0x4A3A2E, showsEyeWhite: false)
    }

    /// The comrade: big, cheerful, broad-faced, in the same iron as Mulan.
    static func comradeLook() -> Kit.Person {
        Kit.Person(age: .adult, skin: 0xD49A6C, hair: hairHex, hairStyle: .topknot, garment: .tunic,
                   cloth: 0x5E6A2A, trim: 0x3A421A, legs: 0x3E3A2E, showsEyeWhite: false)
    }

    /// The hens of the yard (the kit's rooster drawn in hen colours).
    static func henLook() -> Kit.Bird {
        Kit.Bird(kind: .rooster, body: 0xC89A62, belly: 0xE6C690, wing: 0x8A5E36, beak: 0xE8B030, showsEyeWhite: false)
    }

    /// Mulan's bay: a sturdy, short-legged steppe horse with a thick neck and a full dark mane.
    static func bayLook(grey: Bool = false) -> Kit.Beast {
        var look = Kit.horseLook()
        look.body = 0x8E4C2A
        look.belly = grey ? 0xB8A898 : 0xB88A60
        look.dark = 0x2A1C16
        look.legLength = 1.0
        look.bodyLength = 1.9
        look.bulk = 1.05
        look.mane = true
        look.showsEyeWhite = false
        return look
    }

    // MARK: - Small things in hands and hair

    /// The bone pin and the little copper flower pin in Mulan's hair (head centre `head`).
    static func hairPins(_ context: inout GraphicsContext, head: CGPoint) {
        let x: CGFloat = head.x
        let y: CGFloat = head.y
        Art.stroke(&context, Art.line(x - 2, y - 40, x + 22, y - 33), Art.color(0xF2E8D0), width: 2)
        Art.fill(&context, Art.circle(x + 15, y - 41, 3), Art.color(0xC87A3A))
        Art.fill(&context, Art.circle(x + 14, y - 42, 1.2), Art.color(0xF4C27A))
    }

    /// A boat-shaped shuttle, about 22 long at scale 1, centred on (x, y).
    static func shuttle(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: y, scale: scale) { g in
            let body: Path = Art.svg("M-12,0 C-7,-3.6 7,-3.6 12,0 C7,3.4 -7,3.4 -12,0 Z")
            Kit.solid(&g, body, Art.color(0xA87A4A), light: 0.34, shade: 0.24)
            Art.fill(&g, Art.ellipse(0, -0.4, 5, 1.4), Art.color(0xF4EEDC))
        }
    }

    /// A half-mended rope halter hanging from the hands at (x, y).
    static func halter(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat) {
        Art.group(&context, x: x, y: y, scale: scale) { g in
            let rope: Path = Art.svg("M0,0 C-8,10 -10,26 -2,32 C6,36 14,28 12,18 C10,10 4,6 0,0 M-2,32 C-6,40 -4,48 -8,54")
            Art.stroke(&g, rope, Art.color(0x8A6A44), width: 3.2)
            Art.stroke(&g, rope, Art.color(0xC8A878, 0.6), width: 1.2)
        }
    }

    /// A low wooden stool `height` high standing at (x, baseY).
    static func stool(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, width: CGFloat) {
        let half: CGFloat = width / 2
        let top: CGFloat = baseY - height
        var legs = Path()
        legs.addRect(CGRect(x: x - half + 2, y: top, width: 3.5, height: height))
        legs.addRect(CGRect(x: x + half - 5.5, y: top, width: 3.5, height: height))
        Art.fill(&context, legs, Art.color(0x6E4E30))
        Kit.solid(&context, Art.rect(x - half, top - 4, width, 5, radius: 1.5), Art.color(0x8E6A44))
    }

    // MARK: - The loom

    /// A wooden slanting treadle loom seen from the side, the weaver's end on the RIGHT: the
    /// base rail, the tall back upright, the warp running down to the breast beam at the front
    /// post, the pale woven cloth at the near end and the heddle frame. Origin: the foot of the
    /// front post; about 120 long and 150 tall at scale 1. `cloth` 0…1 is how much is woven.
    static func loom(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, scale: CGFloat, cloth: CGFloat) {
        Art.group(&context, x: x, y: baseY, scale: scale) { g in
            let wood: Color = Art.color(0x9A6E42)
            let dark: Color = Art.color(0x6A4A2C)
            Kit.shadow(&g, -56, 0, width: 140, alpha: 0.24)
            // Far frame members in the darker tone, then the warp, then the near frame.
            Art.stroke(&g, Art.line(-112, -2, -112, -150), dark, width: 6)
            Art.stroke(&g, Art.line(-4, -2, -4, -72), dark, width: 5)
            let warpTop = CGPoint(x: -108, y: -142)
            let warpEnd = CGPoint(x: -2, y: -70)
            var warp = Path()
            for index in 0..<9 {
                let off: CGFloat = CGFloat(index) * 1.6 - 6.4
                warp.move(to: CGPoint(x: warpTop.x + off * 0.4, y: warpTop.y + off))
                warp.addLine(to: CGPoint(x: warpEnd.x + off * 0.3, y: warpEnd.y + off * 0.6))
            }
            Art.stroke(&g, warp, Art.color(0xF4EEDC, 0.75), width: 0.8)
            // The woven cloth: a pale band from the breast beam up the warp.
            let t: CGFloat = Kit.clamp(cloth, 0.1, 0.9)
            let clothTopX: CGFloat = Kit.mix(warpEnd.x, warpTop.x, t * 0.6)
            let clothTopY: CGFloat = Kit.mix(warpEnd.y, warpTop.y, t * 0.6)
            let band = Art.polygon([
                CGPoint(x: warpEnd.x, y: warpEnd.y - 6), CGPoint(x: clothTopX, y: clothTopY - 7),
                CGPoint(x: clothTopX, y: clothTopY + 6), CGPoint(x: warpEnd.x, y: warpEnd.y + 6),
            ])
            Kit.solid(&g, band, Art.color(0xF2E8D0), light: 0.3, shade: 0.16)
            Art.stroke(&g, Art.line(clothTopX, clothTopY - 7, clothTopX, clothTopY + 6), Art.color(0xC9B48A), width: 1.4)
            // Heddle frame hanging from a horse-head lever above the middle of the warp.
            Art.stroke(&g, Art.line(-96, -150, -40, -128), wood, width: 4.4)
            Art.stroke(&g, Art.rect(-70, -128, 14, 30, radius: 2), wood, width: 2.4)
            // Near frame: base rail, back upright, front post, breast beam, treadle.
            var near = Path()
            near.addPath(Art.rect(-122, -9, 128, 8, radius: 3))
            near.addPath(Art.rect(-118, -154, 9, 148, radius: 3))
            near.addPath(Art.rect(-8, -74, 8, 68, radius: 2.5))
            near.addPath(Art.rect(-14, -77, 18, 8, radius: 3))
            Kit.solid(&g, near, wood, light: 0.32, shade: 0.24)
            Art.stroke(&g, Art.line(-60, -6, -18, -20), dark, width: 3.4)
            Art.fill(&g, Art.circle(-113, -150, 5.4), dark)
        }
    }

    // MARK: - Courtyard and village

    /// The faint horizontal layers of pounded earth over `rect`.
    static func earthCourses(_ context: inout GraphicsContext, _ rect: CGRect, seed: UInt32) {
        guard rect.width > 0, rect.height > 0 else { return }
        var random = ArtRandom(seed)
        var lines = Path()
        var y: CGFloat = rect.minY + 6
        while y < rect.maxY {
            let wobble: CGFloat = (Kit.rnd(&random) - 0.5) * 2
            lines.move(to: CGPoint(x: rect.minX, y: y))
            lines.addQuadCurve(to: CGPoint(x: rect.maxX, y: y + wobble), control: CGPoint(x: rect.midX, y: y + wobble * 2))
            y += 9 + Kit.rnd(&random) * 4
        }
        Art.stroke(&context, lines, Art.color(0x8A6A42, 0.22), width: 1)
    }

    /// Soft loess hills on the horizon: a far terraced ridge and a nearer, lower one, in the
    /// light's far and middle tones (call `ArtStyle.atmosphere` after).
    static func loessHills(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light, seed: UInt32) {
        let far: Path = Kit.ridge(width: w, y: H - 44 * s, amp: 24 * s, seed: seed, bottom: H + 4, step: 14)
        Art.fill(&context, far, light.far)
        Art.clipped(&context, to: far) { g in
            var terraces = Path()
            var y: CGFloat = H - 60 * s
            var index: CGFloat = 0
            while y < H {
                let bend: CGFloat = (index.truncatingRemainder(dividingBy: 2) == 0 ? 3 : -3) * s
                terraces.move(to: CGPoint(x: 0, y: y))
                terraces.addCurve(to: CGPoint(x: w, y: y + 2), control1: CGPoint(x: w * 0.3, y: y + bend), control2: CGPoint(x: w * 0.7, y: y - bend))
                y += 7 * s
                index += 1
            }
            Art.stroke(&g, terraces, light.mid.opacity(0.3), width: 1.1)
            Art.fill(&g, Art.rect(0, H - 90 * s, w * 0.5, 90 * s), ArtStyle.warmLight.opacity(0.12))
        }
        let near: Path = Kit.ridge(width: w, y: H - 16 * s, amp: 12 * s, seed: seed &+ 7, bottom: H + 4, step: 12)
        Art.fill(&context, near, light.mid.opacity(0.5))
    }

    /// A long wall of pounded earth from x0 to x1 on baseY, `height` tall: smooth, its top
    /// worn and rounded (never crenellated), with faint layer lines and a lit coping.
    static func earthWall(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, baseY: CGFloat, height: CGFloat, color: UInt32, seed: UInt32) {
        let span: CGFloat = x1 - x0
        guard span > 0, height > 0 else { return }
        var random = ArtRandom(seed)
        let top: CGFloat = baseY - height
        var shape = Path()
        shape.move(to: CGPoint(x: x0, y: baseY))
        shape.addLine(to: CGPoint(x: x0, y: top + 2))
        var x: CGFloat = x0
        let step: CGFloat = max(16, height * 0.9)
        while x < x1 {
            let next: CGFloat = min(x1, x + step)
            let dip: CGFloat = Kit.rnd(&random) * height * 0.1
            let mid: CGFloat = (x + next) / 2
            shape.addQuadCurve(to: CGPoint(x: next, y: top + dip), control: CGPoint(x: mid, y: top - height * 0.04))
            x = next
        }
        shape.addLine(to: CGPoint(x: x1, y: baseY))
        shape.closeSubpath()
        ArtStyle.contactShadow(&context, x0 + span * 0.52, baseY, span * 0.52, max(2, height * 0.1), alpha: 0.2)
        Kit.solid(&context, shape, Art.color(color), light: 0.2, shade: 0.2)
        Art.clipped(&context, to: shape) { g in
            earthCourses(&g, CGRect(x: x0, y: top, width: span, height: height), seed: seed &+ 3)
            let foot: Kit.Stops = [(ArtStyle.coolShade.opacity(0), 0), (ArtStyle.coolShade.opacity(0.14), 1)]
            Art.fillLinear(&g, Art.rect(x0, baseY - height * 0.4, span, height * 0.4), foot, from: CGPoint(x: 0, y: baseY - height * 0.4), to: CGPoint(x: 0, y: baseY))
            Art.stroke(&g, shape, ArtStyle.warmLight.opacity(0.4), width: 3)
        }
    }

    /// The courtyard gate: two earth piers, the leaves swung open on the bright lane beyond,
    /// a timber lintel and a small roof of grey tiles. `width` × `height` up to the ridge.
    static func tileGate(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) {
        let half: CGFloat = width / 2
        let eave: CGFloat = baseY - height + 16
        let pier: CGFloat = width * 0.2
        Kit.shadow(&context, cx, baseY, width: width * 1.1)
        Art.fill(&context, Art.rect(cx - half + pier, eave + 6, width - pier * 2, baseY - eave - 6), Art.color(0xEFDDB0))
        var leaves = Path()
        leaves.addRect(CGRect(x: cx - half + pier, y: eave + 8, width: 6, height: baseY - eave - 8))
        leaves.addRect(CGRect(x: cx + half - pier - 6, y: eave + 8, width: 6, height: baseY - eave - 8))
        Art.fill(&context, leaves, Art.color(0x6A4A2E))
        Kit.wall(&context, rect: CGRect(x: cx - half, y: eave + 2, width: pier, height: baseY - eave - 2), color: wallTone)
        Kit.wall(&context, rect: CGRect(x: cx + half - pier, y: eave + 2, width: pier, height: baseY - eave - 2), color: wallTone)
        Kit.solid(&context, Art.rect(cx - half - 4, eave, width + 8, 7, radius: 2), Art.color(0x7A5A3A))
        Kit.roof(&context, cx: cx, eaveY: eave, width: width * 1.36, height: 17, color: tileTone, style: .tile)
    }

    /// A weeping willow at (x, baseY), `height` tall: a leaning trunk, a soft crown and long
    /// hanging fronds.
    static func willow(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, height: CGFloat, seed: UInt32) {
        let h: CGFloat = height
        var random = ArtRandom(seed)
        Kit.shadow(&context, x + 8, baseY, width: h * 0.7, alpha: 0.18)
        let trunk: Path = Art.svg("M-7,0 C-5,-20 -6,-40 -2,-62 C2,-60 4,-58 6,-56 C4,-40 6,-20 8,0 Z")
        let k: CGFloat = h / 118
        Art.group(&context, x: x, y: baseY, scale: k) { g in
            Kit.solid(&g, trunk, Art.color(0x6E5A44), light: 0.3, shade: 0.3)
            Art.stroke(&g, Art.svg("M-2,-60 C-14,-70 -26,-76 -40,-78 M4,-58 C14,-70 28,-76 42,-80 M0,-60 C0,-74 2,-84 4,-92"), Art.color(0x6E5A44), width: 3.4)
        }
        let cy: CGFloat = baseY - h * 0.72
        let blobs: [Kit.Blob] = [
            (x - h * 0.26, cy + h * 0.04, h * 0.17), (x, cy - h * 0.06, h * 0.2),
            (x + h * 0.26, cy + h * 0.03, h * 0.17), (x - h * 0.08, cy + h * 0.1, h * 0.15),
        ]
        Kit.canopy(&context, blobs, seed: seed &+ 3, palette: willowGreens(), density: 1.4)
        var dark = Path()
        var lit = Path()
        for index in 0..<26 {
            let t: CGFloat = CGFloat(index) / 25
            let jitter: CGFloat = (Kit.rnd(&random) - 0.5) * 6
            let along: CGFloat = h * 0.84 * t
            let fx: CGFloat = x - h * 0.42 + along + jitter
            let arch: CGFloat = 1 - (2 * t - 1) * (2 * t - 1)
            let fy: CGFloat = cy - h * 0.05 * arch + h * 0.08
            let length: CGFloat = h * (0.28 + Kit.rnd(&random) * 0.26) * (0.7 + 0.3 * arch)
            let sway: CGFloat = (Kit.rnd(&random) - 0.3) * 8
            var frond = Path()
            frond.move(to: CGPoint(x: fx, y: fy))
            frond.addQuadCurve(to: CGPoint(x: fx + sway, y: fy + length), control: CGPoint(x: fx - 3, y: fy + length * 0.5))
            if t < 0.45 {
                lit.addPath(frond)
            } else {
                dark.addPath(frond)
            }
        }
        Art.stroke(&context, dark, Art.color(0x5E7A3A, 0.85), width: 1.6)
        Art.stroke(&context, lit, Art.color(0xA9BE78, 0.9), width: 1.6)
    }

    /// A small square window of wooden lattice over paper.
    static func latticeWindow(_ context: inout GraphicsContext, _ rect: CGRect) {
        Kit.solid(&context, Path(rect.insetBy(dx: -4, dy: -4)), Art.color(0x7A5A3A), light: 0.3, shade: 0.2)
        Art.fill(&context, Path(rect), Art.color(0xF0E2BE))
        var bars = Path()
        for index in 1..<4 {
            let f: CGFloat = CGFloat(index) / 4
            bars.addPath(Art.line(rect.minX + rect.width * f, rect.minY, rect.minX + rect.width * f, rect.maxY))
            bars.addPath(Art.line(rect.minX, rect.minY + rect.height * f, rect.maxX, rect.minY + rect.height * f))
        }
        Art.stroke(&context, bars, Art.color(0x7A5A3A), width: 1.8)
    }
}

// MARK: - Armour, soldiers, the bay horse and the rider

extension MulanArt {
    /// Rows of small iron plates over `shape` (in its own bounds `box`): plate seams, the
    /// leather laces between rows and a rusted edge.
    static func lamellar(_ context: inout GraphicsContext, _ shape: Path, box: CGRect, row: CGFloat, frost: Bool) {
        let iron: Kit.Stops = [(Art.color(0x6A7078), 0), (Art.color(ironHex), 0.55), (Art.color(ironDarkHex), 1)]
        Kit.solid(&context, shape, stops: iron, light: 0.3, shade: 0.26)
        Art.clipped(&context, to: shape) { g in
            var seams = Path()
            var ticks = Path()
            var laces = Path()
            var y: CGFloat = box.minY + row
            var parity: CGFloat = 0
            while y < box.maxY {
                seams.addPath(Art.line(box.minX, y, box.maxX, y))
                var x: CGFloat = box.minX + parity * 2.6
                while x < box.maxX {
                    ticks.addPath(Art.line(x, y - row + 1, x, y - 1))
                    laces.addPath(Art.circle(x + 2.6, y - 0.4, 0.8))
                    x += 5.2
                }
                parity = parity == 0 ? 1 : 0
                y += row
            }
            Art.stroke(&g, seams, Art.color(ironDarkHex, 0.75), width: 1.1)
            Art.stroke(&g, ticks, Art.color(ironDarkHex, 0.4), width: 0.8)
            Art.fill(&g, laces, Art.color(laceHex, 0.9))
            Art.stroke(&g, shape, Art.color(rustHex, 0.45), width: 2.6)
            if frost {
                Art.fill(&g, Path(box), Color.white.opacity(0.12))
                Kit.flecks(&g, in: box, count: 14, seed: 41, color: Color.white.opacity(0.8), radius: 0.4...1.0)
            }
        }
    }

    /// Mulan's (and the comrade's) armour over a standing or sitting kit figure, in adult person
    /// units: a lamellar cuirass from the shoulders to the belt, a leather belt, a skirt of plates
    /// and the near shoulder guard. `hip` is the rig's hip point.
    static func armour(_ context: inout GraphicsContext, hip: CGPoint, frost: Bool) {
        let x: CGFloat = hip.x
        let y: CGFloat = hip.y
        let chest = Art.rect(x - 17, y - 50, 34, 48, radius: 7)
        lamellar(&context, chest, box: CGRect(x: x - 17, y: y - 50, width: 34, height: 48), row: 6.4, frost: frost)
        let skirt = Art.svg("M\(x - 19),\(y - 2) L\(x + 18),\(y - 2) L\(x + 21),\(y + 18) L\(x - 23),\(y + 18) Z")
        lamellar(&context, skirt, box: CGRect(x: x - 23, y: y - 2, width: 44, height: 20), row: 6.6, frost: frost)
        Kit.solid(&context, Art.rect(x - 19, y - 6, 38, 6, radius: 2), Art.color(0x5A3622), light: 0.3, shade: 0.2)
        Art.fill(&context, Art.rect(x - 4, y - 6.5, 7, 7, radius: 1.5), Art.color(0xB8925A))
        let guardShape = Art.svg("M\(x - 30),\(y - 46) C\(x - 30),\(y - 54) \(x - 12),\(y - 56) \(x - 8),\(y - 47) L\(x - 10),\(y - 28) C\(x - 18),\(y - 26) \(x - 28),\(y - 28) \(x - 31),\(y - 32) Z")
        lamellar(&context, guardShape, box: CGRect(x: x - 31, y: y - 56, width: 23, height: 30), row: 6, frost: frost)
    }

    /// A rounded iron helmet with a brow band, a top knob and a neck guard of plates hanging at
    /// the back (the right, as the figure faces left), centred on the head centre `head`.
    static func helmet(_ context: inout GraphicsContext, head: CGPoint, frost: Bool) {
        Art.group(&context, x: head.x, y: head.y) { g in
            let neck = Art.svg("M10,-12 L31,-10 C33,0 33,10 31,18 L14,20 C12,8 11,-2 10,-12 Z")
            lamellar(&g, neck, box: CGRect(x: 10, y: -12, width: 23, height: 32), row: 6.2, frost: frost)
            let dome = Art.svg("M-30,-6 C-32,-30 -16,-42 0,-42 C16,-42 32,-30 30,-6 C20,-12 -20,-12 -30,-6 Z")
            let iron: Kit.Stops = [(Art.color(0x7A8088), 0), (Art.color(ironHex), 0.6), (Art.color(ironDarkHex), 1)]
            Kit.solid(&g, dome, stops: iron, light: 0.36, shade: 0.26, rim: 2)
            Art.stroke(&g, Art.svg("M0,-41 C-2,-30 -2,-18 0,-10 M-15,-37 C-19,-28 -21,-18 -21,-9 M15,-37 C19,-28 21,-18 21,-9"), Art.color(ironDarkHex, 0.55), width: 1.2)
            Art.stroke(&g, Art.svg("M-30,-7 C-20,-13 20,-13 30,-7"), Art.color(rustHex), width: 3.4)
            Kit.solid(&g, Art.rect(-3, -50, 6, 9, radius: 2), Art.color(ironHex))
            Art.fill(&g, Art.circle(0, -51, 3.4), Art.color(0x6A7078))
            if frost {
                Art.stroke(&g, Art.svg("M-26,-14 C-26,-28 -14,-38 -2,-39"), Color.white.opacity(0.7), width: 2.2)
                Kit.flecks(&g, in: CGRect(x: -26, y: -40, width: 30, height: 26), count: 8, seed: 43, color: Color.white.opacity(0.85), radius: 0.5...1.1)
            }
        }
    }

    /// A soldier — Mulan or the comrade — as a kit figure in armour and (when `helmeted`) the
    /// iron helmet; origin at the feet, facing LEFT. Poses that suit armour: stand, walk, sit.
    static func soldier(
        _ context: inout GraphicsContext,
        _ look: Kit.Person,
        pose: Kit.Pose,
        gaze: CGPoint = .zero,
        mouth: Kit.Mouth = .flat,
        helmeted: Bool = true,
        frost: Bool = false,
        mirrored: Bool = false
    ) {
        Kit.person(&context, look, pose: pose, look: gaze, mouth: mouth, mirrored: mirrored)
        let rig = Kit.bodyRig(look, pose)
        armour(&context, hip: rig.hip, frost: frost)
        if helmeted {
            let head: CGPoint = Kit.bodyHeadCentre(Kit.bodyFrame(look), rig)
            helmet(&context, head: head, frost: frost)
        }
    }

    /// White breath in the cold, in front of a face at (x, y) (facing left).
    static func breath(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, scale: CGFloat) {
        Art.glow(&context, x - 14 * scale, y, 16 * scale, Color.white, alpha: 0.75)
        Art.glow(&context, x - 30 * scale, y - 4 * scale, 20 * scale, Color.white, alpha: 0.5)
        Art.glow(&context, x - 48 * scale, y - 10 * scale, 22 * scale, Color.white, alpha: 0.28)
    }

    /// The bay with its white blaze, a bridle, and (when `saddled`) the saddle-cloth and the
    /// wooden-framed saddle with a stirrup. Origin on the ground under mid-body, facing LEFT.
    static func bayHorse(
        _ context: inout GraphicsContext,
        pose: Kit.BeastPose = .stand,
        mood: Kit.BeastMood = .calm,
        saddled: Bool = true,
        grey: Bool = false,
        mirrored: Bool = false
    ) {
        let spec = bayLook(grey: grey)
        Kit.beast(&context, spec, pose: pose, mood: mood, look: CGPoint(x: -0.4, y: 0), mirrored: mirrored)
        let head: CGPoint = Kit.beastHeadCentre(spec, pose: pose)
        let blaze = Art.svg("M\(head.x - 3),\(head.y - 22) C\(head.x - 1),\(head.y - 10) \(head.x - 10),\(head.y + 2) \(head.x - 24),\(head.y + 8) C\(head.x - 16),\(head.y - 2) \(head.x - 8),\(head.y - 12) \(head.x - 6),\(head.y - 22) Z")
        Art.fill(&context, blaze, Color.white.opacity(0.85))
        let strap = Art.svg("M\(head.x + 2),\(head.y - 20) C\(head.x - 2),\(head.y - 4) \(head.x - 8),\(head.y + 8) \(head.x - 12),\(head.y + 16) M\(head.x - 30),\(head.y + 6) C\(head.x - 24),\(head.y + 12) \(head.x - 16),\(head.y + 16) \(head.x - 10),\(head.y + 14)")
        Art.stroke(&context, strap, Art.color(0x3A2418), width: 2.4)
        if saddled {
            let back: CGPoint = Kit.beastBack(spec, pose: pose)
            saddle(&context, at: back)
        }
    }

    /// The saddle-cloth, saddle and stirrup sitting on a horse's back point `b`.
    static func saddle(_ context: inout GraphicsContext, at b: CGPoint) {
        let cloth = Art.svg("M\(b.x - 26),\(b.y + 2) C\(b.x - 10),\(b.y - 2) \(b.x + 12),\(b.y - 2) \(b.x + 26),\(b.y + 2) L\(b.x + 24),\(b.y + 34) C\(b.x + 8),\(b.y + 38) \(b.x - 10),\(b.y + 38) \(b.x - 24),\(b.y + 34) Z")
        Kit.solid(&context, cloth, Art.color(0x8A3426), light: 0.24, shade: 0.24)
        Art.stroke(&context, Art.svg("M\(b.x - 23),\(b.y + 30) C\(b.x - 8),\(b.y + 34) \(b.x + 8),\(b.y + 34) \(b.x + 22),\(b.y + 30)"), Art.color(0xE8C878, 0.8), width: 2)
        let seat = Art.svg("M\(b.x - 20),\(b.y + 4) C\(b.x - 22),\(b.y - 10) \(b.x - 16),\(b.y - 14) \(b.x - 13),\(b.y - 5) L\(b.x + 12),\(b.y - 5) C\(b.x + 15),\(b.y - 13) \(b.x + 21),\(b.y - 10) \(b.x + 20),\(b.y + 4) Z")
        Kit.solid(&context, seat, Art.color(0x7A4E2C), light: 0.34, shade: 0.24)
        Art.stroke(&context, Art.line(b.x - 2, b.y + 2, b.x - 2, b.y + 44), Art.color(0x3A2418), width: 2)
        Art.stroke(&context, Art.rect(b.x - 7, b.y + 44, 10, 6, radius: 3), Art.color(0x4A4E52), width: 2)
    }

    /// A rider on the bay, both facing LEFT, origin on the ground under the horse: the horse
    /// (saddled), the rider's upper body from a kit figure cut at the hips and seated on the
    /// saddle, the near leg along the flank, the reins to the bit, armour and helmet. About 230
    /// tall and 200 long at scale 1.
    static func rider(
        _ context: inout GraphicsContext,
        _ look: Kit.Person,
        pose: Kit.BeastPose = .stand,
        armoured: Bool = true,
        frost: Bool = false,
        grey: Bool = false,
        mirrored: Bool = false
    ) {
        let spec = bayLook(grey: grey)
        bayHorse(&context, pose: pose, saddled: true, grey: grey, mirrored: mirrored)
        let back: CGPoint = Kit.beastBack(spec, pose: pose)
        let seatX: CGFloat = back.x + 2
        let seatY: CGFloat = back.y + 54
        let hand: CGPoint = Kit.hand(look, pose: .carry)
        Art.group(&context, x: seatX, y: seatY) { g in
            Art.clipped(&g, to: Art.rect(-80, -260, 160, 204)) { c in
                Kit.person(&c, look, pose: .carry, look: CGPoint(x: -0.6, y: 0), mouth: .flat, mirrored: mirrored)
            }
            let flap = Art.svg("M-19,-62 L17,-62 L12,-32 C0,-28 -18,-30 -30,-34 Z")
            Kit.solid(&g, flap, Art.color(look.cloth), light: 0.24, shade: 0.24)
            let leg = Art.svg("M-6,-58 C-18,-52 -26,-44 -26,-36 C-24,-24 -20,-14 -18,-6")
            Art.stroke(&g, leg, Art.color(look.legs), width: 14)
            Kit.solid(&g, Art.svg("M-26,-10 L-12,-10 L-10,0 C-16,2 -28,2 -32,-2 Z"), Art.color(0x2A2220), light: 0.3, shade: 0.2)
            if armoured {
                armour(&g, hip: CGPoint(x: 0, y: -58), frost: frost)
                helmet(&g, head: CGPoint(x: 0, y: -140), frost: frost)
            }
            Kit.solid(&g, Art.circle(hand.x, hand.y, 5), Art.color(look.skin))
        }
        let mouth: CGPoint = Kit.beastMouth(spec, pose: pose)
        var rein = Path()
        rein.move(to: CGPoint(x: seatX + hand.x, y: seatY + hand.y))
        rein.addQuadCurve(to: mouth, control: CGPoint(x: (seatX + hand.x + mouth.x) / 2, y: max(seatY + hand.y, mouth.y) + 16))
        Art.stroke(&context, rein, Art.color(0x3A2418), width: 1.8)
    }

    // MARK: - The frontier

    /// A square watch-tower of pounded earth with a timber lookout, a small roof and a red
    /// pennant, standing at (cx, baseY); about 44 wide and 124 tall at scale 1.
    static func watchTower(_ context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, scale: CGFloat, seed: UInt32 = 1) {
        Art.group(&context, x: cx, y: baseY, scale: scale) { g in
            Kit.shadow(&g, 0, 0, width: 56)
            let base = Art.polygon([CGPoint(x: -22, y: 0), CGPoint(x: -17, y: -54), CGPoint(x: 17, y: -54), CGPoint(x: 22, y: 0)])
            Kit.solid(&g, base, Art.color(wallTone), light: 0.22, shade: 0.28, rim: 2)
            Art.clipped(&g, to: base) { c in
                earthCourses(&c, CGRect(x: -22, y: -54, width: 44, height: 54), seed: seed)
            }
            var posts = Path()
            let xs: [CGFloat] = [-17, -6, 6, 16]
            for px in xs {
                posts.addRect(CGRect(x: px - 1.6, y: -82, width: 3.2, height: 28))
            }
            posts.addRect(CGRect(x: -19, y: -66, width: 38, height: 3))
            posts.addRect(CGRect(x: -20, y: -56, width: 40, height: 4))
            Kit.solid(&g, posts, Art.color(0x7A5A3A), light: 0.3, shade: 0.24)
            Art.fill(&g, Art.rect(-15, -80, 30, 13), Art.color(0x4A3A30, 0.5))
            Kit.roof(&g, cx: 0, eaveY: -80, width: 50, height: 12, color: tileTone, style: .tile)
            Art.stroke(&g, Art.line(10, -88, 10, -124), Art.color(0x5A4030), width: 2)
            pennant(&g, x: 10, y: -123, length: 34, seed: seed)
        }
    }

    /// A long red pennant flying to the right from the pole top at (x, y).
    static func pennant(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, length: CGFloat, seed: UInt32) {
        var random = ArtRandom(seed)
        let wave: CGFloat = (Kit.rnd(&random) - 0.5) * 6
        let l: CGFloat = length
        var flag = Path()
        flag.move(to: CGPoint(x: x, y: y))
        flag.addCurve(to: CGPoint(x: x + l, y: y + 5 + wave), control1: CGPoint(x: x + l * 0.35, y: y - 4), control2: CGPoint(x: x + l * 0.65, y: y + 8 + wave))
        flag.addCurve(to: CGPoint(x: x, y: y + 11), control1: CGPoint(x: x + l * 0.6, y: y + 12 + wave), control2: CGPoint(x: x + l * 0.3, y: y + 6))
        flag.closeSubpath()
        Kit.solid(&context, flag, Art.color(vermilion), light: 0.3, shade: 0.24)
    }

    // MARK: - River, home window

    /// The far bank of the Yellow River: flat-topped cliffs of yellow loess cut by gullies,
    /// with the vertical cracks loess weathers into, across the whole horizon.
    static func loessCliffs(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light) {
        var random = ArtRandom(91)
        var shape = Path()
        shape.move(to: CGPoint(x: -10, y: H + 4))
        var x: CGFloat = -10
        var y: CGFloat = H - 40 * s
        shape.addLine(to: CGPoint(x: x, y: y))
        while x < w + 10 {
            let run: CGFloat = (50 + Kit.rnd(&random) * 70) * s
            let next: CGFloat = x + run
            shape.addLine(to: CGPoint(x: next - 10 * s, y: y))
            let gully: Bool = Kit.rnd(&random) < 0.4
            let dropY: CGFloat = gully ? H - 18 * s : y
            shape.addQuadCurve(to: CGPoint(x: next, y: dropY), control: CGPoint(x: next - 4 * s, y: y + 2 * s))
            y = H - (30 + Kit.rnd(&random) * 26) * s
            shape.addQuadCurve(to: CGPoint(x: next + 8 * s, y: y), control: CGPoint(x: next + 6 * s, y: dropY))
            x = next + 8 * s
        }
        shape.addLine(to: CGPoint(x: w + 10, y: H + 4))
        shape.closeSubpath()
        let tone: Kit.Stops = [(light.far, 0), (light.mid.opacity(0.9), 1)]
        Art.fillLinear(&context, shape, tone, from: CGPoint(x: 0, y: H - 60 * s), to: CGPoint(x: 0, y: H))
        Art.clipped(&context, to: shape) { g in
            var cracks = Path()
            for index in 0..<60 {
                let cx: CGFloat = w * CGFloat(index) / 60 + Kit.rnd(&random) * 8
                let length: CGFloat = (10 + Kit.rnd(&random) * 26) * s
                cracks.addPath(Art.line(cx, H - 50 * s, cx + 1, H - 50 * s + length))
            }
            Art.stroke(&g, cracks, light.near.opacity(0.22), width: 1)
            Art.stroke(&g, shape, ArtStyle.warmLight.opacity(0.5), width: 2.4)
        }
    }

    /// The open window of the home house with Mulan inside in her soft red jacket, combing
    /// out her long loose hair, the small yellow flower on her forehead; lattice shutters open.
    static func windowWithMulan(_ context: inout GraphicsContext, _ rect: CGRect) {
        let k: CGFloat = rect.width / 96
        let shutterY: CGFloat = rect.minY + 4 * k
        let shutterH: CGFloat = rect.height - 8 * k
        latticeWindow(&context, CGRect(x: rect.minX - 32 * k, y: shutterY, width: 26 * k, height: shutterH))
        latticeWindow(&context, CGRect(x: rect.maxX + 6 * k, y: shutterY, width: 26 * k, height: shutterH))
        Kit.solid(&context, Path(rect.insetBy(dx: -6 * k, dy: -6 * k)), Art.color(0x7A5A3A), light: 0.3, shade: 0.2)
        let room: Kit.Stops = [(Art.color(0x6A4A34), 0), (Art.color(0x4E3626), 1)]
        Art.fillLinear(&context, Path(rect), room, from: CGPoint(x: rect.minX, y: rect.minY), to: CGPoint(x: rect.maxX, y: rect.maxY))
        let bustX: CGFloat = rect.midX - 4 * k
        let bustY: CGFloat = rect.minY + 34 * k
        Art.clipped(&context, to: Path(rect)) { c in
            Art.glow(&c, rect.minX + 20 * k, rect.minY + 20 * k, rect.width, Art.color(0xFFE6B0), alpha: 0.35)
            Art.group(&c, x: bustX, y: bustY, scale: 0.46 * k) { b in
                Kit.bust(&b, mulanFeastLook(), look: CGPoint(x: -0.3, y: 0.2), mouth: .smile, wave: true)
                foreheadFlower(&b, x: 0, y: -17)
                comb(&b, x: 70, y: -6)
            }
        }
        Kit.solid(&context, Art.rect(rect.minX - 10 * k, rect.maxY, rect.width + 20 * k, 7 * k, radius: 2), Art.color(0x8E6A44))
    }

    /// The small yellow flower-shape (huahuang) pressed to the forehead, in head units.
    static func foreheadFlower(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        var petals = Path()
        petals.addPath(Art.circle(x - 2.4, y, 1.8))
        petals.addPath(Art.circle(x + 2.4, y, 1.8))
        petals.addPath(Art.circle(x, y - 2.4, 1.8))
        petals.addPath(Art.circle(x, y + 2.4, 1.8))
        Art.fill(&context, petals, Art.color(0xF2C230))
        Art.fill(&context, Art.circle(x, y, 1.2), Art.color(0xE88A1A))
    }

    /// A small wooden comb held at (x, y), teeth down.
    static func comb(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat) {
        let back = Art.svg("M\(x - 10),\(y) C\(x - 10),\(y - 9) \(x + 10),\(y - 9) \(x + 10),\(y) Z")
        Kit.solid(&context, back, Art.color(0xB8864A), light: 0.34, shade: 0.2)
        var teeth = Path()
        for index in 0..<7 {
            let tx: CGFloat = x - 8 + CGFloat(index) * 2.7
            teeth.addPath(Art.line(tx, y, tx, y + 7))
        }
        Art.stroke(&context, teeth, Art.color(0x8A6034), width: 1.2)
    }

    /// One running hare, facing LEFT, origin on the ground under it (about 80 long at scale 1).
    static func hare(_ context: inout GraphicsContext, mirrored: Bool = false) {
        var look = Kit.hareLook()
        look.body = 0xA88A66
        look.showsEyeWhite = false
        Kit.beast(&context, look, pose: .run, mood: .calm, look: CGPoint(x: -0.6, y: 0), mirrored: mirrored)
    }
}
