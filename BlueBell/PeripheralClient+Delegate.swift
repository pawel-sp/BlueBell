//
//  PeripheralClient+Delegate.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

extension PeripheralClient {
    
    class Delegate: NSObject, ExtendedCBPeripheralDelegate {
        
        // MARK: - Properties
        
        let didUpdateValue: Completion<CBCharacteristic>?
        let didWriteValue: Completion<CBCharacteristic>?
        let didDisconnect: ErrorCompletion?
        let peripheral: CBPeripheral
        
        init(
            peripheral: CBPeripheral,
            didUpdateValue: Completion<CBCharacteristic>?,
            didWriteValue: Completion<CBCharacteristic>?,
            didDisconnect: ErrorCompletion?
        ) {
            self.peripheral     = peripheral
            self.didUpdateValue = didUpdateValue
            self.didWriteValue  = didWriteValue
            self.didDisconnect  = didDisconnect
            super.init()
            peripheral.extendedDelegate = self
        }
        
        // MARK: - CBPeripheralDelegate
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            didUpdateValue?(characteristic, error)
        }
        
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            didWriteValue?(characteristic, error)
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDisconnectError: Error?) {
            didDisconnect?(didDisconnectError)
        }
        
    }
    
}
