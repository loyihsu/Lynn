//
//  TargetGroup.swift
//
//
//  Created by Loyi Hsu on 2022/9/15.
//

import Foundation

public protocol TargetGroup {
    var baseURL: String { get }
    var path: String { get }
    var task: LynnTask { get }
    var headers: [String: String]? { get }
    var storageKey: String { get }
    var sampleData: Data? { get }
}

extension TargetGroup {
    var target: LynnTarget {
        LynnTarget(
            url: URL(string: baseURL)!.appendingPathComponent(path),
            task: task,
            headers: headers,
            sampleData: sampleData
        )
    }
}
