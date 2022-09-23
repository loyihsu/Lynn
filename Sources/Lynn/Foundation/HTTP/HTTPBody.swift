//
//  HTTPBody.swift
//
//
//  Created by Loyi Hsu on 2022/9/15.
//

public struct HTTPBody {
    public enum Mode {
        case json
    }

    public let content: [String: Any]
    public let mode: Mode
}
