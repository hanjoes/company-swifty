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
    
    func testPath() {
        let p = Pathy("Test")
        XCTAssertEqual("Test", p.path)
    }
    
    func testConsecutiveSlash() {
        let p = Pathy("Parent//Child")
        XCTAssertEqual("Parent/Child", p.path)
        XCTAssertEqual("Parent//Child", p.rawPath)
        XCTAssertEqual(PathyTest.CURRENT_DIR + "/Parent/Child", p.absPath)
    }
    
}
