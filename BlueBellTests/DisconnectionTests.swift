//
//  DisconnectionTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 06.09.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlueBell

class DisconnectionTests: XCTestCase {
    
    // MARK: - Helpers
    
    class MockClientDelegate: PeripheralClientDelegate {
        
        var disconnectError: Error?
        
        func peripheralClient(_ peripheralClient: PeripheralClient, didDisconnectError: Error?) {
            disconnectError = didDisconnectError
        }
        
    }
    
    // MARK: - Properties
    
    var stubCBPeripheral: StubCBPeripheral!
    var client: PeripheralClient!
    var mockClientDelegate: MockClientDelegate!
    var center: PeripheralCenter!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        stubCBPeripheral   = StubCBPeripheral(stubIdentifier: UUID(uuidString: "FB17969B-3347-4AED-8085-F968B50FA6CF")!)
        client             = PeripheralClient(peripheral: stubCBPeripheral, characteristics: [], deconnect: { _ in })
        mockClientDelegate = MockClientDelegate()
        center             = PeripheralCenter()
        
        client.delegate = mockClientDelegate
    }
    
    // MARK: - Tests
    
    func test1_centralDisconnectPeripheral() {
        let nserror = NSError(domain: "test", code: 12, userInfo: nil)
        center.central.centralManager(center.central.centralManager, didDisconnectPeripheral: stubCBPeripheral, error: nserror)
        XCTAssertTrue(mockClientDelegate.disconnectError as NSError? === nserror)
    }
    
    func test2_clientDeallocates() {
        let exp = expectation(description: "")
        let block = {
             _ = PeripheralClient(peripheral: self.stubCBPeripheral, characteristics: [], deconnect: { _ in exp.fulfill() })
        }
        block()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
