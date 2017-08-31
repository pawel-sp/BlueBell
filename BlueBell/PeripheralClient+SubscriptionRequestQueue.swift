//
//  PeripheralClient+SubscriptionRequestQueue.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

extension PeripheralClient {
    
    class SubscriptionRequestQueue: BaseRequestQueue {
        
        // MARK: - Properties
        
        private var requests: [String : BaseSubscriptionRequest] = [:] // String : Characteristic UUID
        
        // MARK: - Init

        convenience init() {
            self.init(label: "BlueBell.PeripheralClient.SubscriptionRequestQueue")
        }
        
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
