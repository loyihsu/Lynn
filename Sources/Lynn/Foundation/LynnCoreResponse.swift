//
//  LynnCoreResponse.swift
//
//
//  Created by Yu-Sung Loyi Hsu on 2022/9/24.
//

import Foundation

public struct LynnCoreResponse: Codable {
    public var statusCode: Int?
    public var header: LynnCoreHeader
    public var body: Data

    public init(statusCode: Int?, header: [String: Any]?, body: Data) {
        self.statusCode = statusCode
        self.header = LynnCoreHeader(header)
        self.body = body
    }
}

public struct LynnCoreDecodedResponse<D: Decodable> {
    public var statusCode: Int?
    public var header: LynnCoreHeader
    public var body: D

    public init(statusCode: Int?, header: [String: Any]?, body: D) {
        self.statusCode = statusCode
        self.header = LynnCoreHeader(header)
        self.body = body
    }

    init(statusCode: Int?, header: LynnCoreHeader, body: D) {
        self.statusCode = statusCode
        self.header = header
        self.body = body
    }
}

public struct LynnCoreError: Error {
    public var statusCode: Int?
    public var header: LynnCoreHeader
    public var error: Error

    public init(statusCode: Int?, header: [String: Any]?, error: Error) {
        self.statusCode = statusCode
        self.header = LynnCoreHeader(header)
        self.error = error
    }
}

@dynamicMemberLookup
public struct LynnCoreHeader: Codable, CustomStringConvertible {
    private var _header: Data?

    var dictionary: [String: Any]? {
        guard let _header = _header else { return nil }
        return try? JSONSerialization.jsonObject(with: _header) as? [String: Any]
    }

    public subscript(dynamicMember key: String) -> Any? {
        return dictionary?[key]
    }

    init(_ dictionary: [String: Any]?) {
        if let dictionary = dictionary {
            self._header = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        }
    }

    public var description: String {
        return dictionary?.description ?? ""
    }
}
