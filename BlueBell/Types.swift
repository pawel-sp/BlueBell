//
//  Types.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

enum Result<Value> {
    
    case empty
    case value(Value)
    case error(Error)
    
}

typealias ResultCompletion<Value> = (Result<Value>)  -> ()
typealias Completion<Value>       = (Value, Error?)  -> ()
typealias BufferCompletion<Value> = (Value, [Value]) -> ()

typealias PeripheralInfo  = (peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber)
typealias PeripheralInput = (peripheral: CBPeripheral, interface: Peripheral)
