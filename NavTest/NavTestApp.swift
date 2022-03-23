import SwiftUI

@main
struct NavTestApp: App {
    
    @ObservedObject var navModel = NavModel()
    
    init() {
        navModel.a = A(navModel: navModel)
        navModel.b = B(navModel: navModel)
        navModel.c = C(navModel: navModel)
        
        // example to select button 4 on view A
        /*
        let navTo = [
            NavTo(view: navModel.a!, id: 4)
        ]
         */
        
        // example to descend to view C
        let navTo = [
            NavTo(view: navModel.a!, subId: 1),
            NavTo(view: navModel.b!, subId: 1)
        ]
         
        navModel.navTo = navTo
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WrappedA(navModel: navModel, toSelect: 3)
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

