//
//  ShareView.swift
//  March16
//
//  Created by 양시준 on 12/7/25.
//

import SwiftUI
import LinkPresentation

final class ShareableImageItem: NSObject, UIActivityItemSource {
    private let image: UIImage
    private let title: String

    init(image: UIImage, title: String) {
        self.image = image
        self.title = title
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        image
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        image
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.imageProvider = NSItemProvider(object: image)
        return metadata
    }
}

struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var date: Date
    var dailyVerse: DailyVerse

    @State private var renderedImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ShareCardView(date: date, dailyVerse: dailyVerse)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: AppColor.primary.opacity(0.1), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 32)

                if let image = renderedImage {
                    Button {
                        shareImage(image)
                    } label: {
                        Label(String(localized: "Share"), systemImage: "square.and.arrow.up")
                            .appFont(.shareButton)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColor.primary)
                            .foregroundStyle(AppColor.background)
                            .clipShape(.capsule)
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()
            }
            .padding(.top, 24)
            .background(AppColor.background)
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .onAppear {
            renderImage()
        }
    }

    @MainActor
    private func renderImage() {
        let baseWidth: CGFloat = 300
        let baseHeight: CGFloat = 300 * (16.0 / 9.0)
        let scale = 2160.0 / baseWidth

        let cardView = ShareCardView(date: date, dailyVerse: dailyVerse)
            .frame(width: baseWidth, height: baseHeight)
            .environment(\.colorScheme, colorScheme)

        let renderer = ImageRenderer(content: cardView)
        renderer.scale = scale

        if let uiImage = renderer.uiImage {
            renderedImage = uiImage
        }
    }

    private func shareImage(_ image: UIImage) {
        let item = ShareableImageItem(image: image, title: dailyVerse.referenceString)
        let activityVC = UIActivityViewController(
            activityItems: [item],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            activityVC.popoverPresentationController?.sourceView = topVC.view
            topVC.present(activityVC, animated: true)
        }
    }
}

struct ShareCardView: View {
    var date: Date
    var dailyVerse: DailyVerse

    var monthString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }

    var dayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                Text(monthString)
                    .appFont(.shareDateMonth)
                    .frame(height: 32)
                Text(dayString)
                    .appFont(.shareDateDay)
                    .frame(height: 120)
            }
            .foregroundStyle(AppColor.primary)

            Spacer()
                .frame(height: 24)

            VStack(alignment: .leading, spacing: 16) {
                Text(dailyVerse.content)
                    .appFont(.shareVerseContent)
                    .italic()
                    .lineSpacing(4)
                    .foregroundStyle(AppColor.primary)
                Text(dailyVerse.referenceString)
                    .appFont(.shareVerseReference)
                    .foregroundStyle(AppColor.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(9/16, contentMode: .fit)
        .background(AppColor.background)
    }
}

#Preview {
    let dailyVerse = DailyVerse(
        id: 1207,
        month: 12,
        day: 7,
        book: "Proverbs",
        chapter: 12,
        startVerse: 7,
        content: "The wicked are overthrown, and are not: but the house of the righteous shall stand."
    )
    ShareView(date: Date(), dailyVerse: dailyVerse)
}
