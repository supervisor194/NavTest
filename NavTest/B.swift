
import SwiftUI

class BViewModel : ObservableObject, NavViewModel {
    var name: String = "BViewModel"
    @Published var selected: Int?
    @Published var subSelected: Int?
    var isVisible: Bool = false
}

struct WrappedB: View {
    @ObservedObject var navModel: NavModel
    @ObservedObject var vModel : BViewModel
    let b: B
    let toSelect: Int
    
    init(navModel: NavModel, toSelect: Int) {
        b = navModel.b!
        vModel = b.vModel
        self.navModel = navModel
        self.toSelect = toSelect
    }
    
    var body: some View {
        b
            .onAppear {
                vModel.selected = toSelect
            }
            .onDisappear {
                vModel.selected = nil 
            }
    }
}

struct B: View, NavView {
    
    @ObservedObject var navModel: NavModel
    
    var navigationModel: NavModel {
        get {
            navModel
        }
    }
    
    @ObservedObject var vModel: BViewModel
    
    var viewModel : NavViewModel {
        get {
            vModel
        }
    }
    
    init(navModel: NavModel) {
        self.navModel = navModel
        self.vModel = BViewModel()
    }
    
    var body: some View {
        VStack {
            Text("Welcome to B")
            NavigationLink(destination: WrappedC(navModel: navModel, toSelect: 1), tag: 1, selection: $vModel.subSelected) {
                Text("go to C")
            }
        }
        .onAppear {
            vModel.isVisible = true
        }
        .onDisappear {
            vModel.isVisible = false
        }
        .navigationBarTitle("B")
        .navigationBarTitleDisplayMode(.inline)
    }
}
