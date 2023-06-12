//
//  DayListViewController.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import UIKit

class DayListViewController: UIViewController {
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var groupPullDownButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leftMoneyLabel: UILabel!
    @IBOutlet weak var expectedSpendlabel: UILabel!
    @IBOutlet weak var totalMonthExpectedSpendLabel: UILabel!
    
    var monthYearPickerView: MonthYearPickerView = MonthYearPickerView()
    
    var currentNtMonth: NTMonth?
    
    var clickedCellIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format: "🎨 : %@ viewDidLoad", String(cString: class_getName(Self.self))))
        self.setupView()
    }
    
    //MARK: - Setup
    func setupView() {
        self.setupMonthYearPickerView()
        self.setupMonthButton()
        self.setupGroupPullDownButton()
        self.setupTableView()
    }
    
    func setupMonthYearPickerView() {
        self.view.addSubview(self.monthYearPickerView)
        self.monthYearPickerView.delegate = self
        self.monthYearPickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.monthYearPickerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.monthYearPickerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.monthYearPickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            self.monthYearPickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30)
        ])
        self.monthYearPickerView.isHidden = true
    }
    
    func setupMonthButton() {
        self.monthButton.setTitle("\(Date.now.month)월", for: .normal)
        self.monthButton.addTarget(self, action: #selector(clickMonthButton(_:)), for: .touchDown)
    }
    
    func setupGroupPullDownButton() {
        var childrenMenu: [UIMenuElement] = []
        let intDate: Int = self.monthYearPickerView.targetDate.int1970Date
        /*
         ❌ intDate가... since1980이여서, 이 값이 초로 계산이되는구나.....
         Date.now 여서, 이게 초가 포함되네, month만 포함되도록 해야겠는걸,
         */
        
        if let ntMonths: [NTMonth] = dataStore.fetch(NTMonth.self, whereQuery: "date == \(intDate) ORDER BY id DESC") as? [NTMonth] {
            for ntMonth in ntMonths {
                if (self.currentNtMonth == nil) {
                    self.currentNtMonth = ntMonth
                }
                
                let action: UIAction = UIAction(title: "\(ntMonth.groupName)",
                                                image: nil,
                                                identifier: UIAction.Identifier(rawValue: "\(ntMonth.id)"),
                                                discoverabilityTitle: nil,
                                                state: self.currentNtMonth == ntMonth ? .on : .off) { action in
                                                    self.groupPullDownButton.setTitle(ntMonth.groupName, for: .normal)
                                                    self.changeNtMonth(action)
                }
                childrenMenu.append(action)
                if (self.currentNtMonth == ntMonth) {
                    self.groupPullDownButton.setTitle(ntMonth.groupName, for: .normal)
                    self.changeNtMonth(action)
                }
            }
        }
        
        let addAction: UIAction = UIAction(title: "예상 지출 그룹 추가", image: nil, identifier: UIAction.Identifier(rawValue: "add"), discoverabilityTitle: nil, attributes: .destructive, state: .off) { action in
            self.changeNtMonth(action)
        }
        childrenMenu.append(addAction)
        self.groupPullDownButton?.menu = UIMenu(title: "", subtitle: nil, image: nil, identifier: nil, options: .displayInline, children: childrenMenu)
    }
    
    func setupTableView() {
        self.tableView.register(SpendDayTableCell.self, forCellReuseIdentifier: SpendDayTableCell.reuseIdentifier)
        self.tableView.register(SpendDayTableAddCell.self, forCellReuseIdentifier: SpendDayTableAddCell.reuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    func setupMonthPrice() {
        self.expectedSpendlabel.textColor = .systemPink
        guard let currentNtMonth = currentNtMonth else {
            self.leftMoneyLabel.text = "0"
            self.expectedSpendlabel.text = "0"
            return
        }
        
        let leftMoney: Int = currentNtMonth.leftMoney
        let plusString = leftMoney > 0 ? "+" : ""
        
        self.expectedSpendlabel.text = currentNtMonth.expectedSpend.commaString()
        self.leftMoneyLabel.text = plusString + leftMoney.commaString()
        if (leftMoney >= 0) {
            self.leftMoneyLabel.textColor = .systemBlue
        } else {
            self.leftMoneyLabel.textColor = .systemRed
        }
    }
    
    func setupTotalMonthPrice() {
        self.totalMonthExpectedSpendLabel.textColor = .systemOrange
        guard let date: Int = self.currentNtMonth?.date,
              let ntMonths = dataStore.fetch(NTMonth.self, whereQuery: "date == \(date)") as? [NTMonth] else {
            self.totalMonthExpectedSpendLabel.text = "0"
            return
        }
        
        var totalPrice: Int = 0
        ntMonths.forEach {
            totalPrice += $0.expectedSpend
        }
        
        self.totalMonthExpectedSpendLabel.text = totalPrice.commaString()
    }
    
    @objc func clickMonthButton(_ sender: UIView) {
        UIView.animate(withDuration: 0.1) {
            self.monthYearPickerView.isHidden = !self.monthYearPickerView.isHidden
        }
    }
    
    func changeNtMonth(_ action: UIAction) {
        let id: String = action.identifier.rawValue
        if (id == "add") {
            self.showAddMonthViewController()
        } else {
            if let ntMonth: NTMonth = dataStore.fetch(NTMonth.self, whereQuery: "id == \(id)")?.first as? NTMonth {
                self.currentNtMonth = ntMonth
                self.setupMonthPrice()
                self.setupTotalMonthPrice()
                self.tableView.reloadData()
            }
        }
    }
    
    func showAddMonthViewController() {
        Coordinator.shared.showAddMonthViewController(currentMonthDate: self.monthYearPickerView.targetDate,
                                                      from: self)
    }
    
    func showAddMonthViewController(ntMonth: NTMonth) {
        Coordinator.shared.showAddMonthViewController(currentMonthDate: self.monthYearPickerView.targetDate,
                                                       ntMonth: ntMonth,
                                                       from: self)
    }
    
    func showAddSpendViewController(day: Int) {
        guard let currentNtMonth = currentNtMonth else {
            return
        }
        Coordinator.shared.showAddSpendViewController(currentNtMonth: currentNtMonth, day: day, from: self)
    }
    
    func showAddSpendViewController(ntSpend: NTSpendDay) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addMonth: AddSpendViewController = storyboard.instantiateViewController(identifier: "AddSpendViewController") as? AddSpendViewController else { return }
        addMonth.ntSpend = ntSpend
        addMonth.currentNtMonth = self.currentNtMonth
        addMonth.currentDate = ntSpend.dateDate
        addMonth.selectedCategory = ntSpend.category
        addMonth.delegate = self
        show(addMonth, sender: self)
    }
    
    @IBAction func showSpendListViewController(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(tableView.contentSize.width, tableView.contentSize.height),false, 0.0)

        let context = UIGraphicsGetCurrentContext()

        let previousFrame = tableView.frame

        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.contentSize.width, tableView.contentSize.height);
        tableView.layoutIfNeeded()
        tableView.layer.render(in:context!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        tableView.frame = previousFrame
        let imageData = image!.pngData()!
        let documentsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath: URL = documentsURL.appendingPathComponent("saveMoney")
        let fileURL = filePath.appendingPathComponent("image.png")
        try! imageData.write(to: fileURL)
        
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let addMonth: SpendListTableViewController = storyboard.instantiateViewController(identifier: "SpendListTableViewController") as? SpendListTableViewController else { return }
//        addMont   h.ntMonth = self.currentNtMonth
//        show(addMonth, sender: self)
    }
    
    @IBAction func modifyNtMonth(_ sender: Any) {
        guard let currentNtMonth = currentNtMonth else {
            return
        }
        self.showAddMonthViewController(ntMonth: currentNtMonth)
    }
}


extension DayListViewController: MonthYearPickerViewDelegate {
    func monthYearPickerViewDidChange(date: Date) {
        self.currentNtMonth = nil
        self.monthButton.setTitle("\(date.month)월", for: .normal)
        self.setupGroupPullDownButton()
        self.tableView.reloadData()
        self.setupTotalMonthPrice()
    }
    
    func monthYearPickerViewDidClickDoneButton() {
        self.clickMonthButton(self.view)
    }
}

extension DayListViewController: SpendDayTableAddCellDelegate {
    func spendDayTableAddCellClickAdd() {
        self.showAddMonthViewController()
    }
}

extension DayListViewController: SpendDayTableCellDelegate {
    func spendDayTableCellDelegateClickAddSpend(day: Int) {
        self.showAddSpendViewController(day: day)
    }
    
    func spendDayTableCellDelegateClickModifySpend(ntSpend: NTSpendDay) {
        self.showAddSpendViewController(ntSpend: ntSpend)
    }
}



extension DayListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let ntMonth: NTMonth = self.currentNtMonth else {
            guard let cell: SpendDayTableAddCell = tableView.dequeueReusableCell(withIdentifier: SpendDayTableAddCell.reuseIdentifier, for: indexPath) as? SpendDayTableAddCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            return cell
        }
        
        guard let cell: SpendDayTableCell = tableView.dequeueReusableCell(withIdentifier: SpendDayTableCell.reuseIdentifier, for: indexPath) as? SpendDayTableCell else {
            return UITableViewCell()
        }
        let day: Int = indexPath.row + 1
        cell.delegate = self
        // TODO: - (1) 필터 카테고리 지출 파라미터 전달.  Category Id
        cell.setMonth(ntMonth, atDay: day)
        if (self.clickedCellIndexPath == indexPath) {
            cell.showSpendListView()
        } else {
            cell.removeSpendListView()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.currentNtMonth == nil) {
            return 1
        } else {
            return self.monthYearPickerView.targetDate.countOfDay
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.clickedCellIndexPath == indexPath) {
            self.clickedCellIndexPath = nil
            self.tableView.reloadRows(at: [indexPath], with: .top)
        } else {
            
            var indexPaths: [IndexPath] = []
            if let beforeClickedCellIndexPath = self.clickedCellIndexPath {
                indexPaths.append(beforeClickedCellIndexPath)
            }
            self.clickedCellIndexPath = indexPath
            indexPaths.append(indexPath)
            self.tableView.reloadRows(at: indexPaths, with: .bottom)
        }
    }
}

extension DayListViewController: AddMonthViewControllerDelegate {
    func addMontViewControllerDidCreate() {
        self.setupGroupPullDownButton()
    }
}

extension DayListViewController: AddSpendViewControllerDelegate {
    func addSpendViewControllerDidCreate() {
        self.tableView.reloadData()
        self.setupMonthPrice()
        self.setupTotalMonthPrice()
    }
}

extension DayListViewController: ViewControllerUpdatable {
    func updateView() {
        self.tableView.reloadData()
    }
}
