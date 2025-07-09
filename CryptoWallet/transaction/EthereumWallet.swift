//
//import Foundation
//import BigInt
//import CryptoSwift
//import CryptoKit
//import secp256k1
//
//class EthereumWallet: ObservableObject {
//    @Published var address: String = ""
//    @Published var balance: String = "0"
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String = ""
//    @Published var privateKeyHex: String = ""
//    
//    private var privateKey: Data?
//    private let rpcURL = "https://sepolia.infura.io/v3/5c13cec41a9d4475bdd2c744a636a822"
//    
//    private static let secpContext: OpaquePointer = {
//            secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))
//        }()
//    
//    func createWallet() {
//        // Generate a random 32-byte private key
//        let privateKeyData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
//        self.privateKey = privateKeyData
//        self.privateKeyHex = privateKeyData.toHexString()
//        
//        // Generate address from private key
//        self.address = generateAddress(from: privateKeyData)
//        
//        // Clear any previous errors
//        self.errorMessage = ""
//        
//        print("Private Key: \(privateKeyHex)")
//        print("Address: \(address)")
//    }
//    
//    func importWallet(privateKeyString: String) {
//        guard privateKeyString.count == 64 else {
//            errorMessage = "Private key must be 64 characters (32 bytes)"
//            return
//        }
//        
//        guard let privateKeyData = Data(hexString: privateKeyString) else {
//            errorMessage = "Invalid private key format"
//            return
//        }
//        
//        self.privateKey = privateKeyData
//        self.privateKeyHex = privateKeyString
//        self.address = generateAddress(from: privateKeyData)
//        self.errorMessage = ""
//        
//        print("Imported wallet with address: \(address)")
//    }
//    
//    private func generateAddress(from privateKey: Data) -> String {
//        // Generate public key from private key using secp256k1
//        guard let publicKey = generatePublicKey(from: privateKey) else {
//            return ""
//        }
//        
//        // Hash public key with Keccak-256
//        let publicKeyHash = publicKey.sha3(.keccak256)
//        
//        // Take last 20 bytes as address
//        let addressData = publicKeyHash.suffix(20)
//        
//        // Convert to checksummed address
//        return "0x" + addressData.toHexString()
//    }
//    
//    private func generatePublicKey(from privateKey: Data) -> Data? {
//        // This is a simplified version - in production, you'd use a proper secp256k1 library
//        // For now, we'll use a mock implementation
//        let hash = SHA256.hash(data: privateKey + "public".data(using: .utf8)!)
//        return Data(hash) + Data(hash) // 64 bytes total
//    }
//    
//    func getBalance() {
//        guard !address.isEmpty else {
//            errorMessage = "Wallet not initialized"
//            return
//        }
//        
//        isLoading = true
//        errorMessage = ""
//        
//        Task {
//            do {
//                let balance = try await fetchBalance()
//                await MainActor.run {
//                    self.balance = balance
//                    self.isLoading = false
//                }
//            } catch {
//                await MainActor.run {
//                    self.errorMessage = "Failed to get balance: \(error.localizedDescription)"
//                    self.isLoading = false
//                }
//            }
//        }
//    }
//    
//    private func fetchBalance() async throws -> String {
//        guard let url = URL(string: rpcURL) else {
//            throw WalletError.invalidURL
//        }
//        
//        let requestBody = [
//            "jsonrpc": "2.0",
//            "method": "eth_getBalance",
//            "params": [address, "latest"],
//            "id": 1
//        ] as [String : Any]
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse,
//              httpResponse.statusCode == 200 else {
//            throw WalletError.networkError
//        }
//        
//        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//              let result = json["result"] as? String else {
//            throw WalletError.invalidResponse
//        }
//        
//        // Convert hex balance to decimal
//        let balanceHex = String(result.dropFirst(2)) // Remove "0x" prefix
//        guard let balanceInt = BigUInt(balanceHex, radix: 16) else {
//            throw WalletError.invalidBalance
//        }
//        
//        // Convert from Wei to Ether (1 ETH = 10^18 Wei)
//        let etherBalance = Double(balanceInt) / pow(10, 18)
//        return String(format: "%.4f", etherBalance)
//    }
//    
//    func sendTransaction(to: String, amount: String) {
//        guard let privateKey = privateKey else {
//            errorMessage = "Wallet not initialized"
//            return
//        }
//        
//        guard to.hasPrefix("0x") && to.count == 42 else {
//            errorMessage = "Invalid recipient address"
//            return
//        }
//        
//        guard let amountDouble = Double(amount), amountDouble > 0 else {
//            errorMessage = "Invalid amount"
//            return
//        }
//        
//        isLoading = true
//        errorMessage = ""
//        
//        Task {
//            do {
//                let txHash = try await sendRawTransaction(to: to, amount: amount, privateKey: privateKey)
//                await MainActor.run {
//                    self.isLoading = false
//                    print("Transaction sent: \(txHash)")
//                    // Refresh balance after transaction
//                    self.getBalance()
//                }
//            } catch {
//                await MainActor.run {
//                    self.errorMessage = "Transaction failed: \(error.localizedDescription)"
//                    self.isLoading = false
//                }
//            }
//        }
//    }
//    
//    private func getTransactionCount() async throws -> String {
//        let requestBody = [
//            "jsonrpc": "2.0",
//            "method": "eth_getTransactionCount",
//            "params": [address, "latest"],
//            "id": 1
//        ] as [String : Any]
//        
//        return try await performRPCCall(requestBody: requestBody)
//    }
//    
//    private func getGasPrice() async throws -> String {
//        let requestBody = [
//            "jsonrpc": "2.0",
//            "method": "eth_gasPrice",
//            "params": [],
//            "id": 1
//        ] as [String : Any]
//        
//        return try await performRPCCall(requestBody: requestBody)
//    }
//    
//    private func performRPCCall(requestBody: [String: Any]) async throws -> String {
//        guard let url = URL(string: rpcURL) else {
//            throw WalletError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse,
//              httpResponse.statusCode == 200 else {
//            throw WalletError.networkError
//        }
//        
//        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//              let result = json["result"] as? String else {
//            throw WalletError.invalidResponse
//        }
//        
//        return result
//    }
//}
//
//// Error types
//enum WalletError: Error {
//    case invalidURL
//    case networkError
//    case invalidResponse
//    case invalidBalance
//    case transactionFailed
//    
//    var localizedDescription: String {
//        switch self {
//        case .invalidURL:
//            return "Invalid RPC URL"
//        case .networkError:
//            return "Network error"
//        case .invalidResponse:
//            return "Invalid response from server"
//        case .invalidBalance:
//            return "Invalid balance format"
//        case .transactionFailed:
//            return "Transaction failed"
//        }
//    }
//}
//
//// Helper extensions
//extension Data {
//    init?(hexString: String) {
//        let string = hexString.lowercased()
//        guard string.count % 2 == 0 else { return nil }
//        
//        var data = Data()
//        var index = string.startIndex
//        
//        while index < string.endIndex {
//            let nextIndex = string.index(index, offsetBy: 2)
//            let byteString = String(string[index..<nextIndex])
//            
//            guard let byte = UInt8(byteString, radix: 16) else { return nil }
//            data.append(byte)
//            
//            index = nextIndex
//        }
//        
//        self = data
//    }
//    
//    func toHexString() -> String {
//        return self.map { String(format: "%02x", $0) }.joined()
//    }
//    
//    static func random(count: Int) -> Data {
//        return Data((0..<count).map { _ in UInt8.random(in: 0...255) })
//    }
//}
//
//
//
//extension String {
//  func stripHexPrefix() -> String {
//    hasPrefix("0x") ? String(dropFirst(2)) : self
//  }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//extension EthereumWallet {
//  private func sendRawTransaction(
//    to: String,
//    amount: String,
//    privateKey: Data
//  ) async throws -> String {
//    // 1) fetch chain data
//    let nonceHex   = try await getTransactionCount().stripHexPrefix()
//    let gasPriceHex = try await getGasPrice().stripHexPrefix()
//    let nonce      = BigUInt(nonceHex, radix: 16)!
//    let gasPrice   = BigUInt(gasPriceHex, radix: 16)!
//    let gasLimit   = BigUInt(21_000)
//    let value      = BigUInt(Double(amount)! * pow(10, 18))
//    let toData     = Data(hex: to.stripHexPrefix())
//    let chainId    = BigUInt(11155111)
//
//    // 2) RLP‑encode [nonce, gasPrice, gasLimit, to, value, data, chainId, 0, 0]
//    let unsignedTx: [Any] = [
//      nonce, gasPrice, gasLimit,
//      toData, value, Data(),
//      chainId, BigUInt(0), BigUInt(0)
//    ]
//    let rlpUnsigned = rlpEncode(unsignedTx)
//    
//    // 3) hash it
//    let hash = rlpUnsigned.sha3(.keccak256)
//    
//    // 4) sign with secp256k1 C API
//    var recoverableSig = secp256k1_ecdsa_recoverable_signature()
//    hash.withUnsafeBytes { msg in
//      privateKey.withUnsafeBytes { key in
//        _ = secp256k1_ecdsa_sign_recoverable(
//          EthereumWallet.secpContext,
//          &recoverableSig,
//          msg.baseAddress!.assumingMemoryBound(to: UInt8.self),
//          key.baseAddress!.assumingMemoryBound(to: UInt8.self),
//          nil, nil
//        )
//      }
//    }
//    
//    // 5) serialize to (r‖s) + recId
//    var sig64 = [UInt8](repeating: 0, count: 64)
//    var recId: Int32 = 0
//    secp256k1_ecdsa_recoverable_signature_serialize_compact(
//      EthereumWallet.secpContext,
//      &sig64, &recId,
//      &recoverableSig
//    )
//
//    // 6) compute v per EIP‑155
//    let r = BigUInt(Data(sig64[0..<32]))
//    let s = BigUInt(Data(sig64[32..<64]))
//    let v = BigUInt(UInt(recId) + 27) + chainId * 2 + 8
//
//    // 7) RLP‑encode final tx [nonce, gasPrice, gasLimit, to, value, data, v, r, s]
//    let signedTx: [Any] = [
//      nonce, gasPrice, gasLimit,
//      toData, value, Data(),
//      v, r, s
//    ]
//    let rlpSigned = rlpEncode(signedTx)
//
//    // 8) broadcast it
//    let hexTx = "0x" + rlpSigned.toHexString()
//    let body: [String:Any] = [
//      "jsonrpc":"2.0",
//      "method":"eth_sendRawTransaction",
//      "params":[hexTx],
//      "id":1
//    ]
//    return try await performRPCCall(requestBody: body)
//  }
//}


import Foundation
import BigInt
import CryptoSwift
import CryptoKit
import secp256k1

class EthereumWallet: ObservableObject {
    @Published var address: String = ""
    @Published var balance: String = "0"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var privateKeyHex: String = ""
    
    private var privateKey: Data?
    private let rpcURL = "https://sepolia.infura.io/v3/5c13cec41a9d4475bdd2c744a636a822"
    
    private static let secpContext: OpaquePointer = {
        secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))
    }()
    
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
        var publicKey = secp256k1_pubkey()
        
        let result = privateKey.withUnsafeBytes { keyBytes in
            secp256k1_ec_pubkey_create(
                EthereumWallet.secpContext,
                &publicKey,
                keyBytes.bindMemory(to: UInt8.self).baseAddress!
            )
        }
        
        guard result == 1 else { return nil }
        
        var serializedKey = [UInt8](repeating: 0, count: 65)
        var outputLen = 65
        
        secp256k1_ec_pubkey_serialize(
            EthereumWallet.secpContext,
            &serializedKey,
            &outputLen,
            &publicKey,
            UInt32(SECP256K1_EC_UNCOMPRESSED)
        )
        
        // Return the public key without the 0x04 prefix (first byte)
        return Data(serializedKey[1...])
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
    
    private func sendRawTransaction(
        to: String,
        amount: String,
        privateKey: Data
    ) async throws -> String {
        // 1) fetch chain data
        let nonceHex = try await getTransactionCount().stripHexPrefix()
        let gasPriceHex = try await getGasPrice().stripHexPrefix()
        let nonce = BigUInt(nonceHex, radix: 16) ?? BigUInt(0)
        let gasPrice = BigUInt(gasPriceHex, radix: 16) ?? BigUInt(0)
        let gasLimit = BigUInt(21_000)
        let value = BigUInt(Double(amount)! * pow(10, 18))
        let toData = Data(hex: to.stripHexPrefix())
        let chainId = BigUInt(11155111) // Sepolia chain ID
        
        // 2) RLP‑encode [nonce, gasPrice, gasLimit, to, value, data, chainId, 0, 0]
        let unsignedTx: [Any] = [
            nonce, gasPrice, gasLimit,
            toData, value, Data(),
            chainId, BigUInt(0), BigUInt(0)
        ]
        let rlpUnsigned = rlpEncode(unsignedTx)
        
        // 3) hash it
        let hash = rlpUnsigned.sha3(.keccak256)
        
        // 4) sign with secp256k1 C API
        var recoverableSig = secp256k1_ecdsa_recoverable_signature()
        let signResult = hash.withUnsafeBytes { msg in
            privateKey.withUnsafeBytes { key in
                secp256k1_ecdsa_sign_recoverable(
                    EthereumWallet.secpContext,
                    &recoverableSig,
                    msg.bindMemory(to: UInt8.self).baseAddress!,
                    key.bindMemory(to: UInt8.self).baseAddress!,
                    nil, nil
                )
            }
        }
        
        guard signResult == 1 else {
            throw WalletError.transactionFailed
        }
        
        // 5) serialize to (r‖s) + recId
        var sig64 = [UInt8](repeating: 0, count: 64)
        var recId: Int32 = 0
        secp256k1_ecdsa_recoverable_signature_serialize_compact(
            EthereumWallet.secpContext,
            &sig64, &recId,
            &recoverableSig
        )
        
        // 6) compute v per EIP‑155
        let r = BigUInt(Data(sig64[0..<32]))
        let s = BigUInt(Data(sig64[32..<64]))
        let v = BigUInt(UInt(recId)) + chainId * 2 + 35
        
        // 7) RLP‑encode final tx [nonce, gasPrice, gasLimit, to, value, data, v, r, s]
        let signedTx: [Any] = [
            nonce, gasPrice, gasLimit,
            toData, value, Data(),
            v, r, s
        ]
        let rlpSigned = rlpEncode(signedTx)
        
        // 8) broadcast it
        let hexTx = "0x" + rlpSigned.toHexString()
        print("Raw transaction: \(hexTx)")
        
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "eth_sendRawTransaction",
            "params": [hexTx],
            "id": 1
        ]
        
        return try await performRPCCall(requestBody: body)
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
    
    init(hex: String) {
        let string = hex.lowercased()
        var data = Data()
        var index = string.startIndex
        
        while index < string.endIndex {
            let nextIndex = string.index(index, offsetBy: 2)
            let byteString = String(string[index..<nextIndex])
            
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            }
            
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

extension String {
    func stripHexPrefix() -> String {
        hasPrefix("0x") ? String(dropFirst(2)) : self
    }
}
