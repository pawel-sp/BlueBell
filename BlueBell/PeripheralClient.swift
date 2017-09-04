//
//  PeripheralClient.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 24.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

class PeripheralClient {
    
    // MARK: - Enums
    
    enum ClientError: Error {
        
        case incorrectCharacteristicForOperation(String) // it means that characteristic with UUID wasn't discovered and passed to PeripheralClient init
        case incorrectCharacteristicForExpectation(String) // it means that characteristic with UUID wasn't discovered and passed to PeripheralClient init
        case missingExpectation // if you are using completion block in perform method you need to specify expectation, otherwise do not use completion block
        
    }
    
    // MARK: - Properties
    
    let peripheral: CBPeripheral
    let characteristics: Set<CBCharacteristic>
    let commandRequestQueue: CommandRequestQueue
    let subscriptionRequestQueue: SubscriptionRequestQueue
    
    private lazy var peripheralDelegate: Delegate = self.preparedPeripheralDelegate()
    
    // MARK: - Init
    
    convenience init(peripheral: CBPeripheral, characteristics: Set<CBCharacteristic>) {
        self.init(
            peripheral: peripheral,
            characteristics: characteristics,
            commandRequestQueue: CommandRequestQueue(),
            subscriptionRequestQueue: SubscriptionRequestQueue()
        )
    }
    
    init(peripheral: CBPeripheral, characteristics: Set<CBCharacteristic>, commandRequestQueue: CommandRequestQueue, subscriptionRequestQueue: SubscriptionRequestQueue) {
        self.peripheral               = peripheral
        self.characteristics          = characteristics
        self.commandRequestQueue      = commandRequestQueue
        self.subscriptionRequestQueue = subscriptionRequestQueue
    }
    
    // MARK: - Actions
    
    func perform<ValueType>(command: PeripheralCommand<ValueType>, completion: ResultCompletion<ValueType>? = nil) {
        
        switch command.operation {
            case .read(let characteristic):
                guard let cbCharacteristic = characteristics.first(for: characteristic) else {
                    completion?(.error(ClientError.incorrectCharacteristicForOperation(characteristic.uuidString)))
                    return
                }
                peripheral.readValue(for: cbCharacteristic)
            case .write(let value, let characteristic):
                guard let cbCharacteristic = characteristics.first(for: characteristic) else {
                    completion?(.error(ClientError.incorrectCharacteristicForOperation(characteristic.uuidString)))
                    return
                }
                let data = command.transformer.transform(valueToData: value)
                peripheral.writeValue(data, for: cbCharacteristic, type: .withResponse)
        }
        
        if let expectedCharacteristic = command.expectation?.characteristic {
            guard let _ = characteristics.first(for: expectedCharacteristic) else {
                completion?(.error(ClientError.incorrectCharacteristicForExpectation(expectedCharacteristic.uuidString)))
                return
            }
        }
        
        if let completion = completion {
            if command.expectation == nil || command.expectation?.isEmpty == true {
                completion(.error(ClientError.missingExpectation))
                return
            } else {
                let request = CommandRequest(command: command, completion: completion)
                commandRequestQueue.add(request: request)
            }
        }
        
    }
    
    func register<ValueType>(subscription: PeripheralSubscription<ValueType>, update: @escaping ResultCompletion<ValueType>) {
        guard let cbCharacteristic = characteristics.first(for: subscription.characteristic) else {
            update(Result.error(ClientError.incorrectCharacteristicForOperation(subscription.characteristic.uuidString)))
            return
        }
        let request = SubscriptionRequest(subscription: subscription, update: update)
        subscriptionRequestQueue.add(request: request)
        peripheral.setNotifyValue(true, for: cbCharacteristic)
    }
    
    func unregisterSubscription(for characteristic: Characteristic) {
        guard let cbCharacteristic = characteristics.first(for: characteristic) else {
            return
        }
        subscriptionRequestQueue.removeRequest(for: cbCharacteristic)
        peripheral.setNotifyValue(false, for: cbCharacteristic)
    }
    
    // MARK: - Private
    
    private func preparedPeripheralDelegate() -> Delegate {
        //timeouts?, loosing connection?
        let didUpdateAction: Completion<CBCharacteristic> = { characteristic, error in
            if error != nil {
                let request = self.commandRequestQueue.removeFirstRequst(for: characteristic)
                request?.finish(error: error)
                // anulowac pozostale requesty na tej charakterystyce? bo zrobi sie rozjazd
            } else {
                // request
                guard let data = characteristic.value, let request = self.commandRequestQueue.firstRequest(for: characteristic) else { return }
                if request.process(update: data) == .finished {
                    request.finish(error: nil)
                    self.commandRequestQueue.removeFirstRequst(for: characteristic)
                }
                // subscription
                self.subscriptionRequestQueue.request(for: characteristic)?.perform(for: data, error: error)
            }
        }
        
        let didWriteAction: Completion<CBCharacteristic> = { characteristic, error in
            if error != nil {
                let request = self.commandRequestQueue.removeFirstRequst(for: characteristic)
                request?.finish(error: error)
            } else {
                guard let data = characteristic.value, let request = self.commandRequestQueue.firstRequest(for: characteristic) else { return }
                if request.process(write: data) == .finished {
                    request.finish(error: nil)
                    self.commandRequestQueue.removeFirstRequst(for: characteristic)
                }
            }
        }
        
        return Delegate(
            peripheral: peripheral,
            didUpdateValue: didUpdateAction,
            didWriteValue: didWriteAction
        )
    }
    
}
