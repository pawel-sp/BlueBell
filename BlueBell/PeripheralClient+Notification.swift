//
//  PeripheralClient+Notification.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

protocol BaseNotification {
    
    var characteristic: Characteristic { get }
    func perform(for data:Data)
    
}

extension PeripheralClient {
    
    class Notification<ValueType>: BaseNotification {
        
        // MARK: - Properties
        
        let subscription: PeripheralSubscription<ValueType>
        let update:       ResultCompletion<ValueType>
        
        // MARK: - Init
        
        init(subscription: PeripheralSubscription<ValueType>, update: @escaping ResultCompletion<ValueType>) {
            self.subscription = subscription
            self.update       = update
        }
        
        // MARK: - BaseNotification
        
        var characteristic: Characteristic {
            return subscription.characteristic
        }
        
        func perform(for data:Data) {
            let value = subscription.transformer.transform(dataToValue: data)
            update(Result.value(value))
        }
        
    }
    
}
