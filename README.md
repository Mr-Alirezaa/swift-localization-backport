# Localization Backport

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]

Reimplementation of localization tools announced at WWDC22 for older versions of Apple operating systems.

The library provides localization tools with similar interface to what Apple is providing on newest generations of operating systems, iOS 16, macOS 13, watchOS 9 and tvOS 16.

## Installation

Add this project on your `Package.swift`

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .package(url: "https://github.com/Mr-Alirezaa/swift-localization-backport", from: "0.0.1")
    ]
)
```

Or if you are using Xcode, select __File > Add Packages...__ and enter the following url in the search bar and click on __Add Dependency__ button.

```
https://github.com/Mr-Alirezaa/swift-localization-backport
```

## Todos

- [ ] update encoding and decoding style to become similar to Apple tools for localization.

## Contact

Alireza Asadi – [via Twitter @MrAlirezaa](https://twitter.com/MrAlirezaa) – [via Email](alireza.asadi.36@gmail.com)

## License

Distributed under the XYZ license. See ``LICENSE`` for more information.

[swift-image]:https://img.shields.io/badge/swift-5.7-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
