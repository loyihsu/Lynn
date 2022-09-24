//
//  URLSessionNetworkCore.swift
//
//
//  Created by Loyi Hsu on 2022/9/15.
//

import Foundation
import Lynn

public class URLSessionNetworkCore: LynnCore {
    public init() {}

    @available(macOS 10.15, iOS 13.0, *)
    public func sendRequest(
        to target: LynnTarget
    ) async throws -> LynnCoreResponse {
        try await withCheckedThrowingContinuation { continuation in
            sendRequest(
                to: target,
                callback: {
                    continuation.resume(returning: $0)
                },
                onError: {
                    continuation.resume(throwing: $0)
                }
            )
        }
    }

    public func sendRequest(
        to target: LynnTarget,
        callback: @escaping (LynnCoreResponse) -> Void,
        onError: @escaping (LynnCoreError) -> Void
    ) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let url = target.url

        var request: URLRequest

        if let parameters = target.task.urlSessionParameters {
            request = URLRequest(url: url.withQuery(parameterString: parameters))
        } else {
            request = URLRequest(url: url)
        }

        request.httpMethod = target.task.urlSessionHttpMethod

        if let bodyHeader = target.task.urlSessionBodyHeader,
           let bodyContent = target.task.urlSessionBodyData
        {
            bodyHeader.forEach {
                request.addValue($1, forHTTPHeaderField: $0)
            }
            request.httpBody = bodyContent
        }

        target.headers?.forEach {
            request.addValue($1, forHTTPHeaderField: $0)
        }

        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard let response = response as? HTTPURLResponse else { return }
            if let error = error {
                onError(
                    LynnCoreError(
                        statusCode: response.statusCode,
                        header: response.allHeaderFields as? [String: Any],
                        error: error
                    )
                )
            } else if let data = data {
                callback(
                    LynnCoreResponse(
                        statusCode: response.statusCode,
                        header: response.allHeaderFields as? [String: Any],
                        body: data
                    )
                )
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String { get }
}

extension Dictionary: URLQueryParameterStringConvertible {
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
}

private extension URL {
    func withQuery(parameterString: String) -> URL {
        URL(string: "\(absoluteString)?\(parameterString)")!
    }
}
