import SwiftUI
import OmramoCore

/// The fold mark: left pane | spine | right pane. Closed, the three tiles sit
/// flush and read the product name. Open, the outer tiles swing out as the
/// two covers of a book and the middle tile becomes the spine. Tile letters
/// come from `Brand.mark`, so the mark follows a rename automatically.
struct FoldMarkView: View {
    var isOpen: Bool
    var scale: CGFloat = 1
    var mark: FoldMark = Brand.mark

    private var tileHeight: CGFloat { 88 * scale }
    private var paneWidth: CGFloat { 92 * scale }
    private var spineWidth: CGFloat { isOpen ? 22 * scale : 60 * scale }

    var body: some View {
        HStack(spacing: isOpen ? 6 * scale : 0) {
            tile(mark.left, color: OmramoPalette.indigo, width: paneWidth, hidesLettersWhenOpen: false)
                .rotation3DEffect(.degrees(isOpen ? 28 : 0), axis: (x: 0, y: 1, z: 0), anchor: .trailing, perspective: 0.6)
            tile(mark.spine, color: OmramoPalette.spine, width: spineWidth, hidesLettersWhenOpen: true)
                .overlay {
                    if isOpen {
                        Text(mark.spine)
                            .font(.system(size: 12 * scale, weight: .heavy, design: .rounded))
                            .foregroundStyle(OmramoPalette.onShelf.opacity(0.9))
                            .rotationEffect(.degrees(-90))
                            .transition(.opacity)
                    }
                }
            tile(mark.right, color: OmramoPalette.saffron, width: paneWidth, hidesLettersWhenOpen: false)
                .rotation3DEffect(.degrees(isOpen ? -28 : 0), axis: (x: 0, y: 1, z: 0), anchor: .leading, perspective: 0.6)
        }
        .animation(.spring(duration: 0.9, bounce: 0.18), value: isOpen)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(Brand.displayName))
    }

    private func tile(_ letters: String, color: Color, width: CGFloat, hidesLettersWhenOpen: Bool) -> some View {
        RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
            .fill(color)
            .frame(width: width, height: tileHeight)
            .overlay {
                Text(letters)
                    .font(.system(size: 34 * scale, weight: .heavy, design: .rounded))
                    .foregroundStyle(OmramoPalette.onShelf)
                    .opacity(hidesLettersWhenOpen && isOpen ? 0 : 1)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .padding(.horizontal, 4 * scale)
            }
    }
}

#Preview("Closed and open") {
    VStack(spacing: 40) {
        FoldMarkView(isOpen: false)
        FoldMarkView(isOpen: true)
        FoldMarkView(isOpen: true, scale: 0.5)
        FoldMarkView(isOpen: false, mark: FoldMark.derived(from: "Kathalu"))
    }
    .padding()
    .background(OmramoPalette.paper)
}
