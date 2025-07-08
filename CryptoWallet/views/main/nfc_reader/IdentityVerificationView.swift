//import SwiftUI
//import Persona2  // For Persona SDK v2
//// Note: NFC functionality is built into Persona2, no separate import needed
//
//// MARK: - Main Identity Verification View
//struct IdentityVerificationView: View {
//    @StateObject private var viewModel = IdentityVerificationViewModel()
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 30) {
//                // Header
//                VStack(spacing: 16) {
//                    Image(systemName: "person.badge.shield.checkmark")
//                        .font(.system(size: 60))
//                        .foregroundColor(.blue)
//                    
//                    Text("Identity Verification")
//                        .font(.title)
//                        .fontWeight(.bold)
//                    
//                    Text("We'll help you verify your identity using your government-issued ID")
//                        .font(.body)
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.secondary)
//                        .padding(.horizontal)
//                }
//                
//                Spacer()
//                
//                // Status Section
//                VStack(spacing: 16) {
//                    if viewModel.isLoading {
//                        ProgressView()
//                            .scaleEffect(1.2)
//                        
//                        Text("Starting verification...")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    } else {
//                        StatusView(
//                            message: viewModel.statusMessage,
//                            type: viewModel.statusType
//                        )
//                    }
//                }
//                
//                Spacer()
//                
//                // Action Button
//                Button(action: {
//                    viewModel.startVerification()
//                }) {
//                    HStack {
//                        if !viewModel.isLoading {
//                            Image(systemName: "doc.text.magnifyingglass")
//                        }
//                        Text(viewModel.isLoading ? "Processing..." : "Start Identity Verification")
//                    }
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(viewModel.isLoading ? Color.gray : Color.blue)
//                    .cornerRadius(12)
//                }
//                .disabled(viewModel.isLoading)
//                .padding(.horizontal)
//                
//                // Info Text
//                Text("Your ID will be scanned using NFC technology for enhanced security")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//            }
//            .padding()
//            .navigationBarHidden(true)
//            .alert("Verification Result", isPresented: $viewModel.showAlert) {
//                switch viewModel.alertType {
//                case .success:
//                    Button("Continue") {
//                        viewModel.handleSuccessAction()
//                    }
//                case .failure:
//                    Button("Try Again") {
//                        viewModel.resetStatus()
//                    }
//                    Button("Cancel", role: .cancel) { }
//                case .review:
//                    Button("OK") { }
//                case .error:
//                    Button("Try Again") {
//                        viewModel.resetStatus()
//                    }
//                    Button("Cancel", role: .cancel) { }
//                }
//            } message: {
//                Text(viewModel.alertMessage)
//            }
//        }
//    }
//}
//
//// MARK: - Status View Component
//struct StatusView: View {
//    let message: String
//    let type: StatusType
//    
//    var body: some View {
//        HStack {
//            Image(systemName: type.iconName)
//                .foregroundColor(type.color)
//                .font(.title2)
//            
//            Text(message)
//                .font(.body)
//                .foregroundColor(type.color)
//        }
//        .padding()
//        .background(type.color.opacity(0.1))
//        .cornerRadius(8)
//    }
//}
//
//// MARK: - Status Type Enum
//enum StatusType {
//    case ready, success, failure, review, error
//    
//    var color: Color {
//        switch self {
//        case .ready: return .primary
//        case .success: return .green
//        case .failure: return .red
//        case .review: return .orange
//        case .error: return .red
//        }
//    }
//    
//    var iconName: String {
//        switch self {
//        case .ready: return "checkmark.circle"
//        case .success: return "checkmark.circle.fill"
//        case .failure: return "xmark.circle.fill"
//        case .review: return "clock.circle.fill"
//        case .error: return "exclamationmark.triangle.fill"
//        }
//    }
//}
//
//// MARK: - Alert Type Enum
//enum AlertType {
//    case success, failure, review, error
//}
//
//// MARK: - View Model
//class IdentityVerificationViewModel: ObservableObject, InquiryDelegate {
//    
//    // MARK: - Published Properties
//    @Published var isLoading = false
//    @Published var statusMessage = "Ready to start verification"
//    @Published var statusType: StatusType = .ready
//    @Published var showAlert = false
//    @Published var alertMessage = ""
//    @Published var alertType: AlertType = .success
//    
//    // MARK: - Private Properties
//    private let templateId = "itmpl_EXAMPLE" // Replace with your actual template ID
//    private var currentInquiry: Inquiry?
//    private var hostingController: UIViewController?
//    
//    // MARK: - Public Methods
//    func startVerification() {
//        isLoading = true
//        statusMessage = "Preparing verification..."
//        
//        // Build the inquiry with NFC support
//        currentInquiry = Inquiry.from(templateId: templateId, delegate: self)
//            .referenceId(generateUserReferenceId())
//            // NFC support is built into Persona2 SDK - no need for separate adapter
//            .locale("en") // Set locale if needed
//            .fields(getPrefilledFields())
//            .build()
//        
//        // Start the inquiry from the root view controller
//        DispatchQueue.main.async {
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let window = windowScene.windows.first,
//               let rootViewController = window.rootViewController {
//                
//                // Find the topmost view controller
//                let topController = self.findTopViewController(from: rootViewController)
//                self.currentInquiry?.start(from: topController)
//            }
//        }
//    }
//    
//    func resetStatus() {
//        isLoading = false
//        statusMessage = "Ready to start verification"
//        statusType = .ready
//        showAlert = false
//    }
//    
//    func handleSuccessAction() {
//        // Handle successful verification - navigate or update app state
//        // You can use a coordinator pattern or notification center here
//        NotificationCenter.default.post(name: .verificationCompleted, object: nil)
//    }
//    
//    // MARK: - Private Methods
//    private func generateUserReferenceId() -> String {
//        // Replace with your actual user ID from your system
//        return "user_\(UUID().uuidString.prefix(8))"
//    }
//    
//    private func getPrefilledFields() -> [String: InquiryField] {
//        // Pre-fill any known user information
//        return [
//            "name_first": .string(""), // Add user's first name if available
//            "name_last": .string(""),  // Add user's last name if available
//            // Add other fields as needed
//        ]
//    }
//    
//    private func findTopViewController(from controller: UIViewController) -> UIViewController {
//        if let presented = controller.presentedViewController {
//            return findTopViewController(from: presented)
//        } else if let navigationController = controller as? UINavigationController {
//            return findTopViewController(from: navigationController.visibleViewController ?? navigationController)
//        } else if let tabController = controller as? UITabBarController {
//            return findTopViewController(from: tabController.selectedViewController ?? tabController)
//        }
//        return controller
//    }
//    
//    private func sendVerificationResultsToBackend(inquiryId: String, status: String, fields: [String: InquiryField]) {
//        // Implement your backend API call here
//        print("Sending verification results to backend:")
//        print("Inquiry ID: \(inquiryId)")
//        print("Status: \(status)")
//        
//        // Example API call structure:
//        /*
//        let verificationData = VerificationResult(
//            inquiryId: inquiryId,
//            status: status,
//            fields: convertFieldsToDict(fields),
//            userId: getCurrentUserId(),
//            timestamp: Date()
//        )
//        
//        APIManager.shared.submitVerificationResults(verificationData) { result in
//            // Handle API response
//        }
//        */
//    }
//    
//    // MARK: - InquiryDelegate Methods
//    func inquiryComplete(inquiryId: String, status: String, fields: [String : InquiryField]) {
//        print("✅ Inquiry completed - ID: \(inquiryId), Status: \(status)")
//        
//        // Send results to backend
//        sendVerificationResultsToBackend(inquiryId: inquiryId, status: status, fields: fields)
//        
//        DispatchQueue.main.async {
//            self.isLoading = false
//            
//            switch status.lowercased() {
//            case "completed":
//                self.statusMessage = "Verification completed successfully!"
//                self.statusType = .success
//                self.alertType = .success
//                self.alertMessage = "Your identity has been verified successfully!"
//                self.showAlert = true
//                
//            case "failed":
//                self.statusMessage = "Verification failed"
//                self.statusType = .failure
//                self.alertType = .failure
//                self.alertMessage = "We couldn't verify your identity. Please check your documents and try again."
//                self.showAlert = true
//                
//            case "needs_review":
//                self.statusMessage = "Verification under review"
//                self.statusType = .review
//                self.alertType = .review
//                self.alertMessage = "Your verification is being reviewed. You'll receive a notification once it's complete."
//                self.showAlert = true
//                
//            default:
//                self.statusMessage = "Verification status: \(status)"
//                self.statusType = .ready
//            }
//        }
//    }
//    
//    func inquiryCanceled(inquiryId: String?, sessionToken: String?) {
//        print("❌ Inquiry canceled - ID: \(inquiryId ?? "unknown")")
//        
//        DispatchQueue.main.async {
//            self.isLoading = false
//            self.statusMessage = "Verification canceled"
//            self.statusType = .ready
//        }
//    }
//    
//    func inquiryError(_ error: Error) {
//        print("❌ Inquiry error: \(error.localizedDescription)")
//        
//        DispatchQueue.main.async {
//            self.isLoading = false
//            self.statusMessage = "Verification error occurred"
//            self.statusType = .error
//            self.alertType = .error
//            self.alertMessage = "An error occurred during verification: \(error.localizedDescription)"
//            self.showAlert = true
//        }
//    }
//}
//
//// MARK: - Notification Extension
//extension Notification.Name {
//    static let verificationCompleted = Notification.Name("verificationCompleted")
//}
//
//// MARK: - Data Models (Optional)
//struct VerificationResult {
//    let inquiryId: String
//    let status: String
//    let fields: [String: Any]
//    let userId: String
//    let timestamp: Date
//}
//
//// MARK: - Preview
//struct IdentityVerificationView_Previews: PreviewProvider {
//    static var previews: some View {
//        IdentityVerificationView()
//    }
//}
//
//// MARK: - App Integration Example
///*
//// In your main App file or ContentView:
//
//struct ContentView: View {
//    @State private var showVerification = false
//    @State private var isVerified = false
//    
//    var body: some View {
//        VStack {
//            if isVerified {
//                Text("✅ Identity Verified!")
//                    .font(.title)
//                    .foregroundColor(.green)
//            } else {
//                Button("Start Identity Verification") {
//                    showVerification = true
//                }
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//            }
//        }
//        .sheet(isPresented: $showVerification) {
//            IdentityVerificationView()
//        }
//        .onReceive(NotificationCenter.default.publisher(for: .verificationCompleted)) { _ in
//            isVerified = true
//            showVerification = false
//        }
//    }
//}
//*/
