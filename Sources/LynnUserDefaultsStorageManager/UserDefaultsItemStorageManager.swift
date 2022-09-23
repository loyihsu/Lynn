//
//  UserDefaultsItemStorageManager.swift
//
//
//  Created by Yu-Sung Loyi Hsu on 2022/9/16.
//

import Foundation
import Lynn

public final class UserDefaultsItemStorageManager: LynnItemStorageManager {
    private let userDefaults: UserDefaults
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    public func save(key: String, value: LynnStorageData) {
        guard let data = try? jsonEncoder.encode(value) else {
            print("UserDefaultsItemStroageManager save(key:,value:): Failed to save value `\(value)` for `\(key)` due to encoding issues.")
            return
        }
        userDefaults.set(data, forKey: key)
    }

    public func load(key: String) -> LynnStorageData? {
        guard let data = userDefaults.data(forKey: key) else {
            print("UserDefaultsItemStroageManager load(key:): No value exists for key `\(key)`.")
            return nil
        }
        guard let storageData = try? jsonDecoder.decode(LynnStorageData.self, from: data) else {
            print("UserDefaultsItemStroageManager load(key:): Failed to get value for key `\(key)` due to decoding issues.")
            return nil
        }
        return storageData
    }
}
