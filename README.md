# SRG Login SDK — Apple Distribution

![Latest Version](https://img.shields.io/github/v/tag/swisstxt/srg-login-sdk-distribution-apple?label=latest&color=blue)

## Integration

### Xcode

File → Add Package Dependencies → enter this repository URL:
```
https://github.com/swisstxt/srg-login-sdk-distribution-apple
```

Select **Up to Next Major Version** for stable releases, or **Exact Version** for pre-releases (beta/RC).

### Package.swift — stable release

```swift
dependencies: [
    .package(
        url: "https://github.com/swisstxt/srg-login-sdk-distribution-apple",
        from: "1.0.0"
    )
]
```

### Package.swift — pre-release (beta / RC)

```swift
dependencies: [
    .package(
        url: "https://github.com/swisstxt/srg-login-sdk-distribution-apple",
        exact: "1.0.0-beta.6"
    )
]
```

Then add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "SRGLoginSDK", package: "SRGLoginSDK")
    ]
)
```

---

## Quickstart

### Requirements

- Xcode 15+
- iOS 15.0+ deployment target
- Swift 5.9+

### Initialize the SDK

Call `SrgLoginSdk.shared.initialize()` once at app startup — before any login or token operations.

```swift
import SRGLoginCore

// Minimal — uses default token storage config
SrgLoginSdk.shared.initialize()

// Or enable verbose SDK logging in debug builds
SrgLoginSdk.shared.initialize(isDebugBuild: true)

// Or customise token storage keys to avoid collisions with other SDK instances
SrgLoginSdk.shared.initialize(
    tokenStorageConfig: TokenStorageConfig(
        keystoreAlias: "your_app_token_key",
        fileName: "your_app_tokens"
    )
)
```

### Create an SrgLogin instance

Use `environment` to select the OIDC endpoints: `.dev`, `.int`, or `.prod`.

#### AppIdentity

> **`appId`, `appName`, and `appVersion` must be resolved dynamically at runtime — never hardcode these values.**

`businessUnit` and `businessUnitName` must use exact values from the table below. These values are used as Sentry filters to categorize and route error reports — incorrect or custom values will break Sentry dashboards and alerting.

| `businessUnit` | `businessUnitName` |
| --- | --- |
| `"SRF"` | `"Schweizer Radio und Fernsehen"` |
| `"RTS"` | `"Radio Télévision Suisse"` |
| `"RSI"` | `"Radiotelevisione svizzera di lingua italiana"` |
| `"RTR"` | `"Radiotelevisiun Svizra Rumantscha"` |
| `"SWI"` | `"SWI swissinfo.ch"` |
| `"SWISSTXT"` | `"SWISS TXT"` |
| `"SRG"` | `"SRG SSR"` |

```swift
import SRGLoginCore

let config = SrgLoginConfig(
    clientId: "your-oauth-client-id",
    redirectUri: "your-app-scheme://loginSuccess",
    appIdentity: AppIdentity(
        appId: Bundle.main.bundleIdentifier ?? "",
        appName: Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "",
        appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
        businessUnit: "SRF",
        businessUnitName: "Schweizer Radio und Fernsehen"
    ),
    postLogoutRedirectUri: "your-app-scheme://logoutSuccess",
    environment: .prod
)

let srgLogin = SrgLoginSdk.shared.create(config: config)
```

### Login

Logging in requires an `iOSAuthContext` that provides a presentation anchor for `ASWebAuthenticationSession`.

```swift
import SRGLoginCore
import AuthenticationServices

class AuthContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

let authContext = iOSAuthContext(presentationContextProvider: authContextProvider)
let result = try await srgLogin.login(credentials: Credentials.Web(authContext: authContext))

if let success = result as? SdkResultSuccess<TokenSet>, let tokenSet = success.data {
    // User is authenticated — store or use tokenSet as needed
}

if let failure = result as? SdkResultFailure {
    print(failure.error)
}
```

### Observe token state

The SDK exposes a `StateFlow<TokenState>` wrapped by SKIE as a native Swift `AsyncSequence`:

```swift
import SRGLoginCore

let tokenStateFlow = SkieSwiftStateFlow<TokenState>(srgLogin.observeTokenState())

for await state in tokenStateFlow {
    guard !Task.isCancelled else { break }
    // state is one of: Valid, ExpiringSoon, Refreshed, Expired, NoToken, Error
    print("Token state: \(state)")
}
```

### Check authentication state and get the access token

```swift
// Check if the user is currently authenticated
let isAuthenticated = (try? await srgLogin.isAuthenticated())?.boolValue ?? false

// Get the current access token (always fetch at call time — the SDK refreshes it automatically)
let result = try await srgLogin.getAccessToken()

if let success = result as? SdkResultSuccess<AccessToken>, let token = success.data {
    let authHeader = "Bearer \(token.value)"
}

if let failure = result as? SdkResultFailure {
    print(failure.error)
}
```

> Always call `getAccessToken()` at the point of use rather than caching the value. The SDK transparently refreshes the token when it is near expiry.

### Logout

**Front-channel logout** — clears the server session and local tokens:

```swift
let authContext = iOSAuthContext(presentationContextProvider: authContextProvider)
let frontChannel = LogoutType.FrontChannel()
try await srgLogin.logout(logoutType: frontChannel, authContext: authContext)
```

**Local-only logout** — clears local tokens only, without contacting the server:

```swift
try await srgLogin.logout(method: LogoutMethod.LocalOnly())
```

### SSO — open a URL with the user's active session

`openSsoClient` opens any URL in an `ASWebAuthenticationSession` with the user's IDP session cookie already injected:

```swift
let authContext = iOSAuthContext(presentationContextProvider: authContextProvider)

_ = try? await srgLogin.openSsoClient(
    ssoClientUrl: "https://settings.srgssr.ch/profile?prompt=none",
    authContext: authContext
)
```

### Reconfiguration

To switch environments or update the OAuth config at runtime:

```swift
SrgLoginSdk.shared.shutdown()
// Then call initialize(...) and create(config:) again with the new config
```

> Always cancel any active `observeTokenState()` loop before calling `shutdown()`.

---

## Sample app

The [srg-login-sdk-sample-ios](https://github.com/swisstxt/srg-login-sdk-sample-ios) repository contains a fully working SwiftUI reference app demonstrating all SDK features across three tabs (Auth, Token Management, Settings).

---

## Releases

All releases and changelogs are on the [Releases page](https://github.com/swisstxt/srg-login-sdk-distribution-apple/releases).

---

## Questions

Teams: [SRG-Login SDK](https://teams.microsoft.com/l/channel/19%3A77f7201d0aa44ccfb8f2e856c47c7cae%40thread.skype/SRG-Login%20SDK?groupId=4c35f1b2-811c-40ef-aa8e-01eede3277f2&tenantId=2598639a-d083-492d-bdbe-f1dd8066b03a)

For SDK developers and contributors, see the [main repository](https://github.com/swisstxt/srg-login-mobile-sdk).