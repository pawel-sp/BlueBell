//
//  PeripheralCommand.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 24.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

// Command can have two characteristics. First one for performing operation (read, write) and second one for responses (that one inside Expectation. It is for scenario like you're performing operation on particular characteristic but there would be response from another one.
class PeripheralCommand<ValueType>: BLEPeripheralOperation {
    
    // MARK: - Enums
    
    indirect enum Operation {
        
        case read(Characteristic)
        case write(ValueType, Characteristic)

    }
    
    // MARK: - Structs
    
    struct Expectation {
        
        // Data   - last response from didUpdateValue
        // [Data] - all current responses
        // Bool   - should continue collecting responses or not
        typealias Condition = (Data, [Data]) -> Bool
        
        let characteristic: Characteristic
        let updateValue: Condition?
        let writeValue: Condition?
        
    }
    
    // MARK: - Properties
    
    let operation: Operation
    let expectation: Expectation?
    let transformer: CharacteristicDataTransformer<ValueType>
    
    // MARK: - Init
    
    init(operation: Operation, expectation: Expectation?, transformer: CharacteristicDataTransformer<ValueType>) {
        self.operation      = operation
        self.expectation    = expectation
        self.transformer    = transformer
    }
    
    // MARK: - BLEPeripheralOperation
    
    var responseCharacteristic: Characteristic? {
        return expectation?.characteristic
    }
    
}

// MARK: - Extensions

extension PeripheralCommand.Expectation {
    
    var isEmpty: Bool {
        return writeValue == nil && updateValue == nil
    }
    
}
