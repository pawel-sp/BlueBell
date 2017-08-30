//
//  PeripheralOperation.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 24.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

protocol BLEPeripheralOperation {
    
    // Characteristic for which operation should wait regarding any responses (update, write)
    var responseCharacteristic: Characteristic { get }
    
}
