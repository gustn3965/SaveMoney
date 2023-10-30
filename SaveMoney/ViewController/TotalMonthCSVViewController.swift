//
//  TotalMonthCSVViewController.swift
//  SaveMoney
//
//  Created by kakao on 10/31/23.
//

import UIKit
import WebKit

class TotalMonthCSVViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var ntMonth: NTMonth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        showTextViewCSV()
        
        showWebViewCSV()
    }
    
    
    func showTextViewCSV() {
        let ntMOnths = fetchAllNtMonths()
        
        let text = makeCSVTextFrom(months: ntMOnths)
        
        self.textView.text = text
        
        updateTitleFrom(months: ntMOnths)
    }
    
    func showWebViewCSV() {
        let ntMOnths = fetchAllNtMonths()
        
        let text = makeCSVTextFrom(months: ntMOnths)
        
        let htmlString = """
                <html>
                <head>
                <style>
                table {
                    border-collapse: collapse;
                    width: 100%;
                }
                th, td {
                    border: 1px solid black;
                    padding: 8px;
                    text-align: left;
                }
                </style>
                </head>
                <body>
                <table>
                \(text.split(separator: "\n").map { "<tr>" + $0.split(separator: ",").map { "<td>" + $0 + "</td>" }.joined() + "</tr>" }.joined())
                </table>
                </body>
                </html>
                """
        
        // HTML 문자열을 WKWebView에 로드
        webView.loadHTMLString(htmlString, baseURL: nil)
        
        updateTitleFrom(months: ntMOnths)
    }
    
    func updateTitleFrom(months: [NTMonth]) {
        guard let recentMonth = months.first, let lastMonth = months.last else { return }
        self.titleLabel.text = "\(lastMonth.year)년\(lastMonth.month)월 ~ \(recentMonth.year)년\(recentMonth.month)월 까지 \n\(recentMonth.groupName)의 총내역"
    }
    
    func fetchAllNtMonths() -> [NTMonth] {
        guard let ntMOnths = self.ntMonth?.group?.allNtMonths else { return [] }
        return ntMOnths
    }
    
    func makeCSVTextFrom(months: [NTMonth]) -> String {
        var csvData = """
        
        """
        for month in months {
            csvData.append("category,totalPrice,totalCount,날짜,총소비금액,지출예정금액\n")
            
            csvData.append("_,_,_,\(month.year)년\(month.month)월,\(month.actualSpendMoney),\(month.expectedSpend)\n")
            
            guard let spendList: [NTSpendDay] = DataStore.fetch(NTSpendDay.self, whereQuery: "monthId == \(month.id) ORDER BY categoryId") as? [NTSpendDay], spendList.count > 0 else {
                return ""
            }
            
            let models = self.makeSpendListModels(spendList)
            models.forEach {
                var string = ""
                string.append("" + $0.name + ",")
                string.append("\($0.price),")
                string.append("\($0.count),_,_,_,")
                
                csvData.append(string + "\n")
            }
            
            csvData.append("_,_,_,_,_,_,\n")
        }
        
        return csvData
    }
    
    func asdfs() {
        
        
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
    
    @IBAction func clickSaveToCSVFile(_ sender: Any) {
        guard let text = self.textView.text else { return }
        let fileManager = FileManager.default
        
        // Documents 디렉토리 경로 가져오기
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            
            // 파일 경로 생성
            let fileURL = documentsDirectory.appendingPathComponent("\(ntMonth?.groupName ?? "" )의 총 소비내역서.csv")
            
            do {
                // CSV 데이터를 파일에 쓰기
                try text.write(to: fileURL, atomically: true, encoding: .utf8)
                
                showAlert(title: "성공", message: "CSV 파일이 생성되었습니다. 경로: \(fileURL.path)")
            } catch {
                
                showAlert(title: "실패", message: "CSV 파일을 생성하는 데 실패했습니다. 에러: \(error.localizedDescription)")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // 얼럿을 자동으로 사라지게 하려면 DispatchAfter를 사용
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alertController.dismiss(animated: true, completion: nil)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
