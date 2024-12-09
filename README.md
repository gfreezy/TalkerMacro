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