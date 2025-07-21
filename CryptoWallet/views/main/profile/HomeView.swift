//import SwiftUI
//import Charts
//import Toast
//import UIKit
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
//
//
//struct HomeView: View {
//    
//    private let url = "https://scontent.fdac138-2.fna.fbcdn.net/v/t39.30808-6/475995859_1154020176416021_1382538768621471338_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeFJLrlRY_Kx1uYSimzy2GK9FMWRBwz2XQ4UxZEHDPZdDo2OXAsy1lo2WOIvIS9hR5RxFODkGex-wLI2ceGsa21w&_nc_ohc=zyEHJqRp1gQQ7kNvwGRaKCq&_nc_oc=AdkXQtnN5cdoKC501Cz0vLPbejHO_BGi-40BWJC6t31rO8YqRh3VjEWIdvTXSbnB2CE&_nc_zt=23&_nc_ht=scontent.fdac138-2.fna&_nc_gid=gxlkAeEBl-fSMf7WnO-xLQ&oh=00_AfRfjQC48sbuVqe7Xd9j_1mqQBHkg9Lp5zZW0c0lIDq2TQ&oe=6882F1C1"
//    
//    @State var selectedList: String = "All"
//    
//    var lists = [
//        "All",
//        "Sent",
//        "Received",
//        "Denied"
//    ]
//    
//    var transactions: [TransactionItem] = [
//        TransactionItem(id: UUID(), type: .received, amount: "1,250", source: "Coinbase Wallet", date: "Jun 27, 2025"),
//        TransactionItem(id: UUID(), type: .sent, amount: "890", source: "MetaMask", date: "Jun 26, 2025"),
//        TransactionItem(id: UUID(), type: .received, amount: "2,100", source: "Binance", date: "Jun 25, 2025"),
//        TransactionItem(id: UUID(), type: .sent, amount: "450", source: "Trust Wallet", date: "Jun 24, 2025"),
//        TransactionItem(id: UUID(), type: .received, amount: "750", source: "Coinbase Wallet", date: "Jun 23, 2025"),
//        TransactionItem(id: UUID(), type: .sent, amount: "320", source: "MetaMask", date: "Jun 22, 2025"),
//        TransactionItem(id: UUID(), type: .denied, amount: "100", source: "Unknown", date: "Jun 21, 2025")
//    ]
//    
//    var filteredTransactions: [TransactionItem] {
//        switch selectedList {
//        case "Sent":
//            return transactions.filter { $0.type == .sent }
//        case "Received":
//            return transactions.filter { $0.type == .received }
//        case "Denied":
//            return transactions.filter { $0.type == .denied }
//        default:
//            return transactions
//        }
//    }
//    @StateObject private var wallet = EthereumWallet()
//    
//    var body: some View {
//        NavigationView {
//            
//            ScrollView {
//                
//                HomeTopView(url: url)
//                    .padding(.top, 8)
//                
//                HomeBalanceView(wallet: wallet)
//                
//                HStack {
//                    Text("Recent transactions")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                    
//                    Spacer()
//                    
//                    NavigationLink(
//                        destination: AllTransactionsView(
//                            allTransactions: transactions
//                        )
//                    ) {
//                        Image(systemName: "chevron.right")
//                            .frame(height: 30)
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 30)
//                
//                ListsCategoriesView(selectedList: $selectedList, lists: lists)
//                    .padding(.bottom)
//                
//                
//                VStack {
//                    ForEach(filteredTransactions) { tx in
//                        NavigationLink(
//                            destination: TransactionInfoView(
//                                transaction: tx
//                            )
//                        ) {
//                            TransactionListItemView(transaction: tx)
//                                .padding(.horizontal, 20)
//                        }
//                    }
//                    
//                }
//            }
//            .refreshable {
//                print("Refreshing balance...")
//                await wallet.getBalance() // Call getBalance on the wallet object
//            }
//            .padding(.top, 40)
//            .navigationBarHidden(true)
//            .background(Color(.systemGroupedBackground)).edgesIgnoringSafeArea(.all)
//
//            .padding(.top, 40)
//            .navigationBarHidden(true)
//            .background(Color(.systemGroupedBackground)).edgesIgnoringSafeArea(.all)
//        }
//        .navigationBarBackButtonHidden()
//    }
//}
//
//struct HomeTopView: View {
//    let url: String
//    @AppStorage("walletAddress") private var walletAddress: String = ""
//    @State private var showReceiveSheet = false
//    
//    var body: some View {
//        HStack(spacing: 16) {
//            // Profile Image
//            AsyncImage(url: URL(string: url)) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 65, height: 65)
//                    .clipShape(RoundedRectangle(cornerRadius: 40))
//            } placeholder: {
//                Color.gray
//                    .frame(width: 65, height: 65)
//                    .clipShape(RoundedRectangle(cornerRadius: 40))
//            }
//
//            
//            
//            VStack(alignment: .leading, spacing: 6) {
//                HStack {
//                    Text(walletAddress)
//                        .font(.custom(FontUtils.MAIN_BOLD, size: 16))
//                        .truncationMode(.middle)
//                        .lineLimit(1)
//                        .foregroundColor(.primary.opacity(0.8))
//                        .frame(maxWidth: 160)
//                }
//                
//                HStack(spacing: 4) {
//                    Image(systemName: "qrcode.viewfinder")
//                    Text("Receive")
//                        .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
//                }
//                .foregroundColor(.primary.opacity(0.8))
//            }
//            .onTapGesture {
//                showReceiveSheet = true
//            }
//            .sheet(isPresented: $showReceiveSheet) {
//                ReceiveTransactionView(myAddress: walletAddress)
//                    .presentationDetents([.large])
//            }
//            
//            Spacer()
//            
//            Button(action: {
//                // Bell action
//            }) {
//                Image(systemName: "bell")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 20, height: 20)
//                    .foregroundColor(.black)
//            }
//            .frame(width: 45, height: 45)
//            .background(Color.white)
//            .cornerRadius(30)
//            .shadow(radius: 5)
//        }
//        .padding(20)
//    }
//}
//
//struct HomeBalanceView: View {
//    @ObservedObject var wallet: EthereumWallet
//    
//    var body: some View {
//        HStack {
//            
//                VStack (alignment: .leading) {
//                    Text("Your Balance")
//                        .font(.title2)
//                        .foregroundColor(.primary.opacity(0.7))
//                        .padding(.bottom, 2)
//                    
//                    Text("\(wallet.balance) ETH")
//                        .font(.title)
//                        .fontWeight(.medium)
//                        .foregroundStyle(.primary.opacity(0.8))
//                }
//            .padding(.top, 20)
//            .padding(.horizontal, 25)
//            
//            Spacer()
//            
//            VStack(alignment: .trailing) {
//                Spacer()
//                
//                if let balance = Double(wallet.balance) {
//                    Text(String(format: "$%.2f USD", balance * 3795.50))
//                        .font(.callout)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.secondary)
//                        .padding(.bottom, 4)
//                    
//                    Text(String(format: "$%.2f BDT", balance * 461,365.72))
//                        .font(.callout)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.secondary)
//                        .padding(.bottom, 40)
//                    
//                } else {
//                    Text("Invalid balance")
//                        .font(.headline)
//                        .foregroundColor(.red)
//                }
//            }
//            .padding(.trailing)
//
//            
//        }
//        .frame(height: 170)
//        .background(.white)
//        .cornerRadius(15, corners: .allCorners)
//        .shadow(radius: 4)
//        .padding(.horizontal, 20)
//    }
//}
//
//
//struct ListsCategoriesView: View {
//    
//    @Binding var selectedList: String
//    var lists: [String]
//    
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 8) {
//                ForEach(lists, id: \.self) { string in
//                    Button(action: {
//                        selectedList = string
//                    }, label: {
//                        HStack {
//                            Image(systemName: iconName(for: string))
//                                .font(.system(size: 12, weight: .bold))
//                            Text(string)
//                                .font(.custom(FontUtils.MAIN_BOLD, size: 12))
//                        }
//                        .foregroundColor(selectedList == string ? .white : .black)
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 16)
//                        .background(selectedList == string ? Color.black : Color.white)
//                        .cornerRadius(20)
//                        .shadow(color: .gray.opacity(0.1), radius: 1, x: 0, y: 1)
//                    })
//                }
//            }
//            .padding(.horizontal, 20)
//        }
//    }
//    
//    func iconName(for list: String) -> String {
//        switch list {
//        case "Sent":
//            return "arrow.up.right"
//        case "Received":
//            return "arrow.down.left"
//        case "Denied":
//            return "nosign"
//        default:
//            return "tray.full"
//        }
//    }
//}
//
//struct TransactionListItemView: View {
//    var transaction: TransactionItem
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            ZStack {
//                Circle()
//                    .fill(transaction.type == .received ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
//                    .frame(width: 44, height: 44)
//                Image(systemName: transaction.type == .received ? "arrow.down.left" : "arrow.up.right")
//                    .foregroundColor(transaction.type == .received ? .green : .red)
//                    .font(.system(size: 18, weight: .bold))
//            }
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(transaction.type == .received ? "Received" : "Sent")
//                    .font(.custom(FontUtils.MAIN_BOLD, size: 16))
//                    .foregroundColor(.black)
//                
//                Text("From: \(transaction.source)")
//                    .font(.custom(FontUtils.MAIN_REGULAR, size: 13))
//                    .foregroundColor(.gray)
//            }
//            
//            Spacer()
//            
//            VStack(alignment: .trailing, spacing: 4) {
//                Text("\(transaction.type == .received ? "+" : "-")$\(transaction.amount)")
//                    .font(.custom(FontUtils.MAIN_BOLD, size: 16))
//                    .foregroundColor(.black)
//                
//                Text(transaction.date)
//                    .font(.custom(FontUtils.MAIN_REGULAR, size: 13))
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 10)
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(color: .gray.opacity(0.05), radius: 2, x: 0, y: 1)
//        .padding(.bottom, 8)
//    }
//}
//
//struct AllTransactionsView: View {
//    @State private var searchText: String = ""
//    @State private var selectedFilter: TransactionType? = nil
//    var allTransactions: [TransactionItem]
//    
//    var filtered: [TransactionItem] {
//        allTransactions.filter { tx in
//            (searchText.isEmpty || tx.id.uuidString.localizedCaseInsensitiveContains(searchText)) &&
//            (selectedFilter == nil || tx.type == selectedFilter)
//        }
//    }
//    
//    var body: some View {
//        VStack {
//            TextField("Search by TX ID", text: $searchText)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            
//            Picker("Filter", selection: $selectedFilter) {
//                Text("All").tag(TransactionType?.none)
//                Text("Sent").tag(TransactionType?.some(.sent))
//                Text("Received").tag(TransactionType?.some(.received))
//                Text("Denied").tag(TransactionType?.some(.denied))
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding(.horizontal)
//            
//            ScrollView {
//                VStack {
//                    ForEach(filtered) { tx in
//                        NavigationLink(
//                            destination: TransactionInfoView(
//                                transaction: tx
//                            )
//                        ) {
//                            TransactionListItemView(transaction: tx)
//                                .padding(.horizontal, 20)
//                        }
//                    }
//                    
//                }
//            }
//            .padding(.vertical)
//            .background(Color(.systemGroupedBackground)).edgesIgnoringSafeArea(.all)
//            
//        }
//        .navigationTitle("All Transactions")
//    }
//}
//
//struct TransactionInfoView: View {
//    var transaction: TransactionItem
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            ZStack {
//                Circle()
//                    .fill(color(for: transaction.type).opacity(0.1))
//                    .frame(width: 80, height: 80)
//                Image(systemName: icon(for: transaction.type))
//                    .font(.system(size: 40, weight: .bold))
//                    .foregroundColor(color(for: transaction.type))
//            }
//            Text(title(for: transaction.type))
//                .font(.title).fontWeight(.bold)
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Amount: $\(transaction.amount)")
//                Text("Source: \(transaction.source)")
//                Text("Date: \(transaction.date)")
//                Text("Transaction ID: \(transaction.id.uuidString)")
//            }
//            .padding()
//            
//            Spacer()
//        }
//        .padding()
//        .navigationTitle("Transaction Details")
//    }
//    
//    private func icon(for type: TransactionType) -> String {
//        switch type {
//        case .sent: return "arrow.up.right"
//        case .received: return "arrow.down.left"
//        case .denied: return "nosign"
//        }
//    }
//    
//    private func color(for type: TransactionType) -> Color {
//        switch type {
//        case .sent: return .red
//        case .received: return .green
//        case .denied: return .orange
//        }
//    }
//    
//    private func title(for type: TransactionType) -> String {
//        switch type {
//        case .sent: return "Sent"
//        case .received: return "Received"
//        case .denied: return "Denied"
//        }
//    }
//}
//
//// MARK: - Transaction Detail Screen
//struct TransactionDetailView: View {
//    var transaction: TransactionItem
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            ZStack {
//                Circle()
//                    .fill(color(for: transaction.type).opacity(0.1))
//                    .frame(width: 80, height: 80)
//                Image(systemName: icon(for: transaction.type))
//                    .font(.system(size: 40, weight: .bold))
//                    .foregroundColor(color(for: transaction.type))
//            }
//            Text(title(for: transaction.type))
//                .font(.title).fontWeight(.bold)
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Amount: $\(transaction.amount)")
//                Text("Source: \(transaction.source)")
//                Text("Date: \(transaction.date)")
//                Text("Transaction ID: \(transaction.id.uuidString)")
//            }
//            .padding()
//            
//            Spacer()
//        }
//        .padding()
//        .navigationTitle("Transaction Details")
//    }
//    
//    private func icon(for type: TransactionType) -> String {
//        switch type {
//        case .sent: return "arrow.up.right"
//        case .received: return "arrow.down.left"
//        case .denied: return "nosign"
//        }
//    }
//    
//    private func color(for type: TransactionType) -> Color {
//        switch type {
//        case .sent: return .red
//        case .received: return .green
//        case .denied: return .orange
//        }
//    }
//    
//    private func title(for type: TransactionType) -> String {
//        switch type {
//        case .sent: return "Sent"
//        case .received: return "Received"
//        case .denied: return "Denied"
//        }
//    }
//}
//
//struct TransactionItem: Identifiable {
//    let id: UUID
//    let type: TransactionType
//    let amount: String
//    let source: String
//    let date: String
//}
//
//enum TransactionType {
//    case sent
//    case received
//    case denied
//}
//
//
//
//
//
//
////
////
////struct EtherscanResponse: Codable {
////    let status: String
////    let message: String
////    let result: [EtherscanTransaction]
////}
////
////struct EtherscanTransaction: Codable, Identifiable {
////    var id: String { hash }
////    
////    let blockNumber: String
////    let timeStamp: String
////    let hash: String
////    let from: String
////    let to: String
////    let value: String
////    let isError: String
////    let gasUsed: String
////}
////
////
////func fetchTransactions(for address: String, apiKey: String, completion: @escaping ([EtherscanTransaction]) -> Void) {
////    let urlString = """
////    https://api-sepolia.etherscan.io/api?module=account&action=txlist&address=\(address)&startblock=0&endblock=99999999&page=1&offset=50&sort=desc&apikey=\(apiKey)
////    """
////    
////    guard let url = URL(string: urlString) else { return }
////    
////    URLSession.shared.dataTask(with: url) { data, response, error in
////        guard let data = data,
////              let decoded = try? JSONDecoder().decode(EtherscanResponse.self, from: data) else {
////            print("Failed to decode Etherscan response")
////            return
////        }
////        
////        DispatchQueue.main.async {
////            completion(decoded.result)
////        }
////    }.resume()
////}


import SwiftUI
import Charts
import Toast
import UIKit

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(EthereumWallet())
            .onAppear {
                UserDefaults.standard.set("0x1234567890abcdef1234567890abcdef12345678", forKey: "walletAddress")
            }
    }
}

struct TransactionItem: Identifiable {
    let id: UUID
    let type: TransactionType
    let amount: String
    let source: String
    let date: String
}

enum TransactionType: String, CaseIterable, Identifiable {
    case sent
    case received
    case denied

    var id: String { self.rawValue } // Conformance to Identifiable for ForEach in Picker
}

struct HomeView: View {
    
    private let url = "https://scontent.fdac138-2.fna.fbcdn.net/v/t39.30808-6/475995859_1154020176416021_1382538768621471338_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeFJLrlRY_Kx1uYSimzy2GK9FMWRBwz2XQ4UxZEHDPZdDo2OXAsy1lo2WOIvIS9hR5RxFODkGex-wLI2ceGsa21w&_nc_ohc=zyEHJqRp1gQQ7kNvwGRaKCq&_nc_oc=AdkXQtnN5cdoKC501Cz0vLPbejHO_BGi-40BWJC6t31rO8YqRh3VjEWIdvTXSbnB2CE&_nc_zt=23&_nc_ht=scontent.fdac138-2.fna&_nc_gid=gxlkAeEBl-fSMf7WnO-xLQ&oh=00_AfRfjQC48sbuVqe7Xd9j_1mqQBHkg9Lp5zZW0c0lIDq2TQ&oe=6882F1C1"
    
    @State var selectedList: String = "All"
    
    var lists = [
        "All",
        "Sent",
        "Received",
        "Denied"
    ]
    
    // Renamed to dummyTransactions
    var dummyTransactions: [TransactionItem] = [
        TransactionItem(id: UUID(), type: .received, amount: "0.0951", source: "Coinbase Wallet", date: "Jun 27, 2025"),
        TransactionItem(id: UUID(), type: .sent, amount: "0.050", source: "MetaMask", date: "Jun 26, 2025"),
        TransactionItem(id: UUID(), type: .received, amount: "0.1502", source: "Binance", date: "Jun 25, 2025"),
        TransactionItem(id: UUID(), type: .sent, amount: "0.0031", source: "Trust Wallet", date: "Jun 24, 2025"),
        TransactionItem(id: UUID(), type: .received, amount: "0.0281", source: "Coinbase Wallet", date: "Jun 23, 2025"),
        TransactionItem(id: UUID(), type: .sent, amount: "0.007", source: "MetaMask", date: "Jun 22, 2025"),
        TransactionItem(id: UUID(), type: .denied, amount: "0.0029", source: "Unknown", date: "Jun 21, 2025")
    ]
    
    @StateObject private var wallet = EthereumWallet()
        var combinedTransactions: [TransactionItem] {
        var allTx = dummyTransactions + wallet.fetchedTransactions
        allTx.sort { (item1, item2) -> Bool in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            guard let date1 = dateFormatter.date(from: item1.date),
                  let date2 = dateFormatter.date(from: item2.date) else {
                return false
            }
            return date1 > date2 // Sort descending by date (most recent first)
        }
        return allTx
    }

    var filteredTransactions: [TransactionItem] {
        switch selectedList {
        case "Sent":
            return combinedTransactions.filter { $0.type == .sent }
        case "Received":
            return combinedTransactions.filter { $0.type == .received }
        case "Denied":
            return combinedTransactions.filter { $0.type == .denied }
        default:
            return combinedTransactions
        }
    }
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                
                HomeTopView(url: url)
                    .padding(.top, 8)
                
                HomeBalanceView(wallet: wallet)
                
                HStack {
                    Text("Recent transactions")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    NavigationLink(
                        destination: AllTransactionsView(
                            allTransactions: combinedTransactions // Pass combined transactions
                        )
                    ) {
                        Image(systemName: "chevron.right")
                            .frame(height: 30)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                
                ListsCategoriesView(selectedList: $selectedList, lists: lists)
                    .padding(.bottom)
                
                
                VStack {
                    ForEach(filteredTransactions) { tx in
                        NavigationLink(
                            destination: TransactionInfoView(
                                transaction: tx
                            )
                        ) {
                            TransactionListItemView(transaction: tx)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                }
            }
            .refreshable {
                print("Refreshing balance and transactions...")
                Task {
                    await wallet.getBalance()
                    await wallet.fetchEtherscanTransactions()
                } // Fetch latest Etherscan transactions
            }
            .padding(.top, 40)
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground)).edgesIgnoringSafeArea(.all)
            // Removed redundant .padding and .navigationBarHidden here as they were duplicated
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Ensure data is fetched when the view first appears
            Task {
                await wallet.getBalance()
                await wallet.fetchEtherscanTransactions()
            }
        }
    }
}


struct TransactionDetailView: View {
    var transaction: TransactionItem
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(color(for: transaction.type).opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: icon(for: transaction.type))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(color(for: transaction.type))
            }
            Text(title(for: transaction.type))
                .font(.title).fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount: $\(transaction.amount)")
                Text("Source: \(transaction.source)")
                Text("Date: \(transaction.date)")
                Text("Transaction ID: \(transaction.id.uuidString)")
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Transaction Details")
    }
    
    private func icon(for type: TransactionType) -> String {
        switch type {
        case .sent: return "arrow.up.right"
        case .received: return "arrow.down.left"
        case .denied: return "nosign"
        }
    }
    
    private func color(for type: TransactionType) -> Color {
        switch type {
        case .sent: return .red
        case .received: return .green
        case .denied: return .orange
        }
    }
    
    private func title(for type: TransactionType) -> String {
        switch type {
        case .sent: return "Sent"
        case .received: return "Received"
        case .denied: return "Denied"
        }
    }
}


struct HomeTopView: View {
    let url: String
    @AppStorage("walletAddress") private var walletAddress: String = ""
    @State private var showReceiveSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 65, height: 65)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
            } placeholder: {
                Color.gray
                    .frame(width: 65, height: 65)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
            }

//            ZStack {
//                Circle()
//                    .fill(LinearGradient(
//                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    ))
//                    .frame(width: 65, height: 65)
//                
//                Text("A")
//                    .font(.system(size: 30, weight: .semibold))
//                    .foregroundColor(.white)
//            }
//            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(walletAddress)
                        .font(.custom(FontUtils.MAIN_BOLD, size: 16))
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .foregroundColor(.primary.opacity(0.8))
                        .frame(maxWidth: 160)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Receive")
                        .font(.custom(FontUtils.MAIN_REGULAR, size: 14))
                }
                .foregroundColor(.primary.opacity(0.8))
            }
            .onTapGesture {
                showReceiveSheet = true
            }
            .sheet(isPresented: $showReceiveSheet) {
                ReceiveTransactionView(myAddress: walletAddress)
                    .presentationDetents([.large])
            }
            
            Spacer()
            
            Button(action: {
                // Bell action
            }) {
                Image(systemName: "bell")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
            }
            .frame(width: 45, height: 45)
            .background(Color.white)
            .cornerRadius(30)
            .shadow(radius: 5)
        }
        .padding(20)
    }
}

struct HomeBalanceView: View {
    @ObservedObject var wallet: EthereumWallet
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text("Your Balance")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8)) // Changed to white for better contrast
                    .padding(.bottom, 2)
                
                Text("\(wallet.balance) ETH")
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(.white) // Changed to white for better contrast
            }
            .padding(.top, 20)
            .padding(.horizontal, 25)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Spacer()
                
                if let balance = Double(wallet.balance) {
                    Text(String(format: "$%.2f USD", balance * 3795.50))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.7)) // Adjusted for gradient
                        .padding(.bottom, 4)
                    
                    Text(String(format: "৳%.2f BDT", balance * 461_365.72)) // Corrected comma for large number literal
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.7)) // Adjusted for gradient
                        .padding(.bottom, 40)
                    
                } else {
                    Text("Invalid balance")
                        .font(.headline)
                        .foregroundColor(.white) // Keep visible on colorful background
                }
            }
            .padding(.trailing)
        }
        .frame(height: 170)
        // Colorful Gradient Background
        .background(
            RadialGradient(
                gradient: Gradient(colors: [Color("#7A17D7"), Color("#ED74CD"), Color("#EBB5A3")]),
                center: .topTrailing,
                startRadius: 100,
                endRadius: 800
            )
            .opacity(0.5)
        )
        .cornerRadius(15, corners: .allCorners)
        // Removed shadow, as the gradient itself provides a strong visual presence
        .padding(.horizontal, 20)
    }
}



struct ListsCategoriesView: View {
    
    @Binding var selectedList: String
    var lists: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(lists, id: \.self) { string in
                    Button(action: {
                        selectedList = string
                    }, label: {
                        HStack {
                            Image(systemName: iconName(for: string))
                                .font(.system(size: 12, weight: .bold))
                            Text(string)
                                .font(.custom(FontUtils.MAIN_BOLD, size: 12))
                        }
                        .foregroundColor(selectedList == string ? .white : .black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(selectedList == string ? Color.black : Color.white)
                        .cornerRadius(20)
                        .shadow(color: .gray.opacity(0.1), radius: 1, x: 0, y: 1)
                    })
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    func iconName(for list: String) -> String {
        switch list {
        case "Sent":
            return "arrow.up.right"
        case "Received":
            return "arrow.down.left"
        case "Denied":
            return "nosign"
        default:
            return "tray.full"
        }
    }
}

struct TransactionListItemView: View {
    var transaction: TransactionItem
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(transaction.type == .received ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: transaction.type == .received ? "arrow.down.left" : "arrow.up.right")
                    .foregroundColor(transaction.type == .received ? .green : .red)
                    .font(.system(size: 18, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.type == .received ? "Received" : "Sent")
                    .font(.custom(FontUtils.MAIN_BOLD, size: 16))
                    .foregroundColor(.black)
                
                Text("From: \(transaction.source)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.type == .received ? "+" : "-") \(transaction.amount) ETH")
                    .font(.custom(FontUtils.MAIN_BOLD, size: 16))
                    .foregroundColor(.black)
                
                Text(transaction.date)
                    .font(.custom(FontUtils.MAIN_REGULAR, size: 13))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.bottom, 8)
    }
}

struct AllTransactionsView: View {
    @State private var searchText: String = ""
    // Use TransactionType directly with Identifiable for cleaner picker
    @State private var selectedFilter: TransactionType? = nil
    var allTransactions: [TransactionItem] // Now accepts combined transactions
    
    var filtered: [TransactionItem] {
        allTransactions.filter { tx in
            // Filter by search text (e.g., hash) and selected filter type
            (searchText.isEmpty || tx.id.uuidString.localizedCaseInsensitiveContains(searchText) || tx.source.localizedCaseInsensitiveContains(searchText) || tx.amount.localizedCaseInsensitiveContains(searchText)) &&
            (selectedFilter == nil || tx.type == selectedFilter)
        }
    }
    
    var body: some View {
        VStack {
            TextField("Search by TX ID, Source or Amount", text: $searchText) // Updated search hint
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker("Filter", selection: $selectedFilter) {
                Text("All").tag(TransactionType?.none)
                ForEach(TransactionType.allCases) { type in // Use allCases
                    Text(type.rawValue.capitalized).tag(TransactionType?.some(type))
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            ScrollView {
                VStack {
                    ForEach(filtered) { tx in
                        NavigationLink(
                            destination: TransactionInfoView(
                                transaction: tx
                            )
                        ) {
                            TransactionListItemView(transaction: tx)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                }
            }
            .padding(.vertical)
            .background(Color(.systemGroupedBackground)).edgesIgnoringSafeArea(.all)
            
        }
        .navigationTitle("All Transactions")
    }
}

struct TransactionInfoView: View {
    var transaction: TransactionItem
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(color(for: transaction.type).opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: icon(for: transaction.type))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(color(for: transaction.type))
            }
            Text(title(for: transaction.type))
                .font(.title).fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount: $\(transaction.amount)")
                Text("Source: \(transaction.source)")
                Text("Date: \(transaction.date)")
                Text("Transaction ID: \(transaction.id.uuidString)")
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Transaction Details")
    }
    
    private func icon(for type: TransactionType) -> String {
        switch type {
        case .sent: return "arrow.up.right"
        case .received: return "arrow.down.left"
        case .denied: return "nosign"
        }
    }
    
    private func color(for type: TransactionType) -> Color {
        switch type {
        case .sent: return .red
        case .received: return .green
        case .denied: return .orange
        }
    }
    
    private func title(for type: TransactionType) -> String {
        switch type {
        case .sent: return "Sent"
        case .received: return "Received"
        case .denied: return "Denied"
        }
    }
}
