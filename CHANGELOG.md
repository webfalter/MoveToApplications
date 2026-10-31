# Changelog

## 1.1.0

### Neu
- Echtes Verschieben: Original wird nach dem Kopieren in den Papierkorb gelegt
- Unterstützung für Standardbenutzer (Administratorpasswort für `/Programme`, sonst `~/Programme`)
- Erkennung von App Translocation (echter Speicherort heruntergeladener Apps)
- Schreibgeschützte Volumes (Disk-Images) werden erkannt, das Original bleibt erhalten
- Quarantäne-Attribut wird am Ziel entfernt
- Eingebaute deutsche und englische Texte mit App-Namen; eigene Texte über `Localizable.strings` weiterhin möglich
- Neue Schlüssel `MOVE_APP_SUPPRESS`, `MOVE_APP_ERROR_TITLE`, `MOVE_APP_ERROR_MESSAGE`
- `isInApplicationsFolder` und `resetSuppression()`
- Fehlermeldung, wenn das Verschieben scheitert
- Echte Unit-Tests

### Geändert
- Vorhandene App am Ziel wird in den Papierkorb gelegt statt endgültig gelöscht; eine laufende Kopie wird vorher beendet
- Neustart über `NSApp.terminate` statt `exit(0)` – die App kann sauber aufräumen
- „Verschieben“ ist jetzt der Standard-Button
- Exakte Ordnerprüfung (`/ApplicationsAlt` gilt nicht mehr als Programme-Ordner)
- Kein Dialog außerhalb von `.app`-Bundles (z. B. `swift run`, Tests)
- `Process.launchPath`/`launch()` durch `executableURL`/`run()` ersetzt
- API ist `@MainActor`

## 1.0.2
- Lokalisierte Dialogtexte

## 1.0.0
- Erste Version
