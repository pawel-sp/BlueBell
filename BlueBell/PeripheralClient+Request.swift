//
//  PeripheralClient+Request.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 25.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

enum BaseRequestState {
    
    case inProgress
    case finished
    
}

protocol BaseRequest {
    
    var characteristic: Characteristic { get }
    
    func process(update data: Data) -> BaseRequestState
    func process(write data: Data) -> BaseRequestState
    func finish(error: Error?)
    
}

extension PeripheralClient {
    
    class Request<ValueType>: BaseRequest {
        
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
        
        // MARK: - BaseRequest
        
        var characteristic: Characteristic {
            return command.characteristic
        }
        
        func process(update data: Data) -> BaseRequestState {
            updateResponses.append(data)
            return verifyExpectations(for: data)
        }
        
        func process(write data: Data) -> BaseRequestState {
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
        
        private func verifyExpectations(for data: Data) -> BaseRequestState {
            let updateFinished = command.expectation.updateValue?(data, updateResponses) ?? true
            let writeFinished  = command.expectation.writeValue?(data, writeResponses) ?? true
            return (updateFinished && writeFinished) ? .finished : .inProgress
        }
        
    }
    
}
