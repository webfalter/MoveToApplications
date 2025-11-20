import Cocoa
import MoveToApplications

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        MoveToApplications.checkAndPrompt()
    }
}
