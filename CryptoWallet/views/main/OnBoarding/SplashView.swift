import SwiftUI

struct SplashView: View {
    
    @State private var isActive = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color(.white)
                    .edgesIgnoringSafeArea(.all)
                
                
                RadialGradient(gradient: Gradient(colors: [.blue.opacity(0.5), .white.opacity(0.5)]), center: .topTrailing, startRadius: 30, endRadius: 300)
                    .opacity(1)
                    .edgesIgnoringSafeArea(.all)
                    
                RadialGradient(gradient: Gradient(colors: [.cyan.opacity(0.5), .white.opacity(0.5)]), center: .bottomLeading, startRadius: 10, endRadius: 300)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    
                    Text("CryptoWallet")
                        .font(.title.bold())
                }
                
                NavigationLink(destination: WelcomeView(),
                                                              isActive: $isActive,
                                                              label: {  })
            }
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.isActive = true
                        }
        })
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
