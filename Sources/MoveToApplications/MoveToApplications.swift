import AppKit

public enum MoveToApplications {
    
    @discardableResult
    public static func checkAndPrompt() -> Bool {
        guard shouldMove() else { return false }
        return promptUserAndMove()
    }

    public static func checkAndPromptAsync() async -> Bool {
        guard shouldMove() else { return false }
        return await promptUserAndMoveAsync()
    }
}

extension MoveToApplications {

    private static func shouldMove() -> Bool {
        let bundlePath = Bundle.main.bundlePath

        let appPaths = [
            "/Applications",
            FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Applications").path
        ]

        if appPaths.contains(where: { bundlePath.hasPrefix($0) }) {
            return false
        }

        if UserDefaults.standard.bool(forKey: "MoveToAppsSuppress") {
            return false
        }

        return true
    }

    private static func promptUserAndMove() -> Bool {
        let alert = NSAlert()
        alert.messageText = "In Programme verschieben?"
        alert.informativeText = "Ich kann mich automatisch in den Programme-Ordner verschieben."
        alert.alertStyle = .informational
        alert.showsSuppressionButton = true

        alert.addButton(withTitle: "Nicht verschieben")
        alert.addButton(withTitle: "Verschieben")

        let response = alert.runModal()

        if let sup = alert.suppressionButton, sup.state == .on {
            UserDefaults.standard.set(true, forKey: "MoveToAppsSuppress")
        }

        guard response == .alertSecondButtonReturn else { return false }

        return moveApp()
    }

    private static func promptUserAndMoveAsync() async -> Bool {
        await withCheckedContinuation { cont in
            DispatchQueue.main.async {
                let result = promptUserAndMove()
                cont.resume(returning: result)
            }
        }
    }

    private static func moveApp() -> Bool {
        let fm = FileManager.default
        let source = Bundle.main.bundlePath
        let appName = (source as NSString).lastPathComponent

        let targets = [
            "/Applications",
            fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications").path
        ]

        var destination: String?
        for t in targets {
            if fm.isWritableFile(atPath: t) {
                destination = (t as NSString).appendingPathComponent(appName)
                break
            }
        }

        guard let dest = destination else { return false }

        try? fm.removeItem(atPath: dest)

        do {
            try fm.copyItem(atPath: source, toPath: dest)
        } catch {
            print("Copy error:", error)
            return false
        }

        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [dest]
        task.launch()

        exit(0)
    }
}
