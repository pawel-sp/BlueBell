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
        private var connectCompletions: [CBPeripheral : ResultCompletion<CBPeripheral>] = [:]
        
        // MARK: - Init {
        
        override convenience init() {
            self.init(centralManager: CBCentralManager(delegate: nil, queue: nil))
        }
        
        init(centralManager: CBCentralManager) {
            self.centralManager = centralManager
            super.init()
            centralManager.delegate = self
        }
        
        deinit {
            centralManager.delegate = nil
        }
        
        // MARK: - Utilities
        
        func scan(for peripheralInterface: Peripheral, options: [String : Any]?, update: @escaping BufferCompletion<PeripheralInfo>) {
            if centralManager.isScanning {
                stopScan()
                scan(for: peripheralInterface, options: options, update: update)
            } else if centralManager.state != .poweredOn {
                waitingScanningRequest = { [weak self] in
                    self?.scan(for: peripheralInterface, options:options, update: update)
                }
            } else {
                let servicesUUID = peripheralInterface.services.map({ CBUUID(string: $0.uuidString) })
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
            connectCompletions[peripheral] = completion
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
            let newPeripheral = PeripheralInfo(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
            if !peripherals.contains(newPeripheral) {
                peripherals.append(newPeripheral)
                updateCompletion?(newPeripheral, peripherals)
            }
        }
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            connectCompletions[peripheral]?(Result.value(peripheral))
            connectCompletions[peripheral] = nil
        }
        
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            connectCompletions[peripheral]?(Result.error(error ?? CentralError.failedToConnect))
            connectCompletions[peripheral] = nil
        }
        
    }
    
}
