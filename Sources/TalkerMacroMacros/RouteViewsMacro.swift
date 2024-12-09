import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros



public struct RouteViewsMacro: DeclarationMacro {
    public static func expansion(
      of node: some FreestandingMacroExpansionSyntax,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let views = node.arguments
            .compactMap({ expr in
                expr.expression.as(DeclReferenceExprSyntax.self)?.trimmedDescription
            })
            .map { ty in
                """
                case \(ty).path:
                    \(ty)(query)
                """
            }
    
        guard !views.isEmpty else {
            throw MacroError(errorDescription: "No valid types")
        }
        
        let decl = """
        @ViewBuilder
        func view(_ path: String, query: [String: String]) -> some View {
            switch path {
            \(views.joined())
            default:
                Text("Not found: \\(path), \\(query). Did you forget to register the View.")
            }
        }
        """
        return [DeclSyntax(stringLiteral: decl)]
    }
}
