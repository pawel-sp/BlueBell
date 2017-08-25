//
//  ViewController.swift
//  iOS-Client-Example
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import UIKit
import BlueBell

class ViewController: UIViewController {

}





enum LEDCharacteristic: String, Characteristic {
    
    case temperature = "UUID"
    
    var uuidString: String {
        return self.rawValue
    }
    
    static var all: [Characteristic] {
        return [
            LEDCharacteristic.temperature
        ]
    }
    
}

enum LEDService: String, Service {
    
    case main = "UUID"
    
    var uuidString: String {
        return self.rawValue
    }
    
    var characteristics: [Characteristic] {
        return LEDCharacteristic.all
    }
    
    static var all: [Service] {
        return [
            LEDService.main
        ]
    }
    
}

class LEDPeripheral: Peripheral {
    
    var services: [Service] {
        return LEDService.all
    }
    
}

