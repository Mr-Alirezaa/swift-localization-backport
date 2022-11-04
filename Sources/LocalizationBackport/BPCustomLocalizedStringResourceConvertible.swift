//
//  BPCustomLocalizedStringResourceConvertible.swift
//  Localization
//
//  Created by Alireza Asadi on 11/4/22.
//

import Foundation

@available(iOS, deprecated: 16.0, message: "Use Foundation's `BPCustomLocalizedStringResourceConvertible` instead")
@available(macOS, deprecated: 13.0, message: "Use Foundation's `BPCustomLocalizedStringResourceConvertible` instead")
@available(watchOS, deprecated: 9.0, message: "Use Foundation's `BPCustomLocalizedStringResourceConvertible` instead")
@available(tvOS, deprecated: 16.0, message: "Use Foundation's `BPCustomLocalizedStringResourceConvertible` instead")
public protocol BPCustomLocalizedStringResourceConvertible {
    var bpLocalizedStringResource: BPLocalizedStringResource { get }
}

@available(iOS 16, *)
public extension BPCustomLocalizedStringResourceConvertible where Self: CustomLocalizedStringResourceConvertible {
    var localizedStringResounce: LocalizedStringResource {
        LocalizedStringResource(bpLocalizedStringResource)
    }
}
