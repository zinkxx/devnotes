import SwiftUI

struct AboutDevNotesView: View {

    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // MARK: - APP ICON / HEADER
                VStack(spacing: 14) {
                    Image(systemName: "note.text")
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundColor(.accentColor)

                    Text("DevNotes")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Hızlı, sade ve güvenli not alma deneyimi.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Divider()

                // MARK: - DESCRIPTION
                VStack(spacing: 10) {
                    Text(
                        "DevNotes; fikirlerini, yapılacaklarını ve önemli notlarını düzenli bir şekilde saklamanı sağlar."
                    )

                    Text(
                        "Etiketleme, sabitleme ve hatırlatmalar sayesinde notlarına hızlıca erişebilirsin."
                    )
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

                // MARK: - LINKS
                VStack(spacing: 12) {

                    aboutLink(
                        title: "Web Sitesi",
                        subtitle: "www.devtechnic.com.tr",
                        icon: "globe",
                        url: "https://www.devtechnic.com.tr"
                    )

                    aboutLink(
                        title: "GitHub",
                        subtitle: "github.com/zinkxx",
                        icon: "chevron.left.slash.chevron.right",
                        url: "https://github.com/zinkxx"
                    )
                }

                Divider()

                // MARK: - FOOTER
                VStack(spacing: 6) {
                    Text("Sürüm \(appVersion)")
                    Text("© 2026 Zinkx")
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
            .padding()
        }
        .navigationTitle("Hakkında")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - LINK ROW
    private func aboutLink(
        title: String,
        subtitle: String,
        icon: String,
        url: String
    ) -> some View {
        Button {
            if let link = URL(string: url) {
                openURL(link)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color("CardBackground"))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - VERSION
    private var appVersion: String {
        let version =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build =
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "\(version) (\(build))"
    }
}
