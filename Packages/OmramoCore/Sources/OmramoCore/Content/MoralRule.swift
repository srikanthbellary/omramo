import Foundation

/// The rule for a story's `moral`: the one sentence shown to the child on the story-finished
/// moment. Rule code `moral-incomplete`; `tools/validate_content.py` applies the same checks.
public enum MoralRule {
    /// Longest moral, in characters: it has to read at a glance on a phone.
    public static let maximumLength = 120

    /// What is wrong with a moral, or nil when it is fine: present, not blank, at most
    /// `maximumLength` characters, and exactly one sentence (it ends with a full stop, a
    /// question mark or an exclamation mark, and none of those ends a sentence before the end).
    public static func problem(in moral: String?) -> String? {
        guard let moral else {
            return "the story has no moral (one short sentence for the story-finished moment)"
        }
        let text = moral.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            return "the moral is empty"
        }
        if text.count > maximumLength {
            return "the moral is \(text.count) characters long; keep it to \(maximumLength) or fewer"
        }
        if sentenceCount(text) != 1 {
            return "the moral must be exactly one sentence that ends with a full stop, a question mark or an exclamation mark"
        }
        return nil
    }

    /// How many sentences `text` holds: the sentence ends (". ", "! ", "? " or the same at the
    /// very end, a closing quote allowed after the mark). A text that does not end with a
    /// sentence mark counts one unfinished sentence more, so "Be kind" gives 1 end short of
    /// valid and is reported by `problem(in:)` through this count being 1 only when it ends
    /// properly.
    static func sentenceCount(_ text: String) -> Int {
        let marks: Set<Character> = [".", "!", "?"]
        let closers: Set<Character> = ["\"", "\u{201D}", "\u{2019}", "'", ")"]
        let characters = Array(text)
        var count = 0
        var index = 0
        var endedAtLastCharacter = false
        while index < characters.count {
            if marks.contains(characters[index]) {
                // Swallow repeated marks ("?!", "...") and a closing quote or bracket.
                var end = index + 1
                while end < characters.count, marks.contains(characters[end]) || closers.contains(characters[end]) {
                    end += 1
                }
                if end >= characters.count {
                    count += 1
                    endedAtLastCharacter = true
                } else if characters[end].isWhitespace {
                    count += 1
                }
                index = end
            } else {
                index += 1
            }
        }
        // No closing mark: not a finished sentence. Reported as "not exactly one".
        return endedAtLastCharacter ? count : 0
    }
}
