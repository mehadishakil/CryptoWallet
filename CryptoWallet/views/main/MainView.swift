//import SwiftUI
//
//struct MainView: View {
//    
//    @State var selectedIndex = 0
//    
//    
//    var body: some View {
//        
//        ZStack(alignment: .bottom) {
//            
//            
//            Color(.white)
//                .edgesIgnoringSafeArea(.all)
//            
//            
//            
//            ZStack {
//                switch selectedIndex {
//                case 0:
//                    ScrollView { HomeView() }
//                case 1:
//                    // Identitiy verfication with persona
//                case 2:
//                    ScrollView { ScanView() }
//                case 3:
//                    InvoiceScreenView() // No ScrollView wrapper
//                default:
//                        RadialGradient(gradient: Gradient(colors: [Color("#7A17D7"), Color("#ED74CD"), Color("#EBB5A3")]), center: .topTrailing, startRadius: 100, endRadius: 800)
//                            .frame(height: 550)
//                            .edgesIgnoringSafeArea(.top)
//                        
//                        ProfileView()
//                            .padding(.top, 50)
//
//                }
//            }
//            .edgesIgnoringSafeArea(.top)
//            
//            
//            
//            
//            
//            
//            BottomNavigationView(selectedIndex: $selectedIndex)
//                .edgesIgnoringSafeArea(.bottom)
//            
//        }
//        .navigationBarBackButtonHidden()
//        .preferredColorScheme(.dark)
//        
//        
//    }
//}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
//
//struct BottomNavigationView: View {
//    
//    @Binding var selectedIndex: Int
//    
//    let icons = [
//        "house",
//        "magnifyingglass",
//        "qrcode.viewfinder",
//        "text.document",
//        "person"
//    ]
//    
//    var body: some View {
//        VStack {
//            
//            ZStack {
//                Divider()
//                    .shadow(radius: 10)
//                
//                ZStack {
//                    
//                }
//                .frame(maxWidth: .infinity, maxHeight: 50)
//                .background(.white)
//                
//                
//                
//                
//                HStack {
//                    
//                    ForEach(0..<5, id: \.self) { number in
//                        Spacer()
//                        
//                        Button(action: {
//                            self.selectedIndex = number
//                        }, label: {
//                            if number == 2 {
//                                Image(systemName: icons[number])
//                                    .font(.system(size: 25, weight: .regular, design: .rounded))
//                                    .foregroundColor(.white)
//                                    .frame(width: 40, height: 40)
//                                    .padding(2)
//                                    .background(selectedIndex == number ? .black : Color(UIColor.lightGray))
//                                    .cornerRadius(30)
//                            } else {
//                                Image(systemName: icons[number])
//                                    .font(.system(size: 25, weight: .regular, design: .rounded))
//                                    .foregroundColor(selectedIndex == number ? .black : Color(UIColor.lightGray))
//                            }
//                        })
//                        
//                        Spacer()
//                        
//                        
//                    }
//                }
//                
//                
//            }
//            
//            
//            
//            
//        }
//    }
//}
//
//


import SwiftUI
import Persona2
import AVFoundation

struct MainView: View {

    @State var selectedIndex = 0
    @StateObject private var verificationManager = VerificationManager()

    // Navigation states for the new flow
    @State private var showVerifyDocumentView = false
    @State private var showCountrySelectionView = false
    @State private var showUploadIDPhotoView = false
    @State private var showNFCScanInstructionView = false

    var body: some View {
        TabView {
            ScrollView { HomeView() }
                .tabItem { Label("Home", systemImage: "house") }

            ScrollView {
                IdentityVerificationView()
                    .environmentObject(verificationManager) // Pass the environment object
                    .onChange(of: verificationManager.verificationStatus) { status in
                        if status == .completed {
                            showVerifyDocumentView = true // Trigger the next step
                        }
                    }
            }
            .tabItem { Label("Verification", systemImage: "touchid") }

            ScrollView { ScanView() }
                .tabItem { Label("Scan", systemImage: "qrcode.viewfinder") }
            
            ScrollView { InvoiceScreenView() }
                .tabItem { Label("Invoice", systemImage: "document") }

            SettingsScreen()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .background(.ultraThinMaterial)
        .edgesIgnoringSafeArea(.bottom)
        .tint(.primary)

        
//        NavigationStack { // Use NavigationStack for iOS 16+ or NavigationView for older versions
//            ZStack(alignment: .bottom) {
//
//                Color(.white)
//                    .edgesIgnoringSafeArea(.all)
//
//                ZStack {
//                    switch selectedIndex {
//                    case 0:
//                        ScrollView { HomeView() } // Placeholder for HomeView
//                    case 1:
//                        ScrollView {
//                            IdentityVerificationView()
//                                .environmentObject(verificationManager) // Pass the environment object
//                                .onChange(of: verificationManager.verificationStatus) { status in
//                                    if status == .completed {
//                                        showVerifyDocumentView = true // Trigger the next step
//                                    }
//                                }
//                        }
//                    case 2:
//                        ScrollView { ScanView() } // Placeholder for ScanView
//                    case 3:
//                        InvoiceScreenView()
//                        //WalletView() // Placeholder for WalletView
//
//                    default:
//                        RadialGradient(gradient: Gradient(colors: [Color("#7A17D7"), Color("#ED74CD"), Color("#EBB5A3")]), center: .topTrailing, startRadius: 100, endRadius: 800)
//                            .frame(height: 550)
//                            .edgesIgnoringSafeArea(.top)
//
//                        SettingsScreen() // Placeholder for ProfileView
//                            .padding(.top, 50)
//                    }
//                }
//                .edgesIgnoringSafeArea(.top)
//
//                BottomNavigationView(selectedIndex: $selectedIndex, verificationStatus: verificationManager.verificationStatus)
//                    .edgesIgnoringSafeArea(.bottom)
//            }
//            .navigationBarBackButtonHidden()
//            .preferredColorScheme(.dark)
//            .onReceive(NotificationCenter.default.publisher(for: .verificationCompleted)) { _ in
//                selectedIndex = 0 // Navigate back to home after successful verification
//            }
//            // Navigation Destinations
//            .navigationDestination(isPresented: $showVerifyDocumentView) {
//                VerifyDocumentView(showCountrySelectionView: $showCountrySelectionView)
//            }
//            .navigationDestination(isPresented: $showCountrySelectionView) {
//                CountrySelectionView(showUploadIDPhotoView: $showUploadIDPhotoView)
//            }
//            .navigationDestination(isPresented: $showUploadIDPhotoView) {
//                UploadIDPhotoView(showNFCScanInstructionView: $showNFCScanInstructionView)
//            }
//            .navigationDestination(isPresented: $showNFCScanInstructionView) {
//                NFCScanInstructionView()
//            }
//        }
    }
}

// MARK: - Verification Manager
class VerificationManager: ObservableObject {
    @Published var verificationStatus: VerificationStatus = .notStarted

    enum VerificationStatus {
        case notStarted
        case inProgress
        case completed
        case failed
        case underReview
    }
}

// MARK: - Identity Verification View (Integrated)
struct IdentityVerificationView: View {
    @StateObject private var viewModel = IdentityVerificationViewModel()
    @EnvironmentObject var verificationManager: VerificationManager

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.shield.checkmark")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("Identity Verification")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)

                        Text("Verify your identity using your government-issued ID with NFC technology")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 50)

                    Spacer()

                    // Status Section
                    VStack(spacing: 16) {
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.2)

                            Text("Starting verification...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            StatusView(
                                message: viewModel.statusMessage,
                                type: viewModel.statusType
                            )
                        }
                    }

                    Spacer()

                    Button("Test Camera Access") {
                        let descriptionExists = Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") != nil

                        if !descriptionExists {
                            print("❌ NSCameraUsageDescription is missing in Info.plist — app will crash if camera is accessed!")
                            return
                        }

                        AVCaptureDevice.requestAccess(for: .video) { granted in
                            if granted {
                                print("✅ Camera access granted")
                            } else {
                                print("❌ Camera access denied")
                            }
                        }
                    }

                    Spacer()

                    // Action Button
                    Button(action: {
                        viewModel.startVerification()
                    }) {
                        HStack {
                            if !viewModel.isLoading {
                                Image(systemName: "doc.text.magnifyingglass")
                            }
                            Text(viewModel.isLoading ? "Processing..." : "Start Identity Verification")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isLoading ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal)

                    // Info Text
                    VStack(spacing: 8) {
                        Text("🔒 Your data is encrypted and secure")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("📱 NFC scanning provides enhanced security")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 30)

                    Spacer()
                }
                .padding()
            }
        }
        .alert("Verification Result", isPresented: $viewModel.showAlert) {
            switch viewModel.alertType {
            case .success:
                Button("Continue") {
                    viewModel.handleSuccessAction()
                }
            case .failure:
                Button("Try Again") {
                    viewModel.resetStatus()
                }
                Button("Cancel", role: .cancel) { }
            case .review:
                Button("OK") { }
            case .error:
                Button("Try Again") {
                    viewModel.resetStatus()
                }
                Button("Cancel", role: .cancel) { }
            }
        } message: {
            Text(viewModel.alertMessage)
        }
        .onChange(of: viewModel.verificationState) { state in
            // Update the verification manager
            switch state {
            case .notStarted:
                verificationManager.verificationStatus = .notStarted
            case .inProgress:
                verificationManager.verificationStatus = .inProgress
            case .completed:
                verificationManager.verificationStatus = .completed
            case .failed:
                verificationManager.verificationStatus = .failed
            case .underReview:
                verificationManager.verificationStatus = .underReview
            }
        }
    }
}

// MARK: - Enhanced View Model
class IdentityVerificationViewModel: ObservableObject, InquiryDelegate {

    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var statusMessage = "Ready to start verification"
    @Published var statusType: StatusType = .ready
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var alertType: AlertType = .success
    @Published var verificationState: VerificationState = .notStarted

    // MARK: - Private Properties
    private let templateId = "itmpl_ZVr1RAzzvL5uA578dWLuR3e1dXkx" // Replace with your actual template ID
    private var currentInquiry: Inquiry?

    enum VerificationState {
        case notStarted, inProgress, completed, failed, underReview
    }

    // MARK: - Public Methods
    func startVerification() {
        isLoading = true
        verificationState = .inProgress
        statusMessage = "Preparing verification..."

        // Build the inquiry
        currentInquiry = Inquiry.from(templateId: templateId, delegate: self)
            .referenceId(generateUserReferenceId())
            .locale("en")
            .fields(getPrefilledFields())
            .environment(.sandbox)
            .build()

        // Start the inquiry from the root view controller
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {

                let topController = self.findTopViewController(from: rootViewController)
                self.currentInquiry?.start(from: topController)
            }
        }
    }

    func resetStatus() {
        isLoading = false
        verificationState = .notStarted
        statusMessage = "Ready to start verification"
        statusType = .ready
        showAlert = false
    }

    func handleSuccessAction() {
        NotificationCenter.default.post(name: .verificationCompleted, object: nil)
    }

    // MARK: - Private Methods
    private func generateUserReferenceId() -> String {
        return "user_\(UUID().uuidString.prefix(8))"
    }

    private func getPrefilledFields() -> [String: InquiryField] {
        return [
            "name_first": .string(""),
            "name_last": .string(""),
        ]
    }

    private func findTopViewController(from controller: UIViewController) -> UIViewController {
        if let presented = controller.presentedViewController {
            return findTopViewController(from: presented)
        } else if let navigationController = controller as? UINavigationController {
            return findTopViewController(from: navigationController.visibleViewController ?? navigationController)
        } else if let tabController = controller as? UITabBarController {
            return findTopViewController(from: tabController.selectedViewController ?? tabController)
        }
        return controller
    }

    // MARK: - InquiryDelegate Methods
    func inquiryComplete(inquiryId: String, status: String, fields: [String : InquiryField]) {
        print("✅ Inquiry completed - ID: \(inquiryId), Status: \(status)")

        DispatchQueue.main.async {
            self.isLoading = false

            switch status.lowercased() {
            case "completed":
                self.verificationState = .completed
                self.statusMessage = "Verification completed successfully!"
                self.statusType = .success
                self.alertType = .success
                self.alertMessage = "Your identity has been verified successfully!"
                self.showAlert = true

            case "failed":
                self.verificationState = .failed
                self.statusMessage = "Verification failed"
                self.statusType = .failure
                self.alertType = .failure
                self.alertMessage = "We couldn't verify your identity. Please check your documents and try again."
                self.showAlert = true

            case "needs_review":
                self.verificationState = .underReview
                self.statusMessage = "Verification under review"
                self.statusType = .review
                self.alertType = .review
                self.alertMessage = "Your verification is being reviewed. You'll receive a notification once it's complete."
                self.showAlert = true

            default:
                self.statusMessage = "Verification status: \(status)"
                self.statusType = .ready
            }
        }
    }

    func inquiryCanceled(inquiryId: String?, sessionToken: String?) {
        print("❌ Inquiry canceled - ID: \(inquiryId ?? "unknown")")

        DispatchQueue.main.async {
            self.isLoading = false
            self.verificationState = .notStarted
            self.statusMessage = "Verification canceled"
            self.statusType = .ready
        }
    }

    func inquiryError(_ error: Error) {
        print("❌ Inquiry error: \(error)")
        if let nsError = error as NSError? {
            print("📛 Error Domain: \(nsError.domain)")
            print("📛 Code: \(nsError.code)")
            print("📛 Description: \(nsError.localizedDescription)")
        }

        DispatchQueue.main.async {
            self.isLoading = false
            self.verificationState = .failed
            self.statusMessage = "Verification error occurred"
            self.statusType = .error
            self.alertType = .error
            self.alertMessage = "An error occurred during verification: \(error.localizedDescription)"
            self.showAlert = true
        }
    }
}

// MARK: - Status View and Supporting Types
struct StatusView: View {
    let message: String
    let type: StatusType

    var body: some View {
        HStack {
            Image(systemName: type.iconName)
                .foregroundColor(.blue.opacity(0.7))
                .font(.title2)

            Text(message)
                .font(.body)
                .foregroundColor(.black.opacity(0.7))
        }
        .padding()
        .background(.secondary)
        .cornerRadius(8)
    }
}

enum StatusType {
    case ready, success, failure, review, error

    var color: Color {
        switch self {
        case .ready: return .primary
        case .success: return .green
        case .failure: return .red
        case .review: return .orange
        case .error: return .red
        }
    }

    var iconName: String {
        switch self {
        case .ready: return "checkmark.circle"
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        case .review: return "clock.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }
}

enum AlertType {
    case success, failure, review, error
}

// MARK: - Notification Extension
extension Notification.Name {
    static let verificationCompleted = Notification.Name("verificationCompleted")
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}









// MARK: - Updated Bottom Navigation
struct BottomNavigationView: View {
    
    @Binding var selectedIndex: Int
    let verificationStatus: VerificationManager.VerificationStatus
    
    let icons = [
        "house",
        "checkmark.shield", // Changed to verification icon
        "qrcode.viewfinder",
        "text.document",
        "person"
    ]
    
    var body: some View {
        VStack {
            
            ZStack {
                Divider()
                    .shadow(radius: 10)
                
                ZStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(.white)
                
                HStack {
                    
                    ForEach(0..<5, id: \.self) { number in
                        Spacer()
                        
                        Button(action: {
                            self.selectedIndex = number
                        }, label: {
                            if number == 2 {
                                // QR Code button (special styling)
                                Image(systemName: icons[number])
                                    .font(.system(size: 25, weight: .regular, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .padding(2)
                                    .background(selectedIndex == number ? .black : Color(UIColor.lightGray))
                                    .cornerRadius(30)
                            } else if number == 1 {
                                // Verification button with status indicator
                                ZStack {
                                    Image(systemName: icons[number])
                                        .font(.system(size: 25, weight: .regular, design: .rounded))
                                        .foregroundColor(selectedIndex == number ? .black : Color(UIColor.lightGray))
                                    
                                    // Status indicator
                                    if verificationStatus == .completed {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 12, y: -12)
                                    } else if verificationStatus == .inProgress {
                                        Circle()
                                            .fill(Color.orange)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 12, y: -12)
                                    } else if verificationStatus == .failed {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 12, y: -12)
                                    }
                                }
                            } else {
                                // Regular buttons
                                Image(systemName: icons[number])
                                    .font(.system(size: 25, weight: .regular, design: .rounded))
                                    .foregroundColor(selectedIndex == number ? .black : Color(UIColor.lightGray))
                            }
                        })
                        
                        Spacer()
                    }
                }
            }
        }
    }
}
