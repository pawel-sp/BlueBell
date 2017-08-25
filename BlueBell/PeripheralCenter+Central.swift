//
//  PeripheralCenter+Central.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

extension PeripheralCenter {
  
    class Central: NSObject, CBCentralManagerDelegate {
        
        // MARK: - Enums
        
        enum CentralError: Error {
            
            case failedToConnect
            
        }
        
        // MARK: - Properties
        
        let centralManager: CBCentralManager
        
        private var peripherals: [PeripheralInfo] = []
        private var waitingScanningRequest: (() -> ())?
        private var updateCompletion: BufferCompletion<PeripheralInfo>?
        private var connectCompletion: ResultCompletion<CBPeripheral>?
        
        // MARK: - Init {
        
        override init() {
            centralManager = CBCentralManager(delegate: nil, queue: nil)
            super.init()
            centralManager.delegate = self
        }
        
        // MARK: - Utilities
        
        func scan(for peripheral: Peripheral, options: [String : Any]?, update: @escaping BufferCompletion<PeripheralInfo>) {
            if centralManager.isScanning {
                peripherals.removeAll()
            } else if centralManager.state != .poweredOn {
                waitingScanningRequest = { [weak self] in
                    self?.scan(for: peripheral, options:options, update: update)
                }
            } else {
                let servicesUUID = peripheral.services.map({ CBUUID(string: $0.uuidString) })
                updateCompletion = update
                centralManager.scanForPeripherals(withServices: servicesUUID, options: options)
            }
        }
        
        func stopScan() {
            centralManager.stopScan()
            peripherals.removeAll()
            updateCompletion = nil
        }
        
        func connect(to peripheral: CBPeripheral, options: [String : Any]?, completion: @escaping ResultCompletion<CBPeripheral>) {
            connectCompletion = completion
            centralManager.connect(peripheral, options: options)
        }
        
        // MARK: - CBCentralManagerDelegate
        
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
                case .poweredOn:
                    waitingScanningRequest?()
                    waitingScanningRequest = nil
                default:
                    break
            }
        }
        
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            let newPeripheral: PeripheralInfo = (peripheral, advertisementData, RSSI)
            if !peripherals.contains(where: { $0.peripheral.uuidString == peripheral.identifier.uuidString }) {
                peripherals.insert(newPeripheral, at: 0)
            }
            updateCompletion?(newPeripheral, peripherals)
        }
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            connectCompletion?(Result.value(peripheral))
        }
        
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            connectCompletion?(Result.error(error ?? CentralError.failedToConnect))
        }
        
    }
    
}
