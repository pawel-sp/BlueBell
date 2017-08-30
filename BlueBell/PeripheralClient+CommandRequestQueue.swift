//
//  PeripheralClient+RequestQueue.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

extension PeripheralClient {
    
    class CommandRequestQueue {
        
        // MARK: - Properties
        
        private let queue = DispatchQueue(label: "BlueBell.PeripheralClient.CommandRequestQueue", attributes: .concurrent)
        private var requests: [String : [BaseCommandRequest]] = [:] // String - UUID of characteristic
        
        // MARK: - Init
        
        init() {}
        
        // MARK: - Utilities
        
        func add(request: BaseCommandRequest) {
            queue.async(flags: .barrier) {
                let characteristicUUID = request.characteristic.uuidString
                if let _ = self.requests[characteristicUUID] {
                    self.requests[characteristicUUID]?.append(request)
                } else {
                    self.requests[characteristicUUID] = [request]
                }
            }
        }
        
        func firstRequest(for characteristic: CBCharacteristic) -> BaseCommandRequest? {
            var request: BaseCommandRequest?
            queue.sync {
                request = self.requests[characteristic.uuidString]?.first
            }
            return request
        }
        
        @discardableResult
        func removeFirstRequst(for characteristic: CBCharacteristic) -> BaseCommandRequest? {
            var result: BaseCommandRequest?
            queue.async(flags: .barrier) {
                result = self.requests[characteristic.uuidString]?.remove(at: 0)
            }
            return result
        }
        
    }
    
}
