//
//  PathyTest.swift
//  PathyTest
//
//  Created by Hanzhou Shi on 2/18/17.
//  Copyright © 2017 Hanzhou Shi. All rights reserved.
//

import XCTest
@testable import SwiftyFramework

class PathyTest: XCTestCase {
    
    private static let CURRENT_DIR = FileManager.default.currentDirectoryPath
    
    func testRawPath() {
        let p = Pathy("Test")
        XCTAssertEqual("Test", p.rawPath)
    }
    
    func testAbsPath() {
        let p = Pathy("Test")
        XCTAssertEqual(PathyTest.CURRENT_DIR + "/Test", p.absPath)
    }
    
    func testAbsPathAbsolute() {
        let p = Pathy("/Test")
        XCTAssertEqual("/Test", p.absPath)
    }
    
    func testPath() {
        let p = Pathy("Test")
        XCTAssertEqual("Test", p.path)
    }
    
    func testConsecutiveSlash() {
        let p = Pathy("Parent//Child")
        XCTAssertEqual("Parent/Child", p.path)
    }
    
    func testSingleDots() {
        let p = Pathy("Parent/./Child")
        XCTAssertEqual("Parent/Child", p.path)
    }
    
    func testDoubleDotsRelativePath() {
        let p = Pathy("Parent/../Child")
        XCTAssertEqual("Parent/../Child", p.path)
    }
    
    func testDoubleDotsAbsolutePath() {
        let p = Pathy("/Root/../Child")
        XCTAssertEqual("/Child", p.path)
    }
    
    func testDoubleDotsAbsolutePathExceeds() {
        let p = Pathy("/Root/../../Child")
        XCTAssertEqual("/Child", p.path)
    }
    
    func testDoubleDotsAbsolutePathExceedsOnlyRoot() {
        let p = Pathy("/Root/../../")
        XCTAssertEqual("/", p.path)
    }
    
    func testSlash() {
        let p1 = Pathy("Root/")
        let p2 = Pathy("/Child")
        let p = p1/p2
        XCTAssertEqual("Root///Child", p.rawPath)
        XCTAssertEqual("Root/Child", p.path)
    }
    
    func testSlashAbsolute() {
        let p1 = Pathy("/Root/")
        let p2 = Pathy("/Child")
        let p = p1/p2
        XCTAssertEqual("/Root///Child", p.rawPath)
        XCTAssertEqual("/Root/Child", p.path)
    }
    
}
