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
    var subSelect: [String:Int?] { get set}
    var isVisible: Bool { get set }
    var navModel: NavModel { get }
    func doOnAppear(currentView: NavView, dismiss: DismissAction, toSelect: KeyedId?)
    func doOnDisappear(toNil: KeyedId?)
}

extension NavViewModel {
    
    func doOnAppear(currentView: NavView, dismiss: DismissAction, toSelect: KeyedId?) {
        isVisible = true
        if let nnavto = navModel.nnavTo {
            if let upTo = nnavto.upTo {
                if same(upTo, currentView) {
                    navModel.nnavTo!.upTo = nil
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
    var id: KeyedId?
    var subId: KeyedId?
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
    
    var nnavTo: NavTo? = nil
           
    var dismissed: [UUID: Int] = [:]
    
    init() {
    }
    
    func dismiss(_ uuid: UUID) {
        dismissed[uuid, default: 0] += 1
        // _dismiss()
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
    func doSelects(viewModel: inout NavViewModel, id: KeyedId?, subId: KeyedId?) async {
        if let id = id {
            viewModel.selected[id.key] = id.id
        }

        if let subId = subId {
            viewModel.subSelect[subId.key] = subId.id
        }
        
    }
    
    @MainActor
    func navigateOnAppear() async {
        if nnavTo == nil {
            return
        }
        
        while dismissed.count > 0 {
            try? await Task.sleep(nanoseconds: UInt64(1e9*1.0/20.0))
        }
        
        while nnavTo!.downTo != nil  {
            let nt = nnavTo!.downTo!.first!
            var viewModel = nt.view.viewModel
            // print("looking for : \(viewModel.name)")
            while !viewModel.isVisible {
                try? await Task.sleep(nanoseconds: UInt64(1e9*1.0/10.0))
            }
            // print("\(viewModel.name) is visible")
            await doSelects(viewModel: &viewModel, id: nt.id, subId: nt.subId)
            nnavTo!.removeFirst()
        }
       
    }

}
