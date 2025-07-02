import SwiftUI

@main
struct CryptoWalletApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }.modelContainer(for: [Invoice.self])
    }
}
