//
//  LynnWatch.swift
//
//
//  Created by Yu-Sung Loyi Hsu on 2022/10/27.
//

import Foundation

public protocol LynnWatch {
    func willSend(_ request: URLRequest)
    func didReceive(_ response: Result<LynnCoreResponse, LynnCoreError>)
}

public extension Array where Element == LynnWatch {
    func publish(_ request: URLRequest) {
        forEach {
            $0.willSend(request)
        }
    }

    func publish(_ response: LynnCoreResponse) {
        forEach {
            $0.didReceive(.success(response))
        }
    }

    func publish(_ error: LynnCoreError) {
        forEach {
            $0.didReceive(.failure(error))
        }
    }
}
