
import SwiftUI
import Toast

struct SecretPhraseView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private var gridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var words: [SecretWord]?
    @State private var isReadyToConfirm = false
    
    var body: some View {
        NavigationView {
            ZStack (alignment: .leading) {
                Color(.white)
                    .edgesIgnoringSafeArea(.all)
                
                
                VStack {
                    VStack {
                        Text("Secret Recovery Words")
                            .font(.custom(FontUtils.MAIN_BOLD, size: 28))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Your Secret Recovery Phrase (SRP) is a unique 12-word phrase that is generated when you first set up Crypee. Your funds are connected to that phrase.")
                            .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, -10)
                        
                        
                        if let words = words {
                            ScrollView (.vertical, showsIndicators: false) {
                                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 20) {
                                    ForEach(0..<words.count) { index in
                                        
                                        Text("\(index + 1). \(words[index].text)")
                                            .font(.custom(FontUtils.MAIN_BOLD, size: 14))
                                            .padding(5)
                                    }
                                }
                                
                            }
                            .padding(.top, 50)
                        } else {
                            LoadingView()
                                .task {
                                    do {
                                        words = try await WordGeneratorManager.getSecretWords()
                                        
                                    } catch {
                                        print("Error getting weather")
                                    }
                                }
                        }
                        
                        Button {
                            copyToClipboard(words ?? [])
                        } label: {
                            HStack {
                                Image("clipboard")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .padding(.trailing, -10)
                                Text("Copy to Clipboard")
                                    .font(.custom(FontUtils.MAIN_BOLD, size: 18))
                                    .foregroundColor(.gray)
                                    .padding(10)
                            }
                            
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .padding(5)
                        
                        
                        
                    }
                    .padding(20)
                    
                    
                    VStack{
                        Color.gray.frame(height: 10 / UIScreen.main.scale)
                            .gradientForeground([Color(hex: "#7A17D7"), Color(hex: "#ED74CD"), Color(hex: "#EBB5A3") ])
                    }
                    .padding(.top, -20)
                    
                    NavigationLink(destination: ConfirmSecretPhraseView(words: words ?? []),
                                   isActive: $isReadyToConfirm,
                                                                  label: {  })
                    
                    Button {
                        self.isReadyToConfirm = true
                    } label: {
                        Text("Ok, I saved")
                            .font(.custom(FontUtils.MAIN_REGULAR, size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                        
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    
                    .background(Color.black)
                    .cornerRadius(30)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    
                }
                
                
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                
                Image(systemName: "arrow.backward")
                    .foregroundColor(.gray)
                    .font(.system(size: 25))
                    .onTapGesture {
                        self.presentationMode.wrappedValue.dismiss()
                    }
            }
            
        }
    }
    
    func copyToClipboard(_ words: [SecretWord]) {
        let wordsString = words.map { $0.text }.joined(separator: " ")
        
        UIPasteboard.general.string = wordsString
        
        let toast = Toast.text("Secret Phrase copied to clipboard")
        toast.show()
    }
}

struct SecretPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        SecretPhraseView()
    }
}
