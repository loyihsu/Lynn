//
//  LynnTask.swift
//
//
//  Created by Loyi Hsu on 2022/9/15.
//

public struct LynnTask {
    public let method: HTTPMethod
    public let parameters: [String: Any]?
    public let body: HTTPBody?

    public init(method: HTTPMethod, parameters: [String: Any]? = nil, body: HTTPBody? = nil) {
        self.method = method
        self.parameters = parameters
        self.body = body
    }
}
