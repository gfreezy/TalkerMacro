// The Swift Programming Language
// https://docs.swift.org/swift-book
@_exported import OSLog

@attached(peer, names: overloaded, named(route), named(path))
public macro Routable(_: String) = #externalMacro(module: "TalkerMacroMacros", type: "DictParamOverloadMacro")


@freestanding(declaration, names: named(view))
public macro routeViews(_: Any.Type...) = #externalMacro(module: "TalkerMacroMacros", type: "RouteViewsMacro")
