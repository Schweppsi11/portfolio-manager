import SwiftUI

enum ContentTab: String, Hashable {
    case home, portfolio, stocks, settings
}

struct YWMainScreen: View {
    @AppStorage("tab") var tab = ContentTab.home
    @AppStorage("appearance") var appearance = ""
    @State var viewModel = ViewModel()

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                ItemListView()
                    .navigationTitle(Text("\(viewModel.items.count) Items"))
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(ContentTab.home)

            NavigationStack {
                let assets: Array<YWAsset> = [YWAsset(ticker: "AAPL", name: "Apple", value: 325.00, oldValue: 300),
                                            YWAsset(ticker: "MSFT", name: "Microsoft", value: 541.00, oldValue: 643.00),
                                            YWAsset(ticker: "DNG", name: "Dynacor Mining", value:954.30, oldValue: 899.00)]
                let portfolio = YWPortfolio(name: "MyPortfolio", assets: assets)
                YWPortfolioView(portfolio: portfolio)
                    .navigationTitle("Portfolio")
            }
            .tabItem { Label("Portfolio", systemImage: "briefcase.fill") }
            .tag(ContentTab.portfolio)
            
            NavigationStack {
                Text("Stocks")
            }
            .tabItem { Label("Stocks", systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90") }
            .tag(ContentTab.stocks)
            
            NavigationStack {
                SettingsView(appearance: $appearance)
                    .navigationTitle("Settings")
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            .tag(ContentTab.settings)
        }
        .environment(viewModel)
        .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
    }
}

struct ItemListView : View {
    @Environment(ViewModel.self) var viewModel: ViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                NavigationLink(value: item) {
                    Label {
                        Text(item.itemTitle)
                    } icon: {
                        if item.favorite {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
            .onDelete { offsets in
                viewModel.items.remove(atOffsets: offsets)
            }
            .onMove { fromOffsets, toOffset in
                viewModel.items.move(fromOffsets: fromOffsets, toOffset: toOffset)
            }
        }
        .navigationDestination(for: Item.self) { item in
            ItemView(item: item)
                .navigationTitle(item.itemTitle)
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    withAnimation {
                        viewModel.items.insert(Item(), at: 0)
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
    }
}

struct ItemView : View {
    @State var item: Item
    @Environment(ViewModel.self) var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            TextField("Title", text: $item.title)
                .textFieldStyle(.roundedBorder)
            Toggle("Favorite", isOn: $item.favorite)
            DatePicker("Date", selection: $item.date)
            Text("Notes").font(.title3)
            TextEditor(text: $item.notes)
                .border(Color.secondary, width: 1.0)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.save(item: item)
                    dismiss()
                }
                .disabled(!viewModel.isUpdated(item))
            }
        }
    }
}

struct SettingsView : View {
    @Binding var appearance: String

    var body: some View {
        Form {
            Picker("Appearance", selection: $appearance) {
                Text("System").tag("")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                Text("Version \(version) (\(buildNumber))")
            }
            HStack {
                PlatformHeartView()
                Text("Powered by [Skip](https://skip.tools)")
            }
        }
    }
}

/// A view that shows a blue heart on iOS and a green heart on Android.
struct PlatformHeartView : View {
    var body: some View {
       #if SKIP
       ComposeView { ctx in // Mix in Compose code!
           androidx.compose.material3.Text("💚", modifier: ctx.modifier)
       }
       #else
       Text(verbatim: "💙")
       #endif
    }
}
