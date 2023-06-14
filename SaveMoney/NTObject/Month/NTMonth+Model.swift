//
//  NTMonth+Model.swift
//  SaveMoney
//
//  Created by vapor on 2023/06/12.
//

import Foundation

extension NTMonth {
    var group: NTGroup? {
        guard let group: NTGroup = DataStore.fetch(NTGroup.self, whereQuery: String(format:"id == %@", String(self.groupId)))?.first as? NTGroup else {
            return nil
        }
        return group
    }
    
    var groupName: String {
        return self.group?.name ?? ""
    }
    
    func spendList(atDay day: Int) -> [NTSpendDay] {
        var list: [NTSpendDay] = []
        for spend in self.existedSpendList() {
            let dayDate: Date = Date(timeIntervalSince1970: TimeInterval(spend.date))
            if dayDate.day == day {
                list.append(spend)
            }
        }
        return list
    }
    
    func existedSpendList() -> [NTSpendDay] {
        guard let ntSpends: [NTSpendDay] = DataStore.fetch(NTSpendDay.self, whereQuery: String(format: "monthId == %@ ORDER BY id", String(self.id))) as? [NTSpendDay] else {
            return []
        }
        return ntSpends
    }
    
    
    
    func spendList(atDay day: Int, in existedSpendList:[NTSpendDay]) -> [NTSpendDay] {
        var list: [NTSpendDay] = []
        for spend in self.existedSpendList() {
            let dayDate: Date = Date(timeIntervalSince1970: TimeInterval(spend.date))
            if dayDate.day == day {
                list.append(spend)
            }
        }
        return list
    }
    
    func monthSpendList() -> [[NTSpendDay]] {
        var array: [[NTSpendDay]] = Array(repeating: [], count: self.dateDate.countOfDay)
        let existedSpendList: [NTSpendDay] = self.existedSpendList()
        
        for day in 1...array.count {
            array[day-1] = self.spendList(atDay: day, in: existedSpendList)
        }
        return array
    }
    
}
