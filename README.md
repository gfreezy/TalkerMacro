# TalkerMacro

A Swift macro package that provides type-safe routing capabilities for iOS apps.

## Features

### @Routable Macro

The `@Routable` macro generates type-safe initializers for views that can be instantiated from route paths and query parameters. It automatically handles:

- Parameter parsing from query dictionaries
- Type conversion for common Swift types
- Optional parameters with default values
- Early returns for invalid parameters

[TalkerCommon](https://github.com/gfreezy/TalkerCommon)

### @routeViews Macro

The `@routeViews` macro generates a switch statement that matches the route path to the corresponding view type. It automatically handles:

- Type inference for view types
- Early returns for invalid route paths

## How to use

```swift
import SwiftUI
import TalkerMacro

struct AView: View {
    @Routeable
    init(query: [String: Any]) {
        self.query = query
    }
}


struct BView: View {
    @Routeable
    init(query: [String: Any]) {
        self.query = query
    }
}
```

```swift
import SwiftUI
import TalkerMacro

struct RouterView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    #routeViews(AView.self, BView.self)

    var body: some View {
        CmRouterView {
            content
        } destView: { path, query in
            view(path, query: query)
        }
    }
}

```
