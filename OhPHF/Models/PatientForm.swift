import Foundation

// MARK: - PatientForm

struct PatientForm: Codable {
    var patientNumber: String = ""
    var language: String = "de"
    var personalInfo = PersonalInfo()
    var medicationInfo = MedicationInfo()
    var allergyInfo = AllergyInfo()
    var medicalConditionInfo = MedicalConditionInfo()
    var womensHealthInfo = WomensHealthInfo()
    var lifestyleInfo = LifestyleInfo()
    var dentalHistoryInfo = DentalHistoryInfo()
    var consentInfo = ConsentInfo()
    var signatureData: Data? // PNG data of signature
    var submissionDate: Date?
}

// MARK: - PersonalInfo

struct PersonalInfo: Codable {
    var title: Title = .mr
    var firstName: String = ""
    var lastName: String = ""
    var dateOfBirth: Date?
    var gender: Gender = .male
    var street: String = ""
    var postalCode: String = ""
    var city: String = ""
    var country: String = "Austria"
    var phone: String = ""
    var email: String = ""
    var insuranceType: InsuranceType = .public
    var insuranceName: String = ""
    var profession: String = ""
    var emergencyContactName: String = ""
    var emergencyContactPhone: String = ""

    enum Title: String, Codable, CaseIterable {
        case mr = "Mr"
        case mrs = "Mrs"
        case diverse = "Diverse"
        case child = "Child"
    }

    enum Gender: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case diverse = "Diverse"
    }

    enum InsuranceType: String, Codable, CaseIterable {
        case `public` = "Public"
        case `private` = "Private"
        case selfPay = "SelfPay"
        case other = "Other"
    }
}

// MARK: - MedicationInfo

struct MedicationInfo: Codable {
    var isUnderTreatment: Bool = false
    var doctorName: String = ""
    var treatmentReason: String = ""
    var takingMedications: Bool = false
    var medicationsList: String = ""
    var takingBloodThinners: Bool = false
    var bloodThinnerType: BloodThinnerType = .aspirin

    enum BloodThinnerType: String, Codable, CaseIterable {
        case aspirin = "Aspirin"
        case marcumar = "Marcumar"
        case xarelto = "Xarelto"
        case eliquis = "Eliquis"
        case pradaxa = "Pradaxa"
        case heparin = "Heparin"
        case clopidogrel = "Clopidogrel"
        case other = "Other"
    }
}

// MARK: - AllergyInfo

struct AllergyInfo: Codable {
    var hasAllergies: Bool = false
    var allergyTypes: [AllergyType] = []
    var otherAllergyText: String = ""

    enum AllergyType: String, Codable, CaseIterable {
        case penicillin = "Penicillin"
        case localAnesthetics = "LocalAnesthetics"
        case latex = "Latex"
        case iodine = "Iodine"
        case nsaids = "NSAIDs"
        case metals = "Metals"
        case other = "Other"
    }
}

// MARK: - ConditionEntry

struct ConditionEntry: Codable {
    var isPresent: Bool = false
    var details: String = ""
    var subOptions: [String] = []
}

// MARK: - MedicalConditionInfo

struct MedicalConditionInfo: Codable {
    var cardiovascular = ConditionEntry()
    var pacemaker = ConditionEntry()
    var bloodDisorders = ConditionEntry()
    var diabetes = ConditionEntry()
    var respiratory = ConditionEntry()
    var epilepsy = ConditionEntry()
    var infectiousDiseases = ConditionEntry()
    var liverDisease = ConditionEntry()
    var kidneyDisease = ConditionEntry()
    var thyroidDisorders = ConditionEntry()
    var osteoporosis = ConditionEntry()
    var autoimmune = ConditionEntry()
    var headNeckRadiation = ConditionEntry()
    var chemotherapy = ConditionEntry()
    var otherConditions = ConditionEntry()
}

// MARK: - WomensHealthInfo

struct WomensHealthInfo: Codable {
    var isPregnant: Bool = false
    var trimester: Trimester?
    var isBreastfeeding: Bool = false
    var takingContraceptives: Bool = false
    var contraceptiveType: String = ""

    enum Trimester: String, Codable, CaseIterable {
        case first = "First"
        case second = "Second"
        case third = "Third"
    }
}

// MARK: - LifestyleInfo

struct LifestyleInfo: Codable {
    var isSmoker: Bool = false
    var smokingAmount: SmokingAmount?
    var alcoholConsumption: AlcoholConsumption = .never
    var hasBruxism: Bool = false
    var hasNightguard: Bool = false

    enum SmokingAmount: String, Codable, CaseIterable {
        case oneToFive = "1-5"
        case fiveToTen = "5-10"
        case tenToTwenty = "10-20"
        case twentyPlus = "20+"

        var displayString: String {
            switch self {
            case .oneToFive: return "1-5 per day"
            case .fiveToTen: return "5-10 per day"
            case .tenToTwenty: return "10-20 per day"
            case .twentyPlus: return "20+ per day"
            }
        }
    }

    enum AlcoholConsumption: String, Codable, CaseIterable {
        case never = "Never"
        case occasionally = "Occasionally"
        case regularly = "Regularly"
        case daily = "Daily"
    }
}

// MARK: - DentalHistoryInfo

struct DentalHistoryInfo: Codable {
    var visitReason: VisitReason?
    var aestheticSubType: AestheticSubType?
    var bddScreener = BDDScreener()
    var lastDentalVisit: LastDentalVisit?
    var bleedingGums: Bool = false
    var hasTMJ: Bool = false
    var tmjSymptoms: [TMJSymptom] = []
    var hadDentalSurgery: Bool = false
    var hadAnesthesiaComplications: Bool = false
    var anesthesiaComplicationDetails: String = ""
    var anxietyLevel: AnxietyLevel = .none

    enum VisitReason: String, Codable, CaseIterable {
        case checkup = "Checkup"
        case pain = "Pain"
        case aesthetic = "Aesthetic"
        case implant = "Implant"
        case bracesStrightening = "BracesStrightening"
        case continuation = "Continuation"
        case other = "Other"
    }

    enum AestheticSubType: String, Codable, CaseIterable {
        case veneers = "Veneers"
        case veneerRevision = "VeneerRevision"
        case compositeBonding = "CompositeBonding"
        case printedVeneers = "PrintedVeneers"
        case smileMakeover = "SmileMakeover"
    }

    enum LastDentalVisit: String, Codable, CaseIterable {
        case lessThan6Months = "LessThan6Months"
        case sixToTwelveMonths = "6To12Months"
        case oneToTwoYears = "1To2Years"
        case moreThanTwoYears = "MoreThan2Years"
        case never = "Never"
    }

    enum TMJSymptom: String, Codable, CaseIterable {
        case clicking = "Clicking"
        case pain = "Pain"
        case limitedOpening = "LimitedOpening"
        case locking = "Locking"
    }

    enum AnxietyLevel: String, Codable, CaseIterable {
        case none = "None"
        case mild = "Mild"
        case moderate = "Moderate"
        case severe = "Severe"
    }
}

// MARK: - BDDScreener

struct BDDScreener: Codable {
    /// 7 questions scored on a 0-3 scale. -1 means unanswered.
    var questions: [Int] = Array(repeating: -1, count: 7)
}

// MARK: - ConsentInfo

struct ConsentInfo: Codable {
    var gdprConsent: Bool = false
    var drivingAcknowledgment: Bool = false
    var missedAppointmentConsent: Bool = false
    var photosInternal: Bool = false
    var photosResearch: Bool = false
    var photosMarketing: Bool = false
}
