//
//  Date+.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import Foundation

struct WeekDay {
    var isSuday: Bool
    var isSaturday: Bool
    var name: String
    
    init(date: Date) {
        let weekDays: [String] = ["일", "월", "화", "수", "목", "금", "토"]
        let calendar = Calendar.current
        let weekIndex = calendar.dateComponents([.weekday], from: date).weekday! - 1
        self.name = weekDays[weekIndex]
        self.isSuday = weekIndex == 0
        self.isSaturday = weekIndex == 6
    }
}

extension Date {
    static func nowForMonth() -> Date {
        let nowMonth: Int = Date.now.month
        let nowYear: Int = Date.now.year
        return Date.dateFrom(month: nowMonth, year: nowYear)
    }
    
    static func intForCurrentDate() -> Int {
        let time: TimeInterval = Date().timeIntervalSince1970
        return Int(time)
    }
    
    var int1970Date: Int {
        let time: TimeInterval = self.timeIntervalSince1970
        return Int(time)
    }
    
    static func countOfDay(year: Int, month: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }
    
    var countOfDay: Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        let numDays = range.count
        return numDays
    }
    
    var day: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: self).day!
    }
    var month: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.month], from: self).month!
    }
    
    var year: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: self).year!
    }
    
    var weekDay: WeekDay {
        return WeekDay(date: self)
    }
    
    static func dateFrom(month: Int, year: Int) -> Date {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        return date
    }
    
    static func dateFrom(day: Int, month: Int, year: Int) -> Date {
        let dateComponents = DateComponents(year: year, month: month, day: day)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        return date
    }
    
    static func currentWeekDay() -> WeekDay {
        return WeekDay(date: Date.now)
    }
    
//    static func countOfDay(date: Date) -> Int {
//
//        let dateComponents = DateComponents(year: year, month: month)
//        let calendar = Calendar.current
//        let date = calendar.date(from: dateComponents)!
//
//        let range = calendar.range(of: .day, in: .month, for: date)!
//        let numDays = range.count
//        return numDays
//    }
}
