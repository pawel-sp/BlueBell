//
//  CharacteristicDataTransformer.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 24.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

public protocol CharacteristicDataTransformerInterface {
    
    associatedtype ValueType
    
    func transform(valueToData: ValueType) -> Data
    func transform(dataToValue: Data) -> ValueType
    
}

public class CharacteristicDataTransformer<T>: CharacteristicDataTransformerInterface {
    
    public typealias ValueType = T
    
    public func transform(valueToData: ValueType) -> Data {
        fatalError("You need to override that method")
    }
    
    public func transform(dataToValue: Data) -> ValueType {
        fatalError("You need to override that method")
    }
    
}
