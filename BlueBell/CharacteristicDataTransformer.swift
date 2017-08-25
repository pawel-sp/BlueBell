//
//  CharacteristicDataTransformer.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 24.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

protocol CharacteristicDataTransformerInterface {
    
    associatedtype ValueType
    
    func transform(valueToData: ValueType) -> Data
    func transform(dataToValue: Data) -> ValueType
    
}

class CharacteristicDataTransformer<T>: CharacteristicDataTransformerInterface {
    
    typealias ValueType = T
    
    func transform(valueToData: ValueType) -> Data {
        fatalError("You need to override that method")
    }
    
    func transform(dataToValue: Data) -> ValueType {
        fatalError("You need to override that method")
    }
    
}
