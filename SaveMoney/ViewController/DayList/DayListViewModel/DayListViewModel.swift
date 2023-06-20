//
//  DayListViewModel.swift
//  SaveMoney
//
//  Created by vapor on 2023/06/12.
//

import Foundation
import Combine

class DayListViewModel: ObservableObject {
    
    init(monthDate: Int = Date.nowForMonth().int1970Date) {
        
        self.fetchNtMonths(at: monthDate)
    }
    
    // n달의 NTMonth들
    @Published var ntMonths: [NTMonth] = []
    
    // 선택한 NTMonth의 소비데이터 array
    @Published var monthSpendDayList: [[NTSpendDay]] = []
    
//    @Published var groups: [NTGroup] = []
    
    @Published var currentNtMonth: NTMonth? = nil
    
    private var dateMonth: Int = Date.nowForMonth().int1970Date
    
    // 1. n달의 날짜를 선택해서, NTMonth들을 가져온다. ( UIAction의 갯수 )
    // 2. 2번과 반대로 N월의 NTMonth을 선택하여, 해당 월의 spendDayList를 보여줄 수 있도록한다. ( tableView로 )
    // 3. 소비를 추가하여 data변화가 있어야한다.
    // 4. NTMonth를 추가하여 UIAction에 변화가있어야한다.
    
    func fetchNtMonths(at dateMonth: Int) {
        self.dateMonth = dateMonth
        
        guard let ntMonths: [NTMonth] = DataStore.fetch(NTMonth.self, whereQuery: "date == \(dateMonth) ORDER BY id DESC") as? [NTMonth],
              let first = ntMonths.first else {
//            groups = []
            monthSpendDayList = []
            ntMonths = []
            return
        }

        self.ntMonths = ntMonths
        self.currentNtMonth = first
        self.monthSpendDayList = self.currentNtMonth?.monthSpendList() ?? []
    }
    
    func selectNtMonth(by ntMonthId: String) {
        for month in ntMonths {
            if month.id == Int(ntMonthId)! {
                self.currentNtMonth = month
                self.monthSpendDayList = self.currentNtMonth?.monthSpendList() ?? []
                break
            }
        }
    }
    
    func addNtMonth() {
        self.fetchNtMonths(at: self.dateMonth)
    }
    
    func addSpend() {
        let beforeCurrentNtMonth = self.currentNtMonth
        
        self.fetchNtMonths(at: self.dateMonth)
        
        self.currentNtMonth = beforeCurrentNtMonth
        
        self.monthSpendDayList = self.currentNtMonth?.monthSpendList() ?? []
    }
    
}
