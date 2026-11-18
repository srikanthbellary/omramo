import SwiftUI
import UIKit
import OmramoCore

// Pictures for stories, cards and landmarks.
//
// CONCEPT ART — the pictures are drawn in code (`JatakaArt`, `AnansiArt`, `UrashimaArt`,
// `LandmarkArt`, and from round 5 one painter a story under `Art/Stories/`, composed from the
// shared kit in `Art/Kit/`), ported and extended from the locked design sources. They are our own work,
// not final illustration: every `review.art` field stays `pending`.
//
// TODO(art): replace with commissioned illustrations (content milestone C1). When an image
// file named by an `ArtRef` exists in the content folder, `StoryArt` loads it and the code
// drawing is not used, so art can be dropped in file by file with no code change
// (see Content/ART_PLACEHOLDERS.md).

// MARK: - Real art, when present

@MainActor
enum StoryArt {
    private static var cache: [String: UIImage] = [:]
    private static var misses: Set<String> = []

    /// The image for a story's art reference, or nil while it is still drawn in code.
    /// TODO(M6): decode off the main thread and downsample to the displayed size.
    static func image(storyID: StoryID, art: ArtRef) -> UIImage? {
        guard let root = BundledContent.rootURL else { return nil }
        let url = root
            .appendingPathComponent("stories")
            .appendingPathComponent(storyID.rawValue)
            .appendingPathComponent(art.file)
        return image(atPath: url.path)
    }

    /// The image for a landmark's art reference (`landmarks/<file>`), or nil.
    static func landmarkImage(art: ArtRef) -> UIImage? {
        guard let root = BundledContent.rootURL else { return nil }
        let url = root
            .appendingPathComponent("landmarks")
            .appendingPathComponent(art.file)
        return image(atPath: url.path)
    }

    private static func image(atPath path: String) -> UIImage? {
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

// MARK: - Which painter draws what

/// Where a picture belongs: a story's own folder or the shared landmark catalog.
enum ArtSource: Hashable {
    case story(StoryID)
    case landmark
}

enum ArtLibrary {
    /// The art registry: the painter of each story, by story id. A story that is not here yet
    /// (text added before its art) gets the calm stand-in for every picture; nothing crashes.
    /// Add one line per story (docs/agent-runs/r5-batch-notes.md).
    static func storyPainter(for storyID: String) -> ArtPainter? {
        switch storyID {
        // Rounds 2–4: the three prototypes.
        case "monkey-and-crocodile": return JatakaArt.paint(_:role:in:size:)
        case "anansi-wisdom": return AnansiArt.paint(_:role:in:size:)
        case "urashima-taro": return UrashimaArt.paint(_:role:in:size:)
        // Round 5, batch 1: the Low stories.
        case "shipwrecked-sailor": return SailorArt.paint(_:role:in:size:)
        case "tongue-cut-sparrow": return SparrowArt.paint(_:role:in:size:)
        case "old-man-who-moved-mountains": return MountainsArt.paint(_:role:in:size:)
        case "why-possums-tail-is-bare": return PossumArt.paint(_:role:in:size:)
        case "the-snow-house": return SnowHouseArt.paint(_:role:in:size:)
        case "peasant-and-bear": return PeasantBearArt.paint(_:role:in:size:)
        case "bremen-town-musicians": return BremenArt.paint(_:role:in:size:)
        case "north-wind-and-sun": return WindSunArt.paint(_:role:in:size:)
        case "why-sun-and-moon-live-in-sky": return SunMoonArt.paint(_:role:in:size:)
        case "lion-and-hare": return LionHareArt.paint(_:role:in:size:)
        // Round 5, batch 2: the Medium stories.
        case "tiger-brahman-jackal": return TigerArt.paint(_:role:in:size:)
        case "khufu-and-the-magician": return KhufuArt.paint(_:role:in:size:)
        case "bamboo-cutter-and-moon-child": return MoonChildArt.paint(_:role:in:size:)
        case "herd-boy-and-weaving-maiden": return WeaverArt.paint(_:role:in:size:)
        case "iktomi-and-the-muskrat": return IktomiArt.paint(_:role:in:size:)
        case "long-day-at-fish-camp": return FishCampArt.paint(_:role:in:size:)
        case "sadko": return SadkoArt.paint(_:role:in:size:)
        case "androcles-and-the-lion": return AndroclesArt.paint(_:role:in:size:)
        case "horse-and-the-olive": return OliveArt.paint(_:role:in:size:)
        case "sindbad-second-voyage": return SindbadArt.paint(_:role:in:size:)
        default: return nil
        }
    }

    /// True when a painter is registered for the story.
    static func hasPainter(for storyID: StoryID) -> Bool {
        storyPainter(for: storyID.rawValue) != nil
    }

    /// Draws `name` for `source` in the role's units. Returns false when no painter knows it.
    static func paint(_ name: String, source: ArtSource, role: ArtRole, in context: inout GraphicsContext, size: CGSize) -> Bool {
        switch source {
        case .landmark:
            return LandmarkArt.paint(name, role: role, in: &context, size: size)
        case .story(let id):
            guard let painter = storyPainter(for: id.rawValue) else { return false }
            return painter(name, role, &context, size)
        }
    }

    /// A calm stand-in for a picture no painter knows (a story added before its art): the
    /// content's own colours, top to bottom, with a soft light. Never a blank rectangle.
    static func paintStandIn(colors: [Color], in context: inout GraphicsContext, size: CGSize) {
        let top = colors.first ?? Art.color(0xE8E4FF)
        let middle = colors.count > 1 ? colors[1] : top
        let bottom = colors.count > 2 ? colors[2] : middle
        let stops: [(Color, CGFloat)] = [(top, 0), (middle, 0.62), (bottom, 1)]
        Art.fillLinear(
            &context,
            Art.rect(0, 0, size.width, size.height),
            stops,
            from: CGPoint(x: 0, y: 0),
            to: CGPoint(x: 0, y: size.height)
        )
        Art.glow(&context, size.width * 0.3, size.height * 0.62, size.width * 0.45, Color.white, alpha: 0.35)
    }
}

/// One picture drawn in code. Equatable, so SwiftUI redraws it only when the picture changes —
/// not on every change of reader state.
struct CodeArtView: View, Equatable {
    let name: String
    let source: ArtSource
    let role: ArtRole
    /// Content colours for the stand-in (`#RRGGBB`).
    var colors: [String] = []

    var body: some View {
        let name = self.name
        let source = self.source
        let standIn = colors.map { Art.color(string: $0, fallback: 0xE8E4FF) }
        ArtCanvas(name: name, role: role) { name, role, context, size in
            if ArtLibrary.paint(name, source: source, role: role, in: &context, size: size) {
                return true
            }
            ArtLibrary.paintStandIn(colors: standIn, in: &context, size: size)
            return true
        }
    }
}

// MARK: - Caching

extension View {
    /// Flattens a code-drawn picture and its grain into one off-screen image. A page turn, a
    /// card reveal or the library-to-story transition then moves and fades that image; the
    /// `Canvas` is not drawn again and the soft-light grain is not blended again every frame
    /// (docs/ART_DIRECTION.md §8).
    func cachedArt() -> some View {
        // Not opaque: a portrait is drawn over its card's gradient, and a scene over its ground.
        drawingGroup()
    }
}

// MARK: - Scenes

/// A reading scene. Unfolded it is one picture under both panes and the hinge; folded it is the
/// picture band at the top of the pane.
struct SceneArtView: View {
    let storyID: StoryID
    let art: ArtRef
    let role: ArtRole
    let fallbackColors: [String]

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
                CodeArtView(name: art.assetName, source: .story(storyID), role: role, colors: fallbackColors)
                    .equatable()
                    // The designs lay a fine grain over every scene so flat shapes feel painted.
                    .overlay(GrainOverlay(opacity: 0.28))
                    .cachedArt()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: art.alt))
        .accessibilityAddTraits(.isImage)
    }
}

/// The wavy lower edge of the folded picture band (screen 10).
struct WaveEdge: Shape {
    /// Height of the wave, crest to trough.
    var amplitude: CGFloat
    /// Number of waves across the width.
    var waves: CGFloat = 2.5
    /// Where the wave starts, as a fraction of one wave.
    var phase: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        let base = rect.maxY - amplitude
        let steps = 48
        for step in 0...steps {
            let t = CGFloat(step) / CGFloat(steps)
            let x = rect.maxX - rect.width * t
            let angle = (t * waves + phase) * 2 * CGFloat.pi
            let y = base + amplitude * 0.5 * (1 + sin(angle))
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Covers

/// A story's cover: full-bleed, no title baked in (§5.13).
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
                CodeArtView(
                    name: story.cover.assetName,
                    source: .story(story.id),
                    role: .cover,
                    colors: story.spreads.first?.scene.fallbackColors ?? []
                )
                .equatable()
                .overlay(GrainOverlay(opacity: 0.22))
                .cachedArt()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: story.cover.alt))
        .accessibilityAddTraits(.isImage)
    }
}

// MARK: - Card pictures

/// A tap-to-see, landmark or character-card picture.
struct CardArtView: View {
    let art: ArtRef
    let source: ArtSource
    /// `.picture` or `.portrait`.
    let role: ArtRole
    /// The card's own colours, for the stand-in.
    var colors: [String] = []

    private var fileImage: UIImage? {
        switch source {
        case .story(let id): return StoryArt.image(storyID: id, art: art)
        case .landmark: return StoryArt.landmarkImage(art: art)
        }
    }

    var body: some View {
        Group {
            if let image = fileImage {
                Color.clear
                    .overlay {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
            } else {
                CodeArtView(name: art.assetName, source: source, role: role, colors: colors)
                    .equatable()
                    .overlay(GrainOverlay(opacity: 0.22))
                    .cachedArt()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: art.alt))
        .accessibilityAddTraits(.isImage)
    }
}

// MARK: - Face chips

/// The small face that sits in the text where a voice starts (§4.3). Rendered to an image so
/// it can flow inline with the words.
@MainActor
enum FaceChipRenderer {
    private static var chips: [String: UIImage] = [:]
    private static var faces: [String: UIImage] = [:]
    /// Pixel side of the cached face drawing.
    private static let faceSide: CGFloat = 96

    /// The character's face as a square image: the delivered file, else the code drawing.
    static func face(for character: StoryCharacter, storyID: StoryID) -> UIImage? {
        if let image = StoryArt.image(storyID: storyID, art: character.face) {
            return image
        }
        let key = storyID.rawValue + "|" + character.face.assetName
        if let cached = faces[key] { return cached }
        let renderer = ImageRenderer(
            content: CodeArtView(
                name: character.face.assetName,
                source: .story(storyID),
                role: .face,
                colors: [character.chipBackground ?? "#FFFFFF"]
            )
            .frame(width: faceSide, height: faceSide)
        )
        renderer.scale = 2
        guard let image = renderer.uiImage else { return nil }
        faces[key] = image
        return image
    }

    /// - Parameter em: the font size of the surrounding text, in points.
    static func image(for character: StoryCharacter, storyID: StoryID, em: CGFloat) -> UIImage {
        let key = "\(storyID.rawValue)|\(character.id.rawValue)|\(character.color)|\(character.chipBackground ?? "")|\(Int((em * 10).rounded()))"
        if let cached = chips[key] { return cached }

        let diameter = em * CGFloat(ReadingTypeScale.faceChipSizeEm)
        let leading = em * CGFloat(ReadingTypeScale.faceChipLeadingEm)
        let trailing = em * CGFloat(ReadingTypeScale.faceChipTrailingEm)
        let ring = CGFloat(ReadingTypeScale.faceChipRing)
        let size = CGSize(width: leading + diameter + trailing, height: diameter)
        let voice = UIColor(rgba: RGBA(string: character.color) ?? Tokens.Palette.ink)
        let background = UIColor(rgba: character.chipBackground.flatMap { RGBA(string: $0) } ?? RGBA(hex: 0xFFFFFF))
        let face = FaceChipRenderer.face(for: character, storyID: storyID)

        let image = UIGraphicsImageRenderer(size: size).image { rendererContext in
            let context = rendererContext.cgContext
            let circle = CGRect(x: leading, y: 0, width: diameter, height: diameter).insetBy(dx: ring / 2, dy: ring / 2)

            context.saveGState()
            context.addEllipse(in: circle)
            context.clip()
            background.setFill()
            context.fill(circle)
            if let face {
                face.draw(in: circle)
            } else {
                // No drawing available: a plain head in the voice colour.
                voice.setFill()
                context.fillEllipse(in: CGRect(
                    x: circle.minX + circle.width * 0.14,
                    y: circle.minY + circle.height * 0.30,
                    width: circle.width * 0.72,
                    height: circle.height * 0.80
                ))
            }
            context.restoreGState()

            voice.setStroke()
            context.setLineWidth(ring)
            context.strokeEllipse(in: circle)
        }
        chips[key] = image
        return image
    }
}
