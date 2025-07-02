import SwiftUI

struct MainView: View {
    
    @State var selectedIndex = 0
    
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            
            Color(.white)
                .edgesIgnoringSafeArea(.all)
            
            
            
            ZStack {
                switch selectedIndex {
                case 0:
                    ScrollView { HomeView() }
                case 1:
                    ScrollView { SearchView() }
                case 2:
                    ScrollView { ScanView() }
                case 3:
                    InvoiceScreenView() // No ScrollView wrapper
                default:
                    ScrollView {
                        RadialGradient(gradient: Gradient(colors: [Color("#7A17D7"), Color("#ED74CD"), Color("#EBB5A3")]), center: .topTrailing, startRadius: 100, endRadius: 800)
                            .frame(height: 550)
                            .edgesIgnoringSafeArea(.top)
                        
                        ProfileView()
                            .padding(.top, 50)
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            
            
            
            
            
            BottomNavigationView(selectedIndex: $selectedIndex)
                .edgesIgnoringSafeArea(.bottom)
            
        }
        .navigationBarBackButtonHidden()
        .preferredColorScheme(.dark)
        
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct BottomNavigationView: View {
    
    @Binding var selectedIndex: Int
    
    let icons = [
        "house",
        "magnifyingglass",
        "qrcode.viewfinder",
        "text.document",
        "person"
    ]
    
    var body: some View {
        VStack {
            
            ZStack {
                Divider()
                    .shadow(radius: 10)
                
                ZStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(.white)
                
                
                
                
                HStack {
                    
                    ForEach(0..<5, id: \.self) { number in
                        Spacer()
                        
                        Button(action: {
                            self.selectedIndex = number
                        }, label: {
                            if number == 2 {
                                Image(systemName: icons[number])
                                    .font(.system(size: 25, weight: .regular, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .padding(2)
                                    .background(selectedIndex == number ? .black : Color(UIColor.lightGray))
                                    .cornerRadius(30)
                            } else {
                                Image(systemName: icons[number])
                                    .font(.system(size: 25, weight: .regular, design: .rounded))
                                    .foregroundColor(selectedIndex == number ? .black : Color(UIColor.lightGray))
                            }
                        })
                        
                        Spacer()
                        
                        
                    }
                }
                
                
            }
            
            
            
            
        }
    }
}


