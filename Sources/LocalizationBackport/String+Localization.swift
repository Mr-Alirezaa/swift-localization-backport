//
//  String+Localization.swift
//  Localization
//
//  Created by Alireza Asadi on 11/3/22.
//

import Foundation

extension String {
    @available(iOS, deprecated: 16.0, message: "Use Foundation's String.init(localized:) instead")
    @available(macOS, deprecated: 13.0, message: "Use Foundation's String.init(localized:) instead")
    @available(watchOS, deprecated: 9.0, message: "Use Foundation's String.init(localized:) instead")
    @available(tvOS, deprecated: 16.0, message: "Use Foundation's String.init(localized:) instead")
    @_disfavoredOverload public init(localized lsr: BPLocalizedStringResource) {
        if #available(iOS 16, *) {
            self.init(localized: LocalizedStringResource(lsr))
        } else {
            self = lsr.defaultValue.localize(
                locale: lsr.locale,
                bundle: Bundle(lsr.bundle) ?? .main,
                table: lsr.table
            )
        }
    }

    @available(iOS, deprecated: 16.0, message: "Use Foundation's String.init(localized:table:bundle:locale:comment:) instead")
    @available(macOS, deprecated: 13.0, message: "Use Foundation's String.init(localized:table:bundle:locale:comment:) instead")
    @available(watchOS, deprecated: 9.0, message: "Use Foundation's String.init(localized:table:bundle:locale:comment:) instead")
    @available(tvOS, deprecated: 16.0, message: "Use Foundation's String.init(localized:table:bundle:locale:comment:) instead")
    public init(
        localized localizationValue: BPLocalizationValue,
        table: String? = nil,
        bundle: Bundle? = nil,
        locale: Locale = .current,
        comment: StaticString? = nil
    ) {
        if #available(iOS 16, *) {
            let localizationValue = LocalizationValue(localizationValue)
            self.init(localized: localizationValue, table: table, bundle: bundle, locale: locale, comment: nil)
        } else {
            self = localizationValue.localize(locale: locale, bundle: bundle ?? .main, table: table)
        }
    }
}
