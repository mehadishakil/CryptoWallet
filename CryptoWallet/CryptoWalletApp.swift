import SwiftUI

@main
struct CryptoWalletApp: App {
//    var body: some Scene {
//        WindowGroup {
//            MainView()
//        }.modelContainer(for: [Invoice.self])
//    }
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @StateObject private var auth = AuthController()
    
    
    var body: some Scene {
        WindowGroup {
//            if hasCompletedOnboarding {
//                MainView()
//            } else {
//                WelcomeView()
//            }
            ContentView()
        }
        .modelContainer(for: [Invoice.self])
        .environmentObject(auth)
    }
}
