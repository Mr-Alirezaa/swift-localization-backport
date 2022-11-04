//
//  String+LocalizationValue+Placeholder+Extensions.swift
//  Localization
//
//  Created by Alireza Asadi on 11/4/22.
//

import Foundation


@available(iOS 16, *)
extension String.LocalizationValue.Placeholder {
    init(_ _placeholder: String.BPLocalizationValue.BPPlaceholder) {
        switch _placeholder {
        case .double:
            self = .double
        case .float:
            self = .float
        case .int:
            self = .int
        case .object:
            self = .object
        case .uint:
            self = .uint
        }
    }
}
