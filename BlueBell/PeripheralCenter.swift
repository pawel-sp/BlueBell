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
    
    func scan(for peripheral: Peripheral, options: [String : Any]?, update: @escaping BufferCompletion<PeripheralInfo>) {
        central.scan(for: peripheral, options: options, update: update)
    }
    
    func stopScan() {
        central.stopScan()
    }

    func connect(to peripheralInput: PeripheralInput, options: [String : Any]?, completion: @escaping ResultCompletion<PeripheralClient>) {
        central.connect(to: peripheralInput.peripheral, options: options) { _ in
            let discoverer = Discoverer(peripheralInput: peripheralInput)
            discoverer.loadCharacteristics() { result in
                switch result {
                    case .value(let characteristics):
                        let client = PeripheralClient(peripheral: peripheralInput.peripheral, characteristics: characteristics)
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
