import Foundation
import SwiftUI


protocol NavView {
    var viewModel: NavViewModel { get }
}

func same(_ lhs: NavView, _ rhs: NavView) -> Bool {
    lhs.viewModel.uuid == rhs.viewModel.uuid
}

protocol NavViewModel : AnyObject {
    var name: String { get }
    var uuid: UUID { get }
    var selected: [String:Int?] { get set }
    var isVisible: Bool { get set }
    var navModel: NavModel { get }
    func doOnAppear(currentView: NavView, dismiss: DismissAction, toSelect: KeyedId?)
    func doOnDisappear(toNil: KeyedId?)
}

extension NavViewModel {
    
    func doOnAppear(currentView: NavView, dismiss: DismissAction, toSelect: KeyedId?) {
        isVisible = true
        if let nnavto = navModel.navTo {
            if let upTo = nnavto.upTo {
                if same(upTo, currentView) {
                    navModel.navTo!.upTo = nil
                } else {
                    navModel.dismiss(uuid)
                    dismiss()
                    return
                }
            }
            if nnavto.downTo != nil {
                Task.detached {
                    await self.navModel.navigateOnAppear()
                }
                return
            }
        }
        if let toSelect = toSelect {
            selected[toSelect.key] = toSelect.id
        }
    }
}

extension NavViewModel {
    
    func doOnDisappear(toNil: KeyedId?) {
        navModel.onDisappear(uuid)
        isVisible = false
        
        if let toNil = toNil {
            selected[toNil.key] = nil
        }
    }
    
}

struct KeyedId {
    var key: String
    var id: Int?
}

struct DownTo {
    var view: NavView
    var ids: [KeyedId]
}

struct NavTo {
    var upTo: NavView?
    var downTo: [DownTo]?
    
    mutating func removeFirst() {
        if downTo != nil {
            self.downTo!.remove(at: 0)
            if self.downTo?.count == 0 {
                self.downTo = nil
            }
        }
    }
}

class NavModel : ObservableObject {

    var a: A?
    var b: B?
    var c: C?
    
    var navTo: NavTo? = nil
           
    var dismissed: [UUID: Int] = [:]
    
    init() {
    }
    
    func dismiss(_ uuid: UUID) {
        dismissed[uuid, default: 0] += 1
    }
    
    func onDisappear(_ uuid: UUID) {
        if let c = dismissed[uuid] {
            if c == 1 {
                dismissed.removeValue(forKey: uuid)
            } else {
                dismissed[uuid]! -= 1
            }
        }
    }
        
    
    @MainActor
    func doSelects(viewModel: inout NavViewModel, ids: [KeyedId]) async {
        for id in ids {
            viewModel.selected[id.key] = id.id
        }
    }
    
    @MainActor
    func navigateOnAppear() async {
        guard let navTo = navTo else {
            return
        }
        
        while dismissed.count > 0 {
            try? await Task.sleep(nanoseconds: UInt64(1e9*1.0/20.0))
        }
        
        if let downTo = navTo.downTo {
            for nt in downTo {
                var viewModel = nt.view.viewModel
                while !viewModel.isVisible {
                    try? await Task.sleep(nanoseconds: UInt64(1e9*1.0/10.0))
                }
                await doSelects(viewModel: &viewModel, ids: nt.ids)
            }
        }
        
        self.navTo = nil
    }

}
