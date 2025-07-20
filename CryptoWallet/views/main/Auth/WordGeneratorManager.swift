import Foundation
//
//class WordGeneratorManager {
//    
//    class func getSecretWords(_ number:Int = 12) async throws -> [SecretWord] {
//        guard let url = URL(string: "https://random-word-api.herokuapp.com/word?number=\(number)") else {
//            fatalError("Missing URL")
//        }
//        
//        let urlRequest = URLRequest(url: url)
//        let (data, response) = try await URLSession.shared.data(for: urlRequest)
//        
//        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
//            fatalError("Error fetching weather data")
//        }
//        
//        let decodedData = try JSONDecoder().decode([String].self, from: data)
//        
//        return decodedData.map { text in
//            SecretWord(text: text, isSelected: false)
//            
//        }
//    }
//}


import CryptoSwift
import Foundation

struct SecretWord {
    let index: Int
    let text: String
}

enum WordGeneratorManager {
    static func getSecretWords() async throws -> [SecretWord] {
        // 1. Generate 128 bits of entropy (for 12 words)
        var entropy = Data(count: 16) // 16 bytes = 128 bits
        let result = entropy.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 16, $0.baseAddress!)
        }
        guard result == errSecSuccess else {
            throw NSError(domain: "EntropyError", code: -1)
        }

        // 2. Convert entropy to binary string
        let entropyBits = entropy.map { String($0, radix: 2).leftPad(to: 8) }.joined()

        // 3. Compute checksum: SHA256(entropy) first N bits
        let checksumLength = entropy.count * 8 / 32 // 128 bits => 4 bits
        let hash = entropy.sha256()
        let hashBits = hash.map { String($0, radix: 2).leftPad(to: 8) }.joined()
        let checksumBits = String(hashBits.prefix(checksumLength))

        // 4. Combine entropy bits + checksum bits
        let bits = entropyBits + checksumBits

        // 5. Break into 11-bit chunks and map to BIP39 words
        var words: [SecretWord] = []
        for i in 0..<12 {
            let start = i * 11
            let end = start + 11
            let chunk = bits[start..<end]
            let index = Int(chunk, radix: 2)!
            let word = Bip39.wordList[index]
            words.append(SecretWord(index: i + 1, text: word))
        }

        return words
    }
}

extension String {
    // Pads binary strings to exact width
    func leftPad(to width: Int, with char: Character = "0") -> String {
        String(repeating: char, count: max(0, width - self.count)) + self
    }

    // Subscript to get a slice from string (binary slice)
    subscript(range: Range<Int>) -> String {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = index(self.startIndex, offsetBy: range.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
