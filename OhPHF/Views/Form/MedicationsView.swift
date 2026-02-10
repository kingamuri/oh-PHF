import SwiftUI

struct MedicationsView: View {
    @EnvironmentObject var formVM: FormViewModel

    private var medInfo: Binding<MedicationInfo> {
        $formVM.form.medicationInfo
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.sectionSpacing) {
                    // MARK: - Under Medical Treatment
                    GlassCard {
                        YesNoToggle(
                            question: L("medications.underTreatment"),
                            isYes: medInfo.isUnderTreatment
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                TextField(L("medications.doctorName"), text: medInfo.doctorName)
                                    .glassField()

                                TextField(L("medications.treatmentReason"), text: medInfo.treatmentReason)
                                    .glassField()
                            }
                        }
                    }

                    // MARK: - Taking Medications
                    GlassCard {
                        YesNoToggle(
                            question: L("medications.takingMedications"),
                            isYes: medInfo.takingMedications
                        ) {
                            VStack(alignment: .leading, spacing: 14) {
                                // Medications list (multiline)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(L("medications.listLabel"))
                                        .font(Theme.captionFont)
                                        .foregroundStyle(.secondary)

                                    TextEditor(text: medInfo.medicationsList)
                                        .frame(minHeight: 80)
                                        .scrollContentBackground(.hidden)
                                        .padding(8)
                                        .glassBackground(.regular, in: RoundedRectangle(cornerRadius: 8))
                                }

                                // Blood thinners sub-question
                                YesNoToggle(
                                    question: L("medications.bloodThinners"),
                                    isYes: medInfo.takingBloodThinners
                                ) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(L("medications.bloodThinnerType"))
                                            .font(Theme.captionFont)
                                            .foregroundStyle(.secondary)

                                        Picker(L("medications.bloodThinnerType"), selection: medInfo.bloodThinnerType) {
                                            ForEach(MedicationInfo.BloodThinnerType.allCases, id: \.self) { type in
                                                Text(L("medications.thinner.\(type.rawValue)")).tag(type)
                                            }
                                        }
                                        .labelsHidden()
                                        .tint(Theme.accentBlue)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: Theme.maxFormWidth)
                .padding()
            }

            // MARK: - Navigation Bar
            FormNavigationBar(
                currentPage: formVM.currentPage,
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
}

#Preview {
    ZStack {
        SkyBackground()
        MedicationsView()
    }
    .environmentObject(FormViewModel())
    .environmentObject(LocalizationManager.shared)
}
