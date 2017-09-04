//
//  ExtensionsTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 04.09.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlueBell

class ExtensionsTests: XCTestCase {
    
    // MARK: - Set first for characteristic
    
    func testSetFirst_shouldReturnNilIfCharacteristicDoesntExist() {
        let cbChar1 = StubCBCharacteristic(stubIdentifier: CBUUID(string: "3301489C-01F5-43A9-A8A5-AFBBDF696A1F"))
        let set: Set<CBCharacteristic> = Set([cbChar1])
        XCTAssertNil(set.first(for: StubCharacteristic(_uuidString: "B8D53138-5509-448D-BD43-53589DADF34F")))
    }
    
    func testSetFirst_shouldReturnCharacteristicIfExists() {
        let cbChar1 = StubCBCharacteristic(stubIdentifier: CBUUID(string: "3301489C-01F5-43A9-A8A5-AFBBDF696A1F"))
        let cbChar2 = StubCBCharacteristic(stubIdentifier: CBUUID(string: "B8D53138-5509-448D-BD43-53589DADF34F"))
        let set: Set<CBCharacteristic> = Set([cbChar1, cbChar2])
        XCTAssertEqual(set.first(for: StubCharacteristic(_uuidString: "3301489C-01F5-43A9-A8A5-AFBBDF696A1F"))?.uuidString, "3301489C-01F5-43A9-A8A5-AFBBDF696A1F")
    }
    
    // MARK: - Array filter for peripheral
    
    func testArrayFilter_shouldReturnCorrectItems() {
        let array: Array<CBService> = [
            StubCBService(stubIdentifier: CBUUID(string: "3301489C-01F5-43A9-A8A5-AFBBDF696A1F")),
            StubCBService(stubIdentifier: CBUUID(string: "B8D53138-5509-448D-BD43-53589DADF34F")),
            StubCBService(stubIdentifier: CBUUID(string: "EECA2911-D148-4E3E-84CD-F25144587A23")),
        ]
        let peripheral = StubPeripheral(_services: [
            StubService(_uuidString: "22999A4B-BEBF-45E6-8BB6-EC702AAE7552"),
            StubService(_uuidString: "EECA2911-D148-4E3E-84CD-F25144587A23"),
            StubService(_uuidString: "3301489C-01F5-43A9-A8A5-AFBBDF696A1F")
        ])
        let result = array.filter(for: peripheral)
        XCTAssertEqual(result!.map({ $0.uuidString }), ["3301489C-01F5-43A9-A8A5-AFBBDF696A1F", "EECA2911-D148-4E3E-84CD-F25144587A23"])
    }
    
}
