//
//  PeripheralClient+Delegate.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

extension PeripheralClient {
    
    class PeripheralDelegate: NSObject, CBPeripheralDelegate {
        
        // MARK: - Properties
        
        let didUpdateValue: Completion<CBCharacteristic>?
        let didWriteValue: Completion<CBCharacteristic>?
        
        init(peripheral: CBPeripheral, didUpdateValue: Completion<CBCharacteristic>?, didWriteValue: Completion<CBCharacteristic>?) {
            self.didUpdateValue = didUpdateValue
            self.didWriteValue  = didWriteValue
            super.init()
            peripheral.delegate = self
        }
        
        // MARK: - CBPeripheralDelegate
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            didUpdateValue?(characteristic, error)
        }
        
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            didWriteValue?(characteristic, error)
        }
        
    }
    
}
