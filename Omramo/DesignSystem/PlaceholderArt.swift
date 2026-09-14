import SwiftUI
import OmramoCore

/// Procedural stand in for illustrations. Draws a gradient plus a motif so
/// every poster and page has distinct art without shipping image binaries.
/// When `artwork.assetName` is set, the real image is shown instead.
struct PlaceholderArt: View {
    let artwork: Artwork
    var cornerRadius: CGFloat = 12

    var body: some View {
        Group {
            if let assetName = artwork.assetName, UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: artwork.swiftUIColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    MotifCanvas(motif: artwork.motif, tint: artwork.swiftUIColors.last ?? .white)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityLabel(Text("Illustration: \(artwork.motif.rawValue)"))
    }
}

/// Deterministic shapes per motif so the same page always looks the same.
private struct MotifCanvas: View {
    let motif: Artwork.Motif
    let tint: Color

    var body: some View {
        Canvas { context, size in
            var generator = SeededGenerator(seed: UInt64(motif.rawValue.unicodeScalars.reduce(7) { $0 &* 31 &+ UInt64($1.value) }))
            let stroke = tint.opacity(0.85)
            let fill = tint.opacity(0.55)
            let w = size.width
            let h = size.height

            switch motif {
            case .river, .monsoon:
                let lines = motif == .river ? 5 : 12
                for index in 0..<lines {
                    var path = Path()
                    let y = h * (0.35 + 0.55 * Double(index) / Double(lines))
                    path.move(to: CGPoint(x: 0, y: y))
                    var x: CGFloat = 0
                    while x < w {
                        let amp = motif == .river ? h * 0.03 : h * 0.004
                        path.addQuadCurve(
                            to: CGPoint(x: x + w * 0.25, y: y),
                            control: CGPoint(x: x + w * 0.125, y: y - amp * (index.isMultiple(of: 2) ? 1 : -1))
                        )
                        x += w * 0.25
                    }
                    context.stroke(path, with: .color(stroke), lineWidth: motif == .river ? 2.5 : 1)
                }
            case .stars:
                for _ in 0..<40 {
                    let point = CGPoint(x: CGFloat.random(in: 0...w, using: &generator), y: CGFloat.random(in: 0...h * 0.8, using: &generator))
                    let radius = CGFloat.random(in: 0.8...2.6, using: &generator)
                    context.fill(Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)), with: .color(stroke))
                }
                context.fill(Path(ellipseIn: CGRect(x: w * 0.68, y: h * 0.14, width: w * 0.12, height: w * 0.12)), with: .color(fill))
            case .temple:
                var path = Path()
                path.move(to: CGPoint(x: w * 0.25, y: h * 0.85))
                path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.35))
                path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.18))
                path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.35))
                path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.85))
                path.closeSubpath()
                context.fill(path, with: .color(fill))
                context.stroke(Path(CGRect(x: w * 0.2, y: h * 0.85, width: w * 0.6, height: h * 0.04)), with: .color(stroke), lineWidth: 2)
            case .boat:
                var hull = Path()
                hull.move(to: CGPoint(x: w * 0.2, y: h * 0.62))
                hull.addQuadCurve(to: CGPoint(x: w * 0.8, y: h * 0.62), control: CGPoint(x: w * 0.5, y: h * 0.82))
                hull.addLine(to: CGPoint(x: w * 0.72, y: h * 0.56))
                hull.addLine(to: CGPoint(x: w * 0.28, y: h * 0.56))
                hull.closeSubpath()
                context.fill(hull, with: .color(fill))
                var sail = Path()
                sail.move(to: CGPoint(x: w * 0.5, y: h * 0.54))
                sail.addLine(to: CGPoint(x: w * 0.5, y: h * 0.2))
                sail.addLine(to: CGPoint(x: w * 0.68, y: h * 0.5))
                sail.closeSubpath()
                context.fill(sail, with: .color(stroke))
            case .forest:
                for index in 0..<7 {
                    let x = w * (0.1 + 0.13 * Double(index))
                    let height = h * CGFloat.random(in: 0.25...0.5, using: &generator)
                    var tree = Path()
                    tree.move(to: CGPoint(x: x - w * 0.06, y: h * 0.85))
                    tree.addLine(to: CGPoint(x: x, y: h * 0.85 - height))
                    tree.addLine(to: CGPoint(x: x + w * 0.06, y: h * 0.85))
                    tree.closeSubpath()
                    context.fill(tree, with: .color(index.isMultiple(of: 2) ? fill : stroke))
                }
            case .lantern:
                let center = CGPoint(x: w * 0.5, y: h * 0.45)
                for ring in stride(from: 4, through: 1, by: -1) {
                    let radius = w * 0.09 * CGFloat(ring)
                    context.fill(Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)), with: .color(tint.opacity(0.12)))
                }
                context.fill(Path(ellipseIn: CGRect(x: center.x - w * 0.07, y: center.y - w * 0.07, width: w * 0.14, height: w * 0.14)), with: .color(stroke))
            case .map:
                for index in 1..<6 {
                    let offset = CGFloat(index) / 6
                    context.stroke(Path { $0.move(to: CGPoint(x: w * offset, y: 0)); $0.addLine(to: CGPoint(x: w * offset, y: h)) }, with: .color(tint.opacity(0.18)), lineWidth: 1)
                    context.stroke(Path { $0.move(to: CGPoint(x: 0, y: h * offset)); $0.addLine(to: CGPoint(x: w, y: h * offset)) }, with: .color(tint.opacity(0.18)), lineWidth: 1)
                }
                var route = Path()
                route.move(to: CGPoint(x: w * 0.15, y: h * 0.8))
                route.addCurve(to: CGPoint(x: w * 0.8, y: h * 0.25), control1: CGPoint(x: w * 0.2, y: h * 0.3), control2: CGPoint(x: w * 0.7, y: h * 0.7))
                context.stroke(route, with: .color(stroke), style: StrokeStyle(lineWidth: 2.5, dash: [6, 5]))
                context.fill(Path(ellipseIn: CGRect(x: w * 0.8 - 5, y: h * 0.25 - 5, width: 10, height: 10)), with: .color(stroke))
            case .village:
                for index in 0..<4 {
                    let x = w * (0.12 + 0.22 * Double(index))
                    let base = h * 0.8
                    var house = Path()
                    house.addRect(CGRect(x: x, y: base - h * 0.14, width: w * 0.14, height: h * 0.14))
                    house.move(to: CGPoint(x: x - w * 0.02, y: base - h * 0.14))
                    house.addLine(to: CGPoint(x: x + w * 0.07, y: base - h * 0.26))
                    house.addLine(to: CGPoint(x: x + w * 0.16, y: base - h * 0.14))
                    house.closeSubpath()
                    context.fill(house, with: .color(index.isMultiple(of: 2) ? fill : stroke))
                }
            case .festival:
                for _ in 0..<18 {
                    let point = CGPoint(x: CGFloat.random(in: 0...w, using: &generator), y: CGFloat.random(in: 0...h, using: &generator))
                    let radius = CGFloat.random(in: 3...9, using: &generator)
                    context.stroke(Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)), with: .color(stroke), lineWidth: 1.5)
                }
            }
        }
    }
}

/// Tiny xorshift generator so placeholder art is stable across launches.
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

#Preview("Motifs") {
    let motifs = Artwork.Motif.allCases
    return ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
            ForEach(motifs, id: \.self) { motif in
                PlaceholderArt(artwork: Artwork(motif: motif, colors: [HexColor("#0B2E4F")!, HexColor("#1F7A8C")!, HexColor("#F4A259")!]))
                    .aspectRatio(2 / 3, contentMode: .fit)
                    .overlay(alignment: .bottom) {
                        Text(motif.rawValue).font(.caption).padding(4).background(.thinMaterial)
                    }
            }
        }
        .padding()
    }
}
