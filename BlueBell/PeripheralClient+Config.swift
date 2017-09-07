//
//  PeripheralClient+Config.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 07.09.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

extension PeripheralClient {
    
    struct Config {
        
        // There could be a case when there was sent operation to peripheral (like readValue or writeValue) but device is not responding (despite it is connected). For such cases that timeout would be used to avoid situation that completion blocks for commands would never be invoked.
        let commandsTimeout: TimeInterval
     
        static var `default`: Config {
            return Config(
                commandsTimeout: 3
            )
        }
        
    }
    
}
