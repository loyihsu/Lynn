//
//  LynnHandlerExtensions.swift
//
//
//  Created by Loyi Hsu on 2022/9/15.
//

import Lynn

public extension LynnHandler {
    convenience init(
        core: Core = URLSessionNetworkCore(),
        storageManager: LynnStorageManager? = nil,
        maxRetries: Int = 3,
        responseMode: ResponseMode = .normal,
        watches: [LynnWatch] = []
    ) {
        self.init(
            networkCore: core,
            storageManager: storageManager,
            maxRetries: maxRetries,
            responseMode: responseMode,
            watches: watches
        )
    }
}
