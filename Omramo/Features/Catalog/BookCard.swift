import SwiftUI
import OmramoCore

/// Poster card. Telugu title leads, English title supports, and the edition
/// row shows which literary editions are bundled or planned.
struct BookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PlaceholderArt(artwork: book.poster)
                .aspectRatio(2 / 3, contentMode: .fit)
                .overlay(alignment: .bottomLeading) {
                    Text(book.title.resolved(in: .telugu))
                        .font(OmramoType.displayTitle)
                        .foregroundStyle(OmramoPalette.paper)
                        .shadow(color: .black.opacity(0.5), radius: 6, y: 2)
                        .padding(14)
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                }
                .shadow(color: .black.opacity(0.18), radius: 10, y: 6)

            VStack(alignment: .leading, spacing: 4) {
                if let english = book.title[.english] {
                    Text(english)
                        .font(OmramoType.cardTitle)
                        .foregroundStyle(OmramoPalette.ink)
                        .lineLimit(2)
                }
                Text(book.author.resolved(in: .telugu))
                    .font(OmramoType.cardSubtitle)
                    .foregroundStyle(OmramoPalette.inkSoft)
                Text(book.description.resolved(in: .telugu))
                    .font(.footnote)
                    .foregroundStyle(OmramoPalette.inkSoft)
                    .lineLimit(3)
                    .padding(.top, 2)
                EditionRow(book: book)
                    .padding(.top, 4)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(book.title.resolved(in: .telugu)), \(book.title.resolved(in: .english)), by \(book.author.resolved(in: .english))"))
    }
}

/// te | en | hi chips. Ready editions are solid, planned ones are outlined.
struct EditionRow: View {
    let book: Book

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Language.allCases, id: \.self) { language in
                if let edition = book.edition(for: language) {
                    Text(language.rawValue.uppercased())
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(edition.isReady ? OmramoPalette.indigo : .clear, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .strokeBorder(OmramoPalette.indigo.opacity(edition.isReady ? 0 : 0.5), lineWidth: 1)
                        }
                        .foregroundStyle(edition.isReady ? OmramoPalette.paper : OmramoPalette.inkSoft)
                        .accessibilityLabel(Text("\(language.englishName) edition \(edition.isReady ? "ready" : "planned")"))
                }
            }
            Spacer(minLength: 0)
            Text("\(book.pageCount) pages")
                .font(.caption2)
                .foregroundStyle(OmramoPalette.inkSoft)
        }
    }
}
