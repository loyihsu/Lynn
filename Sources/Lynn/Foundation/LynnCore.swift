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
    ) async throws -> Data

    func sendRequest(
        to target: LynnTarget,
        callback: @escaping (Data) -> Void,
        onError: @escaping (Error) -> Void
    )
}
