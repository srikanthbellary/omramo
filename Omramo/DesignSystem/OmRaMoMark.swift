import SwiftUI

/// The mark: OM | RA | MO. Closed, the three tiles sit flush and read Omramo.
/// Open, OM and MO swing out as the two panes of a book and RA becomes the
/// spine. The same geometry is used for the splash and the paywall header.
struct OmRaMoMark: View {
    var isOpen: Bool
    var scale: CGFloat = 1

    private var tileHeight: CGFloat { 88 * scale }
    private var paneWidth: CGFloat { 92 * scale }
    private var spineWidth: CGFloat { isOpen ? 22 * scale : 60 * scale }

    var body: some View {
        HStack(spacing: isOpen ? 6 * scale : 0) {
            tile("OM", color: OmramoPalette.indigo, width: paneWidth)
                .rotation3DEffect(.degrees(isOpen ? 28 : 0), axis: (x: 0, y: 1, z: 0), anchor: .trailing, perspective: 0.6)
            tile("RA", color: OmramoPalette.spine, width: spineWidth)
                .overlay {
                    if isOpen {
                        Text("RA")
                            .font(.system(size: 12 * scale, weight: .heavy, design: .rounded))
                            .foregroundStyle(OmramoPalette.paper.opacity(0.9))
                            .rotationEffect(.degrees(-90))
                            .transition(.opacity)
                    }
                }
            tile("MO", color: OmramoPalette.saffron, width: paneWidth)
                .rotation3DEffect(.degrees(isOpen ? -28 : 0), axis: (x: 0, y: 1, z: 0), anchor: .leading, perspective: 0.6)
        }
        .animation(.spring(duration: 0.9, bounce: 0.18), value: isOpen)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Omramo"))
    }

    private func tile(_ letters: String, color: Color, width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
            .fill(color)
            .frame(width: width, height: tileHeight)
            .overlay {
                Text(letters)
                    .font(.system(size: 34 * scale, weight: .heavy, design: .rounded))
                    .foregroundStyle(OmramoPalette.paper)
                    .opacity(letters == "RA" && isOpen ? 0 : 1)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .padding(.horizontal, 4 * scale)
            }
    }
}

#Preview("Closed and open") {
    VStack(spacing: 40) {
        OmRaMoMark(isOpen: false)
        OmRaMoMark(isOpen: true)
        OmRaMoMark(isOpen: true, scale: 0.5)
    }
    .padding()
    .background(OmramoPalette.paper)
}
