import SwiftUI

struct DeleteTagButton: View {

    let tag: Tag
    @State private var showAlert = false

    private var linkedNotesCount: Int {
        NoteStore.shared.notes.filter { $0.tag?.id == tag.id }.count
    }

    var body: some View {
        Button(role: .destructive) {
            showAlert = true
        } label: {
            Text("Etiketi Sil")
        }
        .alert("Etiket Silinsin mi?", isPresented: $showAlert) {
            Button("Sil", role: .destructive) {
                TagStore.shared.delete(tag)
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text(
                linkedNotesCount > 0
                ? "Bu etiket \(linkedNotesCount) notta kullanılıyor. Silersen notlardan kaldırılacak."
                : "Bu etiket silinecek."
            )
        }
    }
}
