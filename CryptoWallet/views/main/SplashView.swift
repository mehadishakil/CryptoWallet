import SwiftUI

struct SplashView: View {
    
    @State private var isActive = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color(.white)
                    .edgesIgnoringSafeArea(.all)
                
                
                RadialGradient(gradient: Gradient(colors: [.blue.opacity(0.3), .white]), center: .topTrailing, startRadius: 50, endRadius: 400)
                    .opacity(1)
                    .edgesIgnoringSafeArea(.all)
                    
                RadialGradient(gradient: Gradient(colors: [.orange.opacity(0.3), .white.opacity(0)]), center: .bottomLeading, startRadius: 10, endRadius: 400)
                    .edgesIgnoringSafeArea(.all)

                
                Text("CryptoWallet")
                    .font(.title)
                    .fontWeight(.bold)
                
                
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
