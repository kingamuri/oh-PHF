import Foundation

struct ClinicSettings: Codable {
    var clinicName: String = "oh! dental clinic"
    var clinicSubtitle: String = "Zahnklinik"
    var street: String = ""
    var postalCode: String = ""
    var city: String = "Vienna"
    var country: String = "Austria"
    var website: String = ""
    var email: String = ""
    var logoData: Data?
    var missedAppointmentFee: Int = 150
    var staffPIN: String = "1234"

    // SMTP configuration for automatic email delivery
    var smtpEnabled: Bool = false
    var smtpHost: String = ""       // e.g. "smtp.gmail.com"
    var smtpPort: Int = 465         // SSL/TLS port
    var smtpUsername: String = ""   // e.g. "clinic@gmail.com"
    var smtpPassword: String = ""   // App password (not regular password)

    var fullAddress: String {
        var components: [String] = []
        if !street.isEmpty {
            components.append(street)
        }
        let cityLine = [postalCode, city].filter { !$0.isEmpty }.joined(separator: " ")
        if !cityLine.isEmpty {
            components.append(cityLine)
        }
        if !country.isEmpty {
            components.append(country)
        }
        return components.joined(separator: ", ")
    }

    // MARK: - UserDefaults Persistence

    private static let storageKey = "clinicSettings"

    static func load() -> ClinicSettings {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return ClinicSettings()
        }

        do {
            let settings = try JSONDecoder().decode(ClinicSettings.self, from: data)
            return settings
        } catch {
            return ClinicSettings()
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: ClinicSettings.storageKey)
        } catch {
            print("Failed to save ClinicSettings: \(error.localizedDescription)")
        }
    }
}
