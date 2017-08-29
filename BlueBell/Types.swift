//
//  Types.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

// MARK: - Enums

enum Result<Value> {
    
    case value(Value)
    case error(Error)
    
}

// MARK: - Typealiases

typealias ResultCompletion<Value> = (Result<Value>)  -> ()
typealias Completion<Value>       = (Value, Error?)  -> ()
typealias BufferCompletion<Value> = (Value, [Value]) -> ()

// MARK: - Structs

struct PeripheralInfo: Hashable, Equatable {
    
    let peripheral: CBPeripheral
    let advertisementData: [String : Any]
    let rssi: NSNumber

    var hashValue: Int {
        return peripheral.hashValue
    }
    
    static func ==(lhs: PeripheralInfo, rhs: PeripheralInfo) -> Bool {
        return lhs.peripheral.uuidString == rhs.peripheral.uuidString
    }
    
}
