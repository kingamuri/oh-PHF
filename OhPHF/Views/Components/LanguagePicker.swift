import SwiftUI

/// Four-language picker with flag emojis and language names.
/// Reads and updates the current language via `LocalizationManager`.
struct LanguagePicker: View {
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        CompatGlassContainer(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(AppLanguage.allCases) { language in
                    languageButton(for: language)
                }
            }
        }
    }

    // MARK: - Language Button

    private func languageButton(for language: AppLanguage) -> some View {
        let isSelected = localization.language == language

        return Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                localization.language = language
            }
        } label: {
            HStack(spacing: 6) {
                Text(language.flag)
                    .font(.system(size: 18))

                Text(language.displayName)
                    .font(Theme.captionFont)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .white : Theme.deepBlue)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassBackground(
                isSelected
                    ? .interactiveTinted(Theme.accentBlue)
                    : .interactive,
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        SkyBackground()

        VStack(spacing: 24) {
            LanguagePicker()

            Text("Selected language updates the entire form.")
                .font(Theme.bodyFont)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    .environmentObject(LocalizationManager.shared)
}
