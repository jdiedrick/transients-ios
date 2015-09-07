//
//  TZGeoSoundTests.swift
//  transients
//
//  Created by Johann Diedrick on 9/7/15.
//  Copyright (c) 2015 Johann Diedrick. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import transients


class TZGeoSoundTests : XCTestCase{

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let geoSound : TZGeoSound = TZGeoSound()
        
        let testFileURL : NSURL = NSURL(fileURLWithPath: "http://www.fileurl.com/sound.mp3")!
        
        
        geoSound.fileURL = testFileURL
        
        XCTAssertEqual(geoSound.fileURL!, testFileURL)
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
