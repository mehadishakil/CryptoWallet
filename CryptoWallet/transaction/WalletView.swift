
import SwiftUI

struct WalletView: View {
    @StateObject private var wallet = EthereumWallet()
    @State private var recipientAddress = ""
    @State private var sendAmount = ""
    @State private var privateKeyInput = ""
    @State private var showingImportSheet = false
    @State private var showingPrivateKey = false
    
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Text("Ethereum Testnet Wallet")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Wallet Info
                VStack(alignment: .leading, spacing: 10) {
                    Text("Address:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(wallet.address.isEmpty ? "No wallet created" : wallet.address)
                        .font(.system(size: 12))
                        .textSelection(.enabled)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Private Key Section
                    if !wallet.address.isEmpty {
                        HStack {
                            Text("Private Key:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(showingPrivateKey ? "Hide" : "Show") {
                                showingPrivateKey.toggle()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        if showingPrivateKey {
                            Text(wallet.privateKeyHex)
                                .font(.system(size: 10))
                                .textSelection(.enabled)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            
                            Text("⚠️ Keep this private key safe! Anyone with this key can access your wallet.")
                                .font(.caption2)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••")
                                .font(.system(size: 10))
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    Text("Balance:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("\(wallet.balance) ETH")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("Refresh") {
                            wallet.getBalance()
                        }
                        .disabled(wallet.address.isEmpty || wallet.isLoading)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Wallet Actions
                VStack(spacing: 15) {
                    Button("Create New Wallet") {
                        wallet.createWallet()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(wallet.isLoading)
                    
                    Button("Import Wallet") {
                        showingImportSheet = true
                    }
                    .buttonStyle(.bordered)
                    .disabled(wallet.isLoading)
                }
                
                // Send Transaction
                if !wallet.address.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Send Transaction")
                            .font(.headline)
                        
                        TextField("Recipient Address", text: $recipientAddress)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 12))
                        
                        TextField("Amount (ETH)", text: $sendAmount)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        
                        Button("Send Transaction") {
                            wallet.sendTransaction(to: recipientAddress, amount: sendAmount)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(recipientAddress.isEmpty || sendAmount.isEmpty || wallet.isLoading)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Loading indicator
                if wallet.isLoading {
                    ProgressView("Processing...")
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                // Error message
                if !wallet.errorMessage.isEmpty {
                    Text(wallet.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImportSheet) {
            ImportWalletView(privateKeyInput: $privateKeyInput) {
                wallet.importWallet(privateKeyString: privateKeyInput)
                showingImportSheet = false
                privateKeyInput = ""
            }
        }
    }
}

struct ImportWalletView: View {
    @Binding var privateKeyInput: String
    let onImport: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Import Wallet")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter your private key")
                        .font(.headline)
                    
                    Text("Private key should be 64 characters (32 bytes) without '0x' prefix")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Private Key", text: $privateKeyInput)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Text("Characters: \(privateKeyInput.count)/64")
                        .font(.caption2)
                        .foregroundColor(privateKeyInput.count == 64 ? .green : .secondary)
                }
                
                Button("Import Wallet") {
                    onImport()
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(privateKeyInput.count != 64)
                
                Spacer()
                
                VStack(spacing: 5) {
                    Text("⚠️ Security Warning")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Text("Never share your private key with anyone. Anyone with access to your private key can control your wallet and funds.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    privateKeyInput = ""
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}




















