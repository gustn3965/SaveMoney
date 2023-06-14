//
//  DayListViewController.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import UIKit
import Combine

class DayListViewController: UIViewController {
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var groupPullDownButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leftMoneyLabel: UILabel!
    @IBOutlet weak var expectedSpendlabel: UILabel!
    @IBOutlet weak var allMonthExpectedSpendLabel: UILabel!
    @IBOutlet weak var everyExpectedSpendLabel: UILabel!
    @IBOutlet weak var totalLeftMoneyLabel: UILabel!
    
    var monthYearPickerView: MonthYearPickerView = MonthYearPickerView()
    
    var clickedCellIndexPath: IndexPath?
    
    var viewModel: DayListViewModel = DayListViewModel()
    var disposableBag = Set<AnyCancellable>()
    var data: [[NTSpendDay]] = []  // TODO: - 6/12 viewModel이면...이렇게 따로빼나 ?
    var currentNtMonth: NTMonth?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format: "🎨 : %@ viewDidLoad", String(cString: class_getName(Self.self))))
        self.setupView()
        
        self.bindingViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let indexPathToScroll = IndexPath(row: Date().day, section: 0)
        if (tableView.numberOfRows(inSection: 0) > indexPathToScroll.row) {
            tableView.scrollToRow(at: indexPathToScroll, at: .middle, animated: true)
        }
    }
    
    func bindingViewModel() {
        
        self.viewModel.$ntMonths.sink(receiveValue: { (allNtMonth: [NTMonth]) in
            var childrenMenu: [UIMenuElement] = []
            
            self.allMonthExpectedSpendLabel.textColor = .systemOrange
            var totalPrice: Int = 0
            var totalLeftMoney: Int = 0
            for month in allNtMonth {
                totalPrice += month.expectedSpend
                totalLeftMoney += month.leftMoney
                let customAction: UIAction = UIAction(title: "\(month.groupName)",
                                                image: nil,
                                                identifier: UIAction.Identifier(rawValue: "\(month.id)"),
                                                discoverabilityTitle: nil,
                                                state: .off) { action in
                                                    self.groupPullDownButton.setTitle(month.groupName, for: .normal)
                                                    self.clickNtMonth(action)
                }
                childrenMenu.append(customAction)
            }
            self.allMonthExpectedSpendLabel.text = totalPrice.commaString()
            self.totalLeftMoneyLabel.text = totalLeftMoney.commaString()
            self.totalLeftMoneyLabel.textColor = totalLeftMoney >= 0 ? .systemBlue : .systemRed
            
            let addAction: UIAction = UIAction(title: "예상 지출 그룹 추가", image: nil, identifier: UIAction.Identifier(rawValue: "add"), discoverabilityTitle: nil, attributes: .destructive, state: .off) { action in
                self.clickNtMonth(action)
            }
            childrenMenu.append(addAction)
            self.groupPullDownButton?.menu = UIMenu(title: "", subtitle: nil, image: nil, identifier: nil, options: .displayInline, children: childrenMenu)
        }).store(in: &disposableBag)
        
        self.viewModel.$currentNtMonth.sink { ntMonth in
            self.expectedSpendlabel.textColor = .systemPink
            guard let currentNtMonth = ntMonth else {
                self.leftMoneyLabel.text = "0"
                self.expectedSpendlabel.text = "0"
                self.everyExpectedSpendLabel.text = "0"
                return
            }
            self.currentNtMonth = currentNtMonth
            
            let leftMoney: Int = currentNtMonth.leftMoney
            let plusString = leftMoney > 0 ? "+" : ""
            
            self.expectedSpendlabel.text = currentNtMonth.expectedSpend.commaString()
            self.leftMoneyLabel.text = plusString + leftMoney.commaString()
            self.leftMoneyLabel.textColor = leftMoney >= 0 ? .systemBlue : .systemRed
            self.everyExpectedSpendLabel.textColor = .orange
            self.everyExpectedSpendLabel.text = currentNtMonth.everyExpectedSpend.commaString()
            
            
            self.groupPullDownButton.setTitle(currentNtMonth.groupName, for: .normal)
        }.store(in: &disposableBag)
        
        self.viewModel.$monthSpendDayList.sink(receiveValue: { monthSpendDayList in
            self.data = monthSpendDayList
            self.tableView.reloadData()
        }).store(in: &disposableBag)
    }
    
    
    //MARK: - Setup
    func setupView() {
        self.setupMonthYearPickerView()
        self.setupMonthButton()
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
    
    func setupTableView() {
        self.tableView.register(SpendDayTableCell.self, forCellReuseIdentifier: SpendDayTableCell.reuseIdentifier)
        self.tableView.register(SpendDayTableAddCell.self, forCellReuseIdentifier: SpendDayTableAddCell.reuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Action
    @objc func clickMonthButton(_ sender: UIView) {
        UIView.animate(withDuration: 0.1) {
            self.monthYearPickerView.isHidden = !self.monthYearPickerView.isHidden
        }
    }
    
    @IBAction func modifyNtMonth(_ sender: Any) {
        guard let currentNtMonth = currentNtMonth else {
            return
        }
        self.showAddMonthViewController(ntMonth: currentNtMonth)
    }
    
    func clickNtMonth(_ action: UIAction) {
        let id = action.identifier.rawValue
        if (id == "add") {
            self.showAddMonthViewController()
        } else {
            self.viewModel.selectNtMonth(by: id)
        }
    }
    
    @IBAction func showSpendListViewController(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addMonth: SpendListTableViewController = storyboard.instantiateViewController(identifier: "SpendListTableViewController") as? SpendListTableViewController else { return }
        addMonth.ntMonth = self.currentNtMonth
        show(addMonth, sender: self)
    }
    
    
    // MARK: - Coordinate
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
}

// MARK: - MonthYearPickerViewDelegate
extension DayListViewController: MonthYearPickerViewDelegate {
    func monthYearPickerViewDidChange(date: Date) {
        self.currentNtMonth = nil
        self.monthButton.setTitle("\(date.month)월", for: .normal)
        self.viewModel.fetchNtMonths(at: date.int1970Date)
//        self.setupGroupPullDownButton()
//        self.tableView.reloadData()
//        self.setupTotalMonthPrice()
    }
    
    func monthYearPickerViewDidClickDoneButton() {
        self.clickMonthButton(self.view)
    }
}

// MARK: - SpendDayTableAddCellDelegate
extension DayListViewController: SpendDayTableAddCellDelegate {
    func spendDayTableAddCellClickAdd() {
        self.showAddMonthViewController()
    }
}

// MARK: - SpendDayTableCellDelegate
extension DayListViewController: SpendDayTableCellDelegate {
    func spendDayTableCellDelegateClickAddSpend(day: Int) {
        self.showAddSpendViewController(day: day)
    }
    
    func spendDayTableCellDelegateClickModifySpend(ntSpend: NTSpendDay) {
        self.showAddSpendViewController(ntSpend: ntSpend)
    }
}


// MARK: - UITableViewDataSource, Delegate
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
        let spendList: [NTSpendDay] = data[indexPath.row]
        cell.delegate = self
        // TODO: - (1) 필터 카테고리 지출 파라미터 전달.  Category Id
        cell.updateView(spendList, ntMonth: ntMonth, atDay: day)
        
        if (self.clickedCellIndexPath == indexPath) {
            cell.showSpendListView()
        } else {
            cell.removeSpendListView()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count == 0 ? 1 : data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.clickedCellIndexPath == indexPath) {
            self.clickedCellIndexPath = nil
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            
        } else {
            
            var indexPaths: [IndexPath] = []
            if let beforeClickedCellIndexPath = self.clickedCellIndexPath {
                indexPaths.append(beforeClickedCellIndexPath)
            }
            self.clickedCellIndexPath = indexPath
            indexPaths.append(indexPath)
            UIView.performWithoutAnimation {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}

// MARK: - AddMonthViewControllerDelegate
extension DayListViewController: AddMonthViewControllerDelegate {
    func addMontViewControllerDidCreate() {
        self.viewModel.addNtMonth()
    }
}


// MARK: - AddSpendViewControllerDelegate
extension DayListViewController: AddSpendViewControllerDelegate {
    func addSpendViewControllerDidCreate() {
        self.viewModel.addSpend()
    }
}

extension DayListViewController: ViewControllerUpdatable {
    func updateView() {
        self.tableView.reloadData()
    }
}
