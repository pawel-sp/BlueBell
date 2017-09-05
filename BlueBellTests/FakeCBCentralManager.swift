//
//  FakeCBCentralManager.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 28.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

class FakeCBCentralManager: CBCentralManager {
    
    // MARK: - Properties
    
    var scanParameters: (invokes: Int, params: (serviceUUIDs: [CBUUID]?, options: [String : Any]?)?) = (0, nil)
    var stopScanParameters: Int = 0 // counter
    var connectParameters: (invokes: Int, params: (peripheral: CBPeripheral, options: [String : Any]?)?) = (0, nil)
    var disconnectParameters: (invokes: Int, peripheral: CBPeripheral?) = (0, nil)
    
    var stateResult: CBManagerState? {
        didSet {
            delegate?.centralManagerDidUpdateState(self)
        }
    }
    
    var stubConnectionParams: [String : Error?] = [:] // UUID : Error
    var stubDisconnectionParams: [String : Error?] = [:] // UUID : Error
    
    private var isScanningResult: Bool = false
    
    // MARK: - Overrides
    
    override var state: CBManagerState {
        return stateResult ?? super.state
    }
    
    override func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) {
        isScanningResult = true
        scanParameters = (invokes: scanParameters.invokes + 1, params: (serviceUUIDs: serviceUUIDs, options: options))
        if state == .poweredOn {
            discoverFakePeripherals()
        }
    }
    
    override func stopScan() {
        isScanningResult = false
        stopScanParameters += 1
    }
    
    override var isScanning: Bool {
        return isScanningResult
    }
    
    override func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) {
        connectParameters = (invokes: connectParameters.invokes + 1, params: (peripheral: peripheral, options: options))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let uuidString = peripheral.identifier.uuidString
            let error      = self.stubConnectionParams[uuidString]
            if let error = error {
                self.delegate?.centralManager?(self, didFailToConnect: peripheral, error: error)
            } else {
                self.delegate?.centralManager?(self, didConnect: peripheral)
            }
        }
    }
    
    override func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        disconnectParameters = (disconnectParameters.invokes + 1, peripheral: peripheral)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let uuidString = peripheral.identifier.uuidString
            let error      = self.stubDisconnectionParams[uuidString]
            if let error = error {
                self.delegate?.centralManager?(self, didDisconnectPeripheral: peripheral, error: error)
            } else {
                self.delegate?.centralManager?(self, didDisconnectPeripheral: peripheral, error: nil)
            }
        }
    }
    
    // MARK: - Private
    
    private let fakePeripherals: [(CBPeripheral, [String : Any], NSNumber)] = [
        (StubCBPeripheral(stubIdentifier: UUID(uuidString: "DBB8BB99-6440-4190-8F69-F27AE8867803")!), ["name" : "1"], NSNumber(value: 10)),
        (StubCBPeripheral(stubIdentifier: UUID(uuidString: "DBB8BB99-6440-4190-8F69-F27AE8867803")!), ["name" : "2"], NSNumber(value: 15)),
        (StubCBPeripheral(stubIdentifier: UUID(uuidString: "4294CA7A-27AB-4F55-A760-F4AD4ADB03F4")!), ["name" : "3"], NSNumber(value: 25)),
        (StubCBPeripheral(stubIdentifier: UUID(uuidString: "C50C65BE-E41C-445F-9988-6FF1C11F957E")!), ["name" : "4"], NSNumber(value: 20)),
    ]

    private var discoverCounter: Int = 0
    
    private func discoverFakePeripherals() {
        // it discovers first two the same peripherals, then third one which is different but with error and last one with another id without error
        if discoverCounter == fakePeripherals.count {
            discoverCounter = 0
        } else {
            let info       = fakePeripherals[discoverCounter]
            let peripheral = info.0
            let advData    = info.1
            let rssi       = info.2
            delegate?.centralManager?(self, didDiscover: peripheral, advertisementData: advData, rssi: rssi)
            discoverCounter += 1
            discoverFakePeripherals()
        }
    }
    
}
