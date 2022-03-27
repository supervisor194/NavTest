import SwiftUI

class BViewModel : ObservableObject, NavViewModel {
    var name: String = "BViewModel"
    let uuid: UUID = UUID.init()
    @Published var selected: [String : Int?] = [:]
    var isVisible: Bool = false
    var navModel: NavModel
    
    init(navModel: NavModel) {
        self.navModel = navModel
    }
}

struct WrappedB: View {
    @Environment(\.dismiss) var _dismiss
    
    @ObservedObject var navModel: NavModel
    @ObservedObject var vModel : BViewModel
    let b: B
    let toSelect: KeyedId
    
    init(navModel: NavModel, toSelect: KeyedId) {
        b = navModel.b!
        vModel = b.vModel
        self.navModel = navModel
        self.toSelect = toSelect
    }
    
    var body: some View {
        b
            .onAppear {
                vModel.doOnAppear(currentView: b, dismiss: _dismiss, toSelect: toSelect)
            }
            .onDisappear {
                vModel.doOnDisappear(toNil: toSelect)
            }
    }
}

struct B: View, NavView {
    @ObservedObject var vModel: BViewModel
    
    var viewModel : NavViewModel {
        get {
            vModel
        }
    }
    
    init(navModel: NavModel) {
        self.vModel = BViewModel(navModel: navModel)
    }
    
    var body: some View {
        VStack {
            Text("Welcome to B")
            NavigationLink(destination: WrappedC(navModel: vModel.navModel, toSelect: KeyedId(key: "only", id: 1)), tag: 1, selection: $vModel.selected["foo"]) {
                Text("go to C")
            }
        }
        .onAppear {
            print("B internal onAppear()")
        }
        .onDisappear {
            print("B internal onDisappear()")
        }
        .navigationBarTitle("B")
        .navigationBarTitleDisplayMode(.inline)
    }
}
