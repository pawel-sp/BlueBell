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
        
    }
    
    enum Result<Value> {
        
        case empty
        case value(Value)
        case error(Error)
        
    }
    
    // MARK: - Typealiases
    
    typealias ResultCompletion<Value> = (Result<Value>) -> ()
    
    // MARK: - Properties
    
    let peripheral: CBPeripheral
    let characteristics: [CBCharacteristic]
    
    private let requestQueue = RequestQueue()
    private let notifier     = Notifier()
    private lazy var peripheralDelegate: PeripheralDelegate = self.preparedPeripheralDelegate()
    
    // MARK: - Init
    
    init(peripheral: CBPeripheral, characteristics: [CBCharacteristic]) {
        self.peripheral      = peripheral
        self.characteristics = characteristics
    }
    
    // MARK: - Actions
    
    func perform<ValueType>(command: PeripheralCommand<ValueType>, completion: @escaping ResultCompletion<ValueType>) {
        
        guard let cbCharacteristic = cbCharacteristic(for: command) else {
            completion(.error(ClientError.incorrectCharacteristic))
            return
        }
        
        switch command.operation {
        case .read:
            peripheral.readValue(for: cbCharacteristic)
        case .write(let value):
            let data = command.transformer.transform(valueToData: value)
            peripheral.writeValue(data, for: cbCharacteristic, type: .withResponse)
        }
        
        let request = Request(command: command, completion: completion)
        requestQueue.add(request: request)
        
    }
    
    func register<ValueType>(subscription: PeripheralSubscription<ValueType>, update: @escaping ResultCompletion<ValueType>) {
        guard let cbCharacteristic = cbCharacteristic(for: subscription) else {
            update(.error(ClientError.incorrectCharacteristic))
            return
        }
        let notification = Notification(subscription: subscription, update: update)
        notifier.add(notification: notification)
        peripheral.setNotifyValue(true, for: cbCharacteristic)
    }
    
    func unregister(subscriptionFor characteristic: Characteristic) {
        guard let cbCharacteristic = cbCharacteristic(for: characteristic) else {
            return
        }
        notifier.removeNotification(for: cbCharacteristic)
        peripheral.setNotifyValue(false, for: cbCharacteristic)
    }
    
    // MARK: - Private
    
    private func cbCharacteristic(for operation: BLEPeripheralOperation) -> CBCharacteristic? {
        return cbCharacteristic(for: operation.characteristic)
    }
    
    private func cbCharacteristic(for characteristic: Characteristic) -> CBCharacteristic? {
        return characteristics.filter({ $0.uuid.uuidString == characteristic.uuidString }).first
    }
    
    private func preparedPeripheralDelegate() -> PeripheralDelegate {
        
        let didUpdateAction: PeripheralDelegate.Action = { characteristic, error in
            if error != nil {
                let request = self.requestQueue.removeFirstRequst(for: characteristic)
                request?.finish(error: error)
            } else {
                // request
                guard let data = characteristic.value, let request = self.requestQueue.firstRequest(for: characteristic) else { return }
                if request.process(update: data) == .finished {
                    request.finish(error: nil)
                    self.requestQueue.removeFirstRequst(for: characteristic)
                }
                // subscription
                self.notifier.notification(for: characteristic)?.perform(for: data)
            }
        }
        
        let didWriteAction: PeripheralDelegate.Action = { characteristic, error in
            if error != nil {
                let request = self.requestQueue.removeFirstRequst(for: characteristic)
                request?.finish(error: error)
            } else {
                guard let data = characteristic.value, let request = self.requestQueue.firstRequest(for: characteristic) else { return }
                if request.process(write: data) == .finished {
                    request.finish(error: nil)
                    self.requestQueue.removeFirstRequst(for: characteristic)
                }
            }
        }
        
        return PeripheralDelegate(
            peripheral: peripheral,
            didUpdateValue: didUpdateAction,
            didWriteValue: didWriteAction
        )
    }
    
}
