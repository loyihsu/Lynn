//
//  LynnCacheError.swift
//
//
//  Created by Yu-Sung Loyi Hsu on 2022/9/23.
//

import Foundation

enum LynnCacheError: LocalizedError {
    case generalStorageManagerProvided

    var errorDescription: String? {
        switch self {
        case .generalStorageManagerProvided:
            return "The storage manager should be a type-specific one (ex. `LynnItemStorageManager` or `LynnListStorageManager`)."
        }
    }
}
