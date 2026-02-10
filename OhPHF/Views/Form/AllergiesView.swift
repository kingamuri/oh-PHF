import SwiftUI

struct AllergiesView: View {
    @EnvironmentObject var formVM: FormViewModel

    private var allergyInfo: Binding<AllergyInfo> {
        $formVM.form.allergyInfo
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.sectionSpacing) {
                    // MARK: - Allergies
                    GlassCard {
                        YesNoToggle(
                            question: L("allergies.hasAllergies"),
                            isYes: allergyInfo.hasAllergies
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L("allergies.selectTypes"))
                                    .font(Theme.captionFont)
                                    .foregroundStyle(.secondary)

                                // Allergy type checklist
                                ForEach(AllergyInfo.AllergyType.allCases, id: \.self) { allergyType in
                                    allergyToggleRow(for: allergyType)
                                }

                                // Other allergy text field
                                ConditionalSubform(
                                    isExpanded: formVM.form.allergyInfo.allergyTypes.contains(.other)
                                ) {
                                    TextField(
                                        L("allergies.otherPlaceholder"),
                                        text: allergyInfo.otherAllergyText
                                    )
                                    .glassField()
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

    // MARK: - Allergy Toggle Row

    private func allergyToggleRow(for allergyType: AllergyInfo.AllergyType) -> some View {
        let isSelected = formVM.form.allergyInfo.allergyTypes.contains(allergyType)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    formVM.form.allergyInfo.allergyTypes.removeAll { $0 == allergyType }
                } else {
                    formVM.form.allergyInfo.allergyTypes.append(allergyType)
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Theme.accentBlue : Theme.softGray)

                Text(L("allergies.type.\(allergyType.rawValue)"))
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.deepBlue)

                Spacer()
            }
            .padding(10)
            .glassBackground(
                isSelected
                    ? .interactiveTinted(Theme.accentBlue.opacity(0.15))
                    : .interactive,
                in: RoundedRectangle(cornerRadius: 10)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        SkyBackground()
        AllergiesView()
    }
    .environmentObject(FormViewModel())
    .environmentObject(LocalizationManager.shared)
}
