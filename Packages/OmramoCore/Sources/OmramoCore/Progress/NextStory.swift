import Foundation

/// Which story to offer when one is finished (the "Next story" button of the story-finished
/// moment). Pure: the catalog order, the tiers and what has been finished decide; nothing is
/// random and nothing depends on the clock.
public enum NextStory {
    /// The story to suggest after `finishedID`, or nil when the catalog holds no other story.
    ///
    /// In order of weight:
    /// 1. a story that has **not been finished** before one that has (the story just finished
    ///    counts as finished);
    /// 2. the **same level**, then one level up, then one level down, then further away — a
    ///    reader is never pushed two levels up while something nearer is unread;
    /// 3. the catalog's own order, starting after the story just finished and wrapping round.
    ///
    /// - Parameters:
    ///   - finishedID: the story that has just been finished.
    ///   - stories: the catalog, in its order.
    ///   - finished: stories finished before (the reading log).
    public static func suggestion(after finishedID: StoryID, in stories: [Story], finished: Set<StoryID>) -> Story? {
        let others = stories.filter { $0.id != finishedID }
        guard !others.isEmpty else { return nil }
        let current = stories.first { $0.id == finishedID }
        let currentIndex = stories.firstIndex { $0.id == finishedID } ?? -1
        let count = stories.count

        func rank(_ story: Story) -> (Int, Int, Int) {
            let read = finished.contains(story.id) ? 1 : 0
            let level = current.map { tierDistance(from: $0.tier, to: story.tier) } ?? 0
            let index = stories.firstIndex { $0.id == story.id } ?? 0
            // Steps forward from the finished story in catalog order, wrapping.
            let steps = currentIndex < 0 ? index : ((index - currentIndex) % count + count) % count
            return (read, level, steps)
        }
        return others.min { rank($0) < rank($1) }
    }

    /// 0 for the same level, 1 for one level up, 2 for one level down, 3 for two up, 4 for
    /// two down: nearer first, and up before down at the same distance.
    static func tierDistance(from: Tier, to: Tier) -> Int {
        let delta = to.level - from.level
        if delta == 0 { return 0 }
        return delta > 0 ? delta * 2 - 1 : -delta * 2
    }
}
