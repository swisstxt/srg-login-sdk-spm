# SRG Login SDK — Swift Package Manager

## Integration

### Xcode

File → Add Package Dependencies → enter this repository URL:
```
https://github.com/swisstxt/srg-login-sdk-spm
```

Select **Up to Next Major Version** for stable releases, or **Exact Version** for pre-releases (beta/RC).

### Package.swift — stable release

```swift
dependencies: [
    .package(
        url: "https://github.com/swisstxt/srg-login-sdk-spm",
        from: "1.0.0"
    )
]
```

### Package.swift — pre-release (beta / RC)

```swift
dependencies: [
    .package(
        url: "https://github.com/swisstxt/srg-login-sdk-spm",
        exact: "1.0.0-beta.6"
    )
]
```

Then add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "SRGLoginSDK", package: "srg-login-sdk-spm")
    ]
)
```

---

## Releases

All releases and changelogs are on the [Releases page](https://github.com/swisstxt/srg-login-sdk-spm/releases).

---

## Questions

Slack: **#srg-mobile-sdk**

For SDK developers and contributors, see the [main repository](https://github.com/swisstxt/srg-login-mobile-sdk).