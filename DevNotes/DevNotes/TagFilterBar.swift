import SwiftUI

struct TagFilterMenu: View {

    let tags: [Tag]
    @Binding var selectedTag: Tag?

    var body: some View {
        Menu {
            // 🔹 Tümü
            Button {
                selectedTag = nil
            } label: {
                Label("Tümü", systemImage: "line.3.horizontal.decrease.circle")
            }

            Divider()

            // 🔹 Tag’ler
            ForEach(tags) { tag in
                Button {
                    selectedTag = tag
                } label: {
                    Label(tag.name, systemImage: tag.icon)
                }
            }

        } label: {
            HStack(spacing: 6) {
                Image(systemName: "line.3.horizontal.decrease.circle")

                Text(selectedTag?.name ?? "Filtre")
                    .font(.subheadline)
            }
        }
    }
}
