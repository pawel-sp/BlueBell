//
//  PeripheralCommand.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 24.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

// Command can have two characteristics. First one for performing operation (read, write) and second one for responses (that one inside Expectation. It is for scenario like you're performing operation on particular characteristic but there would be response from another one.
public class PeripheralCommand<ValueType>: BLEPeripheralOperation {
    
    // MARK: - Enums
    
    public indirect enum Operation {
        
        case read(Characteristic)
        case write(ValueType, Characteristic)

    }
    
    // MARK: - Structs
    
    public struct Expectation {
        
        // Data   - last response from didUpdateValue
        // [Data] - all current responses
        // Bool   - should continue collecting responses or not
        public typealias Condition = (Data, [Data]) -> Bool
        
        public let characteristic: Characteristic
        public let updateValue: Condition?
        public let writeValue: Condition?
        
    }
    
    // MARK: - Properties
    
    public let operation: Operation
    public let expectation: Expectation?
    public let transformer: CharacteristicDataTransformer<ValueType>
    
    // MARK: - Init
    
    public init(operation: Operation, expectation: Expectation?, transformer: CharacteristicDataTransformer<ValueType>) {
        self.operation      = operation
        self.expectation    = expectation
        self.transformer    = transformer
    }
    
    // MARK: - BLEPeripheralOperation
    
    public var responseCharacteristic: Characteristic? {
        return expectation?.characteristic
    }
    
}

// MARK: - Extensions

public extension PeripheralCommand.Expectation {
    
    public var isEmpty: Bool {
        return writeValue == nil && updateValue == nil
    }
    
}

public extension PeripheralCommand.Operation {
    
    public var characteristic: Characteristic {
        switch self {
            case .read(let characteristic):
                return characteristic
            case .write(_, let characteristic):
                return characteristic
        }
    }
    
}
