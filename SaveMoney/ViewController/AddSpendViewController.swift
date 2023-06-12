//
//  AddSpendViewController.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/25.
//

import UIKit

protocol AddSpendViewControllerDelegate: AnyObject {
    func addSpendViewControllerDidCreate()
}

class AddSpendViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var categorySelectedLabel: UILabel!
    @IBOutlet weak var spendTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var categoryTextField: UITextField!
    
    weak var delegate: AddSpendViewControllerDelegate?
    
    var categorys: [NTSpendCategory] = []
    var selectedCategory: NTSpendCategory?
    var currentDate: Date?
    var currentNtMonth: NTMonth?
    
    var ntSpend: NTSpendDay?
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(format: "🎨 : %@ viewDidLoad", String(cString: class_getName(Self.self))))
        self.setupView()
        self.fetchCategory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.spendTextField.becomeFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.view.endEditing(true)
    }
    
    func setupView() {
        self.setupTableView()
        self.spendTextField.placeholder = "금액을 입력해주세요"
        self.categoryTextField.placeholder = "추가할 카테고리 이름을 입력해주세요"
        
        
        if let ntSpend = self.ntSpend {
            self.spendTextField.text = String(ntSpend.spend)
            self.categorySelectedLabel.text = selectedCategory?.name
            self.deleteButton.isHidden = false
            self.selectedCategory = ntSpend.category
        }
    }
    
    
    
    func setupTableView() {
        self.tableView.register(CategoryTableCell.self, forCellReuseIdentifier: CategoryTableCell.reuseIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func fetchCategory() {
        if let categorys: [NTSpendCategory] = dataStore.fetch(NTSpendCategory.self, whereQuery: "id > 0 ORDER BY id DESC") as? [NTSpendCategory] {
            self.categorys = categorys
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addSpend(_ sender: UIButton) {
        if let ntSpend = self.ntSpend {
            guard let category: NTSpendCategory = self.selectedCategory,
                  let spendText: String = self.spendTextField.text,
                  let spend: Int = Int(spendText) else {
                return
            }
            ntSpend.categoryId = category.id
            ntSpend.spend = spend
            self.delegate?.addSpendViewControllerDidCreate()
            self.dismiss(animated: true)
        } else {
            guard let category: NTSpendCategory = self.selectedCategory,
                  let spendText: String = self.spendTextField.text,
                  let spend: Int = Int(spendText),
                  let intDate: Int = self.currentDate?.int1970Date,
                  let ntMonth: NTMonth = self.currentNtMonth else {
                return
            }
     
            
            if (NTSpendDay.create(id: NTObject.index(),
                               date: intDate,
                               spend: spend,
                               monthId: ntMonth.id,
                               groupId: ntMonth.groupId,
                               categoryId: category.id)) != nil {
                self.delegate?.addSpendViewControllerDidCreate()
                self.dismiss(animated: true)
            }
        }
        
        
    }
    
    @IBAction func deleteSpend(_ sender: UIButton) {
        
    }
    
    // 하단 그룹 추가
    @IBAction func addCategory(_ sender: UIButton) {
        if self.categoryTextField.text?.isEmpty == true {
            return
        }
        if (NTSpendCategory.create(id: NTObject.index(), name: self.categoryTextField.text!)) != nil {
            self.fetchCategory()
        }
    }
}

extension AddSpendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CategoryTableCell = tableView.dequeueReusableCell(withIdentifier: CategoryTableCell.reuseIdentifier, for: indexPath) as? CategoryTableCell else {
            return UITableViewCell()
        }
        cell.updateCategory(self.categorys[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categorys.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category: NTSpendCategory = self.categorys[indexPath.row]
        self.selectedCategory = category
        self.categorySelectedLabel.text = category.name
    }
}
