//
//  LynnHandler.swift
//
//
//  Created by Loyi Hsu on 2022/9/15.
//

import Foundation

public class LynnHandler<Core: LynnCore> {
    // MARK: - Properties

    private let networkCore: Core
    private let storageManager: LynnStorageManager?
    private let maxRetries: Int
    private let responseMode: ResponseMode
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    // MARK: - Init

    public init(
        networkCore: Core,
        storageManager: LynnStorageManager? = nil,
        maxRetries: Int = 3,
        responseMode: ResponseMode = .normal
    ) {
        self.networkCore = networkCore
        self.storageManager = storageManager
        self.maxRetries = maxRetries
        self.responseMode = responseMode
    }

    // MARK: - APIs

    public func request<Group: TargetGroup, Model: Decodable>(
        targetGroup: Group,
        model: Model.Type,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
        getValidUntil: ((Model) -> Date)? = nil,
        callback: @escaping (LynnCoreDecodedResponse<Model>) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        if let storedData = try? cacheRoutine(targetGroup: targetGroup) {
            jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
            if let decodedModel = try? jsonDecoder.decode(model, from: storedData.body) {
                callback(
                    LynnCoreDecodedResponse(
                        statusCode: storedData.statusCode,
                        header: storedData.header,
                        body: decodedModel
                    )
                )
                return
            }
        }

        let target = targetGroup.target
        requestRoutine(
            target: target,
            callback: { [weak self] response in
                guard let self = self else { return }
                do {
                    self.jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
                    let decoded = try self.jsonDecoder.decode(model, from: response.body)
                    if let validUntil = getValidUntil?(decoded) {
                        self.storeIfNeeded(targetGroup: targetGroup, response: response, validUntil: validUntil)
                    }
                    callback(
                        LynnCoreDecodedResponse(
                            statusCode: response.statusCode,
                            header: response.header,
                            body: decoded
                        )
                    )
                } catch {
                    onError(error)
                }
            },
            onError: onError
        )
    }

    public func request<Group: TargetGroup>(
        targetGroup: Group,
        getValidUntil: ((Data) -> Date)? = nil,
        callback: @escaping (LynnCoreResponse) -> Void,
        onError: @escaping (LynnCoreError) -> Void
    ) {
        if let cached = try? cacheRoutine(targetGroup: targetGroup) {
            callback(cached)
        }

        let target = targetGroup.target
        requestRoutine(
            target: target,
            callback: { [weak self] lynnCoreData in
                if let validUntil = getValidUntil?(lynnCoreData.body) {
                    self?.storeIfNeeded(targetGroup: targetGroup, response: lynnCoreData, validUntil: validUntil)
                }
                callback(lynnCoreData)
            },
            onError: onError
        )
    }

    // MARK: - Helpers

    // MARK: Routines

    private func cacheRoutine<Group: TargetGroup>(
        targetGroup: Group
    ) throws -> LynnCoreResponse? {
        switch responseMode {
        case .alwaysLive:
            return nil
        case .normal, .sample:
            if let storedData = try fetchFromStorageIfNeeded(targetGroup: targetGroup) {
                jsonDecoder.keyDecodingStrategy = .useDefaultKeys
                let decodedData = try jsonDecoder.decode(LynnCoreResponse.self, from: storedData)
                return decodedData
            } else {
                return nil
            }
        }
    }

    private func requestRoutine(
        target: LynnTarget,
        callback: @escaping (LynnCoreResponse) -> Void,
        onError: @escaping (LynnCoreError) -> Void
    ) {
        switch responseMode {
        case .alwaysLive, .normal:
            sendRequest(
                to: target,
                callback: callback,
                onError: onError
            )
        case .sample:
            if let sampleData = target.sampleData {
                callback(
                    LynnCoreResponse(statusCode: 200, header: [:], body: sampleData)
                )
            } else {
                onError(LynnCoreError(statusCode: 404, header: [:], error: DebugError.noSampleData))
            }
        }
    }

    // MARK: Request

    private func sendRequest(
        to target: LynnTarget,
        callback: @escaping (LynnCoreResponse) -> Void,
        onError: @escaping (LynnCoreError) -> Void,
        error: LynnCoreError? = nil,
        currentRetry: Int = 0
    ) {
        guard currentRetry < maxRetries else {
            if let error = error {
                onError(error)
            }
            return
        }
        networkCore.sendRequest(
            to: target,
            callback: callback,
            onError: { error in
                self.sendRequest(
                    to: target,
                    callback: callback,
                    onError: onError,
                    error: error,
                    currentRetry: currentRetry + 1
                )
            }
        )
    }

    // MARK: Cache

    private func storeIfNeeded(targetGroup: TargetGroup, response: LynnCoreResponse, validUntil: Date) {
        guard let storageManager = storageManager,
              let encodedResponse = try? jsonEncoder.encode(response) else { return }
        let storageData = LynnStorageData(
            validUntil: validUntil,
            data: encodedResponse
        )
        storageManager.save(key: targetGroup.storageKey, value: storageData)
    }

    private func fetchFromStorageIfNeeded(targetGroup: TargetGroup) throws -> Data? {
        guard let storageManager = storageManager else { return nil }

        if let itemStorageManager = storageManager as? LynnItemStorageManager {
            let item = itemStorageManager.load(key: targetGroup.storageKey)
            return item?.isValid == true ? item?.data : nil
        }

        if let listStorageManager = storageManager as? LynnListStorageManager {
            return listStorageManager.load(key: targetGroup.storageKey)
                .filter(\.isValid)
                .first?
                .data
        }

        throw LynnCacheError.generalStorageManagerProvided
    }
}

// MARK: - Async/Await API

public extension LynnHandler {
    @available(macOS 10.15, iOS 13.0, *)
    func request<Group: TargetGroup, Model: Decodable>(
        targetGroup: Group,
        model: Model.Type,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
        getValidUntil: ((Model) -> Date)? = nil
    ) async throws -> LynnCoreDecodedResponse<Model> {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try request(
                    targetGroup: targetGroup,
                    model: model,
                    keyDecodingStrategy: keyDecodingStrategy,
                    getValidUntil: getValidUntil,
                    callback: { response in
                        continuation.resume(returning: response)
                    },
                    onError: { error in
                        continuation.resume(throwing: error)
                    }
                )
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    @available(macOS 10.15, iOS 13.0, *)
    func request<Group: TargetGroup>(
        targetGroup: Group,
        getValidUntil: ((Data) -> Date)? = nil
    ) async throws -> LynnCoreResponse {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try request(
                    targetGroup: targetGroup,
                    getValidUntil: getValidUntil,
                    callback: { data in
                        continuation.resume(returning: data)
                    },
                    onError: { error in
                        continuation.resume(throwing: error)
                    }
                )
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - Responses

public extension LynnHandler {
    enum ResponseMode {
        case alwaysLive
        case normal
        case sample
    }

    enum DebugError: LocalizedError {
        case noSampleData

        public var errorDescription: String? {
            switch self {
            case .noSampleData:
                return "No sample data provided while using .sample response mode."
            }
        }
    }
}
