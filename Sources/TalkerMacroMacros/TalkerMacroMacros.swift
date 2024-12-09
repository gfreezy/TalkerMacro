import SwiftCompilerPlugin
import Foundation
import SwiftSyntaxMacros


struct MacroError: LocalizedError {
    var errorDescription: String?
}

@main
struct TalkerMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DictParamOverloadMacro.self,
        RouteViewsMacro.self
    ]
}
