//
//  PeripheralClient+Notifier.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

extension PeripheralClient {
    
    class Notifier {
        
        // MARK: - Properties
        
        private var notifications: [String : BaseNotification] = [:]
        
        // MARK: - Init
        
        init() {}
        
        // MARK: - Actions
        
        func add(notification: BaseNotification) {
            let characteristicUUID = notification.characteristic.uuidString
            self.notifications[characteristicUUID] = notification
        }
        
        func removeNotification(for characteristic: CBCharacteristic) {
            notifications[characteristic.uuid.uuidString] = nil
        }
        
        func notification(for characteristic: CBCharacteristic) -> BaseNotification? {
            return notifications[characteristic.uuid.uuidString]
        }
        
    }
    
}
