//
//  StubPeripheral.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 28.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

@testable import BlueBell

class StubPeripheral: Peripheral {
    
    let _services: [Service]
    
    init(_services: [Service]) {
        self._services = _services
    }
    
    var services: [Service] {
        return self._services
    }
    
}
