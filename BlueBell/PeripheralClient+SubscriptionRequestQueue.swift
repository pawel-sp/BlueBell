//
//  PeripheralClient+SubscriptionRequestQueue.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

extension PeripheralClient {
    
    class SubscriptionRequestQueue {
        
        // MARK: - Properties
        
        private var requests: [String : BaseSubscriptionRequest] = [:]
        
        // MARK: - Init
        
        init() {}
        
        // MARK: - Actions
        
        func add(request: BaseSubscriptionRequest) {
            let characteristicUUID = request.characteristic.uuidString
            self.requests[characteristicUUID] = request
        }
        
        func removeRequest(for characteristic: CBCharacteristic) {
            requests[characteristic.uuidString] = nil
        }
        
        func request(for characteristic: CBCharacteristic) -> BaseSubscriptionRequest? {
            return requests[characteristic.uuidString]
        }
        
    }
    
}
