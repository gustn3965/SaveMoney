//
//  DataStore.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/12.
//

import Foundation

var DBVERSION = 1;

protocol DataStoreable {
    static var shared: DataStoreable { get set}
    
    func openDB() -> Bool
    
    func createObject(_ classType: NTObject.Type, columsName: [String], datas: [Any]) -> NTObject?
    
    func updateObject(_ classType: NTObject.Type, columsName: [String], datas: [Any], id: Int) -> Bool
    
    func fetch(_ classType: NTObject.Type, whereQuery: String?) -> [NTObject]?
    
    func fetchAll(_ classType: NTObject.Type) -> [NTObject]?
    
    
    func migrationNTSpend()
    func migrationNTCategory()
    func removeOldNTSpendTable()
    func removeOldNTCategoryTable()
}

