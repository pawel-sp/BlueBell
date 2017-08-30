//
//  Extensions.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

// MARK: - Models

extension BlueModel {
    
    var cbuuid: CBUUID {
        return CBUUID(string: uuidString)
    }
    
}

extension Peripheral {
    
    func service(for cbService: CBService) -> Service? {
        return services.filter({ $0.uuidString == cbService.uuidString }).first
    }
    
    var characteristicsCount: Int {
        return services.flatMap({ $0.characteristics }).count
    }
    
}

// MARK: - CoreBluetooth

extension CBCharacteristic {
    
    var uuidString: String {
        return uuid.uuidString
    }
    
}

extension CBService {
    
    var uuidString: String {
        return uuid.uuidString
    }
    
}

extension CBPeripheral {
    
    var uuidString: String {
        return identifier.uuidString
    }
    
}

// MARK: - Array

extension Set where Element: CBCharacteristic {
    
    func first(for characteristic: Characteristic) -> Element? {
        return filter({ $0.uuidString == characteristic.uuidString }).first
    }
    
}

extension Array where Element: CBService {
    
    func filter(for peripheral: Peripheral) -> [Element]? {
        return filter({ service in peripheral.services.contains(where: { service.uuidString == $0.uuidString }) })
    }
    
}
