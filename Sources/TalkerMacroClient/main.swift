import TalkerMacro
import Foundation
import SwiftUI
import OSLog

struct A: View {
    @Routable("/path/a")
    init(a: String, b: Int, c: Float, d: String?) {
        fatalError()
    }
    
    var body: some View {
        Text("hell")
    }
}

struct C: View {
    @Routable("/path/a")
    @MainActor init(a: String, b: Int, c: Float = 0, d: String? = nil) {
        fatalError()
    }
    
    
    var body: some View {
        Text("hell")
    }
}


struct B {
    @MainActor
    #routeViews(A, C)
}
