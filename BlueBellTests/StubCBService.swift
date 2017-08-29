//
//  StubCBService.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 29.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

class StubCBService: CBService {
    
    // MARK: - Properties
    
    let stubIdentifier: CBUUID
    let stubCharacteristics: [StubCBCharacteristic]?
    
    // MARK: - Init
    
    init(stubIdentifier: CBUUID, stubCharacteristics: [StubCBCharacteristic]? = nil) {
        self.stubIdentifier      = stubIdentifier
        self.stubCharacteristics = stubCharacteristics
    }
    
    // MARK: - Overrides
    
    override var uuid: CBUUID {
        return stubIdentifier
    }
    
    override var characteristics: [CBCharacteristic]? {
        return stubCharacteristics ?? super.characteristics
    }
    
}
