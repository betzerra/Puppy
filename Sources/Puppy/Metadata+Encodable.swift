//
//  Metadata+Encodable.swift
//  
//
//  Created by Ezequiel Becerra on 08/07/2022.
//

#if canImport(Logging)
import Foundation
import Logging

extension Logger.MetadataValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let string):
            try container.encode(string)

        case .stringConvertible(let convertible):
            try container.encode(convertible.description)

        case .dictionary(let submeta):
            try container.encode(submeta)

        case .array(let items):
            try container.encode(items)
        }
    }
}
#endif
