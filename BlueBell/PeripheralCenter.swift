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

    private let central: Central
    
    // MARK: - Init
    
    init() {
        central = Central()
    }
    
    // MARK: - Utilities
    
    func scan(for peripheralInterface: Peripheral, options: [String : Any]?, update: @escaping BufferCompletion<PeripheralInfo>) {
        central.scan(for: peripheralInterface, options: options, update: update)
    }
    
    func stopScan() {
        central.stopScan()
    }

    func connect(to cbPeripheral: CBPeripheral, peripheralInterface: Peripheral, options: [String : Any]?, completion: @escaping ResultCompletion<PeripheralClient>) {
        central.connect(to: cbPeripheral, options: options) { _ in
            let discoverer = Discoverer(peripheral: cbPeripheral, interface: peripheralInterface)
            discoverer.loadCharacteristics() { result in
                switch result {
                    case .value(let characteristics):
                        let client = PeripheralClient(peripheral: cbPeripheral, characteristics: characteristics)
                        completion(Result.value(client))
                    case .error(let error):
                        completion(Result.error(error))
                    case .empty:
                        completion(Result.empty)
                }
            }
        }
    }
    
//    func reconnect(client: PeripheralClient) -> PeripheralClient {
//        
//    }
    
}
