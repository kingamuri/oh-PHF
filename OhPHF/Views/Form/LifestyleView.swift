import SwiftUI

/// Screen 7 (page index 6): Lifestyle questions.
/// Covers smoking habits, alcohol consumption, and bruxism/nightguard use.
struct LifestyleView: View {
    @EnvironmentObject var formVM: FormViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.sectionSpacing) {
                    // MARK: - Section Header
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L("lifestyle.title"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            Text(L("lifestyle.subtitle"))
                                .font(Theme.captionFont)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: - Smoking
                    GlassCard {
                        YesNoToggle(
                            question: L("lifestyle.smoking"),
                            isYes: $formVM.form.lifestyleInfo.isSmoker
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(L("lifestyle.smokingAmount"))
                                    .font(Theme.captionFont)
                                    .foregroundStyle(.secondary)

                                Picker(
                                    L("lifestyle.smokingAmount"),
                                    selection: smokingAmountBinding
                                ) {
                                    ForEach(LifestyleInfo.SmokingAmount.allCases, id: \.self) { amount in
                                        Text(amount.displayString)
                                            .tag(amount)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }

                    // MARK: - Alcohol Consumption
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(L("lifestyle.alcohol"))
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.deepBlue)

                            Picker(
                                L("lifestyle.alcohol"),
                                selection: $formVM.form.lifestyleInfo.alcoholConsumption
                            ) {
                                ForEach(LifestyleInfo.AlcoholConsumption.allCases, id: \.self) { level in
                                    Text(alcoholDisplayName(level))
                                        .tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    // MARK: - Bruxism
                    GlassCard {
                        YesNoToggle(
                            question: L("lifestyle.bruxism"),
                            isYes: $formVM.form.lifestyleInfo.hasBruxism
                        ) {
                            YesNoToggle(
                                question: L("lifestyle.nightguard"),
                                isYes: $formVM.form.lifestyleInfo.hasNightguard
                            )
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

    /// Non-optional binding for the smoking amount picker.
    /// Defaults to `.oneToFive` when the stored value is `nil`.
    private var smokingAmountBinding: Binding<LifestyleInfo.SmokingAmount> {
        Binding(
            get: { formVM.form.lifestyleInfo.smokingAmount ?? .oneToFive },
            set: { formVM.form.lifestyleInfo.smokingAmount = $0 }
        )
    }

    /// Returns the localized display name for an alcohol consumption level.
    private func alcoholDisplayName(_ level: LifestyleInfo.AlcoholConsumption) -> String {
        switch level {
        case .never:        return L("lifestyle.alcohol.never")
        case .occasionally: return L("lifestyle.alcohol.occasionally")
        case .regularly:    return L("lifestyle.alcohol.regularly")
        case .daily:        return L("lifestyle.alcohol.daily")
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        SkyBackground()
        LifestyleView()
    }
    .environmentObject(FormViewModel())
    .environmentObject(LocalizationManager.shared)
}
