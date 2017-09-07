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
        
        private var requests: [String : [(operation: ()->(), request: BaseCommandRequest)]] = [:] // String = Characteristic UUID
        
        // MARK: - Init
        
        convenience init() {
            self.init(label: "BlueBell.PeripheralClient.CommandRequestQueue")
        }
        
        // MARK: - Utilities
        
        func add(operation: @escaping ()->(), for request: BaseCommandRequest) {
            // if there is no command requests for specific UUID invoke operation immediatelly, otherwise it's gonna be performed after dropping first
            queue.async {
                guard let characteristicUUID = request.characteristic?.uuidString else { return }
                if let _ = self.requests[characteristicUUID] {
                    self.requests[characteristicUUID]?.append((operation, request))
                } else {
                    self.requests[characteristicUUID] = [(operation, request)]
                    operation()
                }
            }
        }
        
        @discardableResult
        func dropFirstRequst(for characteristic: CBCharacteristic) -> BaseCommandRequest? {
            var result: BaseCommandRequest?
            queue.sync {
                result = self.requests[characteristic.uuidString]?.removeFirst().request
                if let first = self.requests[characteristic.uuidString]?.first {
                    first.operation()
                }
            }
            return result
        }
        
        func firstRequest(for characteristic: CBCharacteristic) -> BaseCommandRequest? {
            var request: BaseCommandRequest?
            queue.sync {
                request = self.requests[characteristic.uuidString]?.first?.request
            }
            return request
        }
        
        func reset() {
            requests.removeAll()
        }
        
        var allRequests: [BaseCommandRequest] {
            return requests.map({ $0.value.map({ $0.request }) }).flatMap({ $0 })
        }
        
        var isEmpty: Bool {
            return requests.count == 0
        }
        
    }
    
}
