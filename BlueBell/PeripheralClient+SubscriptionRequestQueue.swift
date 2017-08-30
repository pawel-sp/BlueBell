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
        
        private let queue = DispatchQueue(label: "BlueBell.PeripheralClient.SubscriptionRequestQueue", attributes: .concurrent)
        private var requests: [String : BaseSubscriptionRequest] = [:] // String - UUID of characteristic
        
        // MARK: - Init
        
        init() {}
        
        // MARK: - Actions
        
        func add(request: BaseSubscriptionRequest) {
            queue.async {
                let characteristicUUID = request.characteristic.uuidString
                self.requests[characteristicUUID] = request
            }
        }
        
        func removeRequest(for characteristic: CBCharacteristic) {
            queue.async {
                self.requests[characteristic.uuidString] = nil
            }
        }
        
        func request(for characteristic: CBCharacteristic) -> BaseSubscriptionRequest? {
            var result: BaseSubscriptionRequest?
            queue.sync {
                result = self.requests[characteristic.uuidString]
            }
            return result
        }
        
    }
    
}
