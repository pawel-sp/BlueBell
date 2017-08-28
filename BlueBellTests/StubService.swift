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
    
    init(_uuidString: String) {
        self._uuidString = _uuidString
    }
    
    var uuidString: String {
        return _uuidString
    }
    
    var characteristics: [Characteristic] {
        return []
    }
    
}
