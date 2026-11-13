import Foundation
import Observation
import OmramoCore

/// State of the reader: which story, which page. Lives outside the views so a posture change
/// (fold / unfold) lays out the same page again and never resets the position.
@MainActor
@Observable
final class ReaderModel {
    let story: Story
    let pager: Pager
    private(set) var spreadID: SpreadID?
    private let progress: ReadingProgressStore

    init(story: Story, progress: ReadingProgressStore) {
        self.story = story
        self.progress = progress
        let pager = Pager(story: story)
        self.pager = pager
        self.spreadID = pager.resume(from: progress.position(for: story.id))
    }

    var spread: Spread? {
        guard let spreadID else { return nil }
        return story.spreads.first { $0.id == spreadID }
    }

    /// 1-based, for "1 / 14".
    var pageNumber: Int {
        spreadID.flatMap { pager.pageNumber(of: $0) } ?? 1
    }

    var pageCount: Int {
        pager.pageCount
    }

    var isLastPage: Bool {
        guard let spreadID else { return true }
        return pager.isLast(spreadID)
    }

    /// "Part I" for the crumb.
    var partTitle: String {
        guard let spread, let part = story.part(id: spread.part) else { return "" }
        return part.title
    }

    /// The reader came on screen: remember this story as the one being read.
    func didOpen() {
        savePosition()
    }

    /// The child pressed the round button. A page never turns any other way.
    func turnPage() {
        // TODO(M5): ask SampleGate before showing a spread beyond `story.sample.freeSpreads`.
        // TODO(M4): record a page-read event (date, story, spread — never a time) in ReadingLog.
        guard let spreadID, let next = pager.next(after: spreadID) else { return }
        self.spreadID = next
        savePosition()
    }

    /// The child pressed the button on the last page.
    /// TODO(M6): the story-finished moment (design gap G3). TODO(M4): mark the story finished.
    func finish() {
        progress.clear(storyID: story.id)
    }

    private func savePosition() {
        guard let spreadID else { return }
        let firstBlock = spread?.blocks.first?.id
        progress.record(ReadingPosition(storyID: story.id, spreadID: spreadID, blockID: firstBlock))
    }
}
