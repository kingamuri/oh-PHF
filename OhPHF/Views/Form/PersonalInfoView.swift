import SwiftUI

struct PersonalInfoView: View {
    @EnvironmentObject var formVM: FormViewModel

    private var info: Binding<PersonalInfo> {
        $formVM.form.personalInfo
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: Theme.sectionSpacing) {
                    // MARK: - Validation Errors
                    if !formVM.validationErrors.isEmpty {
                        validationBanner
                    }

                    // MARK: - Name Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L("personal.nameSection"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            // Title
                            HStack {
                                Text(L("personal.title"))
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.deepBlue)
                                Spacer()
                                Picker(L("personal.title"), selection: info.title) {
                                    ForEach(PersonalInfo.Title.allCases, id: \.self) { title in
                                        Text(L("personal.title.\(title.rawValue)")).tag(title)
                                    }
                                }
                                .labelsHidden()
                                .tint(Theme.accentBlue)
                            }

                            // First Name
                            TextField(L("personal.firstName"), text: info.firstName)
                                .textFieldStyle(.roundedBorder)

                            // Last Name
                            TextField(L("personal.lastName"), text: info.lastName)
                                .textFieldStyle(.roundedBorder)

                            // Date of Birth
                            DatePicker(
                                L("personal.dateOfBirth"),
                                selection: Binding(
                                    get: { formVM.form.personalInfo.dateOfBirth ?? Date() },
                                    set: { formVM.form.personalInfo.dateOfBirth = $0 }
                                ),
                                displayedComponents: .date
                            )
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.deepBlue)

                            // Gender
                            VStack(alignment: .leading, spacing: 8) {
                                Text(L("personal.gender"))
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.deepBlue)

                                Picker(L("personal.gender"), selection: info.gender) {
                                    ForEach(PersonalInfo.Gender.allCases, id: \.self) { gender in
                                        Text(L("personal.gender.\(gender.rawValue)")).tag(gender)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .labelsHidden()
                            }
                        }
                    }

                    // MARK: - Address Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L("personal.addressSection"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            TextField(L("personal.street"), text: info.street)
                                .textFieldStyle(.roundedBorder)

                            HStack(spacing: 12) {
                                TextField(L("personal.postalCode"), text: info.postalCode)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .frame(maxWidth: 140)

                                TextField(L("personal.city"), text: info.city)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text(L("personal.country"))
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.deepBlue)
                                Spacer()
                                Picker(L("personal.country"), selection: info.country) {
                                    ForEach(Self.countries, id: \.self) { country in
                                        Text(country).tag(country)
                                    }
                                }
                                .labelsHidden()
                                .tint(Theme.accentBlue)
                            }
                        }
                    }

                    // MARK: - Contact Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L("personal.contactSection"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            TextField(L("personal.phone"), text: info.phone)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.phonePad)

                            TextField(L("personal.email"), text: info.email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                    }

                    // MARK: - Insurance Section
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L("personal.insuranceSection"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            HStack {
                                Text(L("personal.insuranceType"))
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.deepBlue)
                                Spacer()
                                Picker(L("personal.insuranceType"), selection: info.insuranceType) {
                                    ForEach(PersonalInfo.InsuranceType.allCases, id: \.self) { type in
                                        Text(L("personal.insurance.\(type.rawValue)")).tag(type)
                                    }
                                }
                                .labelsHidden()
                                .tint(Theme.accentBlue)
                            }

                            TextField(L("personal.insuranceName"), text: info.insuranceName)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    // MARK: - Profession
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L("personal.professionSection"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            TextField(L("personal.profession"), text: info.profession)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    // MARK: - Emergency Contact
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L("personal.emergencySection"))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.deepBlue)

                            TextField(L("personal.emergencyName"), text: info.emergencyContactName)
                                .textFieldStyle(.roundedBorder)

                            TextField(L("personal.emergencyPhone"), text: info.emergencyContactPhone)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.phonePad)
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

    // MARK: - Validation Banner

    private var validationBanner: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(formVM.validationErrors, id: \.self) { error in
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                        Text(error)
                            .font(Theme.captionFont)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }

    // MARK: - Country List

    private static let countries = [
        "Austria",
        "Germany",
        "Switzerland",
        "Liechtenstein",
        "Italy",
        "Czech Republic",
        "Slovakia",
        "Hungary",
        "Slovenia",
        "Croatia",
        "Poland",
        "France",
        "Netherlands",
        "Belgium",
        "United Kingdom",
        "Turkey",
        "Serbia",
        "Bosnia and Herzegovina",
        "Romania",
        "Bulgaria",
        "Other"
    ]
}

#Preview {
    ZStack {
        SkyBackground()
        PersonalInfoView()
    }
    .environmentObject(FormViewModel())
    .environmentObject(LocalizationManager.shared)
}
