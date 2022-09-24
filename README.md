# Lynn

![Overview](https://i.imgur.com/zlB49UL.png)

Lynn is a [Moya][1]-inspired flexible network abstraction layer. With the core and storage manager protocol, it can be based on any network packages and storage technology.

Default implementations of core using `URLSession` and storage manager using `UserDefaults` are provided.

## Basic Usage

### Installation

You can install it through SPM:

```swift=
.package(url: "https://github.com/loyihsu/Lynn", branch: "main"),
```

### `TargetGroup`

Network requests are grouped into a Moya-styled `TargetGroup`. A normal implementation of would be using an `enum`. 

```swift
enum SomeTargetGroup {
    case someCase(someParameter: Int, anotherParameter: Int)
    case anotherCase(someMessage: String)
}

extension SomeTargetGroup: TargetGroup {
    var baseURL: String {
        // base URL goes here, ex. 'http://example.com'
    }

    var path: String {
        // path goes here, ex. 'some/case'
    }

    var task: LynnTask {
        // map your task into a LynnTask, for example:
        switch self {
        case let .someCase(someParameter, anotherParameter):
            return LynnTask(
                method: .get,
                parameters: [
                    "someParameter": someParameter,
                    "anotherParameter": anotherParameter
                ]
            )
        case let .anotherCase(someMessage):
            return LynnTask(
                method: .post,
                body: HTTPBody(
                    content: ["someMessage": someMessage],
                    mode: .json
                )
            )
        }
    }

    var headers: [String: String]? {
        // Provide any header if needed; otherwise, just return `nil`.
    }

    var storageKey: String {
        // This is the storage key used if you are using the cache system. Ex. 'someCase'
    }

    var sampleData: Data? {
        // Provide any sample data if you want to use the `.sample` response mode.
    }
}
```

## `LynnHandler`

A `LynnHandler` takes a `LynnCore` and a `LynnStorageManager` (if caching is needed). You can either use the `LynnURLSession` implementation of `Core`, or make your own `LynnCore`. Using `LynnURLSession`:

```swift
import Lynn
import LynnURLSession
let networkHandler = LynnHandler()
```

If you want to use the cache system, provide a storage manager here:

```swift
import Lynn
import LynnURLSession
import LynnUserDefaultsStorageManager
let networkHandler = LynnHandler(
    storageManager: UserDefaultsItemStroageManager()
)
```

To use any custom core or storage manager, implement the `LynnCore` or `LynnStorageManager` protocols and provide them to the initialiser.

```swift
import Lynn
let networkHandler = LynnHandler(
    networkCore: MyLynnCore(),
    storageManager: MyLynnStorageManager()
)
```

By default, the `LynnHandler` would retry up to 3 time if the request fails, you can set this number in the initialiser, too:

```swift
let networkHandler = LynnHandler(
    storageManager: UserDefaultsItemStroageManager(),
    maxRetries: 5
)
```

You can also specify the response mode here, there are multiple response modes defined:

* `.normal` would request from the cache first if a storage manager is provided and if no valid cache is found, it will request from the url specified.
* `.alwaysLive` would skip the cache and request from the live server immediately.
* `.sample` would request from the cache first if a storage manager is provided and if no valid cache is found, it will return and save the `sampleData` specified in the `TargetGroup` into the cache.

Just specify any response mode from above by:

```swift
let networkHandler = LynnHandler(
    storageManager: UserDefaultsItemStroageManager(),
    responseMode: .sample
)
```

## Sending Requests

There are four main APIs provided:

1. `request` using callback style returning data (`LynnCoreResponse`)

```swift
networkHandler.request(
    targetGroup: YourTargetGroup.target(parameter: 1),
    getValidUntil: { data in
        // return your cache invalidation time here
    },
    callback: { response in
        // do something with the data in response.body       
    },
    onError: { error in
        // do something with the error
    }
)
```

2. `request` using callback style returning `LynnCoreDecodedResponse<YourDecodableModel>`.

```swift
networkHandler.request(
    targetGroup: YourTargetGroup.target(parameter: 1),
    model: YourDecodableModel.self,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy....,
    getValidUntil: { model in
        // return your can invalidation time here
    },
    callback: { response in
        // Do something with the model in response.body
    },
    onError: { error in
        // Do something with the error
    }
)
```

3. `request` using async/await style returning `LynnCoreResponse` (macOS 10.15+, iOS 13+)

```swift
Task {
    do {
        let response = try await networkHandler
            .request(
                targetGroup: YourTargetGroup.target(parameter: 1),
                getValidUntil: { data in
                    // return your can invalidation time here
                }
            )
        // Do something with the data in response.body
    } catch {
        // Do something with the error
    }
}
```

4. `request` using async/await style returning `LynnCoreDecodedResponse<YourDecodableModel>` (macOS 10.15+, iOS 13+)

```swift
Task {
    do {
        let response = try await networkHandler
            .request(
                targetGroup: YourTargetGroup.target(parameter: 1),
                model: YourDecodableModel.self,
                keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy....,
                getValidUntil: { model in
                    // return your can invalidation time here
                }
            )
        // Do something with the model in response.body
    } catch {
        // Do something with the error
    }
}
```

## Cache

To use the cache system, add you would need to provide:

1. A storage manager instance
2. `getValidUntil` when making a request request

A storage manager can implement either one of `LynnItemStorageManager` or `LynnListStorageManager`, depending on whether you want to store an item or a list of items. Implementations for either an item or a list using `UserDefaults` are provided:

```swift
import LynnUserDefaultsStorageManager
let networkHandler = LynnHandler(
    storageManager: UserDefaultsItemStorageManager()
)
```

```swift
import LynnUserDefaultsStorageManager
let networkHandler = LynnHandler(
    storageManager: UserDefaultsListStorageManager()
)
```

## License

[MIT][2]

[1]:	https://github.com/Moya/Moya
[2]:	https://github.com/loyihsu/Lynn/blob/main/LICENSE
