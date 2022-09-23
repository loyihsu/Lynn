//
//  LYStorageData.swift
//
//
//  Created by Yu-Sung Loyi Hsu on 2022/9/17.
//

import Foundation

public struct LynnStorageData: Codable {
    public let validUntil: Date
    public let data: Data

    var isValid: Bool {
        Date() <= validUntil
    }
}
