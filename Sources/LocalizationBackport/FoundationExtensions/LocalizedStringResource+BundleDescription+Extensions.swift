//
//  LocalizedStringResource+BundleDescription+Extensions.swift
//  Localization
//
//  Created by Alireza Asadi on 11/4/22.
//

import Foundation

@available(iOS 16, *)
extension LocalizedStringResource {
    init(_ bplsr: BPLocalizedStringResource) {
        self.init(
            String.LocalizationValue(bplsr.defaultValue),
            table: bplsr.table,
            locale: bplsr.locale,
            bundle: LocalizedStringResource.BundleDescription(bplsr.bundle)
        )
    }
}

@available(iOS 16, *)
extension LocalizedStringResource.BundleDescription {
    init(_ bpBundleDescription: BPLocalizedStringResource.BPBundleDescription) {
        switch bpBundleDescription {
        case .main:
            self = .main
        case .atURL(let url):
            self = .atURL(url)
        case .forClass(let anyClass):
            self = .forClass(anyClass)
        }
    }
}
