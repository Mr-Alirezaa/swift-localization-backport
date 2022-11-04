//
//  _LocalizedStringResource.swift
//  Localization
//
//  Created by Alireza Asadi on 11/4/22.
//

import Foundation

@available(iOS, deprecated: 16.0, message: "Use Foundation's `LocalizedStringResource` instead")
@available(macOS, deprecated: 13.0, message: "Use Foundation's `LocalizedStringResource` instead")
@available(watchOS, deprecated: 9.0, message: "Use Foundation's `LocalizedStringResource` instead")
@available(tvOS, deprecated: 16.0, message: "Use Foundation's `LocalizedStringResource` instead")
public struct BPLocalizedStringResource: Equatable, Codable, ExpressibleByStringInterpolation {
    public typealias StringLiteralType = String

    public enum BPBundleDescription {
        case main
        case atURL(URL)
        case forClass(AnyClass)
    }

    public let key: String
    public let defaultValue: String.BPLocalizationValue
    public let table: String?
    public let bundle: BPLocalizedStringResource.BPBundleDescription
    public var locale: Locale

    public init(
        _ key: StaticString,
        defaultValue: String.BPLocalizationValue,
        table: String? = nil,
        locale: Locale = .current,
        bundle: BPLocalizedStringResource.BPBundleDescription = .main,
        comment: StaticString? = nil
    ) {
        self.key = "\(key)"
        self.defaultValue = defaultValue
        self.table = table
        self.locale = locale
        self.bundle = bundle
    }

    public init(
        _ keyAndValue: String.BPLocalizationValue,
        table: String? = nil,
        locale: Locale = .current,
        bundle: BPLocalizedStringResource.BPBundleDescription = .main,
        comment: StaticString? = nil
    ) {
        self.key = "\(keyAndValue)"
        self.defaultValue = keyAndValue
        self.table = table
        self.locale = locale
        self.bundle = bundle
    }

    public init(stringLiteral: StringLiteralType) {
        key = stringLiteral
        defaultValue = "\(stringLiteral)"
        table = nil
        locale = .current
        bundle = .main
    }

    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.key == rhs.key
        && lhs.defaultValue == rhs.defaultValue
        && Bundle(lhs.bundle) == Bundle(rhs.bundle)
        && lhs.table == rhs.table
    }

    enum CodingKeys: CodingKey {
        case key
        case defaultValue
        case table
        case bundle
        case locale
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        defaultValue = try container.decode(String.BPLocalizationValue.self, forKey: .defaultValue)
        table = try container.decodeIfPresent(String.self, forKey: .table)
        let bundleURL = try container.decodeIfPresent(URL.self, forKey: .bundle) ?? Bundle.main.bundleURL
        bundle = .atURL(bundleURL)
        locale = try container.decode(Locale.self, forKey: .locale)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(defaultValue, forKey: .defaultValue)
        try container.encode(table, forKey: .table)
        try container.encode(Bundle(bundle)?.bundleURL ?? Bundle.main.bundleURL, forKey: .bundle)
        try container.encode(locale, forKey: .locale)
    }

    func localize() -> String {
        defaultValue.localize(locale: locale, bundle: Bundle(bundle) ?? .main, table: table)
    }

}

extension BPLocalizedStringResource: BPCustomLocalizedStringResourceConvertible {
    public var bpLocalizedStringResource: BPLocalizedStringResource {
        self
    }
}

@available(iOS 16, *)
extension BPLocalizedStringResource: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        LocalizedStringResource(self)
    }
}
