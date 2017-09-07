//
//  PeripheralCenter.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

public protocol PeripheralCenterDelegate: class {
    
    func peripheralCenter(_ peripheralCenter: PeripheralCenter, centralManagerDidUpdateState state: CBManagerState)
    
}

public class PeripheralCenter {
    
    // MARK: - Properties

    public static let shared = PeripheralCenter()
    
    private(set) var central: Central!
    let discovererClass: Discoverer.Type
    
    public weak var delegate: PeripheralCenterDelegate?
    
    // MARK: - Init
    
    init(central: Central, discovererClass: Discoverer.Type) {
        self.central         = central
        self.discovererClass = discovererClass
        setup()
    }
    
    convenience init(central: Central) {
        self.init(central: central, discovererClass: Discoverer.self)
    }
    
    convenience init() {
        self.init(central: Central())
    }
    
    // MARK: - Setup
    
    private func setup() {
        self.central.centralUpdateState = { [weak self] state in
            if let sself = self {
                self?.delegate?.peripheralCenter(sself, centralManagerDidUpdateState: state)
            }
        }
    }
    
    // MARK: - Utilities
    
    public func scan(for peripheralInterface: Peripheral, options: [String : Any]?, update: @escaping BufferResultCompletion<PeripheralInfo>) {
        central.scan(for: peripheralInterface, options: options, update: update)
    }
    
    public func stopScan() {
        central.stopScan()
    }

    public func connect(to cbPeripheral: CBPeripheral, peripheralInterface: Peripheral, options: [String : Any]?, clientConfig: PeripheralClient.Config = .default, completion: @escaping ResultCompletion<PeripheralClient>) {
        central.connect(to: cbPeripheral, options: options) { connectResult in
            switch connectResult {
                case .value(let value):
                    let discoverer = self.discovererClass.init(peripheral: value, interface: peripheralInterface)
                    discoverer.loadCharacteristics() { characteristicsResult in
                        switch characteristicsResult {
                            case .value(let characteristics):
                                let client = PeripheralClient(peripheral: cbPeripheral, characteristics: characteristics, config: clientConfig)
                                completion(Result.value(client))
                            case .error(let error):
                                completion(Result.error(error))
                        }
                }
                case .error(let error):
                    completion(Result.error(error))
            }
        }
    }
    
    public  func disconnect(cbPeripheral: CBPeripheral, completion: @escaping ResultCompletion<CBPeripheral>) {
        central.disconnect(cbPeripheral, completion: completion)
    }
    
}
