//
//  NTMonth.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import Foundation

// n달의 지출 예상 그룹 모델able
protocol NTMonthleable {
    var id: Int { get set }
    var date: Int { get set } // 소비 달 (month) since 1970 date
    var groupId: Int { get set } // 지출예상그룹의 이름 id
    var spendType: Int { get set } // 소비타입
    var expectedSpend: Int { get set } // 이번달 총 지출 예정 금액
    var everyExpectedSpend: Int { get set } // 매일 소비 지출 예정 금액
    var additionalMoney: Int { get set } 
}

class NTMonth: NTObject, NTMonthleable {
    // MARK: DB Property
    var id: Int
    var date: Int
    var groupId: Int {
        didSet {
            if dataStore.updateObject(Self.self, columsName: ["groupId"], datas: [self.groupId], id: self.id) == false {
                self.groupId = oldValue
            }
        }
    }
    var spendType: Int {
        didSet {
            if dataStore.updateObject(Self.self, columsName: ["spendType"], datas: [self.spendType], id: self.id) == false {
                self.spendType = oldValue
            }
        }
    }
    var expectedSpend: Int {
        didSet {
            if dataStore.updateObject(Self.self, columsName: ["expectedSpend"], datas: [self.expectedSpend], id: self.id) == false {
                self.expectedSpend = oldValue
            }
        }
    }
    var everyExpectedSpend: Int {
        didSet {
            if dataStore.updateObject(Self.self, columsName: ["everyExpectedSpend"], datas: [self.everyExpectedSpend], id: self.id) == false {
                self.everyExpectedSpend = oldValue
            }
        }
    }
    var additionalMoney: Int {
        didSet {
            if dataStore.updateObject(Self.self, columsName: ["additionalMoney"], datas: [self.additionalMoney], id: self.id) == false {
                self.additionalMoney = oldValue
            }
        }
    }
    
    // MARK: Property
    
    
    // MARK: Init
    required init(_ dictionary: [String : Any]) {
        self.id = dictionary["id"] as! Int
        self.date = dictionary["date"] as! Int
        self.groupId = dictionary["groupId"] as! Int
        self.spendType = dictionary["spendType"] as! Int
        self.expectedSpend = dictionary["expectedSpend"] as! Int
        self.everyExpectedSpend = dictionary["everyExpectedSpend"] as! Int
        self.additionalMoney = dictionary["additionalMoney"] as! Int
        super.init(dictionary)
    }
    
    static func create(id: Int, date: Int, groupId: Int, spendType: Int, expectedSpend: Int, everyExpectedSpend: Int, additionalMoney: Int) -> NTObject? {
        let columsName: [String] = ["id", "date", "groupId", "spendType", "expectedSpend", "everyExpectedSpend", "additionalMoney"]
        let datas: [Any] = [id, date, groupId, spendType, expectedSpend, everyExpectedSpend, additionalMoney]
        
        return dataStore.createObject(Self.self, columsName: columsName, datas: datas)
    }
    
    override var debugDescription: String {
        let debugString: String = String(format: "%@\n  -id: %@\n  -date: %@\n  -groupId: %@\n  -spendType: %@\n  -expectedSpend: %@\n  -everyExpectedSpend: %@\n  -additionalMoeny: %@\n", String(describing: self), String(id), String(date), String(groupId), String(spendType), String(expectedSpend), String(everyExpectedSpend), String(additionalMoney))
        return debugString
    }
    
    var leftMoney: Int {  
        if self.everyExpectedSpend == 0 {
            var spendMoney: Int = 0
            self.spendList().forEach {
                spendMoney += $0.spend
            }
            return self.expectedSpend - spendMoney
        } else {
            var money: Int = self.expectedSpend
            for idx in 1...self.dateDate.countOfDay {
                var spendMoneyForIdx: Int = 0
                var isSpend: Bool = false
                self.spendList(atDay: idx).forEach {
                    spendMoneyForIdx += $0.spend
                    isSpend = true
                }
                if spendMoneyForIdx != 0 || isSpend {
                    money += (-spendMoneyForIdx)
                } else {
                    money -= self.everyExpectedSpend
                }
            }
            return money
        }
    }
    
    var dateDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(self.date))
    }
    
    var month: Int {
        return Date(timeIntervalSince1970: TimeInterval(self.date)).month
    }
    
    var year: Int {
        return Date(timeIntervalSince1970: TimeInterval(self.date)).year
    }
    
}