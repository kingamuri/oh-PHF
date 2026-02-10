import SwiftUI

struct DentalHistoryView: View {
    @EnvironmentObject var formVM: FormViewModel

    private var info: Binding<DentalHistoryInfo> {
        $formVM.form.dentalHistoryInfo
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.sectionSpacing) {
                    // MARK: - Visit Reason
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L("dental.visitReasonSection"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            HStack {
                                Text(L("dental.visitReason"))
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.deepBlue)
                                Spacer()
                                Picker(L("dental.visitReason"), selection: info.visitReason) {
                                    Text(L("dental.visitReason.select"))
                                        .tag(DentalHistoryInfo.VisitReason?.none)
                                    ForEach(DentalHistoryInfo.VisitReason.allCases, id: \.self) { reason in
                                        Text(L("dental.visitReason.\(reason.rawValue)"))
                                            .tag(DentalHistoryInfo.VisitReason?.some(reason))
                                    }
                                }
                                .labelsHidden()
                                .tint(Theme.accentBlue)
                            }

                            // Aesthetic sub-type picker
                            if formVM.form.dentalHistoryInfo.visitReason == .aesthetic {
                                HStack {
                                    Text(L("dental.aestheticType"))
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.deepBlue)
                                    Spacer()
                                    Picker(L("dental.aestheticType"), selection: info.aestheticSubType) {
                                        Text(L("dental.aestheticType.select"))
                                            .tag(DentalHistoryInfo.AestheticSubType?.none)
                                        ForEach(DentalHistoryInfo.AestheticSubType.allCases, id: \.self) { subType in
                                            Text(L("dental.aestheticType.\(subType.rawValue)"))
                                                .tag(DentalHistoryInfo.AestheticSubType?.some(subType))
                                        }
                                    }
                                    .labelsHidden()
                                    .tint(Theme.accentBlue)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: formVM.form.dentalHistoryInfo.visitReason)

                    // MARK: - BDD Screener (Aesthetic only)
                    if formVM.form.dentalHistoryInfo.visitReason == .aesthetic {
                        bddScreenerSection
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // MARK: - Last Dental Visit
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L("dental.lastVisitSection"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            HStack {
                                Text(L("dental.lastVisit"))
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.deepBlue)
                                Spacer()
                                Picker(L("dental.lastVisit"), selection: info.lastDentalVisit) {
                                    Text(L("dental.lastVisit.select"))
                                        .tag(DentalHistoryInfo.LastDentalVisit?.none)
                                    ForEach(DentalHistoryInfo.LastDentalVisit.allCases, id: \.self) { visit in
                                        Text(L("dental.lastVisit.\(visit.rawValue)"))
                                            .tag(DentalHistoryInfo.LastDentalVisit?.some(visit))
                                    }
                                }
                                .labelsHidden()
                                .tint(Theme.accentBlue)
                            }
                        }
                    }

                    // MARK: - Gum & TMJ
                    GlassCard {
                        VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                            YesNoToggle(
                                question: L("dental.bleedingGums"),
                                isYes: info.bleedingGums
                            )

                            Divider()

                            YesNoToggle(
                                question: L("dental.hasTMJ"),
                                isYes: info.hasTMJ
                            ) {
                                tmjSymptomsChecklist
                            }
                        }
                    }

                    // MARK: - Surgery & Anesthesia
                    GlassCard {
                        VStack(alignment: .leading, spacing: Theme.sectionSpacing) {
                            YesNoToggle(
                                question: L("dental.hadDentalSurgery"),
                                isYes: info.hadDentalSurgery
                            )

                            Divider()

                            YesNoToggle(
                                question: L("dental.hadAnesthesiaComplications"),
                                isYes: info.hadAnesthesiaComplications
                            ) {
                                TextField(
                                    L("dental.anesthesiaDetails"),
                                    text: info.anesthesiaComplicationDetails
                                )
                                .textFieldStyle(.roundedBorder)
                            }
                        }
                    }

                    // MARK: - Anxiety Level
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L("dental.anxietyLevel"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            Picker(L("dental.anxietyLevel"), selection: info.anxietyLevel) {
                                ForEach(DentalHistoryInfo.AnxietyLevel.allCases, id: \.self) { level in
                                    Text(L("dental.anxiety.\(level.rawValue)")).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }
                    }
                }
                .frame(maxWidth: Theme.maxFormWidth)
                .padding()
            }

            // MARK: - Navigation Bar
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
        .animation(.easeInOut(duration: 0.3), value: formVM.form.dentalHistoryInfo.visitReason)
    }

    // MARK: - BDD Screener Section

    private var bddScreenerSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 20) {
                Text(L("bdd.title"))
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.deepBlue)

                ForEach(0..<7, id: \.self) { index in
                    bddQuestionRow(index: index)

                    if index < 6 {
                        Divider()
                    }
                }
            }
        }
    }

    private func bddQuestionRow(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("bdd.q\(index + 1)"))
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.deepBlue)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { value in
                    bddOptionButton(questionIndex: index, value: value)
                }
            }
        }
    }

    private func bddOptionButton(questionIndex: Int, value: Int) -> some View {
        let isSelected = formVM.form.dentalHistoryInfo.bddScreener.questions[questionIndex] == value

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                formVM.form.dentalHistoryInfo.bddScreener.questions[questionIndex] = value
            }
        } label: {
            Text(L("bdd.q\(questionIndex + 1).a\(value)"))
                .font(Theme.captionFont)
                .foregroundStyle(isSelected ? .white : Theme.deepBlue)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
                .background(
                    isSelected
                        ? AnyShapeStyle(Theme.accentBlue)
                        : AnyShapeStyle(.ultraThinMaterial),
                    in: RoundedRectangle(cornerRadius: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isSelected ? Color.clear : Theme.softGray,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - TMJ Symptoms Checklist

    private var tmjSymptomsChecklist: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("dental.tmjSymptoms"))
                .font(Theme.captionFont)
                .foregroundStyle(.secondary)

            ForEach(DentalHistoryInfo.TMJSymptom.allCases, id: \.self) { symptom in
                tmjSymptomToggle(symptom: symptom)
            }
        }
    }

    private func tmjSymptomToggle(symptom: DentalHistoryInfo.TMJSymptom) -> some View {
        let isSelected = formVM.form.dentalHistoryInfo.tmjSymptoms.contains(symptom)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    formVM.form.dentalHistoryInfo.tmjSymptoms.removeAll { $0 == symptom }
                } else {
                    formVM.form.dentalHistoryInfo.tmjSymptoms.append(symptom)
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? Theme.accentBlue : Theme.softGray)
                    .font(.title3)

                Text(L("dental.tmj.\(symptom.rawValue)"))
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
        DentalHistoryView()
    }
    .environmentObject(FormViewModel())
    .environmentObject(SettingsViewModel())
    .environmentObject(LocalizationManager.shared)
}
