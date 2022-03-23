
import SwiftUI

class AViewModel : ObservableObject, NavViewModel {
    
    var name: String = "AViewModel"
    
    @Published var selected: Int?
    
    @Published var subSelected: Int?
    
    var isVisible: Bool = false
    
}

struct WrappedA : View {
    
    @ObservedObject var navModel: NavModel
    @ObservedObject var vModel : AViewModel
    let a: A
    let toSelect: Int
    
    init(navModel: NavModel, toSelect: Int) {
        a = navModel.a!
        vModel = a.vModel
        self.navModel = navModel
        self.toSelect = toSelect
    }
    
    var body: some View {
        a
            .onAppear {
                vModel.selected = toSelect
            }
            .onDisappear {
                vModel.selected = nil
            }
    }
}

struct A: View, NavView {
    
    @ObservedObject var navModel: NavModel
    
    var navigationModel: NavModel {
        get {
            navModel
        }
    }
    
    @ObservedObject var vModel: AViewModel
    
    var viewModel: NavViewModel {
        get {
            vModel
        }
    }
    
    init(navModel: NavModel) {
        self.navModel = navModel
        self.vModel = AViewModel()
    }
    
    var body: some View {
        VStack {
            Text("On view A")
            NavigationLink(destination: WrappedB(navModel: navModel, toSelect: 1), tag: 1, selection: $vModel.subSelected) {
                Text("to B")
            }
            NavigationLink(destination: WrappedC(navModel: navModel, toSelect: 1), tag: 2, selection: $vModel.subSelected) {
                Text("to C")
            }
            HStack {
                ForEach( (1...5), id: \.self) { i in
                    Button(action: {
                        vModel.selected = i
                    }) {
                        Image(systemName: "circle.fill")
                            .font(.largeTitle)
                            .foregroundColor( vModel.selected == i ? .blue : .white)
                            .overlay(
                                Text(String(i))
                                    .foregroundColor( vModel.selected == i ? .white : .blue))
                    }
                }
            }
        }
        .onAppear {
            vModel.isVisible = true
        }
        .onDisappear {
            vModel.isVisible = false 
        }
        .navigationBarTitle("A")
        .navigationBarTitleDisplayMode(.inline)
    }
}
