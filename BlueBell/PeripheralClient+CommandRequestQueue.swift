//
//  PeripheralClient+RequestQueue.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

extension PeripheralClient {
    
    class CommandRequestQueue: BaseRequestQueue {
        
        // MARK: - Properties
        
        private var requests: [String : [BaseCommandRequest]] = [:] // String : Characteristic UUID
        
        // MARK: - Init
        
        convenience init() {
            self.init(label: "BlueBell.PeripheralClient.CommandRequestQueue")
        }
        
        // MARK: - Utilities
        
        func add(request: BaseCommandRequest) {
            queue.async {
                let characteristicUUID = request.characteristic.uuidString
                if let _ = self.requests[characteristicUUID] {
                    self.requests[characteristicUUID]?.append(request)
                } else {
                    self.requests[characteristicUUID] = [request]
                }
            }
        }
        
        @discardableResult
        func removeFirstRequst(for characteristic: CBCharacteristic) -> BaseCommandRequest? {
            var result: BaseCommandRequest?
            queue.async {
                result = self.requests[characteristic.uuidString]?.removeFirst()
            }
            return result
        }
        
        func firstRequest(for characteristic: CBCharacteristic) -> BaseCommandRequest? {
            var request: BaseCommandRequest?
            queue.sync {
                request = self.requests[characteristic.uuidString]?.first
            }
            return request
        }
        
    }
    
}
