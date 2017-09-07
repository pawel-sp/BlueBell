//
//  Types.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

// MARK: - Enums

public enum Result<Value> {
    
    case value(Value)
    case error(Error)
    
}

// MARK: - Typealiases

typealias ErrorCompletion               = (Error?) -> ()
typealias ValueCompletion<Value>        = (Value) -> ()
typealias Completion<Value>             = (Value, Error?)  -> ()
typealias BufferCompletion<Value>       = (Value, [Value]) -> ()

public typealias BufferResultCompletion<Value> = (Result<(Value, [Value])>) -> ()
public typealias ResultCompletion<Value>       = (Result<Value>)  -> ()

typealias DataReduce = ([Data]) -> Data

// MARK: - Structs

public struct PeripheralInfo: Hashable, Equatable {
    
    public let peripheral: CBPeripheral
    public let advertisementData: [String : Any]
    public let rssi: NSNumber

    public var hashValue: Int {
        return peripheral.hashValue
    }
    
    public static func ==(lhs: PeripheralInfo, rhs: PeripheralInfo) -> Bool {
        return lhs.peripheral.uuidString == rhs.peripheral.uuidString
    }
    
}
