//
//  PeripheralClient+CommandRequestQueueTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 31.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlueBell

class PeripheralClient_CommandRequestQueueTests: XCTestCase {

    // MARK: - Helpers
    
    class Request: BaseCommandRequest {
        
        let characteristic: Characteristic?
        
        init(characteristic: Characteristic) {
            self.characteristic = characteristic
        }
        
        func process(update data: Data) -> BaseCommandRequestState { return .inProgress }
        func process(write data: Data) -> BaseCommandRequestState { return .inProgress }
        func finish(error: Error?) {}
        
    }
    
    // MARK: - Properties
    
    var mockDispatchQueue: MockDispatchQueue!
    var commandQueue: PeripheralClient.CommandRequestQueue!
    var stubCharacteristic1_1: StubCharacteristic!
    var stubCharacteristic1_2: StubCharacteristic!
    var stubCharacteristic2: StubCharacteristic!
    var stubCBCharacteristic1_1: StubCBCharacteristic!
    var stubCBCharacteristic1_2: StubCBCharacteristic!
    var stubCBCharacteristic2: StubCBCharacteristic!
    var request1_1: Request!
    var request1_2: Request!
    var request2: Request!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        mockDispatchQueue       = MockDispatchQueue()
        commandQueue            = PeripheralClient.CommandRequestQueue(queue: mockDispatchQueue)
        stubCharacteristic1_1   = StubCharacteristic(_uuidString: "1E0588A4-A5CD-4203-BDB0-42ED8D687C66")
        stubCharacteristic1_2   = StubCharacteristic(_uuidString: "1E0588A4-A5CD-4203-BDB0-42ED8D687C66")
        stubCharacteristic2     = StubCharacteristic(_uuidString: "8165F165-542B-4BDB-9541-8B66DC04C7FF")
        stubCBCharacteristic1_1 = StubCBCharacteristic(stubIdentifier: CBUUID(string: "1E0588A4-A5CD-4203-BDB0-42ED8D687C66"))
        stubCBCharacteristic1_2 = StubCBCharacteristic(stubIdentifier: CBUUID(string: "1E0588A4-A5CD-4203-BDB0-42ED8D687C66"))
        stubCBCharacteristic2   = StubCBCharacteristic(stubIdentifier: CBUUID(string: "8165F165-542B-4BDB-9541-8B66DC04C7FF"))
        request1_1              = Request(characteristic: stubCharacteristic1_1)
        request1_2              = Request(characteristic: stubCharacteristic1_2)
        request2                = Request(characteristic: stubCharacteristic2)
    }
    
    // MARK: - Add & first
    
    func test() {
        // adding first request
        commandQueue.add(request: request1_1)
        XCTAssertTrue(commandQueue.firstRequest(for: stubCBCharacteristic1_1) as! Request === request1_1)
        XCTAssertNil(commandQueue.firstRequest(for: stubCBCharacteristic2))
        
        // adding another request for the same characteristic
        commandQueue.add(request: request1_2)
        XCTAssertTrue(commandQueue.firstRequest(for: stubCBCharacteristic1_1) as! Request === request1_1)
        XCTAssertTrue(commandQueue.firstRequest(for: stubCBCharacteristic1_2) as! Request === request1_1)
        
        // adding another request for different characteristic
        commandQueue.add(request: request2)
        XCTAssertTrue(commandQueue.firstRequest(for: stubCBCharacteristic1_1) as! Request === request1_1)
        XCTAssertTrue(commandQueue.firstRequest(for: stubCBCharacteristic1_2) as! Request === request1_1)
        XCTAssertTrue(commandQueue.firstRequest(for: stubCBCharacteristic2) as! Request === request2)
        
        // remove first characteristic (right now there are two requests)
        commandQueue.removeFirstRequst(for: stubCBCharacteristic1_1)
        XCTAssertTrue(commandQueue.firstRequest(for: stubCBCharacteristic1_1) as! Request === request1_2)
        XCTAssertTrue(commandQueue.firstRequest(for: stubCBCharacteristic1_2) as! Request === request1_2)
        
        // remove last request
        commandQueue.removeFirstRequst(for: stubCBCharacteristic1_2)
        XCTAssertNil(commandQueue.firstRequest(for: stubCBCharacteristic1_2))
        XCTAssertNil(commandQueue.firstRequest(for: stubCBCharacteristic1_1))
    }
    
}
