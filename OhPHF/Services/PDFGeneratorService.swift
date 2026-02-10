import UIKit

struct PDFGeneratorService {

    /// Load a localized string for the patient's chosen language (safe to call off MainActor).
    private static func localizedString(_ key: String, language: String) -> String {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }

    private static func localizedString(_ key: String, language: String, _ args: CVarArg...) -> String {
        let format = localizedString(key, language: language)
        return String(format: format, arguments: args)
    }

    // MARK: - Public

    static func generatePDF(form: PatientForm, settings: ClinicSettings) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { context in
            var yPosition: CGFloat = 0
            let margin: CGFloat = 40
            let contentWidth = pageRect.width - 2 * margin

            // MARK: Helpers

            func startNewPage() {
                context.beginPage()
                yPosition = margin
            }

            func checkPageBreak(needed: CGFloat) {
                if yPosition + needed > pageRect.height - margin {
                    startNewPage()
                }
            }

            func drawText(
                _ text: String,
                font: UIFont,
                color: UIColor = .black,
                x: CGFloat = margin,
                maxWidth: CGFloat? = nil
            ) {
                let width = maxWidth ?? contentWidth
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color
                ]
                let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
                let boundingRect = (text as NSString).boundingRect(
                    with: constraintRect,
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                checkPageBreak(needed: boundingRect.height + 5)
                (text as NSString).draw(
                    in: CGRect(x: x, y: yPosition, width: width, height: boundingRect.height),
                    withAttributes: attributes
                )
                yPosition += boundingRect.height + 5
            }

            func drawSectionHeader(_ title: String) {
                yPosition += 10
                checkPageBreak(needed: 30)
                drawText(
                    title,
                    font: .boldSystemFont(ofSize: 14),
                    color: UIColor(red: 0.17, green: 0.37, blue: 0.54, alpha: 1)
                )
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: yPosition))
                path.addLine(to: CGPoint(x: pageRect.width - margin, y: yPosition))
                UIColor.lightGray.setStroke()
                path.lineWidth = 0.5
                path.stroke()
                yPosition += 8
            }

            func drawField(label: String, value: String) {
                guard !value.isEmpty else { return }
                drawText("\(label): \(value)", font: .systemFont(ofSize: 10))
            }

            func drawYesNo(label: String, value: Bool, details: String? = nil) {
                let answer = value ? "Yes" : "No"
                drawText("\(label): \(answer)", font: .systemFont(ofSize: 10))
                if value, let details, !details.isEmpty {
                    drawText(
                        "  \u{2192} \(details)",
                        font: .italicSystemFont(ofSize: 9),
                        color: .darkGray
                    )
                }
            }

            // MARK: Page 1 – Header

            startNewPage()

            if let logoData = settings.logoData, let logo = UIImage(data: logoData) {
                let logoSize: CGFloat = 50
                logo.draw(in: CGRect(x: margin, y: yPosition, width: logoSize, height: logoSize))
                let infoX = margin + logoSize + 10
                let infoWidth = contentWidth - logoSize - 10
                let savedY = yPosition
                drawText(settings.clinicName, font: .boldSystemFont(ofSize: 16), x: infoX, maxWidth: infoWidth)
                if !settings.clinicSubtitle.isEmpty {
                    drawText(settings.clinicSubtitle, font: .systemFont(ofSize: 10), color: .gray, x: infoX, maxWidth: infoWidth)
                }
                let address = settings.fullAddress
                if !address.isEmpty {
                    drawText(address, font: .systemFont(ofSize: 9), color: .gray, x: infoX, maxWidth: infoWidth)
                }
                if !settings.website.isEmpty {
                    drawText(settings.website, font: .systemFont(ofSize: 9), color: .gray, x: infoX, maxWidth: infoWidth)
                }
                yPosition = max(yPosition, savedY + logoSize + 10)
            } else {
                drawText(settings.clinicName, font: .boldSystemFont(ofSize: 18))
                if !settings.clinicSubtitle.isEmpty {
                    drawText(settings.clinicSubtitle, font: .systemFont(ofSize: 11), color: .gray)
                }
            }

            yPosition += 5
            drawText("Patient History Form", font: .boldSystemFont(ofSize: 16))
            drawField(label: "Patient No.", value: form.patientNumber)

            if let date = form.submissionDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                drawField(label: "Date", value: formatter.string(from: date))
            }

            // MARK: Personal Information

            drawSectionHeader("Personal Information")

            let pi = form.personalInfo
            drawField(label: "Salutation", value: pi.salutation.rawValue)
            drawField(label: "Name", value: pi.fullName)

            if let dob = pi.dateOfBirth {
                let df = DateFormatter()
                df.dateStyle = .medium
                drawField(label: "Date of Birth", value: df.string(from: dob))
            }

            drawField(label: "Gender", value: pi.gender.rawValue)

            let addressParts = [pi.street, pi.postalCode, pi.city, pi.country]
                .filter { !$0.isEmpty }
                .joined(separator: ", ")
            drawField(label: "Address", value: addressParts)
            drawField(label: "Phone", value: pi.phone)
            drawField(label: "Email", value: pi.email)
            drawField(label: "Insurance", value: "\(pi.insuranceType.rawValue) - \(pi.insuranceName)")
            drawField(label: pi.insuranceType == .public ? "SV-Nr." : "Policy No.", value: pi.insuranceNumber)
            drawField(label: "Profession", value: pi.profession)

            if !pi.emergencyContactName.isEmpty {
                drawField(
                    label: "Emergency Contact",
                    value: "\(pi.emergencyContactName) (\(pi.emergencyContactPhone))"
                )
            }

            // MARK: Medications

            drawSectionHeader("Medications")

            let med = form.medicationInfo
            drawYesNo(
                label: "Under medical treatment",
                value: med.isUnderTreatment,
                details: med.isUnderTreatment
                    ? "\(med.doctorName) - \(med.treatmentReason)"
                    : nil
            )
            drawYesNo(
                label: "Taking medications",
                value: med.takingMedications,
                details: med.medicationsList
            )
            if med.takingBloodThinners {
                drawYesNo(
                    label: "Blood thinners",
                    value: true,
                    details: med.bloodThinnerType.rawValue
                )
            }

            // MARK: Allergies

            drawSectionHeader("Allergies")

            let allergy = form.allergyInfo
            if allergy.hasAllergies {
                let types = allergy.allergyTypes.map(\.rawValue).joined(separator: ", ")
                drawYesNo(label: "Allergies", value: true, details: types)
                if !allergy.otherAllergyText.isEmpty {
                    drawText(
                        "  Other: \(allergy.otherAllergyText)",
                        font: .italicSystemFont(ofSize: 9)
                    )
                }
            } else {
                drawYesNo(label: "Allergies", value: false)
            }

            // MARK: Medical Conditions

            drawSectionHeader("Medical Conditions")

            let mc = form.medicalConditionInfo
            let conditions: [(String, ConditionEntry)] = [
                ("Cardiovascular", mc.cardiovascular),
                ("Pacemaker/Defibrillator", mc.pacemaker),
                ("Blood disorders", mc.bloodDisorders),
                ("Diabetes", mc.diabetes),
                ("Respiratory", mc.respiratory),
                ("Epilepsy", mc.epilepsy),
                ("Infectious diseases", mc.infectiousDiseases),
                ("Liver disease", mc.liverDisease),
                ("Kidney disease", mc.kidneyDisease),
                ("Thyroid disorders", mc.thyroidDisorders),
                ("Osteoporosis", mc.osteoporosis),
                ("Autoimmune", mc.autoimmune),
                ("Head/neck radiation", mc.headNeckRadiation),
                ("Chemotherapy", mc.chemotherapy),
                ("Other", mc.otherConditions)
            ]

            var hasAnyCondition = false
            for (name, entry) in conditions {
                if entry.isPresent {
                    hasAnyCondition = true
                    var detail = entry.details
                    if !entry.subOptions.isEmpty {
                        let sub = entry.subOptions.joined(separator: ", ")
                        detail += detail.isEmpty ? sub : "; \(sub)"
                    }
                    drawYesNo(label: name, value: true, details: detail.isEmpty ? nil : detail)
                }
            }

            if !hasAnyCondition {
                drawText(
                    "No medical conditions reported",
                    font: .italicSystemFont(ofSize: 10),
                    color: .gray
                )
            }

            // MARK: Women's Health

            if form.personalInfo.gender == .female {
                drawSectionHeader("Women's Health")
                let wh = form.womensHealthInfo
                drawYesNo(label: "Pregnant", value: wh.isPregnant, details: wh.trimester?.rawValue)
                drawYesNo(label: "Breastfeeding", value: wh.isBreastfeeding)
                drawYesNo(
                    label: "Oral contraceptives",
                    value: wh.takingContraceptives,
                    details: wh.contraceptiveType
                )
            }

            // MARK: Lifestyle

            drawSectionHeader("Lifestyle")

            let ls = form.lifestyleInfo
            drawYesNo(label: "Smoker", value: ls.isSmoker, details: ls.smokingAmount?.rawValue)
            drawField(label: "Alcohol", value: ls.alcoholConsumption.rawValue)
            drawYesNo(
                label: "Bruxism",
                value: ls.hasBruxism,
                details: ls.hasNightguard ? "Wears nightguard" : nil
            )

            // MARK: Dental History

            drawSectionHeader("Dental History")

            let dh = form.dentalHistoryInfo
            if let reason = dh.visitReason {
                drawField(label: "Visit reason", value: reason.rawValue)
                if reason == .aesthetic, let subType = dh.aestheticSubType {
                    drawField(label: "Aesthetic type", value: subType.rawValue)
                }
            }
            if let lastVisit = dh.lastDentalVisit {
                drawField(label: "Last dental visit", value: lastVisit.rawValue)
            }
            drawYesNo(label: "Bleeding gums", value: dh.bleedingGums)
            drawYesNo(
                label: "TMJ issues",
                value: dh.hasTMJ,
                details: dh.tmjSymptoms.isEmpty
                    ? nil
                    : dh.tmjSymptoms.map(\.rawValue).joined(separator: ", ")
            )
            drawYesNo(label: "Prior dental surgery", value: dh.hadDentalSurgery)
            drawYesNo(
                label: "Anesthesia complications",
                value: dh.hadAnesthesiaComplications,
                details: dh.anesthesiaComplicationDetails
            )
            drawField(label: "Anxiety level", value: dh.anxietyLevel.rawValue)

            // MARK: BDD Risk Badge (aesthetic visits)

            if dh.visitReason == .aesthetic {
                let score = BDDScorer.calculateScore(from: dh.bddScreener)
                let risk = BDDScorer.riskLevel(for: score)
                yPosition += 5

                let badgeText = "BDD Risk: \(risk.label) (\(score)/21)"
                let badgeFont = UIFont.boldSystemFont(ofSize: 11)
                let badgeSize = (badgeText as NSString).size(
                    withAttributes: [.font: badgeFont]
                )
                let badgeRect = CGRect(
                    x: margin,
                    y: yPosition,
                    width: badgeSize.width + 16,
                    height: badgeSize.height + 8
                )
                checkPageBreak(needed: badgeRect.height + 10)

                let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: 6)
                let riskUIColor: UIColor
                switch risk {
                case .green:
                    riskUIColor = UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1)
                case .yellow:
                    riskUIColor = UIColor(red: 1.00, green: 0.76, blue: 0.03, alpha: 1)
                case .orange:
                    riskUIColor = UIColor(red: 1.00, green: 0.60, blue: 0.00, alpha: 1)
                case .red:
                    riskUIColor = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1)
                }
                riskUIColor.setFill()
                badgePath.fill()

                let textColor: UIColor = (risk == .yellow) ? .black : .white
                (badgeText as NSString).draw(
                    at: CGPoint(x: badgeRect.minX + 8, y: badgeRect.minY + 4),
                    withAttributes: [.font: badgeFont, .foregroundColor: textColor]
                )
                yPosition += badgeRect.height + 10
            }

            // MARK: Consents

            let lang = form.language

            drawSectionHeader(localizedString("consent.title", language: lang))

            // Privacy Notice (full text for legal record)
            drawText(
                localizedString("consent.privacyTitle", language: lang),
                font: .boldSystemFont(ofSize: 10)
            )
            drawText(
                localizedString("consent.privacyNotice", language: lang),
                font: .systemFont(ofSize: 8),
                color: .darkGray
            )
            yPosition += 5

            let consent = form.consentInfo
            let checkmark = "\u{2713}"
            let xmark = "\u{2717}"

            // Each consent with exact text as shown to the patient
            drawText(
                "\(consent.gdprConsent ? checkmark : xmark) \(localizedString("consent.gdpr", language: lang))",
                font: .systemFont(ofSize: 9)
            )
            drawText(
                "\(consent.drivingAcknowledgment ? checkmark : xmark) \(localizedString("consent.driving", language: lang))",
                font: .systemFont(ofSize: 9)
            )
            drawText(
                "\(consent.missedAppointmentConsent ? checkmark : xmark) \(localizedString("consent.missedAppointment", language: lang, settings.missedAppointmentFee))",
                font: .systemFont(ofSize: 9)
            )
            drawText(
                "\(consent.photosInternal ? checkmark : xmark) \(localizedString("consent.photosInternal", language: lang))",
                font: .systemFont(ofSize: 9)
            )
            drawText(
                "\(consent.photosResearch ? checkmark : xmark) \(localizedString("consent.photosResearch", language: lang))",
                font: .systemFont(ofSize: 9)
            )
            drawText(
                "\(consent.photosMarketing ? checkmark : xmark) \(localizedString("consent.photosMarketing", language: lang))",
                font: .systemFont(ofSize: 9)
            )

            // MARK: Signature

            yPosition += 10

            if let sigData = form.signatureData, let sigImage = UIImage(data: sigData) {
                let maxSigWidth: CGFloat = 250
                let maxSigHeight: CGFloat = 120
                let aspect = sigImage.size.width / max(sigImage.size.height, 1)
                let sigWidth = min(maxSigWidth, maxSigHeight * aspect)
                let sigHeight = sigWidth / max(aspect, 0.1)

                checkPageBreak(needed: sigHeight + 30)
                drawText("Patient Signature:", font: .boldSystemFont(ofSize: 10))
                sigImage.draw(in: CGRect(x: margin, y: yPosition, width: sigWidth, height: sigHeight))
                yPosition += sigHeight + 10
            }

            if let date = form.submissionDate {
                let df = DateFormatter()
                df.dateStyle = .long
                df.timeStyle = .short
                drawText("Date: \(df.string(from: date))", font: .systemFont(ofSize: 9))
            }
        }

        return data
    }
}
