//
//  Int+.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/30.
//

import Foundation

extension Int {
    func commaString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
