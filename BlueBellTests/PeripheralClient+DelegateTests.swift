//
//  PeripheralClient+DelegateTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 30.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlueBell

class PeripheralClient_DelegateTests: XCTestCase {

    // MARK: - Properties
    
    var stubCBPeripheral: StubCBPeripheral!
    var stubCBCharacteristic: StubCBCharacteristic!
    var delegate: PeripheralClient.Delegate!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        stubCBCharacteristic = StubCBCharacteristic(stubIdentifier: CBUUID(string: "A88DFB00-03B5-440E-BFB8-CF0C8CC03316"))
        stubCBPeripheral     = StubCBPeripheral(stubIdentifier: UUID(uuidString: "13CA7CCC-6E22-42E6-B000-09D7A5299605")!)
    }
    
    // MARK: - Init
    
    func testInit_assignsProperties() {
        let updateExp = expectation(description: "UpdateValue")
        let updateBlock: Completion<CBCharacteristic> = { _ in updateExp.fulfill() }
        let writeExp = expectation(description: "WriteValue")
        let writeBlock: Completion<CBCharacteristic> = { _ in writeExp.fulfill() }
        let discExp = expectation(description: "Disconnect")
        let discBlock: ErrorCompletion = { _ in discExp.fulfill() }
        let delegate = PeripheralClient.Delegate(peripheral: stubCBPeripheral, didUpdateValue: updateBlock, didWriteValue: writeBlock, didDisconnect: discBlock)
        delegate.didUpdateValue?(stubCBCharacteristic, nil)
        delegate.didWriteValue?(stubCBCharacteristic, nil)
        delegate.didDisconnect?(nil)
        XCTAssertEqual(delegate.peripheral, stubCBPeripheral)
        XCTAssertTrue(delegate.peripheral.extendedDelegate === delegate)
        wait(for: [updateExp, writeExp, discExp], timeout: 1)
    }
    
    // MARK: - Blocks 
    
    func testUpdateValueBlock() {
        let updateExp = expectation(description: "UpdateValue")
        let nserror   = NSError(domain: "test", code: 1, userInfo: nil)
        let updateBlock: Completion<CBCharacteristic> = { characteristic, error in
            XCTAssertTrue(error! as NSError === nserror)
            XCTAssertEqual(characteristic, self.stubCBCharacteristic)
            updateExp.fulfill()
        }
        let delegate = PeripheralClient.Delegate(peripheral: stubCBPeripheral, didUpdateValue: updateBlock, didWriteValue: nil, didDisconnect: nil)
        delegate.peripheral(stubCBPeripheral, didUpdateValueFor: stubCBCharacteristic, error: nserror)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWriteValueBlock() {
        let writeExp = expectation(description: "WriteValue")
        let nserror   = NSError(domain: "test", code: 1, userInfo: nil)
        let writeBlock: Completion<CBCharacteristic> = { characteristic, error in
            XCTAssertTrue(error! as NSError === nserror)
            XCTAssertEqual(characteristic, self.stubCBCharacteristic)
            writeExp.fulfill()
        }
        let delegate = PeripheralClient.Delegate(peripheral: stubCBPeripheral, didUpdateValue: nil, didWriteValue: writeBlock, didDisconnect: nil)
        delegate.peripheral(stubCBPeripheral, didWriteValueFor: stubCBCharacteristic, error: nserror)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDisconnectBlock() {
        let discExp = expectation(description: "Disconnect")
        let nserror   = NSError(domain: "test", code: 1, userInfo: nil)
        let discBlock: ErrorCompletion = { error in
            XCTAssertTrue(error! as NSError === nserror)
            discExp.fulfill()
        }
        let delegate = PeripheralClient.Delegate(peripheral: stubCBPeripheral, didUpdateValue: nil, didWriteValue: nil, didDisconnect: discBlock)
        delegate.peripheral(stubCBPeripheral, didDisconnectError: nserror)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
