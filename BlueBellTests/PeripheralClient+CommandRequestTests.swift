//
//  PeripheralClient+CommandRequestTests.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 30.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import XCTest
@testable import BlueBell

class PeripheralClient_CommandRequestTests: XCTestCase {
    
    // MARK: - Properties
    
    var stubCharacteristic: StubCharacteristic!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        stubCharacteristic = StubCharacteristic(_uuidString: "1B6D6320-4825-4ED1-B5F4-237729AD748E")
    }
    
    private func request<ValueType>(
        with expectation: PeripheralCommand<ValueType>.Expectation,
        transformer: CharacteristicDataTransformer<ValueType>? = nil,
        reducer: (([Data]) -> Data)? = nil,
        completion: ((Result<ValueType>) -> ())? = nil
    ) -> PeripheralClient.CommandRequest<ValueType>
    {
        let operation      = PeripheralCommand<ValueType>.Operation.read(stubCharacteristic)
        let command        = PeripheralCommand(operation: operation, expectation: expectation, transformer: transformer ?? CharacteristicDataTransformer<ValueType>())
        let block          = { (result: Result<ValueType>) in }
        if let reducer = reducer {
            return PeripheralClient.CommandRequest<ValueType>(command: command, reducer: reducer, completion: completion ?? block)
        } else {
            return PeripheralClient.CommandRequest<ValueType>(command: command, completion: completion ?? block)
        }
    }
    
    // MARK: - Init
    
    func testInit_assignsAllProperties() {
        let operation      = PeripheralCommand<Int>.Operation.read(stubCharacteristic)
        let commandExp     = PeripheralCommand<Int>.Expectation(characteristic: stubCharacteristic, updateValue: nil, writeValue: nil)
        let transformer    = CharacteristicDataTransformer<Int>()
        let command        = PeripheralCommand(operation: operation, expectation: commandExp, transformer: transformer)
        let exp1           = expectation(description: "1")
        let completion     = { (result: Result<Int>) in exp1.fulfill() }
        let exp2           = expectation(description: "2")
        let reduce         = { (array: [Data]) -> Data in exp2.fulfill(); return Data(); }
        let request        = PeripheralClient.CommandRequest<Int>(command: command, reducer: reduce, completion: completion)
        
        XCTAssertTrue(request.command === command)
        request.completion(Result.value(1))
        _ = request.reducer([])
        
        wait(for: [exp1, exp2], timeout: 1)
    }
    
    // MARK: - Process & expectation
    
    func testProcess_noExpectation_update_shouldReturnFinish() {
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(characteristic: stubCharacteristic, updateValue: nil, writeValue: nil))
        let state = request.process(update: Data())
        XCTAssertTrue(state == .finished)
    }
    
    func testProcess_noExpectation_write_shouldReturnFinish() {
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(characteristic: stubCharacteristic, updateValue: nil, writeValue: nil))
        let state = request.process(write: Data())
        XCTAssertTrue(state == .finished)
    }
    
    func testProcess_onlyReadExpectation_update() {
        var counter = 0
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(
            characteristic: stubCharacteristic,
            updateValue: { _, _ in
                counter += 1
                return counter == 2
            },
            writeValue: nil)
        )
        let state1 = request.process(update: Data())
        XCTAssertTrue(state1 == .inProgress)
        let state2 = request.process(update: Data())
        XCTAssertTrue(state2 == .finished)
    }
    
    func testProcess_onlyReadExpectation_write() {
        var counter = 0
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(
            characteristic: stubCharacteristic,
            updateValue: { _, _ in
                counter += 1
                return counter == 2
            },
            writeValue: nil)
        )
        let state1 = request.process(write: Data())
        XCTAssertTrue(state1 == .inProgress)
        let state2 = request.process(write: Data())
        XCTAssertTrue(state2 == .inProgress)
    }
    
    func testProcess_onlyWriteExpectation_update() {
        var counter = 0
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(
            characteristic: stubCharacteristic,
            updateValue: nil,
            writeValue: { _, _ in
                counter += 1
                return counter == 2
            })
        )
        let state1 = request.process(update: Data())
        XCTAssertTrue(state1 == .inProgress)
        let state2 = request.process(update: Data())
        XCTAssertTrue(state2 == .inProgress)
    }
    
    func testProcess_onlyWriteExpectation_write() {
        var counter = 0
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(
            characteristic: stubCharacteristic,
            updateValue: nil,
            writeValue: { _, _ in
                counter += 1
                return counter == 2
            })
        )
        let state1 = request.process(write: Data())
        XCTAssertTrue(state1 == .inProgress)
        let state2 = request.process(write: Data())
        XCTAssertTrue(state2 == .finished)
    }
    
    func testProcess_readAndWriteExpectation_update() {
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(
            characteristic: stubCharacteristic,
            updateValue: { _, _ in
                return true
            },
            writeValue: { _, _ in
                return true
            })
        )
        let state = request.process(update: Data())
        XCTAssertTrue(state == .inProgress)
    }
    
    func testProcess_readAndWriteExpectation_write() {
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(
            characteristic: stubCharacteristic,
            updateValue: { _, _ in
                return true
            },
            writeValue: { _, _ in
                return true
            })
        )
        let state = request.process(write: Data())
        XCTAssertTrue(state == .inProgress)
    }
    
    func testProcess_readAndWriteExpectation_updateAndWrite() {
        var updateCounter = 0
        var writeCounter  = 0
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(
            characteristic: stubCharacteristic,
            updateValue: { _, _ in
                updateCounter += 1
                return updateCounter == 2
            },
            writeValue: { _, _ in
                writeCounter += 1
                return writeCounter == 1
            })
        )
        let state1 = request.process(update: Data())
        XCTAssertTrue(state1 == .inProgress)
        let state2 = request.process(write: Data())
        XCTAssertTrue(state2 == .inProgress)
        let state3 = request.process(update: Data())
        XCTAssertTrue(state3 == .finished)
    }

    func testProcess_readExpectation_afterFinishedState() {
        var counter = 0
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(
            characteristic: stubCharacteristic,
            updateValue: { _, _ in
                counter += 1
                return counter == 1
            },
            writeValue: nil)
        )
        let state1 = request.process(update: Data())
        XCTAssertTrue(state1 == .finished)
        let state2 = request.process(update: Data())
        XCTAssertTrue(state2 == .finished)
    }
    
    func testProcess_writeExpectation_afterFinishedState() {
        var counter = 0
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(
            characteristic: stubCharacteristic,
            updateValue: nil,
            writeValue: { _, _ in
                counter += 1
                return counter == 1
            })
        )
        let state1 = request.process(write: Data())
        XCTAssertTrue(state1 == .finished)
        let state2 = request.process(write: Data())
        XCTAssertTrue(state2 == .finished)
    }
    
    // MARK: - Finish
    
    func testFinish_withError() {
        let nserror = NSError(domain: "test", code: 0, userInfo: nil)
        let exp     = expectation(description: "")
        let request: PeripheralClient.CommandRequest<Int> = self.request(with: PeripheralCommand.Expectation(characteristic: stubCharacteristic, updateValue: nil, writeValue: nil)) { result in
            switch result {
                case .error(let error):
                    XCTAssertTrue(error as NSError === nserror)
                    exp.fulfill()
                case .value:
                    break
            }
        }
        request.finish(error: nserror)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFinish_withResponses() {
        
        class Transformer: CharacteristicDataTransformer<Int> {
            
            var data: Data?
            
            override func transform(dataToValue: Data) -> Int {
                self.data = dataToValue
                return 10
            }
            
        }
        
        let dataResult = Data()
        let transformer = Transformer()
        let exp = expectation(description: "")
        let request: PeripheralClient.CommandRequest<Int> = self.request(
            with: PeripheralCommand.Expectation(characteristic: stubCharacteristic, updateValue: nil, writeValue: nil),
            transformer: transformer,
            reducer: { _ in
                return dataResult
            },
            completion: { result in
                switch result {
                    case .error:
                        break
                    case .value(let value):
                        XCTAssertEqual(value, 10)
                        XCTAssertTrue(transformer.data == dataResult)
                        exp.fulfill()
                }
            }
        )
        request.finish(error: nil)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
