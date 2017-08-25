//
//  PeripheralSubscription.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 24.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

class PeripheralSubscription<ValueType>: BLEPeripheralOperation {
    
    // MARK: - Properties
    
    let characteristic: Characteristic
    let transformer: CharacteristicDataTransformer<ValueType>
    
    // MARK: - Init
    
    init(characteristic: Characteristic, transformer: CharacteristicDataTransformer<ValueType>) {
        self.characteristic = characteristic
        self.transformer    = transformer
    }
    
}
