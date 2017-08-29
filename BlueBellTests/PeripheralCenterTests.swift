//
//  PeripheralCenterTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 29.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlueBell

class PeripheralCenterTests: XCTestCase {

    // MARK: - Properties
    
    var center: PeripheralCenter!
    var fakeCentral: FakeCentral!
    var stubPeripheral: StubPeripheral!
    var options: [String : Any]!
    var stubCBPeripheral: StubCBPeripheral!
    var peripheralInfo: PeripheralInfo!
    var stubDiscovererClass: StubDiscoverer.Type!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        stubCBPeripheral    = StubCBPeripheral(stubIdentifier: UUID(uuidString: "55866811-9FCA-4AE0-96D5-41799D825121")!)
        peripheralInfo      = PeripheralInfo(peripheral: stubCBPeripheral, advertisementData: [:], rssi: NSNumber(value: 0))
        options             = ["key" : "value"]
        fakeCentral         = FakeCentral()
        stubDiscovererClass = StubDiscoverer.self
        center              = PeripheralCenter(central: fakeCentral, discovererClass: stubDiscovererClass)
        stubPeripheral      = StubPeripheral(_services: [])
    }
    
    // MARK: - Init
    
    func testInit_assignsProperties() {
        let central = PeripheralCenter.Central()
        let center  = PeripheralCenter(central: central)
        XCTAssertEqual(center.central, central)
    }
    
    // MARK: - Scan
    
    func testScan_invokesScanningForCentral() {
        let exp = expectation(description: "")
        let update: BufferCompletion<PeripheralInfo> = { _, _ in
            exp.fulfill()
        }
        center.scan(for: stubPeripheral, options: options, update: update)
        fakeCentral.scanParameters.params?.update(peripheralInfo, [peripheralInfo])
        XCTAssertEqual(fakeCentral.scanParameters.invokes, 1)
        XCTAssertTrue(fakeCentral.scanParameters.params?.peripheralInterface as? StubPeripheral === stubPeripheral)
        XCTAssertTrue(fakeCentral.scanParameters.params!.options! == options)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testStopScan_invokesStopScanForCentral() {
        center.stopScan()
        XCTAssertEqual(fakeCentral.stopScanParameters, 1)
    }
    
    // MARK: - Connect 
    
    func testConnect_passesCorrectParametersToCentral() {
        let exp = expectation(description: "")
        let completion: ResultCompletion<PeripheralClient> = { _ in
            exp.fulfill()
        }
        center.connect(to: stubCBPeripheral, peripheralInterface: stubPeripheral, options: options, completion: completion)
        fakeCentral.connectParameters.params?.completion(Result.error(NSError(domain: "test", code: 0, userInfo: nil)))
        XCTAssertEqual(fakeCentral.connectParameters.invokes, 1)
        XCTAssertEqual(fakeCentral.connectParameters.params?.peripheral, stubCBPeripheral)
        XCTAssertTrue(fakeCentral.connectParameters.params!.options! == options)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testConnect_centralConnectionReturnsError() {
        let nserror = NSError(domain: "test", code: 0, userInfo: nil)
        let exp     = expectation(description: "")
        fakeCentral.connectionResult = Result.error(nserror)
        center.connect(to: stubCBPeripheral, peripheralInterface: stubPeripheral, options: options) { result in
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
    
    func testConnect_centralConnectionReturnsPeripheral_loadCharacteristicsReturnsError() {
        let exp     = expectation(description: "")
        let nserror = NSError(domain: "", code: 1, userInfo: nil)
        fakeCentral.connectionResult = Result.value(stubCBPeripheral)
        stubDiscovererClass.loadCharacteristicsResult = Result.error(nserror)
        center.connect(to: stubCBPeripheral, peripheralInterface: stubPeripheral, options: options) { result in
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
    
    func testConnect_centralConnectionReturnsPeripheral_loadCharacteristicsReturnsCharacteristics() {
        let characteristics = [
            StubCBCharacteristic(stubIdentifier: CBUUID(string: "0074119E-951A-4CF8-99D4-232FAE8AA2A6")),
            StubCBCharacteristic(stubIdentifier: CBUUID(string: "C6741C33-AD9C-4E7F-9EBE-D166EB959FAD"))
        ]
        let set = Set(characteristics)
        let exp = expectation(description: "")
        fakeCentral.connectionResult = Result.value(stubCBPeripheral)
        stubDiscovererClass.loadCharacteristicsResult = Result.value(set)
        center.connect(to: stubCBPeripheral, peripheralInterface: stubPeripheral, options: options) { result in
            switch result {
                case .value(let value):
                    XCTAssertEqual(value.peripheral, self.stubCBPeripheral)
                    XCTAssertEqual(value.characteristics.count, 2)
                    XCTAssertTrue(value.characteristics.contains(where: { $0.uuidString == "0074119E-951A-4CF8-99D4-232FAE8AA2A6" }))
                    XCTAssertTrue(value.characteristics.contains(where: { $0.uuidString == "C6741C33-AD9C-4E7F-9EBE-D166EB959FAD" }))
                    exp.fulfill()
                case .error:
                    break
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
