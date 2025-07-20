import SwiftUI

struct WelcomeView: View {
    @State private var isNewWallet = false
    @State private var isHasWallet = false
    @StateObject private var viewModel = IdentityVerificationViewModel()
    @State private var showNFC = false
    var body: some View {
        NavigationView {
            ZStack {
                Color(.white)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    VStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .padding(.top, 50)
                        Text("CryptoWallet")
                            .font(.title.bold())
                    }
                    Spacer()
                    VStack {
                        Text("Use our app to safely do the transactions")
                            .foregroundColor(.gray)
                            .font(.custom(FontUtils.MAIN_REGULAR, size: 16))
                            .multilineTextAlignment(.center)
                            .padding(.top, 1)
                        Spacer(minLength: 20)
                        
//                        NavigationLink(destination: NFCScanInstructionView(),
//                                       isActive: $viewModel.shouldShowNFCScan,
//                                       label: { })
                        
                        NavigationLink(destination: VerifyDocumentView(),
                                       isActive: $isNewWallet,
                                       label: { })
                        
                        NavigationLink(destination: FetchSeedPhraseView(),
                                       isActive: $isHasWallet,
                                       label: { })
                        
                        Button {
                            isNewWallet = true
                            // viewModel.startVerification()
                            // NFCScanInstructionView()
                            // SecretPhraseView()
                        } label: {
                            Text("Create a New Wallet")
                                .font(.custom(FontUtils.MAIN_REGULAR, size: 18))
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .padding(5)
                        .background(Color.black)
                        .cornerRadius(30)
                        Button {
                            print("Wordlist count:", Bip39.wordList.count)
                            isHasWallet = true
                        } label: {
                            Text("Already Have a Wallet")
                                .font(.custom(FontUtils.MAIN_MEDIUM, size: 18))
                                .foregroundColor(.black)
                                .padding(10)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .padding(5)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(30)
                        .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding(.all, 20)
                    .background(.white)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()

    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
