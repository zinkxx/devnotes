import SwiftUI

struct TermsOfServiceView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Title
                Text("Kullanım Şartları")
                    .font(.title.bold())

                Text("Son güncelleme: \(formattedDate)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                // MARK: - Introduction
                Text("""
DevNotes uygulamasını kullanarak aşağıda belirtilen kullanım şartlarını kabul etmiş sayılırsınız. Bu şartlar, uygulamanın güvenli, adil ve sürdürülebilir şekilde kullanılmasını sağlamak amacıyla hazırlanmıştır.
""")

                // MARK: - Usage
                sectionTitle("1. Kullanım Koşulları")
                sectionText("""
• DevNotes yalnızca bireysel ve kişisel kullanım içindir.  
• Uygulama, yasa dışı veya kötüye kullanım amacıyla kullanılamaz.  
• Uygulamanın işleyişini bozacak davranışlarda bulunulamaz.
""")

                // MARK: - User Content
                sectionTitle("2. Kullanıcı İçerikleri")
                sectionText("""
• Oluşturduğunuz tüm notlar ve içeriklerin sorumluluğu tamamen size aittir.  
• DevNotes, kullanıcı tarafından oluşturulan içerikleri incelemez veya doğrulamaz.  
• İçeriklerinizin yedeklenmesi kullanıcının sorumluluğundadır.
""")

                // MARK: - Data & Liability
                sectionTitle("3. Veri ve Sorumluluk Reddi")
                sectionText("""
• Uygulama, veri kaybı veya beklenmeyen hatalardan dolayı sorumluluk kabul etmez.  
• Yazılım "olduğu gibi" sunulmaktadır.  
• Teknik sorunlar, güncellemeler veya sistem hataları nedeniyle oluşabilecek aksaklıklardan geliştirici sorumlu tutulamaz.
""")

                // MARK: - Changes
                sectionTitle("4. Değişiklikler")
                sectionText("""
• Bu kullanım şartları önceden bildirim yapılmaksızın güncellenebilir.  
• Güncellemeler uygulama içerisinde yayınlandığı andan itibaren geçerli olur.
""")

                // MARK: - Acceptance
                sectionTitle("5. Kabul")
                sectionText("""
Uygulamayı kullanmaya devam etmeniz, bu kullanım şartlarını kabul ettiğiniz anlamına gelir.
""")

            }
            .padding()
        }
        .navigationTitle("Kullanım Şartları")
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
