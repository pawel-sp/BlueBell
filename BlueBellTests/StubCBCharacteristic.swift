//
//  StubCBCharacteristic.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 29.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

class StubCBCharacteristic: CBCharacteristic {
    
    // MARK: - Properties
    
    let stubIdentifier: CBUUID
    
    // MARK: - Init
    
    init(stubIdentifier: CBUUID) {
        self.stubIdentifier = stubIdentifier
    }
    
    // MARK: - Overrides
    
    override var uuid: CBUUID {
        return stubIdentifier
    }
    
}
