//
//  Texts.swift
//  MoveToApplications
//
//  Created by Torsten Hofmann.
//  Copyright © 2025–2026 Torsten Hofmann. MIT License.
//

import Foundation

/// Dialogtexte: zuerst aus der Localizable.strings der App (zum Anpassen),
/// sonst eingebaute deutsche bzw. englische Standardtexte. `%@` wird durch den App-Namen ersetzt.
///
/// Absichtlich ohne Ressourcen-Bundle (`Bundle.module`), damit das Package in jeder
/// App-Konfiguration funktioniert – auch ohne mitkopiertes Ressourcenpaket.
enum Texts {
    static let builtIn: [String: [String: String]] = [
        "de": [
            "MOVE_APP_TITLE": "%@ in den Programme-Ordner verschieben?",
            "MOVE_APP_MESSAGE": "%@ läuft gerade nicht aus dem Programme-Ordner. Soll die App dorthin verschoben werden? Das Original wird dabei in den Papierkorb gelegt.",
            "MOVE_APP_CONFIRM": "In „Programme“ verschieben",
            "MOVE_APP_SKIP": "Nicht verschieben",
            "MOVE_APP_SUPPRESS": "Nicht mehr fragen",
            "MOVE_APP_ERROR_TITLE": "%@ konnte nicht verschoben werden",
            "MOVE_APP_ERROR_MESSAGE": "Bitte ziehe die App im Finder manuell in den Programme-Ordner."
        ],
        "en": [
            "MOVE_APP_TITLE": "Move %@ to the Applications folder?",
            "MOVE_APP_MESSAGE": "%@ is not running from the Applications folder. Would you like to move it there? The original will be moved to the Trash.",
            "MOVE_APP_CONFIRM": "Move to Applications",
            "MOVE_APP_SKIP": "Don't Move",
            "MOVE_APP_SUPPRESS": "Don't ask again",
            "MOVE_APP_ERROR_TITLE": "%@ could not be moved",
            "MOVE_APP_ERROR_MESSAGE": "Please drag the app into the Applications folder in Finder."
        ]
    ]

    static func string(_ key: String, bundle: Bundle = .main, languages: [String] = Locale.preferredLanguages) -> String {
        let missing = "\u{1}__missing__"
        let appText = bundle.localizedString(forKey: key, value: missing, table: nil)
        let template = appText != missing ? appText : builtInText(key, languages: languages)
        return template.replacingOccurrences(of: "%@", with: appName(bundle))
    }

    static func builtInText(_ key: String, languages: [String]) -> String {
        let language = languages.first.map { $0.hasPrefix("de") ? "de" : "en" } ?? "en"
        return builtIn[language]?[key] ?? builtIn["en"]?[key] ?? key
    }

    static func appName(_ bundle: Bundle) -> String {
        bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? ProcessInfo.processInfo.processName
    }
}
