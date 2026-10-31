//
//  AppDelegate.swift
//  MoveToApplications – Beispiel
//
//  Created by Torsten Hofmann.
//  Copyright © 2025–2026 Torsten Hofmann. MIT License.
//

import Cocoa
import MoveToApplications

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        #if !DEBUG
        MoveToApplications.checkAndPrompt()
        #endif
    }
}
