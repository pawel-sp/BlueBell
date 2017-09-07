//
//  PeripheralSubscription.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 24.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

public class PeripheralSubscription<ValueType>: BLEPeripheralOperation {
    
    // MARK: - Properties
    
    public let characteristic: Characteristic
    public let transformer: CharacteristicDataTransformer<ValueType>
    
    // MARK: - Init
    
    public init(characteristic: Characteristic, transformer: CharacteristicDataTransformer<ValueType>) {
        self.characteristic = characteristic
        self.transformer    = transformer
    }
    
    // MARK: - BLEPeripheralOperation
    
    public var responseCharacteristic: Characteristic? {
        return characteristic
    }
    
}
