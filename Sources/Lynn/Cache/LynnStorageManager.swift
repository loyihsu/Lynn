//
//  LYStorageManager.swift
//
//
//  Created by Yu-Sung Loyi Hsu on 2022/9/16.
//

import Foundation

public protocol LynnStorageManager {
    func save(key: String, value: LynnStorageData)
}

public protocol LynnItemStorageManager: LynnStorageManager {
    func load(key: String) -> LynnStorageData?
}

public protocol LynnListStorageManager: LynnStorageManager {
    func load(key: String) -> [LynnStorageData]
}
