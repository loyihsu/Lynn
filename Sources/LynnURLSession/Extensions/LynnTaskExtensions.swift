//
//  LynnTaskExtensions.swift
//
//
//  Created by Loyi Hsu on 2022/9/15.
//

import Foundation
import Lynn

extension LynnTask {
    var urlSessionHttpMethod: String {
        switch method {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }

    var urlSessionParameters: String? {
        guard let parameters = parameters else { return nil }
        return urlEncode(dictionary: parameters)
    }

    var urlSessionBodyHeader: [String: String]? {
        guard let body = body else { return nil }
        switch body.mode {
        case .json:
            return ["Content-Type": "application/json; charset=utf-8"]
        case .urlEncoded:
            return ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8"]
        }
    }

    var urlSessionBodyData: Data? {
        guard let body = body else { return nil }
        switch body.mode {
        case .json:
            return try? JSONSerialization.data(withJSONObject: body.content)
        case .urlEncoded:
            return urlEncode(dictionary: body.content)?.data(using: .utf8)
        }
    }

    private func urlEncode(dictionary: [String: Any]) -> String? {
        dictionary
            .compactMap { key, value -> String? in
                guard let key = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let value = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                else {
                    return nil
                }
                return "\(key)=\(value)"
            }
            .joined(separator: "&")
    }
}
