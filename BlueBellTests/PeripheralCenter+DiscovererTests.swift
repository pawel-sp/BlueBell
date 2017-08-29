//
//  PeripheralCenter+DiscovererTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 29.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import BlueBell

class PeripheralCenter_DiscovererTests: XCTestCase {
    
    // MARK: - Properties
    
    var stubCBPeripheral: StubCBPeripheral!
    var stubPeripheral: StubPeripheral!
    var fakeCBPeripheral: FakeCBPeripheral!
    
    var discoverer: PeripheralCenter.Discoverer!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        stubPeripheral = StubPeripheral(_services: [
            StubService(_uuidString: "971DC1F9-3595-47EC-B849-EDB930A606D3", _characteristicUUIDStrings: [
                "0D6DF401-880E-432D-B3FC-279B159F98E4",
                "00B87777-3E42-4EA7-8A29-9B364A328DCD"
            ]),
            StubService(_uuidString: "57445811-D0EC-492E-9D37-3B3488999366", _characteristicUUIDStrings: [
                "D6F0E0BF-7157-4800-BE32-FEB4AEBFFA91"
            ])
        ])
        stubCBPeripheral = StubCBPeripheral(stubIdentifier: UUID(uuidString: "D7363E81-20B4-4909-AEBC-1E5D9AE87E4D")!)
        fakeCBPeripheral = FakeCBPeripheral(stubIdentifier: UUID(uuidString: "82B6DDAB-F0C2-4D2C-89CA-8ECF8639DA0F")!)
        discoverer       = PeripheralCenter.Discoverer(peripheral: fakeCBPeripheral, interface: stubPeripheral)
    }
    
    // MARK: - Init
    
    func testInit_assingsProperties() {
        let discoverer = PeripheralCenter.Discoverer(peripheral: stubCBPeripheral, interface: stubPeripheral)
        XCTAssertTrue(discoverer.peripheral === stubCBPeripheral)
        XCTAssertTrue(discoverer.interface as? StubPeripheral === stubPeripheral)
    }
    
    func testInit_assignsDelegate() {
        let discoverer = PeripheralCenter.Discoverer(peripheral: stubCBPeripheral, interface: stubPeripheral)
        XCTAssertTrue(discoverer.peripheral.delegate === discoverer)
    }
    
    // MARK: - Load characteristics
    
    func testLoad_discoversServicesWithCorrectUUIDs() {
        discoverer.loadCharacteristics(completion: { _ in })
        XCTAssertEqual(fakeCBPeripheral.discoverServicesParameters.invokes, 1)
        XCTAssertEqual(fakeCBPeripheral.discoverServicesParameters.serviceUUIDs!.map({ $0.uuidString }), ["971DC1F9-3595-47EC-B849-EDB930A606D3", "57445811-D0EC-492E-9D37-3B3488999366"])
    }
    
    func testLoad_discoversAllCharacteristics_onlyUnique() {
        discoverer.loadCharacteristics(completion: { _ in })
        XCTAssertEqual(fakeCBPeripheral.discoverCharacteristicParameters["971DC1F9-3595-47EC-B849-EDB930A606D3"]!.map({ $0.uuidString }), ["0D6DF401-880E-432D-B3FC-279B159F98E4", "00B87777-3E42-4EA7-8A29-9B364A328DCD"])
        XCTAssertEqual(fakeCBPeripheral.discoverCharacteristicParameters["57445811-D0EC-492E-9D37-3B3488999366"]!.map({ $0.uuidString }), ["D6F0E0BF-7157-4800-BE32-FEB4AEBFFA91"])
    }
    
    func testLoad_completionHasOnlyUniqueCharacteristics() {
        let exp = expectation(description: "")
        discoverer.loadCharacteristics() { result in
            switch result {
                case .value(let characteristics):
                    XCTAssertTrue(characteristics.contains(where: { $0.uuidString == "0D6DF401-880E-432D-B3FC-279B159F98E4" }))
                    XCTAssertTrue(characteristics.contains(where: { $0.uuidString == "00B87777-3E42-4EA7-8A29-9B364A328DCD" }))
                    XCTAssertTrue(characteristics.contains(where: { $0.uuidString == "D6F0E0BF-7157-4800-BE32-FEB4AEBFFA91" }))
                    XCTAssertEqual(characteristics.count, 3)
                    exp.fulfill()
                case .error:
                    break
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLoad_discoverServiceReturnsError() {
        let nserror = NSError(domain: "test", code: 1, userInfo: nil)
        let exp     = expectation(description: "")
        fakeCBPeripheral.discoverServiceError = nserror
        discoverer.loadCharacteristics() { result in
            switch result {
                case .value:
                    break
                case .error(let error):
                    XCTAssertEqual(error as NSError, nserror)
                    exp.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLoad_discoverCharacteristicReturnsError() {
        let nserror = NSError(domain: "test", code: 1, userInfo: nil)
        let exp     = expectation(description: "")
        fakeCBPeripheral.discoverCharacteristicError = nserror
        discoverer.loadCharacteristics() { result in
            switch result {
            case .value:
                break
            case .error(let error):
                XCTAssertEqual(error as NSError, nserror)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
