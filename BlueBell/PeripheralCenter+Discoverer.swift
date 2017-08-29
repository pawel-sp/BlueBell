//
//  PeripheralCenter+Discoverer.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

extension PeripheralCenter {
    
    class Discoverer: NSObject, CBPeripheralDelegate {
        
        // MARK: - Properties
        
        let peripheral: CBPeripheral
        let interface: Peripheral
        
        private var characteristics: Set<CBCharacteristic> = []
        private var completion: ResultCompletion<Set<CBCharacteristic>>?
        
        // MARK: - Init
        
        init(peripheral: CBPeripheral, interface: Peripheral) {
            self.peripheral = peripheral
            self.interface  = interface
            super.init()
            peripheral.delegate = self
        }
        
        deinit {
            peripheral.delegate = nil
        }
        
        // MARK: - Utilities
        
        func loadCharacteristics(completion: @escaping ResultCompletion<Set<CBCharacteristic>>) {
            let serviceUUIDs = interface.services.map({ $0.cbuuid })
            self.completion  = completion
            peripheral.discoverServices(serviceUUIDs)
        }
        
        // MARK: - CBPeripheralDelegate
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            if let error = error {
                completion?(Result.error(error))
                completion = nil
            } else if let cbServices = peripheral.services?.filter(for: interface) {
                for cbService in cbServices {
                    if let service = interface.service(for: cbService) {
                        peripheral.discoverCharacteristics(
                            service.characteristics.map({ $0.cbuuid }),
                            for: cbService
                        )
                    }
                }
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            if let error = error  {
                completion?(Result.error(error))
                completion = nil
            } else {
                let characteristics = service.characteristics ?? []
                for characteristic in characteristics {
                    self.characteristics.insert(characteristic)
                }
                if interface.characteristicsCount == self.characteristics.count {
                    completion?(Result.value(self.characteristics))
                }
            }
        }
        
    }
    
}
