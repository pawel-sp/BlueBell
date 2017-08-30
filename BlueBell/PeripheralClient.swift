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
        
        case incorrectCharacteristic
        // timeout 3 s na jedna paczke
        
    }
    
    // MARK: - Properties
    
    let peripheral: CBPeripheral
    let characteristics: Set<CBCharacteristic>
    
    private let commandRequestQueue      = CommandRequestQueue()
    private let subscriptionRequestQueue = SubscriptionRequestQueue()
    private lazy var peripheralDelegate: Delegate = self.preparedPeripheralDelegate()
    
    // MARK: - Init
    
    init(peripheral: CBPeripheral, characteristics: Set<CBCharacteristic>) {
        self.peripheral      = peripheral
        self.characteristics = characteristics
    }
    
    // MARK: - Actions
    
    func perform<ValueType>(command: PeripheralCommand<ValueType>, completion: ResultCompletion<ValueType>?) {
        switch command.operation {
            case .read(let characteristic):
                guard let cbCharacteristic = characteristics.first(for: characteristic) else {
                    completion?(.error(ClientError.incorrectCharacteristic))
                    return
                }
                peripheral.readValue(for: cbCharacteristic)
            case .write(let value, let characteristic):
                guard let cbCharacteristic = characteristics.first(for: characteristic) else {
                    completion?(.error(ClientError.incorrectCharacteristic))
                    return
                }
                let data = command.transformer.transform(valueToData: value)
                peripheral.writeValue(data, for: cbCharacteristic, type: .withResponse)
        }
        
        if let completion = completion {
            let request = CommandRequest(command: command, completion: completion)
            commandRequestQueue.add(request: request)
        }
    }
    
    func register<ValueType>(subscription: PeripheralSubscription<ValueType>, update: @escaping ResultCompletion<ValueType>) {
//        guard let cbCharacteristic = cbCharacteristic(for: subscription) else {
//            update(.error(ClientError.incorrectCharacteristic))
//            return
//        }
//        let notification = Notification(subscription: subscription, update: update)
//        notifier.add(notification: notification)
//        peripheral.setNotifyValue(true, for: cbCharacteristic)
    }
    
    func unregister(subscriptionFor characteristic: Characteristic) {
        guard let cbCharacteristic = cbCharacteristic(for: characteristic) else {
            return
        }
        subscriptionRequestQueue.removeRequest(for: cbCharacteristic)
        peripheral.setNotifyValue(false, for: cbCharacteristic)
    }
    
    // MARK: - Private
    
//    private func cbCharacteristic(for operation: BLEPeripheralOperation) -> CBCharacteristic? {
//        return cbCharacteristic(for: operation.characteristic)
//    }
    
    private func cbCharacteristic(for characteristic: Characteristic) -> CBCharacteristic? {
        return nil
        return characteristics.first(for: characteristic)
    }
    
    private func preparedPeripheralDelegate() -> Delegate {
        
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
                self.subscriptionRequestQueue.request(for: characteristic)?.perform(for: data)
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
