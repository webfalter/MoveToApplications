//
//  MoveToApplications.swift
//  MoveToApplications
//
//  Created by Torsten Hofmann.
//  Copyright © 2025–2026 Torsten Hofmann. MIT License.
//

import AppKit

/// Bietet beim Start an, die App in den Programme-Ordner zu verschieben.
///
/// ```swift
/// func applicationDidFinishLaunching(_ notification: Notification) {
///     MoveToApplications.checkAndPrompt()
/// }
/// ```
public enum MoveToApplications {

    /// UserDefaults-Schlüssel für „Nicht mehr fragen“.
    public static let suppressKey = "MoveToAppsSuppress"

    /// Prüft, ob die App außerhalb des Programme-Ordners läuft, fragt nach und verschiebt sie.
    ///
    /// Nach erfolgreichem Verschieben wird die App aus dem Programme-Ordner neu gestartet
    /// und die laufende Instanz beendet.
    /// - Returns: `true`, wenn verschoben wurde (die App beendet sich dann gleich), sonst `false`.
    @MainActor
    @discardableResult
    public static func checkAndPrompt() -> Bool {
        guard shouldOfferMove else { return false }
        return Mover.promptAndMove()
    }

    /// async-Variante von ``checkAndPrompt()``.
    @MainActor
    @discardableResult
    public static func checkAndPromptAsync() async -> Bool {
        checkAndPrompt()
    }

    /// `true`, wenn die App bereits aus /Programme oder ~/Programme läuft.
    public static var isInApplicationsFolder: Bool {
        Paths.isInApplicationsFolder(Translocation.originalURL(for: Bundle.main.bundleURL).path)
    }

    /// Setzt „Nicht mehr fragen“ zurück, z. B. für einen Menüpunkt in den Einstellungen.
    public static func resetSuppression() {
        UserDefaults.standard.removeObject(forKey: suppressKey)
    }

    /// Ob beim Start gefragt werden soll.
    static var shouldOfferMove: Bool {
        // Nur echte App-Bundles – nicht bei `swift run` oder Tests.
        guard Bundle.main.bundleURL.pathExtension == "app" else { return false }
        guard !UserDefaults.standard.bool(forKey: suppressKey) else { return false }
        return !isInApplicationsFolder
    }
}
