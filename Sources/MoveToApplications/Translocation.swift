//
//  Translocation.swift
//  MoveToApplications
//
//  Created by Torsten Hofmann.
//  Copyright © 2025–2026 Torsten Hofmann. MIT License.
//

import Foundation

/// App Translocation: macOS startet heruntergeladene, noch nicht verschobene Apps aus einem
/// zufälligen, schreibgeschützten Ordner. Hier wird der echte Speicherort ermittelt.
/// Die Funktionen sind nicht öffentlich dokumentiert und werden daher dynamisch geladen –
/// fehlen sie, wird einfach die übergebene URL verwendet.
enum Translocation {
    private typealias IsTranslocatedFunction = @convention(c) (
        CFURL, UnsafeMutablePointer<Bool>, UnsafeMutablePointer<Unmanaged<CFError>?>?
    ) -> UInt8

    private typealias OriginalPathFunction = @convention(c) (
        CFURL, UnsafeMutablePointer<Unmanaged<CFError>?>?
    ) -> Unmanaged<CFURL>?

    static func originalURL(for url: URL) -> URL {
        guard let handle = dlopen("/System/Library/Frameworks/Security.framework/Security", RTLD_LAZY) else {
            return url
        }
        defer { dlclose(handle) }

        guard let isSymbol = dlsym(handle, "SecTranslocateIsTranslocatedURL"),
              let originalSymbol = dlsym(handle, "SecTranslocateCreateOriginalPathForURL") else {
            return url
        }
        let isTranslocated = unsafeBitCast(isSymbol, to: IsTranslocatedFunction.self)
        let originalPath = unsafeBitCast(originalSymbol, to: OriginalPathFunction.self)

        var translocated = false
        guard isTranslocated(url as CFURL, &translocated, nil) != 0, translocated,
              let original = originalPath(url as CFURL, nil)?.takeRetainedValue() else {
            return url
        }
        return original as URL
    }
}
