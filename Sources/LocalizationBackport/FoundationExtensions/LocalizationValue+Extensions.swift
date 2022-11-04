//
//  String+LocalizationValue+Extensions.swift
//  Localization
//
//  Created by Alireza Asadi on 11/4/22.
//

import Foundation

@available(iOS 16, *)
extension String.LocalizationValue {
    init(_ bpLocalizationValue: String.BPLocalizationValue) {
        var interpolation = String.LocalizationValue.StringInterpolation(
            literalCapacity: 0,
            interpolationCount: bpLocalizationValue.arguments.count + 1
        )

        for element in bpLocalizationValue.elements {
            switch element {
            case .literal(let literal):
                interpolation.appendLiteral(literal)
            case .interpolation(let formatArgument):
                switch formatArgument.storage {
                case let .value(value):
                    let value = value.cVarArg()
                    if let formatSpecifiable = value as? (any _FormatSpecifiable) {
                        interpolation.appendInterpolation(
                            formatSpecifiable,
                            specifier: formatArgument.specifier
                        )
                    } else if let value = value as? String {
                        interpolation.appendInterpolation(value)
                    }
                case .placeholder(let placeholder):
                    interpolation.appendInterpolation(
                        placeholder: Placeholder(placeholder),
                        specifier: formatArgument.specifier
                    )
                }
            }
        }

        self = String.LocalizationValue(stringInterpolation: interpolation)
    }
}
