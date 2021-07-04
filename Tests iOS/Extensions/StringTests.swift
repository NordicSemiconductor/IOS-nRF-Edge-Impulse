//
//  StringTests.swift
//  Tests iOS
//
//  Created by Nick Kibysh on 04/07/2021.
//

import XCTest

@testable import nRF_Edge_Impulse

class StringTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDateConversion() {
        XCTAssertNotNil("".toDate())
        
    }

}
