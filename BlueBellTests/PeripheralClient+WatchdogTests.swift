//
//  PeripheralClient+WatchdogTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 07.09.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import BlueBell

class PeripheralClient_WatchdogTests: XCTestCase {
    
    // MARK: - Init
    
    func testInit_assignsProperties() {
        let exp      = expectation(description: "")
        let timeout  = 13.45
        let barrier  = { exp.fulfill() }
        let watchdog = PeripheralClient.Watchdog(barrier: barrier, timeout: timeout)
        watchdog.barrier()
        XCTAssertEqual(watchdog.timeout, timeout)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK; - CarryOn
    
    func testCarryOn_invokesBlockAfterDelay() {
        let exp      = expectation(description: "")
        let watchdog = PeripheralClient.Watchdog(barrier: { exp.fulfill() }, timeout: 0.1)
        watchdog.carryOn()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCarryOn_stopsPreviousBlockAndInvokesNewOneAfterDelay() {
        let exp      = expectation(description: "")
        var counter  = 0
        let watchdog = PeripheralClient.Watchdog(barrier: { counter += 1; exp.fulfill() }, timeout: 0.1)
        watchdog.carryOn()
        watchdog.carryOn()
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(counter, 1)
        }
    }
    
    // MARK: - Stop
    
    func testStop() {
        var counter: Int = 0
        let exp = expectation(description: "")
        let watchdog = PeripheralClient.Watchdog(barrier: { counter += 1 }, timeout: 0.1)
        watchdog.carryOn()
        watchdog.stop()
        exp.fulfill()
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(counter, 0)
        }
    }
    
}
