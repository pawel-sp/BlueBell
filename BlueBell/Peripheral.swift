//
//  Peripheral.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

public protocol Peripheral {
    
    var services: [Service] { get }
    
}
