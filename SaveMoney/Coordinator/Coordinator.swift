//
//  Coordinator.swift
//  SaveMoney
//
//  Created by vapor on 2022/12/10.
//

import UIKit

class Coordinator {
    
    static let shared: Coordinator = Coordinator()
    
    private var window: UIWindow?
    
    func setWindow(_ window: UIWindow) {
        self.window = window
    }
    
    private init() {}
    
    var currentViewController: ViewControllerUpdatable?
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let dayList: DayListViewController = storyboard.instantiateViewController(identifier: "DayListViewController") as? DayListViewController else { return }
        self.window?.rootViewController = dayList
        self.window?.makeKeyAndVisible()
        self.currentViewController = dayList
    }
    
    // MARK: - AddMonthViewController
    func showAddMonthViewController(currentMonthDate: Date,
                                    ntMonth: NTMonth? = nil,
                                    from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addMonth: AddMonthViewController = storyboard.instantiateViewController(identifier: "AddMonthViewController") as? AddMonthViewController else { return }
        addMonth.currentMonthDate = currentMonthDate
        if let delegate: AddMonthViewControllerDelegate = viewController as? AddMonthViewControllerDelegate {
            addMonth.delegate = delegate
        }
        addMonth.ntMonth = ntMonth // 수정 or 새로만들지
        
        viewController.show(addMonth, sender: nil)
    }
    
    // MARK: - AddSpendViewController
    func showAddSpendViewController(currentNtMonth: NTMonth,
                                    day: Int,
                                    from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let spend: AddSpendViewController = storyboard.instantiateViewController(identifier: "AddSpendViewController") as? AddSpendViewController else { return }
        spend.currentNtMonth = currentNtMonth
        spend.currentDate = Date.dateFrom(day: day, month: currentNtMonth.month, year: currentNtMonth.year)
        if let delegate: AddSpendViewControllerDelegate = viewController as? AddSpendViewControllerDelegate {
            spend.delegate = delegate
        }
        viewController.show(spend, sender: nil)
    }
    
    func showAddSpendViewController(ntSpend: NTSpendDay) {
        
    }
}
