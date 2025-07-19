import SwiftUI
import Charts
import Toast
import UIKit

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


struct HomeView: View {
    
    private let url = "https://pyxis.nymag.com/v1/imgs/654/1f1/08de774c11d89cb3f4ecf600a33e9c8283-24-keanu-reeves.rsquare.w700.jpg"
    
    @State var selectedList: String = "All"
    
    var lists = [
        "All",
        "Sent",
        "Received",
        "Denied"
    ]
    
    var transactions: [TransactionItem] = [
        TransactionItem(id: UUID(), type: .received, amount: "1,250", source: "Coinbase Wallet", date: "Jun 27, 2025"),
        TransactionItem(id: UUID(), type: .sent, amount: "890", source: "MetaMask", date: "Jun 26, 2025"),
        TransactionItem(id: UUID(), type: .received, amount: "2,100", source: "Binance", date: "Jun 25, 2025"),
        TransactionItem(id: UUID(), type: .sent, amount: "450", source: "Trust Wallet", date: "Jun 24, 2025"),
        TransactionItem(id: UUID(), type: .received, amount: "750", source: "Coinbase Wallet", date: "Jun 23, 2025"),
        TransactionItem(id: UUID(), type: .sent, amount: "320", source: "MetaMask", date: "Jun 22, 2025"),
        TransactionItem(id: UUID(), type: .denied, amount: "100", source: "Unknown", date: "Jun 21, 2025")
    ]
    
    var filteredTransactions: [TransactionItem] {
        switch selectedList {
        case "Sent":
            return transactions.filter { $0.type == .sent }
        case "Received":
            return transactions.filter { $0.type == .received }
        case "Denied":
            return transactions.filter { $0.type == .denied }
        default:
            return transactions
        }
    }
    
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                
                HomeTopView(url: url)
                    .padding(.top, 8)
                
                HomeBalanceView()
                
                HStack {
                    Text("Recent transactions")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    NavigationLink(
                        destination: AllTransactionsView(
                            allTransactions: transactions
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
            .padding(.top, 40)
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground)).edgesIgnoringSafeArea(.all)
        }
    }
}

struct HomeTopView: View {
    let url: String
    private let walletAddress = "0x2D3b3A14c7ff8156dF61c85b77392291c0747e87"
    @State private var showReceiveSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            AsyncImage(url: URL(string: url)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 65, height: 65)
            .clipShape(RoundedRectangle(cornerRadius: 40))
            
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
    @StateObject private var wallet = EthereumWallet()
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                VStack (alignment: .leading) {
                    Text("Your Balance")
                        .font(.custom(FontUtils.MAIN_REGULAR, size: 18)).foregroundColor(.gray)
                        .padding(.bottom, 2)
                    
                    Text("\(wallet.balance) ETH")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary.opacity(0.8))
                    
                    if let balance = Double(wallet.balance) {
                        Text(String(format: "$%.2f USD", balance * 3489.59))
                            .font(.headline)
                            .foregroundColor(.black)
                    } else {
                        Text("Invalid balance")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    
                    
                }
                
                Spacer()
                
                
            }
            .padding(.top, 20)
            .padding(.horizontal, 25)
            
            Spacer()
            
            HStack {
                Chart {
                    ForEach(0..<7, id: \.self) { item in
                        LineMark(
                            x: .value("x", item),
                            y: .value("y", Int.random(in: 0...7))
                        )
                        .lineStyle(.init(lineWidth: 3))
                        .foregroundStyle(.green)
                        
                    }
                }
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
                
            }
            .padding(.top, 10)
            .padding(.horizontal, 25)
            .padding(.bottom, 20)
            
        }
        .frame(height: 170)
        .background(.white)
        .cornerRadius(15, corners: .allCorners)
        .shadow(radius: 4)
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
                    .font(.custom(FontUtils.MAIN_REGULAR, size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.type == .received ? "+" : "-")$\(transaction.amount)")
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
    @State private var selectedFilter: TransactionType? = nil
    var allTransactions: [TransactionItem]
    
    var filtered: [TransactionItem] {
        allTransactions.filter { tx in
            (searchText.isEmpty || tx.id.uuidString.localizedCaseInsensitiveContains(searchText)) &&
            (selectedFilter == nil || tx.type == selectedFilter)
        }
    }
    
    var body: some View {
        VStack {
            TextField("Search by TX ID", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker("Filter", selection: $selectedFilter) {
                Text("All").tag(TransactionType?.none)
                Text("Sent").tag(TransactionType?.some(.sent))
                Text("Received").tag(TransactionType?.some(.received))
                Text("Denied").tag(TransactionType?.some(.denied))
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

// MARK: - Transaction Detail Screen
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

struct TransactionItem: Identifiable {
    let id: UUID
    let type: TransactionType
    let amount: String
    let source: String
    let date: String
}

enum TransactionType {
    case sent
    case received
    case denied
}
