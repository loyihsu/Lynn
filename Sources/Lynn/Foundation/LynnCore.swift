//
//  LynnCore.swift
//
//
//  Created by Loyi Hsu on 2022/9/15.
//

import Foundation

public protocol LynnCore {
    @available(macOS 10.15, iOS 13.0, *)
    func sendRequest(
        to target: LynnTarget
    ) async throws -> LynnCoreResponse

    func sendRequest(
        to target: LynnTarget,
        callback: @escaping (LynnCoreResponse) -> Void,
        onError: @escaping (LynnCoreError) -> Void
    )
}

public struct LynnCoreResponse: Codable {
    private var _header: Data?

    public var statusCode: Int?
    public var body: Data

    public var header: [String: Any]? {
        guard let _header = _header else { return nil }
        return try? JSONSerialization.jsonObject(with: _header) as? [String: Any]
    }

    public init(statusCode: Int?, header: [String: Any]?, body: Data) {
        self.statusCode = statusCode
        if let header = header {
            self._header = try? JSONSerialization.data(withJSONObject: header, options: [])
        }
        self.body = body
    }
}

public struct LynnCoreError: Error {
    private var _header: Data?

    public var statusCode: Int?
    public var error: Error

    public var header: [String: Any]? {
        guard let _header = _header else { return nil }
        return try? JSONSerialization.jsonObject(with: _header) as? [String: Any]
    }

    public init(statusCode: Int?, header: [String: Any]?, error: Error) {
        self.statusCode = statusCode
        if let header = header {
            self._header = try? JSONSerialization.data(withJSONObject: header, options: [])
        }
        self.error = error
    }
}

public struct LynnCoreDecodedResponse<D: Decodable> {
    private var _header: Data?

    public var statusCode: Int?
    public var body: D

    public var header: [String: Any]? {
        guard let _header = _header else { return nil }
        return try? JSONSerialization.jsonObject(with: _header) as? [String: Any]
    }

    public init(statusCode: Int?, header: [String: Any]?, body: D) {
        self.statusCode = statusCode
        if let header = header {
            self._header = try? JSONSerialization.data(withJSONObject: header, options: [])
        }
        self.body = body
    }
}
