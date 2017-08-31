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
        
        // MARK: - Properties
        
        let command: PeripheralCommand<ValueType>
        let completion: ResultCompletion<ValueType>
        let reducer: DataReduce
        
        private var updateResponses: [Data] = []
        private var writeResponses: [Data]  = []
        
        private var updateFinished: Bool!
        private var writeFinished: Bool!
        
        // MARK: - Init
        
        // Completion contains final data only from update responses.
        init(command: PeripheralCommand<ValueType>, reducer: @escaping DataReduce, completion: @escaping ResultCompletion<ValueType>) {
            self.command    = command
            self.completion = completion
            self.reducer    = reducer
            
            // if there are no expectations - update is already finished
            self.updateFinished = command.expectation.updateValue == nil
            self.writeFinished  = command.expectation.writeValue == nil
        }
        
        convenience init(command: PeripheralCommand<ValueType>, completion: @escaping ResultCompletion<ValueType>) {
            self.init(
                command: command,
                reducer: { array in
                    return array.reduce(Data()) { data, nextData in
                        var data = data
                        data.append(nextData)
                        return data
                    }
                },
                completion: completion
            )
        }
        
        // MARK: - BaseCommandRequest
        
        var characteristic: Characteristic {
            return command.responseCharacteristic
        }
        
        func process(update data: Data) -> BaseCommandRequestState {
            if !updateFinished {
                updateResponses.append(data)
                self.updateFinished = command.expectation.updateValue?(data, updateResponses) ?? true
            }
            return verifyExpectations()
        }
        
        func process(write data: Data) -> BaseCommandRequestState {
            if !writeFinished {
                writeResponses.append(data)
                self.writeFinished = command.expectation.writeValue?(data, writeResponses) ?? true
            }
            return verifyExpectations()
        }
        
        func finish(error: Error?) {
            if let error = error {
                completion(Result.error(error))
            } else {
                let data  = reducer(updateResponses)
                let value = command.transformer.transform(dataToValue: data)
                completion(Result.value(value))
            }
        }
        
        // MARK: - Private
        
        private func verifyExpectations() -> BaseCommandRequestState {
            return updateFinished && writeFinished ? .finished : .inProgress
        }
        
    }
    
}
