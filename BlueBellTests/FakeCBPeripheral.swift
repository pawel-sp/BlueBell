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
    
    var discoverServiceError: Error?
    var discoverCharacteristicError: Error?
    
    private var serviceResult: StubCBService!
    private var stubServices: [StubCBService]?
    
    let stubIdentifier: UUID
    
    // MARK: - Init 
    
    init(stubIdentifier: UUID) {
        self.stubIdentifier = stubIdentifier
    }
    
    // MARK: - Overrides
    
    override var services: [CBService]? {
        return stubServices ?? super.services
    }
    
    override var identifier: UUID {
        return stubIdentifier
    }
    
    override func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        discoverServicesParameters = (discoverServicesParameters.invokes + 1, serviceUUIDs)
        self.stubServices = serviceUUIDs?.map({ StubCBService(stubIdentifier: $0) })
        delegate?.peripheral?(self, didDiscoverServices: self.discoverServiceError)
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
    
}
