//
//  FakeCentral.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 30.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth
@testable import BlueBell

class FakeCentral: PeripheralCenter.Central {
    
    // MARK: - Properties
    
    var scanParameters: (invokes: Int, params: (peripheralInterface: Peripheral, options: [String : Any]?, update: (Result<(PeripheralInfo, [PeripheralInfo])>) -> ())?) = (0, nil)
    var stopScanParameters: Int = 0 // invokes
    var connectParameters: (invokes: Int, params: (peripheral: CBPeripheral, options: [String : Any]?, completion: (Result<CBPeripheral>) -> ())?) = (0, nil)
    var disconnectParameters: (invokes: Int, peripheral: CBPeripheral?) = (0, nil)
    
    var connectionResult: Result<CBPeripheral>?
    
    // MARK: - Overrides
    
    override func scan(for peripheralInterface: Peripheral, options: [String : Any]?, update: @escaping (Result<(PeripheralInfo, [PeripheralInfo])>) -> ()) {
        scanParameters = (invokes: scanParameters.invokes + 1, params: (peripheralInterface, options, update))
    }
    
    override func stopScan() {
        stopScanParameters += 1
    }
    
    override func connect(to peripheral: CBPeripheral, options: [String : Any]?, completion: @escaping (Result<CBPeripheral>) -> ()) {
        connectParameters = (invokes: connectParameters.invokes + 1, params: (peripheral: peripheral, options: options, completion: completion))
        if let result = connectionResult {
            completion(result)
        }
    }
    
    override func disconnect(_ peripheral: CBPeripheral, completion: ((Result<CBPeripheral>) -> ())?) {
        disconnectParameters = (invokes: disconnectParameters.invokes + 1, peripheral: peripheral)
    }
    
}
