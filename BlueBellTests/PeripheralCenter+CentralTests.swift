//
//  PeripheralCenter+CentralTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 28.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlueBell

class PeripheralCenter_CentralTests: XCTestCase {
    
    // MARK: - Properties
    
    var central: PeripheralCenter.Central!
    var fakeCentralManager: FakeCBCentralManager!
    var peripheral: Peripheral!
    var stubCBPeripheral: StubCBPeripheral!
    var anotherStubCBPeripheral: StubCBPeripheral!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        fakeCentralManager = FakeCBCentralManager()
        fakeCentralManager.stateResult = .poweredOn
        central            = PeripheralCenter.Central(centralManager: fakeCentralManager)
        peripheral         = StubPeripheral(_services: [
            StubService(_uuidString: "107E43D7-50D0-47EB-936A-0E5729B376C3"),
            StubService(_uuidString: "D9D0005E-2AA0-406B-B6F0-F3486FE791BC")
        ])
        stubCBPeripheral        = StubCBPeripheral(stubIdentifier: UUID(uuidString: "89739652-9C94-4989-A196-BFFBB75A3CDE")!)
        anotherStubCBPeripheral = StubCBPeripheral(stubIdentifier: UUID(uuidString: "A3028452-A053-42C0-B2B7-D9937AFD1F3A")!)
    }
    
    // MARK: - Init
    
    func testInit_custom_createsCentralManager() {
        let centralManager = CBCentralManager()
        let central        = PeripheralCenter.Central(centralManager: centralManager)
        XCTAssertEqual(central.centralManager, centralManager)
    }
    
    func testInit_custom_assignsDelegate() {
        let centralManager = CBCentralManager()
        let central        = PeripheralCenter.Central(centralManager: centralManager)
        XCTAssertTrue(central.centralManager.delegate === central)
    }
    
    func testInit_default_createsCentralManager() {
        let central = PeripheralCenter.Central()
        XCTAssertNotNil(central.centralManager)
    }
    
    func testInit_default_assignsDelegate() {
        let central = PeripheralCenter.Central()
        XCTAssertTrue(central.centralManager.delegate === central)
    }
    
    // MARK: - Scan
    
    func testScan_poweredOn_runsScanning() {
        let options: [String : Any] = ["name" : "value"]
        central.scan(for: peripheral, options: options, update: { _ in })
        XCTAssertEqual(fakeCentralManager.scanParameters.invokes, 1)
        XCTAssertEqual(fakeCentralManager.scanParameters.params!.serviceUUIDs!.map({ $0.uuidString }), ["107E43D7-50D0-47EB-936A-0E5729B376C3", "D9D0005E-2AA0-406B-B6F0-F3486FE791BC"])
        XCTAssertTrue(options == fakeCentralManager.scanParameters.params!.options!)
    }
    
    func testScan_poweredOn_returnsResults() {
        let options: [String : Any] = ["name" : "value"]
        let exp = expectation(description: "")
        var expectedCount = 3
        
        // check fake peripherals from FakeCBCentralManager
        central.scan(for: peripheral, options: options) { result in
            switch expectedCount {
                case 3:
                    switch result {
                        case .value(let result):
                            // last one
                            XCTAssertEqual(result.0.peripheral.uuidString, "DBB8BB99-6440-4190-8F69-F27AE8867803")
                            XCTAssertTrue(result.0.advertisementData == ["name" : "1"])
                            XCTAssertEqual(result.0.rssi, NSNumber(value: 10))
                            // all discovered
                            XCTAssertEqual(result.1.count, 1)
                            XCTAssertEqual(result.1[0].peripheral.uuidString, "DBB8BB99-6440-4190-8F69-F27AE8867803")
                            XCTAssertTrue(result.1[0].advertisementData == ["name" : "1"])
                            XCTAssertEqual(result.1[0].rssi, NSNumber(value: 10))
                        case .error:
                            XCTAssertFalse(true)
                    }
                case 2:
                    switch result {
                        case .value(let result):
                            // last one
                            XCTAssertEqual(result.0.peripheral.uuidString, "4294CA7A-27AB-4F55-A760-F4AD4ADB03F4")
                            XCTAssertTrue(result.0.advertisementData == ["name" : "3"])
                            XCTAssertEqual(result.0.rssi, NSNumber(value: 25))
                            // all discovered
                            XCTAssertEqual(result.1.count, 2)
                            XCTAssertEqual(result.1[0].peripheral.uuidString, "DBB8BB99-6440-4190-8F69-F27AE8867803")
                            XCTAssertTrue(result.1[0].advertisementData == ["name" : "1"])
                            XCTAssertEqual(result.1[0].rssi, NSNumber(value: 10))
                            XCTAssertEqual(result.1[1].peripheral.uuidString, "4294CA7A-27AB-4F55-A760-F4AD4ADB03F4")
                            XCTAssertTrue(result.1[1].advertisementData == ["name" : "3"])
                            XCTAssertEqual(result.1[1].rssi, NSNumber(value: 25))
                        case .error:
                            XCTAssertFalse(true)
                    }
                case 1:
                    switch result {
                        case .value(let result):
                            // last one
                            XCTAssertEqual(result.0.peripheral.uuidString, "C50C65BE-E41C-445F-9988-6FF1C11F957E")
                            XCTAssertTrue(result.0.advertisementData == ["name" : "4"])
                            XCTAssertEqual(result.0.rssi, NSNumber(value: 20))
                            // all discovered
                            XCTAssertEqual(result.1.count, 3)
                            XCTAssertEqual(result.1[0].peripheral.uuidString, "DBB8BB99-6440-4190-8F69-F27AE8867803")
                            XCTAssertTrue(result.1[0].advertisementData == ["name" : "1"])
                            XCTAssertEqual(result.1[0].rssi, NSNumber(value: 10))
                            XCTAssertEqual(result.1[1].peripheral.uuidString, "4294CA7A-27AB-4F55-A760-F4AD4ADB03F4")
                            XCTAssertTrue(result.1[1].advertisementData == ["name" : "3"])
                            XCTAssertEqual(result.1[1].rssi, NSNumber(value: 25))
                            XCTAssertEqual(result.1[2].peripheral.uuidString, "C50C65BE-E41C-445F-9988-6FF1C11F957E")
                            XCTAssertTrue(result.1[2].advertisementData == ["name" : "4"])
                            XCTAssertEqual(result.1[2].rssi, NSNumber(value: 20))
                            // end
                            exp.fulfill()
                        case .error:
                            XCTAssertFalse(true)
                    }
                default:
                    break
            }
            expectedCount -= 1
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testScan_poweredOff_doesntRunScanning() {
        let options: [String : Any] = ["name" : "value"]
        fakeCentralManager.stateResult = .poweredOff
        central.scan(for: peripheral, options: options, update: { _ in })
        XCTAssertEqual(fakeCentralManager.scanParameters.invokes, 0)
    }
    
    func testScan_poweredOff_runsWhenDeviceWouldChangeStateToPoweredOn() {
        let options: [String : Any] = ["name" : "value"]
        let exp = expectation(description: "")
        var expectedCount = 3
        fakeCentralManager.stateResult = .poweredOff
        central.scan(for: peripheral, options: options, update: { _ in
            expectedCount -= 1
            if expectedCount == 0 {
                exp.fulfill()
            }
        })
        fakeCentralManager.stateResult = .poweredOn
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testScan_isAlreadyScanning_returnsError() {
        let newPeripheral = StubPeripheral(_services: [
            StubService(_uuidString: "5924CB4D-75B5-435D-9EA4-470A20214810")
        ])
        let options: [String : Any] = ["name" : "value"]
        let newOptions: [String : Any] = ["name2" : "value2"]
        let exp = expectation(description: "")
        central.scan(for: peripheral, options: options, update: { _ in })
        central.scan(for: newPeripheral, options: newOptions, update: { result in
            switch result {
                case .error(let error):
                    switch error as! PeripheralCenter.Central.CentralError {
                        case .scanningIsAreadyOn:
                            exp.fulfill()
                        default:
                            break
                    }
                default:
                    break
            }
        })
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Stop scan
    
    func testStopScan_stopsCentralManager() {
        central.scan(for: peripheral, options: nil, update: { _ in })
        central.stopScan()
        XCTAssertEqual(fakeCentralManager.stopScanParameters, 1)
    }
    
    func testStopScan_clearCurrentUpdateBlock() {
        let exp = expectation(description: "")
        central.scan(for: peripheral, options: nil) { result in
            self.central.stopScan()
            exp.fulfill()
            // that is enough because invoking fulfill multiple time cases exception as well (test won't pass)
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Connect
    
    func testConnect_connectsToCentralManager() {
        let options: [String : Any] = ["name" : "value"]
        central.connect(to: stubCBPeripheral, options: options, completion: { _ in })
        XCTAssertEqual(fakeCentralManager.connectParameters.invokes, 1)
        XCTAssertEqual(fakeCentralManager.connectParameters.params?.peripheral.uuidString, "89739652-9C94-4989-A196-BFFBB75A3CDE")
        XCTAssertTrue(options == fakeCentralManager.connectParameters.params!.options!)
    }
    
    func testConnect_invokesComletionWithSuccess() {
        let exp = expectation(description: "")
        central.connect(to: stubCBPeripheral, options: nil) { result in
            switch result {
                case .value(let peripheral):
                    XCTAssertEqual(peripheral.identifier.uuidString, "89739652-9C94-4989-A196-BFFBB75A3CDE")
                    exp.fulfill()
                case .error:
                    break
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testConnect_invokesCompletionWithError() {
        let exp   = expectation(description: "")
        let error = NSError(domain: "test", code: 13, userInfo: nil)
        fakeCentralManager.stubConnectionParams["89739652-9C94-4989-A196-BFFBB75A3CDE"] = error
        central.connect(to: stubCBPeripheral, options: nil) { result in
            switch result {
                case .value(_):
                    break
                case .error(let err):
                    XCTAssertEqual(err as NSError, error)
                    exp.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testConnect_connectingWithTwoPeripherals() {
        let exp1 = expectation(description: "exp1")
        let exp2 = expectation(description: "exp2")
        central.connect(to: stubCBPeripheral, options: nil) { result in
            switch result {
                case .value(let peripheral):
                    XCTAssertEqual(peripheral.identifier.uuidString, "89739652-9C94-4989-A196-BFFBB75A3CDE")
                    exp1.fulfill()
                case .error:
                    break
            }
        }
        central.connect(to: anotherStubCBPeripheral, options: nil) { result in
            switch result {
                case .value(let peripheral):
                    XCTAssertEqual(peripheral.identifier.uuidString, "A3028452-A053-42C0-B2B7-D9937AFD1F3A")
                    exp2.fulfill()
                case .error:
                    break
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Disconnect
    
    func testDisconnect_disconnectsToCentralManager() {
        central.disconnect(stubCBPeripheral, completion: { _ in })
        XCTAssertEqual(fakeCentralManager.disconnectParameters.invokes, 1)
        XCTAssertEqual(fakeCentralManager.disconnectParameters.peripheral?.uuidString, "89739652-9C94-4989-A196-BFFBB75A3CDE")
    }
    
    func testDisconnect_invokesCompletionWithSuccess() {
        let exp = expectation(description: "")
        central.disconnect(stubCBPeripheral) { result in
            switch result {
                case .value(let peripheral):
                    XCTAssertEqual(peripheral.identifier.uuidString, "89739652-9C94-4989-A196-BFFBB75A3CDE")
                    exp.fulfill()
                case .error:
                    break
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDisconnect_invokesCompletionWithError() {
        let exp   = expectation(description: "")
        let error = NSError(domain: "test", code: 13, userInfo: nil)
        fakeCentralManager.stubDisconnectionParams["89739652-9C94-4989-A196-BFFBB75A3CDE"] = error
        central.disconnect(stubCBPeripheral) { result in
            switch result {
                case .value(_):
                    break
                case .error(let err):
                    XCTAssertEqual(err as NSError, error)
                    exp.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDisconnect_disconnectingWithTwoPeripherals() {
        let exp1 = expectation(description: "exp1")
        let exp2 = expectation(description: "exp2")
        central.disconnect(stubCBPeripheral) { result in
            switch result {
                case .value(let peripheral):
                    XCTAssertEqual(peripheral.identifier.uuidString, "89739652-9C94-4989-A196-BFFBB75A3CDE")
                    exp1.fulfill()
                case .error:
                    break
            }
        }
        central.disconnect(anotherStubCBPeripheral) { result in
            switch result {
                case .value(let peripheral):
                    XCTAssertEqual(peripheral.identifier.uuidString, "A3028452-A053-42C0-B2B7-D9937AFD1F3A")
                    exp2.fulfill()
                case .error:
                    break
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - CentralUpdateState
    
    func testCentralUpdateState_1() {
        let exp = expectation(description: "")
        var counter: Int = 0
        central.centralUpdateState = { state in
            XCTAssertTrue(state == .poweredOn)
            counter += 1
            if counter == 1 {
                exp.fulfill()
            }
        }
        fakeCentralManager.stateResult = .poweredOn
        central.centralManagerDidUpdateState(fakeCentralManager)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCentralUpdateState_2() {
        let exp = expectation(description: "")
        var counter: Int = 0
        central.centralUpdateState = { state in
            XCTAssertTrue(state == .poweredOff)
            counter += 1
            if counter == 1 {
                exp.fulfill()
            }
        }
        fakeCentralManager.stateResult = .poweredOff
        central.centralManagerDidUpdateState(fakeCentralManager)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
