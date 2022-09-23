//
//  UserDefaultsListStorageManager.swift
//
//
//  Created by Yu-Sung Loyi Hsu on 2022/9/23.
//

import Foundation
import Lynn

public final class UserDefaultsListStorageManager: LynnListStorageManager {
    private let userDefaults: UserDefaults
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    public func load(key: String) -> [LynnStorageData] {
        guard let data = userDefaults.data(forKey: key) else {
            print("UserDefaultsListStorageManager load(key:,value:): Failed to get data.")
            return []
        }
        guard let decoded = try? jsonDecoder.decode([LynnStorageData].self, from: data) else {
            print("UserDefaultsListStorageManager load(key:,value:): Failed to decode.")
            return []
        }
        return decoded
    }

    public func save(key: String, value: LynnStorageData) {
        var array = load(key: key)
        array.append(value)
        guard let data = try? jsonEncoder.encode(array) else {
            print("UserDefaultsListStorageManager save(key:,value:): Failed to save value `\(value)` for `\(key)` due to encoding issues.")
            return
        }
        userDefaults.set(data, forKey: key)
    }
}
