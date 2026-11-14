import Foundation

/// Checks that markup never changed the wording: the run texts of a story, joined, must equal
/// its manuscript in `Content/sources/` after normalising typographic quotes, dashes and
/// whitespace.
///
/// Manuscript format: plain UTF-8 text. Lines starting with `#` are notes (source header,
/// part headings) and are not story text. Everything else is story text; line breaks and blank
/// lines are only whitespace.
public enum TextFidelity {
    public struct Mismatch: Equatable, Sendable {
        /// Offset in the normalised text where the two first differ.
        public var offset: Int
        /// About 40 characters of the manuscript from the difference.
        public var expected: String
        /// About 40 characters of the story from the difference.
        public var found: String
    }

    public static func normalize(_ text: String) -> String {
        var output = ""
        var pendingSpace = false
        var lastWasDash = false
        for scalar in text.unicodeScalars {
            let piece: String
            switch scalar.value {
            case 0x201C, 0x201D, 0x201E, 0x00AB, 0x00BB:    // “ ” „ « »
                piece = "\""
            case 0x2018, 0x2019, 0x201A:                    // ‘ ’ ‚
                piece = "'"
            case 0x2010, 0x2011, 0x2012, 0x2013, 0x2014, 0x2015, 0x2212:    // hyphens and dashes
                piece = "-"
            case 0x2026:                                    // …
                piece = "..."
            case 0x0009, 0x000A, 0x000D, 0x0020, 0x00A0, 0x2009, 0x200A, 0x202F:
                piece = " "
            default:
                piece = String(scalar)
            }
            if piece == " " {
                pendingSpace = true
                continue
            }
            if piece == "-" {
                // "--" and "—" are the same dash.
                if lastWasDash && !pendingSpace { continue }
                lastWasDash = true
            } else {
                lastWasDash = false
            }
            if pendingSpace && !output.isEmpty {
                output += " "
            }
            pendingSpace = false
            output += piece
        }
        return output
    }

    /// The story text of a manuscript file: every line that is not a `#` note.
    public static func manuscriptBody(_ manuscript: String) -> String {
        manuscript
            .split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline })
            .filter { !$0.drop(while: { $0 == " " || $0 == "\t" }).hasPrefix("#") }
            .joined(separator: "\n")
    }

    /// All paragraphs of a story in reading order, one per line.
    public static func storyText(_ story: Story) -> String {
        story.spreads
            .flatMap { $0.blocks }
            .map { $0.plainText }
            .joined(separator: "\n")
    }

    /// Returns nil when the story's text equals the manuscript.
    public static func compare(story: Story, manuscript: String) -> Mismatch? {
        let expected = Array(normalize(manuscriptBody(manuscript)).unicodeScalars)
        let found = Array(normalize(storyText(story)).unicodeScalars)
        var index = 0
        while index < expected.count && index < found.count && expected[index] == found[index] {
            index += 1
        }
        if index == expected.count && index == found.count {
            return nil
        }
        return Mismatch(
            offset: index,
            expected: excerpt(expected, from: index),
            found: excerpt(found, from: index)
        )
    }

    private static func excerpt(_ scalars: [Unicode.Scalar], from index: Int) -> String {
        let start = max(0, index - 12)
        let end = min(scalars.count, index + 28)
        guard start < end else { return "(end of text)" }
        var view = String.UnicodeScalarView()
        view.append(contentsOf: scalars[start..<end])
        return String(view)
    }
}
