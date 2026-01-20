import SwiftUI

struct PrivacyPolicyView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Title
                Text("Gizlilik Politikası")
                    .font(.title.bold())

                Text("Son güncelleme: \(formattedDate)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                // MARK: - Introduction
                Text("""
DevNotes, kullanıcı gizliliğini temel bir ilke olarak benimser. Uygulama, kişisel verilerinizi toplamaz, izlemez veya üçüncü taraflarla paylaşmaz.
""")

                // MARK: - Data Storage
                sectionTitle("1. Veri Saklama")
                sectionText("""
• Oluşturduğunuz notlar yalnızca cihazınızda saklanır.  
• iCloud senkronizasyonu açıksa, verileriniz Apple iCloud hesabınızda güvenli şekilde depolanır.  
• Geliştirici, not içeriklerinize erişemez.
""")

                // MARK: - Data Collection
                sectionTitle("2. Veri Toplama")
                sectionText("""
• DevNotes herhangi bir analitik, izleme veya reklam verisi toplamaz.  
• Konum, kişi listesi, fotoğraf, mikrofon veya kamera erişimi talep edilmez.  
• Kullanıcı davranışları izlenmez.
""")

                // MARK: - Notifications
                sectionTitle("3. Bildirimler")
                sectionText("""
• Bildirim izinleri yalnızca kullanıcı tarafından oluşturulan hatırlatmalar için kullanılır.  
• Bildirimler reklam, pazarlama veya üçüncü taraf içerikleri içermez.
""")

                // MARK: - Third Parties
                sectionTitle("4. Üçüncü Taraflar")
                sectionText("""
• Hiçbir kişisel veri üçüncü taraf servislerle paylaşılmaz.  
• Uygulama içerisinde reklam SDK’ları veya takip araçları bulunmaz.
""")

                // MARK: - User Control
                sectionTitle("5. Kullanıcı Kontrolü")
                sectionText("""
• Tüm verilerinizi dilediğiniz zaman silebilirsiniz.  
• iCloud senkronizasyonunu ayarlardan kapatabilirsiniz.  
• Bildirim izinlerini iOS Ayarlar uygulaması üzerinden yönetebilirsiniz.
""")

                // MARK: - Changes
                sectionTitle("6. Değişiklikler")
                sectionText("""
Bu gizlilik politikası zaman zaman güncellenebilir. Güncellemeler uygulama içerisinde yayınlandığı andan itibaren geçerli olur.
""")
            }
            .padding()
        }
        .navigationTitle("Gizlilik Politikası")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding(.top, 8)
    }

    private func sectionText(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
}
