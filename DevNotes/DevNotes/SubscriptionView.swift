import SwiftUI

struct SubscriptionView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var session = UserSession.shared

    var body: some View {
        VStack(spacing: 24) {

            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("DevNotes Pro")
                .font(.largeTitle.bold())

            VStack(alignment: .leading, spacing: 12) {
                Label("Sınırsız not", systemImage: "checkmark")
                Label("Gelişmiş hatırlatmalar", systemImage: "checkmark")
                Label("iCloud Sync (yakında)", systemImage: "checkmark")
            }

            Button("Pro’ya Geç") {
                // Şimdilik mock
                session.isPro = true
                dismiss()
            }
            .buttonStyle(.borderedProminent)

            Button("Vazgeç") {
                dismiss()
            }
            .foregroundStyle(.secondary)
        }
        .padding()
    }
}
