//
//  PeripheralClient+Watchdog.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 07.09.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

extension PeripheralClient {
    
    class Watchdog: NSObject {
        
        // MARK: - Properties
        
        let timeout: TimeInterval
        let barrier: ()->()
        
        // MARK: - Init
        
        init(barrier: @escaping ()->(), timeout: TimeInterval) {
            self.barrier = barrier
            self.timeout = timeout
        }
        
        // MARK: - Actions
        
        func carryOn() {
            stop()
            perform(#selector(Watchdog.invokeBarrier), with: nil, afterDelay: timeout)
        }
        
        func stop() {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(Watchdog.invokeBarrier), object: nil)
        }
        
        func invokeBarrier() {
            barrier()
        }
        
    }
    
}
