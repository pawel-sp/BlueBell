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
        
        private var characteristics: [CBCharacteristic] = [] // Set ?, timeouty?
        private var completion: ResultCompletion<[CBCharacteristic]>?
        
        // MARK: - Init
        
        init(peripheralInput: PeripheralInput) {
            self.peripheral = peripheralInput.peripheral
            self.interface  = peripheralInput.interface
            super.init()
            peripheral.delegate = self
        }
        
        // MARK: - Utilities
        
        func loadCharacteristics(completion: @escaping ResultCompletion<[CBCharacteristic]>) {
            let serviceUUIDs = interface.services.map({ $0.cbuuid })
            self.completion  = completion
            peripheral.discoverServices(serviceUUIDs)
        }
        
        // MARK: - CBPeripheralDelegate
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            if let error = error {
                completion?(Result.error(error))
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
            let characteristics = service.characteristics ?? []
            for characteristic in characteristics {
                if !self.characteristics.contains(where: { characteristic.uuidString == $0.uuidString }) {
                    self.characteristics.append(characteristic)
                }
            }
            if interface.characteristicsCount == characteristics.count {
                completion?(Result.value(characteristics))
            }
        }
        
    }
    
}
