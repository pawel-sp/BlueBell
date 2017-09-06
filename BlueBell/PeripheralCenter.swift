//
//  PeripheralCenter.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

class PeripheralCenter {
    
    // MARK: - Properties

    let central: Central
    let discovererClass: Discoverer.Type
    
    // MARK: - Init
    
    init(central: Central, discovererClass: Discoverer.Type) {
        self.central         = central
        self.discovererClass = discovererClass
    }
    
    convenience init(central: Central) {
        self.init(central: central, discovererClass: Discoverer.self)
    }
    
    convenience init() {
        self.init(central: Central())
    }
    
    // MARK: - Utilities
    
    func scan(for peripheralInterface: Peripheral, options: [String : Any]?, update: @escaping BufferResultCompletion<PeripheralInfo>) {
        central.scan(for: peripheralInterface, options: options, update: update)
    }
    
    func stopScan() {
        central.stopScan()
    }

    func connect(to cbPeripheral: CBPeripheral, peripheralInterface: Peripheral, options: [String : Any]?, completion: @escaping ResultCompletion<PeripheralClient>) {
        central.connect(to: cbPeripheral, options: options) { connectResult in
            switch connectResult {
                case .value(let value):
                    let discoverer = self.discovererClass.init(peripheral: value, interface: peripheralInterface)
                    discoverer.loadCharacteristics() { characteristicsResult in
                        switch characteristicsResult {
                            case .value(let characteristics):
                                let client = PeripheralClient(peripheral: cbPeripheral, characteristics: characteristics)
                                completion(Result.value(client))
                            case .error(let error):
                                completion(Result.error(error))
                        }
                }
                case .error(let error):
                    completion(Result.error(error))
            }
        }
    }
    
    func disconnect(cbPeripheral: CBPeripheral, completion: @escaping ResultCompletion<CBPeripheral>) {
        central.disconnect(cbPeripheral, completion: completion)
    }
    
}
