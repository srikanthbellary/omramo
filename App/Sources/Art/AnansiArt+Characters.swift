import SwiftUI
import Foundation
import OmramoCore

// The people of the Anansi pictures: Father Anansi (climbing, standing, face) and his son
// Kweku Tsin, ported from art-anansi.js, plus the village listeners and houses.

extension AnansiArt {
    // MARK: Father Anansi, climbing

    /// Father Anansi climbing in profile, facing right. Origin is his hip; the trunk surface
    /// is at x ≈ 36 (times `s`). He is about 95 units tall above the hip and 32 below.
    static func anansiClimbing(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ s: CGFloat,
        withPot: Bool = true,
        lookingDown: Bool = false
    ) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            // Far leg and far arm.
            limb(&g, "M-2,6 C4,18 16,24 31,25", 9.5, skinDark)
            Art.group(&g, x: 36, y: 27, rotate: rad(62)) { f in
                Art.fill(&f, Art.ellipse(0, 0, 7.5, 4.5), skinDark)
            }
            limb(&g, "M10,-50 C20,-60 30,-66 40,-68", 8, skinDark)

            // Wrapped cloth.
            let body = Art.svg("M-4,-58 C6,-64 16,-60 18,-52 C22,-36 16,-14 12,2 C8,10 -6,12 -12,4 C-18,-14 -16,-44 -4,-58Z")
            kente(&g, in: body, scale: 0.5)
            // The one light comes from the upper left, behind him: his back is lit, and the
            // side toward the trunk falls into the indigo shade (the pot lights it again).
            let shade: [(Color, CGFloat)] = [
                (Art.color(0xFFE9A8, 0.26), 0), (ArtStyle.coolShade.opacity(0), 0.4), (ArtStyle.coolShade.opacity(0.38), 1),
            ]
            Art.fillLinear(&g, body, shade, from: pt(-16, 0), to: pt(20, 0))
            let back = Art.svg("M-10,-52 C-22,-40 -24,-12 -18,10 C-14,16 -8,14 -8,6 C-12,-14 -10,-36 -2,-56Z")
            kente(&g, in: back, scale: 0.5)
            Art.fill(&g, back, ArtStyle.warmLight.opacity(0.14))
            Art.stroke(
                &g,
                Art.svg("M-9,-51 C-21,-40 -23,-12 -17.4,9"),
                ArtStyle.warmLight.opacity(0.6), width: 1.2
            )

            // Near leg.
            limb(&g, "M2,2 C12,-12 24,-14 32,-6", 11, skin)
            limb(&g, "M32,-6 C34,-1 34,2 33,5", 9.5, skin)
            Art.group(&g, x: 36, y: 8, rotate: rad(64)) { f in
                Art.fill(&f, Art.ellipse(0, 0, 7.5, 4.5), skin)
            }

            // Cord, and the pot swinging in front of him.
            if withPot {
                Art.stroke(
                    &g,
                    Art.svg("M8,-58 C14,-48 22,-40 27,-36 M14,-60 C20,-50 26,-42 29,-37"),
                    Art.color(0xE9D9B0), width: 1.3, cap: .butt
                )
                Art.group(&g, x: 27, y: -20, rotate: rad(-10)) { p in
                    pot(&p, 0, 6, 0.8)
                }
            }

            // Near arm and both hands on the trunk.
            limb(&g, "M12,-52 C20,-50 30,-48 38,-50", 8.5, skin)
            Art.fill(&g, Art.circle(40, -51, 5.2), skin)
            Art.fill(&g, Art.circle(42, -69, 5), skinDark)

            // Head: a little larger than the design's, so he stands about 3 heads tall like
            // the front-view Anansi. The shared eye, cheek and mouth; a raised, friendly brow.
            let tilt: CGFloat = lookingDown ? 8 : -14
            Art.group(&g, x: 6, y: -78, rotate: rad(tilt), scale: 1.2) { hd in
                let tone: [(Color, CGFloat)] = [(skinLight, 0), (skinDark, 1)]
                Art.fillRadial(&hd, Art.ellipse(0, 0, 14.5, 15.5), tone, center: pt(-4.6, -6.6), radius: 27)
                Art.fill(&hd, Art.svg("M-14,-2 C-16,-14 -6,-19 4,-17 C-2,-14 -6,-10 -7,-4 C-8,2 -11,4 -14,-2Z"), hairWhite)
                Art.fill(&hd, Art.svg("M-2,13 C4,17 11,14 13,6 C13,12 10,20 2,20 C-2,20 -4,16 -2,13Z"), hairWhite)
                Art.fill(&hd, Art.ellipse(-5, 2, 3, 4), skinDark)
                ArtStyle.rimLight(&hd, 0, 0, 15, alpha: 0.26)
                let eyeLook = CGPoint(x: 0.7, y: lookingDown ? 0.9 : -0.5)
                let eyeY: CGFloat = lookingDown ? -2.2 : -3.2
                ArtStyle.eye(&hd, 7.4, eyeY, 2.7, look: eyeLook, iris: eyeTone, showsWhite: false)
                Art.stroke(&hd, Art.svg("M2.6,-8.6 Q7,-11.6 11.6,-8.9"), hairWhite, width: 1.8)
                ArtStyle.cheek(&hd, 5.5, 4.4, 4.6, alpha: 0.3)
                let nose = Art.svg("M14,0 C17,2 17,5 13.5,5")
                Art.fill(&hd, nose, skin)
                Art.stroke(&hd, nose, skinDark, width: 0.8)
                if lookingDown {
                    Art.fill(&hd, Art.ellipse(10, 9.6, 1.9, 2.3), mouthTone)
                } else {
                    ArtStyle.smile(&hd, 9.6, 8.8, width: 6.4, curve: 0.9, color: mouthTone, lineWidth: 1.5)
                }
            }

            // Drops of effort while he struggles with the pot.
            if withPot {
                let drops = Art.svg("M-19,-95 q-3,5 0,8 q3,-3 0,-8Z M-25,-82 q-3,5 0,8 q3,-3 0,-8Z")
                Art.fill(&g, drops, Art.color(0xBFE6FF, 0.9))
            }
        }
    }

    // MARK: Faces

    /// The skin of a front-view face, lit from the upper left like everything in the app.
    static func faceSkin(_ g: inout GraphicsContext) {
        let tone: [(Color, CGFloat)] = [(skinLight, 0), (skinWarm, 1)]
        Art.fillRadial(&g, Art.ellipse(0, 0, 26, 28), tone, center: pt(-5.2, -11.2), radius: 48.6)
    }

    /// The two eyes of a front-view face (the shared `ArtStyle.eye`). Scenes and the cover
    /// use the plain dark eye of the Medium tier; the portrait cards and face chips pass
    /// `showsWhite: true` for a modest white, the same for both characters.
    /// `lookX` / `lookY` are in face units (about −3…3), as in the design.
    static func faceEyes(_ g: inout GraphicsContext, lookX: CGFloat, lookY: CGFloat, showsWhite: Bool) {
        let look = CGPoint(x: lookX / 3, y: lookY / 3)
        let centres: [CGFloat] = [-10, 10]
        for ex in centres {
            if showsWhite {
                ArtStyle.eye(&g, ex, -1, 5.6, look: look, iris: eyeTone, showsWhite: true)
            } else {
                let cx: CGFloat = ex + lookX * 0.3
                let cy: CGFloat = -1 + lookY * 0.3
                ArtStyle.eye(&g, cx, cy, 3.9, look: look, iris: eyeTone, showsWhite: false)
            }
        }
    }

    /// The soft blush and the nose of a front-view face.
    static func faceCheeksAndNose(_ g: inout GraphicsContext) {
        ArtStyle.cheek(&g, -15, 9.5, 6.5, alpha: 0.3)
        ArtStyle.cheek(&g, 15, 9.5, 6.5, alpha: 0.3)
        Art.stroke(&g, Art.svg("M-2.5,8 q2.5,2.4 5,0"), skinDark, width: 1.8)
    }

    static func ears(_ g: inout GraphicsContext) {
        Art.fill(&g, Art.ellipse(-27, 2, 6, 8), skin)
        Art.fill(&g, Art.ellipse(27, 2, 6, 8), skin)
        Art.fill(&g, Art.ellipse(-27, 2, 3, 4.5), skinDark)
        Art.fill(&g, Art.ellipse(27, 2, 3, 4.5), skinDark)
    }

    /// Kweku Tsin's face, front view. Origin is the middle of the face (52 × 56 units).
    static func kwekuHead(
        _ g: inout GraphicsContext,
        lookX: CGFloat, lookY: CGFloat,
        mouthOpen: Bool,
        showsWhite: Bool = false
    ) {
        ears(&g)
        faceSkin(&g)
        Art.fill(&g, Art.svg("M-26,-4 C-28,-26 -12,-34 0,-34 C12,-34 28,-26 26,-4 C22,-16 12,-21 0,-21 C-12,-21 -22,-16 -26,-4Z"), hairDark)
        faceEyes(&g, lookX: lookX, lookY: lookY, showsWhite: showsWhite)
        // Soft, lifted brows: curious, never cross.
        Art.stroke(&g, Art.svg("M-15.5,-11.5 q5.5,-3.4 10.5,-1 M5,-12.5 q5,-2.4 10.5,1"), browTone, width: 1.8)
        faceCheeksAndNose(&g)
        if mouthOpen {
            Art.fill(&g, Art.ellipse(0, 16.5, 3.4, 4), mouthTone)
        } else {
            ArtStyle.smile(&g, 0.5, 14.5, width: 14, curve: 2.8, color: mouthTone, lineWidth: 2)
        }
    }

    /// Father Anansi's face, front view. Origin is the middle of the face.
    /// `detail` adds ears and a little modelling for the larger drawings.
    /// Warm and wise, a little pleased with himself: one brow sits a touch higher.
    static func anansiHead(_ g: inout GraphicsContext, detail: Bool = false, showsWhite: Bool = false) {
        if detail {
            ears(&g)
        }
        faceSkin(&g)
        if detail {
            // Soft shade under the hairline and along the jaw, away from the light.
            Art.clipped(&g, to: Art.ellipse(0, 0, 26, 28)) { c in
                Art.fill(&c, Art.ellipse(0, -20, 27, 9), skinDark.opacity(0.3))
                Art.fill(&c, Art.ellipse(22, 12, 9, 16), skinDark.opacity(0.22))
            }
        }
        Art.fill(&g, Art.svg("M-26,-2 C-29,-24 -14,-33 0,-33 C14,-33 29,-24 26,-2 C22,-15 12,-20 0,-20 C-12,-20 -22,-15 -26,-2Z"), hairWhite)
        Art.fill(&g, Art.svg("M-20,12 C-17,27 -8,31 0,31 C8,31 17,27 20,12 C15,21 8,24 0,24 C-8,24 -15,21 -20,12Z"), hairWhite)
        faceEyes(&g, lookX: 0, lookY: 0, showsWhite: showsWhite)
        if detail {
            // Smile lines at the corners of the eyes.
            Art.stroke(&g, Art.svg("M-18,3.5 q-2,1.5 -2.5,4 M18,3.5 q2,1.5 2.5,4"), skinDark.opacity(0.5), width: 1)
        }
        // White brows in high, round arcs; the one on the right a touch higher.
        Art.stroke(&g, Art.svg("M-16,-10.5 q5,-3 10,-0.5 M16,-12 q-5,-3 -10,-0.5"), hairWhite, width: 2.2)
        faceCheeksAndNose(&g)
        ArtStyle.smile(&g, 0, 14.5, width: 13, curve: 2.4, color: mouthTone, lineWidth: 2)
    }

    // MARK: Kweku Tsin

    /// Kweku's shoulders, kente wrap and head. Origin is the middle of his face; the body
    /// runs down to y = 110.
    static func kwekuBust(
        _ g: inout GraphicsContext,
        lookX: CGFloat, lookY: CGFloat,
        mouthOpen: Bool,
        tilt: CGFloat = 8,
        showsWhite: Bool = false
    ) {
        Art.fill(&g, Art.svg("M-40,110 C-44,50 -30,26 0,24 C30,26 46,50 42,110Z"), Art.color(0x8A4F33))
        let wrap = Art.svg("M-42,110 C-44,60 -30,30 -6,24 L34,66 L44,110Z")
        kente(&g, in: wrap, scale: 0.42)
        let fall: [(Color, CGFloat)] = [
            (ArtStyle.coolShade.opacity(0.06), 0), (ArtStyle.coolShade.opacity(0.3), 1),
        ]
        Art.fillLinear(&g, wrap, fall, from: pt(-44, 0), to: pt(44, 0))
        Art.group(&g, rotate: rad(tilt)) { hd in
            kwekuHead(&hd, lookX: lookX, lookY: lookY, mouthOpen: mouthOpen, showsWhite: showsWhite)
            ArtStyle.rimLight(&hd, 0, -3, 30, alpha: 0.2)
        }
        // The warm edge of the one light along his left shoulder.
        Art.stroke(&g, Art.svg("M-41,104 C-43,66 -36,42 -22,31"), ArtStyle.warmLight.opacity(0.45), width: 1.4)
    }

    /// Kweku's hands, drawn over the leaves he holds apart. Same origin as `kwekuBust`.
    static func kwekuHands(_ g: inout GraphicsContext) {
        Art.fill(&g, Art.ellipse(-34, 36, 9, 7), skin)
        Art.fill(&g, Art.ellipse(40, 44, 9, 7), skin)
        Art.stroke(&g, Art.svg("M-38,33 q4,-2 8,0 M36,41 q4,-2 8,0"), skinDark.opacity(0.5), width: 1)
    }

    /// Kweku peeking from the leaves at the bottom right of the leading pane (screen 04).
    /// He belongs to the near plane: on a tall canvas he and his leaves grow with it.
    static func kwekuWatching(
        _ context: inout GraphicsContext,
        _ st: Stage,
        lookX: CGFloat, lookY: CGFloat,
        mouthOpen: Bool
    ) {
        nearStage(&context, st, anchor: 348, scale: st.near) { g in
            Art.glow(&g, 330, 610, 70, ArtStyle.anansi.glowColor, alpha: 0.14)
            Art.group(&g, x: 348, y: 622) { b in
                kwekuBust(&b, lookX: lookX, lookY: lookY, mouthOpen: mouthOpen)
            }
            leaf(&g, 262, 740, 130, -58, dark: false)
            leaf(&g, 318, 760, 128, -100, dark: true)
            leaf(&g, 446, 740, 140, -122, dark: false)
            leaf(&g, 380, 770, 120, -78, dark: true)
            Art.group(&g, x: 348, y: 622) { b in
                kwekuHands(&b)
            }
        }
    }

    /// Kweku in his leaves for the folded bands: the bust at (x, y), `s` times the scene size,
    /// with the leaves he holds apart.
    static func kwekuInLeaves(
        _ g: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ s: CGFloat,
        lookX: CGFloat, lookY: CGFloat,
        mouthOpen: Bool
    ) {
        Art.group(&g, x: x, y: y, scale: s) { b in
            Art.glow(&b, -14, -8, 66, ArtStyle.anansi.glowColor, alpha: 0.16)
            kwekuBust(&b, lookX: lookX, lookY: lookY, mouthOpen: mouthOpen)
            leaf(&b, -86, 118, 130, -58, dark: false)
            leaf(&b, -30, 138, 128, -100, dark: true)
            leaf(&b, 98, 118, 140, -122, dark: false)
            leaf(&b, 32, 148, 120, -78, dark: true)
            kwekuHands(&b)
        }
    }

    // MARK: Father Anansi, standing

    /// Father Anansi standing, front view, in a cloth draped over one shoulder. Origin is the
    /// ground between his feet; he is about 140 units tall at scale 1 — a little over 3 heads.
    /// `withPot` hangs the pot round his neck; `gesture` raises his open hand as he speaks.
    static func anansiStanding(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ s: CGFloat,
        withPot: Bool,
        gesture: Bool
    ) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            // The shared contact shadow on the ground.
            ArtStyle.contactShadow(&g, 2, 1, 28, 5, alpha: 0.34)

            // Legs and feet.
            limb(&g, "M-7,-30 C-8,-20 -8,-12 -8,-4", 8, skin)
            limb(&g, "M7,-30 C8,-20 8,-12 8,-4", 8, skinDark)
            Art.fill(&g, Art.ellipse(-10, -2, 7, 3.6), skin)
            Art.fill(&g, Art.ellipse(11, -2, 7, 3.6), skinDark)

            // Bare shoulder and chest.
            Art.fill(&g, Art.svg("M-18,-90 C-10,-97 8,-98 17,-92 L20,-60 L-21,-60Z"), skin)

            // The cloth, from one shoulder across the body down to the shins.
            let cloth = Art.svg("M-20,-74 C-8,-78 6,-87 13,-97 C21,-93 25,-82 25,-66 C26,-50 25,-38 23,-24 L-22,-24 C-24,-42 -24,-60 -20,-74Z")
            kente(&g, in: cloth, scale: 0.5)
            // Lit from the upper left; the far side of the cloth falls into the indigo shade.
            let shade: [(Color, CGFloat)] = [
                (Art.color(0xFFE9A8, 0.24), 0), (ArtStyle.coolShade.opacity(0), 0.42), (ArtStyle.coolShade.opacity(0.34), 1),
            ]
            Art.fillLinear(&g, cloth, shade, from: pt(-24, 0), to: pt(26, 0))
            Art.stroke(&g, Art.svg("M-20,-74 C-24,-60 -24,-42 -22,-25"), ArtStyle.warmLight.opacity(0.5), width: 1.1)
            let fold = Art.svg("M9,-98 C18,-97 25,-90 26,-78 C27,-60 25,-46 21,-36 C18,-38 16,-42 15,-46 C17,-62 15,-80 7,-93Z")
            Art.fill(&g, fold, ArtStyle.coolShade.opacity(0.24))
            Art.stroke(&g, Art.svg("M7,-93 C15,-80 17,-62 15,-46"), Art.color(0xFFE9A8, 0.35), width: 1)
            Art.stroke(
                &g,
                Art.svg("M-12,-70 C-10,-54 -12,-40 -14,-25 M2,-78 C4,-60 2,-42 3,-25"),
                ArtStyle.coolShade.opacity(0.22), width: 1
            )
            Art.stroke(&g, Art.line(-21, -24, 22, -24), ArtStyle.coolShade.opacity(0.45), width: ArtStyle.detailLine)

            if withPot {
                Art.stroke(
                    &g,
                    Art.svg("M-6,-93 C-7,-82 -6,-72 -5,-66 M6,-94 C7,-82 6,-72 5,-66"),
                    Art.color(0xE9D9B0), width: 1.1, cap: .butt
                )
                pot(&g, 0, -51, 0.62)
                limb(&g, "M-18,-86 C-27,-76 -26,-62 -14,-53", 7.5, skin)
                Art.fill(&g, Art.circle(-12.5, -52, 4.6), skin)
                Art.fill(&g, Art.circle(12.5, -50, 4.6), skin)
            } else if gesture {
                limb(&g, "M-18,-86 C-27,-80 -31,-73 -35,-80", 7.5, skin)
                Art.fill(&g, Art.circle(-36, -83, 4.6), skin)
                Art.fill(&g, Art.circle(14, -58, 4.4), skin)
            } else {
                limb(&g, "M-18,-86 C-24,-74 -25,-62 -23,-52", 7.5, skin)
                Art.fill(&g, Art.circle(-23, -50, 4.6), skin)
            }

            // Neck and head.
            Art.fill(&g, Art.rect(-5, -102, 10, 10, radius: 3), skinDark)
            Art.group(&g, x: 0, y: -117, scale: 0.78) { hd in
                anansiHead(&hd, detail: true)
                ArtStyle.rimLight(&hd, 0, -2, 30, alpha: 0.2)
            }
        }
    }

    // MARK: Village

    /// A listener turned toward Father Anansi, lit warmly by the doorway on the right, with
    /// the same small eye, cheek and smile as everyone else. Origin is the ground under them.
    static func villager(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ s: CGFloat,
        seated: Bool,
        cloth: Color
    ) {
        // About 3 heads tall standing (63 units, head 21); 46 units seated.
        Art.group(&context, x: x, y: y, scale: s) { g in
            let seatedShape = "M-8,-25 C-13,-18 -16,-8 -17,0 L17,0 C16,-5 14,-9 11,-11 C12,-16 11,-21 8,-25 C4,-28 -4,-28 -8,-25Z"
            let standingShape = "M-9,-41 C-13,-30 -13,-14 -11,-2 C-4,0.5 5,0.5 11,-2 C13,-14 13,-30 9,-41 C5,-44.5 -5,-44.5 -9,-41Z"
            let body = Art.svg(seated ? seatedShape : standingShape)
            let headY: CGFloat = seated ? -35.5 : -52.5
            let headR: CGFloat = 10.5
            let top: CGFloat = seated ? -28 : -45
            let bounds = CGRect(x: -17, y: top, width: 34, height: -top)
            let head = Art.circle(0, headY, headR)

            ArtStyle.contactShadow(&g, 3, 0.5, 19, 3.2, alpha: 0.3)
            if !seated {
                Art.fill(&g, Art.ellipse(-3.5, -1, 5, 2.3), skinDark)
                Art.fill(&g, Art.ellipse(6, -1, 5, 2.3), skinDark)
            }

            // The wrapped cloth: lit from the upper left, warmed again by the doorway on
            // the right.
            Art.fill(&g, body, cloth)
            ArtStyle.form(&g, body, bounds: bounds, light: 0.3, shade: 0.3)
            let warm: [(Color, CGFloat)] = [
                (Art.color(0xFFB45A, 0), 0), (Art.color(0xFFB45A, 0), 0.6), (Art.color(0xFFB45A, 0.3), 1),
            ]
            Art.fillLinear(&g, body, warm, from: pt(-17, 0), to: pt(17, 0))
            let foldLine = seated ? "M-7,-24 C-1,-18 5,-14 11,-11" : "M-8,-40 C-2,-30 5,-22 11,-16"
            Art.stroke(&g, Art.svg(foldLine), ArtStyle.coolShade.opacity(0.35), width: 1)
            let hemLine = seated ? "M-15,-4 C-5,-1.5 6,-1.5 15,-4" : "M-11,-7 C-4,-4.5 5,-4.5 11,-7"
            Art.stroke(&g, Art.svg(hemLine), ArtStyle.anansi.glowColor.opacity(0.4), width: 0.9)
            limb(&g, seated ? "M6,-22 C10,-18 11,-14 9,-10" : "M7,-38 C11,-31 12,-25 10,-19", 4.2, skinDark)

            // Neck and head.
            Art.fill(&g, Art.rect(-3, headY + headR - 2.5, 6, 5, radius: 2), skinDark)
            let tone: [(Color, CGFloat)] = [(skin, 0), (skinDark, 1)]
            Art.fillRadial(&g, head, tone, center: pt(-3.5, headY - 4), radius: headR * 1.9)
            Art.clipped(&g, to: head) { c in
                Art.fill(&c, Art.ellipse(-3.5, headY - 6.5, 12, 8), hairDark)
                Art.glow(&c, 9.5, headY - 1, 10, Art.color(0xFFB45A), alpha: 0.32)
            }
            Art.fill(&g, Art.ellipse(-2.6, headY + 1.2, 2, 2.8), skinDark)
            ArtStyle.rimLight(&g, 0, headY, headR, alpha: 0.3)
            ArtStyle.eye(&g, 4.8, headY + 0.6, 1.5, iris: eyeTone, showsWhite: false)
            ArtStyle.cheek(&g, 4.2, headY + 4, 3, alpha: 0.3)
            ArtStyle.smile(&g, 5.8, headY + 5.2, width: 3.4, curve: 0.6, color: mouthTone, lineWidth: 0.9)
        }
    }

    /// A small far-off hut with a lit doorway. `peak` is the height of the roof point.
    static func hut(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ s: CGFloat,
        peak: CGFloat = 27
    ) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            let wallTone: [(Color, CGFloat)] = [(Art.color(0x3A2158), 0), (Art.color(0x241340), 1)]
            Art.fillLinear(&g, Art.rect(-11, -13, 22, 13), wallTone, from: pt(-11, 0), to: pt(11, 0))
            // A steep thatched roof with a soft, slightly bowed slope.
            var roof = Path()
            roof.move(to: pt(-17, -11))
            roof.addQuadCurve(to: pt(0, -peak), control: pt(-7, -peak * 0.6))
            roof.addQuadCurve(to: pt(17, -11), control: pt(7, -peak * 0.6))
            roof.addQuadCurve(to: pt(-17, -11), control: pt(0, -8.5))
            roof.closeSubpath()
            Art.fill(&g, roof, Art.color(0x1B0F33))
            var lit = Path()
            lit.move(to: pt(-16.4, -11.4))
            lit.addQuadCurve(to: pt(-0.6, -peak + 1), control: pt(-6.6, -peak * 0.6))
            Art.stroke(&g, lit, ArtStyle.warmLight.opacity(0.4), width: 0.9)
            let door = Art.rect(-3, -9.5, 6, 9.5, radius: 2.6)
            Art.fill(&g, door, Art.color(0xFFC45A))
            Art.fill(&g, door, Art.color(0xFFE9A8, 0.6))
        }
        Art.fill(&context, Art.circle(x, y - 5 * s, 12 * s), Art.color(0xFFB84D, 0.18))
    }

    /// A house with a steep thatched roof and a doorway lit from inside (`lit` 0…1).
    /// Origin is the middle of the doorstep; 100 units wide and 124 tall at scale 1.
    static func house(
        _ context: inout GraphicsContext,
        _ x: CGFloat, _ y: CGFloat, _ s: CGFloat,
        lit: Double
    ) {
        Art.group(&context, x: x, y: y, scale: s) { g in
            // The house's own shadow falls to the lower right, away from the one light.
            ArtStyle.contactShadow(&g, 16, 2, 58, 6, alpha: 0.3)
            let wall = Art.svg("M-34,0 C-35,-18 -35,-36 -33,-50 L33,-50 C35,-36 35,-18 34,0Z")
            let wallTone: [(Color, CGFloat)] = [(Art.color(0x4A2A5E), 0), (Art.color(0x2A1746), 1)]
            Art.fillLinear(&g, wall, wallTone, from: pt(0, -50), to: pt(0, 0))
            let wallShade: [(Color, CGFloat)] = [
                (ArtStyle.warmLight.opacity(0.1), 0), (ArtStyle.coolShade.opacity(0), 0.4), (ArtStyle.coolShade.opacity(0.34), 1),
            ]
            Art.fillLinear(&g, wall, wallShade, from: pt(-34, 0), to: pt(34, 0))
            if lit > 0 {
                Art.clipped(&g, to: wall) { c in
                    Art.glow(&c, 0, -18, 48, Art.color(0xFFB84D), alpha: 0.45 * lit)
                }
            }
            // The eave's shadow on the wall.
            Art.fill(&g, Art.svg("M-33,-50 L33,-50 L33.6,-41 C12,-37 -12,-37 -33.6,-41Z"), ArtStyle.coolShade.opacity(0.3))

            let roof = Art.svg("M-50,-44 C-30,-66 -12,-98 -2,-120 C-1,-126 1,-126 2,-120 C12,-98 30,-66 50,-44 C30,-39 -30,-39 -50,-44Z")
            let roofTone: [(Color, CGFloat)] = [(Art.color(0x2E1A4C), 0), (Art.color(0x150A2C), 1)]
            Art.fillLinear(&g, roof, roofTone, from: pt(0, -124), to: pt(0, -40))
            ArtStyle.form(&g, roof, bounds: CGRect(x: -50, y: -126, width: 100, height: 88), light: 0.2, shade: 0.3)
            Art.stroke(
                &g,
                Art.svg("M-49,-44.6 C-30,-66 -12,-98 -2,-120"),
                ArtStyle.warmLight.opacity(0.5), width: 1.2
            )
            var thatch = Path()
            for i in 0..<9 {
                let t = CGFloat(i) / 8 - 0.5
                thatch.move(to: pt(t * 10, -108))
                thatch.addQuadCurve(to: pt(t * 92, -43), control: pt(t * 44, -78))
            }
            let thatchLines = thatch
            Art.clipped(&g, to: roof) { c in
                Art.stroke(&c, thatchLines, Art.color(0x6A4A80, 0.4), width: 0.8, cap: .butt)
            }
            Art.stroke(
                &g,
                Art.svg("M-50,-44 C-30,-39 30,-39 50,-44"),
                Art.color(0xFFB45A, 0.12 + 0.3 * lit), width: 1.2
            )

            let door = Art.svg("M-10,0 L-10,-34 C-10,-43 10,-43 10,-34 L10,0Z")
            Art.fill(&g, door, Art.color(0x1B0F33))
            if lit > 0 {
                let light: [(Color, CGFloat)] = [
                    (Art.color(0xFFF1C0, lit), 0), (Art.color(0xFFC45A, lit), 0.6), (Art.color(0xF08A4A, lit), 1),
                ]
                Art.fillLinear(&g, door, light, from: pt(0, -42), to: pt(0, 0))
                Art.glow(&g, 0, -20, 46, Art.color(0xFFB84D), alpha: 0.4 * lit)
                Art.fill(&g, Art.ellipse(0, 3, 34, 5), Art.color(0xFFB84D, 0.25 * lit))
            }
        }
    }
}
