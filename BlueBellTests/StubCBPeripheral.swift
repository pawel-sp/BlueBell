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
    let stubServices: [StubCBService]?
    
    // MARK: - Init
    
    init(stubIdentifier: UUID, stubServices: [StubCBService]? = nil) {
        self.stubIdentifier = stubIdentifier
        self.stubServices   = stubServices
    }
    
    // MARK: - Overrides
    
    override var identifier: UUID {
        return stubIdentifier
    }
    
    override var services: [CBService]? {
        return stubServices ?? super.services
    }
    
}
