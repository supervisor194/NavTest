import SwiftUI

@main
struct NavTestApp: App {
    
    @ObservedObject var navModel = NavModel()
    
    init() {
        navModel.a = A(navModel: navModel)
        navModel.b = B(navModel: navModel)
        navModel.c = C(navModel: navModel)
        
        // to select button 4 on view A
        let navTo = NavTo(downTo: [
            DownTo(view: navModel.a!, ids: [KeyedId(key: "buttons", id: 4)])
        ])
        
        
        // descend to B then C
        let navTo2 = NavTo(downTo: [
            DownTo(view: navModel.a!, ids: [KeyedId(key: "B", id: 1)]),
            DownTo(view: navModel.b!, ids: [KeyedId(key: "C", id: 1)]),
            DownTo(view: navModel.c!, ids: [KeyedId(key: "C", id: 7)])
        ])
        
        navModel.navTo = navTo2
         
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WrappedA(navModel: navModel, toSelect: KeyedId(key: "only", id: 3))
            }
            .onAppear {
                Task.detached {
                    await navModel.navigateOnAppear()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())

        }
    }
}

