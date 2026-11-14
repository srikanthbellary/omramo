import Foundation

/// The curve of a `pathText` block (text on a path, docs/DESIGN.md §4.3): SVG path data limited
/// to the absolute commands M, L, Q and C, in the block's 400 × 96 box. One open curve.
/// `tools/validate_content.py` (`parse_path`) accepts exactly the same strings.
public struct SVGPath: Equatable, Hashable, Sendable {
    public struct Point: Equatable, Hashable, Sendable {
        public var x: Double
        public var y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    public enum Segment: Equatable, Hashable, Sendable {
        case line(to: Point)
        case quad(control: Point, to: Point)
        case cubic(control1: Point, control2: Point, to: Point)
    }

    /// The box the designs draw a path block in.
    public static let boxWidth: Double = 400
    public static let boxHeight: Double = 96

    public var start: Point
    public var segments: [Segment]

    /// Nil when the text is not a path of the supported kind.
    public init?(string: String) {
        var tokens: [String] = []
        var number = ""
        func flush() {
            if !number.isEmpty {
                tokens.append(number)
                number = ""
            }
        }
        for character in string {
            switch character {
            case "M", "L", "Q", "C":
                flush()
                tokens.append(String(character))
            case " ", ",", "\n", "\t", "\r", "\r\n":
                // "\r\n" is one Character in Swift; the Python validator sees two separators.
                flush()
            case "-":
                flush()
                number = "-"
            case "0"..."9", ".":
                if character == ".", number.contains(".") {
                    // "1.5.25" is two numbers, as in SVG.
                    flush()
                }
                number.append(character)
            default:
                return nil
            }
        }
        flush()

        var start: Point?
        var segments: [Segment] = []
        var command: String?
        var index = 0
        func arity(_ command: String) -> Int {
            switch command {
            case "Q": return 4
            case "C": return 6
            default: return 2
            }
        }
        while index < tokens.count {
            if ["M", "L", "Q", "C"].contains(tokens[index]) {
                command = tokens[index]
                index += 1
            }
            guard let active = command else { return nil }
            let count = arity(active)
            guard index + count <= tokens.count else { return nil }
            var values: [Double] = []
            for token in tokens[index..<(index + count)] {
                guard token.contains(where: { $0.isNumber }) else { return nil }
                // ".5" and "-.5" are valid SVG numbers; give them their leading zero.
                var text = token
                if text.hasPrefix(".") {
                    text = "0" + text
                } else if text.hasPrefix("-.") {
                    text = "-0" + String(text.dropFirst())
                }
                // "1." is a valid SVG number too (the Python validator accepts it).
                if text.hasSuffix(".") {
                    text += "0"
                }
                guard let value = Double(text) else { return nil }
                values.append(value)
            }
            index += count
            switch active {
            case "M":
                // One curve only: a second move is not supported.
                guard start == nil, segments.isEmpty else { return nil }
                start = Point(x: values[0], y: values[1])
                // Further pairs after a move are lines, as in SVG.
                command = "L"
            case "L":
                segments.append(.line(to: Point(x: values[0], y: values[1])))
            case "Q":
                segments.append(.quad(control: Point(x: values[0], y: values[1]), to: Point(x: values[2], y: values[3])))
            default:
                segments.append(.cubic(
                    control1: Point(x: values[0], y: values[1]),
                    control2: Point(x: values[2], y: values[3]),
                    to: Point(x: values[4], y: values[5])
                ))
            }
            if start == nil { return nil }
        }
        guard let start, !segments.isEmpty else { return nil }
        self.start = start
        self.segments = segments
    }

    /// The curve as a run of points, `stepsPerSegment` to each curved segment.
    public func flattened(stepsPerSegment: Int = 24) -> [Point] {
        let steps = max(1, stepsPerSegment)
        var points = [start]
        var current = start
        for segment in segments {
            switch segment {
            case .line(let end):
                points.append(end)
                current = end
            case .quad(let control, let end):
                for step in 1...steps {
                    let t = Double(step) / Double(steps)
                    let u = 1 - t
                    points.append(Point(
                        x: u * u * current.x + 2 * u * t * control.x + t * t * end.x,
                        y: u * u * current.y + 2 * u * t * control.y + t * t * end.y
                    ))
                }
                current = end
            case .cubic(let control1, let control2, let end):
                for step in 1...steps {
                    let t = Double(step) / Double(steps)
                    let u = 1 - t
                    let a = u * u * u
                    let b = 3 * u * u * t
                    let c = 3 * u * t * t
                    let d = t * t * t
                    points.append(Point(
                        x: a * current.x + b * control1.x + c * control2.x + d * end.x,
                        y: a * current.y + b * control1.y + c * control2.y + d * end.y
                    ))
                }
                current = end
            }
        }
        return points
    }
}

/// Walks along a curve by distance, for setting letters on it one by one.
public struct PathSampler: Equatable, Sendable {
    public struct Sample: Equatable, Sendable {
        public var x: Double
        public var y: Double
        /// Direction of travel, in radians (0 = to the right, positive = clockwise on screen).
        public var angle: Double
    }

    private let points: [SVGPath.Point]
    /// Distance along the curve at each point.
    private let distances: [Double]

    public init(path: SVGPath, stepsPerSegment: Int = 24) {
        let points = path.flattened(stepsPerSegment: stepsPerSegment)
        var distances: [Double] = [0]
        var total = 0.0
        for index in 1..<max(1, points.count) {
            let dx = points[index].x - points[index - 1].x
            let dy = points[index].y - points[index - 1].y
            total += (dx * dx + dy * dy).squareRoot()
            distances.append(total)
        }
        self.points = points
        self.distances = distances
    }

    public var length: Double {
        distances.last ?? 0
    }

    /// The point `distance` along the curve and the direction there. Distances outside the
    /// curve are clamped to its ends.
    public func sample(at distance: Double) -> Sample {
        guard points.count > 1 else {
            let only = points.first ?? SVGPath.Point(x: 0, y: 0)
            return Sample(x: only.x, y: only.y, angle: 0)
        }
        let target = min(max(0, distance), length)
        // Binary search for the piece that holds `target`.
        var low = 1
        var high = distances.count - 1
        while low < high {
            let middle = (low + high) / 2
            if distances[middle] < target {
                low = middle + 1
            } else {
                high = middle
            }
        }
        let a = points[low - 1]
        let b = points[low]
        let span = distances[low] - distances[low - 1]
        let t = span > 0 ? (target - distances[low - 1]) / span : 0
        return Sample(
            x: a.x + (b.x - a.x) * t,
            y: a.y + (b.y - a.y) * t,
            angle: atan2(b.y - a.y, b.x - a.x)
        )
    }
}
