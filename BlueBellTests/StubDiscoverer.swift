//
//  StubDiscoverer.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 30.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth
@testable import BlueBell

class StubDiscoverer: PeripheralCenter.Discoverer {
    
    // MARK: - Properties
    
    static var loadCharacteristicsResult: Result<Set<CBCharacteristic>>?
    
    // MARK: - Overrides
    
    override func loadCharacteristics(completion: @escaping (Result<Set<CBCharacteristic>>) -> ()) {
        if let result = StubDiscoverer.loadCharacteristicsResult {
            completion(result)
        } else {
            super.loadCharacteristics(completion: completion)
        }
    }
    
}
