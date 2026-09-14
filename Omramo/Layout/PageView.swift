import SwiftUI
import OmramoCore

/// The same page in a second edition, shown under the first when only one
/// pane is available. This is how bilingual reading survives the fold closing.
struct CompanionPage: Equatable {
    let page: Page
    let language: Language
}

/// One printed page: optional illustration band, the text, a caption and the
/// page number. Used identically in the sample and the reader.
struct PageView: View {
    let page: Page
    let language: Language
    var showsIllustration: Bool = true
    var companion: CompanionPage? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if showsIllustration, let illustration = page.illustration {
                    PlaceholderArt(artwork: illustration, cornerRadius: 8)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                }
                Text(page.text)
                    .pageTextStyle()
                    .fixedSize(horizontal: false, vertical: true)
                if let caption = page.caption {
                    Text(caption)
                        .font(OmramoType.pageCaption)
                        .foregroundStyle(OmramoPalette.inkSoft)
                }
                if let companion {
                    Divider()
                        .overlay(OmramoPalette.inkSoft.opacity(0.4))
                        .padding(.vertical, 4)
                    Text(companion.language.nativeName)
                        .font(OmramoType.pageNumber)
                        .foregroundStyle(OmramoPalette.inkSoft)
                    Text(companion.page.text)
                        .pageTextStyle()
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            HStack {
                if let companion {
                    Text("\(language.nativeName) | \(companion.language.nativeName)")
                } else {
                    Text(language.nativeName)
                }
                Spacer()
                Text("\(page.number)")
            }
            .font(OmramoType.pageNumber)
            .foregroundStyle(OmramoPalette.inkSoft)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
        }
        .background(PaperBackground())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Page \(page.number), \(language.englishName)"))
    }
}

/// The illustration pane for `SpreadMode.illustrated`. Falls back to the
/// book's poster art when a page has no illustration of its own.
struct ArtPane: View {
    let page: Page
    let fallback: Artwork

    var body: some View {
        VStack(spacing: 12) {
            PlaceholderArt(artwork: page.illustration ?? fallback, cornerRadius: 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let caption = page.caption {
                Text(caption)
                    .font(OmramoType.pageCaption)
                    .foregroundStyle(OmramoPalette.inkSoft)
            }
        }
        .padding(24)
        .background(PaperBackground())
    }
}

/// Shown in place of a page the reader is not entitled to. This is the hard
/// paywall inside the book: nothing past the sample renders without a plan.
struct LockedPageView: View {
    let pageNumber: Int
    let onSubscribe: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(OmramoPalette.saffron)
            Text("Page \(pageNumber) is part of the full book")
                .font(OmramoType.cardTitle)
                .foregroundStyle(OmramoPalette.ink)
                .multilineTextAlignment(.center)
            Text("One subscription opens every title in \(Brand.displayName).")
                .font(OmramoType.cardSubtitle)
                .foregroundStyle(OmramoPalette.inkSoft)
                .multilineTextAlignment(.center)
            Button("Subscribe to keep reading", action: onSubscribe)
                .buttonStyle(.borderedProminent)
                .tint(OmramoPalette.saffron)
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PaperBackground())
    }
}

/// Empty pane for the right side when a book ends on the left page.
struct BlankPageView: View {
    var body: some View {
        PaperBackground()
            .overlay {
                Image(systemName: "book.closed")
                    .font(.title)
                    .foregroundStyle(OmramoPalette.inkSoft.opacity(0.35))
            }
            .accessibilityHidden(true)
    }
}

struct PaperBackground: View {
    var body: some View {
        LinearGradient(
            colors: [OmramoPalette.paper, OmramoPalette.paperShade],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview("Page") {
    PageView(
        page: Page(
            number: 1,
            text: "గోదావరి ఒడ్డున ఉన్న చిన్న పల్లె పేరు కొత్తూరు. ఉదయం సూర్యుడు నదిపై బంగారు రంగు చల్లే వేళ, పదేళ్ల లక్ష్మి తాతయ్య పడవ దగ్గరకు పరుగెత్తింది.",
            illustration: Artwork(motif: .river, colors: [HexColor("#0B2E4F")!, HexColor("#1F7A8C")!, HexColor("#F4A259")!]),
            caption: "ఉదయపు గోదావరి"
        ),
        language: .telugu
    )
}
