//
//  Bundle+Extensions.swift
//  Localization
//
//  Created by Alireza Asadi on 11/4/22.
//

import Foundation

extension Bundle {
    convenience init?(_ bpBundleDescription: BPLocalizedStringResource.BPBundleDescription) {
        switch bpBundleDescription {
        case .main:
            self.init()
        case .atURL(let url):
            self.init(url: url)
        case .forClass(let anyClass):
            self.init(for: anyClass)
        }
    }
}
