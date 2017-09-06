//
//  ExtendedCBPeripheralDelegate.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 06.09.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

protocol ExtendedCBPeripheralDelegate: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDisconnectError: Error?)
    
}

extension CBPeripheral {
    
    var extendedDelegate: ExtendedCBPeripheralDelegate? {
        set {
            delegate = newValue
        }
        get {
            return delegate as? ExtendedCBPeripheralDelegate
        }
    }
    
}
