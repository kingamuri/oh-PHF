import SwiftUI

/// Screen 6 (page index 5): Women's health questions.
/// Only displayed when the patient's gender is `.female`.
/// Covers pregnancy, breastfeeding, and oral contraceptive use.
struct WomensHealthView: View {
    @EnvironmentObject var formVM: FormViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.sectionSpacing) {
                    // MARK: - Section Header
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L("womensHealth.title"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            Text(L("womensHealth.subtitle"))
                                .font(Theme.captionFont)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: - Pregnancy
                    GlassCard {
                        YesNoToggle(
                            question: L("womensHealth.pregnant"),
                            isYes: $formVM.form.womensHealthInfo.isPregnant
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(L("womensHealth.trimester"))
                                    .font(Theme.captionFont)
                                    .foregroundStyle(.secondary)

                                Picker(
                                    L("womensHealth.trimester"),
                                    selection: trimesterBinding
                                ) {
                                    ForEach(WomensHealthInfo.Trimester.allCases, id: \.self) { trimester in
                                        Text(trimesterDisplayName(trimester))
                                            .tag(trimester)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }

                    // MARK: - Breastfeeding
                    GlassCard {
                        YesNoToggle(
                            question: L("womensHealth.breastfeeding"),
                            isYes: $formVM.form.womensHealthInfo.isBreastfeeding
                        )
                    }

                    // MARK: - Oral Contraceptives
                    GlassCard {
                        YesNoToggle(
                            question: L("womensHealth.contraceptives"),
                            isYes: $formVM.form.womensHealthInfo.takingContraceptives
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("womensHealth.contraceptiveType"))
                                    .font(Theme.captionFont)
                                    .foregroundStyle(.secondary)

                                TextField(
                                    L("womensHealth.contraceptiveTypePlaceholder"),
                                    text: $formVM.form.womensHealthInfo.contraceptiveType
                                )
                                .glassField()
                            }
                        }
                    }
                }
                .frame(maxWidth: Theme.maxFormWidth)
                .padding()
            }

            // MARK: - Navigation
            FormNavigationBar(
                currentPage: formVM.effectivePageIndex,
                totalPages: formVM.effectiveTotalPages,
                pageTitle: formVM.currentPageTitle,
                canGoBack: formVM.currentPage > 0,
                isLastPage: false,
                isSubmitting: false,
                onBack: { formVM.previousPage() },
                onNext: { formVM.nextPage() },
                onSubmit: {}
            )
        }
    }

    // MARK: - Helpers

    /// Non-optional binding for the trimester picker.
    /// Defaults to `.first` when the stored value is `nil`.
    private var trimesterBinding: Binding<WomensHealthInfo.Trimester> {
        Binding(
            get: { formVM.form.womensHealthInfo.trimester ?? .first },
            set: { formVM.form.womensHealthInfo.trimester = $0 }
        )
    }

    /// Returns the localized display name for a trimester case.
    private func trimesterDisplayName(_ trimester: WomensHealthInfo.Trimester) -> String {
        switch trimester {
        case .first:  return L("womensHealth.trimester.first")
        case .second: return L("womensHealth.trimester.second")
        case .third:  return L("womensHealth.trimester.third")
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        SkyBackground()
        WomensHealthView()
    }
    .environmentObject({
        let vm = FormViewModel()
        vm.form.personalInfo.gender = .female
        return vm
    }())
    .environmentObject(LocalizationManager.shared)
}
