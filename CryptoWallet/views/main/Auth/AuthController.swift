import Foundation
import SwiftUI

@MainActor
@Observable
class AuthController: ObservableObject {
    enum AuthState { case undefined, authenticated, unauthenticated, error(Error) }

       var authState: AuthState = .unauthenticated {
           didSet {
               self.log("authState changed to: \(authState)")
           }
       }

       var displayName: String = "anonymous" {
           didSet {
               self.log("displayName updated to: \(displayName)")
           }
       }

       var isAnonymousUser: Bool = true {
           didSet {
               self.log("isAnonymousUser updated to: \(isAnonymousUser)")
           }
       }

       func log(_ message: String) {
           print("[AuthController] \(message)")
       }
    // Persisted flag
    private let defaults = UserDefaults.standard
    private let authKey = "isAuthenticated"


    // MARK: – Call this when sign‑in succeeds
    func markSignedIn() {
        defaults.set(true, forKey: authKey)
        authState = .authenticated
    }

    // MARK: – Call this when you sign out
    func signOut() {
        defaults.set(false, forKey: authKey)
        authState = .unauthenticated
    }

    // MARK: – On launch, read the flag
    func loadUserData() async throws {
        let wasAuth = defaults.bool(forKey: authKey)
        authState = wasAuth ? .authenticated : .unauthenticated
    }
}
