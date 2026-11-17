import SwiftUI
import UIKit

struct CardArtworkSource: Decodable {
    let id: String
    let file: String
    let page: URL
    let url: URL
    let crop: [Double]?

    var displayRect: CGRect {
        guard let crop, crop.count == 4,
              crop.allSatisfy({ $0.isFinite && $0 >= 0 && $0 <= 1 }),
              crop[2] > 0, crop[3] > 0, crop[0] + crop[2] <= 1.001, crop[1] + crop[3] <= 1.001 else {
            return CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        return CGRect(x: crop[0], y: crop[1], width: crop[2], height: crop[3])
    }
}

enum CardArtworkCatalog {
    private static let images: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 24
        cache.totalCostLimit = 40 * 1024 * 1024
        return cache
    }()
    static let sources: [CardArtworkSource] = {
        guard let url = Bundle.main.url(forResource: "manifest", withExtension: "json", subdirectory: "CardArt"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([CardArtworkSource].self, from: data) else { return [] }
        return entries
    }()

    static func source(for id: String?) -> CardArtworkSource? { sources.first { $0.id == id } }

    static func image(for id: String?) -> UIImage? {
        guard let id else { return nil }
        if let image = images.object(forKey: id as NSString) { return image }
        guard let source = source(for: id),
              let url = Bundle.main.url(forResource: source.file, withExtension: nil, subdirectory: "CardArt") else { return nil }
        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
        images.setObject(image, forKey: id as NSString, cost: Int(image.size.width * image.size.height * 4))
        return image
    }
}

struct CardArtworkView: View {
    let presetID: String?
    let title: String
    let face: KnownCardInterface
    var height: CGFloat = 190

    var body: some View {
        let image = CardArtworkCatalog.image(for: presetID)
        let source = CardArtworkCatalog.source(for: presetID)
        Group {
            if let image, let source {
                let rect = source.displayRect
                let ratio = image.size.width * rect.width / (image.size.height * rect.height)
                GeometryReader { stage in
                    let width = max(1, min(stage.size.width - 24, height * ratio))
                    let artHeight = width / ratio
                    GeometryReader { _ in
                        // Only the viewport changes; original issuer files remain untouched.
                        Image(uiImage: image).resizable()
                            .frame(width: width / rect.width, height: artHeight / rect.height)
                            .offset(x: -width * rect.minX / rect.width, y: -artHeight * rect.minY / rect.height)
                    }
                    .frame(width: width, height: artHeight).clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.primary.opacity(0.1), lineWidth: 0.6))
                    .shadow(color: .black.opacity(0.16), radius: 9, x: 0, y: 6)
                    .frame(width: stage.size.width, height: height)
                }
            } else {
                fallback
            }
        }
        .frame(height: height)
        .contentShape(Rectangle())
        // Clipping an oversized source image does not clip its hit-test area.
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(image != nil && source != nil ? "card.artwork.\(presetID ?? "")" : "card.artwork.fallback")
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isImage)
    }

    private var fallback: some View {
        HStack {
            Spacer(minLength: 12)
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(face.badge).font(.system(size: 14, weight: .bold, design: .rounded)).lineLimit(1)
                    Spacer()
                    Image(systemName: "wave.3.right").font(.system(size: 18, weight: .light))
                }
                Spacer(minLength: 4)
                Image(systemName: face.symbol).font(.system(size: 25, weight: .light)).opacity(0.85)
                Text(title).font(.system(size: 18, weight: .semibold, design: .rounded)).lineLimit(2).minimumScaleFactor(0.7)
            }
            .foregroundStyle(.white).padding(22)
            .frame(maxWidth: 310).frame(height: height - 8)
            .background(LinearGradient(colors: face.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                Canvas { context, size in
                    for y in stride(from: 0.0, to: size.height, by: 3) {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y - 12))
                        context.stroke(path, with: .color(.white.opacity(0.055)), lineWidth: 0.5)
                    }
                }.allowsHitTesting(false)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.3), lineWidth: 0.7))
            .shadow(color: face.colors.first?.opacity(0.2) ?? .clear, radius: 8, x: 0, y: 5)
            Spacer(minLength: 12)
        }
    }
}
