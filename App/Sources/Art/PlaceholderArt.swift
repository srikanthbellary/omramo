import SwiftUI
import UIKit
import OmramoCore

// PLACEHOLDER ART — everything in this file is temporary.
//
// M1 ships no illustrations. Story JSON names image files that do not exist yet (see
// Content/ART_PLACEHOLDERS.md); until they are delivered, the app draws simple shapes and
// gradients here, keyed by the art reference's asset name ("scene-river", "cover", …).
//
// TODO(art): replace with real illustrations. When an image file named by an ArtRef exists in
// the content folder, `StoryArt` loads it and the placeholder is not drawn, so art can be
// dropped in file by file with no code change.

// MARK: - Real art, when present

@MainActor
enum StoryArt {
    private static var cache: [String: UIImage] = [:]
    private static var misses: Set<String> = []

    /// The image for a story's art reference, or nil while it is still a placeholder.
    /// TODO(M6): decode off the main thread and downsample to the displayed size.
    static func image(storyID: StoryID, art: ArtRef) -> UIImage? {
        guard let root = BundledContent.rootURL else { return nil }
        let path = root
            .appendingPathComponent("stories")
            .appendingPathComponent(storyID.rawValue)
            .appendingPathComponent(art.file)
            .path
        if let cached = cache[path] { return cached }
        if misses.contains(path) { return nil }
        guard let image = UIImage(contentsOfFile: path) else {
            misses.insert(path)
            return nil
        }
        cache[path] = image
        return image
    }
}

// MARK: - Scenes

/// The placeholder scenes the sample story uses. The raw value is the ArtRef asset name.
enum PlaceholderSceneKind: String {
    /// Morning: the Monkey's tree on the bank, the little Crocodile in the water.
    case river = "scene-river"
    /// Mid-river: the Monkey riding on the Crocodile's back.
    case ride = "scene-ride"
    /// The new tree, the stepping-stone rock and the fruit island.
    case island = "scene-island"
    /// Dusk: the Crocodile lying on the rock.
    case dusk = "scene-dusk"
}

/// One scene drawn across whatever space it is given (the whole canvas when unfolded).
/// `viewport` is the part of the 892 × 720 reference scene to show, aspect-filled.
struct SceneArtView: View {
    let storyID: StoryID
    let art: ArtRef
    let fallbackColors: [String]
    var viewport = CGRect(x: 0, y: 0, width: ReferenceCanvas.unfoldedWidth, height: ReferenceCanvas.paneHeight)

    var body: some View {
        Group {
            if let image = StoryArt.image(storyID: storyID, art: art) {
                Color.clear
                    .overlay {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
            } else {
                PlaceholderScene(
                    kind: PlaceholderSceneKind(rawValue: art.assetName),
                    colors: fallbackColors.map { Color(hex: $0, fallback: Tokens.Palette.cloud) },
                    viewport: viewport
                )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: art.alt))
        .accessibilityAddTraits(.isImage)
    }
}

struct PlaceholderScene: View {
    let kind: PlaceholderSceneKind?
    /// Sky, glow near the horizon, water — the spread's `fallbackColors`.
    let colors: [Color]
    let viewport: CGRect

    var body: some View {
        let kind = self.kind
        let colors = self.colors
        let viewport = self.viewport
        Canvas { context, size in
            guard viewport.width > 0, viewport.height > 0 else { return }
            let scale = max(size.width / viewport.width, size.height / viewport.height)
            context.translateBy(
                x: (size.width - viewport.width * scale) / 2,
                y: (size.height - viewport.height * scale) / 2
            )
            context.scaleBy(x: scale, y: scale)
            context.translateBy(x: -viewport.minX, y: -viewport.minY)
            ScenePainter.paint(kind, colors: colors, in: &context)
        }
    }
}

/// Draws in the coordinates of the 892 × 720 reference canvas. Shapes only; no detail.
enum ScenePainter {
    private static let width: CGFloat = 892
    private static let height: CGFloat = 720
    private static let horizon: CGFloat = 584

    private static let trunk = Color(rgba: RGBA(hex: 0x6B4138))
    private static let leafDark = Color(rgba: RGBA(hex: 0x16695A))
    private static let leafMid = Color(rgba: RGBA(hex: 0x22966A))
    private static let leafLight = Color(rgba: RGBA(hex: 0x52BF72))
    private static let fur = Color(rgba: RGBA(hex: 0xA8643A))
    private static let furLight = Color(rgba: RGBA(hex: 0xF3D2A8))
    private static let crocGreen = Color(rgba: RGBA(hex: 0x4FA65A))
    private static let crocDark = Color(rgba: RGBA(hex: 0x2F7A4A))
    private static let sand = Color(rgba: RGBA(hex: 0xE9D58A))
    private static let grass = Color(rgba: RGBA(hex: 0x5DBB63))
    private static let rock = Color(rgba: RGBA(hex: 0x8C8FA3))

    static func paint(_ kind: PlaceholderSceneKind?, colors: [Color], in context: inout GraphicsContext) {
        let sky = colors.count > 0 ? colors[0] : Color(rgba: RGBA(hex: 0xBDEFE9))
        let glow = colors.count > 1 ? colors[1] : Color(rgba: RGBA(hex: 0xFFF2B5))
        let water = colors.count > 2 ? colors[2] : Color(rgba: RGBA(hex: 0x1596A0))

        // Sky: calm in the upper part (where the text sits), warm toward the horizon.
        context.fill(
            Path(CGRect(x: 0, y: 0, width: width, height: height)),
            with: .linearGradient(
                Gradient(stops: [
                    .init(color: sky, location: 0),
                    .init(color: sky.opacity(0.75), location: 0.45),
                    .init(color: glow, location: 0.8),
                ]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: height)
            )
        )

        // Sun and its glow, low on the leading side.
        let sunCenter = CGPoint(x: 120, y: horizon - 30)
        context.fill(
            Path(ellipseIn: CGRect(x: sunCenter.x - 170, y: sunCenter.y - 170, width: 340, height: 340)),
            with: .radialGradient(
                Gradient(colors: [Color.white.opacity(0.85), glow.opacity(0.4), glow.opacity(0)]),
                center: sunCenter,
                startRadius: 0,
                endRadius: 170
            )
        )
        context.fill(circle(sunCenter, 38), with: .color(Color.white.opacity(0.9)))

        // Far hills.
        context.fill(hills(baseline: horizon - 22, amplitude: 26), with: .color(water.opacity(0.28)))
        context.fill(hills(baseline: horizon - 6, amplitude: 14), with: .color(water.opacity(0.42)))

        // River.
        context.fill(
            Path(CGRect(x: 0, y: horizon, width: width, height: height - horizon)),
            with: .linearGradient(
                Gradient(colors: [water.opacity(0.55), water, water]),
                startPoint: CGPoint(x: 0, y: horizon),
                endPoint: CGPoint(x: 0, y: height)
            )
        )
        for index in 0..<7 {
            let y = horizon + 18 + CGFloat(index) * 17
            let x = 60 + CGFloat((index * 131) % 700)
            context.fill(
                Path(roundedRect: CGRect(x: x, y: y, width: 46 + CGFloat(index % 3) * 18, height: 2.5), cornerRadius: 1.2),
                with: .color(Color.white.opacity(0.35))
            )
        }

        island(at: CGPoint(x: 314, y: horizon + 22), in: &context)

        switch kind {
        case .ride:
            // Mid-river: no bank. The Monkey rides on the Crocodile's back.
            crocodile(at: CGPoint(x: 640, y: horizon + 70), scale: 1.25, in: &context)
            monkey(at: CGPoint(x: 648, y: horizon + 52), scale: 0.95, in: &context)
        case .island:
            bankAndTree(in: &context)
            stone(at: CGPoint(x: 540, y: horizon + 52), in: &context)
            monkey(at: CGPoint(x: 606, y: 300), scale: 1, in: &context)
            crocodile(at: CGPoint(x: 150, y: horizon + 96), scale: 0.5, in: &context)
        case .dusk:
            bankAndTree(in: &context)
            stone(at: CGPoint(x: 540, y: horizon + 52), in: &context)
            crocodile(at: CGPoint(x: 540, y: horizon + 34), scale: 0.8, in: &context)
            monkey(at: CGPoint(x: 700, y: horizon - 2), scale: 0.8, in: &context)
        case .river, .none:
            bankAndTree(in: &context)
            monkey(at: CGPoint(x: 606, y: 300), scale: 1, in: &context)
            crocodile(at: CGPoint(x: 380, y: horizon + 84), scale: 0.5, in: &context)
        }
    }

    private static func circle(_ center: CGPoint, _ radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    }

    private static func hills(baseline: CGFloat, amplitude: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: horizon + 2))
        path.addLine(to: CGPoint(x: 0, y: baseline))
        let step: CGFloat = 148
        var x: CGFloat = 0
        var up = true
        while x < width {
            path.addQuadCurve(
                to: CGPoint(x: x + step, y: baseline),
                control: CGPoint(x: x + step / 2, y: baseline - (up ? amplitude * 2 : amplitude * 0.6))
            )
            x += step
            up.toggle()
        }
        path.addLine(to: CGPoint(x: width, y: horizon + 2))
        path.closeSubpath()
        return path
    }

    private static func island(at center: CGPoint, in context: inout GraphicsContext) {
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - 112, y: center.y - 12, width: 224, height: 30)),
            with: .color(sand)
        )
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - 92, y: center.y - 16, width: 184, height: 24)),
            with: .color(grass)
        )
        for (dx, size) in [(-48.0, 26.0), (0.0, 34.0), (48.0, 24.0)] {
            let base = CGPoint(x: center.x + CGFloat(dx), y: center.y - 8)
            let crown = CGFloat(size)
            context.fill(
                Path(CGRect(x: base.x - 2.5, y: base.y - crown * 1.5, width: 5, height: crown * 1.5)),
                with: .color(trunk)
            )
            let top = CGPoint(x: base.x, y: base.y - crown * 1.7)
            context.fill(circle(top, crown), with: .color(leafMid))
            // The ripe fruit.
            for offset in [CGPoint(x: -8, y: 2), CGPoint(x: 6, y: -6), CGPoint(x: 4, y: 9)] {
                context.fill(
                    circle(CGPoint(x: top.x + offset.x, y: top.y + offset.y), 3.6),
                    with: .color(Color(rgba: RGBA(hex: 0xFF9F1A)))
                )
            }
        }
    }

    /// The near bank with the great tree: trunk on the trailing edge, one long branch reaching
    /// toward the leading pane, canopy across the top of the trailing pane.
    private static func bankAndTree(in context: inout GraphicsContext) {
        var bank = Path()
        bank.move(to: CGPoint(x: 892, y: 470))
        bank.addCurve(
            to: CGPoint(x: 650, y: horizon + 22),
            control1: CGPoint(x: 820, y: 490),
            control2: CGPoint(x: 720, y: 560)
        )
        bank.addCurve(
            to: CGPoint(x: 892, y: 660),
            control1: CGPoint(x: 660, y: horizon + 56),
            control2: CGPoint(x: 800, y: 640)
        )
        bank.closeSubpath()
        context.fill(bank, with: .color(Color(rgba: RGBA(hex: 0x3F9E58))))

        var trunkPath = Path()
        trunkPath.move(to: CGPoint(x: 770, y: horizon - 10))
        trunkPath.addCurve(to: CGPoint(x: 790, y: 150), control1: CGPoint(x: 796, y: 440), control2: CGPoint(x: 806, y: 260))
        trunkPath.addLine(to: CGPoint(x: 880, y: 150))
        trunkPath.addCurve(to: CGPoint(x: 892, y: 540), control1: CGPoint(x: 870, y: 300), control2: CGPoint(x: 868, y: 480))
        trunkPath.addLine(to: CGPoint(x: 892, y: horizon + 20))
        trunkPath.addLine(to: CGPoint(x: 752, y: horizon + 10))
        trunkPath.closeSubpath()
        context.fill(trunkPath, with: .color(trunk))

        var branch = Path()
        branch.move(to: CGPoint(x: 806, y: 330))
        branch.addCurve(to: CGPoint(x: 436, y: 306), control1: CGPoint(x: 700, y: 330), control2: CGPoint(x: 520, y: 320))
        branch.addLine(to: CGPoint(x: 438, y: 298))
        branch.addCurve(to: CGPoint(x: 800, y: 286), control1: CGPoint(x: 540, y: 306), control2: CGPoint(x: 700, y: 304))
        branch.closeSubpath()
        context.fill(branch, with: .color(trunk))

        // Canopy blobs (a subset of the design's banyan canopy positions).
        let blobs: [(CGFloat, CGFloat, CGFloat)] = [
            (835, 60, 95), (720, 50, 80), (610, 78, 70), (520, 60, 62), (440, 46, 50),
            (880, 170, 70), (760, 140, 66), (660, 150, 46), (560, 132, 40), (480, 112, 34),
            (870, 260, 44), (800, 200, 40),
        ]
        for (index, blob) in blobs.enumerated() {
            let color = index % 3 == 0 ? leafDark : (index % 3 == 1 ? leafMid : leafLight.opacity(0.9))
            context.fill(circle(CGPoint(x: blob.0, y: blob.1), blob.2), with: .color(color))
        }
        for blob in [(505.0, 302.0, 24.0), (470.0, 314.0, 20.0), (760.0, 240.0, 28.0)] {
            context.fill(circle(CGPoint(x: blob.0, y: blob.1), CGFloat(blob.2)), with: .color(leafMid))
        }
    }

    private static func stone(at center: CGPoint, in context: inout GraphicsContext) {
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - 74, y: center.y - 26, width: 148, height: 52)),
            with: .color(rock)
        )
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - 60, y: center.y - 26, width: 110, height: 22)),
            with: .color(Color.white.opacity(0.18))
        )
    }

    /// `point` is where the monkey sits (the bottom of its body).
    private static func monkey(at point: CGPoint, scale: CGFloat, in context: inout GraphicsContext) {
        let bodyHeight = 58 * scale
        let body = CGRect(x: point.x - 21 * scale, y: point.y - bodyHeight, width: 42 * scale, height: bodyHeight)
        context.fill(Path(ellipseIn: body), with: .color(fur))
        context.fill(
            Path(ellipseIn: body.insetBy(dx: 9 * scale, dy: 10 * scale).offsetBy(dx: 0, dy: 4 * scale)),
            with: .color(furLight)
        )
        let head = CGPoint(x: point.x, y: point.y - bodyHeight - 22 * scale)
        context.fill(circle(CGPoint(x: head.x - 30 * scale, y: head.y), 10 * scale), with: .color(fur))
        context.fill(circle(CGPoint(x: head.x + 30 * scale, y: head.y), 10 * scale), with: .color(fur))
        context.fill(circle(head, 30 * scale), with: .color(fur))
        context.fill(
            Path(ellipseIn: CGRect(x: head.x - 21 * scale, y: head.y - 14 * scale, width: 42 * scale, height: 36 * scale)),
            with: .color(furLight)
        )
        for dx in [-8.0, 8.0] {
            context.fill(
                circle(CGPoint(x: head.x + CGFloat(dx) * scale, y: head.y - 2 * scale), 3.4 * scale),
                with: .color(Color(rgba: RGBA(hex: 0x2A1408)))
            )
        }
    }

    /// `point` is the middle of the crocodile's back at the water line.
    private static func crocodile(at point: CGPoint, scale: CGFloat, in context: inout GraphicsContext) {
        let length = 210 * scale
        let body = CGRect(x: point.x - length / 2, y: point.y - 16 * scale, width: length, height: 30 * scale)
        context.fill(Path(roundedRect: body, cornerRadius: 15 * scale), with: .color(crocGreen))
        // Back ridges.
        for index in 0..<7 {
            let x = body.minX + 36 * scale + CGFloat(index) * 16 * scale
            var ridge = Path()
            ridge.move(to: CGPoint(x: x, y: body.minY + 2 * scale))
            ridge.addLine(to: CGPoint(x: x + 7 * scale, y: body.minY - 9 * scale))
            ridge.addLine(to: CGPoint(x: x + 14 * scale, y: body.minY + 2 * scale))
            ridge.closeSubpath()
            context.fill(ridge, with: .color(crocDark))
        }
        // Snout, eye and a little white tooth, facing the leading pane (toward the text).
        let snout = CGRect(x: body.minX - 44 * scale, y: point.y - 8 * scale, width: 70 * scale, height: 20 * scale)
        context.fill(Path(roundedRect: snout, cornerRadius: 10 * scale), with: .color(crocGreen))
        let eye = CGPoint(x: body.minX + 16 * scale, y: body.minY - 2 * scale)
        context.fill(circle(eye, 9 * scale), with: .color(crocGreen))
        context.fill(circle(eye, 5 * scale), with: .color(Color(rgba: RGBA(hex: 0xFFF2B5))))
        context.fill(circle(eye, 2.2 * scale), with: .color(Color(rgba: RGBA(hex: 0x16123D))))
        context.fill(
            Path(CGRect(x: snout.minX + 10 * scale, y: snout.maxY - 5 * scale, width: 4 * scale, height: 5 * scale)),
            with: .color(Color.white)
        )
    }
}

// MARK: - Cover

/// Placeholder cover: the story's own scene colours with the ride across the river.
/// Full-bleed, no title baked in (§5.13).
struct CoverArtView: View {
    let story: Story

    var body: some View {
        Group {
            if let image = StoryArt.image(storyID: story.id, art: story.cover) {
                // Fill whatever frame the caller gives, without growing past it.
                Color.clear
                    .overlay {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
            } else {
                PlaceholderScene(
                    kind: .ride,
                    colors: (story.spreads.first?.scene.fallbackColors ?? []).map { Color(hex: $0, fallback: Tokens.Palette.cloud) },
                    viewport: CGRect(x: 480, y: 320, width: 320, height: 400)
                )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: story.cover.alt))
        .accessibilityAddTraits(.isImage)
    }
}

// MARK: - Face chips

/// The small face that sits in the text where a voice starts (§4.3). Rendered to an image so
/// it can flow inline with the words.
@MainActor
enum FaceChipRenderer {
    private static var cache: [String: UIImage] = [:]

    /// - Parameter em: the font size of the surrounding text, in points.
    static func image(for character: StoryCharacter, em: CGFloat) -> UIImage {
        let key = "\(character.id.rawValue)|\(character.color)|\(character.chipBackground ?? "")|\(Int((em * 10).rounded()))"
        if let cached = cache[key] { return cached }

        let diameter = em * CGFloat(ReadingTypeScale.faceChipSizeEm)
        let leading = em * CGFloat(ReadingTypeScale.faceChipLeadingEm)
        let trailing = em * CGFloat(ReadingTypeScale.faceChipTrailingEm)
        let ring = CGFloat(ReadingTypeScale.faceChipRing)
        let size = CGSize(width: leading + diameter + trailing, height: diameter)
        let voice = UIColor(rgba: RGBA(string: character.color) ?? Tokens.Palette.ink)
        let background = UIColor(rgba: character.chipBackground.flatMap { RGBA(string: $0) } ?? RGBA(hex: 0xFFFFFF))

        let image = UIGraphicsImageRenderer(size: size).image { rendererContext in
            let context = rendererContext.cgContext
            let circle = CGRect(x: leading, y: 0, width: diameter, height: diameter).insetBy(dx: ring / 2, dy: ring / 2)

            context.saveGState()
            context.addEllipse(in: circle)
            context.clip()
            background.setFill()
            context.fill(circle)
            // PLACEHOLDER face: a head in the voice colour with two eyes.
            // TODO(art): draw the real face chip (ArtRef `character.face`).
            voice.setFill()
            context.fillEllipse(in: CGRect(
                x: circle.minX + circle.width * 0.14,
                y: circle.minY + circle.height * 0.30,
                width: circle.width * 0.72,
                height: circle.height * 0.80
            ))
            UIColor.white.setFill()
            for offset in [0.36, 0.64] {
                let eye = CGRect(
                    x: circle.minX + circle.width * CGFloat(offset) - circle.width * 0.07,
                    y: circle.minY + circle.height * 0.46,
                    width: circle.width * 0.14,
                    height: circle.width * 0.14
                )
                context.fillEllipse(in: eye)
            }
            context.restoreGState()

            voice.setStroke()
            context.setLineWidth(ring)
            context.strokeEllipse(in: circle)
        }
        cache[key] = image
        return image
    }
}
