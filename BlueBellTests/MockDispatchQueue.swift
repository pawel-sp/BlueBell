//
//  MockDispatchQueue.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 31.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

@testable import BlueBell

class MockDispatchQueue: QueueInterface {
    
    // MARK: - Properties
    
    var syncCounter: Int = 0
    var asyncCounter: Int = 0
    
    // MARK: - QueueInterface
    
    func sync(execute workItem: () -> ()) {
        syncCounter += 1
        workItem()
    }
    
    func async(execute workItem: @escaping @convention(block) () -> ()) {
        asyncCounter += 1
        workItem()
    }
    
}
