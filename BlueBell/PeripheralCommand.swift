//
//  PeripheralCommand.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 24.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

class PeripheralCommand<ValueType>: BLEPeripheralOperation {
    
    // MARK: - Enums
    
    enum Operation {
        
        case read
        case write(ValueType)
        
    }
    
    // MARK: - Structs
    
    struct Expectation {
        
        // Data   - last response from didUpdateValue
        // [Data] - all current responses
        // Bool   - should continue collecting responses or not
        typealias Expectation = (Data, [Data]) -> Bool
        
        let updateValue: Expectation?
        let writeValue:  Expectation?
        
    }
    
    // MARK: - Properties
    
    let characteristic: Characteristic
    let operation: Operation
    let expectation: Expectation
    let transformer: CharacteristicDataTransformer<ValueType>
    
    // MARK: - Init
    
    init(characteristic: Characteristic, operation: Operation, expectation: Expectation, transformer: CharacteristicDataTransformer<ValueType>) {
        self.characteristic = characteristic
        self.operation      = operation
        self.expectation    = expectation
        self.transformer    = transformer
    }
    
}
