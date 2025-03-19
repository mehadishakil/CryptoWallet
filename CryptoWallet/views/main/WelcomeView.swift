
import SwiftUI

struct WelcomeView: View {
    
    @State private var isNewWallet = false
    @State private var isHasWallet = false

    
    var body: some View {
        NavigationView {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color("#7A17D7"), Color("#ED74CD"), Color("#EBB5A3") ]), center: .topTrailing, startRadius: 100, endRadius: 800)
                    .opacity(1)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    ZStack  {
                        Image("welcome_crypto")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .padding(.top, 50)
                    }
                  
                    Spacer()
                        
                    
                    VStack {
                        
                        HStack {
                            
                            Text("Buy & Sell")
                                .font(.custom(FontUtils.MAIN_BOLD, size: 28))
                            
                            Text("Instantly").foregroundColor(.purple).font(.custom(FontUtils.MAIN_BOLD, size: 32))
                                .underline()
                                .gradientForeground([Color("#7A17D7"), Color("#ED74CD"), Color("#EBB5A3") ])
                        }
                        
                            
                        
                        Text("Use our swapper to safely swap tokens at the best prives, instantly")
                            .foregroundColor(.gray)
                            .font(.custom(FontUtils.MAIN_REGULAR, size: 16))
                            .multilineTextAlignment(.center)
                            .padding(.top, 1)
                        
                        Spacer(minLength: 20)
                        
                        NavigationLink(destination: SecretPhraseView(),
                                                                      isActive: $isNewWallet,
                                                                      label: {  })
                        
                        NavigationLink(destination: MainView(),
                                       isActive: $isHasWallet,
                                                                      label: {  })
                        
                        
                        Button { isNewWallet = true } label: {
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
        .onAppear(perform: {
            isNewWallet = false
            isHasWallet = false
        })
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
