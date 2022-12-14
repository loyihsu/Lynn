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
        to target: LynnTarget,
        watches: [LynnWatch]
    ) async throws -> LynnCoreResponse

    func sendRequest(
        to target: LynnTarget,
        callback: @escaping (LynnCoreResponse) -> Void,
        onError: @escaping (LynnCoreError) -> Void,
        watches: [LynnWatch]
    )
}
