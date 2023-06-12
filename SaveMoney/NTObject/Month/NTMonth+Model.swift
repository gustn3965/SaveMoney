//
//  NTMonth+Model.swift
//  SaveMoney
//
//  Created by vapor on 2023/06/12.
//

import Foundation

extension NTMonth {
    var group: NTGroup? {
        guard let group: NTGroup = dataStore.fetch(NTGroup.self, whereQuery: String(format:"id == %@", String(self.groupId)))?.first as? NTGroup else {
            return nil
        }
        return group
    }
    
    var groupName: String {
        return self.group?.name ?? ""
    }
    
    func spendList(atDay day: Int) -> [NTSpendDay] {
        var list: [NTSpendDay] = []
        for spend in self.spendList() {
            let dayDate: Date = Date(timeIntervalSince1970: TimeInterval(spend.date))
            if dayDate.day == day {
                list.append(spend)
            }
        }
        return list
    }
    
    func spendList() -> [NTSpendDay] {
        guard let ntSpends: [NTSpendDay] = dataStore.fetch(NTSpendDay.self, whereQuery: String(format: "monthId == %@ ORDER BY id", String(self.id))) as? [NTSpendDay] else {
            return []
        }
        return ntSpends
    }
    
}
