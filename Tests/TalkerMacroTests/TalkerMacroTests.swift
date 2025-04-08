import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(TalkerMacroMacros)
import TalkerMacroMacros

let testMacros: [String: Macro.Type] = [
    "Routable": DictParamOverloadMacro.self,
    "routeViews": RouteViewsMacro.self,
]
#endif

final class TalkerMacroTests: XCTestCase {
    func testMacroInit() throws {
        #if canImport(TalkerMacroMacros)
        assertMacroExpansion(
            """
            struct A<T: Decodable> {
                @Routable("/p")
                init(a: String, b: Int, c: Float = 0, d: String? = nil, e: T, f: T?) {
                    fatalError()
                }
            }
            """,
            expandedSource: """
            struct A<T: Decodable> {
                init(a: String, b: Int, c: Float = 0, d: String? = nil, e: T, f: T?) {
                    fatalError()
                }

                public static var path: String {
                    "/p"
                }

                init?(_ data: [String: String]) {
                    let __a = data["a"]
                    guard let __a else {
                        os_log("Navigate to route `/p` error, return early.")
                    return nil
                    }
                    guard let __b_val = data["b"]?.data(using: String.Encoding.utf8) else {
                        os_log("Navigate to route `/p` error, return early.")
                    return nil
                    }
                    let __b = try? JSONDecoder().decode(Int.self, from: __b_val)
                    guard let __b else {
                        os_log("Navigate to route `/p` error, return early.")
                    return nil
                    }
                    let __c_val = data["c"]?.data(using: String.Encoding.utf8)
                    let __c: Float = if let __c_val {
                        (try? JSONDecoder().decode(Float.self, from: __c_val)) ?? 0
                    } else {
                        0
                    }
                    let __d = data["d"] ?? nil
                    guard let __e_val = data["e"]?.data(using: String.Encoding.utf8) else {
                        os_log("Navigate to route `/p` error, return early.")
                    return nil
                    }
                    let __e = try? JSONDecoder().decode(T.self, from: __e_val)
                    guard let __e else {
                        os_log("Navigate to route `/p` error, return early.")
                    return nil
                    }
                    let __f_val = data["f"]?.data(using: String.Encoding.utf8)
                    let __f: T?? = if let __f_val {
                        try? JSONDecoder().decode(T?.self, from: __f_val)
                    } else {
                        nil
                    }
                    self.init(a: __a, b: __b, c: __c, d: __d, e: __e, f: __f)
                }

                static func route(a: String, b: Int, c: Float = 0, d: String? = nil, e: T, f: T?) -> (String, [String: String]) {
                    var data: [String: String] = [:]
                    data["a"] = a
                    let __b = try? JSONEncoder().encode(b)
                    if let __b {
                        data["b"] = String(data: __b, encoding: .utf8)
                    }
                    let __c = try? JSONEncoder().encode(c)
                    if let __c {
                        data["c"] = String(data: __c, encoding: .utf8)
                    }
                    if let d {
                        data["d"] = d
                    }
                    let __e = try? JSONEncoder().encode(e)
                    if let __e {
                        data["e"] = String(data: __e, encoding: .utf8)
                    }
                    if let f {
                        let __f = try? JSONEncoder().encode(f)
                        if let __f {
                            data["f"] = String(data: __f, encoding: .utf8)
                        }
                    }
                    return (Self.path, data)
                }
            }

            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroRouteView() throws {
        #if canImport(TalkerMacroMacros)
        assertMacroExpansion(
            """
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
                @MainActor
                init(a: String, b: Int, c: Float, d: String?) {
                    fatalError()
                }

                var body: some View {
                    Text("hell")
                }
            }

            struct B {
                @MainActor
                #routeViews(A.self, C.self)
            }

            """,
            expandedSource: """
            struct A: View {
                init(a: String, b: Int, c: Float, d: String?) {
                    fatalError()
                }

                public static var path: String {
                    "/path/a"
                }

                init?(_ data: [String: String]) {
                    let __a = data["a"]
                    guard let __a else {
                        os_log("Navigate to route `/path/a` error, return early.")
                    return nil
                    }
                    guard let __b_val = data["b"]?.data(using: String.Encoding.utf8) else {
                        os_log("Navigate to route `/path/a` error, return early.")
                    return nil
                    }
                    let __b = try? JSONDecoder().decode(Int.self, from: __b_val)
                    guard let __b else {
                        os_log("Navigate to route `/path/a` error, return early.")
                    return nil
                    }
                    guard let __c_val = data["c"]?.data(using: String.Encoding.utf8) else {
                        os_log("Navigate to route `/path/a` error, return early.")
                    return nil
                    }
                    let __c = try? JSONDecoder().decode(Float.self, from: __c_val)
                    guard let __c else {
                        os_log("Navigate to route `/path/a` error, return early.")
                    return nil
                    }
                    let __d = data["d"]
                    self.init(a: __a, b: __b, c: __c, d: __d)
                }

                static func route(a: String, b: Int, c: Float, d: String?) -> (String, [String: String]) {
                    var data: [String: String] = [:]
                    data["a"] = a
                    let __b = try? JSONEncoder().encode(b)
                    if let __b {
                        data["b"] = String(data: __b, encoding: .utf8)
                    }
                    let __c = try? JSONEncoder().encode(c)
                    if let __c {
                        data["c"] = String(data: __c, encoding: .utf8)
                    }
                    if let d {
                        data["d"] = d
                    }
                    return (Self.path, data)
                }

                var body: some View {
                    Text("hell")
                }
            }

            struct C: View {
                @MainActor
                init(a: String, b: Int, c: Float, d: String?) {
                    fatalError()
                }

                public static var path: String {
                    "/path/a"
                }

                @MainActor  init?(_ data: [String: String]) {
                    let __a = data["a"]
                    guard let __a else {
                        os_log("Navigate to route `/path/a` error, return early.")
                    return nil
                    }
                    guard let __b_val = data["b"]?.data(using: String.Encoding.utf8) else {
                        os_log("Navigate to route `/path/a` error, return early.")
                    return nil
                    }
                    let __b = try? JSONDecoder().decode(Int.self, from: __b_val)
                    guard let __b else {
                        os_log("Navigate to route `/path/a` error, return early.")
                    return nil
                    }
                    guard let __c_val = data["c"]?.data(using: String.Encoding.utf8) else {
                        os_log("Navigate to route `/path/a` error, return early.")
                    return nil
                    }
                    let __c = try? JSONDecoder().decode(Float.self, from: __c_val)
                    guard let __c else {
                        os_log("Navigate to route `/path/a` error, return early.")
                    return nil
                    }
                    let __d = data["d"]
                    self.init(a: __a, b: __b, c: __c, d: __d)
                }

                @MainActor  static func route(a: String, b: Int, c: Float, d: String?) -> (String, [String: String]) {
                    var data: [String: String] = [:]
                    data["a"] = a
                    let __b = try? JSONEncoder().encode(b)
                    if let __b {
                        data["b"] = String(data: __b, encoding: .utf8)
                    }
                    let __c = try? JSONEncoder().encode(c)
                    if let __c {
                        data["c"] = String(data: __c, encoding: .utf8)
                    }
                    if let d {
                        data["d"] = d
                    }
                    return (Self.path, data)
                }

                var body: some View {
                    Text("hell")
                }
            }

            struct B {
                @MainActor @ViewBuilder
                func view(_ path: String, query: [String: String]) -> some View {
                    switch path {
                    case A.path:
                    A(query)
                    case C.path:
                        C(query)
                    default:
                        Text("Not found: \\(path), \\(query). Did you forget to register the View.")
                    }
                }
            }

            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
