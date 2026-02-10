import SwiftUI

struct ContentView: View {
    @EnvironmentObject var formVM: FormViewModel
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ZStack {
            SkyBackground()

            if formVM.showThankYou {
                thankYouView
                    .transition(.opacity)
            } else {
                Group {
                    switch formVM.currentPage {
                    case 0:
                        WelcomeView()
                    case 1:
                        PersonalInfoView()
                    case 2:
                        MedicationsView()
                    case 3:
                        AllergiesView()
                    case 4:
                        MedicalConditionsView()
                    case 5:
                        WomensHealthView()
                    case 6:
                        LifestyleView()
                    case 7:
                        DentalHistoryView()
                    case 8:
                        ConsentsView()
                    default:
                        WelcomeView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: formVM.navigatingForward ? .trailing : .leading).combined(with: .opacity),
                    removal: .move(edge: formVM.navigatingForward ? .leading : .trailing).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.3), value: formVM.currentPage)
                .environment(\.layoutDirection, localization.isRTL ? .rightToLeft : .leftToRight)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: formVM.showThankYou)
    }

    // MARK: - Thank You View

    private var thankYouView: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.accentBlue)
                .bounceEffectCompat(value: formVM.showThankYou)

            Text(L("thankYou.title"))
                .font(Theme.titleFont)
                .foregroundStyle(Theme.deepBlue)
                .multilineTextAlignment(.center)

            Text(L("thankYou.message"))
                .font(Theme.bodyFont)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: Theme.maxFormWidth)
    }
}

// MARK: - Symbol Effect Compat

private extension View {
    @ViewBuilder
    func bounceEffectCompat(value: Bool) -> some View {
        if #available(iOS 17.0, *) {
            self.symbolEffect(.bounce, value: value)
        } else {
            self
        }
    }
}
