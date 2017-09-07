//
//  PeripheralClient.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 24.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

public protocol PeripheralClientDelegate: class {
    
    func peripheralClient(_ peripheralClient: PeripheralClient, didDisconnectError: Error?)
    
}

public class PeripheralClient {
    
    // MARK: - Enums
    
    public enum ClientError: Error {
        
        case incorrectCharacteristicForOperation(String) // it means that characteristic with UUID wasn't discovered and passed to PeripheralClient init
        case incorrectCharacteristicForExpectation(String) // it means that characteristic with UUID wasn't discovered and passed to PeripheralClient init
        case missingExpectation // if you are using completion block in perform method you need to specify expectation, otherwise do not use completion block
        case deviceNotConnected(CBPeripheralState)
        case deviceNotResponding // it means either device is disconnected or there no expected updateValue or writeValue response
        
    }
    
    // MARK: - Properties
    
    public weak var delegate: PeripheralClientDelegate?
    
    let peripheral: CBPeripheral
    let characteristics: Set<CBCharacteristic>
    let commandRequestQueue: CommandRequestQueue
    let subscriptionRequestQueue: SubscriptionRequestQueue
    let config: Config
    
    private var watchdog: Watchdog!
    private var peripheralDelegate: Delegate!
    
    // MARK: - Init
    
    convenience init(peripheral: CBPeripheral, characteristics: Set<CBCharacteristic>, config: Config = .default) {
        self.init(
            peripheral: peripheral,
            characteristics: characteristics,
            commandRequestQueue: CommandRequestQueue(),
            subscriptionRequestQueue: SubscriptionRequestQueue(),
            config: config
        )
    }
    
    init(peripheral: CBPeripheral, characteristics: Set<CBCharacteristic>, commandRequestQueue: CommandRequestQueue, subscriptionRequestQueue: SubscriptionRequestQueue, config: Config = .default) {
        self.peripheral               = peripheral
        self.characteristics          = characteristics
        self.commandRequestQueue      = commandRequestQueue
        self.subscriptionRequestQueue = subscriptionRequestQueue
        self.config                   = config
        
        self.peripheralDelegate       = self.preparedPeripheralDelegate()
        self.watchdog                 = self.preparedWatchdog()
    }
    
    deinit {
        self.commandRequestQueue.reset()
        self.watchdog.stop()
    }
    
    // MARK: - Actions
    
    public func perform<ValueType>(command: PeripheralCommand<ValueType>, completion: ResultCompletion<ValueType>? = nil) {
        guard peripheral.state == .connected else {
            completion?(.error(ClientError.deviceNotConnected(peripheral.state)))
            return
        }
        guard let cbCharacteristic = characteristics.first(for: command.operation.characteristic) else {
            completion?(.error(ClientError.incorrectCharacteristicForOperation(command.operation.characteristic.uuidString)))
            return
        }
        if let expectedCharacteristic = command.expectation?.characteristic, characteristics.first(for: expectedCharacteristic) == nil {
            completion?(.error(ClientError.incorrectCharacteristicForExpectation(expectedCharacteristic.uuidString)))
            return
        }
        if let completion = completion, (command.expectation == nil || command.expectation?.isEmpty == true) {
            completion(.error(ClientError.missingExpectation))
            return
        }
        if let completion = completion {
            let request = CommandRequest(command: command, completion: completion)
            commandRequestQueue.add(
                operation: { [weak self] in
                    switch command.operation {
                        case .read(_):
                            self?.peripheral.readValue(for: cbCharacteristic)
                        case .write(let value, _):
                            let data = command.transformer.transform(valueToData: value)
                            self?.peripheral.writeValue(data, for: cbCharacteristic, type: .withResponse)
                    }
                    // here we know for for sure every command inside the queue has expectation - it's necessary, otherwise watchdog would invoke timeout block because delegate's method won't stop it.
                    self?.watchdog.carryOn()
                },
                for: request
            )
        }
    }
    
    public func register<ValueType>(subscription: PeripheralSubscription<ValueType>, update: @escaping ResultCompletion<ValueType>) {
        if peripheral.state != .connected {
            update(.error(ClientError.deviceNotConnected(peripheral.state)))
            return
        }
        guard let cbCharacteristic = characteristics.first(for: subscription.characteristic) else {
            update(Result.error(ClientError.incorrectCharacteristicForOperation(subscription.characteristic.uuidString)))
            return
        }
        let request = SubscriptionRequest(subscription: subscription, update: update)
        subscriptionRequestQueue.add(request: request)
        peripheral.setNotifyValue(true, for: cbCharacteristic)
    }
    
    public func unregisterSubscription(for characteristic: Characteristic) {
        guard let cbCharacteristic = characteristics.first(for: characteristic) else {
            return
        }
        subscriptionRequestQueue.removeRequest(for: cbCharacteristic)
        peripheral.setNotifyValue(false, for: cbCharacteristic)
    }
    
    // MARK: - Private
    
    private func preparedPeripheralDelegate() -> Delegate {
        
        let didUpdateAction: Completion<CBCharacteristic> = { [weak self] characteristic, error in
            if error != nil {
                let request = self?.commandRequestQueue.dropFirstRequst(for: characteristic)
                request?.finish(error: error)
            } else {
                // request
                guard let data = characteristic.value, let request = self?.commandRequestQueue.firstRequest(for: characteristic) else { return }
                if request.process(update: data) == .finished {
                    request.finish(error: nil)
                    self?.commandRequestQueue.dropFirstRequst(for: characteristic)
                    
                }
                // subscription
                self?.subscriptionRequestQueue.request(for: characteristic)?.perform(for: data, error: error)
            }
            // watchdog
            self?.verifyWatchdog()
        }
        
        let didWriteAction: Completion<CBCharacteristic> = { [weak self] characteristic, error in
            if error != nil {
                let request = self?.commandRequestQueue.dropFirstRequst(for: characteristic)
                request?.finish(error: error)
            } else {
                // request
                guard let data = characteristic.value, let request = self?.commandRequestQueue.firstRequest(for: characteristic) else { return }
                if request.process(write: data) == .finished {
                    request.finish(error: nil)
                    self?.commandRequestQueue.dropFirstRequst(for: characteristic)
                }
            }
            // watchdog
            self?.verifyWatchdog()
        }
        
        let didDisconnect: ErrorCompletion = { [weak self] error in
            if let sself = self {
                self?.delegate?.peripheralClient(sself, didDisconnectError: error)
            }
        }
        
        return Delegate(
            peripheral: peripheral,
            didUpdateValue: didUpdateAction,
            didWriteValue: didWriteAction,
            didDisconnect: didDisconnect
        )
    }
    
    private func preparedWatchdog() -> Watchdog {
        return Watchdog(
            barrier: { [weak self] in
                self?.commandRequestQueue.allRequests.forEach({ request in
                    request.finish(error: ClientError.deviceNotResponding)
                })
                self?.commandRequestQueue.reset()
            },
            timeout: config.commandsTimeout
        )
    }
    
    private func verifyWatchdog() {
        if commandRequestQueue.isEmpty {
            watchdog.stop()
        } else {
            watchdog.carryOn()
        }
    }
    
}
