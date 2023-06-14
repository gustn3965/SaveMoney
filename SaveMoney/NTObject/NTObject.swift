//
//  NTObject.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import Foundation

class NTObject: NSObject {
    
    required init(_ dictionary: [String: Any]) {
        
    }
    
    override init() {
        
    }
    
    static func index() -> Int {
        let time: TimeInterval = Date().timeIntervalSince1970
        return Int(time * 10000) // 빠르게 호출되는 경우 같은 값이 나올수있으므로, 최대한 소수점 가져옴 
    }
}

