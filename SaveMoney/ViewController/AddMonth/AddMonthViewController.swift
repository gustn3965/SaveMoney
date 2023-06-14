//
//  AddMonthViewController.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import Foundation
import UIKit


protocol AddMonthViewControllerDelegate: AnyObject {
    func addMontViewControllerDidCreate()
}
class AddMonthViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var groupSelectedLabel: UILabel!
    @IBOutlet weak var monthExpedtedSpendTextField: UITextField!
    @IBOutlet weak var expectedSpendSegment: UISegmentedControl!
    
    @IBOutlet weak var groupTextField: UITextField!
    
    var groups: [NTGroup] = []
    
    var selectedGroup: NTGroup?
    var currentMonthDate: Date?
    
    var delegate: AddMonthViewControllerDelegate?
    
    
    var ntMonth: NTMonth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format: "🎨 : %@ viewDidLoad", String(cString: class_getName(Self.self))))
        
        self.setupView()
        
        self.fetchGroup()
        
        if let ntMonth = self.ntMonth {
            self.groupSelectedLabel.text = ntMonth.groupName
            self.monthExpedtedSpendTextField.text = "\(ntMonth.expectedSpend)"
            self.expectedSpendSegment.selectedSegmentIndex = ntMonth.spendType
            self.selectedGroup = ntMonth.group
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.view.endEditing(true)
    }
    
    func setupView() {
        self.setupTableView()
    }
    
    func setupTableView() {
        self.tableView.register(GroupTableCell.self, forCellReuseIdentifier: GroupTableCell.reuseIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func fetchGroup() {
        if let groups: [NTGroup] = DataStore.fetch(NTGroup.self, whereQuery: "id > 0 ORDER BY id DESC") as? [NTGroup] {
            self.groups = groups
            self.tableView.reloadData()
        }
    }
    
    // 확인
    @IBAction func addNtMonth(_ sender: UIButton) {
        if let ntMonth = self.ntMonth {
           guard  let group: NTGroup = self.selectedGroup,
                  let spendText: String = self.monthExpedtedSpendTextField.text,
                  let expectedSpend: Int = Int(spendText),
                  let countOfDay: Int = self.currentMonthDate?.countOfDay else {
                    return
                }
            let isEverySpending: Bool = self.expectedSpendSegment.selectedSegmentIndex == 0
            let everyExpectedSpend: Int = isEverySpending ? expectedSpend / countOfDay : 0
            
            ntMonth.groupId = group.id
            ntMonth.spendType = isEverySpending ? 0 : 1
            ntMonth.everyExpectedSpend = everyExpectedSpend
            ntMonth.expectedSpend = expectedSpend
            
            self.delegate?.addMontViewControllerDidCreate()
            self.dismiss(animated: true)
        } else {
            guard let group: NTGroup = self.selectedGroup,
                  let spendText: String = self.monthExpedtedSpendTextField.text,
                  let expectedSpend: Int = Int(spendText),
                  let intDate: Int = self.currentMonthDate?.int1970Date,
                  let countOfDay: Int = self.currentMonthDate?.countOfDay else {
                return
            }
            let isEverySpending: Bool = self.expectedSpendSegment.selectedSegmentIndex == 0
            let everyExpectedSpend: Int = isEverySpending ? expectedSpend / countOfDay : 0
            
            if (NTMonth.create(id: NTObject.index(),
                           date: intDate,
                           groupId: group.id,
                           spendType: isEverySpending ? 1 : 0,
                           expectedSpend: expectedSpend,
                           everyExpectedSpend: everyExpectedSpend,
                               additionalMoney: 0)) != nil {
                self.delegate?.addMontViewControllerDidCreate()
                self.dismiss(animated: true)
            }
        }
            
    }
    
    // 하단 그룹 추가 
    @IBAction func addGroup(_ sender: UIButton) {
        if self.groupTextField.text?.isEmpty == true {
            return
        }
        if (NTGroup.create(id: NTObject.index(), name: self.groupTextField.text!)) != nil {
            self.fetchGroup()
        }
    }
}

extension AddMonthViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: GroupTableCell = tableView.dequeueReusableCell(withIdentifier: GroupTableCell.reuseIdentifier, for: indexPath) as? GroupTableCell else {
            return UITableViewCell()
        }
        cell.updateGroup(self.groups[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group: NTGroup = self.groups[indexPath.row]
        self.selectedGroup = group
        self.groupSelectedLabel.text = group.name
    }
}
