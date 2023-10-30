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
        
        self.spendListModel = self.makeSpendListModels(spendList)
        self.tableView.reloadData()
    }
    
    func makeSpendListModels(_ spendList: [NTSpendDay]) -> [SpendListModel] {
        let first = spendList.first!
        var models = [SpendListModel(name: first.categoryName, price: first.spend, count: 1)]
        for idx in 1..<spendList.count {
            let next: NTSpendDay = spendList[idx]
            if next.categoryName == models.last!.name {
                models[models.count-1].price += next.spend
                models[models.count-1].count += 1
            } else {
                models.append(SpendListModel(name: next.categoryName, price: next.spend, count: 1))
            }
        }
        models.sort(by: {$0.price > $1.price})
        return models
    }
    
    
    @IBAction func clickCSV(_ sender: Any) {
       
        guard let ntMOnths = self.ntMonth?.group?.allNtMonths else { return }
        
        
        // CSV 데이터 생성
        var csvData = """
        
        """
        
        
        for month in ntMOnths {
            csvData.append("날짜,총소비금액,지출예정금액,category,totalPrice,totalCount\n")
            
            csvData.append("\(month.year)년\(month.month)월,\(month.actualSpendMoney),\(month.expectedSpend),,,\n")
            
            guard let spendList: [NTSpendDay] = DataStore.fetch(NTSpendDay.self, whereQuery: "monthId == \(month.id) ORDER BY categoryId") as? [NTSpendDay], spendList.count > 0 else {
                return
            }
            
            let models = self.makeSpendListModels(spendList)
            models.forEach {
                var string = ""
                string.append(",,," + $0.name + ",")
                string.append("\($0.price),")
                string.append("\($0.count),")
                
                csvData.append(string + "\n")
            }
            
            csvData.append("\n")
        }
        

        let fileManager = FileManager.default

        // Documents 디렉토리 경로 가져오기
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {

            // 파일 경로 생성
            let fileURL = documentsDirectory.appendingPathComponent("example.csv")

            do {
                // CSV 데이터를 파일에 쓰기
                try csvData.write(to: fileURL, atomically: true, encoding: .utf8)
                print("CSV 파일이 생성되었습니다. 경로: \(fileURL.path)")
            } catch {
                // 에러 처리
                print("CSV 파일을 생성하는 데 실패했습니다. 에러: \(error.localizedDescription)")
            }
        }
        
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
