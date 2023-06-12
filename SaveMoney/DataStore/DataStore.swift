//
//  DataStore.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/12.
//

import Foundation

var DBVERSION = 1;

protocol DataStore {
    static var shared: DataStore { get set}
    
    func openDB() -> Bool
    
    func createObject(_ classType: NTObject.Type, columsName: [String], datas: [Any]) -> NTObject?
    
    func updateObject(_ classType: NTObject.Type, columsName: [String], datas: [Any], id: Int) -> Bool
    
    func fetch(_ classType: NTObject.Type, whereQuery: String) -> [NTObject]?
}

