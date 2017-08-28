//
//  StubCBPeripheral.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 28.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

class StubCBPeripheral: CBPeripheral {
    
    // MARK: - Properties
    
    let stubIdentifier: UUID
    
    init(stubIdentifier: UUID) {
        self.stubIdentifier = stubIdentifier
    }
    
    // MARK: - Overrides
    
    override var identifier: UUID {
        return stubIdentifier
    }
    
}
