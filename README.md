
# DevNotes 📝

**DevNotes** is a modern, fast, and minimal **note-taking application built with SwiftUI**.  
It targets **macOS and iOS**, focusing on productivity features such as tagging, pinning, searching, and sharing notes with a clean user experience.

---

## ✨ Features

- 🗒️ **Note Management**
  - Title & rich text content
  - Pinned notes
  - Date-based sorting

- 🏷️ **Tag System**
  - Colorful tags with icons
  - Filter notes by tags
  - Centralized `TagStore` management

- 🔍 **Smart Search**
  - Search across titles and content
  - Real-time filtering

- ⏰ **Reminders (Optional)**
  - Date & time based reminder infrastructure

- 📤 **Sharing**
  - Native ShareSheet support

- 🌗 **Dark / Light Mode**
  - Fully compatible with system appearance

---

## 🧱 Architecture

- **SwiftUI**
- **MVVM pattern**
- **ObservableObject & State-driven UI**
- **Modular view structure**
- **Central Store logic (TagStore)**

---

## 📁 Project Structure

```text
DevNotes/
├── Models/
│   ├── Note.swift
│   └── Tag.swift
├── Stores/
│   └── TagStore.swift
├── Views/
│   ├── ContentView.swift
│   ├── AddNoteView.swift
│   ├── TagManagerView.swift
│   └── Components/
├── Utilities/
│   └── ShareSheet.swift
├── Assets.xcassets
└── DevNotesApp.swift
```

---

## 🚀 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/zinkxx/devnotes.git
   ```

2. Open with Xcode:
   ```
   DevNotes.xcodeproj
   ```

3. Run the project (`⌘ + R`)

---

## 🧪 Development Notes

- Code readability and maintainability are top priorities
- Views are small and responsibility-focused
- UI follows Apple Human Interface Guidelines

---

## 🛣️ Roadmap

- [ ] CoreData integration
- [ ] iCloud sync
- [ ] Markdown export
- [ ] Advanced reminders
- [ ] Widget support

---

## 👤 Author

**Zinkx (Said Kaya)**  
Software Developer · UI/UX focused  
GitHub: https://github.com/zinkxx

---

## 📄 License

MIT License — free to use, modify, and distribute.

