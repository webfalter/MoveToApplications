# MoveToApplications
[![download-badge](https://img.shields.io/github/downloads/webfalter/MoveToApplications/total.svg?style=flat-square "Download status")](https://github.com/webfalter/MoveToApplications/releases/latest "Download status")

Ein Swift-Package für macOS, das beim Start anbietet, die App in den Programme-Ordner zu verschieben – mit einem einzigen Aufruf.

## Funktionen

- **Echtes Verschieben:** Kopie nach `/Programme`, Original in den Papierkorb, Neustart aus dem neuen Ort
- **Standardbenutzer:** Fehlt das Schreibrecht auf `/Programme`, fragt macOS nach dem Administratorpasswort; bei Abbruch wird `~/Programme` verwendet
- **App Translocation:** Erkennt heruntergeladene Apps, die macOS aus einem zufälligen Ordner startet, und verwendet den echten Speicherort
- **Disk-Images:** Läuft die App von einem schreibgeschützten Volume (z. B. DMG), bleibt das Original unangetastet
- **Sicher:** Eine vorhandene Version wird in den Papierkorb gelegt statt gelöscht; läuft sie noch, wird sie vorher beendet
- **Quarantäne-Attribut** wird entfernt, damit macOS die App am neuen Ort nicht erneut isoliert
- **„Nicht mehr fragen“** mit Möglichkeit zum Zurücksetzen
- **Eingebaute Texte** auf Deutsch und Englisch mit dem Namen der App – eigene Texte optional
- Fragt nur in echten `.app`-Bundles, nicht bei `swift run` oder in Tests

## Installation

Mit Swift Package Manager:
```swift
.package(url: "https://github.com/webfalter/MoveToApplications.git", from: "1.1.0")
```

## Nutzung

```swift
import MoveToApplications

func applicationDidFinishLaunching(_ notification: Notification) {
    MoveToApplications.checkAndPrompt()
}
```

Mit SwiftUI über einen App-Delegate:
```swift
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if !DEBUG
        MoveToApplications.checkAndPrompt()
        #endif
    }
}

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    var body: some Scene { WindowGroup { ContentView() } }
}
```

### async/await

```swift
Task { await MoveToApplications.checkAndPromptAsync() }
```

### Weitere API

```swift
MoveToApplications.isInApplicationsFolder   // läuft die App schon aus /Programme?
MoveToApplications.resetSuppression()       // „Nicht mehr fragen“ zurücksetzen
```

## Eigene Texte

Die eingebauten Texte genügen meist. Zum Anpassen in der `Localizable.strings` der App die gewünschten Schlüssel setzen; `%@` wird durch den App-Namen ersetzt:

```
"MOVE_APP_TITLE" = "%@ in den Programme-Ordner verschieben?";
"MOVE_APP_MESSAGE" = "…";
"MOVE_APP_CONFIRM" = "In „Programme“ verschieben";
"MOVE_APP_SKIP" = "Nicht verschieben";
"MOVE_APP_SUPPRESS" = "Nicht mehr fragen";
"MOVE_APP_ERROR_TITLE" = "%@ konnte nicht verschoben werden";
"MOVE_APP_ERROR_MESSAGE" = "…";
```

## Hinweise

- Für Apps außerhalb des Mac App Store (nicht sandboxed).
- Nach dem Verschieben beendet sich die App über `NSApp.terminate` und startet aus dem neuen Ort. Lehnt die App das Beenden ab (`applicationShouldTerminate`), erfolgt kein Neustart.

## Lizenz

MIT – siehe [LICENSE](LICENSE).
