//
//  LynnTarget.swift
//
//
//  Created by Loyi Hsu on 2022/9/15.
//

import Foundation

public struct LynnTarget {
    public let url: URL
    public let task: LynnTask
    public let headers: [String: String]?
    public let sampleData: Data?

    public init(url: URL, task: LynnTask, headers: [String: String]?, sampleData: Data?) {
        self.url = url
        self.task = task
        self.headers = headers
        self.sampleData = sampleData
    }
}
