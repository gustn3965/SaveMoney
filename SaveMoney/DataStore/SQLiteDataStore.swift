//
//  SQLiteDataStore.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import Foundation
import SQLite3

class SQLiteDataStore: DataStore {
    
    private var db: OpaquePointer?
    private var cache: [String: [Int: NTObject]] = [:]
    
    static var shared: DataStore = SQLiteDataStore()
    
    private init () {
        if (self.openDB()) {
            
        } else {
            
        }
    }
    
    func object(_ classType: NTObject.Type, id: Int) -> NTObject? {
        let typeString: String = String(describing: classType)
        if let object = cache[typeString]?[id] {
            return object
        } else {
            return self.fetch(classType, whereQuery: "id == \(id)")?.first
        }
    }
    
    func fetch(_ classType: NTObject.Type, whereQuery: String) -> [NTObject]? {
        let typeString: String = String(describing: classType)
        let query: String = "select * from \(typeString) where " + whereQuery
        var result: OpaquePointer? = nil
        
        if (sqlite3_prepare(self.db, query, -1, &result, nil)) != SQLITE_OK {
            print("sql prepare faield")
            return nil
        } else {
            var fetchList: [NTObject] = []
            while sqlite3_step(result) == SQLITE_ROW {
                let columnsCount: Int32 = sqlite3_column_count(result)
                var dictionary: [String: Any] = [:]
                for index in 0..<columnsCount {
                    if let columnName = sqlite3_column_name(result, index) {
                        var value: Any?
                        let name: String = String(cString: columnName)
                        let columnType = sqlite3_column_type(result, index)
                        if (columnType == SQLITE_INTEGER) {
                            value = Int(sqlite3_column_int64(result, index))
                        } else if (columnType == SQLITE_TEXT) {
                            value = String(cString: sqlite3_column_text(result, index))
                        }
                        if let value = value {
                            dictionary[name] = value
                        }
                    }
                }
                if let id: Int = dictionary["id"] as? Int {
                    if let object = cache[typeString]?[id] {
                        fetchList.append(object)
                        
                    } else {
                        let object = classType.init(dictionary)
                        if cache[typeString] == nil {
                            cache[typeString] = [:]
                        }
                        cache[typeString]?[id] = object
                        fetchList.append(object)
                    }
                } else {
                    print("no id")
                }
            }
            
            return fetchList
        }
    }
    
    /*
     NTMonth(date)
        NTDataStore fetch
     
     NTMonth(init)
        NTDataStore createObject
     
     NTSpendDay(date, groupId)
        NTDataStore fetch
     
     NTSpendDay(init)
        NTDataStore createObject
     
     NTSpendDay.update()
        NTDataStore update
     
     */
    
    func createObject(_ classType: NTObject.Type, columsName: [String], datas: [Any]) -> NTObject? {
        let typeString: String = String(describing: classType)
        var query = "insert into \(typeString) ("
        
        columsName.forEach {
            query += "\($0),"
        }
        query.removeLast()
        query += ") "
        
        query += "values ("
        columsName.forEach { _ in
            query += "?,"
        }
        query.removeLast()
        query += ") "
        
        var result: OpaquePointer? = nil
        if (sqlite3_prepare_v2(self.db, query, -1, &result, nil)) != SQLITE_OK {
        } else {
            for index in 0..<datas.count {
                let value = datas[index]
                if let value = value as? NSString {
                    sqlite3_bind_text(result, Int32(index+1), value.utf8String, -1, nil)
//                    sqlite3_bind_text64(result, Int32(index+1), value.utf8CString, 1, nil, UInt8(SQLITE_UTF8))
                } else if let value = value as? Int {
                    sqlite3_bind_int64(result, Int32(index+1), Int64(value))
                }
            }
            
            if sqlite3_step(result) == SQLITE_DONE {
                print("create successFull ")
                if let index = columsName.firstIndex(of: "id"),
                    let id: Int = datas[index] as? Int {
                    let newObject: NTObject? = self.object(classType, id: id)
                    if let id: Int = datas[index] as? Int {
                        if cache[typeString] == nil {
                            cache[typeString] = [:]
                        }
                        cache[typeString]?[id] = newObject
                    }
                    return newObject
                }
            } else {
                print("error : \(String(cString: sqlite3_errmsg(db)!))")
                print("create failed ")
            }
        }
        return nil
    }
    
    
    func updateObject(_ classType: NTObject.Type, columsName: [String], datas: [Any], id: Int) -> Bool {
        let typeString: String = String(describing: classType)
        var query = "UPDATE \(typeString) SET "
        
        columsName.forEach {
            query += "\($0)=?,"
        }
        query.removeLast()
        query += " where id == \(id)"
        
        var result: OpaquePointer? = nil
        if (sqlite3_prepare_v2(self.db, query, -1, &result, nil)) != SQLITE_OK {
            print("sqlite prepare faield ")
            return false
        } else {
            for index in 0..<datas.count {
                let value = datas[index]
                if let value = value as? String {
                    sqlite3_bind_text(result, Int32(index+1), value, -1, nil)
                } else if let value = value as? Int {
                    sqlite3_bind_int64(result, Int32(index+1), Int64(value))
                }
            }
            
            if sqlite3_step(result) == SQLITE_DONE {
                print("update successFull \(typeString) ")
                return true
            } else {
                print("update failed")
                return false
            }
        }
    }
    
    
    // https://youtu.be/Bvgj-QxTBwE

    func createSaveMoneyFolder() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("saveMoney")
        if FileManager.default.fileExists(atPath: filePath.path) == false  {
            do {
                try FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
                print("success to make Folder ")
            } catch (let error) {
                print(error)
            }
        } else {
        
        }
    }
    func openDB() -> Bool {
        self.createSaveMoneyFolder()
        
        let documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath: URL = documentsURL.appendingPathComponent("saveMoney")
        let fileURL = filePath.appendingPathComponent("SaveMoeny.sqlite")
        let log = String(format: "\n -- # db location: %@ \n", fileURL.absoluteString)
        print(log)
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("❌ db not opend ")
            return false
        } else {
            self.excuteQueries()
            return true
        }
    }
    
    private func excuteQueries() {
        for query in self.queryForCreateTable() {
            if (sqlite3_exec(self.db, query, nil, nil, nil)) != SQLITE_OK {
                print("❌ db query failed")
                return;
            }
        }
    }
    
    private func queryForCreateTable() -> [String] {
        return [self.queryForCreateNTMonth(),
                self.queryForCreateNTSpend(),
                self.queryForCreateNTGroup(),
                self.queryForCreateNTCategory()]
    }
    
    private func queryForCreateNTMonth() -> String {
        return """
        CREATE TABLE IF NOT EXISTS NTMonth (
        id                          INTEGER NOT NULL,
        date                        INTEGER NOT NULL,
        groupId                     INTEGER NOT NULL,
        spendType                   INTEGER NOT NULL,
        expectedSpend               INTEGER NOT NULL,
        everyExpectedSpend          INTEGER NOT NULL,
        additionalMoney             INTEGER NOT NULL,
        PRIMARY KEY(id, date, groupId)
        )
        """
    }
    
    private func queryForCreateNTSpend() -> String {
        return """
        CREATE TABLE IF NOT EXISTS NTSpendDay (
        id                           INTEGER NOT NULL,
        date                         INTEGER NOT NULL,
        spend                        INTEGER NOT NULL,
        monthId                      INTEGER NOT NULL,
        groupId                      INTEGER NOT NULL,
        categoryId                INTEGER NOT NULL,
        PRIMARY KEY(id)
        )
        """
    }
    
    private func queryForCreateNTGroup() -> String {
        return """
        CREATE TABLE IF NOT EXISTS NTGroup (
        id                             INTEGER NOT NULL,
        name                           TEXT NOT NULL,
        PRIMARY KEY(id)
        )
        """
    }
    
    private func queryForCreateNTCategory() -> String {
        return """
        CREATE TABLE IF NOT EXISTS NTSpendCategory (
        id                             INTEGER NOT NULL,
        name                           TEXT NOT NULL,
        PRIMARY KEY(id)
        )
        """
    }
}


