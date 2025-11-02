import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var donationVM = DonationViewModel()
    
    var body: some View {
        if auth.user == nil {
            ContentView()
        } else {
            DonorHomeView()
                .environmentObject(donationVM)
        }
    }
}
