//
//  PeripheralClient+SubscriptionRequestQueueTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 31.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlueBell

class PeripheralClient_SubscriptionRequestQueueTests: XCTestCase {
  
    // MARK: - Helpers
    
    class Request: BaseSubscriptionRequest {
        
        let characteristic: Characteristic?
        
        init(characteristic: Characteristic) {
            self.characteristic = characteristic
        }
        
        func perform(for data: Data, error: Error?) {}
        
    }
    
    // MARK: - Properties
    
    var requestQueue: PeripheralClient.SubscriptionRequestQueue!
    var mockDispatchQueue: MockDispatchQueue!
    var stubCharacteristic: StubCharacteristic!
    var stubCBCharacteristic: StubCBCharacteristic!
    var anotherStubCBCharacteristic: StubCBCharacteristic!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        stubCBCharacteristic        = StubCBCharacteristic(stubIdentifier: CBUUID(string: "2F374B37-9525-4EB1-8394-879B2D5217A2"))
        anotherStubCBCharacteristic = StubCBCharacteristic(stubIdentifier: CBUUID(string: "53A43A98-FEA4-4F84-9C79-91372DD197F4"))
        stubCharacteristic          = StubCharacteristic(_uuidString: "2F374B37-9525-4EB1-8394-879B2D5217A2")
        mockDispatchQueue           = MockDispatchQueue()
        requestQueue                = PeripheralClient.SubscriptionRequestQueue(queue: mockDispatchQueue)
    }
    
    // MARK: - Add, remove, get
    
    func test() {
        let request = Request(characteristic: stubCharacteristic)
        
        // queue is empty, request doesn't exist
        XCTAssertNil(requestQueue.request(for: stubCBCharacteristic))
        XCTAssertEqual(mockDispatchQueue.syncCounter, 1)
        XCTAssertEqual(mockDispatchQueue.asyncCounter, 0)
        
        // adding new request
        requestQueue.add(request: request)
        XCTAssertEqual(mockDispatchQueue.syncCounter, 1)
        XCTAssertEqual(mockDispatchQueue.asyncCounter, 1)
        XCTAssertTrue(requestQueue.request(for: stubCBCharacteristic) as? Request === request)
        XCTAssertEqual(mockDispatchQueue.syncCounter, 2)
        XCTAssertEqual(mockDispatchQueue.asyncCounter, 1)
        
        // removing request which doesn't exist
        requestQueue.removeRequest(for: anotherStubCBCharacteristic)
        XCTAssertEqual(mockDispatchQueue.syncCounter, 2)
        XCTAssertEqual(mockDispatchQueue.asyncCounter, 2)
        XCTAssertTrue(requestQueue.request(for: stubCBCharacteristic) as? Request === request)
        XCTAssertEqual(mockDispatchQueue.syncCounter, 3)
        XCTAssertEqual(mockDispatchQueue.asyncCounter, 2)
        
        // removing existing request
        requestQueue.removeRequest(for: stubCBCharacteristic)
        XCTAssertEqual(mockDispatchQueue.syncCounter, 3)
        XCTAssertEqual(mockDispatchQueue.asyncCounter, 3)
        XCTAssertNil(requestQueue.request(for: stubCBCharacteristic))
        XCTAssertEqual(mockDispatchQueue.syncCounter, 4)
        XCTAssertEqual(mockDispatchQueue.asyncCounter, 3)
    }
    
}
