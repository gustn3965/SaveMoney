//
//  SpendListTableViewController.swift
//  SaveMoney
//
//  Created by vapor on 2022/12/05.
//

import UIKit

struct SpendListModel {
    var name: String
    var price: Int
    var count: Int
}
class SpendListTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ntMonth: NTMonth?
    var spendListModel: [SpendListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format: "🎨 : %@ viewDidLoad", String(cString: class_getName(Self.self))))
        self.setupTableView()
        self.fetchSpendList()
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(SpendListTableCell.self, forCellReuseIdentifier: SpendListTableCell.reuseIdentifier)
    }
    
    func fetchSpendList() {
        guard let ntMonth = self.ntMonth else {
            return
        }
        guard let spendList: [NTSpendDay] = DataStore.fetch(NTSpendDay.self, whereQuery: "monthId == \(ntMonth.id) ORDER BY categoryId") as? [NTSpendDay], spendList.count > 0 else {
            return
        }
        self.calculate(spendList)
    }
    
    func calculate(_ spendList: [NTSpendDay]) {
        let first = spendList.first!
        self.spendListModel = [SpendListModel(name: first.categoryName, price: first.spend, count: 1)]
        for idx in 1..<spendList.count {
            let next: NTSpendDay = spendList[idx]
            if next.categoryName == self.spendListModel.last!.name {
                self.spendListModel[self.spendListModel.count-1].price += next.spend
                self.spendListModel[self.spendListModel.count-1].count += 1
            } else {
                self.spendListModel.append(SpendListModel(name: next.categoryName, price: next.spend, count: 1))
            }
        }
        self.spendListModel.sort(by: {$0.price > $1.price})
        self.tableView.reloadData()
    }
}

extension SpendListTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.spendListModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: SpendListTableCell = tableView.dequeueReusableCell(withIdentifier: SpendListTableCell.reuseIdentifier, for: indexPath) as? SpendListTableCell else {
            return UITableViewCell()
        }
        cell.updateView(spendList: self.spendListModel[indexPath.row])
        return cell
    }
}
