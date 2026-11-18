import SwiftUI
import OmramoCore

/// Concept art for "The Snow House", drawn in code (round 5; composed from the shared kit).
///
/// An Omramo original set in present-day Nunavut; cultural review is required and pending, so
/// every picture here is concept art. The cast, the land and the snow house itself live in
/// `SnowHouseArt+Cast.swift`; the folded scenes in `SnowHouseArt+Folded.swift`; the tap
/// pictures, portraits, faces and the cover in `SnowHouseArt+Pictures.swift`. This file holds
/// the entry point, the sled and the snowmobile, and the four unfolded scenes.
enum SnowHouseArt {
    /// Draws the picture called `name`. Returns false for a name this story does not have.
    static func paint(_ name: String, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else { return false }
        switch (name, role) {
        case ("scene-trail", .sceneUnfolded): trailScene(&context, size)
        case ("scene-trail", .sceneFolded): trailFolded(&context, size)
        case ("scene-cutting", .sceneUnfolded): cuttingScene(&context, size)
        case ("scene-cutting", .sceneFolded): cuttingFolded(&context, size)
        case ("scene-spiral", .sceneUnfolded): spiralScene(&context, size)
        case ("scene-spiral", .sceneFolded): spiralFolded(&context, size)
        case ("scene-night", .sceneUnfolded): nightScene(&context, size)
        case ("scene-night", .sceneFolded): nightFolded(&context, size)
        case ("see-nunavut", .picture): nunavutPicture(&context, size)
        case ("see-snow-knife", .picture): snowKnifePicture(&context, size)
        case ("see-qulliq", .picture): qulliqPicture(&context, size)
        case ("char-elisapie", .portrait): elisapiePortrait(&context, size)
        case ("char-grandfather", .portrait): grandfatherPortrait(&context, size)
        case ("face-elisapie", .face): elisapieFace(&context, size)
        case ("face-grandfather", .face): grandfatherFace(&context, size)
        case ("cover", .cover): cover(&context, size)
        default:
            return false
        }
        return true
    }
}

// MARK: - The qamutiik and the snowmobile

extension SnowHouseArt {
    /// The qamutiik: a long, low wooden sled, two runners with many crosspieces lashed on.
    /// Side view, nose to the LEFT; the origin is the snow under its middle; about 200 long.
    /// The top of the load (where a rider sits) is at about (55, −66).
    static func qamutiik(_ context: inout GraphicsContext, loaded: Bool = true) {
        let runner: Path = Art.svg("M-104,-26 Q-110,-8 -92,0 L96,0 L98,-12 L-84,-12 Q-94,-14 -95,-26Z")
        Kit.solid(&context, runner, Art.color(woodHex), light: 0.26, shade: 0.24)
        Art.stroke(&context, Art.line(-90, -2, 95, -2), Kit.propTone(woodHex, 0.62), width: 1.6)
        var slats = Path()
        var lashes = Path()
        for i in 0..<12 {
            let x: CGFloat = -80 + CGFloat(i) * 15.4
            slats.addPath(Art.rect(x - 5, -18.5, 10, 6.5, radius: 2))
            lashes.move(to: pt(x, -12))
            lashes.addLine(to: pt(x, -6))
        }
        Art.fill(&context, slats, Kit.propTone(woodHex, 1.22))
        Art.stroke(&context, lashes, Art.color(furPale), width: 1.6)
        if loaded {
            qamutiikLoad(&context)
        }
    }

    /// The load: rolled sleeping bags, a fuel can, a plywood sled box, caribou skins on top.
    static func qamutiikLoad(_ context: inout GraphicsContext) {
        let roll1: Path = Art.rect(-78, -44, 34, 25.5, radius: 12)
        Kit.solid(&context, roll1, Art.color(0x3E8FA0), light: 0.24, shade: 0.24)
        Art.stroke(&context, Art.svg("M-66,-43 L-66,-20 M-56,-43 L-56,-20"), Art.color(0x2B6B7A), width: 1.6)
        let roll2: Path = Art.rect(-43, -41, 30, 22.5, radius: 10.5)
        Kit.solid(&context, roll2, Art.color(0xE2A93B), light: 0.24, shade: 0.24)
        Art.stroke(&context, Art.svg("M-28,-40 L-28,-20"), Art.color(0xB07F1E), width: 1.6)
        let can: Path = Art.rect(-9, -49, 25, 30.5, radius: 4)
        Kit.solid(&context, can, Art.color(0xD9503E), light: 0.24, shade: 0.24)
        Art.fill(&context, Art.rect(8, -54, 6, 6, radius: 1.5), Art.color(0x2E3444))
        Art.stroke(&context, Art.svg("M-5,-49 Q0,-57 6,-50"), Art.color(0xA83426), width: 2.4)
        let box: Path = Art.rect(22, -58, 68, 39.5, radius: 2)
        Kit.solid(&context, box, Art.color(0xDDB97E), light: 0.26, shade: 0.24)
        Art.stroke(&context, Art.svg("M23,-47 L89,-47 M56,-47 L56,-20"), Kit.propTone(0xDDB97E, 0.72), width: 1.4)
        let skins: Path = Art.svg("M18,-56 C32,-68 74,-70 94,-58 C99,-50 97,-44 93,-40 C72,-48 42,-48 22,-40 C17,-45 16,-50 18,-56Z")
        Kit.solid(&context, skins, Art.color(0xB48E68), light: 0.24, shade: 0.22)
        Art.stroke(&context, Art.svg("M22,-40 C42,-48 72,-48 93,-40"), Art.color(0xEADFCB), width: 3.4)
        let ropes: Path = Art.svg("M-80,-18 C-74,-50 -46,-50 -40,-19 M-12,-19 C-8,-56 18,-56 20,-19")
        Art.stroke(&context, ropes, Art.color(furPale, 0.9), width: 1.5)
    }

    /// A plain modern snowmobile, side view, nose to the LEFT; the origin is the snow under
    /// its middle; about 160 long and 80 high. With `rider`, Grandfather sits on it, driving.
    static func snowmobile(_ context: inout GraphicsContext, body: UInt32 = 0xF2B62E, rider: Bool = false) {
        let dark: Color = Art.color(0x2E3444)
        // The ski at the front and its strut.
        Art.stroke(&context, Art.svg("M-86,-10 Q-82,-1 -70,-1 L-24,-1"), Art.color(0x3A4052), width: 4)
        Art.stroke(&context, Art.line(-50, -3, -42, -24), Art.color(0x596074), width: 4)
        // The track at the back.
        let track: Path = Art.rect(-14, -22, 92, 22, radius: 11)
        Kit.solid(&context, track, dark, light: 0.12, shade: 0.2)
        var wheels = Path()
        let hubs: [CGFloat] = [0, 22, 44, 65]
        for hub in hubs {
            wheels.addPath(Art.circle(hub, -11, 5.4))
        }
        Art.fill(&context, wheels, Art.color(0x6C7488))
        Art.stroke(&context, Art.line(-4, -1.4, 68, -1.4), Art.color(0x1F2330), width: 2.4, cap: .butt, dash: [3, 4])
        // The body, the seat and the windshield.
        let shell: Path = Art.svg("M-70,-24 C-66,-36 -48,-46 -24,-52 L62,-46 C74,-44 80,-36 78,-24 C40,-18 -30,-18 -70,-24Z")
        Kit.solid(&context, shell, Art.color(body), light: 0.3, shade: 0.24, rim: 2)
        Art.stroke(&context, Art.svg("M-54,-30 C-20,-26 30,-26 72,-31"), Kit.propTone(body, 0.74), width: 1.6)
        let seat: Path = Art.svg("M-8,-52 C10,-60 50,-58 66,-50 L64,-44 C40,-48 10,-48 -8,-46Z")
        Art.fill(&context, seat, dark)
        Art.stroke(&context, Art.svg("M-4,-54 C12,-59 46,-58 62,-51"), Art.color(0x596074), width: 1.4)
        let shield: Path = Art.svg("M-36,-49 L-20,-80 Q-16,-83 -14,-79 L-22,-52Z")
        Art.fill(&context, shield, Art.color(0xCFE9F7, 0.72))
        Art.stroke(&context, shield, Color.white.opacity(0.85), width: 1.2)
        Art.stroke(&context, Art.line(-20, -52, -10, -68), Art.color(0x3A4052), width: 3.4)
        Art.stroke(&context, Art.line(-13, -69.5, -5, -67), dark, width: 5)
        Art.fill(&context, Art.ellipse(-62, -30, 5, 4), Art.color(0xFFF6D0))
        if rider {
            Art.group(&context, x: 30, y: -22) { g in
                grandfather(&g, pose: .sit, look: CGPoint(x: -0.5, y: 0), mouth: .smile)
            }
        }
    }
}

// MARK: - Scene 1 (unfolded): the trail

extension SnowHouseArt {
    static func trailScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = day()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 150, st.H - 44 * st.far, 24 * st.far, light: light)
        Kit.cloud(&context, 610, st.H * 0.3, scale: 0.9 * st.far, color: Art.color(0xFFFFFF, 0.6))
        let hills: [(CGFloat, CGFloat, CGFloat)] = [(0.26, 0.6, 30), (0.74, 1.06, 42)]
        farLand(&context, width: w, horizon: st.H, scale: st.far, light: light, hills: hills, seed: 4)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: snowStops(dusk: false), seed: 71)
        // The low sun lies warm on the snow under it; the sea ice is a paler band.
        flatGlow(&context, 150, st.H + 14 * st.far, rx: 240 * st.far, ry: 26 * st.far, color: light.glow, alpha: 0.4)
        iceBand(&context, x0: -40, x1: 520, y: st.H + 12 * st.far, depth: 16 * st.far)
        Kit.designSpace(&context, st) { v in
            trailMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 690) { n in
                trailSubject(&n, st)
            }
            tallFill(&v, st, seed: 11)
            trailNear(&v, st)
        }
        ArtStyle.finish(&context, size)
    }

    static func trailMiddle(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        windRipples(&v, x0: 0, x1: 892, y0: Hv + 26, y1: Hv + 170, count: 34, seed: 5)
        softDrift(&v, x0: 40, x1: 330, baseY: Hv + 74, height: 16)
        softDrift(&v, x0: 250, x1: 470, baseY: Hv + 128, height: 13)
        Kit.rock(&v, cx: 96, baseY: Hv + 116, width: 62, height: 26, color: rockHex, seed: 6)
        Art.fill(&v, Art.ellipse(90, Hv + 91, 20, 6), Art.color(0xF8FAFE))
        Kit.pebbles(&v, in: CGRect(x: 126, y: Hv + 112, width: 70, height: 10), count: 5, seed: 8, color: rockHex)
        let sparkle = CGRect(x: 0, y: Hv + 40, width: 892, height: 130)
        Kit.flecks(&v, in: sparkle, count: 26, seed: 9, color: Color.white, radius: 0.7...1.5)
    }

    /// The snowmobile with Grandfather driving, the tow rope, and the qamutiik with Elisapie
    /// riding on the load, leaning forward and shouting "Faster!".
    static func trailSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let y0: CGFloat = st.Hv + 62
        tracks(&n, from: pt(858, y0 + 3), round: pt(950, y0 - 12), to: pt(735, st.Hv + 4), gap: 14)
        castShadow(&n, 566, y0 + 3, length: 150)
        castShadow(&n, 764, y0 + 3, length: 200)
        Art.group(&n, x: 562, y: y0, scale: 0.95) { g in
            snowmobile(&g, rider: true)
        }
        // The tow rope.
        Art.stroke(&n, Art.line(636, y0 - 24, 657, y0 - 23), Art.color(0x8A7A66), width: 1.8)
        Art.group(&n, x: 760, y: y0) { g in
            qamutiik(&g)
            Art.group(&g, x: 55, y: -40) { e in
                elisapie(&e, pose: .sit, look: CGPoint(x: -0.7, y: -0.1), mouth: .open)
            }
        }
        // Snow thrown up by the track and by the runners.
        var spray = Path()
        spray.addEllipse(in: CGRect(x: 630, y: y0 - 12, width: 18, height: 10))
        spray.addEllipse(in: CGRect(x: 642, y: y0 - 7, width: 12, height: 7))
        spray.addEllipse(in: CGRect(x: 856, y: y0 - 9, width: 16, height: 9))
        spray.addEllipse(in: CGRect(x: 868, y: y0 - 5, width: 10, height: 6))
        Art.fill(&n, spray, Color.white.opacity(0.85))
    }

    static func trailNear(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        Kit.drift(&v, x0: -80, x1: 300, baseY: st.hv + 4, height: 40, bottom: st.hv + 8, snow: true)
        nearBank(&v, x0: 590, x1: 990, baseY: st.hv + 6, height: 46)
    }
}

// MARK: - Scene 2 (unfolded): cutting the blocks

extension SnowHouseArt {
    static func cuttingScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = day()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 128, st.H - 40 * st.far, 23 * st.far, light: light)
        Kit.cloud(&context, 700, st.H * 0.24, scale: 0.8 * st.far, color: Art.color(0xFFFFFF, 0.6))
        let hills: [(CGFloat, CGFloat, CGFloat)] = [(-0.04, 0.2, 22), (0.5, 0.78, 26), (0.84, 1.1, 36)]
        farLand(&context, width: w, horizon: st.H, scale: st.far, light: light, hills: hills, seed: 14)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: snowStops(dusk: false), seed: 72)
        flatGlow(&context, 128, st.H + 14 * st.far, rx: 230 * st.far, ry: 26 * st.far, color: light.glow, alpha: 0.4)
        // The frozen lake.
        iceBand(&context, x0: 30, x1: 610, y: st.H + 16 * st.far, depth: 22 * st.far)
        Kit.designSpace(&context, st) { v in
            cuttingMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 690) { n in
                cuttingSubject(&n, st)
            }
            tallFill(&v, st, seed: 21)
            Kit.drift(&v, x0: -90, x1: 280, baseY: st.hv + 4, height: 38, bottom: st.hv + 8, snow: true)
            nearBank(&v, x0: 600, x1: 990, baseY: st.hv + 6, height: 44)
        }
        ArtStyle.finish(&context, size)
    }

    /// The parked snowmobile and sled, small, by the lake; ripples and a drift.
    static func cuttingMiddle(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        windRipples(&v, x0: 0, x1: 892, y0: Hv + 30, y1: Hv + 170, count: 34, seed: 15)
        tracks(&v, from: pt(318, Hv + 54), round: pt(420, Hv + 44), to: pt(372, Hv + 6), gap: 6)
        Art.group(&v, x: 240, y: Hv + 54, scale: 0.42) { g in
            castShadow(&g, -90, 3, length: 150)
            castShadow(&g, 100, 3, length: 200)
            Art.group(&g, x: -98, y: 0) { m in
                snowmobile(&m)
            }
            Art.stroke(&g, Art.line(-20, -24, -4, -23), Art.color(0x8A7A66), width: 2)
            Art.group(&g, x: 100, y: 0) { s in
                qamutiik(&s)
            }
        }
        softDrift(&v, x0: 20, x1: 200, baseY: Hv + 116, height: 14)
        softDrift(&v, x0: 300, x1: 470, baseY: Hv + 140, height: 12)
        let sparkle = CGRect(x: 0, y: Hv + 40, width: 892, height: 130)
        Kit.flecks(&v, in: sparkle, count: 26, seed: 19, color: Color.white, radius: 0.7...1.5)
    }

    /// The neat pit the blocks are cut from: a sharp-edged trench seen from a little above.
    static func cuttingPit(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, depth: CGFloat) {
        let mouth: [CGPoint] = [pt(x0 + 6, y), pt(x1 - 4, y), pt(x1 + 8, y + depth), pt(x0 - 6, y + depth)]
        let shape: Path = Art.polygon(mouth)
        Art.fillLinear(&context, shape, Kit.stops(0xC6D5EE, 0x7F98C8), from: pt(0, y), to: pt(0, y + depth))
        // The far cut face catches a little light; the near lip is a crisp white edge.
        let face: [CGPoint] = [pt(x0 + 6, y), pt(x1 - 4, y), pt(x1 - 1, y + depth * 0.4), pt(x0 + 3, y + depth * 0.4)]
        Art.fill(&context, Art.polygon(face), Art.color(0xDDE7F6, 0.9))
        Art.stroke(&context, Art.line(x0 + 6, y, x1 - 4, y), Art.color(snowLine, 0.8), width: 1.4)
        Art.stroke(&context, Art.line(x0 - 6, y + depth, x1 + 8, y + depth), Color.white, width: 2.2)
    }

    /// Elisapie stares at the block that cracked in two, her heap of crumbled snow behind
    /// her; Grandfather bends to the pit with his snow knife; clean blocks stand by.
    static func cuttingSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        crumbHeap(&n, cx: 506, baseY: Hv + 42, width: 76, seed: 3)
        Kit.snowBlock(&n, x: 770, baseY: Hv + 42, width: 54, height: 32)
        Kit.snowBlock(&n, x: 828, baseY: Hv + 40, width: 50, height: 30, tilt: 0.05)
        cuttingPit(&n, x0: 610, x1: 700, y: Hv + 52, depth: 18)
        Kit.snowBlock(&n, x: 604, baseY: Hv + 60, width: 56, height: 30, tilt: -0.14)
        // Grandfather, bending, the knife going down into the hard snow.
        castShadow(&n, 724, Hv + 54, length: 90)
        Art.group(&n, x: 722, y: Hv + 52) { g in
            grandfather(&g, pose: .bow, look: CGPoint(x: -0.2, y: 0.8), mouth: .smile)
            let hand = grandfatherHand(.bow)
            Art.group(&g, x: hand.x, y: hand.y, rotate: CGFloat.pi) { k in
                snowKnife(&k, length: 58)
            }
            Art.fill(&g, Art.circle(hand.x, hand.y, 6), Kit.personTone(parkaBlue, 0.7))
        }
        Kit.snowBlock(&n, x: 796, baseY: Hv + 58, width: 58, height: 34, tilt: -0.04)
        // Elisapie, the saw in her mitt, looking down at her block.
        castShadow(&n, 562, Hv + 64, length: 64)
        Art.group(&n, x: 560, y: Hv + 62) { g in
            elisapie(&g, pose: .stand, look: CGPoint(x: -0.5, y: 0.9), mouth: .oh)
            let hand = elisapieHand(.stand)
            Art.group(&g, x: hand.x, y: hand.y, rotate: CGFloat.pi - 0.2) { s in
                woodSaw(&s, length: 28)
            }
            Art.fill(&g, Art.circle(hand.x, hand.y, 4.6), Kit.personTone(parkaRed, 0.7))
        }
        brokenBlock(&n, x: 474, baseY: Hv + 74, width: 64, height: 32)
        let crumbs = CGRect(x: 468, y: Hv + 70, width: 84, height: 10)
        Kit.flecks(&n, in: crumbs, count: 9, seed: 23, color: Color.white, radius: 1.4...3)
    }
}

// MARK: - Scene 3 (unfolded): the spiral

extension SnowHouseArt {
    static func spiralScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = day()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        Kit.sun(&context, 118, st.H - 30 * st.far, 24 * st.far, light: light)
        let hills: [(CGFloat, CGFloat, CGFloat)] = [(0.1, 0.4, 24), (0.62, 0.92, 30)]
        farLand(&context, width: w, horizon: st.H, scale: st.far, light: light, hills: hills, seed: 24)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: snowStops(dusk: false), seed: 73)
        flatGlow(&context, 118, st.H + 14 * st.far, rx: 250 * st.far, ry: 28 * st.far, color: light.glow, alpha: 0.45)
        iceBand(&context, x0: -60, x1: 430, y: st.H + 14 * st.far, depth: 18 * st.far)
        Kit.designSpace(&context, st) { v in
            spiralMiddle(&v, st)
            Kit.nearSpace(&v, st, anchorX: 680) { n in
                spiralSubject(&n, st)
            }
            tallFill(&v, st, seed: 31)
            Kit.drift(&v, x0: -90, x1: 300, baseY: st.hv + 4, height: 36, bottom: st.hv + 8, snow: true)
            nearBank(&v, x0: 620, x1: 990, baseY: st.hv + 6, height: 40)
        }
        ArtStyle.finish(&context, size)
    }

    static func spiralMiddle(_ v: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        windRipples(&v, x0: 0, x1: 892, y0: Hv + 30, y1: Hv + 170, count: 34, seed: 25)
        Art.group(&v, x: 210, y: Hv + 46, scale: 0.36) { g in
            castShadow(&g, -90, 3, length: 150)
            castShadow(&g, 100, 3, length: 200)
            Art.group(&g, x: -98, y: 0) { m in
                snowmobile(&m)
            }
            Art.group(&g, x: 100, y: 0) { s in
                qamutiik(&s)
            }
        }
        softDrift(&v, x0: 30, x1: 250, baseY: Hv + 112, height: 14)
        softDrift(&v, x0: 290, x1: 450, baseY: Hv + 138, height: 12)
        let sparkle = CGRect(x: 0, y: Hv + 40, width: 892, height: 130)
        Kit.flecks(&v, in: sparkle, count: 26, seed: 29, color: Color.white, radius: 0.7...1.5)
    }

    /// The half-built house: the wall climbs round in a spiral, low at one end. Grandfather
    /// stands inside setting the next block on the low end; Elisapie presses soft snow into
    /// the gaps from outside.
    static func spiralSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let d = Dome(cx: 660, baseY: Hv + 70, radius: 165, rise: 150)
        castShadow(&n, 700, Hv + 86, length: 330, alpha: 0.36)
        snowWallBack(&n, d, courses: 2)
        Art.group(&n, x: 668, y: Hv + 86) { g in
            grandfather(&g, pose: .carry, look: CGPoint(x: -0.6, y: 0.5), mouth: .smile)
        }
        // His snow knife, stuck in the top of the wall beside him.
        Art.group(&n, x: 774, y: Hv - 32, rotate: CGFloat.pi + 0.08) { k in
            snowKnife(&k, length: 46)
        }
        snowWall(&n, d, courses: 2, blockLength: 58)
        // The next block, going down on the low end of the slope.
        Kit.snowBlock(&n, x: 580, baseY: Hv + 9, width: 54, height: 24, tilt: -0.1)
        // Spare blocks and the saw, waiting outside.
        castShadow(&n, 530, Hv + 106, length: 70, alpha: 0.26)
        Kit.snowBlock(&n, x: 500, baseY: Hv + 102, width: 56, height: 30)
        Kit.snowBlock(&n, x: 548, baseY: Hv + 108, width: 50, height: 28, tilt: 0.12)
        Art.group(&n, x: 478, y: Hv + 78, rotate: CGFloat.pi - 0.12) { s in
            woodSaw(&s, length: 26)
        }
        // Elisapie, patting snow into a seam with both mitts, the tip of her tongue out.
        castShadow(&n, 814, Hv + 100, length: 60)
        crumbHeap(&n, cx: 850, baseY: Hv + 98, width: 46, seed: 33)
        var pat = Path()
        pat.addEllipse(in: CGRect(x: 772, y: Hv + 22, width: 24, height: 18))
        pat.addEllipse(in: CGRect(x: 766, y: Hv + 33, width: 13, height: 10))
        Art.fill(&n, pat, Color.white)
        Art.stroke(&n, Art.line(770, Hv + 21, 778, Hv + 17), Art.color(snowLine, 0.6), width: 1.2)
        Art.group(&n, x: 812, y: Hv + 98) { g in
            elisapie(&g, pose: .carry, look: CGPoint(x: -0.6, y: 0.1), mouth: .smile, tongue: true)
        }
    }
}

// MARK: - Scene 4 (unfolded): the house at night

extension SnowHouseArt {
    static func nightScene(_ context: inout GraphicsContext, _ size: CGSize) {
        let st = Kit.stage(size, ground: 170)
        let light = dusk()
        let w: CGFloat = size.width
        Kit.sky(&context, size, horizon: st.H, light: light)
        // The sun has only just dipped: a band of peach and cream lies along the horizon.
        flatGlow(&context, 150, st.H - 4, rx: 270 * st.far, ry: 62 * st.far, color: Art.color(0xFFDDB0), alpha: 0.6)
        Kit.cloud(&context, 730, st.H * 0.22, scale: 0.8 * st.far, color: Art.color(0xFFFFFF, 0.42))
        let hills: [(CGFloat, CGFloat, CGFloat)] = [(0.02, 0.3, 22), (0.44, 0.72, 26)]
        farLand(&context, width: w, horizon: st.H, scale: st.far, light: light, hills: hills, seed: 34)
        Kit.ground(&context, width: w, top: st.H, bottom: size.height, stops: snowStops(dusk: true), seed: 74)
        iceBand(&context, x0: 20, x1: 640, y: st.H + 14 * st.far, depth: 20 * st.far, dusk: true)
        Kit.designSpace(&context, st) { v in
            let Hv: CGFloat = st.Hv
            windRipples(&v, x0: 0, x1: 892, y0: Hv + 30, y1: Hv + 170, count: 30, seed: 35)
            softDrift(&v, x0: 40, x1: 280, baseY: Hv + 96, height: 14)
            softDrift(&v, x0: 270, x1: 450, baseY: Hv + 136, height: 12)
            Kit.nearSpace(&v, st, anchorX: 680) { n in
                nightSubject(&n, st)
            }
            tallFill(&v, st, seed: 41)
            Kit.drift(&v, x0: -90, x1: 290, baseY: st.hv + 4, height: 36, bottom: st.hv + 8, snow: true)
            nearBank(&v, x0: 610, x1: 990, baseY: st.hv + 6, height: 42)
        }
        ArtStyle.finish(&context, size, wash: 0.06, vignette: 0.1)
    }

    /// The finished house, glowing gold from the lamp inside; the qamutiik beside it, the
    /// snowmobile behind, the knife and a spare block by the door, footprints in the snow.
    static func nightSubject(_ n: inout GraphicsContext, _ st: Kit.Stage) {
        let Hv: CGFloat = st.Hv
        let d = Dome(cx: 640, baseY: Hv + 62, radius: 150, rise: 140)
        Art.group(&n, x: 838, y: Hv + 36, scale: 0.6) { m in
            castShadow(&m, 0, 3, length: 150, alpha: 0.2)
            snowmobile(&m)
        }
        castShadow(&n, 670, Hv + 80, length: 290, alpha: 0.2)
        snowDome(&n, d, glow: true, blockLength: 54)
        // Footprints from the door.
        var prints = Path()
        let steps: [(CGFloat, CGFloat)] = [(548, 92), (530, 100), (508, 104), (488, 114), (462, 118)]
        for step in steps {
            prints.addEllipse(in: CGRect(x: step.0 - 5, y: Hv + step.1 - 2.4, width: 10, height: 4.8))
        }
        Art.fill(&n, prints, Art.color(snowLine, 0.55))
        Kit.snowBlock(&n, x: 612, baseY: Hv + 98, width: 50, height: 28, tilt: 0.04)
        Art.group(&n, x: 526, y: Hv + 56, rotate: CGFloat.pi + 0.1) { k in
            snowKnife(&k, length: 40)
        }
        // The sled rests beside the house, its near side catching the lamplight.
        castShadow(&n, 810, Hv + 80, length: 150, alpha: 0.22)
        Art.group(&n, x: 806, y: Hv + 78, scale: 0.72) { s in
            qamutiik(&s)
        }
        flatGlow(&n, 740, Hv + 60, rx: 60, ry: 30, color: Art.color(0xFFC766), alpha: 0.22)
    }
}