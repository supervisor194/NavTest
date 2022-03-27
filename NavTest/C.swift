import SwiftUI

class CViewModel : ObservableObject, NavViewModel {
    var name: String = "CViewModel"
    let uuid: UUID = UUID.init()
    @Published var selected: [String: Int?] = [:]
    var isVisible: Bool = false
    var navModel: NavModel

    init(navModel: NavModel) {
        self.navModel = navModel
    }
    
}

struct WrappedC : View {
    @Environment(\.dismiss) var _dismiss

    @ObservedObject var navModel: NavModel
    @ObservedObject var vModel : CViewModel
    let c: C
    let toSelect: KeyedId
    
    init(navModel: NavModel, toSelect: KeyedId) {
        c = navModel.c!
        vModel = c.vModel
        self.navModel = navModel
        self.toSelect = toSelect
    }
    
    var body: some View {
        c
            .onAppear {
                vModel.doOnAppear(currentView: c, dismiss: _dismiss, toSelect: toSelect)
            }
            .onDisappear {
                vModel.doOnDisappear(toNil: toSelect)
            }
    }
}


struct C: View, NavView {
    @Environment(\.dismiss) var _dismiss
    
    @ObservedObject var vModel : CViewModel
    
    var viewModel: NavViewModel {
        get {
            vModel
        }
    }

    init(navModel: NavModel) {
        self.vModel = CViewModel(navModel: navModel)
    }


    var body: some View {
        VStack {
            Text("Welcome to C")
            
            Text( vModel.selected["C"] == nil ? "none" : String(vModel.selected["C"]!!))
            
            Button(action: {
                let navModel = vModel.navModel
                navModel.navTo = NavTo(upTo: navModel.a, downTo: [ DownTo(view: navModel.a!,ids: [KeyedId(key: "B", id: 1)])]
                                                                    )
                navModel.dismiss(vModel.uuid)
                _dismiss()
            }) {
                Label("BackToA, DownToB", systemImage: "arrow.left")
            }
        }
        .onAppear {
            print("C internal onAppear()")
        }
        .onDisappear {
            print("C internal onDisappear()")
        }
    }
}


