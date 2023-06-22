//
//  NtMonth+Report.swift
//  SaveMoney
//
//  Created by vapor on 2023/06/20.
//

import Foundation

extension NTMonth {
    var report: String {
        var str: String = "아래는 이번달 지출 내역입니다. \n이번달 목표 지출 예상금액은 \(self.expectedSpend)입니다. \n지출내역에 따른 평가를 해주시기 바랍니다. 전문가스럽게 평가해줘."
        self.existedSpendList().forEach { spend in
            str.append("\n\(spend.dateDate.yyyymmdd) \(spend.categoryName) \(spend.spend)")
        }
        
        return str
    }
}
