import SwiftUI

struct ThemePickerView: View {

    let selectedTheme: AppTheme
    let onSelect: (AppTheme) -> Void

    var body: some View {
        List {
            ForEach(AppTheme.allCases) { theme in
                HStack(spacing: 12) {

                    Image(systemName: theme.icon)
                        .foregroundColor(.accentColor)
                        .frame(width: 24)

                    Text(theme.rawValue)

                    Spacer()

                    if theme == selectedTheme {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(theme)
                }
            }
        }
        .navigationTitle("Tema")
    }
}
