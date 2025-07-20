//import SwiftUI
//
//struct ConfirmSecretPhraseView: View {
//    
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
//    
//    @State var words: [SecretWord] = []
//    @State var confirmedWords: [String] = []
//    
//    var body: some View {
//        NavigationView {
//            ZStack (alignment: .leading) {
//                Color(.white)
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack {
//                    ScrollView {
//                        VStack {
//                            TitleTopView()
//                            ConfirmedListView(words: $confirmedWords, onUnConfirmWord: { word in
//                                print("UNCONFIRM \(word)")
//                                words = words.map { wo in
//                                    if (wo.text == word) {
//                                        wo.isSelected = false
//                                    }
//                                    return wo
//                                }
//                            })
//                            WordsToConfirmView(words: $words, onSelect: { word in
//                               
//                                confirmedWords.append(word.text)
//                            })
//                            
//                            VStack {}
//                                .frame(height: 300)
//                        }
//                        .padding(20)
//                    }
//                    .padding(10)
//                    
//                    
//                    BottomView()
//                }
//            }
//        }
//        .navigationBarBackButtonHidden()
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                
//                Image(systemName: "arrow.backward")
//                    .foregroundColor(.gray)
//                    .font(.system(size: 25))
//                    .onTapGesture {
//                        self.presentationMode.wrappedValue.dismiss()
//                    }
//            }
//            
//        }
//    }
//    
//    
//}
//
//struct ConfirmSecretPhraseView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConfirmSecretPhraseView(words: [])
//    }
//}
//
//struct ConfirmedListView: View {
//    
//    var gridLayout = [
//        GridItem(.flexible()),
//        GridItem(.flexible())
//    ]
//    
//    @Binding var words: [String]
//    
//    let onUnConfirmWord: (String) -> Void
//    
//    var body: some View {
//        VStack {
//            
//            ScrollView (.vertical, showsIndicators: false) {
//                LazyVGrid(columns: gridLayout, alignment: .center, spacing: 10) {
//                    ForEach(0..<12, id: \.self) { index in
//                        WordView(index: index, selected: index < words.count, text: index < words.count ? words[index] : "", onWordClick: { text in
//                            words = words.filter { $0 != text }
//                            onUnConfirmWord(text)
//                        })
//                        .padding(3)
//                        
//                    }
//                }
//                .padding()
//                
//            }
//            .padding(.top, 10)
//        }
//        
//    }
//}
//
//struct TitleTopView: View {
//    var body: some View {
//        VStack {
//            Text("Confirm Secret Recovery Words")
//                .font(.custom(FontUtils.MAIN_BOLD, size: 28))
//                .foregroundColor(.black)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            Text("Select the words in order it was presented on previous screen.")
//                .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
//                .foregroundColor(.gray)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.top, -10)
//        }
//    }
//}
//
//struct BottomView: View {
//    @State var goToScan = false
//    
//    var body: some View {
//        VStack {
//            VStack{
//                Color.gray.frame(height: 10 / UIScreen.main.scale)
//                    .gradientForeground([Color("#7A17D7"), Color("#ED74CD"), Color("#EBB5A3") ])
//            }
//            .padding(.top, -20)
//            
//            NavigationLink(destination: FaceIdFingerScanView(),
//                           isActive: $goToScan,
//                                                          label: {  })
//           
//            
//            Button {
//                goToScan = true
//            } label: {
//                Text("Confirmation")
//                    .font(.custom(FontUtils.MAIN_REGULAR, size: 18))
//                    .foregroundColor(.white)
//                    .padding(10)
//                
//            }
//            .frame(maxWidth: .infinity, minHeight: 60)
//            
//            .background(Color.black)
//            .cornerRadius(30)
//            .padding(.vertical, 10)
//            .padding(.horizontal, 20)
//        }
//        .onAppear {
//            goToScan = false
//        }
//    }
//}
//
//struct WordsToConfirmView: View {
//    
//    @Binding var words: [SecretWord]
//    
//    let onSelect: (SecretWord) -> ()
//    
//    var body: some View {
//        GeometryReader { geometry in
//            self.generateContent(in: geometry)
//        }
//    }
//    
//    
//    private func generateContent(in g: GeometryProxy) -> some View {
//        var width = CGFloat.zero
//        var height = CGFloat.zero
//        
//        return ZStack(alignment: .topLeading) {
//            ForEach(self.words, id: \.id) { word in
//                self.item(word)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .alignmentGuide(.leading, computeValue: { d in
//                        if (abs(width - d.width) > g.size.width)
//                        {
//                            width = 0
//                            height -= d.height
//                        }
//                        let result = width
//                        if word.text == self.words.last?.text {
//                            width = 0 //last item
//                        } else {
//                            width -= d.width
//                        }
//                        return result
//                    })
//                    .alignmentGuide(.top, computeValue: {d in
//                        let result = height
//                        if word.text == self.words.last?.text {
//                            height = 0 // last item
//                        }
//                        return result
//                    })
//            }
//            
//            
//        }
//    }
//    
//    private func item(_ word: SecretWord) -> some View {
//        Text(word.text)
//            .padding(.all, 13)
//            .font(.custom(FontUtils.MAIN_BOLD, size: 15))
//            .background(word.isSelected ? Color("#F1F1F2") : Color.white)
//            .foregroundColor(word.isSelected ? Color("#D3D4D7") : Color.black)
//            .cornerRadius(30)
//            .shadow(color: .gray, radius: 5, x: 2, y: 2)
//            .onTapGesture(count: 1, perform: {
//                if (!word.isSelected) {
//                    words = words.map { wo in
//                        if (wo.text == word.text) {
//                            wo.isSelected = true
//                        }
//                        return wo
//                    }
//                    word.isSelected = true
//                    onSelect(word)
//                }
//                
//            })
//    }
//}
//
//struct WordView: View {
//    
//    var index: Int
//    var selected: Bool
//    var text: String
//    
//    let onWordClick: (String) -> Void
//    
//    var body: some View {
//        
//        if selected {
//            ZStack {
//                Text("\(index + 1). \(text)")
//                    .font(.custom(FontUtils.MAIN_BOLD, size: 16))
//                    .padding(10)
//                    .foregroundColor(.black)
//                    .frame(maxWidth: .infinity)
//                    .lineLimit(1)
//                
//                
//            }
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(Color.black, lineWidth: 1)
//            )
//            .onTapGesture {
//                onWordClick(text)
//            }
//        } else {
//            ZStack {
//                Text("\(index + 1).                 ")
//                    .font(.custom(FontUtils.MAIN_BOLD, size: 16))
//                    .padding(10)
//                    .foregroundColor(.gray)
//                    .frame(maxWidth: .infinity)
//                    .lineLimit(1)
//                
//                
//            }
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(.gray, lineWidth: 1)
//            )
//        }
//    }
//}
//
//#Preview(body: {
//    ConfirmSecretPhraseView()
//})

import SwiftUI

struct ConfirmSecretPhraseView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var inputText: String = ""
    @State private var keywords: [String] = []
    @State private var goToScan = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Title
                TitleTopView()
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
                .padding(.bottom, 32)

                // Confirmation button
                BottomView(goToScan: $goToScan, seedphrase: $keywords)
            }
            .navigationBarBackButtonHidden()
        }
    }
}

// MARK: - Title
struct TitleTopView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Confirm Secret Words")
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom)
            Text("Enter each word in order by typing and pressing space.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Keywords Flow Layout
struct KeywordsFlowView: View {
    @Binding var keywords: [String]
    let onRemove: (String) -> Void

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            var x: CGFloat = 0
            var y: CGFloat = 0

            ZStack(alignment: .topLeading) {
                ForEach(Array(keywords.enumerated()), id: \ .offset) { index, word in
                    let item = KeywordCard(word: word) {
                        onRemove(word)
                    }
                    item
                        .alignmentGuide(.leading) { dimension in
                            if abs(x - dimension.width) > width {
                                x = 0
                                y -= dimension.height + 8
                            }
                            let result = x
                            if index == keywords.count - 1 {
                                x = 0
                            } else {
                                x -= dimension.width + 8
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = y
                            if index == keywords.count - 1 {
                                y = 0
                            }
                            return result
                        }
                }
            }
        }
    }
}

// MARK: - Keyword Card
struct KeywordCard: View {
    let word: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(word)
                .font(.system(size: 16, weight: .medium))
                .padding(.vertical, 8)
                .padding(.leading, 12)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
            }
            .padding(.trailing, 8)
        }
        .background(Color(.systemGray5))
        .cornerRadius(20)
        .shadow(radius: 1)
    }
}

// MARK: - Bottom Confirmation Button
struct BottomView: View {
    @Binding var goToScan: Bool
    @Binding var seedphrase : [String]

    var body: some View {
        VStack(spacing: 0) {
            Color.gray.frame(height: 1)
                .padding(.bottom, 10)

            NavigationLink(destination: WalletView(seedPhrase: seedphrase.joined(separator: " ")), isActive: $goToScan) {
                EmptyView()
            }

            Button(action: {
                goToScan = true
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

struct ConfirmSecretPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmSecretPhraseView()
    }
}
