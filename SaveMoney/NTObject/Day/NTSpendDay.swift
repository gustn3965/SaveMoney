//
//  NTSpend.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import Foundation

// n일의 소비 모델able
// 소비가없는 날에는 해당 날에 데이터없음. 
protocol NTSpendDayable {
    var id: Int { get set }
    var date: Int { get set } // 소비날짜  since 1970 date
    var spend: Int { get set } // 소비금액
    var monthId: Int { get set } // 소비한 지출예상그룹의 id
    var groupId: Int { get set } // 소비한 지출예상그룹의 NTGroup id
    var categoryId: Int { get set } // 소비 카테고리 id
}

class NTSpendDay: NTObject, NTSpendDayable {
    // MARK: Property
    var id: Int
    var date: Int  // since 1970 date
    var spend: Int {
        didSet {
            if DataStore.updateObject(Self.self, columsName: ["spend"], datas: [self.spend], id: self.id) == false {
                self.spend = oldValue
            }
        }
    }
    var monthId: Int
    var groupId: Int
    var categoryId: Int {
        didSet {
            if DataStore.updateObject(Self.self, columsName: ["categoryId"], datas: [self.categoryId], id: self.id) == false {
                self.categoryId = oldValue
            }
        }
    }

    // MARK: Init
    required init(_ dictionary: [String : Any]) {
        self.id = dictionary["id"] as! Int
        self.date = dictionary["date"] as! Int
        self.spend = dictionary["spend"] as! Int
        self.monthId = dictionary["monthId"] as! Int
        self.groupId = dictionary["groupId"] as! Int
        self.categoryId = dictionary["categoryId"] as! Int
        super.init(dictionary)
    }
        
    static func create(id: Int, date: Int, spend: Int, monthId: Int, groupId: Int, categoryId: Int) -> NTObject? {
        let columsName: [String] = ["id", "date", "spend", "monthId", "groupId", "categoryId"]
        let datas: [Any] = [id, date, spend, monthId, groupId, categoryId]
        
        return DataStore.createObject(Self.self, columsName: columsName, datas: datas)
    }
    
    override var debugDescription: String {
        let debugString: String = String(format: "%@\n  -id: %@\n  -date: %@\n  -spend: %@\n  -monthId: %@\n  -groupId: %@\n  -categoryId: %@\n", String(describing: self), String(id), String(date), String(spend), String(monthId), String(groupId), String(categoryId))
        return debugString
    }
    
    var dateDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(self.date))
    }
    
    var day: Int {
        return Date(timeIntervalSince1970: TimeInterval(self.date)).day
    }
    var month: Int {
        return Date(timeIntervalSince1970: TimeInterval(self.date)).month
    }
    
    var year: Int {
        return Date(timeIntervalSince1970: TimeInterval(self.date)).year
    }
    
    
    var category: NTSpendCategory? {
        guard let category: NTSpendCategory = DataStore.fetch(NTSpendCategory.self, whereQuery: String(format:"id == %@", String(self.categoryId)))?.first as? NTSpendCategory else {
            return nil
        }
        return category
    }
    
    
    var categoryName: String {
        return self.category?.name ?? ""
    }
    
    
}


// 이전 모델 
class NTSpend: NTObject, NTSpendDayable {
    // MARK: Property
    var id: Int
    var date: Int  // since 1970 date
    var spend: Int {
        didSet {
            if DataStore.updateObject(Self.self, columsName: ["spend"], datas: [self.spend], id: self.id) == false {
                self.spend = oldValue
            }
        }
    }
    var monthId: Int
    var groupId: Int
    var categoryId: Int {
        didSet {
            if DataStore.updateObject(Self.self, columsName: ["categoryId"], datas: [self.categoryId], id: self.id) == false {
                self.categoryId = oldValue
            }
        }
    }

    // MARK: Init
    required init(_ dictionary: [String : Any]) {
        self.id = dictionary["id"] as! Int
        self.date = dictionary["date"] as! Int
        self.spend = dictionary["spend"] as! Int
        self.monthId = dictionary["monthId"] as! Int
        self.groupId = dictionary["groupId"] as! Int
        self.categoryId = dictionary["categoryId"] as! Int
        super.init(dictionary)
    }
        
    static func create(id: Int, date: Int, spend: Int, monthId: Int, groupId: Int, categoryId: Int) -> NTObject? {
        let columsName: [String] = ["id", "date", "spend", "monthId", "groupId", "categoryId"]
        let datas: [Any] = [id, date, spend, monthId, groupId, categoryId]
        
        return DataStore.createObject(Self.self, columsName: columsName, datas: datas)
    }
    
    override var debugDescription: String {
        let debugString: String = String(format: "%@\n  -id: %@\n  -date: %@\n  -spend: %@\n  -monthId: %@\n  -groupId: %@\n  -categoryId: %@\n", String(describing: self), String(id), String(date), String(spend), String(monthId), String(groupId), String(categoryId))
        return debugString
    }
    
    var dateDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(self.date))
    }
    
    var day: Int {
        return Date(timeIntervalSince1970: TimeInterval(self.date)).day
    }
    var month: Int {
        return Date(timeIntervalSince1970: TimeInterval(self.date)).month
    }
    
    var year: Int {
        return Date(timeIntervalSince1970: TimeInterval(self.date)).year
    }
    
    
    var category: NTSpendCategory? {
        guard let category: NTSpendCategory = DataStore.fetch(NTSpendCategory.self, whereQuery: String(format:"id == %@", String(self.categoryId)))?.first as? NTSpendCategory else {
            return nil
        }
        return category
    }
    
    
    var categoryName: String {
        return self.category?.name ?? ""
    }
    
    
}
