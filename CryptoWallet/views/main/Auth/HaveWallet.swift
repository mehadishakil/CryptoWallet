//
//  HaveWallet.swift
//  CryptoWallet
//
//  Created by Mehadi Hasan on 20/7/25.
//

import Foundation
import SwiftUI

struct FetchSeedPhraseView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var inputText: String = ""
    @State private var keywords: [String] = []
    @State private var goToScan = false
    
    var body: some View {
        
            VStack(spacing: 0) {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Type Your Seed Words")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.bottom)
                    Text("Enter each word in order by typing and pressing space.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding()
                
                // Keywords display
                KeywordsFlowView(keywords: $keywords, onRemove: { word in
                    keywords.removeAll { $0 == word }
                })
                .padding(.horizontal)
                .frame(maxHeight: 300)
                
                
                Spacer()
                
                // Text input for keywords
                HStack {
                    TextField("Type a word and press space", text: $inputText)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .onChange(of: inputText) { newValue in
                            if let last = newValue.last, last == " " {
                                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                                if !trimmed.isEmpty {
                                    keywords.append(trimmed)
                                }
                                inputText = ""
                            }
                        }
                }
                .padding()
                .padding(.bottom, 8)
                
                // Confirmation button
                LogActionView(goToScan: $goToScan, seedphrase: $keywords)
            }
            
    }
}

// MARK: - Bottom Confirmation Button
struct LogActionView: View {
    @Binding var goToScan: Bool
    @Binding var seedphrase: [String]
    @StateObject var wallet = EthereumWallet()
    @State private var navigateToMain = false  // New state variable
    @AppStorage("SeedPhrase") private var sp: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Color.gray.frame(height: 1)
                .padding(.bottom, 10)

            // Actual NavigationLink (visible to SwiftUI)
            NavigationLink(
                destination: MainView(
                    seedPhrase: seedphrase.joined(separator: " ")
                ),
                isActive: $navigateToMain
            ) {
                EmptyView()
            }

            Button(action: {
                do {
                    try wallet.importWallet(from: seedphrase.joined(separator: " "))
                    sp = seedphrase.joined(separator: " ")
                    navigateToMain = true  // Trigger navigation
                } catch {
                    print("Wallet import failed: \(error.localizedDescription)")
                }
            }) {
                Text("Confirm")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
}


struct FetchSeedPhrase_Preview: PreviewProvider {
    static var previews: some View {
        FetchSeedPhraseView()
    }
}
