import SwiftUI
import UIKit

// MARK: - AddNoteView

struct AddNoteView: View {

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    @State private var title = ""
    @State private var plainContent = ""   // sadece save için

    @State private var selectedTag: Tag? = nil
    @State private var isPinned = false
    @State private var hasReminder = false
    @State private var reminderDate = Date()

    enum Field { case title }

    let onSave: (Note) -> Void

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Title
                Section("Başlık") {
                    TextField("Not başlığı", text: $title)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                }

                // MARK: Content
                Section("İçerik") {
                    RichTextContainer(text: plainContent) { text in
                        plainContent = text
                    }
                    .frame(minHeight: 180)
                }

                // MARK: Pin
                Section {
                    Toggle(isOn: $isPinned) {
                        Label("Notu Sabitle", systemImage: "pin.fill")
                            .foregroundStyle(.orange)
                    }
                }

                // MARK: Reminder
                Section("Hatırlatma") {
                    Toggle("Hatırlatma Ekle", isOn: $hasReminder)

                    if hasReminder {
                        DatePicker(
                            "Tarih",
                            selection: $reminderDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

                // MARK: Tag
                Section("Etiket") {
                    ForEach(TagStore.shared.tags) { tag in
                        Button {
                            selectedTag = tag
                        } label: {
                            HStack {
                                Image(systemName: tag.icon)
                                    .foregroundStyle(Color(tag.color))
                                Text(tag.name)
                                Spacer()
                                if selectedTag?.id == tag.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.accent)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Yeni Not")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear { focusedField = .title }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !plainContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        let note = Note(
            id: UUID(),
            title: title,
            content: plainContent,
            createdAt: Date(),
            tag: selectedTag,
            isPinned: isPinned,
            reminderDate: hasReminder ? reminderDate : nil
        )
        onSave(note)
        dismiss()
    }
}
struct RichTextContainer: UIViewRepresentable {

    let text: String
    var onTextChange: (String) -> Void

    func makeUIView(context: Context) -> UIView {
        let container = UIView()

        let toolbar = UIToolbar()
        toolbar.isTranslucent = true
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)

        if #available(iOS 15.0, *) {
            let appearance = UIToolbarAppearance()
            appearance.configureWithTransparentBackground()
            toolbar.standardAppearance = appearance
            toolbar.scrollEdgeAppearance = appearance
        }

        toolbar.items = [
            makeItem("bold", context, #selector(Coordinator.bold)),
            makeItem("italic", context, #selector(Coordinator.italic)),
            makeItem("underline", context, #selector(Coordinator.underline)),
            UIBarButtonItem.flexibleSpace(),
            makeItem("list.bullet", context, #selector(Coordinator.bullet)),
            makeItem("checklist", context, #selector(Coordinator.checklist))
        ]

        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.text = text   // ⭐ EN KRİTİK SATIR
        context.coordinator.textView = textView

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(toolbar)
        container.addSubview(textView)

        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: container.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            textView.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let tv = context.coordinator.textView, tv.text != text else { return }
        tv.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTextChange: onTextChange)
    }

    private func makeItem(
        _ system: String,
        _ context: Context,
        _ selector: Selector
    ) -> UIBarButtonItem {

        let image = UIImage(systemName: system,
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 13))

        var config = UIButton.Configuration.plain()
        config.image = image
        config.contentInsets = .zero

        let button = UIButton(configuration: config)
        button.tintColor = .label
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        button.addTarget(context.coordinator, action: selector, for: .touchUpInside)

        return UIBarButtonItem(customView: button)
    }

    final class Coordinator: NSObject, UITextViewDelegate {

        weak var textView: UITextView?
        let onTextChange: (String) -> Void

        init(onTextChange: @escaping (String) -> Void) {
            self.onTextChange = onTextChange
        }

        func textViewDidChange(_ textView: UITextView) {
            onTextChange(textView.text)
        }

        @objc func bold() { toggle(.traitBold) }
        @objc func italic() { toggle(.traitItalic) }
        @objc func underline() {
            guard let tv = textView else { return }
            let range = tv.selectedRange
            tv.textStorage.addAttribute(
                .underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: range
            )
        }

        @objc func bullet() { textView?.insertText("\n• ") }
        @objc func checklist() { textView?.insertText("\n☐ ") }

        private func toggle(_ trait: UIFontDescriptor.SymbolicTraits) {
            guard let tv = textView else { return }
            let font = tv.font ?? .systemFont(ofSize: 16)
            let traits = font.fontDescriptor.symbolicTraits.contains(trait)
                ? font.fontDescriptor.symbolicTraits.subtracting(trait)
                : font.fontDescriptor.symbolicTraits.union(trait)
            let desc = font.fontDescriptor.withSymbolicTraits(traits) ?? font.fontDescriptor
            tv.font = UIFont(descriptor: desc, size: font.pointSize)
        }
    }
}


private extension UIFont {
    func toggle(_ trait: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let has = fontDescriptor.symbolicTraits.contains(trait)
        let traits = has
            ? fontDescriptor.symbolicTraits.subtracting(trait)
            : fontDescriptor.symbolicTraits.union(trait)
        let desc = fontDescriptor.withSymbolicTraits(traits) ?? fontDescriptor
        return UIFont(descriptor: desc, size: pointSize)
    }
}
