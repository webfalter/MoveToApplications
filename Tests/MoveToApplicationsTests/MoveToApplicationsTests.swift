//
//  MoveToApplicationsTests.swift
//  MoveToApplications
//
//  Created by Torsten Hofmann.
//  Copyright © 2025–2026 Torsten Hofmann. MIT License.
//

import XCTest
@testable import MoveToApplications

final class MoveToApplicationsTests: XCTestCase {

    func testApplicationsFolderIsDetected() {
        XCTAssertTrue(Paths.isInApplicationsFolder("/Applications/Foo.app", home: "/Users/test"))
        XCTAssertTrue(Paths.isInApplicationsFolder("/Applications/Tools/Foo.app", home: "/Users/test"))
        XCTAssertTrue(Paths.isInApplicationsFolder("/Users/test/Applications/Foo.app", home: "/Users/test"))
    }

    func testOtherFoldersAreNotApplications() {
        XCTAssertFalse(Paths.isInApplicationsFolder("/Users/test/Downloads/Foo.app", home: "/Users/test"))
        XCTAssertFalse(Paths.isInApplicationsFolder("/ApplicationsOld/Foo.app", home: "/Users/test"))
        XCTAssertFalse(Paths.isInApplicationsFolder("/Volumes/Foo/Foo.app", home: "/Users/test"))
    }

    func testBuiltInTextsExistForAllKeys() {
        let keys = Texts.builtIn["en"]!.keys
        for language in ["de", "en"] {
            for key in keys {
                XCTAssertNotNil(Texts.builtIn[language]?[key], "\(language): \(key) fehlt")
            }
        }
    }

    func testBuiltInTextLanguageSelection() {
        XCTAssertEqual(Texts.builtInText("MOVE_APP_SKIP", languages: ["de-DE"]), "Nicht verschieben")
        XCTAssertEqual(Texts.builtInText("MOVE_APP_SKIP", languages: ["fr-FR"]), "Don't Move")
        XCTAssertEqual(Texts.builtInText("UNKNOWN_KEY", languages: ["de"]), "UNKNOWN_KEY")
    }

    func testTranslocationReturnsSameURLWhenNotTranslocated() {
        let url = URL(fileURLWithPath: "/Applications/Safari.app")
        XCTAssertEqual(Translocation.originalURL(for: url), url)
    }

    func testShouldNotOfferMoveOutsideAppBundle() {
        // Tests laufen nicht aus einem .app-Bundle
        XCTAssertFalse(MoveToApplications.shouldOfferMove)
    }

    func testQuoteEscapesSingleQuotes() {
        XCTAssertEqual(Shell.quote("/Apps/It's.app"), "'/Apps/It'\\''s.app'")
    }
}
