//
//  Dictionary.swift
//  BlueBell
//
//  Created by Paweł Sporysz on 28.08.2017.
//  Copyright © 2017 Paweł Sporysz. All rights reserved.
//

import Foundation

func == (lhs: [String : Any], rhs: [String : Any]) -> Bool {
    return (NSDictionary(dictionary: lhs).isEqual(to: NSDictionary(dictionary: rhs) as! [AnyHashable : Any]))
}
