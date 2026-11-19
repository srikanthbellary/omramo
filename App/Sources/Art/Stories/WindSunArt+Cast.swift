import SwiftUI
import OmramoCore

// The cast of "The North Wind and the Sun": the palette and the lights, the two sky heroes
// (drawn here, the kit has neither), the traveller and his cloak, and the small parts of the
// Greek coast that several pictures share.

// MARK: - Palette and light

extension WindSunArt {
    /// Clear Aegean light: sea blue, olive silver-green, pale stone, one warm red-brown note.
    static let ramp = ArtStyle.Ramp(deep: 0x0B4F7A, shade: 0x5E7F5A, mid: 0x2A9DB8, light: 0xD3EEF0, glow: 0xFFE3A6, accent: 0xB5482E)

    static let cloakHex: UInt32 = 0xB5482E
    static let cloakDarkHex: UInt32 = 0x8A3220
    static let cloakLightHex: UInt32 = 0xD26A4A
    static let bronzeHex: UInt32 = 0xD9A441
    static let strawHex: UInt32 = 0xE6CC8A
    static let stoneHex: UInt32 = 0xD8CFB8
    static let roadHex: UInt32 = 0xF0E6C8
    static let cloudHex: UInt32 = 0xBCD2E2
    static let cloudDeepHex: UInt32 = 0x8FAEC9

    /// Late morning: a clear pale-blue sky going to warm cream at the horizon.
    static func day() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xBFE4F2), 0), (Art.color(0xD8F0F2), 0.55), (Art.color(0xFFF1C9), 1)]
        return Kit.Light(sky: sky, sun: 0xFFD45A, glow: 0xFFE3A6, haze: 0xE4F2EA, far: 0xA9CCDA, mid: 0x93B8B4, near: 0x6E9A86)
    }

    /// The gale: a pale silvery grey-blue sky, never dark.
    static func gale() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xD3DFE7), 0), (Art.color(0xE3EAEC), 0.6), (Art.color(0xF4EFDD), 1)]
        return Kit.Light(sky: sky, sun: 0xFFF1C9, glow: 0xFFEFC6, haze: 0xE6ECEA, far: 0xB4C6CF, mid: 0x9DB4B4, near: 0x7C9A94)
    }

    /// The Sun's turn: warm gold light.
    static func gold() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xC4E8F0), 0), (Art.color(0xE6F3DC), 0.5), (Art.color(0xFFE9A8), 1)]
        return Kit.Light(sky: sky, sun: 0xFFD45A, glow: 0xFFE3A6, haze: 0xF2F0D2, far: 0xA6CCD6, mid: 0x9ABFA8, near: 0x74A07E)
    }

    /// Late afternoon at the harbour: pale and still.
    static func afternoon() -> Kit.Light {
        let sky: Kit.Stops = [(Art.color(0xCDEAEE), 0), (Art.color(0xEFF0D8), 0.55), (Art.color(0xFFE0A2), 1)]
        return Kit.Light(sky: sky, sun: 0xFFD45A, glow: 0xFFE3A6, haze: 0xF4EED2, far: 0xA8CBD2, mid: 0x9CBBA4, near: 0x789E80)
    }

    static func calmSea() -> Kit.Stops {
        [(Art.color(0x58B9CF), 0), (Art.color(0x2A9DB8), 0.4), (Art.color(0x157CA6), 1)]
    }

    static func galeSea() -> Kit.Stops {
        [(Art.color(0x9BBDC6), 0), (Art.color(0x5E8F9E), 0.45), (Art.color(0x3D748A), 1)]
    }

    static func lateSea() -> Kit.Stops {
        [(Art.color(0x66C3CC), 0), (Art.color(0x1F8FA8), 0.45), (Art.color(0x14789C), 1)]
    }

    /// Dry Greek hillside: pale straw grass over limestone.
    static func hillStops() -> Kit.Stops {
        [(Art.color(0xDCD6A2), 0), (Art.color(0xC3C088), 0.5), (Art.color(0x9FA872), 1)]
    }

    static func roadStops() -> Kit.Stops {
        [(Art.color(0xF6EED6), 0), (Art.color(0xEADDBA), 1)]
    }
}

// MARK: - Small shared tools

extension WindSunArt {
    /// A stroke that is thick where it starts and thin where it ends (a stream of wind, a wisp).
    static func taperStroke(_ context: inout GraphicsContext, _ data: String, width: CGFloat, color: Color) {
        let path: Path = Art.svg(data)
        Art.stroke(&context, path, color.opacity(0.5), width: width * 0.34)
        Art.stroke(&context, path.trimmedPath(from: 0, to: 0.72), color.opacity(0.7), width: width * 0.62)
        Art.stroke(&context, path.trimmedPath(from: 0, to: 0.4), color, width: width)
    }

    /// One friendly eye whose catchlight stays upper-left even when the caller has flipped x.
    static func heroEye(_ context: inout GraphicsContext, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, look: CGPoint, mirrored: Bool) {
        if mirrored {
            let flipped = CGPoint(x: -look.x, y: look.y)
            Art.group(&context, x: cx, y: cy, scaleX: -1) { e in
                ArtStyle.eye(&e, 0, 0, r, look: flipped, showsWhite: true)
            }
        } else {
            ArtStyle.eye(&context, cx, cy, r, look: look, showsWhite: true)
        }
    }

    /// A soft eyelid over the top `share` of an eye at (cx, cy) of radius r, with its lash line.
    static func heroLid(_ context: inout GraphicsContext, _ cx: CGFloat, _ cy: CGFloat, _ r: CGFloat, share: CGFloat, skin: Color, line: Color) {
        let lidBottom: CGFloat = cy - r + r * 2 * share
        Art.clipped(&context, to: Art.circle(cx, cy, r + 0.6)) { c in
            Art.fill(&c, Art.rect(cx - r - 2, cy - r - 2, r * 2 + 4, lidBottom - (cy - r - 2)), skin)
        }
        var lash = Path()
        lash.move(to: CGPoint(x: cx - r, y: lidBottom))
        lash.addQuadCurve(to: CGPoint(x: cx + r, y: lidBottom), control: CGPoint(x: cx, y: lidBottom + r * 0.22))
        Art.stroke(&context, lash, line, width: max(1.2, r * 0.2))
    }
}

// MARK: - The Sun

extension WindSunArt {
    enum SunMood { case smiling, glowing, speaking }

    /// The Sun: a warm golden disc of radius 50 centred on (0, 0), a soft halo, short rounded
    /// rays (out to radius 78) and a calm, kind face. A picture-book sky character, not a god.
    static func sunHero(_ context: inout GraphicsContext, mood: SunMood = .smiling, halo: Bool = true) {
        if halo {
            let reach: CGFloat = mood == .glowing ? 150 : 128
            Art.glow(&context, 0, 0, reach, Art.color(0xFFE9A0), alpha: mood == .glowing ? 0.95 : 0.75)
        }
        // Short rounded rays, long and short by turns; the upper-left ones catch more light.
        var longRays = Path()
        var shortRays = Path()
        for i in 0..<14 {
            let a: CGFloat = CGFloat(i) / 14 * 2 * CGFloat.pi + 0.12
            let dx: CGFloat = cos(a)
            let dy: CGFloat = sin(a)
            if i % 2 == 0 {
                longRays.move(to: CGPoint(x: dx * 61, y: dy * 61))
                longRays.addLine(to: CGPoint(x: dx * 73, y: dy * 73))
            } else {
                shortRays.move(to: CGPoint(x: dx * 60, y: dy * 60))
                shortRays.addLine(to: CGPoint(x: dx * 66, y: dy * 66))
            }
        }
        Art.stroke(&context, longRays, Art.color(0xFFC84A), width: 9.5)
        Art.stroke(&context, shortRays, Art.color(0xFFD86A), width: 8)
        Art.stroke(&context, longRays, Art.color(0xFFF2B0, 0.55), width: 3.4)
        // The disc: a soft scalloped edge under a round face.
        let frill: Path = Kit.personScallop(cx: 0, cy: 0, rx: 49, ry: 49, from: 0, to: 345, count: 24, r: 7)
        Art.fill(&context, frill, Art.color(0xFFC247))
        let disc: Path = Art.circle(0, 0, 50)
        let gold: Kit.Stops = [(Art.color(0xFFF1A6), 0), (Art.color(0xFFD860), 0.5), (Art.color(0xFFB83E), 1)]
        Art.fillRadial(&context, disc, gold, center: CGPoint(x: -16, y: -18), radius: 82)
        Art.clipped(&context, to: disc) { c in
            Art.glow(&c, 30, 34, 52, Art.color(0xF0842A), alpha: 0.3)
        }
        ArtStyle.rimLight(&context, 0, 0, 50, alpha: 0.4)
        sunFeatures(&context, mood: mood)
    }

    /// The Sun's face: half-closed smiling eyes, soft brows, rosy cheeks, a closed smile.
    static func sunFeatures(_ context: inout GraphicsContext, mood: SunMood) {
        let ink: Color = Art.color(0x9A4A0A)
        let lid: Color = Art.color(0xFFD25A)
        let brows: Path = Art.svg("M-28,-21 q9,-6.5 18,-1.5 M10,-22.5 q9,-5 18,1.5")
        Art.stroke(&context, brows, Art.color(0xD98A22), width: 2.6)
        if mood == .glowing {
            // Eyes closed in a smile.
            let arcs: Path = Art.svg("M-26,-5 q9,-9 18,0 M8,-5 q9,-9 18,0")
            Art.stroke(&context, arcs, ink, width: 3)
        } else {
            let look = CGPoint(x: -0.25, y: 0.3)
            ArtStyle.eye(&context, -17, -6, 9, look: look, showsWhite: true)
            ArtStyle.eye(&context, 17, -6, 9, look: look, showsWhite: true)
            heroLid(&context, -17, -6, 9, share: 0.36, skin: lid, line: ink)
            heroLid(&context, 17, -6, 9, share: 0.36, skin: lid, line: ink)
        }
        ArtStyle.cheek(&context, -30, 12, 13, alpha: 0.6)
        ArtStyle.cheek(&context, 30, 12, 13, alpha: 0.6)
        Art.stroke(&context, Art.svg("M-3,5 q3,3 6,0"), Art.color(0xD98A22), width: 2)
        switch mood {
        case .smiling:
            ArtStyle.smile(&context, 0, 19, width: 30, curve: 5.5, color: ink, lineWidth: 2.8)
        case .glowing:
            ArtStyle.smile(&context, 0, 18, width: 36, curve: 8, color: ink, lineWidth: 3)
            Art.stroke(&context, Art.svg("M-20,15 q-2,2 -1,5 M20,15 q2,2 1,5"), ink.opacity(0.7), width: 1.6)
        case .speaking:
            let mouth: Path = Art.svg("M-11,17 C-5,15 5,15 11,17 C10,26 5,30 0,30 C-5,30 -10,26 -11,17Z")
            Art.fill(&context, mouth, Art.color(0x8A3A14))
            Art.clipped(&context, to: mouth) { c in
                Art.fill(&c, Art.ellipse(0, 30, 6, 4), Art.color(0xF08A7A))
            }
        }
    }
}

// MARK: - The North Wind

extension WindSunArt {
    enum WindMood { case boasting, puffing, howling, spent, oh, pleased }

    /// The North Wind: a great grey-blue cloud of overlapping puffs with a face in it, centred
    /// on the face at (0, 0); about 300 wide (x −146…166) and 215 tall (y −110…106). He looks
    /// and blows toward the LEFT; mirror with `Art.group(scaleX: -1)` and `mirrored: true`.
    /// `streams` draws the curling breath from his mouth (about 190 units to the left).
    /// `pink` warms his edges (the last page). Blustery and comic, never a storm.
    static func windHero(_ context: inout GraphicsContext, mood: WindMood, streams: Bool = false, pink: Bool = false, mirrored: Bool = false) {
        let side: CGFloat = mirrored ? 1 : -1
        // Trailing wisps instead of arms, behind the cloud.
        let wisp: Color = Art.color(0xDCE8F1)
        taperStroke(&context, "M120,30 C160,36 186,20 196,2 C202,-12 188,-20 180,-10 C176,-4 182,2 188,0", width: 16, color: wisp)
        taperStroke(&context, "M112,58 C146,72 172,70 190,58 C200,50 194,40 186,44", width: 12, color: wisp)
        let backBlobs: [Kit.Blob] = [
            (-92, 10, 46), (88, -8, 52), (40, -66, 44), (-48, -58, 46), (118, 28, 34),
            (-6, 56, 50), (64, 46, 46), (-70, 48, 40), (140, -4, 26),
        ]
        var back = Path()
        for blob in backBlobs {
            back.addPath(Art.circle(blob.0, blob.1, blob.2))
        }
        Art.fill(&context, back, Art.color(cloudDeepHex))
        let mainBlobs: [Kit.Blob] = [
            (-60, -20, 56), (0, -40, 60), (58, -22, 56), (-84, 24, 40), (84, 24, 44),
            (0, 22, 66), (-34, 52, 40), (40, 54, 40),
        ]
        var main = Path()
        for blob in mainBlobs {
            main.addPath(Art.circle(blob.0, blob.1, blob.2))
        }
        let body: Path = main
        let tone: Kit.Stops = [(Art.color(0xDEE9F2), 0), (Art.color(cloudHex), 0.55), (Art.color(0x9DBBD4), 1)]
        Art.fillLinear(&context, body, tone, from: CGPoint(x: 0, y: -100), to: CGPoint(x: 0, y: 96))
        Art.clipped(&context, to: body) { c in
            // The one light: bright puff tops on the lit side, indigo under the far side.
            Art.glow(&c, 44 * side, -56, 60, Color.white, alpha: 0.55)
            Art.glow(&c, 96 * side, -6, 40, Color.white, alpha: 0.4)
            Art.glow(&c, -12 * side, -84, 40, Color.white, alpha: 0.4)
            Art.glow(&c, -70 * side, 60, 96, ArtStyle.coolShade, alpha: 0.16)
            if pink {
                Art.glow(&c, 96 * side, 20, 70, Art.color(0xFFA9B8), alpha: 0.5)
                Art.glow(&c, -96 * side, 16, 70, Art.color(0xFFA9B8), alpha: 0.5)
                Art.glow(&c, 0, 84, 70, Art.color(0xFFB9A8), alpha: 0.45)
            }
        }
        let scallops: Path = Art.svg("M-58,82 q20,13 40,2 M6,86 q20,11 42,-3 M-104,50 q8,13 24,13 M70,76 q18,2 30,-12")
        Art.stroke(&context, scallops, Art.color(0x7FA2C2, 0.55), width: 2.4)
        if streams {
            let power: CGFloat = mood == .howling ? 1.25 : 1
            Art.group(&context, x: -16, y: 40, scale: power) { g in
                windStreams(&g)
            }
        }
        windFeatures(&context, mood: mood, pink: pink, mirrored: mirrored)
    }

    /// The curling breath of the Wind, from (0, 0) toward the left: long tapering strokes that
    /// end in curls.
    static func windStreams(_ context: inout GraphicsContext) {
        let pale: Color = Art.color(0xFFFFFF, 0.9)
        let blue: Color = Art.color(0xA9C6DC, 0.8)
        taperStroke(&context, "M-6,-12 C-50,-22 -96,-30 -150,-22 C-176,-18 -188,-40 -172,-50 C-160,-56 -150,-44 -158,-38", width: 9, color: blue)
        taperStroke(&context, "M0,0 C-40,4 -90,-8 -130,6 C-158,16 -170,44 -150,54 C-134,60 -124,44 -136,36", width: 12, color: pale)
        taperStroke(&context, "M-4,12 C-36,26 -70,30 -104,44 C-126,54 -128,78 -112,82 C-100,84 -96,72 -104,68", width: 8, color: blue)
    }

    /// The Wind's face: big friendly eyes, soft brows, puffed cheeks and a mouth for each mood.
    static func windFeatures(_ context: inout GraphicsContext, mood: WindMood, pink: Bool, mirrored: Bool) {
        let side: CGFloat = mirrored ? 1 : -1
        let ink: Color = Art.color(0x47688A)
        let skin: Color = Art.color(0xC9DBE8)
        // Cheeks: two puffs of their own, bigger the harder he blows.
        var puff: CGFloat = 24
        if mood == .puffing { puff = 30 }
        if mood == .howling { puff = 34 }
        if mood == .boasting { puff = 27 }
        var cheeks = Path()
        cheeks.addPath(Art.circle(-46, 22, puff))
        cheeks.addPath(Art.circle(46, 22, puff))
        Art.fill(&context, cheeks, Art.color(0xD6E4EF))
        Art.stroke(&context, Art.svg("M-66,36 q10,14 30,12 M30,48 q20,2 32,-12"), Art.color(0x7FA2C2, 0.5), width: 2)
        let blush: Double = pink ? 0.8 : 0.5
        ArtStyle.cheek(&context, -46, 24, puff * 0.72, alpha: blush)
        ArtStyle.cheek(&context, 46, 24, puff * 0.72, alpha: blush)
        Art.fill(&context, Art.ellipse(-46 + 9 * side, 12, puff * 0.26, puff * 0.18), Color.white.opacity(0.6))
        Art.fill(&context, Art.ellipse(46 + 9 * side, 12, puff * 0.26, puff * 0.18), Color.white.opacity(0.6))
        windEyes(&context, mood: mood, ink: ink, skin: skin, mirrored: mirrored)
        windMouth(&context, mood: mood, ink: ink)
        if mood == .spent {
            // Two drops of effort on the lit side of his brow.
            var drops = Path()
            drops.addPath(Kit.placed("M0,-7 C4,-1 5,2 5,4 C5,7 3,9 0,9 C-3,9 -5,7 -5,4 C-5,2 -4,-1 0,-7Z", x: 62, y: -52, scale: 1))
            drops.addPath(Kit.placed("M0,-7 C4,-1 5,2 5,4 C5,7 3,9 0,9 C-3,9 -5,7 -5,4 C-5,2 -4,-1 0,-7Z", x: 78, y: -34, scale: 0.7))
            Art.fill(&context, drops, Art.color(0xEAF6FF))
            Art.stroke(&context, drops, Art.color(0x8FB6D6), width: 1.2)
        }
    }

    static func windEyes(_ context: inout GraphicsContext, mood: WindMood, ink: Color, skin: Color, mirrored: Bool) {
        var brows: Path = Art.svg("M-39,-44 q14,-9 27,-2 M12,-46 q13,-7 27,2")
        switch mood {
        case .boasting:
            heroEye(&context, -24, -22, 13, look: CGPoint(x: -0.5, y: -0.3), mirrored: mirrored)
            heroEye(&context, 24, -22, 13, look: CGPoint(x: -0.5, y: -0.3), mirrored: mirrored)
        case .puffing:
            heroEye(&context, -24, -22, 13, look: CGPoint(x: -0.6, y: 0.5), mirrored: mirrored)
            heroEye(&context, 24, -22, 13, look: CGPoint(x: -0.6, y: 0.5), mirrored: mirrored)
            brows = Art.svg("M-39,-41 q14,-7 27,-2 M12,-43 q13,-5 27,2")
        case .howling:
            // Eyes squeezed shut with the effort.
            let shut: Path = Art.svg("M-36,-28 L-16,-21 L-36,-14 M36,-28 L16,-21 L36,-14")
            Art.stroke(&context, shut, ink, width: 3.6)
            brows = Art.svg("M-40,-38 q14,-6 26,-1 M14,-39 q12,-5 26,1")
        case .spent:
            heroEye(&context, -24, -22, 12, look: CGPoint(x: -0.2, y: 0.7), mirrored: mirrored)
            heroEye(&context, 24, -22, 12, look: CGPoint(x: -0.2, y: 0.7), mirrored: mirrored)
            heroLid(&context, -24, -22, 12, share: 0.52, skin: skin, line: ink)
            heroLid(&context, 24, -22, 12, share: 0.52, skin: skin, line: ink)
            brows = Art.svg("M-40,-36 q14,-7 27,-9 M13,-45 q13,2 27,9")
        case .oh:
            heroEye(&context, -24, -22, 14, look: CGPoint(x: -0.5, y: 0.5), mirrored: mirrored)
            heroEye(&context, 24, -22, 14, look: CGPoint(x: -0.5, y: 0.5), mirrored: mirrored)
            brows = Art.svg("M-39,-49 q14,-8 27,-2 M12,-51 q13,-6 27,2")
        case .pleased:
            let arcs: Path = Art.svg("M-36,-20 q12,-12 24,0 M12,-20 q12,-12 24,0")
            Art.stroke(&context, arcs, ink, width: 3.6)
        }
        Art.stroke(&context, brows, Art.color(0x6E8FAE), width: 4.2)
    }

    static func windMouth(_ context: inout GraphicsContext, mood: WindMood, ink: Color) {
        let inside: Color = Art.color(0x4A5E86)
        let tongue: Color = Art.color(0xF0919E)
        let lip: Color = Art.color(0x7FA2C2)
        switch mood {
        case .boasting:
            let mouth: Path = Art.svg("M-21,24 C-8,20 8,20 21,24 C19,43 9,52 0,52 C-9,52 -19,43 -21,24Z")
            Art.fill(&context, mouth, inside)
            Art.clipped(&context, to: mouth) { c in
                Art.fill(&c, Art.ellipse(0, 52, 13, 9), tongue)
            }
            Art.stroke(&context, Art.svg("M-21,24 C-8,20 8,20 21,24"), ink, width: 2.2)
        case .puffing:
            Art.fill(&context, Art.ellipse(-12, 40, 11, 12), lip)
            Art.fill(&context, Art.ellipse(-13, 40, 6.5, 8), inside)
        case .howling:
            Art.fill(&context, Art.ellipse(-10, 40, 18, 20), lip)
            Art.fill(&context, Art.ellipse(-11, 40, 13.5, 16), inside)
            Art.fill(&context, Art.ellipse(-9, 51, 7, 4), tongue)
        case .spent:
            let mouth: Path = Art.svg("M-12,36 C-5,33 5,33 12,36 C11,45 6,48 0,48 C-6,48 -11,45 -12,36Z")
            Art.fill(&context, mouth, inside)
            Art.fill(&context, Art.svg("M-5,43 C-5,54 7,54 7,43Z"), tongue)
        case .oh:
            Art.fill(&context, Art.ellipse(0, 40, 8, 9), lip)
            Art.fill(&context, Art.ellipse(0, 40, 5, 6.2), inside)
        case .pleased:
            ArtStyle.smile(&context, 0, 36, width: 32, curve: 7, color: ink, lineWidth: 3.2)
        }
    }
}

// MARK: - The traveller and his cloak

extension WindSunArt {
    /// wrapped: walking, hat on, cloak round him. gale: leaning into the wind, bare-headed,
    /// both fists in the wool, the cloak streaming behind. easy: walking in the sun, hat pushed
    /// back, cloak hanging loose, stick in hand. resting: sitting (the caller draws the seat),
    /// no cloak, hat in his hand. phew: as easy, standing, one hand up to push back his hat.
    enum TravellerState { case wrapped, gale, easy, phew, resting }

    /// A man of about thirty: brown skin, dark curly hair, a short dark beard, a cream
    /// knee-length tunic, sandals; a wide straw-coloured sun hat when `hat`.
    static func travellerLook(hat: Bool) -> Kit.Person {
        Kit.Person(
            age: .adult,
            skin: 0xB07A4E,
            hair: 0x2A1E1A,
            hairStyle: .curly,
            beard: .short,
            headwear: hat ? .wideBrim : .none,
            headwearColor: strawHex,
            garment: .chiton,
            cloth: 0xF5EAD0,
            trim: 0x9A6A3A,
            legs: 0xB07A4E,
            showsEyeWhite: true
        )
    }

    /// The traveller, origin at his feet (for `resting`: the ground under his seat), 168 tall,
    /// facing LEFT. In `gale` he leans 13 degrees into the wind: his face is then near
    /// (−35, −136). The caller draws the contact shadow, and mirrors with
    /// `Art.group(scaleX: -1)` and `mirrored: true`.
    static func traveller(_ context: inout GraphicsContext, state: TravellerState, mouth: Kit.Mouth = .smile, mirrored: Bool = false) {
        switch state {
        case .wrapped:
            Kit.person(&context, travellerLook(hat: true), pose: .walk, look: CGPoint(x: -0.3, y: 0), mouth: mouth, mirrored: mirrored)
            cloakWrap(&context, fists: false)
        case .gale:
            Art.group(&context, rotate: Kit.deg(-13)) { g in
                cloakFlap(&g)
                Kit.person(&g, travellerLook(hat: false), pose: .walk, look: CGPoint(x: -0.5, y: 0.3), mouth: mouth, mirrored: mirrored)
                cloakWrap(&g, fists: true)
                // His curls blown back.
                let blown: Path = Art.svg("M14,-160 q12,-6 20,-2 M18,-150 q12,-3 20,2 M10,-167 q10,-7 18,-5")
                Art.stroke(&g, blown, Art.color(0x2A1E1A), width: 2.6)
            }
        case .easy, .phew:
            if state == .easy {
                let stick: Path = Art.svg("M-36,-100 L-50,-1")
                Art.stroke(&context, stick, Art.color(0x8A6642), width: 4.2)
                Art.stroke(&context, Art.svg("M-37.5,-98 L-51,-6"), Art.color(0xC9A070, 0.7), width: 1.2)
            }
            cloakBack(&context)
            Art.group(&context, x: 15, y: -159, rotate: Kit.deg(26)) { g in
                strawHat(&g, cord: false)
            }
            let pose: Kit.Pose = state == .easy ? .walk : .wave
            Kit.person(&context, travellerLook(hat: false), pose: pose, look: CGPoint(x: -0.2, y: -0.2), mouth: mouth, mirrored: mirrored)
            cloakCollar(&context)
        case .resting:
            let look: Kit.Person = travellerLook(hat: false)
            Kit.person(&context, look, pose: .sit, look: CGPoint(x: -0.3, y: 0.1), mouth: mouth, mirrored: mirrored)
            let hand: CGPoint = Kit.hand(look, pose: .sit)
            Art.group(&context, x: hand.x - 10, y: hand.y - 14, rotate: Kit.deg(-62), scale: 0.9) { g in
                strawHat(&g, cord: false)
            }
            Art.fill(&context, Art.circle(hand.x, hand.y, 5.5), Art.color(0xB07A4E))
        }
    }

    /// The cloak wrapped round the walking body (person units, over the kit figure): from the
    /// collar under his chin to just above the knee, pinned at the shoulder with a bronze pin.
    static func cloakWrap(_ context: inout GraphicsContext, fists: Bool) {
        let wrap: Path = Art.svg("M-22,-113 C-12,-118 8,-118 20,-113 C30,-104 35,-80 33,-52 C32,-40 26,-30 18,-28 C4,-24 -16,-26 -28,-30 C-41,-37 -47,-60 -43,-80 C-41,-97 -32,-109 -22,-113Z")
        Kit.solid(&context, wrap, Art.color(cloakHex), light: 0.26, shade: 0.26)
        let folds: Path = Art.svg("M-31,-98 C-21,-80 -23,-56 -31,-34 M-7,-110 C2,-86 0,-60 -9,-29 M16,-109 C23,-84 23,-60 16,-31")
        Art.stroke(&context, folds, Art.color(cloakDarkHex, 0.7), width: ArtStyle.detailLine)
        let hem: Path = Art.svg("M-29,-31 C-16,-27 4,-25 18,-29")
        Art.stroke(&context, hem, Art.color(cloakDarkHex), width: 2.4)
        let collar: Path = Art.svg("M-22,-112 C-10,-105 8,-105 20,-112")
        Art.stroke(&context, collar, Art.color(cloakLightHex), width: 6.5)
        Art.stroke(&context, Art.svg("M-36,-92 C-40,-80 -41,-66 -38,-52"), ArtStyle.warmLight.opacity(0.35), width: 2.2)
        bronzePin(&context, x: -15, y: -108, r: 4.2)
        if fists {
            let skin: Color = Kit.personTone(0xB07A4E, 0.96)
            let pulls: Path = Art.svg("M-27,-86 L-12,-96 M-27,-84 L-8,-82 M-23,-73 L-6,-66 M-24,-76 L-12,-58")
            Art.stroke(&context, pulls, Art.color(cloakDarkHex, 0.8), width: 1.4)
            Art.fill(&context, Art.circle(-30, -86, 5.8), skin)
            Art.fill(&context, Art.circle(-26, -74, 5.8), skin)
            Art.stroke(&context, Art.svg("M-33,-87 q3,2 6,0 M-29,-75 q3,2 6,0"), Kit.personTone(0xB07A4E, 0.7), width: 1)
        }
    }

    /// The loose end of the cloak streaming out behind him in the gale (drawn before the body).
    static func cloakFlap(_ context: inout GraphicsContext) {
        let far: Path = Art.svg("M20,-96 C44,-110 70,-98 96,-112 C92,-96 100,-86 116,-84 C98,-72 80,-78 62,-66 C48,-58 36,-58 26,-62Z")
        Kit.solid(&context, far, Art.color(cloakDarkHex), light: 0.2, shade: 0.2)
        let near: Path = Art.svg("M22,-84 C46,-90 66,-76 90,-82 C84,-68 90,-56 104,-50 C84,-40 68,-48 52,-38 C42,-32 32,-32 24,-36Z")
        Kit.solid(&context, near, Art.color(cloakHex), light: 0.24, shade: 0.24)
        let folds: Path = Art.svg("M30,-74 C50,-76 66,-66 84,-68 M30,-56 C46,-56 60,-48 76,-50")
        Art.stroke(&context, folds, Art.color(cloakDarkHex, 0.7), width: ArtStyle.detailLine)
        Art.stroke(&context, Art.svg("M24,-84 C46,-90 66,-76 88,-81"), Art.color(cloakLightHex, 0.8), width: 1.6)
    }

    /// The cloak hanging loose down his back (drawn before the body).
    static func cloakBack(_ context: inout GraphicsContext) {
        let cape: Path = Art.svg("M-18,-112 C0,-117 16,-115 23,-109 C36,-88 44,-58 48,-22 C38,-15 22,-14 8,-19 C10,-50 6,-84 -18,-112Z")
        Kit.solid(&context, cape, Art.color(cloakHex), light: 0.24, shade: 0.26)
        let folds: Path = Art.svg("M26,-98 C34,-72 38,-48 38,-20 M18,-92 C24,-66 26,-44 24,-18")
        Art.stroke(&context, folds, Art.color(cloakDarkHex, 0.7), width: ArtStyle.detailLine)
        Art.stroke(&context, Art.svg("M9,-19 C22,-14 38,-15 47,-22"), Art.color(cloakDarkHex), width: 2.2)
    }

    /// The loose cloak's collar across his shoulders, with the pin (drawn after the body).
    static func cloakCollar(_ context: inout GraphicsContext) {
        let band: Path = Art.svg("M-24,-111 C-10,-103 10,-103 22,-110 L25,-99 C12,-92 -10,-92 -25,-100Z")
        Kit.solid(&context, band, Art.color(cloakHex), light: 0.26, shade: 0.22)
        Art.stroke(&context, Art.svg("M-24,-110 C-10,-102 10,-102 22,-109"), Art.color(cloakLightHex), width: 2)
        bronzePin(&context, x: -16, y: -104, r: 4.2)
    }

    /// The round bronze pin of the cloak, catching the light.
    static func bronzePin(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat) {
        Art.fill(&context, Art.circle(x + r * 0.12, y + r * 0.16, r * 1.08), Art.color(0x7A4A1E, 0.6))
        let disc: Path = Art.circle(x, y, r)
        let tone: Kit.Stops = [(Art.color(0xFFE9A8), 0), (Art.color(bronzeHex), 0.5), (Art.color(0xA8702A), 1)]
        Art.fillRadial(&context, disc, tone, center: CGPoint(x: x - r * 0.35, y: y - r * 0.4), radius: r * 1.5)
        Art.stroke(&context, Art.circle(x, y, r * 0.55), Art.color(0x8A5A22, 0.7), width: max(0.6, r * 0.14))
        Art.fill(&context, Art.circle(x - r * 0.34, y - r * 0.38, r * 0.2), Color.white.opacity(0.9))
    }

    /// The cloak folded on the ground: origin under its middle, about 70 wide and 27 high.
    static func foldedCloak(_ context: inout GraphicsContext) {
        Kit.shadow(&context, 0, 0, width: 72)
        let lower: Path = Art.svg("M-34,0 C-37,-8 -35,-13 -28,-14 L28,-14 C35,-13 37,-8 34,0Z")
        Kit.solid(&context, lower, Art.color(cloakDarkHex), light: 0.2, shade: 0.2)
        let upper: Path = Art.svg("M-30,-12 C-33,-21 -29,-26 -22,-27 L24,-27 C32,-25 33,-17 29,-12Z")
        Kit.solid(&context, upper, Art.color(cloakHex), light: 0.28, shade: 0.24)
        let edges: Path = Art.svg("M-28,-13 C-10,-10 12,-10 28,-13 M-24,-20 C-8,-17 10,-17 26,-20")
        Art.stroke(&context, edges, Art.color(cloakDarkHex, 0.8), width: ArtStyle.detailLine)
        Art.stroke(&context, Art.svg("M-22,-26.4 L22,-26.4"), Art.color(cloakLightHex), width: 1.6)
        bronzePin(&context, x: 10, y: -23, r: 3.4)
    }

    /// His wide straw sun hat on its own (pushed back, in the hand, in the air): origin at the
    /// middle of the brim, 84 wide, the crown 25 above. `cord` draws the chin cord trailing.
    static func strawHat(_ context: inout GraphicsContext, cord: Bool) {
        if cord {
            Art.stroke(&context, Art.svg("M-30,3 C-26,30 14,40 30,4"), Art.color(0x8A6642), width: 1.4)
        }
        let brim: Path = Art.svg("M-42,0 C-40,-7 -20,-9.5 0,-9.5 C20,-9.5 40,-7 42,0 C40,6 20,8.5 0,8.5 C-20,8.5 -40,6 -42,0Z")
        Kit.solid(&context, brim, Art.color(strawHex), light: 0.32, shade: 0.3, rim: 1.2)
        let crown: Path = Art.svg("M-19,-3 C-22,-19 -11,-25 0,-25 C11,-25 22,-19 19,-3 C10,0 -10,0 -19,-3Z")
        Kit.solid(&context, crown, Art.color(strawHex), light: 0.3, shade: 0.24)
        Art.stroke(&context, Art.svg("M-19.6,-7 C-10,-3 10,-3 19.6,-7"), Art.color(0x9A6A3A), width: 3, cap: .butt)
        let weave: Path = Art.svg("M-30,-2 C-16,-5 16,-5 30,-2 M-34,3 C-16,6 16,6 34,3")
        Art.stroke(&context, weave, Art.color(0xB89A56, 0.6), width: 0.9)
    }
}

// MARK: - The coast: islands, goats, thyme, leaves on the wind

extension WindSunArt {
    /// One rocky island standing on the water line at (x, y): hazy, with a lit left slope and
    /// a thread of surf.
    static func island(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: Color) {
        let half: CGFloat = width / 2
        let top = CGPoint(x: x - width * 0.12, y: y - height)
        let leftControl = CGPoint(x: x - width * 0.4, y: y - height * 0.95)
        var shape = Path()
        shape.move(to: CGPoint(x: x - half, y: y))
        shape.addQuadCurve(to: top, control: leftControl)
        shape.addQuadCurve(to: CGPoint(x: x + width * 0.16, y: y - height * 0.6), control: CGPoint(x: x + width * 0.04, y: y - height * 0.98))
        shape.addQuadCurve(to: CGPoint(x: x + half, y: y), control: CGPoint(x: x + width * 0.34, y: y - height * 0.7))
        shape.closeSubpath()
        Art.fill(&context, shape, color)
        var lit = Path()
        lit.move(to: CGPoint(x: x - half, y: y))
        lit.addQuadCurve(to: top, control: leftControl)
        Art.stroke(&context, lit, ArtStyle.warmLight.opacity(0.45), width: max(1, height * 0.07))
        let surf: Path = Art.line(x - half * 1.06, y + 0.6, x + half * 1.06, y + 0.6)
        Art.stroke(&context, surf, Color.white.opacity(0.55), width: 1.3)
    }

    /// Two or three hazy islands along the horizon of a picture `w` wide, then a veil of air.
    static func islandRow(_ context: inout GraphicsContext, width w: CGFloat, horizon H: CGFloat, scale s: CGFloat, light: Kit.Light) {
        island(&context, x: w * 0.10, y: H + 1, width: 150 * s, height: 30 * s, color: light.far)
        island(&context, x: w * 0.31, y: H + 1, width: 84 * s, height: 19 * s, color: light.far.opacity(0.8))
        island(&context, x: w * 0.70, y: H + 1, width: 120 * s, height: 22 * s, color: light.far.opacity(0.7))
        ArtStyle.atmosphere(&context, width: w, top: H - 40 * s, bottom: H + 2, color: light.haze, alpha: 0.3)
    }

    static func goatLook() -> Kit.Beast {
        Kit.Beast(body: 0xEDE4D2, belly: 0xFBF6EA, dark: 0x6B5646, ears: .floppy, tail: .stub, muzzle: .long, bodyLength: 1.5, legLength: 0.9, bulk: 0.8)
    }

    /// A hill goat with short horns and a small bronze bell; origin on the ground under it,
    /// facing LEFT, about 150 long at scale 1.
    static func goat(_ context: inout GraphicsContext, pose: Kit.BeastPose = .stand) {
        let look: Kit.Beast = goatLook()
        Kit.shadow(&context, 0, 0, width: 110)
        Kit.beast(&context, look, pose: pose, mood: .calm)
        let head: CGPoint = Kit.beastHeadCentre(look, pose: pose)
        let horns: Path = Kit.placed("M0,0 C2,-14 12,-22 22,-21 M9,1 C11,-11 19,-17 29,-15", x: head.x + 2, y: head.y - 25, scale: 1)
        Art.stroke(&context, horns, Art.color(0x8A7A66), width: 4.2)
        bronzePin(&context, x: head.x + 8, y: head.y + 36, r: 5)
    }

    /// A cushion of thyme in flower: a low grey-green tuft with a few lilac specks.
    static func thyme(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat, width: CGFloat, seed: UInt32) {
        let palette: Kit.Greens = Kit.greens(0x4A6650, 0x66836A, 0x86A283, 0xAEC4A0, 0xD6E2BE)
        Kit.bush(&context, x: x, baseY: baseY, width: width, palette: palette, seed: seed)
        let top = CGRect(x: x - width * 0.4, y: baseY - width * 0.42, width: width * 0.8, height: width * 0.26)
        Kit.flecks(&context, in: top, count: 9, seed: seed &+ 3, color: Art.color(0xC9A6E0), radius: 1.0...2.0)
    }

    /// Olive leaves torn off by the wind, flying level across `rect`: silver and green.
    static func leafFlurry(_ context: inout GraphicsContext, in rect: CGRect, count: Int, seed: UInt32, size: CGFloat = 9) {
        var random = ArtRandom(seed)
        var silver = Path()
        var green = Path()
        for i in 0..<max(0, count) {
            let x: CGFloat = rect.minX + rect.width * Kit.rnd(&random)
            let y: CGFloat = rect.minY + rect.height * Kit.rnd(&random)
            let angle: CGFloat = (Kit.rnd(&random) - 0.5) * 0.9
            let length: CGFloat = size * (0.7 + Kit.rnd(&random) * 0.6)
            let base = CGPoint(x: x, y: y)
            if i % 2 == 0 {
                Kit.groundLeaf(&silver, base: base, angle: angle, length: length, width: length * 0.3)
            } else {
                Kit.groundLeaf(&green, base: base, angle: angle, length: length, width: length * 0.3)
            }
        }
        Art.fill(&context, green, Art.color(0x7C947A))
        Art.fill(&context, silver, Art.color(0xDCE6C8))
    }

    /// One long pale gust blowing to the RIGHT from (x, y), ending in a curl.
    static func gust(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, length L: CGFloat, width: CGFloat, color: Color) {
        let k: CGFloat = L / 200
        var path = Path()
        path.move(to: CGPoint(x: x, y: y))
        path.addCurve(to: CGPoint(x: x + L * 0.8, y: y - 2 * k), control1: CGPoint(x: x + L * 0.3, y: y + 9 * k), control2: CGPoint(x: x + L * 0.55, y: y - 11 * k))
        path.addCurve(to: CGPoint(x: x + L * 0.9, y: y - 20 * k), control1: CGPoint(x: x + L, y: y + 5 * k), control2: CGPoint(x: x + L * 1.02, y: y - 19 * k))
        path.addCurve(to: CGPoint(x: x + L * 0.88, y: y - 7 * k), control1: CGPoint(x: x + L * 0.8, y: y - 20 * k), control2: CGPoint(x: x + L * 0.8, y: y - 9 * k))
        let whole: Path = path
        Art.stroke(&context, whole, color.opacity(0.5), width: width * 0.34)
        Art.stroke(&context, whole.trimmedPath(from: 0, to: 0.72), color.opacity(0.7), width: width * 0.62)
        Art.stroke(&context, whole.trimmedPath(from: 0, to: 0.4), color, width: width)
    }
}
