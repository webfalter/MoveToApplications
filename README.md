# MoveToApplications

Ein Swift-Package für macOS, das eine App automatisch in den Programme-Ordner verschieben kann.

## Installation

Mit Swift Package Manager:
```swift
.package(url: "https://github.com/webfalter/MoveToApplications.git", from: "1.0.0")
```

## Nutzung

```swift
import MoveToApplications

MoveToApplications.checkAndPrompt()
```

## async/await Variante

```swift
Task {
    await MoveToApplications.checkAndPromptAsync()
}
```

