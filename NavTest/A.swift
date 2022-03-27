import SwiftUI

class AViewModel : ObservableObject, NavViewModel {
    var name: String = "AViewModel"
    let uuid: UUID = UUID.init()
    @Published var selected: [String: Int?] = [:]
    var isVisible: Bool = false
    var navModel: NavModel
    
    init(navModel: NavModel) {
        self.navModel = navModel
    }
}

struct WrappedA : View {
    @Environment(\.dismiss) var _dismiss
    
    @ObservedObject var navModel: NavModel
    @ObservedObject var vModel : AViewModel
    let a: A
    let toSelect: KeyedId
    
    init(navModel: NavModel, toSelect: KeyedId) {
        a = navModel.a!
        vModel = a.vModel
        self.navModel = navModel
        self.toSelect = toSelect
    }
    
    var body: some View {
        a
            .onAppear {
                vModel.doOnAppear(currentView: a, dismiss: _dismiss, toSelect: toSelect)
            }
            .onDisappear {
                vModel.doOnDisappear(toNil: toSelect)
            }
    }
}

struct A: View, NavView {
    @ObservedObject var vModel: AViewModel
    
    var viewModel: NavViewModel {
        get {
            vModel
        }
    }
    
    init(navModel: NavModel) {
        self.vModel = AViewModel(navModel: navModel)
    }
    
    var body: some View {
        VStack {
            Text("On view A")
            NavigationLink(destination: WrappedB(navModel: vModel.navModel, toSelect: KeyedId(key: "only", id: 1)), tag: 1, selection: $vModel.selected["foo"]) {
                Text("to B")
            }
            NavigationLink(destination: WrappedC(navModel: vModel.navModel, toSelect: KeyedId(key: "only", id: 1)), tag: 2, selection: $vModel.selected["C"]) {
                Text("to C")
            }
            HStack {
                ForEach( (1...5), id: \.self) { i in
                    Button(action: {
                        vModel.selected["only"] = i
                    }) {
                        Image(systemName: "circle.fill")
                            .font(.largeTitle)
                            .foregroundColor( vModel.selected["only"] == i ? .blue : .white)
                            .overlay(
                                Text(String(i))
                                    .foregroundColor( vModel.selected["only"] == i ? .white : .blue))
                    }
                }
            }
        }
        .onAppear {
            print("A internal onAppear()")
        }
        .onDisappear {
            print("A internal onDisappear()")
        }
        .navigationBarTitle("A")
        .navigationBarTitleDisplayMode(.inline)
    }
}
