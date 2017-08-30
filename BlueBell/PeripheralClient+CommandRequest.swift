//
//  PeripheralClient+CommandRequest.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

enum BaseCommandRequestState {
    
    case inProgress
    case finished
    
}

protocol BaseCommandRequest: BaseRequest {
    
    func process(update data: Data) -> BaseCommandRequestState
    func process(write data: Data) -> BaseCommandRequestState
    func finish(error: Error?)
    
}

extension PeripheralClient {
    
    class CommandRequest<ValueType>: BaseCommandRequest {
        
        // MARK: - Enums
        
        enum RequestError: Error {
            
            case emptyResponse
            
        }
        
        // MARK: - Properties
        
        let command: PeripheralCommand<ValueType>
        let completion: ResultCompletion<ValueType>
        
        private var updateResponses: [Data] = []
        private var writeResponses: [Data]  = []
        
        // MARK: - Init
        
        init(command: PeripheralCommand<ValueType>, completion: @escaping ResultCompletion<ValueType>) {
            self.command    = command
            self.completion = completion
        }
        
        // MARK: - BaseCommandRequest
        
        var characteristic: Characteristic {
            return command.responseCharacteristic
        }
        
        func process(update data: Data) -> BaseCommandRequestState {
            updateResponses.append(data)
            return verifyExpectations(for: data)
        }
        
        func process(write data: Data) -> BaseCommandRequestState {
            writeResponses.append(data)
            return verifyExpectations(for: data)
        }
        
        func finish(error: Error?) {
            if let error = error {
                completion(Result.error(error))
            } else if updateResponses.isEmpty {
                completion(Result.error(RequestError.emptyResponse))
            } else {
                let data = updateResponses.reduce(Data()) { data, nextData in
                    var data = data
                    data.append(nextData)
                    return data
                }
                let value = command.transformer.transform(dataToValue: data)
                completion(Result.value(value))
            }
        }
        
        // MARK: - Private
        
        private func verifyExpectations(for data: Data) -> BaseCommandRequestState {
            let updateFinished = command.expectation.updateValue?(data, updateResponses) ?? true
            let writeFinished  = command.expectation.writeValue?(data, writeResponses) ?? true
            return (updateFinished && writeFinished) ? .finished : .inProgress
        }
        
    }
    
}
