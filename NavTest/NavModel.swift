import Foundation
import SwiftUI

protocol NavView {
    var navigationModel: NavModel { get }
    var viewModel: NavViewModel { get }
}

protocol NavViewModel {
    var name: String { get }
    var selected: Int? { get set }
    var subSelected: Int? { get set }
    var isVisible: Bool { get set }
}

struct NavTo {
    var view: NavView
    var id: Int?
    var subId: Int?
}

class NavModel : ObservableObject {
    
    var a: A?
    var b: B?
    var c: C?
    
    var navTo: [NavTo]? = nil
   
    init() {
    }
    
    @MainActor
    func doSelects(viewModel: inout NavViewModel, id: Int?, subId: Int?) async {
        if let id = id {
            viewModel.selected = id
        }
        if let subId = subId {
            viewModel.subSelected = subId
        }
    }
    
    func navigateOnAppear() async {
        if navTo == nil {
            return
        }
        while navTo!.count > 0 {
            let nt = navTo!.first!
            var viewModel = nt.view.viewModel
            while !viewModel.isVisible {
                try? await Task.sleep(nanoseconds: UInt64(1e9*1.0/10.0))
            }
            await doSelects(viewModel: &viewModel, id: nt.id, subId: nt.subId)
            navTo!.remove(at: 0)
        }
       
    }

}
