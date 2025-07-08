//
//  ContentView.swift
//  CryptoWallet
//
//  Created by Mehadi Hasan on 2/7/25.
//

//
//import SwiftUI
//import CoreNFC
//
//struct NFCView: View {
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 40) {
//                NavigationLink(destination: WriteView()) {
//                    Text("Write NFC")
//                        .frame(width: 150, height: 44)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//
//                NavigationLink(destination: ReadView()) {
//                    Text("Read NFC")
//                        .frame(width: 150, height: 44)
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//            }
//            .navigationTitle("NFC Demo")
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(.systemBackground))
//        }
//    }
//}
//
//
//struct WriteView: View {
//    @State private var textToWrite: String = ""
//
//    var body: some View {
//        VStack(spacing: 30) {
//            TextField("Write NFC text here....", text: $textToWrite)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal)
//
//            Button("Write NFC") {
//                btnWrite()
//            }
//            .frame(width: 150, height: 44)
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//
//            Spacer()
//        }
//        .padding(.top, 100)
//        .navigationTitle("Write NFC")
//        .background(Color(.systemBackground))
//    }
//
//    func btnWrite() {
//        // Implement NFC write logic here
//        print("Writing to NFC: \(textToWrite)")
//    }
//}
//
//
//
//
//struct ReadView: View {
//    @State private var scannedData: String = ""
//    @State private var nfcSession: NFCNDEFReaderSession?
//    
//    var body: some View {
//        VStack(spacing: 50) {
//            Button("Scan") {
//                startNFCSession()
//            }
//            .frame(width: 100, height: 44)
//            .background(Color.orange)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//
//            Text(scannedData)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal, 30)
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//
//            Spacer()
//        }
//        .padding(.top, 20)
//        .navigationTitle("Read NFC")
//        .background(Color(.systemBackground))
//    }
//
//    func startNFCSession() {
//        guard NFCNDEFReaderSession.readingAvailable else {
//            scannedData = "NFC not supported on this device"
//            return
//        }
//        
//        nfcSession = NFCNDEFReaderSession(
//            delegate: NFCReaderDelegate(scannedData: $scannedData),
//            queue: nil,
//            invalidateAfterFirstRead: true
//        )
//        nfcSession?.alertMessage = "Hold your iPhone near an NFC tag"
//        nfcSession?.begin()
//    }
//}
//
//class NFCReaderDelegate: NSObject, NFCNDEFReaderSessionDelegate {
//    @Binding var scannedData: String
//    
//    init(scannedData: Binding<String>) {
//        self._scannedData = scannedData
//    }
//    
//    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
//        DispatchQueue.main.async {
//            self.scannedData = "Session error: \(error.localizedDescription)"
//        }
//    }
//    
//    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
//        guard let firstTag = tags.first else { return }
//        
//        session.connect(to: firstTag) { error in
//            if let error = error {
//                session.invalidate(errorMessage: error.localizedDescription)
//                return
//            }
//            
//            firstTag.queryNDEFStatus { status, _, error in
//                if let error = error {
//                    session.invalidate(errorMessage: error.localizedDescription)
//                    return
//                }
//                
//                if status == .notSupported {
//                    session.invalidate(errorMessage: "Tag not supported")
//                    return
//                }
//                
//                firstTag.readNDEF { message, error in
//                    if let error = error {
//                        session.invalidate(errorMessage: error.localizedDescription)
//                        return
//                    }
//                    
//                    guard let message = message else {
//                        session.invalidate(errorMessage: "No data found")
//                        return
//                    }
//                    
//                    self.processMessage(message)
//                    session.alertMessage = "Read successful!"
//                    session.invalidate()
//                }
//            }
//        }
//    }
//    
//    private func processMessage(_ message: NFCNDEFMessage) {
//        var result = ""
//        
//        for record in message.records {
//            if record.typeNameFormat == .nfcWellKnown,
//               let (text, _) = record.wellKnownTypeTextPayload() {
//                result += "\(text)\n"
//            } else if let text = String(data: record.payload, encoding: .utf8) {
//                result += "\(text)\n"
//            }
//        }
//        
//        DispatchQueue.main.async {
//            self.scannedData = result.isEmpty ? "No readable data" : result
//        }
//    }
//    
//    // Required delegate method
//    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}
//}
