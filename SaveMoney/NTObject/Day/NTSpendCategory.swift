//
//  NTSpendCategory.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//


import Foundation

// 지출 이름 모델 able
protocol NTSpendCategoryable {
    var id: Int { get set }
    var name: String { get set } // 소비날짜
}

class NTSpendCategory: NTObject, NTSpendCategoryable {
    // MARK: Property
    var id: Int
    var name: String {
        didSet {
            if dataStore.updateObject(Self.self, columsName: ["name"], datas: [self.name], id: self.id) == false {
                self.name = oldValue
            }
        }
    }

    // MARK: Init
    required init(_ dictionary: [String : Any]) {
        self.id = dictionary["id"] as! Int
        self.name = dictionary["name"] as! String
        super.init(dictionary)
    }
    
    static func create(id: Int, name: String) -> NTObject? {
        let columsName: [String] = ["id", "name"]
        let datas: [Any] = [id, name]
        
        return dataStore.createObject(Self.self, columsName: columsName, datas: datas)
    }
    
    override var debugDescription: String {
        let debugString: String = String(format: "%@\n  -id: %@\n  -name: %@\n",  String(describing: self), String(id), name)
        return debugString
    }
    
}
