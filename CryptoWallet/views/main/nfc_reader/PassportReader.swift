import SwiftUI
import CoreNFC
import CryptoKit


// MARK: - Passport Data Model
struct PassportData : Equatable {
    let documentNumber: String
    let firstName: String
    let lastName: String
    let nationality: String
    let dateOfBirth: String
    let expiryDate: String
    let gender: String
    let photo: Data?
}

// MARK: - NFC Passport Scanner View
struct NFCPassportScannerView: View {
    @StateObject private var nfcReader = NFCPassportReader()
    @State private var showingPassportDetails = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Status Icon
                Image(systemName: nfcReader.isScanning ? "wave.3.right.circle.fill" : "wave.3.right.circle")
                    .font(.system(size: 80))
                    .foregroundColor(nfcReader.isScanning ? .blue : .gray)
                    .scaleEffect(nfcReader.isScanning ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: nfcReader.isScanning)
                
                // Status Text
                VStack(spacing: 10) {
                    Text(nfcReader.statusMessage)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                    if nfcReader.isScanning {
                        Text("Hold your iPhone near the passport")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Scan Button
                Button(action: {
                    nfcReader.startScanning()
                }) {
                    HStack {
                        Image(systemName: "wave.3.right")
                        Text("Scan Passport")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .disabled(nfcReader.isScanning)
                
                // Error Message
                if let errorMessage = nfcReader.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("NFC Scanner")
            .sheet(isPresented: $showingPassportDetails) {
                if let passportData = nfcReader.passportData {
                    PassportDetailsView(passportData: passportData)
                }
            }
            .onChange(of: nfcReader.passportData) { data in
                if data != nil {
                    showingPassportDetails = true
                }
            }
        }
    }
}

// MARK: - Passport Details View
struct PassportDetailsView: View {
    let passportData: PassportData
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Photo Section
                    if let photoData = passportData.photo,
                       let uiImage = UIImage(data: photoData) {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 160)
                                .cornerRadius(8)
                            Spacer()
                        }
                    }
                    
                    // Personal Information
                    VStack(alignment: .leading, spacing: 15) {
                        DetailRow(label: "Document Number", value: passportData.documentNumber)
                        DetailRow(label: "First Name", value: passportData.firstName)
                        DetailRow(label: "Last Name", value: passportData.lastName)
                        DetailRow(label: "Nationality", value: passportData.nationality)
                        DetailRow(label: "Date of Birth", value: passportData.dateOfBirth)
                        DetailRow(label: "Expiry Date", value: passportData.expiryDate)
                        DetailRow(label: "Gender", value: passportData.gender)
                    }
                }
                .padding()
            }
            .navigationTitle("Passport Details")
            .navigationBarItems(trailing: Button("Done") {
                presentation.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - NFC Passport Reader
class NFCPassportReader: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var statusMessage = "Ready to scan"
    @Published var errorMessage: String?
    @Published var passportData: PassportData?
    
    private var nfcSession: NFCTagReaderSession?
    
    override init() {
        super.init()
    }
    
    func startScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            errorMessage = "NFC is not available on this device"
            return
        }
        
        isScanning = true
        statusMessage = "Looking for passport..."
        errorMessage = nil
        passportData = nil
        
        nfcSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        nfcSession?.alertMessage = "Hold your iPhone near the passport"
        nfcSession?.begin()
    }
    
    private func stopScanning() {
        nfcSession?.invalidate()
        nfcSession = nil
        isScanning = false
    }
}

// MARK: - NFC Tag Reader Session Delegate
extension NFCPassportReader: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // Session is active
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.stopScanning()
            if let nfcError = error as? NFCReaderError {
                switch nfcError.code {
                case .readerSessionInvalidationErrorUserCanceled:
                    self.statusMessage = "Scanning cancelled"
                case .readerSessionInvalidationErrorSessionTimeout:
                    self.errorMessage = "Scanning timed out"
                default:
                    self.errorMessage = "NFC error: \(nfcError.localizedDescription)"
                }
            } else {
                self.errorMessage = "Error: \(error.localizedDescription)"
            }
            self.statusMessage = "Ready to scan"
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if tags.count > 1 {
            session.alertMessage = "Multiple tags detected. Please try again."
            session.invalidate(errorMessage: "Multiple tags detected")
            return
        }
        
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tag detected")
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }
            
            // Process the passport tag
            self.processPassportTag(tag: tag, session: session)
        }
    }
    
    private func processPassportTag(tag: NFCTag, session: NFCTagReaderSession) {
        // This is a simplified version - real implementation would involve:
        // 1. Basic Access Control (BAC) authentication
        // 2. Reading various data groups (DG1, DG2, etc.)
        // 3. Parsing ASN.1 encoded data
        // 4. Verifying digital signatures
        
        guard case .iso7816(let iso7816Tag) = tag else {
            session.invalidate(errorMessage: "Invalid tag type")
            return
        }
        
        // For demonstration, we'll simulate reading passport data
        // In a real implementation, you would:
        // 1. Send APDU commands to select the passport application
        // 2. Perform BAC authentication using passport MRZ data
        // 3. Read and parse data groups
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Simulate successful read with dummy data
            self.passportData = PassportData(
                documentNumber: "P123456789",
                firstName: "JOHN",
                lastName: "DOE",
                nationality: "USA",
                dateOfBirth: "01/01/1990",
                expiryDate: "01/01/2030",
                gender: "M",
                photo: nil
            )
            
            session.alertMessage = "Passport read successfully!"
            session.invalidate()
            
            self.statusMessage = "Passport scanned successfully"
            self.stopScanning()
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
