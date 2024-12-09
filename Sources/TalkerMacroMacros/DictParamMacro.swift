import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import OSLog


public struct DictParamOverloadMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let path = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue else {
            throw MacroError(errorDescription: "Path must be string")
        }
        let functionName: String
        let signature: FunctionSignatureSyntax
        let visibility: String
        let attributes: String
        if let functionDecl = declaration.as(InitializerDeclSyntax.self) {
            functionName = "init"
            signature = functionDecl.signature
            visibility = functionDecl.modifiers.description
            attributes = functionDecl.attributes.filter({ attr in
                return attr.trimmedDescription != node.trimmedDescription
            }).trimmedDescription
        } else {
            throw MacroError(errorDescription: "macro must be used on init")
        }
        
        let parameterList = signature.parameterClause.parameters
        let earlyReturnStmt = """
            os_log("Navigate to route `\(path)` error, return early.")
            return nil
            """
        
        var assignments: [String] = []
        var buildAssignments: [String] = []
        var methodArguments = [String]()
        var paramDeclList = [String]()
        for parameter in parameterList {
            let paramName = parameter.firstName.text
            let paramType = parameter.type.trimmedDescription
            let isParamOptionalType = parameter.type.as(OptionalTypeSyntax.self) != nil
            let defaultValue = parameter.defaultValue?.value.trimmedDescription

            let assignment: String
            switch (paramType, defaultValue) {
            case ("String", let defaultValue?):
                assignment = """
                let __\(paramName) = data[\"\(paramName)\"] ?? \(defaultValue)
                """
            case ("String?", let defaultValue?):
                assignment = """
                let __\(paramName) = data[\"\(paramName)\"] ?? \(defaultValue)
                """
            case ("String", nil):
                assignment = """
                let __\(paramName) = data[\"\(paramName)\"]
                guard let __\(paramName) else {
                    \(earlyReturnStmt)
                }
                """
            case ("String?", nil):
                assignment = """
                let __\(paramName) = data[\"\(paramName)\"]
                """
            case (_, let defaultValue?) where !isParamOptionalType:
                assignment =
                """
                let __\(paramName)_val = data["\(paramName)"]?.data(using: String.Encoding.utf8)
                let __\(paramName): \(paramType) = if let __\(paramName)_val {
                    (try? JSONDecoder().decode(\(paramType).self, from: __\(paramName)_val)) ?? \(defaultValue)
                } else {
                    \(defaultValue)
                }
                """
            case (_, let defaultValue?) where isParamOptionalType:
                assignment =
                """
                let __\(paramName)_val = data["\(paramName)"]?.data(using: String.Encoding.utf8)
                let __\(paramName): \(paramType) = if let __\(paramName)_val {
                    (try? JSONDecoder().decode(\(paramType).self, from: __\(paramName)_val)) ?? \(defaultValue)
                } else {
                    \(defaultValue)
                }
                """
            case (_, nil) where !isParamOptionalType:
                assignment =
                """
                guard let __\(paramName)_val = data["\(paramName)"]?.data(using: String.Encoding.utf8) else {
                    \(earlyReturnStmt)
                }
                let __\(paramName) = try? JSONDecoder().decode(\(paramType).self, from: __\(paramName)_val)
                guard let __\(paramName) else {
                    \(earlyReturnStmt)
                }
                """
            case (_, nil) where isParamOptionalType:
                assignment =
                """
                let __\(paramName)_val = data["\(paramName)"]?.data(using: String.Encoding.utf8)
                let __\(paramName): \(paramType)? = if let __\(paramName)_val {
                    try? JSONDecoder().decode(\(paramType).self, from: __\(paramName)_val)
                } else {
                    nil
                }
                """
            default:
                fatalError("Should never be reachable.")
            }
            assignments.append(assignment)
            
            let buildAssignment: String
            switch paramType {
            case "String":
                buildAssignment = """
                data["\(paramName)"] = \(paramName)
                """
            case "String?":
                buildAssignment = """
                if let \(paramName) {
                    data["\(paramName)"] = \(paramName)
                }
                """
            case _ where isParamOptionalType:
                buildAssignment =
                """
                if let \(paramName) {
                    let __\(paramName) = try? JSONEncoder().encode(\(paramName))
                    if let __\(paramName) {
                        data["\(paramName)"] = String(data: __\(paramName), encoding: .utf8)
                    }
                }
                """
            case _ where !isParamOptionalType:
                buildAssignment =
                """
                let __\(paramName) = try? JSONEncoder().encode(\(paramName))
                if let __\(paramName) {
                    data["\(paramName)"] = String(data: __\(paramName), encoding: .utf8)
                }
                """
            default:
                fatalError("Should never be reachable")
            }
            buildAssignments.append(buildAssignment)
            if let defaultValue {
                paramDeclList.append("\(paramName): \(paramType) = \(defaultValue)")
            } else {
                paramDeclList.append("\(paramName): \(paramType)")
            }
            methodArguments.append("\(paramName): __\(paramName)")
        }

        let callMethod = "\(functionName)(\(methodArguments.joined(separator: ", ")))"
        
        let decl =
            """
            \(attributes) \(visibility) init?(_ data: [String: String]) {
                \(assignments.joined(separator: "\n"))
                self.\(callMethod)
            }
            """

        
        let buildDictDecl =
            """
            \(attributes) \(visibility) static func route(\(paramDeclList.joined(separator: ", "))) -> (String, [String: String]) {
                \(paramDeclList.isEmpty ? "let" : "var") data: [String: String] = [:]
                \(buildAssignments.joined(separator: "\n"))
                return (Self.path, data)
            }
            """
        
        let staticPathVar = """
        public static var path: String { "\(path)" }
        """
        return [
            DeclSyntax(stringLiteral: staticPathVar),
            DeclSyntax(stringLiteral: decl),
            DeclSyntax(stringLiteral: buildDictDecl),
        ]
    }
}

