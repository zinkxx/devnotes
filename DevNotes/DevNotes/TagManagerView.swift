import SwiftUI

struct TagManagerView: View {

    @ObservedObject var store = TagStore.shared
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.tags) { tag in

                    // 👇 ETİKETE TIKLA → DÜZENLE
                    NavigationLink {
                        EditTagView(tag: tag)
                    } label: {
                        HStack {
                            Image(systemName: tag.icon)
                                .foregroundStyle(Color(tag.color))

                            Text(tag.name)

                            Spacer()
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { store.tags[$0] }.forEach {
                        store.delete($0)
                    }
                }
            }
            .navigationTitle("Etiketler")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddTagView()
            }
        }
    }
}
