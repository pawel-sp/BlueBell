//
//  PeripheralClientTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 04.09.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BlueBell

class PeripheralClientTests: XCTestCase {
    
    // MARK: - Helpers
    
    class Transformer: CharacteristicDataTransformer<Int> {
        
        var valueToData: Int?
        
        override func transform(valueToData: Int) -> Data {
            self.valueToData = valueToData
            return Data()
        }
        
        override func transform(dataToValue: Data) -> Int {
            return 0
        }
        
    }
    
    class MockCommandRequestQueue: PeripheralClient.CommandRequestQueue {
        
        var addedRequests: [(BaseCommandRequest, ()->())] = []
        
        override func add(operation: @escaping ()->(), for request: BaseCommandRequest) {
            addedRequests.append((request, operation))
        }
        
    }
    
    class MockSubscritpionRequestQueue: PeripheralClient.SubscriptionRequestQueue {
        
        var addedRequest: [BaseSubscriptionRequest] = []
        var removedRequestForCharacteristics: [CBCharacteristic] = []
        
        override func add(request: BaseSubscriptionRequest) {
            addedRequest.append(request)
        }
        
        override func removeRequest(for characteristic: CBCharacteristic) {
            removedRequestForCharacteristics.append(characteristic)
        }
        
    }
    
    // MARK: - Properties
    
    var fakeCBPeripheral: FakeCBPeripheral!
    var stubCBCharacteristic1: StubCBCharacteristic!
    var stubCBCharacteristic2: StubCBCharacteristic!
    var client: PeripheralClient!
    var transformer: Transformer!
    var mockCommandRequestQueue: MockCommandRequestQueue!
    var mockSubscriptionRequestQueue: MockSubscritpionRequestQueue!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        fakeCBPeripheral             = FakeCBPeripheral(stubIdentifier: UUID(uuidString: "2B5B3B65-CB4A-4E78-9BE5-AF06E90F3BB5")!)
        stubCBCharacteristic1        = StubCBCharacteristic(stubIdentifier: CBUUID(string: "14047276-33BC-4CF9-AC75-5CD111EC213D"))
        stubCBCharacteristic2        = StubCBCharacteristic(stubIdentifier: CBUUID(string: "331DE754-BF63-4332-8095-3B84DF4AE654"))
        mockCommandRequestQueue      = MockCommandRequestQueue()
        mockSubscriptionRequestQueue = MockSubscritpionRequestQueue()
        client                       = PeripheralClient(peripheral: fakeCBPeripheral, characteristics: Set([stubCBCharacteristic1, stubCBCharacteristic2]), commandRequestQueue: mockCommandRequestQueue, subscriptionRequestQueue: mockSubscriptionRequestQueue, deconnect: { _ in })
        transformer                  = Transformer()
        
        fakeCBPeripheral.stateResult = .connected
    }
    
    // MARK: - Init
    
    func testInit_assignsProperties() {
        XCTAssertTrue(client.peripheral === fakeCBPeripheral)
        XCTAssertTrue(client.characteristics == Set([stubCBCharacteristic1, stubCBCharacteristic2]))
        XCTAssertTrue(client.commandRequestQueue === mockCommandRequestQueue)
        XCTAssertTrue(client.subscriptionRequestQueue === mockSubscriptionRequestQueue)
    }
    
    // MARK: - Perform
    
    func testPerform_readCommand_incorrectCharacteristic() {
        let readChar = StubCharacteristic(_uuidString: "3B84612F-516B-4BD9-94BF-50B8E606F7AC")
        let command  = PeripheralCommand(
            operation: .read(readChar),
            expectation: nil,
            transformer: transformer
        )
        let exp = expectation(description: "")
        client.perform(command: command) { result in
            switch result {
                case .value:
                    break
                case .error(let error):
                    switch error as! PeripheralClient.ClientError {
                        case .incorrectCharacteristicForOperation(let uuid):
                            XCTAssertEqual(uuid, "3B84612F-516B-4BD9-94BF-50B8E606F7AC")
                            XCTAssertEqual(self.mockCommandRequestQueue.addedRequests.count, 0)
                            exp.fulfill()
                        default:
                            break
                    }
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerform_readCommand_correctCharacteristic_missingExpectation() {
        let readChar = StubCharacteristic(_uuidString: "14047276-33BC-4CF9-AC75-5CD111EC213D")
        let command  = PeripheralCommand(
            operation: .read(readChar),
            expectation: nil,
            transformer: transformer
        )
        let exp = expectation(description: "")
        client.perform(command: command) { result in
            switch result {
                case .value:
                    break
                case .error(let error):
                    switch error as! PeripheralClient.ClientError {
                        case .missingExpectation:
                            XCTAssertEqual(self.mockCommandRequestQueue.addedRequests.count, 0)
                            exp.fulfill()
                        default:
                            break
                    }
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerform_readCommand_correctCharacteristic_correctExpectation_incorrectCharacteristic() {
        let readChar = StubCharacteristic(_uuidString: "14047276-33BC-4CF9-AC75-5CD111EC213D")
        let expChar  = StubCharacteristic(_uuidString: "4A9663F2-A0BA-4EDB-9CA3-D5AA4891BA09")
        let command  = PeripheralCommand(
            operation: .read(readChar),
            expectation: PeripheralCommand.Expectation(
                characteristic: expChar,
                updateValue: { _, _ in return true },
                writeValue: { _, _ in return true }
            ),
            transformer: transformer
        )
        let exp = expectation(description: "")
        client.perform(command: command) { result in
            switch result {
                case .value:
                    break
                case .error(let error):
                    switch error as! PeripheralClient.ClientError {
                        case .incorrectCharacteristicForExpectation(let uuid):
                            XCTAssertEqual(uuid, "4A9663F2-A0BA-4EDB-9CA3-D5AA4891BA09")
                            XCTAssertEqual(self.mockCommandRequestQueue.addedRequests.count, 0)
                            exp.fulfill()
                        default:
                            break
                    }
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerform_readCommand_correctCharacteristic_correctExpectation_correctCharacteristic() {
        let readChar = StubCharacteristic(_uuidString: "14047276-33BC-4CF9-AC75-5CD111EC213D")
        let expChar  = StubCharacteristic(_uuidString: "331DE754-BF63-4332-8095-3B84DF4AE654")
        let command  = PeripheralCommand(
            operation: .read(readChar),
            expectation: PeripheralCommand.Expectation(
                characteristic: expChar,
                updateValue: { _, _ in return true },
                writeValue: { _, _ in return true }
            ),
            transformer: transformer
        )
        client.perform(command: command) { _ in } // completion is necessary - without it request won't be added to queue
        XCTAssertEqual(self.mockCommandRequestQueue.addedRequests.count, 1)
        XCTAssertEqual(self.mockCommandRequestQueue.addedRequests[0].0.characteristic?.uuidString, "331DE754-BF63-4332-8095-3B84DF4AE654")
    }
    
    func testPerform_writeCommand_incorrectCharacteristic() {
        let writeChar = StubCharacteristic(_uuidString: "3B84612F-516B-4BD9-94BF-50B8E606F7AC")
        let command  = PeripheralCommand(
            operation: .write(0, writeChar),
            expectation: nil,
            transformer: transformer
        )
        let exp = expectation(description: "")
        client.perform(command: command) { result in
            switch result {
                case .value:
                    break
                case .error(let error):
                    switch error as! PeripheralClient.ClientError {
                        case .incorrectCharacteristicForOperation(let uuid):
                            XCTAssertEqual(uuid, "3B84612F-516B-4BD9-94BF-50B8E606F7AC")
                            XCTAssertEqual(self.mockCommandRequestQueue.addedRequests.count, 0)
                            exp.fulfill()
                        default:
                            break
                    }
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerform_writeCommand_correctCharacteristic_missingExpectation() {
        let writeChar = StubCharacteristic(_uuidString: "14047276-33BC-4CF9-AC75-5CD111EC213D")
        let command  = PeripheralCommand(
            operation: .write(0, writeChar),
            expectation: nil,
            transformer: transformer
        )
        let exp = expectation(description: "")
        client.perform(command: command) { result in
            switch result {
                case .value:
                    break
                case .error(let error):
                    switch error as! PeripheralClient.ClientError {
                        case .missingExpectation:
                            XCTAssertEqual(self.mockCommandRequestQueue.addedRequests.count, 0)
                            exp.fulfill()
                        default:
                            break
                    }
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerform_writeCommand_correctCharacteristic_correctExpectation_incorrectCharacteristic() {
        let writeChar = StubCharacteristic(_uuidString: "14047276-33BC-4CF9-AC75-5CD111EC213D")
        let expChar   = StubCharacteristic(_uuidString: "4A9663F2-A0BA-4EDB-9CA3-D5AA4891BA09")
        let command   = PeripheralCommand(
            operation: .write(13, writeChar),
            expectation: PeripheralCommand.Expectation(
                characteristic: expChar,
                updateValue: { _, _ in return true },
                writeValue: { _, _ in return true }
            ),
            transformer: transformer
        )
        let exp = expectation(description: "")
        client.perform(command: command) { result in
            switch result {
                case .value:
                    break
                case .error(let error):
                    switch error as! PeripheralClient.ClientError {
                        case .incorrectCharacteristicForExpectation(let uuid):
                            XCTAssertEqual(uuid, "4A9663F2-A0BA-4EDB-9CA3-D5AA4891BA09")
                            XCTAssertEqual(self.mockCommandRequestQueue.addedRequests.count, 0)
                            exp.fulfill()
                        default:
                            break
                    }
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPerform_writeCommand_correctCharacteristic_correctExpectation_correctCharacteristic() {
        let writeChar = StubCharacteristic(_uuidString: "14047276-33BC-4CF9-AC75-5CD111EC213D")
        let expChar   = StubCharacteristic(_uuidString: "331DE754-BF63-4332-8095-3B84DF4AE654")
        let command   = PeripheralCommand(
            operation: .write(13, writeChar),
            expectation: PeripheralCommand.Expectation(
                characteristic: expChar,
                updateValue: { _, _ in return true },
                writeValue: { _, _ in return true }
            ),
            transformer: transformer
        )
        client.perform(command: command) { _ in } // completion is necessary - without it request won't be added to queue
        XCTAssertEqual(self.mockCommandRequestQueue.addedRequests.count, 1)
        XCTAssertEqual(self.mockCommandRequestQueue.addedRequests[0].0.characteristic?.uuidString, "331DE754-BF63-4332-8095-3B84DF4AE654")
    }
    
    func testPerform_deviceIsNotConnected() {
        fakeCBPeripheral.stateResult = .disconnected
        let writeChar = StubCharacteristic(_uuidString: "14047276-33BC-4CF9-AC75-5CD111EC213D")
        let expChar   = StubCharacteristic(_uuidString: "331DE754-BF63-4332-8095-3B84DF4AE654")
        let command   = PeripheralCommand(
            operation: .write(13, writeChar),
            expectation: PeripheralCommand.Expectation(
                characteristic: expChar,
                updateValue: { _, _ in return true },
                writeValue: { _, _ in return true }
            ),
            transformer: transformer
        )
        let exp = expectation(description: "")
        client.perform(command: command) { result in
            switch result {
                case .value:
                    break
                case .error(let error):
                    switch error as! PeripheralClient.ClientError {
                    case .deviceNotConnected(let state):
                        XCTAssertEqual(state, .disconnected)
                        XCTAssertEqual(self.mockCommandRequestQueue.addedRequests.count, 0)
                        XCTAssertEqual(self.fakeCBPeripheral.writeValueParameters.invokes, 0)
                        exp.fulfill()
                    default:
                        break
                    }
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Register subscription
    
    func testRegisterSubscription_incorrectCharacteristic() {
        let char         = StubCharacteristic(_uuidString: "3B84612F-516B-4BD9-94BF-50B8E606F7AC")
        let subscription = PeripheralSubscription(characteristic: char, transformer: transformer)
        let exp          = expectation(description: "")
        client.register(subscription: subscription) { result in
            switch result {
                case .error(let error):
                    switch error as! PeripheralClient.ClientError {
                        case .incorrectCharacteristicForOperation(let uuid):
                            XCTAssertEqual(uuid, "3B84612F-516B-4BD9-94BF-50B8E606F7AC")
                            XCTAssertEqual(self.fakeCBPeripheral.setNotifyParameters.invokes, 0)
                            XCTAssertEqual(self.mockSubscriptionRequestQueue.addedRequest.count, 0)
                            exp.fulfill()
                        default:
                            break
                    }
                default:
                    break
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRegisterSubscription_correctCharacteristic() {
        let char         = StubCharacteristic(_uuidString: "14047276-33BC-4CF9-AC75-5CD111EC213D")
        let subscription = PeripheralSubscription(characteristic: char, transformer: transformer)
        client.register(subscription: subscription) { _ in }
        XCTAssertEqual(fakeCBPeripheral.setNotifyParameters.invokes, 1)
        XCTAssertEqual(fakeCBPeripheral.setNotifyParameters.params?.enabled, true)
        XCTAssertEqual(fakeCBPeripheral.setNotifyParameters.params?.characteristic.uuidString, "14047276-33BC-4CF9-AC75-5CD111EC213D")
        XCTAssertEqual(mockSubscriptionRequestQueue.addedRequest.count, 1)
        XCTAssertEqual(mockSubscriptionRequestQueue.addedRequest[0].characteristic?.uuidString, "14047276-33BC-4CF9-AC75-5CD111EC213D")
    }
    
    func testRegisterSubscription_deviceIsNotConnected() {
        fakeCBPeripheral.stateResult = .disconnected
        let char         = StubCharacteristic(_uuidString: "14047276-33BC-4CF9-AC75-5CD111EC213D")
        let subscription = PeripheralSubscription(characteristic: char, transformer: transformer)
        let exp          = expectation(description: "")
        client.register(subscription: subscription) { result in
            switch result {
                case .error(let error):
                    switch error as! PeripheralClient.ClientError {
                        case .deviceNotConnected(let state):
                            XCTAssertEqual(state, .disconnected)
                            XCTAssertEqual(self.fakeCBPeripheral.setNotifyParameters.invokes, 0)
                            XCTAssertEqual(self.mockSubscriptionRequestQueue.addedRequest.count, 0)
                            exp.fulfill()
                        default:
                            break
                    }
                default:
                    break
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Unregister subscription
    
    func testUnregisterSubscription_incorrectCharacteristic() {
        let char = StubCharacteristic(_uuidString: "3B84612F-516B-4BD9-94BF-50B8E606F7AC")
        client.unregisterSubscription(for: char)
        XCTAssertEqual(self.fakeCBPeripheral.setNotifyParameters.invokes, 0)
        XCTAssertEqual(self.mockSubscriptionRequestQueue.removedRequestForCharacteristics.count, 0)
    }
    
    func testUnregisterSubscription_correctCharacteristic() {
        let char = StubCharacteristic(_uuidString: "14047276-33BC-4CF9-AC75-5CD111EC213D")
        client.unregisterSubscription(for: char)
        XCTAssertEqual(self.fakeCBPeripheral.setNotifyParameters.invokes, 1)
        XCTAssertEqual(self.fakeCBPeripheral.setNotifyParameters.params?.enabled, false)
        XCTAssertEqual(self.fakeCBPeripheral.setNotifyParameters.params?.characteristic.uuidString, "14047276-33BC-4CF9-AC75-5CD111EC213D")
        XCTAssertEqual(self.mockSubscriptionRequestQueue.removedRequestForCharacteristics.count, 1)
        XCTAssertEqual(self.mockSubscriptionRequestQueue.removedRequestForCharacteristics[0].uuidString, "14047276-33BC-4CF9-AC75-5CD111EC213D")
    }
    
}
