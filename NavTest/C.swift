
import SwiftUI

class CViewModel : ObservableObject, NavViewModel {
    var name: String = "CViewModel"
    @Published var selected: Int?
    @Published var subSelected: Int?
    var isVisible: Bool = false
}

struct WrappedC : View {
    @ObservedObject var navModel: NavModel
    @ObservedObject var vModel : CViewModel
    let c: C
    let toSelect: Int
    
    init(navModel: NavModel, toSelect: Int) {
        c = navModel.c!
        vModel = c.vModel
        self.navModel = navModel
        self.toSelect = toSelect
    }
    
    var body: some View {
        c
            .onAppear {
                vModel.selected = toSelect
            }
            .onDisappear {
                vModel.selected = nil
            }
    }
}


struct C: View, NavView {
    @ObservedObject var navModel : NavModel
    
    var navigationModel: NavModel {
        get {
            navModel
        }
    }
    
    @ObservedObject var vModel : CViewModel
    
    var viewModel: NavViewModel {
        get {
            vModel
        }
    }

    init(navModel: NavModel) {
        self.navModel = navModel
        self.vModel = CViewModel()
    }
    
    var body: some View {
        VStack {
            Text("Welcome to C")
        }
    }
}


