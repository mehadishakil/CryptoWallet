import SwiftUI
//
//struct VerifyDocumentView: View {
//    @State private var selectedLanguage: String = "English"
//
//    var body: some View {
//        VStack {
//            VStack(alignment: .leading, spacing: 20) {
//                Text("Verify Your Document")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.horizontal)
//
//                Text("Before we begin, we need you verify your document.")
//                    .font(.body)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal)
//
//                Image("biometric_illustration") // Replace with your actual image asset name
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxWidth: 300)
//                    .padding(.vertical)
//                    .frame(maxWidth: .infinity) // Center the image
//
//                Spacer()
//
//                HStack {
//                    Text("By clicking the button below, you consent to Persona, our vendor, collecting, using, and utilizing its service providers to process your biometric information to verify your identity, identify fraud, and improve Persona's platform in accordance with its ")
//                        .font( .caption)
//                        .foregroundColor(.gray)
//                    + Text("Privacy Policy")
//                        .font(.caption)
//                        .foregroundColor(.blue) // Make it look like a link
//                    + Text(". Your biometric information will be stored for no more than 3 years.")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//                .padding()
//                    
//
//                Button(action: {
//                    // Action to begin verifying
//                    print("Begin verifying tapped")
//                }) {
//                    Text("Begin verifying")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black)
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                }
//                .padding(.bottom, 20)
//            }
//
//            Spacer()
//
//            // Footer
//            VStack {
//                Divider()
//                    .padding(.vertical, 5)
//
//                HStack {
//                    Menu {
//                        Button("English", action: { selectedLanguage = "English" })
//                        Button("Spanish", action: { selectedLanguage = "Spanish" })
//                        // Add more languages
//                    } label: {
//                        HStack {
//                            Image(systemName: "globe")
//                            Text(selectedLanguage)
//                            Image(systemName: "chevron.down")
//                        }
//                        .foregroundColor(.gray)
//                    }
//
//                    Spacer()
//
//                    HStack(spacing: 5) {
//                        Text("SECURED WITH")
//                            .font(.caption2)
//                            .foregroundColor(.gray)
//                        Image("persona_logo") // Replace with your actual Persona logo asset
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 15)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 10)
//            }
//        }
//        .navigationBarHidden(true) // Hide default navigation bar if using NavigationView
//    }
//}
//
//import SwiftUI
//
//struct CountrySelectionView: View {
//    @State private var selectedCountry: String = "United States"
//
//    var body: some View {
//        VStack {
//            VStack(alignment: .leading, spacing: 20) {
//                Text("What country is your government ID from?")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.horizontal)
//
//                Text("This helps us determine the best way to verify your identity.")
//                    .font(.body)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal)
//
//                // Country Picker/Dropdown
//                Picker(selection: $selectedCountry, label: Text("Country")) {
//                    Text("United States").tag("United States")
//                    Text("Canada").tag("Canada")
//                    Text("Mexico").tag("Mexico")
//                    // Add more countries
//                }
//                .pickerStyle(.menu) // Or .wheel for a larger selection
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
//                .padding(.horizontal)
//
//
//                Spacer() // Pushes content to the top
//
//                Button(action: {
//                    // Action for Select button
//                    print("Selected country: \(selectedCountry)")
//                }) {
//                    Text("Select")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black)
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                }
//                .padding(.bottom, 20)
//            }
//        }
//        .navigationBarHidden(true) // Hide default navigation bar
//    }
//}
//
//import SwiftUI
//
//struct UploadIDPhotoView: View {
//    var body: some View {
//        VStack {
//            VStack(alignment: .leading, spacing: 20) {
//                Text("Upload a photo of that ID")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.horizontal)
//
//                Text("We require a photo of your ID to verify your identity.")
//                    .font(.body)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal)
//
//                Text("Choose 1 of the following options")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//
//                ScrollView {
//                    VStack(spacing: 15) {
//                        IDOptionRow(iconName: "car.fill", title: "Driver License") { print("Driver License tapped") }
//                        IDOptionRow(iconName: "person.crop.rectangle.fill", title: "State ID") { print("State ID tapped") }
//                        IDOptionRow(iconName: "globe", title: "Passport") { print("Passport tapped") }
//                        IDOptionRow(iconName: "creditcard.fill", title: "Passport Card") { print("Passport Card tapped") }
//                        IDOptionRow(iconName: "person.2.fill", title: "Permanent Resident Card") { print("Permanent Resident Card tapped") }
//                        IDOptionRow(iconName: "doc.text.fill", title: "Non-Citizen Travel Document") { print("Non-Citizen Travel Document tapped") }
//                        // Add more options as needed
//                    }
//                    .padding(.horizontal)
//                }
//                Spacer()
//            }
//        }
//        .navigationBarHidden(true) // Hide default navigation bar
//    }
//}
//
//struct IDOptionRow: View {
//    let iconName: String
//    let title: String
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Image(systemName: iconName)
//                    .font(.title2)
//                    .foregroundColor(.blue)
//                    .frame(width: 40) // Fixed width for alignment
//
//                Text(title)
//                    .font(.body)
//                    .foregroundColor(.primary)
//
//                Spacer()
//
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.gray)
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(10)
//            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//        }
//    }
//}
//
//
//// MARK: - Enhanced NFC Scan Instruction View
//struct NFCScanInstructionView: View {
//    @State private var animationTrigger = false
//    @State private var navigateToResults = false
//    @State private var data : String = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                VStack(spacing: 30) {
//                    // Animated NFC Icon
//                    ZStack {
//                        Circle()
//                            .fill(Color.blue.opacity(0.1))
//                            .frame(width: 160, height: 160)
//                            .scaleEffect(animationTrigger ? 1.2 : 1.0)
//                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animationTrigger)
//                        
//                        Image(systemName: "wave.3.right.circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 120, height: 120)
//                            .foregroundColor(.blue)
//                            .scaleEffect(animationTrigger ? 1.1 : 1.0)
//                            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animationTrigger)
//                    }
//                    .onAppear {
//                        animationTrigger = true
//                    }
//                    
//                    Text("Tap Document to NFC Chip")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                    
//                    Text("Place your document (e.g., ePassport) near the top edge of your iPhone to read the embedded chip.")
//                        .font(.body)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 40)
//                    
//                    
//                }
//                
//                Spacer()
//                
//                nfcButton(data: $data)
//                    .frame(width: 100, height: 30)
//                                    .padding()
//                                    .background(Color.blue)
//                                    .cornerRadius(12)
//                                    .padding(.horizontal)
//                
//                Spacer()
//            }
//            .navigationBarHidden(true)
//        }
//    }
//}
//
//
//
//struct BiometricFlow_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            VerifyDocumentView()
//            CountrySelectionView()
//            UploadIDPhotoView()
//            NFCScanInstructionView()
//        }
//    }
//}


struct VerifyDocumentView: View {
    @State private var selectedLanguage: String = "English"
    @Binding var showCountrySelectionView: Bool // New binding for navigation

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Verify Your Document")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Text("Before we begin, we need you verify your document.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                Image("biometric_illustration") // Replace with your actual image asset name
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity) // Center the image

                Spacer()

                HStack {
                    Text("By clicking the button below, you consent to Persona, our vendor, collecting, using, and utilizing its service providers to process your biometric information to verify your identity, identify fraud, and improve Persona's platform in accordance with its ")
                        .font(.caption)
                        .foregroundColor(.gray)
                    + Text("Privacy Policy")
                        .font(.caption)
                        .foregroundColor(.blue) // Make it look like a link
                    + Text(". Your biometric information will be stored for no more than 3 years.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()


                Button(action: {
                    // Action to begin verifying
                    print("Begin verifying tapped")
                    showCountrySelectionView = true // Navigate to the next view
                }) {
                    Text("Begin verifying")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }

            Spacer()

            // Footer
            VStack {
                Divider()
                    .padding(.vertical, 5)

                HStack {
                    Menu {
                        Button("English", action: { selectedLanguage = "English" })
                        Button("Spanish", action: { selectedLanguage = "Spanish" })
                        // Add more languages
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                            Text(selectedLanguage)
                            Image(systemName: "chevron.down")
                        }
                        .foregroundColor(.gray)
                    }

                    Spacer()

                    HStack(spacing: 5) {
                        Text("SECURED WITH")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Image("persona_logo") // Replace with your actual Persona logo asset
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .navigationBarHidden(true) // Hide default navigation bar if using NavigationView
    }
}

import SwiftUI

struct CountrySelectionView: View {
    @State private var selectedCountry: String = "United States"
    @Binding var showUploadIDPhotoView: Bool // New binding for navigation

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("What country is your government ID from?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Text("This helps us determine the best way to verify your identity.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                // Country Picker/Dropdown
                Picker(selection: $selectedCountry, label: Text("Country")) {
                    Text("United States").tag("United States")
                    Text("Canada").tag("Canada")
                    Text("Mexico").tag("Mexico")
                    // Add more countries
                }
                .pickerStyle(.menu) // Or .wheel for a larger selection
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                .padding(.horizontal)


                Spacer() // Pushes content to the top

                Button(action: {
                    // Action for Select button
                    print("Selected country: \(selectedCountry)")
                    showUploadIDPhotoView = true // Navigate to the next view
                }) {
                    Text("Select")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true) // Hide default navigation bar
    }
}

import SwiftUI

struct UploadIDPhotoView: View {
    @Binding var showNFCScanInstructionView: Bool // New binding for navigation

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Upload a photo of that ID")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Text("We require a photo of your ID to verify your identity.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                Text("Choose 1 of the following options")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.top, 10)

                ScrollView {
                    VStack(spacing: 15) {
                        IDOptionRow(iconName: "car.fill", title: "Driver License") {
                            print("Driver License tapped")
                            showNFCScanInstructionView = true // Navigate
                        }
                        IDOptionRow(iconName: "person.crop.rectangle.fill", title: "State ID") {
                            print("State ID tapped")
                            showNFCScanInstructionView = true // Navigate
                        }
                        IDOptionRow(iconName: "globe", title: "Passport") {
                            print("Passport tapped")
                            showNFCScanInstructionView = true // Navigate
                        }
                        IDOptionRow(iconName: "creditcard.fill", title: "Passport Card") {
                            print("Passport Card tapped")
                            showNFCScanInstructionView = true // Navigate
                        }
                        IDOptionRow(iconName: "person.2.fill", title: "Permanent Resident Card") {
                            print("Permanent Resident Card tapped")
                            showNFCScanInstructionView = true // Navigate
                        }
                        IDOptionRow(iconName: "doc.text.fill", title: "Non-Citizen Travel Document") {
                            print("Non-Citizen Travel Document tapped")
                            showNFCScanInstructionView = true // Navigate
                        }
                        // Add more options as needed
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
        .navigationBarHidden(true) // Hide default navigation bar
    }
}

struct IDOptionRow: View {
    let iconName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40) // Fixed width for alignment

                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}


// MARK: - Enhanced NFC Scan Instruction View
struct NFCScanInstructionView: View {
    @State private var animationTrigger = false
    @State private var navigateToResults = false
    @State private var data : String = ""

    var body: some View {
        VStack {
            VStack(spacing: 30) {
                // Animated NFC Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .scaleEffect(animationTrigger ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animationTrigger)

                    Image(systemName: "wave.3.right.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                        .scaleEffect(animationTrigger ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animationTrigger)
                }
                .onAppear {
                    animationTrigger = true
                }

                Text("Tap Document to NFC Chip")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Place your document (e.g., ePassport) near the top edge of your iPhone to read the embedded chip.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)


            }

            Spacer()

            // You'll need to define nfcButton or remove it if it's not provided.
            // For now, I'm commenting it out or replacing it with a placeholder button.
            // If `nfcButton` is a custom view, ensure it's defined elsewhere.
            // nfcButton(data: $data)
            nfcButton(data: $data)
                .frame(width: 100, height: 30)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal)


            Spacer()
        }
        .navigationBarHidden(true)
    }
}



struct BiometricFlow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
                .environmentObject(VerificationManager()) // Provide the environment object for preview
        }
    }
    
}
