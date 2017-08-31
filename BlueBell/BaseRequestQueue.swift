//
//  BaseRequestQueue.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 31.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

protocol QueueInterface {
    
    func async(execute workItem: @escaping @convention(block) () -> ())
    func sync(execute workItem: () -> ())
}

extension DispatchQueue: QueueInterface {
    
    func async(execute workItem: @escaping @convention(block) () -> ()) {
        async(flags: .barrier, execute: workItem)
    }
    
}

class BaseRequestQueue {
    
    // MARK: - Properties
    
    let queue: QueueInterface
    
    // MARK: - Init
    
    init(queue: QueueInterface) {
        self.queue = queue
    }
    
    convenience init(label: String) {
        self.init(queue: DispatchQueue(label: label, attributes: .concurrent))
    }

}
