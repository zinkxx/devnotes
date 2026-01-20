import SwiftUI

struct LicensesView: View {

    var body: some View {
        List {

            // MARK: - System Frameworks
            Section {
                licenseRow(
                    name: "SwiftUI",
                    owner: "Apple Inc.",
                    description: "Modern declarative UI framework for Apple platforms."
                )

                licenseRow(
                    name: "UIKit",
                    owner: "Apple Inc.",
                    description: "UIKit framework used for advanced text editing and system components."
                )

                licenseRow(
                    name: "UserNotifications",
                    owner: "Apple Inc.",
                    description: "Framework used to schedule and manage local notifications."
                )
            } header: {
                Text("Sistem Frameworkleri")
            }

            // MARK: - Notes
            Section {
                Text("""
Bu uygulama, yalnızca Apple tarafından sağlanan sistem frameworklerini kullanmaktadır.

Tüm frameworkler Apple lisansları kapsamında olup, ilgili lisans şartları Apple geliştirici dokümantasyonunda belirtilmiştir.
""")
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

        }
        .navigationTitle("Lisanslar")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Row

    private func licenseRow(
        name: String,
        owner: String,
        description: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)

            Text(owner)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
