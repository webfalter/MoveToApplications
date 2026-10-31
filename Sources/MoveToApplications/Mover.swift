//
//  Mover.swift
//  MoveToApplications
//
//  Created by Torsten Hofmann.
//  Copyright © 2025–2026 Torsten Hofmann. MIT License.
//

import AppKit

enum Mover {

    // MARK: - Dialog

    @MainActor
    static func promptAndMove() -> Bool {
        let alert = NSAlert()
        alert.messageText = Texts.string("MOVE_APP_TITLE")
        alert.informativeText = Texts.string("MOVE_APP_MESSAGE")
        alert.alertStyle = .informational
        alert.icon = NSApp.applicationIconImage
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = Texts.string("MOVE_APP_SUPPRESS")
        // Erster Button = Standard (Return)
        alert.addButton(withTitle: Texts.string("MOVE_APP_CONFIRM"))
        alert.addButton(withTitle: Texts.string("MOVE_APP_SKIP"))

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()

        if alert.suppressionButton?.state == .on {
            UserDefaults.standard.set(true, forKey: MoveToApplications.suppressKey)
        }
        guard response == .alertFirstButtonReturn else { return false }

        if move() { return true }

        let failure = NSAlert()
        failure.messageText = Texts.string("MOVE_APP_ERROR_TITLE")
        failure.informativeText = Texts.string("MOVE_APP_ERROR_MESSAGE")
        failure.alertStyle = .warning
        failure.runModal()
        return false
    }

    // MARK: - Verschieben

    /// Kopiert die App nach /Programme (bei Bedarf mit Administratorrechten, sonst ~/Programme),
    /// legt das Original in den Papierkorb und startet die App aus dem neuen Ort.
    @MainActor
    static func move() -> Bool {
        let fm = FileManager.default
        let running = Bundle.main.bundleURL
        // Bei App Translocation läuft die App aus einem zufälligen, schreibgeschützten Ordner –
        // der eigentliche Speicherort (z. B. ~/Downloads) wird hier ermittelt.
        let original = Translocation.originalURL(for: running)
        let appName = original.lastPathComponent

        var destination = URL(fileURLWithPath: "/Applications").appendingPathComponent(appName)
        var copied: Bool
        if fm.isWritableFile(atPath: "/Applications") {
            copied = copyAsUser(from: running, to: destination)
        } else {
            copied = copyAsAdmin(from: running, to: destination)
        }

        if !copied {
            let userApps = fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications")
            try? fm.createDirectory(at: userApps, withIntermediateDirectories: true)
            destination = userApps.appendingPathComponent(appName)
            copied = copyAsUser(from: running, to: destination)
        }
        guard copied else { return false }

        removeQuarantine(at: destination)

        // Original wegräumen – nicht bei schreibgeschützten Orten (z. B. Disk-Image)
        if Paths.standardized(original) != Paths.standardized(destination), !isOnReadOnlyVolume(original) {
            try? fm.trashItem(at: original, resultingItemURL: nil)
        }

        relaunch(at: destination)
        return true
    }

    private static func copyAsUser(from source: URL, to destination: URL) -> Bool {
        let fm = FileManager.default
        terminateRunningCopy(at: destination)
        if fm.fileExists(atPath: destination.path) {
            // vorhandene Version in den Papierkorb statt endgültig löschen
            do {
                try fm.trashItem(at: destination, resultingItemURL: nil)
            } catch {
                NSLog("MoveToApplications: Vorhandene App konnte nicht entfernt werden: \(error)")
                return false
            }
        }
        do {
            try fm.copyItem(at: source, to: destination)
            return true
        } catch {
            NSLog("MoveToApplications: Kopieren fehlgeschlagen: \(error)")
            return false
        }
    }

    /// Für Standardbenutzer ohne Schreibrecht auf /Programme.
    @MainActor
    private static func copyAsAdmin(from source: URL, to destination: URL) -> Bool {
        terminateRunningCopy(at: destination)
        let src = Shell.quote(source.path)
        let dst = Shell.quote(destination.path)
        // Ausgaben nach /dev/null, sonst kann `do shell script` hängen bleiben
        let command = "{ /bin/rm -rf \(dst) && /usr/bin/ditto \(src) \(dst); "
            + "/usr/bin/xattr -d -r com.apple.quarantine \(dst); } </dev/null >/dev/null 2>&1; "
            + "/bin/test -d \(dst)"
        return Shell.runAsAdministrator(command)
    }

    private static func removeQuarantine(at url: URL) {
        _ = Shell.run("/usr/bin/xattr", ["-d", "-r", "com.apple.quarantine", url.path])
    }

    private static func isOnReadOnlyVolume(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.volumeIsReadOnlyKey]))?.volumeIsReadOnly ?? false
    }

    /// Läuft am Ziel bereits eine ältere Kopie, wird sie vorher beendet.
    private static func terminateRunningCopy(at destination: URL) {
        let me = ProcessInfo.processInfo.processIdentifier
        let target = Paths.standardized(destination)
        for app in NSWorkspace.shared.runningApplications
        where app.processIdentifier != me && app.bundleURL.map(Paths.standardized) == target {
            app.terminate()
            for _ in 0..<30 where !app.isTerminated {
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }

    /// Startet die App aus dem neuen Ort, sobald die laufende Instanz beendet ist.
    @MainActor
    private static func relaunch(at destination: URL) {
        let pid = ProcessInfo.processInfo.processIdentifier
        let script = "while /bin/kill -0 \(pid) >/dev/null 2>&1; do /bin/sleep 0.2; done; "
            + "/usr/bin/open \(Shell.quote(destination.path))"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", script]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try? process.run()
        NSApp.terminate(nil)
    }
}

// MARK: - Hilfsfunktionen

enum Paths {
    static func standardized(_ url: URL) -> String {
        url.resolvingSymlinksInPath().standardizedFileURL.path
    }

    /// Exakter Ordnervergleich – "/ApplicationsAlt" zählt nicht als "/Applications".
    static func isInApplicationsFolder(_ path: String, home: String = NSHomeDirectory()) -> Bool {
        let folders = ["/Applications", home + "/Applications"]
        return folders.contains { folder in path == folder || path.hasPrefix(folder + "/") }
    }
}

enum Shell {
    static func quote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    @discardableResult
    static func run(_ executable: String, _ arguments: [String]) -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus
        } catch {
            return -1
        }
    }

    @MainActor
    static func runAsAdministrator(_ command: String) -> Bool {
        let escaped = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        guard let script = NSAppleScript(source: "do shell script \"\(escaped)\" with administrator privileges") else {
            return false
        }
        var error: NSDictionary?
        _ = script.executeAndReturnError(&error)
        return error == nil
    }
}
