# NavTest
SwiftUI example of programmatic navigable views for NavigationView hierarchies 

This example takes 3 View structs, A,B and C that want to live in a stack navigation view hierarchy.  Sometimes
we may want to pop the initial view open to the 3rd View C, while maintaining the nice navigation that the
stack navigation view provides, the back buttons and forward navigation.  The following code has A,B and C 
conform to a few protocols and adds them to a containing model called the <code>class NavModel: ObservableObject</code>.
Additonally, the A,B and C are 'wrapped' by 3 separate View structs to maintain some additional state about what
has appeared or disappeared.  While not strictly needed to get programmatic navigation working, these wrappers 
can be helpful in more complex situations where one does not want to instantiate the underlying A,B and C multiple
times.  One can remove the <code>Wrapped(A|B|C)</code> and push the onAppear/onDisappear elsewhere.  The Wrappers
have proven to be useful in other situations and so I've kept them here. 

Two protocols <code>NavView</code> and <code>NavViewModel</code> along with an <code>class NavModel: ObservableObject</code> 
offer a simple structure for building SwiftUI View hierarchies that utilize 
the <code>NavigationView</code> along with a <code>.navigationViewStyle(StackNavigationViewStyle())</code>. 
The <code>NavModel</code> knows about the optional Views for the hierarchy.  Generally, we want to lay
the Views out in a well known fashion, A before B before C or some such.  These may also be optional. Perhaps
A, B and C represent some SwiftUI package with reusable views.  There may be occassions for configuring them
into various hiearchies, like A, C  or  B, C  or just B or just C.   

```
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

class NavModel : ObservableObject {
    
    var a: A?
    var b: B?
    var c: C?
    ...
}
```

The <code>NavModel</code> is asked to consume a <code>[NavTo]?</code> upon appearing in order to execute the
programmatic navigation async fashion.
```
.onAppear {
      Task.detached {
           await navModel.navigateOnAppear()
      }
}
```
The <code>NavViewModel</code> in this example supports a single select key, <code>var selected: Int?</code> per View 
and a single sub selection, <code>var subSelected: Int?</code> for triggering <code>NavigationLink</code> instances 
that will match on some <code>tag</code>.  One can make more complex selection mechanisms.  Often these 
two work for many situations, but extend as necessary.  The per View <code>selected</code> could be used 
to select a list item or as in this example, a button.  The <code>subSelected</code> is really where the 
navigation between Views takes place.  One could have multiple subSelected to match tags as needed: subSelected1,
subSelectedX, etc.
``` 
NavigationLink(destination: WrappedB(navModel: navModel, toSelect: 1), tag: 1, selection: $vModel.subSelected) {
                Text("Let's go to B")
}
```

An iOS App, <code>NavTestApp</code> ties things together for this example by setting up 3 Views, A,B and C and
programmatically navigating to C upon open, while preserving all the back buttons and hierarchy for stack navigation.
The navigation is guided by the <code>[NavTo]</code>:
```
let navTo = [
            NavTo(view: navModel.a!, subId: 1),
            NavTo(view: navModel.b!, subId: 1)
]
```
