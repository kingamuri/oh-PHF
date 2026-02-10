import SwiftUI

struct PinEntryView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Environment(\.dismiss) var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    private let maxPinLength = 6

    var body: some View {
        ZStack {
            SkyBackground()

            VStack(spacing: 30) {
                Spacer()

                headerSection
                pinDotsSection
                errorSection
                numberPadSection

                Spacer()

                cancelButton
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield")
                .font(.system(size: 40))
                .foregroundStyle(Theme.accentBlue)

            Text(L("enter_staff_pin"))
                .font(Theme.headlineFont)
                .foregroundStyle(Theme.deepBlue)
        }
    }

    // MARK: - PIN Dots

    private var pinDotsSection: some View {
        HStack(spacing: 12) {
            ForEach(0..<maxPinLength, id: \.self) { index in
                Circle()
                    .fill(
                        index < settingsVM.pinInput.count
                            ? Theme.accentBlue
                            : Theme.softGray
                    )
                    .frame(width: 16, height: 16)
                    .animation(.easeInOut(duration: 0.15), value: settingsVM.pinInput.count)
            }
        }
    }

    // MARK: - Error Message

    @ViewBuilder
    private var errorSection: some View {
        if settingsVM.pinError {
            Text(L("incorrect_pin"))
                .foregroundStyle(.red)
                .font(Theme.captionFont)
                .transition(.opacity.combined(with: .scale))
        }
    }

    // MARK: - Number Pad

    private var numberPadSection: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(1...9, id: \.self) { digit in
                numberButton("\(digit)") {
                    appendDigit("\(digit)")
                }
            }

            // Empty space (bottom-left)
            Color.clear
                .frame(height: 64)

            // Zero button (bottom-center)
            numberButton("0") {
                appendDigit("0")
            }

            // Delete button (bottom-right)
            Button {
                deleteLastDigit()
            } label: {
                Image(systemName: "delete.backward")
                    .font(.title2)
                    .foregroundStyle(Theme.deepBlue)
                    .frame(width: 72, height: 64)
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }
        }
        .frame(maxWidth: 280)
    }

    // MARK: - Cancel

    private var cancelButton: some View {
        Button {
            settingsVM.pinInput = ""
            settingsVM.pinError = false
            dismiss()
        } label: {
            Text(L("cancel"))
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.accentBlue)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Number Button

    private func numberButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.deepBlue)
                .frame(width: 72, height: 64)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 12)
                )
        }
    }

    // MARK: - Logic

    private func appendDigit(_ digit: String) {
        guard settingsVM.pinInput.count < maxPinLength else { return }

        settingsVM.pinError = false
        settingsVM.pinInput += digit

        // Auto-verify when the PIN length matches the stored PIN length
        if settingsVM.pinInput.count == settingsVM.settings.staffPIN.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                _ = settingsVM.verifyPIN()
            }
        }
    }

    private func deleteLastDigit() {
        guard !settingsVM.pinInput.isEmpty else { return }
        settingsVM.pinInput.removeLast()
        settingsVM.pinError = false
    }
}

#Preview {
    PinEntryView()
        .environmentObject(SettingsViewModel())
}
