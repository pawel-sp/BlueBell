//
//  StubService.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 28.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

@testable import BlueBell

class StubService: Service {
    
    var _uuidString: String
    var _characteristicUUIDStrings: [String]
    
    init(_uuidString: String, _characteristicUUIDStrings: [String] = []) {
        self._uuidString                = _uuidString
        self._characteristicUUIDStrings = _characteristicUUIDStrings
    }
    
    var uuidString: String {
        return _uuidString
    }
    
    var characteristics: [Characteristic] {
        return _characteristicUUIDStrings.map({ StubCharacteristic(_uuidString: $0) })
    }
    
}
