//
//  PeripheralClient+SubscriptionRequestTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 31.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import BlueBell

class PeripheralClient_SubscriptionRequestTests: XCTestCase {
    
    // MARK: - Properties
    
    var stubCharacteristic: StubCharacteristic!
    var intTransformer: IntTransformer!
    
    // MARK: - Helpers
    
    class IntTransformer: CharacteristicDataTransformer<Int> {
        
        var data: Data?
        
        override func transform(dataToValue: Data) -> Int {
            self.data = dataToValue
            return 10
        }
        
    }
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        stubCharacteristic = StubCharacteristic(_uuidString: "31C2A3BC-C510-460B-914D-28D0C2042C10")
        intTransformer = IntTransformer()
    }
    
    // MARK: - Init
    
    func testInit_assignsAllProperties() {
        let subscription   = PeripheralSubscription(characteristic: stubCharacteristic, transformer: intTransformer)
        let request        = PeripheralClient.SubscriptionRequest(subscription: subscription, update: { _ in })
        XCTAssertTrue(request.subscription === subscription)
        XCTAssertTrue(request.characteristic as? StubCharacteristic === stubCharacteristic)
    }
    
    func testPerform_invokesBlock_withoutError() {
        let data = Data()
        let exp = expectation(description: "")
        let subscription = PeripheralSubscription(characteristic: stubCharacteristic, transformer: intTransformer)
        let request      = PeripheralClient.SubscriptionRequest(subscription: subscription) { result in
            switch result {
                case .value(let value):
                    XCTAssertEqual(value, 10)
                    XCTAssertEqual(data, self.intTransformer.data)
                    exp.fulfill()
                case .error:
                    break
            }
        }
        request.perform(for: data, error: nil)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerform_invokesBlock_withError() {
        let data         = Data()
        let nserror      = NSError(domain: "", code: 1, userInfo: nil)
        let exp          = expectation(description: "")
        let subscription = PeripheralSubscription(characteristic: stubCharacteristic, transformer: intTransformer)
        let request      = PeripheralClient.SubscriptionRequest(subscription: subscription) { result in
            switch result {
            case .value:
                break
            case .error(let error):
                XCTAssertTrue(nserror == error as NSError)
                exp.fulfill()
            }
        }
        request.perform(for: data, error: nserror)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
