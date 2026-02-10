import SwiftUI

struct ContentView: View {
    @EnvironmentObject var formVM: FormViewModel
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ZStack {
            SkyBackground()

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
}
