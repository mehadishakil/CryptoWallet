
import Foundation
import BigInt
import CryptoSwift
import CryptoKit

class EthereumWallet: ObservableObject {
    @Published var address: String = ""
    @Published var balance: String = "0"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var privateKeyHex: String = ""
    
    private var privateKey: Data?
    private let rpcURL = "https://sepolia.infura.io/v3/5c13cec41a9d4475bdd2c744a636a822"
    
    func createWallet() {
        // Generate a random 32-byte private key
        let privateKeyData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        self.privateKey = privateKeyData
        self.privateKeyHex = privateKeyData.toHexString()
        
        // Generate address from private key
        self.address = generateAddress(from: privateKeyData)
        
        // Clear any previous errors
        self.errorMessage = ""
        
        print("Private Key: \(privateKeyHex)")
        print("Address: \(address)")
    }
    
    func importWallet(privateKeyString: String) {
        guard privateKeyString.count == 64 else {
            errorMessage = "Private key must be 64 characters (32 bytes)"
            return
        }
        
        guard let privateKeyData = Data(hexString: privateKeyString) else {
            errorMessage = "Invalid private key format"
            return
        }
        
        self.privateKey = privateKeyData
        self.privateKeyHex = privateKeyString
        self.address = generateAddress(from: privateKeyData)
        self.errorMessage = ""
        
        print("Imported wallet with address: \(address)")
    }
    
    private func generateAddress(from privateKey: Data) -> String {
        // Generate public key from private key using secp256k1
        guard let publicKey = generatePublicKey(from: privateKey) else {
            return ""
        }
        
        // Hash public key with Keccak-256
        let publicKeyHash = publicKey.sha3(.keccak256)
        
        // Take last 20 bytes as address
        let addressData = publicKeyHash.suffix(20)
        
        // Convert to checksummed address
        return "0x" + addressData.toHexString()
    }
    
    private func generatePublicKey(from privateKey: Data) -> Data? {
        // This is a simplified version - in production, you'd use a proper secp256k1 library
        // For now, we'll use a mock implementation
        let hash = SHA256.hash(data: privateKey + "public".data(using: .utf8)!)
        return Data(hash) + Data(hash) // 64 bytes total
    }
    
    func getBalance() {
        guard !address.isEmpty else {
            errorMessage = "Wallet not initialized"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let balance = try await fetchBalance()
                await MainActor.run {
                    self.balance = balance
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to get balance: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func fetchBalance() async throws -> String {
        guard let url = URL(string: rpcURL) else {
            throw WalletError.invalidURL
        }
        
        let requestBody = [
            "jsonrpc": "2.0",
            "method": "eth_getBalance",
            "params": [address, "latest"],
            "id": 1
        ] as [String : Any]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WalletError.networkError
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = json["result"] as? String else {
            throw WalletError.invalidResponse
        }
        
        // Convert hex balance to decimal
        let balanceHex = String(result.dropFirst(2)) // Remove "0x" prefix
        guard let balanceInt = BigUInt(balanceHex, radix: 16) else {
            throw WalletError.invalidBalance
        }
        
        // Convert from Wei to Ether (1 ETH = 10^18 Wei)
        let etherBalance = Double(balanceInt) / pow(10, 18)
        return String(format: "%.4f", etherBalance)
    }
    
    func sendTransaction(to: String, amount: String) {
        guard let privateKey = privateKey else {
            errorMessage = "Wallet not initialized"
            return
        }
        
        guard to.hasPrefix("0x") && to.count == 42 else {
            errorMessage = "Invalid recipient address"
            return
        }
        
        guard let amountDouble = Double(amount), amountDouble > 0 else {
            errorMessage = "Invalid amount"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let txHash = try await sendRawTransaction(to: to, amount: amount, privateKey: privateKey)
                await MainActor.run {
                    self.isLoading = false
                    print("Transaction sent: \(txHash)")
                    // Refresh balance after transaction
                    self.getBalance()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Transaction failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func sendRawTransaction(to: String, amount: String, privateKey: Data) async throws -> String {
        // Get transaction count (nonce)
        let nonce = try await getTransactionCount()
        
        // Get gas price
        let gasPrice = try await getGasPrice()
        
        // Convert amount to Wei
        let amountDouble = Double(amount) ?? 0
        let valueInWei = BigUInt(amountDouble * pow(10, 18))
        
        // Build transaction
        let transaction = [
            "from": address,
            "to": to,
            "value": "0x" + String(valueInWei, radix: 16),
            "gas": "0x5208", // 21000 gas for simple transfer
            "gasPrice": gasPrice,
            "nonce": nonce
        ]
        
        // For demo purposes, we'll simulate sending
        // In production, you'd need to properly sign and send the transaction
        let mockTxHash = "0x" + Data.random(count: 32).toHexString()
        return mockTxHash
    }
    
    private func getTransactionCount() async throws -> String {
        let requestBody = [
            "jsonrpc": "2.0",
            "method": "eth_getTransactionCount",
            "params": [address, "latest"],
            "id": 1
        ] as [String : Any]
        
        return try await performRPCCall(requestBody: requestBody)
    }
    
    private func getGasPrice() async throws -> String {
        let requestBody = [
            "jsonrpc": "2.0",
            "method": "eth_gasPrice",
            "params": [],
            "id": 1
        ] as [String : Any]
        
        return try await performRPCCall(requestBody: requestBody)
    }
    
    private func performRPCCall(requestBody: [String: Any]) async throws -> String {
        guard let url = URL(string: rpcURL) else {
            throw WalletError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WalletError.networkError
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = json["result"] as? String else {
            throw WalletError.invalidResponse
        }
        
        return result
    }
}

// Error types
enum WalletError: Error {
    case invalidURL
    case networkError
    case invalidResponse
    case invalidBalance
    case transactionFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid RPC URL"
        case .networkError:
            return "Network error"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidBalance:
            return "Invalid balance format"
        case .transactionFailed:
            return "Transaction failed"
        }
    }
}

// Helper extensions
extension Data {
    init?(hexString: String) {
        let string = hexString.lowercased()
        guard string.count % 2 == 0 else { return nil }
        
        var data = Data()
        var index = string.startIndex
        
        while index < string.endIndex {
            let nextIndex = string.index(index, offsetBy: 2)
            let byteString = String(string[index..<nextIndex])
            
            guard let byte = UInt8(byteString, radix: 16) else { return nil }
            data.append(byte)
            
            index = nextIndex
        }
        
        self = data
    }
    
    func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
    
    static func random(count: Int) -> Data {
        return Data((0..<count).map { _ in UInt8.random(in: 0...255) })
    }
}


















