import Foundation

/// Touch areas for small things in running text: a marked word must be easy to hit even when
/// it is short ("pot"), without stealing the taps meant for the marked word next to it.
/// Pure arithmetic, so it is tested in the core; the view only places the results.
public enum HitTargets {
    /// Apple's minimum comfortable touch target, in points.
    public static let minimumSide: Double = 44

    /// `rect` grown about its centre until it is at least `minimum` wide and tall, plus
    /// `padding` on the left and right (a finger rarely lands exactly on a word's first letter).
    public static func expanded(_ rect: LayoutRect, minimum: Double = HitTargets.minimumSide, padding: Double = 4) -> LayoutRect {
        let width = max(minimum, rect.width + padding * 2)
        let height = max(minimum, rect.height)
        return LayoutRect(
            x: rect.x + rect.width / 2 - width / 2,
            y: rect.y + rect.height / 2 - height / 2,
            width: width,
            height: height
        )
    }

    /// Touch areas for several words of one paragraph, in the same order as `rects`.
    ///
    /// Every area is the word's rectangle grown to the minimum size. Where two grown areas
    /// overlap, the overlap is shared at the midpoint between the two words — sideways when
    /// the words sit side by side on a line, up and down when one is on the line below — so
    /// each area still contains its whole word and a tap always opens the nearer word.
    public static func resolve(_ rects: [LayoutRect], minimum: Double = HitTargets.minimumSide, padding: Double = 4) -> [LayoutRect] {
        var areas = rects.map { expanded($0, minimum: minimum, padding: padding) }
        guard areas.count > 1 else { return areas }
        for first in 0..<(rects.count - 1) {
            for second in (first + 1)..<rects.count {
                guard overlaps(areas[first], areas[second]) else { continue }
                let a = rects[first]
                let b = rects[second]
                if a.maxX <= b.x {
                    cutHorizontally(&areas, left: first, right: second, at: (a.maxX + b.x) / 2)
                } else if b.maxX <= a.x {
                    cutHorizontally(&areas, left: second, right: first, at: (b.maxX + a.x) / 2)
                } else if a.maxY <= b.y {
                    cutVertically(&areas, upper: first, lower: second, at: (a.maxY + b.y) / 2)
                } else if b.maxY <= a.y {
                    cutVertically(&areas, upper: second, lower: first, at: (b.maxY + a.y) / 2)
                }
                // Words that themselves overlap (never produced by a text layout) are left alone.
            }
        }
        return areas
    }

    /// The index of the area a point falls in, or nil. With the areas from `resolve`, at most
    /// one matches; if a caller passes overlapping areas the first wins.
    public static func index(at x: Double, _ y: Double, in areas: [LayoutRect]) -> Int? {
        areas.firstIndex { area in
            x >= area.x && x < area.maxX && y >= area.y && y < area.maxY
        }
    }

    private static func overlaps(_ a: LayoutRect, _ b: LayoutRect) -> Bool {
        a.x < b.maxX && b.x < a.maxX && a.y < b.maxY && b.y < a.maxY
    }

    private static func cutHorizontally(_ areas: inout [LayoutRect], left: Int, right: Int, at x: Double) {
        let leftArea = areas[left]
        if leftArea.maxX > x {
            areas[left].width = max(0, x - leftArea.x)
        }
        let rightArea = areas[right]
        if rightArea.x < x {
            areas[right].width = max(0, rightArea.maxX - x)
            areas[right].x = x
        }
    }

    private static func cutVertically(_ areas: inout [LayoutRect], upper: Int, lower: Int, at y: Double) {
        let upperArea = areas[upper]
        if upperArea.maxY > y {
            areas[upper].height = max(0, y - upperArea.y)
        }
        let lowerArea = areas[lower]
        if lowerArea.y < y {
            areas[lower].height = max(0, lowerArea.maxY - y)
            areas[lower].y = y
        }
    }
}

extension StoryCardRef {
    /// The id of the card a marked word opens, as written in the content: the tap target's id
    /// or the character's id.
    public var cardID: String {
        switch self {
        case .tapTarget(let id): return id.rawValue
        case .character(let id): return id.rawValue
        }
    }

    /// Stable accessibility identifier of a marked word in the text: `word.<cardID>`.
    public var wordIdentifier: String { "word." + cardID }

    /// Stable accessibility identifier of the card it opens: `card.<cardID>`.
    public var cardIdentifier: String { "card." + cardID }
}

extension TextBlock {
    /// The marked words of this paragraph as the reader meets them: every run that names a
    /// tap target or a character, in order (a card may appear more than once).
    public var markedWords: [(text: String, ref: StoryCardRef)] {
        var result: [(text: String, ref: StoryCardRef)] = []
        for run in runs {
            if let tap = run.tapTarget {
                result.append((text: run.text, ref: StoryCardRef.tapTarget(tap)))
            } else if let name = run.characterName {
                result.append((text: run.text, ref: StoryCardRef.character(name)))
            }
        }
        return result
    }
}
