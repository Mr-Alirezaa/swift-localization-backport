//
//  BPLocalizationValue.swift
//  Localization
//
//  Created by Alireza Asadi on 11/4/22.
//

import Foundation

extension String {
    @available(iOS, deprecated: 16.0, message: "Use Foundation's `String.LocalizationValue` instead")
    @available(macOS, deprecated: 13.0, message: "Use Foundation's `String.LocalizationValue` instead")
    @available(watchOS, deprecated: 9.0, message: "Use Foundation's `String.LocalizationValue` instead")
    @available(tvOS, deprecated: 16.0, message: "Use Foundation's `String.LocalizationValue` instead")
    public struct BPLocalizationValue {
        let elements: [Element]
        let key: String
        let arguments: [FormatArgument]
    }
}

extension String.BPLocalizationValue: Equatable, Codable, ExpressibleByStringInterpolation {
    public typealias StringLiteralType = String

    public init(_ value: String) {
        elements = [.literal(value)]
        (key, arguments) = Self.extract(from: elements)
    }

    public init(stringLiteral: StringLiteralType) {
        elements = [.literal(stringLiteral)]
        (key, arguments) = Self.extract(from: elements)
    }

    public init(stringInterpolation: StringInterpolation) {
        elements = stringInterpolation.elements
        (key, arguments) = Self.extract(from: stringInterpolation.elements)
    }

    func localize(locale: Locale = .current, bundle: Bundle = .main, table: String? = nil) -> String {
        let localizedFormat = bundle.localizedString(forKey: key, value: nil, table: table)

        return String(
            format: localizedFormat,
            locale: locale,
            arguments: arguments.map { value -> any CVarArg in
                switch value.storage {
                case .value(let value):
                    return value.cVarArg()
                case .placeholder(let placeholder):
                    switch placeholder {
                    case .double:
                        return 0.0 as Double
                    case .float:
                        return 0.0 as Float
                    case .int:
                        return 0 as Int
                    case .object:
                        return "(null)"
                    case .uint:
                        return 0 as UInt
                    }
                }
            }
        )
    }

    private static func extract(from elements: [Element]) -> (key: String, arguments: [FormatArgument]) {
        var arguments: [FormatArgument] = []
        let key = elements.reduce(into: "") { partialResult, element in
            switch element {
            case .literal(let literal):
                partialResult += literal
            case .interpolation(let argument):
                partialResult += argument.specifier
                arguments.append(argument)
            }
        }

        return (key: key, arguments: arguments)
    }
}

extension String.BPLocalizationValue {
    enum Element: Codable, Hashable {
        case literal(String)
        case interpolation(FormatArgument)

        static func string(
            _ arg: String,
            specifier: String = BPPlaceholder.object.formatSpecifier
        ) -> Element {
            .interpolation(.init(storage: .value(.string(arg)), specifier: specifier))
        }

        static func double(
            _ arg: Double,
            specifier: String = BPPlaceholder.double.formatSpecifier
        ) -> Element {
            .interpolation(.init(storage: .value(.double(arg)), specifier: specifier))
        }

        static func float(
            _ arg: Float,
            specifier: String = BPPlaceholder.float.formatSpecifier
        ) -> Element {
            .interpolation(.init(storage: .value(.float(arg)), specifier: specifier))
        }

        static func int(
            _ arg: Int,
            specifier: String = BPPlaceholder.int.formatSpecifier
        ) -> Element {
            .interpolation(.init(storage: .value(.int(arg)), specifier: specifier))
        }

        static func object<Subject: NSObject>(
            _ arg: Subject,
            specifier: String = BPPlaceholder.object.formatSpecifier
        ) -> Element {
            .interpolation(.init(storage: .value(.object(arg)), specifier: specifier))
        }

        static func uint(
            _ arg: UInt,
            specifier: String = BPPlaceholder.uint.formatSpecifier
        ) -> Element {
            .interpolation(.init(storage: .value(.uint(arg)), specifier: specifier))
        }

        static func placeholder(placeholder: BPPlaceholder) -> Element {
            .interpolation(.init(storage: .placeholder(placeholder), specifier: placeholder.formatSpecifier))
        }

        static func placeholder(placeholder: BPPlaceholder, specifier: String) -> Element {
            .interpolation(.init(storage: .placeholder(placeholder), specifier: specifier))
        }
    }
}

extension String.BPLocalizationValue {
    public enum BPPlaceholder: Codable, Hashable, Equatable {
        case double
        case float
        case int
        case object
        case uint

        var formatSpecifier: String {
            switch self {
            case .double:
                return "%lf"
            case .float:
                return "%f"
            case .int:
                return "%lld"
            case .object:
                return "%@"
            case .uint:
                return "%llu"
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(formatSpecifier)
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let specifier = try container.decode(String.self)
            switch specifier {
            case "%lf":
                self = .double
            case "%f":
                self = .float
            case "%lld":
                self = .int
            case "%@":
                self = .object
            case "%llu":
                self = .uint
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Unable to create `BPPlaceholder` from specified String value."
                    )
                )
            }
        }
    }
}

extension String.BPLocalizationValue {
    public struct StringInterpolation: StringInterpolationProtocol {
        public typealias StringLiteralType = String

        var elements: [Element]

        public init(literalCapacity: Int, interpolationCount: Int) {
            elements = []
            elements.reserveCapacity(2 * interpolationCount + 1)
        }

        public mutating func appendLiteral(_ literal: String) {
            elements.append(.literal(literal.replacingOccurrences(of: "%", with: "%%")))
        }

        public mutating func appendInterpolation(_ string: String) {
            elements.append(.string(string))
        }

        public mutating func appendInterpolation<F: BinaryFloatingPoint>(_ floatingPoint: F) {
            elements.append(.double(Double(floatingPoint)))
        }

        public mutating func appendInterpolation<F: BinaryFloatingPoint>(_ floatingPoint: F, specifier: String) {
            elements.append(.double(Double(floatingPoint), specifier: specifier))
        }

        public mutating func appendInterpolation(_ float: Float) {
            elements.append(.float(float))
        }

        public mutating func appendInterpolation(_ float: Float, specifier: String) {
            elements.append(.float(float, specifier: specifier))
        }

        public mutating func appendInterpolation<I: BinaryInteger>(_ int: I) {
            elements.append(.int(Int(truncatingIfNeeded: int)))
        }

        public mutating func appendInterpolation<I: BinaryInteger>(_ int: I, specifier: String) {
            elements.append(.int(Int(truncatingIfNeeded: int), specifier: specifier))
        }

        public mutating func appendInterpolation<U: UnsignedInteger>(_ uint: U) {
            elements.append(.uint(UInt(truncatingIfNeeded: uint)))
        }

        public mutating func appendInterpolation<U: UnsignedInteger>(_ uint: U, specifier: String) {
            elements.append(.uint(UInt(truncatingIfNeeded: uint), specifier: specifier))
        }

        public mutating func appendInterpolation(_ int: Int, formatter: Formatter) {
            guard let formattedString = formatter.string(for: NSNumber(value: int)) else {
                fatalError("Unable to create format the input value into desired String form.")
            }

            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ uint: UInt, formatter: Formatter) {
            guard let formattedString = formatter.string(for: NSNumber(value: uint)) else {
                fatalError("Unable to create format the input value into desired String form.")
            }

            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ double: Double, formatter: Formatter) {
            guard let formattedString = formatter.string(for: NSNumber(value: double)) else {
                fatalError("Unable to create format the input value into desired String form.")
            }

            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation<U>(_ measurement: Measurement<U>, formatter: MeasurementFormatter) {
            guard let formattedString = formatter.string(for: measurement) else {
                fatalError("Unable to create format the input value into desired String form.")
            }

            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ components: PersonNameComponents, formatter: PersonNameComponentsFormatter) {
            guard let formattedString = formatter.string(for: components) else {
                fatalError("Unable to create format the input value into desired String form.")
            }

            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ date: Date, formatter: DateFormatter) {
            let formattedString = formatter.string(from: date)
            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ components: DateComponents, formatter: DateComponentsFormatter) {
            guard let formattedString = formatter.string(from: components) else {
                fatalError("Unable to create format the input value into desired String form.")
            }

            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ components: DateComponents, formatter: RelativeDateTimeFormatter) {
            let formattedString = formatter.localizedString(from: components)
            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ date: Date, relativeTo referenceDate: Date, formatter: RelativeDateTimeFormatter) {
            let formattedString = formatter.localizedString(for: date, relativeTo: referenceDate)
            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ dateInterval: DateInterval, formatter: DateIntervalFormatter) {
            guard let formattedString = formatter.string(from: dateInterval) else {
                fatalError("Unable to create format the input value into desired String form.")
            }

            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ date: Date, to endDate: Date, formatter: DateIntervalFormatter) {
            let formattedString = formatter.string(from: date, to: endDate)
            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ byteCount: Int64, formatter: ByteCountFormatter) {
            let formattedString = formatter.string(fromByteCount: byteCount)
            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(_ list: Array<Any>, formatter: ListFormatter) {
            guard let formattedString = formatter.string(from: list) else {
                fatalError("Unable to create format the input value into desired String form.")
            }

            elements.append(.string(formattedString))
        }

        public mutating func appendInterpolation(placeholder: String.BPLocalizationValue.BPPlaceholder) {
            elements.append(.placeholder(placeholder: placeholder))
        }

        public mutating func appendInterpolation(placeholder: String.BPLocalizationValue.BPPlaceholder, specifier: String) {
            elements.append(.placeholder(placeholder: placeholder, specifier: specifier))
        }

        @available(iOS 15.0, *)
        public mutating func appendInterpolation<F>(
            _ value: F.FormatInput,
            format: F
        ) where F: FormatStyle, F.FormatOutput: StringProtocol {
            elements.append(.string(String(format.format(value))))
        }

        @available(iOS 15.0, *)
        public mutating func appendInterpolation<C: Collection>(
            _ value: C,
            format: ListFormatStyle<StringStyle, [String]>
        ) where C.Element: BPCustomLocalizedStringResourceConvertible {
            elements.append(.string(format.format(value.map { $0.bpLocalizedStringResource.localize() })))
        }
    }
}

extension String.BPLocalizationValue {
    struct FormatArgument: Codable, Hashable {
        enum Storage: Codable, Hashable {
            case value(Value)
            case placeholder(BPPlaceholder)

            enum CodingKeys: String, CodingKey {
                case type
                case storage
            }

            private enum StorageType: Codable, Hashable {
                case value
                case placeholder
            }

            enum Value: Codable, Hashable {
                case string(String)
                case int(Int)
                case double(Double)
                case float(Float)
                case uint(UInt)
                case object(NSObject)

                func cVarArg() -> CVarArg {
                    switch self {
                    case .string(let value):
                        return value
                    case .int(let value):
                        return value
                    case .double(let value):
                        return value
                    case .float(let value):
                        return value
                    case .uint(let value):
                        return value
                    case .object(let value):
                        return value
                    }
                }

                private enum CodingKeys: String, CodingKey {
                    case type
                    case value
                }

                private enum ValueType: String, Codable {
                    case string
                    case int
                    case double
                    case float
                    case uint
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    let type = try container.decode(ValueType.self, forKey: .type)
                    switch type {
                    case .string:
                        let value = try container.decode(String.self, forKey: .value)
                        self = .string(value)
                    case .int:
                        let value = try container.decode(Int.self, forKey: .value)
                        self = .int(value)
                    case .double:
                        let value = try container.decode(Double.self, forKey: .value)
                        self = .double(value)
                    case .float:
                        let value = try container.decode(Float.self, forKey: .value)
                        self = .float(value)
                    case .uint:
                        let value = try container.decode(UInt.self, forKey: .value)
                        self = .uint(value)
                    }
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    switch self {
                    case .string(let value):
                        try container.encode(value, forKey: .value)
                        try container.encode(ValueType.string, forKey: .type)
                    case .int(let value):
                        try container.encode(value, forKey: .value)
                        try container.encode(ValueType.int, forKey: .type)
                    case .double(let value):
                        try container.encode(value, forKey: .value)
                        try container.encode(ValueType.double, forKey: .type)
                    case .float(let value):
                        try container.encode(value, forKey: .value)
                        try container.encode(ValueType.float, forKey: .type)
                    case .uint(let value):
                        try container.encode(value, forKey: .value)
                        try container.encode(ValueType.uint, forKey: .type)
                    case .object(let value):
                        throw EncodingError.invalidValue(
                            value,
                            EncodingError.Context(codingPath: container.codingPath,
                                                  debugDescription: "Unable to encode value.")
                        )
                    }
                }
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(StorageType.self, forKey: .type)

                switch type {
                case .value:
                    self = try .value(container.decode(Value.self, forKey: .storage))
                case .placeholder:
                    self = try .placeholder(container.decode(BPPlaceholder.self, forKey: .storage))
                }
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case .value(let value):
                    try container.encode(StorageType.value, forKey: .type)
                    try container.encode(value, forKey: .storage)
                case .placeholder(let placeholder):
                    try container.encode(StorageType.placeholder, forKey: .type)
                    try container.encode(placeholder, forKey: .storage)
                }
            }
        }

        var storage: Storage
        var specifier: String
    }

}
