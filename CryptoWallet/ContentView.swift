import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var auth: AuthController
    @AppStorage("SeedPhrase") private var sp: String = ""
    @AppStorage("walletAddress") private var walletAddress: String = ""
    
    var body: some View {
        Group {
                    switch auth.authState {
                    case .undefined:
                        ProgressView("Checking authentication…")
                            .progressViewStyle(CircularProgressViewStyle())
                    case .unauthenticated:
                        if walletAddress.isEmpty {
                            WelcomeView()
                        } else {
                            MainView(selectedIndex: 0, seedPhrase: sp)
                        }
                        
                    case .authenticated:
                        MainView(selectedIndex: 0, seedPhrase: sp)
                    case .error(let err):
                        // You can customize error handling here
                        VStack {
                            Text("Auth error:")
                            Text(err.localizedDescription)
                            Button("Retry") {
                                print("Retry authentication")
                            }
                        }
                    }
                }
        .task {
            auth.authState = .undefined
            do {
              try await auth.loadUserData()
            } catch {
              auth.authState = .unauthenticated
            }
        }

    }
}

#Preview {
    ContentView()
}
