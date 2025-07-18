import SwiftUI
import CoreNFC

struct nfcButton: UIViewRepresentable {
    @Binding var data: String

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton()
        button.setTitle("Read NFC", for: .normal)
        button.tintColor = .label
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.beginScan(_:)),
            for: .touchUpInside
        )
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(data: $data)
    }

    final class Coordinator: NSObject, NFCTagReaderSessionDelegate {
        var session: NFCTagReaderSession?
        @Binding var data: String

        init(data: Binding<String>) {
            _data = data
        }

        @objc func beginScan(_ sender: Any) {
            guard NFCTagReaderSession.readingAvailable else {
                print("error: Scanning not supported")
                return
            }
            session = NFCTagReaderSession(
                pollingOption: [.iso14443],
                delegate: self,
                queue: .main
            )
            session?.alertMessage = "Hold your iPhone near your passport’s NFC chip."
            session?.begin()
        }

        func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
            print("Session active — looking for tags")
        }

        func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
            print("Session invalidated:", error.localizedDescription)
            self.session = nil
        }

        func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
            guard let first = tags.first else { return }
            session.connect(to: first) { error in
                if let err = error {
                    session.invalidate(errorMessage: "Connection failed: \(err.localizedDescription)")
                    return
                }
                switch first {
                case .iso7816(let isoTag):
                    self.readPassport(isoTag, in: session)
                default:
                    session.invalidate(errorMessage: "Not a passport chip")
                }
            }
        }

        private func readPassport(_ tag: NFCISO7816Tag, in session: NFCTagReaderSession) {
            // 1) Perform BAC → derive keys from MRZ
            let mrz = "P<BGDHASAN<<MEHADI<<<<<<<<<<<<<<<<<<<<<<<<<<A144328091BGD0001100M34030604662137837<<<<78"
            let keys = deriveBACKeys(from: mrz)
            let secureChannel = BACSecureChannel(tag: tag, keys: keys)

            secureChannel.open { result in
                switch result {
                case .success:
                    // 2) Select the eMRTD AID
                    let selectApp = NFCISO7816APDU(
                        instructionClass: 0x00,
                        instructionCode: 0xA4,
                        p1Parameter: 0x04,
                        p2Parameter: 0x0C,
                        data: Data([0xA0, 0x00, 0x00, 0x02, 0x47, 0x10, 0x01]),
                        expectedResponseLength: -1
                    )
                    secureChannel.send(apdu: selectApp) { selResult in
                        switch selResult {
                        case .success:
                            // 3) GET DATA for DG1 (MRZ)
                            let getDG1 = NFCISO7816APDU(
                                instructionClass: 0x00,
                                instructionCode: 0xCB,
                                p1Parameter: 0x3F,
                                p2Parameter: 0xFF,
                                data: Data([0x5C, 0x02, 0x01, 0x1E]), // tag list for DG1
                                expectedResponseLength: -1
                            )
                            secureChannel.send(apdu: getDG1) { dg1Result in
                                switch dg1Result {
                                case .success(let dg1Data):
                                    let parsed = self.parseDG1Data(dg1Data)
                                    DispatchQueue.main.async {
                                        self.data = parsed
                                    }
                                    session.alertMessage = "Passport read!"
                                    session.invalidate()
                                case .failure(let err):
                                    session.invalidate(errorMessage: "Read DG1 failed: \(err)")
                                }
                            }
                        case .failure(let err):
                            session.invalidate(errorMessage: "Select failed: \(err)")
                        }
                    }
                case .failure(let err):
                    session.invalidate(errorMessage: "BAC failed: \(err)")
                }
            }
        }

        // MARK: — stubs you must implement or replace with a library —

        func deriveBACKeys(from mrz: String) -> (kEnc: Data, kMac: Data) {
            // derive 16‑byte ENC/MAC keys from MRZ — see ICAO Doc 9303
            return (Data(), Data())
        }

        struct BACSecureChannel {
            let tag: NFCISO7816Tag
            let keys: (kEnc: Data, kMac: Data)

            func open(_ completion: @escaping (Result<Void, Error>) -> Void) {
                // perform the mutual auth/secure messaging handshake
                completion(.failure(NSError(domain: "BAC", code: -1, userInfo: nil)))
            }

            func send(apdu: NFCISO7816APDU,
                      _ completion: @escaping (Result<Data, Error>) -> Void) {
                // wrap the APDU in secure messaging, exchange, unwrap response
                completion(.failure(NSError(domain: "APDU", code: -1, userInfo: nil)))
            }
        }

        func parseDG1Data(_ raw: Data) -> String {
            // decode the TLV, extract MRZ string
            return "Parsed MRZ goes here"
        }
    }
}












//import SwiftUI
//import CoreNFC
//
//// MARK: - Data Models
//struct DocumentInfo: Identifiable {
//    let id = UUID()
//    let field: String
//    let value: String
//}
//
//struct NFCDocument : Equatable {
//    let documentType: String
//    let fullName: String
//    let dateOfBirth: String
//    let documentNumber: String
//    let nationality: String
//    let expirationDate: String
//    let gender: String
//    
//    func toDocumentInfo() -> [DocumentInfo] {
//        return [
//            DocumentInfo(field: "Document Type", value: documentType),
//            DocumentInfo(field: "Full Name", value: fullName),
//            DocumentInfo(field: "Date of Birth", value: dateOfBirth),
//            DocumentInfo(field: "Document Number", value: documentNumber),
//            DocumentInfo(field: "Nationality", value: nationality),
//            DocumentInfo(field: "Expiration Date", value: expirationDate),
//            DocumentInfo(field: "Gender", value: gender)
//        ]
//    }
//}
//
//// MARK: - NFC Reader Manager
//class NFCReaderManager: NSObject, ObservableObject {
//    @Published var isScanning = false
//    @Published var scannedDocument: NFCDocument?
//    @Published var errorMessage: String?
//    @Published var scanProgress: Double = 0.0
//    
//    private var nfcSession: NFCNDEFReaderSession?
//    
//    override init() {
//        super.init()
//    }
//    
//    func startNFCSession() {
//        guard NFCNDEFReaderSession.readingAvailable else {
//            errorMessage = "NFC is not available on this device"
//            return
//        }
//        
//        isScanning = true
//        errorMessage = nil
//        scanProgress = 0.0
//        
//        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
//        nfcSession?.alertMessage = "Hold your device near the NFC chip in your document"
//        nfcSession?.begin()
//    }
//    
//    func stopNFCSession() {
//        nfcSession?.invalidate()
//        isScanning = false
//    }
//    
//    // Mock function to simulate document data extraction
//    private func extractDocumentData(from records: [NFCNDEFPayload]) -> NFCDocument {
//        // In a real implementation, you would parse the actual NFC data
//        // This is a mock implementation for demonstration
//        return NFCDocument(
//            documentType: "Passport",
//            fullName: "John Doe",
//            dateOfBirth: "1990-01-01",
//            documentNumber: "P1234567",
//            nationality: "USA",
//            expirationDate: "2030-01-01",
//            gender: "Male"
//        )
//    }
//}
//
//// MARK: - NFC Delegate
//extension NFCReaderManager: NFCNDEFReaderSessionDelegate {
//    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
//        DispatchQueue.main.async {
//            self.isScanning = false
//            if let nfcError = error as? NFCReaderError {
//                switch nfcError.code {
//                case .readerSessionInvalidationErrorUserCanceled:
//                    self.errorMessage = "Scan cancelled by user"
//                case .readerSessionInvalidationErrorSessionTimeout:
//                    self.errorMessage = "Scan session timed out"
//                case .readerSessionInvalidationErrorSessionTerminatedUnexpectedly:
//                    self.errorMessage = "Session terminated unexpectedly"
//                case .readerSessionInvalidationErrorSystemIsBusy:
//                    self.errorMessage = "System is busy, try again"
//                default:
//                    self.errorMessage = "NFC scan failed: \(error.localizedDescription)"
//                }
//            } else {
//                self.errorMessage = "NFC scan failed: \(error.localizedDescription)"
//            }
//        }
//    }
//    
//    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
//        DispatchQueue.main.async {
//            self.scanProgress = 0.5
//        }
//        
//        var allRecords: [NFCNDEFPayload] = []
//        for message in messages {
//            allRecords.append(contentsOf: message.records)
//        }
//        
//        DispatchQueue.main.async {
//            self.scanProgress = 1.0
//            self.scannedDocument = self.extractDocumentData(from: allRecords)
//            self.isScanning = false
//        }
//        
//        session.alertMessage = "Document read successfully!"
//        session.invalidate()
//    }
//}
//
//// MARK: - Enhanced NFC Scan Instruction View
//struct NFCScanInstructionView: View {
//    @StateObject private var nfcReader = NFCReaderManager()
//    @State private var animationTrigger = false
//    @State private var navigateToResults = false
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                VStack(spacing: 30) {
//                    // Animated NFC Icon
//                    ZStack {
//                        Circle()
//                            .fill(Color.blue.opacity(0.1))
//                            .frame(width: 160, height: 160)
//                            .scaleEffect(animationTrigger ? 1.2 : 1.0)
//                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animationTrigger)
//                        
//                        Image(systemName: "wave.3.right.circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 120, height: 120)
//                            .foregroundColor(.blue)
//                            .scaleEffect(animationTrigger ? 1.1 : 1.0)
//                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animationTrigger)
//                    }
//                    .onAppear {
//                        animationTrigger = true
//                    }
//                    
//                    Text("Tap Document to NFC Chip")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                    
//                    Text("Place your document (e.g., ePassport) near the top edge of your iPhone to read the embedded chip.")
//                        .font(.body)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 40)
//                    
//                    // Dynamic content based on scanning state
//                    if nfcReader.isScanning {
//                        VStack(spacing: 15) {
//                            ProgressView("Scanning...", value: nfcReader.scanProgress, total: 1.0)
//                                .progressViewStyle(CircularProgressViewStyle())
//                            
//                            if nfcReader.scanProgress > 0 {
//                                Text("Reading document data...")
//                                    .font(.caption)
//                                    .foregroundColor(.blue)
//                            }
//                        }
//                        .padding(.top, 20)
//                    } else {
//                        Button(action: {
//                            nfcReader.startNFCSession()
//                        }) {
//                            HStack {
//                                Image(systemName: "nfc")
//                                Text("Start NFC Scan")
//                            }
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                        }
//                        .padding(.top, 20)
//                    }
//                    
//                    // Error message
//                    if let errorMessage = nfcReader.errorMessage {
//                        Text(errorMessage)
//                            .font(.caption)
//                            .foregroundColor(.red)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal, 40)
//                    }
//                }
//                
//                Spacer()
//                
//                Button(action: {
//                    // Action for help or troubleshooting
//                }) {
//                    Text("Having trouble?")
//                        .font(.subheadline)
//                        .foregroundColor(.blue)
//                }
//                .padding(.bottom, 20)
//            }
//            .navigationBarHidden(true)
//            .onChange(of: nfcReader.scannedDocument) { document in
//                if document != nil {
//                    navigateToResults = true
//                }
//            }
//            .sheet(isPresented: $navigateToResults) {
//                if let document = nfcReader.scannedDocument {
//                    NFCInformationDisplayView(fetchedDocumentData: document.toDocumentInfo())
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Enhanced Information Display View
//struct NFCInformationDisplayView: View {
//    let fetchedDocumentData: [DocumentInfo]
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showingConfirmation = false
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                VStack(alignment: .leading, spacing: 20) {
//                    HStack {
//                        Button(action: {
//                            presentationMode.wrappedValue.dismiss()
//                        }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .font(.title2)
//                                .foregroundColor(.gray)
//                        }
//                        
//                        Spacer()
//                        
//                        Text("Document Verified")
//                            .font(.headline)
//                            .foregroundColor(.green)
//                    }
//                    .padding(.horizontal)
//                    
//                    Text("Document Information")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .padding(.horizontal)
//                    
//                    Text("We successfully read the following information from your document:")
//                        .font(.body)
//                        .foregroundColor(.gray)
//                        .padding(.horizontal)
//                        .padding(.bottom)
//                    
//                    List {
//                        ForEach(fetchedDocumentData) { info in
//                            HStack {
//                                Text(info.field)
//                                    .font(.headline)
//                                    .foregroundColor(.primary)
//                                Spacer()
//                                Text(info.value)
//                                    .font(.body)
//                                    .foregroundColor(.secondary)
//                                    .multilineTextAlignment(.trailing)
//                            }
//                            .padding(.vertical, 8)
//                        }
//                    }
//                    .listStyle(.plain)
//                    
//                    Spacer()
//                    
//                    VStack(spacing: 12) {
//                        Button(action: {
//                            showingConfirmation = true
//                        }) {
//                            Text("Confirm Information")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(Color.black)
//                                .cornerRadius(10)
//                                .padding(.horizontal)
//                        }
//                        
//                        Button(action: {
//                            presentationMode.wrappedValue.dismiss()
//                        }) {
//                            Text("Scan Again")
//                                .font(.subheadline)
//                                .foregroundColor(.blue)
//                        }
//                    }
//                    .padding(.bottom, 20)
//                }
//            }
//            .navigationBarHidden(true)
//            .alert("Information Confirmed", isPresented: $showingConfirmation) {
//                Button("OK") {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            } message: {
//                Text("The document information has been confirmed and saved to your wallet.")
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//struct NFCScanInstructionView_Previews: PreviewProvider {
//    static var previews: some View {
//        NFCScanInstructionView()
//    }
//}
//
//struct NFCInformationDisplayView_Previews: PreviewProvider {
//    static var previews: some View {
//        NFCInformationDisplayView(fetchedDocumentData: [
//            DocumentInfo(field: "Document Type", value: "Passport"),
//            DocumentInfo(field: "Full Name", value: "John Doe"),
//            DocumentInfo(field: "Date of Birth", value: "1990-01-01"),
//            DocumentInfo(field: "Document Number", value: "P1234567"),
//            DocumentInfo(field: "Nationality", value: "USA"),
//            DocumentInfo(field: "Expiration Date", value: "2030-01-01"),
//            DocumentInfo(field: "Gender", value: "Male")
//        ])
//    }
//}
//
//// For ISO 14443 and ISO 7816 communication
//import CryptoKit
//import Foundation
//
//// Advanced NFC Tag Reader for ISO documents
//class AdvancedNFCReader: NSObject, ObservableObject {
//    @Published var isScanning = false
//    @Published var documentData: [String: Any] = [:]
//    @Published var errorMessage: String?
//    
//    private var tagSession: NFCTagReaderSession?
//    
//    func startAdvancedScan() {
//        guard NFCTagReaderSession.readingAvailable else {
//            errorMessage = "NFC not available"
//            return
//        }
//        
//        isScanning = true
//        tagSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
//        tagSession?.alertMessage = "Hold your device near the document"
//        tagSession?.begin()
//    }
//}
//
//
//func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
//    <#code#>
//}
//
