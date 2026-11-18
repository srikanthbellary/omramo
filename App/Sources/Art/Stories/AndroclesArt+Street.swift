import SwiftUI
import OmramoCore

// The street's own parts for "Androcles and the Lion" (used by the unfolded street scene in
// `AndroclesArt.swift` and the folded street band in `AndroclesArt+Folded.swift`): windows,
// neighbours, awnings, shop fronts, the fountain, the man and the lion walking together, and
// the near plane of the street scene.

extension AndroclesArt {
    /// A window opening with its two wooden shutters folded back and a stone sill.
    static func streetWindow(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, shutter: UInt32) {
        let hole = Art.rect(x, y, width, height, radius: 1)
        let dark: Kit.Stops = [(Art.color(0x4A3430), 0), (Art.color(0x6B4C40), 1)]
        Art.fillLinear(&context, hole, dark, from: CGPoint(x: 0, y: y), to: CGPoint(x: 0, y: y + height))
        let leaf: CGFloat = width * 0.42
        let left = Art.rect(x - leaf - 1, y, leaf, height, radius: 1)
        let right = Art.rect(x + width + 1, y, leaf, height, radius: 1)
        Kit.solid(&context, left, Art.color(shutter), light: 0.22, shade: 0.16)
        Kit.solid(&context, right, Art.color(shutter), light: 0.22, shade: 0.16)
        var slats = Path()
        var sy: CGFloat = y + 5
        while sy < y + height - 2 {
            slats.move(to: CGPoint(x: x - leaf + 1, y: sy))
            slats.addLine(to: CGPoint(x: x - 3, y: sy))
            slats.move(to: CGPoint(x: x + width + 3, y: sy))
            slats.addLine(to: CGPoint(x: x + width + leaf - 1, y: sy))
            sy += 5
        }
        Art.stroke(&context, slats, Kit.propTone(shutter, 0.7), width: 1)
        let sill = Art.rect(x - 3, y + height, width + 6, 4, radius: 1)
        Kit.solid(&context, sill, Art.color(0xEFE3C8), light: 0.2, shade: 0.14)
    }

    /// A neighbour leaning in a window, one arm out over the sill with a few roses.
    static func windowNeighbour(_ context: inout GraphicsContext, window: CGRect, person: Kit.Person) {
        let hole = Art.rect(window.minX, window.minY, window.width, window.height, radius: 1)
        let s: CGFloat = window.width / 110
        let headY: CGFloat = window.minY + window.height * 0.42
        Art.clipped(&context, to: hole) { g in
            Art.group(&g, x: window.midX, y: headY, scale: s) { b in
                Kit.bust(&b, person, look: CGPoint(x: -0.3, y: 0.6), mouth: .smile)
            }
        }
        var arm = Path()
        arm.move(to: CGPoint(x: window.midX - 4, y: window.maxY - 6))
        arm.addQuadCurve(to: CGPoint(x: window.minX - 6, y: window.maxY + 4), control: CGPoint(x: window.minX, y: window.maxY - 8))
        Art.stroke(&context, arm, Art.color(person.skin), width: 4.2)
        let hx: CGFloat = window.minX - 7
        let hy: CGFloat = window.maxY + 5
        Art.fill(&context, Art.circle(hx, hy, 3), Art.color(person.skin))
        Art.fill(&context, Art.circle(hx - 3, hy + 2, 2.6), Art.color(0xDB5A6E))
        Art.fill(&context, Art.circle(hx + 1, hy + 4, 2.2), Art.color(0xF6B4C2))
    }

    /// A striped cloth awning with a scalloped hem, from `x0` to `x1`, hung at `y`.
    static func streetAwning(_ context: inout GraphicsContext, x0: CGFloat, x1: CGFloat, y: CGFloat, depth: CGFloat) {
        guard x1 > x0 + 8, depth > 0 else { return }
        Art.fill(&context, Art.rect(x0 + 4, y + depth, x1 - x0 - 8, depth * 0.5), ArtStyle.coolShade.opacity(0.12))
        let count: Int = max(3, Int((x1 - x0) / 16))
        let step: CGFloat = (x1 - x0) / CGFloat(count)
        var cloth = Path()
        cloth.move(to: CGPoint(x: x0 + 4, y: y))
        cloth.addLine(to: CGPoint(x: x1 - 4, y: y))
        cloth.addLine(to: CGPoint(x: x1, y: y + depth))
        for i in 0..<count {
            let xa: CGFloat = x1 - step * CGFloat(i + 1)
            let mid: CGFloat = xa + step / 2
            cloth.addQuadCurve(to: CGPoint(x: xa, y: y + depth), control: CGPoint(x: mid, y: y + depth + step * 0.45))
        }
        cloth.closeSubpath()
        Kit.solid(&context, cloth, Art.color(0xF4E6C6), light: 0.2, shade: 0.2)
        Art.clipped(&context, to: cloth) { g in
            var stripes = Path()
            var sx: CGFloat = x0
            while sx < x1 {
                stripes.addRect(CGRect(x: sx, y: y - 2, width: step / 2, height: depth + step))
                sx += step
            }
            Art.fill(&g, stripes, Art.color(0xCB6B4C, 0.85))
            Art.fill(&g, Art.rect(x0, y, x1 - x0, depth * 0.3), ArtStyle.coolShade.opacity(0.08))
        }
    }

    /// An open shop front on the ground floor: the dim inside, a stone counter (round loaves
    /// for the baker, oil jars otherwise) and a striped awning.
    static func streetShop(_ context: inout GraphicsContext, x0: CGFloat, width: CGFloat, base: CGFloat, baker: Bool) {
        let top: CGFloat = base - 66
        let inside: Kit.Stops = [(Art.color(0x5A4038), 0), (Art.color(0x7A5A48), 1)]
        Art.fillLinear(&context, Art.rect(x0, top, width, base - top), inside, from: CGPoint(x: 0, y: top), to: CGPoint(x: 0, y: base))
        Art.stroke(&context, Art.line(x0 + 6, top + 24, x0 + width - 6, top + 24), Art.color(0x8A6450), width: 2.4)
        let counterTop: CGFloat = base - 26
        let counter = Art.rect(x0 - 3, counterTop, width + 6, 26)
        Kit.solid(&context, counter, Art.color(0xE6D6B6), light: 0.26, shade: 0.2)
        Art.stroke(&context, Art.line(x0 - 3, counterTop + 1, x0 + width + 3, counterTop + 1), Art.color(0xFFF6E0, 0.8), width: 1.6)
        if baker {
            let gap: CGFloat = (width - 36) / 3
            for i in 0..<4 {
                let lx: CGFloat = x0 + 18 + CGFloat(i) * gap
                loaf(&context, x: lx, y: counterTop - 3, r: 11)
            }
            let shelf: Int = width > 100 ? 3 : 2
            for i in 0..<shelf {
                let lx: CGFloat = x0 + 22 + CGFloat(i) * 30
                loaf(&context, x: lx, y: top + 20, r: 8)
            }
        } else {
            for i in 0..<3 {
                let px: CGFloat = x0 + 24 + CGFloat(i) * 34
                Kit.pot(&context, cx: px, baseY: counterTop, width: 16, height: 26, color: 0xB5683A)
            }
        }
        streetAwning(&context, x0: x0 - 8, x1: x0 + width + 8, y: top - 6, depth: 18)
    }

    /// The small stone fountain: a slab with a bronze spout and a basin, standing on baseY.
    static func streetFountain(_ context: inout GraphicsContext, x: CGFloat, baseY: CGFloat) {
        let stone: UInt32 = 0xE9DCC0
        let bronze = Art.color(0xA07A3C)
        Kit.shadow(&context, x, baseY, width: 84)
        let slab = Art.rect(x - 15, baseY - 74, 30, 60, radius: 3)
        Kit.solid(&context, slab, Art.color(stone), light: 0.26, shade: 0.2, rim: 1.6)
        let cap = Art.rect(x - 18, baseY - 78, 36, 7, radius: 2)
        Kit.solid(&context, cap, Art.color(0xF2E8D2), light: 0.2, shade: 0.16)
        Art.fill(&context, Art.circle(x, baseY - 52, 5), bronze)
        Art.stroke(&context, Art.line(x, baseY - 52, x - 9, baseY - 50), bronze, width: 3.4)
        var jet = Path()
        jet.move(to: CGPoint(x: x - 10, y: baseY - 50))
        jet.addQuadCurve(to: CGPoint(x: x - 18, y: baseY - 25), control: CGPoint(x: x - 18, y: baseY - 48))
        Art.stroke(&context, jet, Art.color(0xCFE8F2, 0.9), width: 2.4)
        let basin = Kit.placed("M-40,-26 L40,-26 L36,-3 C35,-1 32,0 28,0 L-28,0 C-32,0 -35,-1 -36,-3Z", x: x, y: baseY)
        Kit.solid(&context, basin, Art.color(stone), light: 0.28, shade: 0.22, rim: 2)
        Art.fill(&context, Art.ellipse(x, baseY - 26, 39, 3.6), Art.color(0x9CC9E0))
        Art.fill(&context, Art.ellipse(x - 8, baseY - 26.6, 22, 1.4), Art.color(0xFFFFFF, 0.5))
        Kit.ripples(&context, x - 18, baseY - 27, 10, count: 1, color: Color.white, opacity: 0.6)
    }

    /// Androcles in his clean tunic and sandals walking LEFT behind the Lion, who goes ahead
    /// with petals in his mane; the thin leash hangs slack from the man's hand to the lion's
    /// neck. Origin on the ground under the lion; the man walks at x +150. No collar, no chain.
    static func streetPair(_ context: inout GraphicsContext) {
        let body = lionBodyLook()
        let hc: CGPoint = Kit.beastHeadCentre(body, pose: .walk)
        let p = androclesLook(clean: true)
        let hand: CGPoint = Kit.hand(p, pose: .walk)
        let manX: CGFloat = 150
        Kit.shadow(&context, 4, 0, width: 150)
        Kit.shadow(&context, manX, 0, width: 64)
        lion(&context, pose: .walk, mood: .happy, look: CGPoint(x: -0.5, y: 0), petals: true)
        Art.group(&context, x: manX, y: 0) { g in
            androcles(&g, pose: .walk, look: CGPoint(x: -0.6, y: 0.2), mouth: .smile, clean: true)
            sandals(&g)
        }
        let from = CGPoint(x: manX + hand.x, y: hand.y)
        let to = CGPoint(x: hc.x + 22, y: hc.y + 30)
        let sag: CGFloat = max(from.y, to.y) + 34
        var leash = Path()
        leash.move(to: from)
        leash.addQuadCurve(to: to, control: CGPoint(x: (from.x + to.x) / 2, y: sag))
        Art.stroke(&context, leash, Art.color(0xA33A2E), width: 1.8)
        // A soft loop of the same ribbon round the neck, lost in the mane.
        Art.stroke(&context, Art.ellipse(to.x - 4, to.y, 7, 4), Art.color(0xA33A2E, 0.8), width: 1.6)
    }

    /// Simple leather sandals under the walking feet (in the person's own units).
    static func sandals(_ context: inout GraphicsContext) {
        let leather = Art.color(0x7A4E2E)
        var soles = Path()
        soles.move(to: CGPoint(x: -34, y: -1))
        soles.addLine(to: CGPoint(x: -18, y: -1))
        soles.move(to: CGPoint(x: 12, y: -2))
        soles.addLine(to: CGPoint(x: 28, y: -2))
        Art.stroke(&context, soles, leather, width: 2.6)
        let straps = Art.svg("M-24,-1 L-21,-8 M-29,-1 L-25,-5 M22,-2 L25,-9 M17,-2 L20,-6")
        Art.stroke(&context, straps, leather, width: 1.4)
    }

    /// Near framing, petals on the stones, and the deeper foreground of a tall window.
    static func streetNear(_ context: inout GraphicsContext, _ st: Kit.Stage) {
        let floor: CGFloat = st.h
        let lying = CGRect(x: 20, y: st.H + 16, width: 860, height: max(10, st.depth - 40))
        petals(&context, in: lying, count: 40, seed: 62)
        Kit.cornerLeaves(&context, size: st.size, corner: 2, color: Art.color(0x5E6B3E), scale: 0.9, seed: 9)
        if st.tall > 0.25 {
            Kit.pot(&context, cx: 330, baseY: floor - 60, width: 70, height: 84, color: tileHex)
            Kit.grassTuft(&context, x: 330, baseY: floor - 140, height: 40, color: 0x5E6B3E, seed: 64)
            Kit.flowers(&context, in: CGRect(x: 300, y: floor - 160, width: 60, height: 24), count: 6, seed: 63, petal: 0xDB5A6E)
            petals(&context, in: CGRect(x: 20, y: floor - 260, width: 860, height: 220), count: 30, seed: 65)
            Kit.flecks(&context, in: CGRect(x: 0, y: st.H + 60, width: 892, height: st.depth - 70), count: 50, seed: 66, color: Art.color(0xFFFFFF, 0.35), radius: 0.8...1.8)
        }
    }
}
