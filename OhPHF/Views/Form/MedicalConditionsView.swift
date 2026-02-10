import SwiftUI

/// Screen 5 (page index 4): Medical conditions checklist.
/// Displays 15 collapsible condition sections, each with yes/no toggle,
/// optional sub-option checkboxes, and a free-text details field.
struct MedicalConditionsView: View {
    @EnvironmentObject var formVM: FormViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.sectionSpacing) {
                    // MARK: - Section Header
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L("conditions.title"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            Text(L("conditions.subtitle"))
                                .font(Theme.captionFont)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: - 1. Cardiovascular
                    GlassCard {
                        conditionRow(
                            title: L("conditions.cardiovascular"),
                            entry: $formVM.form.medicalConditionInfo.cardiovascular,
                            subOptions: [
                                L("conditions.cardiovascular.hypertension"),
                                L("conditions.cardiovascular.hypotension"),
                                L("conditions.cardiovascular.heartAttack"),
                                L("conditions.cardiovascular.angina"),
                                L("conditions.cardiovascular.heartFailure"),
                                L("conditions.cardiovascular.valveDisease"),
                                L("conditions.cardiovascular.arrhythmia"),
                                L("conditions.cardiovascular.stroke")
                            ]
                        )
                    }

                    // MARK: - 2. Pacemaker / Defibrillator
                    GlassCard {
                        conditionRow(
                            title: L("conditions.pacemaker"),
                            entry: $formVM.form.medicalConditionInfo.pacemaker
                        )
                    }

                    // MARK: - 3. Blood Disorders
                    GlassCard {
                        conditionRow(
                            title: L("conditions.bloodDisorders"),
                            entry: $formVM.form.medicalConditionInfo.bloodDisorders,
                            subOptions: [
                                L("conditions.bloodDisorders.anemia"),
                                L("conditions.bloodDisorders.hemophilia"),
                                L("conditions.bloodDisorders.thrombosis")
                            ]
                        )
                    }

                    // MARK: - 4. Diabetes
                    GlassCard {
                        conditionRow(
                            title: L("conditions.diabetes"),
                            entry: $formVM.form.medicalConditionInfo.diabetes,
                            subOptions: [
                                L("conditions.diabetes.type1"),
                                L("conditions.diabetes.type2")
                            ]
                        )
                    }

                    // MARK: - 5. Respiratory
                    GlassCard {
                        conditionRow(
                            title: L("conditions.respiratory"),
                            entry: $formVM.form.medicalConditionInfo.respiratory,
                            subOptions: [
                                L("conditions.respiratory.asthma"),
                                L("conditions.respiratory.copd"),
                                L("conditions.respiratory.sleepApnea")
                            ]
                        )
                    }

                    // MARK: - 6. Epilepsy / Seizures
                    GlassCard {
                        conditionRow(
                            title: L("conditions.epilepsy"),
                            entry: $formVM.form.medicalConditionInfo.epilepsy
                        )
                    }

                    // MARK: - 7. Infectious Diseases
                    GlassCard {
                        conditionRow(
                            title: L("conditions.infectiousDiseases"),
                            entry: $formVM.form.medicalConditionInfo.infectiousDiseases,
                            subOptions: [
                                L("conditions.infectiousDiseases.hiv"),
                                L("conditions.infectiousDiseases.hepatitisB"),
                                L("conditions.infectiousDiseases.hepatitisC"),
                                L("conditions.infectiousDiseases.tuberculosis"),
                                L("conditions.infectiousDiseases.other")
                            ]
                        )
                    }

                    // MARK: - 8. Liver Disease
                    GlassCard {
                        conditionRow(
                            title: L("conditions.liverDisease"),
                            entry: $formVM.form.medicalConditionInfo.liverDisease
                        )
                    }

                    // MARK: - 9. Kidney Disease
                    GlassCard {
                        conditionRow(
                            title: L("conditions.kidneyDisease"),
                            entry: $formVM.form.medicalConditionInfo.kidneyDisease
                        )
                    }

                    // MARK: - 10. Thyroid Disorders
                    GlassCard {
                        conditionRow(
                            title: L("conditions.thyroidDisorders"),
                            entry: $formVM.form.medicalConditionInfo.thyroidDisorders
                        )
                    }

                    // MARK: - 11. Osteoporosis
                    GlassCard {
                        conditionRow(
                            title: L("conditions.osteoporosis"),
                            entry: $formVM.form.medicalConditionInfo.osteoporosis,
                            subOptions: [
                                L("conditions.osteoporosis.alendronate"),
                                L("conditions.osteoporosis.zoledronicAcid"),
                                L("conditions.osteoporosis.denosumab"),
                                L("conditions.osteoporosis.other")
                            ]
                        )
                    }

                    // MARK: - 12. Autoimmune Disease
                    GlassCard {
                        conditionRow(
                            title: L("conditions.autoimmune"),
                            entry: $formVM.form.medicalConditionInfo.autoimmune
                        )
                    }

                    // MARK: - 13. Radiation to Head/Neck
                    GlassCard {
                        conditionRow(
                            title: L("conditions.headNeckRadiation"),
                            entry: $formVM.form.medicalConditionInfo.headNeckRadiation
                        )
                    }

                    // MARK: - 14. Chemotherapy
                    GlassCard {
                        conditionRow(
                            title: L("conditions.chemotherapy"),
                            entry: $formVM.form.medicalConditionInfo.chemotherapy
                        )
                    }

                    // MARK: - 15. Other Conditions
                    GlassCard {
                        conditionRow(
                            title: L("conditions.otherConditions"),
                            entry: $formVM.form.medicalConditionInfo.otherConditions
                        )
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

    // MARK: - Reusable Condition Row

    /// Builds a collapsible condition section with a yes/no toggle,
    /// optional sub-option checkboxes, and a details text field.
    ///
    /// - Parameters:
    ///   - title: The localized condition name displayed as the question.
    ///   - entry: Binding to the `ConditionEntry` in the form model.
    ///   - subOptions: Optional array of localized sub-option labels.
    ///     When provided, each option renders as a tappable checkbox row.
    ///     Selected options are stored in `entry.subOptions`.
    private func conditionRow(
        title: String,
        entry: Binding<ConditionEntry>,
        subOptions: [String]? = nil
    ) -> some View {
        YesNoToggle(
            question: title,
            isYes: entry.isPresent
        ) {
            VStack(alignment: .leading, spacing: 12) {
                // Sub-option checkboxes (if any)
                if let subOptions {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(subOptions, id: \.self) { option in
                            subOptionCheckbox(option: option, entry: entry)
                        }
                    }
                }

                // Details text field
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("conditions.detailsPlaceholder"))
                        .font(Theme.captionFont)
                        .foregroundStyle(.secondary)

                    TextField(L("conditions.detailsPlaceholder"), text: entry.details)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }

    // MARK: - Sub-Option Checkbox

    /// A single tappable checkbox row for a sub-option within a condition.
    /// Toggles the option in/out of `entry.subOptions`.
    private func subOptionCheckbox(
        option: String,
        entry: Binding<ConditionEntry>
    ) -> some View {
        let isSelected = entry.wrappedValue.subOptions.contains(option)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    entry.wrappedValue.subOptions.removeAll { $0 == option }
                } else {
                    entry.wrappedValue.subOptions.append(option)
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Theme.accentBlue : Theme.softGray)

                Text(option)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.deepBlue)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        SkyBackground()
        MedicalConditionsView()
    }
    .environmentObject(FormViewModel())
    .environmentObject(LocalizationManager.shared)
}
