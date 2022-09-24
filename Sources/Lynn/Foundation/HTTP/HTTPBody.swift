//
//  HTTPBody.swift
//
//
//  Created by Loyi Hsu on 2022/9/15.
//

public struct HTTPBody {
    public enum Mode {
        case json, urlEncoded
    }

    public let content: [String: Any]
    public let mode: Mode

    public init(content: [String: Any], mode: Mode) {
        self.content = content
        self.mode = mode
    }
}
