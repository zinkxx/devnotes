import SwiftUI

struct ProfileView: View {

    @ObservedObject var session = UserSession.shared

    var body: some View {
        List {

            Section {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.accent)

                    VStack(alignment: .leading) {
                        Text("DevNotes Kullanıcısı")
                            .font(.headline)

                        Text(session.isPro ? "Pro Üye" : "Ücretsiz Plan")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Abonelik") {
                if session.isPro {
                    Label("Pro aktif", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                } else {
                    Button("Pro’ya Yükselt") {
                        // paywall aç
                    }
                }
            }

            Section("Limitler") {
                HStack {
                    Text("Not limiti")
                    Spacer()
                    Text(session.isPro ? "Sınırsız" : "3 not")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Profil")
    }
}
