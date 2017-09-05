//
//  FakeCBPeripheral.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 29.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import CoreBluetooth

class FakeCBPeripheral: CBPeripheral {
    
    // MARK: - Properties
    
    var discoverServicesParameters: (invokes: Int, serviceUUIDs: [CBUUID]?) = (0, nil)
    var discoverCharacteristicParameters: [String : [CBUUID]] = [:]
    var writeValueParameters: (invokes: Int, params: (value: Data, characteristic: CBCharacteristic)?) = (0, nil)
    var readValueParameters: (invokes: Int, characteristic: CBCharacteristic?) = (0, nil)
    var setNotifyParameters: (invokes: Int, params: (enabled: Bool, characteristic: CBCharacteristic)?) = (0, nil)
    
    var discoverServiceError: Error?
    var discoverCharacteristicError: Error?
    
    var stateResult: CBPeripheralState?
    
    private var serviceResult: StubCBService!
    private var stubServices: [StubCBService]?
    
    let stubIdentifier: UUID
    
    // MARK: - Init 
    
    init(stubIdentifier: UUID) {
        self.stubIdentifier = stubIdentifier
    }
    
    // MARK: - Overrides
    
    override var state: CBPeripheralState {
        return stateResult ?? super.state
    }
    
    override var services: [CBService]? {
        return stubServices ?? super.services
    }
    
    override var identifier: UUID {
        return stubIdentifier
    }
    
    override func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        discoverServicesParameters = (discoverServicesParameters.invokes + 1, serviceUUIDs)
        stubServices = serviceUUIDs?.map({ StubCBService(stubIdentifier: $0) })
        delegate?.peripheral?(self, didDiscoverServices: discoverServiceError)
    }
    
    override func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        if discoverCharacteristicParameters[service.uuid.uuidString] == nil {
            discoverCharacteristicParameters[service.uuid.uuidString] = characteristicUUIDs
        } else {
            discoverCharacteristicParameters[service.uuid.uuidString]?.append(contentsOf: characteristicUUIDs ?? [])
        }
        serviceResult = StubCBService(
            stubIdentifier: service.uuid,
            stubCharacteristics: characteristicUUIDs?.map({ StubCBCharacteristic(stubIdentifier: $0) })
        )
        delegate?.peripheral?(self, didDiscoverCharacteristicsFor: serviceResult, error: self.discoverCharacteristicError)
    }
    
    override func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        writeValueParameters = (invokes: writeValueParameters.invokes + 1, params: (data, characteristic))
    }
    
    override func readValue(for characteristic: CBCharacteristic) {
        readValueParameters = (invokes: readValueParameters.invokes + 1, characteristic: characteristic)
    }
    
    override func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        setNotifyParameters = (invokes: setNotifyParameters.invokes + 1, params: (enabled, characteristic))
    }
    
}
