import SwiftUI
import Toast
import CodeScanner
import CoreImage.CIFilterBuiltins

struct ScanView: View {
    @State private var address: String = ""
    @State private var showingQRScanner = false
    @State private var showingMyQRCode = false
    @State private var showingSendTransaction = false
    @State private var showingReceiveTransaction = false
    @State private var walletBalance: Double = 1250.75 // Mock balance
    @AppStorage("walletAddress") private var walletAddress: String = ""
    
    @StateObject private var wallet = EthereumWallet()
    let seedPhrase: String // Pass this from parent view
    
    var body: some View {
        ZStack(alignment: .top) {
            RadialGradient(
                gradient: Gradient(colors: [Color("#7A17D7"), Color("#ED74CD"), Color("#EBB5A3")]),
                center: .topTrailing,
                startRadius: 100,
                endRadius: 800
            )
            .frame(maxHeight: .infinity)
            .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Text("Wallet Balance")
                        .font(.custom(FontUtils.MAIN_REGULAR, size: 16))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(wallet.balance) ETH")
                        .font(.custom(FontUtils.MAIN_BOLD, size: 32))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        Button(action: { showingSendTransaction = true }) {
                            VStack(spacing: 5) {
                                Image(systemName: "paperplane.fill")
                                    .font(.title2)
                                Text("Send")
                                    .font(.custom(FontUtils.MAIN_REGULAR, size: 12))
                            }
                            .frame(width: 50, height: 50)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                        }
                        
                        Button(action: { showingReceiveTransaction = true }) {
                            VStack(spacing: 5) {
                                Image(systemName: "paperplane.fill")
                                    .font(.title2)
                                    .rotationEffect(.init(degrees: 180))
                                Text("Receive")
                                    .font(.custom(FontUtils.MAIN_REGULAR, size: 12))
                            }
                            .frame(width: 50, height: 50)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                        }
                    }
                    .padding()
                }
                .padding(.top, 20)
                .padding(.bottom, 4)
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 15) {
                        Button(action: { showingQRScanner = true }) {
                            VStack(spacing: 10) {
                                Image(systemName: "qrcode.viewfinder")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.purple)
                                    .frame(width: 50, height: 50)
                                
                                Text("Scan QR Code")
                                    .font(.custom(FontUtils.MAIN_BOLD, size: 18))
                                    .foregroundColor(.black)
                                
                                Text("Tap to scan wallet address")
                                    .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .padding(20)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Or Input Wallet Address")
                            .font(.headline)
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Text("Enter wallet address manually")
                            .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
                            .foregroundColor(.gray)
                        
                        TextField("Input Wallet address", text: $address)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .cornerRadius(15)
                            .padding(.bottom)
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                if !address.isEmpty {
                                    showingSendTransaction = true
                                }
                            }) {
                                Text("Send Transaction")
                                    .font(.custom(FontUtils.MAIN_REGULAR, size: 16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(address.isEmpty ? Color.gray : Color.black)
                                    .cornerRadius(15)
                            }
                            .disabled(address.isEmpty)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 30)
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
        }
        .sheet(isPresented: $showingQRScanner) {
            QRScannerView { result in
                address = result
                showingQRScanner = false
            }
        }
        .sheet(isPresented: $showingSendTransaction) {
            SendTransactionView(
                recipientAddress: address,
                seedPhrase: seedPhrase,
                wallet: wallet // Pass the shared one
            )
        }
        .sheet(isPresented: $showingReceiveTransaction) {
            ReceiveTransactionView(myAddress: wallet.address.isEmpty ? walletAddress : wallet.address)
        }
        .onAppear {
            if wallet.address.isEmpty && !seedPhrase.isEmpty {
                do {
                    try wallet.importWallet(from: seedPhrase)
                } catch {
                    print("❗️Failed to import wallet: \(error)")
                }
            }
        }
    }
}

struct QRScannerView: View {
    let onCodeScanned: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            CodeScannerView(codeTypes: [.qr], simulatedData: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh") { result in
                switch result {
                case .success(let code):
                    onCodeScanned(code.string)
                case .failure(let error):
                    print("Scanning failed: \(error.localizedDescription)")
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


struct SendTransactionView: View {
    @ObservedObject var wallet: EthereumWallet
    @State var recipientAddress: String
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var attachInvoice = false
    @State private var showingDocumentPicker = false
    @State private var selectedDocument: URL?
    @Environment(\.presentationMode) var presentationMode
    
    let seedPhrase: String?
    
    init(recipientAddress: String, seedPhrase: String? = nil, wallet: EthereumWallet) {
        self.recipientAddress = recipientAddress
        self.seedPhrase = seedPhrase
        self.wallet = wallet
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !wallet.address.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Balance:")
                                .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text("\(wallet.balance) ETH")
                                    .font(.custom(FontUtils.MAIN_BOLD, size: 20))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button("Refresh") {
                                    wallet.getBalance()
                                }
                                .font(.custom(FontUtils.MAIN_REGULAR, size: 12))
                                .disabled(wallet.isLoading)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recipient Address:")
                            .font(.custom(FontUtils.MAIN_BOLD, size: 16))
                        
                        TextField("Wallet address", text: $recipientAddress)
                            .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    FloatingLabelTextField(amount: $amount)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle("Attach Invoice/PDF", isOn: $attachInvoice)
                            .font(.custom(FontUtils.MAIN_BOLD, size: 16))
                        
                        if attachInvoice {
                            Button(action: { showingDocumentPicker = true }) {
                                HStack {
                                    Image(systemName: "doc.badge.plus")
                                    Text(selectedDocument?.lastPathComponent ?? "Select Document")
                                        .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Loading indicator (from WalletView)
                    if wallet.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Processing transaction...")
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        .padding()
                    }
                    
                    if !wallet.errorMessage.isEmpty {
                        Text(wallet.errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        if !wallet.address.isEmpty {
                            wallet.sendTransaction(to: recipientAddress, amount: amount)
                        }
                    }) {
                        Text("Send Transaction")
                            .font(.custom(FontUtils.MAIN_BOLD, size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background((amount.isEmpty || recipientAddress.isEmpty || wallet.address.isEmpty || wallet.isLoading) ? Color.gray : Color.green)
                            .cornerRadius(15)
                    }
                    .disabled(amount.isEmpty || recipientAddress.isEmpty || wallet.address.isEmpty || wallet.isLoading)
                    .padding(.top, 20)
                    
                    if wallet.address.isEmpty {
                        VStack(spacing: 15) {
                            Text("No wallet found. Create or import a wallet to send transactions.")
                                .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            
                            if let seedPhrase = seedPhrase {
                                Button("Create Wallet from Seed") {
                                    wallet.createWallet(from: seedPhrase)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(wallet.isLoading)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Send Transaction")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(selectedDocument: $selectedDocument)
        }
        .onChange(of: wallet.errorMessage) { errorMessage in
            if errorMessage.isEmpty && !wallet.isLoading {
            }
        }
    }
}

struct FloatingLabelTextField: View {
    @Binding var amount: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Amount:")
                .font(.custom(FontUtils.MAIN_BOLD, size: 16))
                .padding(.bottom, 4)

            ZStack(alignment: .leading) {
                // Floating label
                if isFocused || !amount.isEmpty {
                    Text("ETH")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 6)
                        .background(Color.gray.opacity(0.1))
                        .offset(x: 10, y: -28)
                        .zIndex(1)
                }

                HStack {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.custom(FontUtils.MAIN_REGULAR, size: 18))
                        .focused($isFocused)
                    
                    if amount.isEmpty && !isFocused {
                        Text("ETH")
                            .font(.custom(FontUtils.MAIN_REGULAR, size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .animation(.easeInOut(duration: 0.2), value: isFocused || !amount.isEmpty)
        }
    }
}



struct ReceiveTransactionView: View {
    let myAddress: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Receive Payment")
                    .font(.custom(FontUtils.MAIN_BOLD, size: 24))
                    .foregroundColor(.black)
                
                Text("Share this QR code or address to receive payments")
                    .font(.custom(FontUtils.MAIN_REGULAR, size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                if let qrImage = generateQRCode(from: myAddress) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                
                VStack(spacing: 10) {
                    Text("Your Wallet Address:")
                        .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
                        .foregroundColor(.gray)
                    
                    Button {
                        UIPasteboard.general.string = myAddress
                        let toast = Toast.text("Address copied!")
                        toast.show()
                    } label: {
                        HStack{
                            Text(myAddress)
                                .font(.caption2)
                                .foregroundColor(.primary)
                                
                            Image(systemName: "doc.on.doc")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundColor(.primary.opacity(0.8))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    
                    Text("Tap to copy address")
                        .font(.custom(FontUtils.MAIN_REGULAR, size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Receive")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(Data(string.utf8), forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

// Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedDocument: URL?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .image], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedDocument = urls.first
        }
    }
}


extension Color {
    init(_ hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView(seedPhrase: "ASDF ASDF ASDF ASD FASDF SAD F")
    }
}
