//
//  ViewController.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/12.
//

import UIKit
import SQLite3

let DataStore: DataStoreable = SQLiteDataStore.shared;

class ViewController: UIViewController {

    let index: Int = NTObject.index()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
//    @IBAction func create(_ sender: Any) {
//        print(NTSpend.create(id: self.index, date: Date.intForCurrentDate(), spend: 1000, monthId: 234234, groupId: 1, categoryId: 2))
//    }
//    
//    @IBAction func find(_ sender: Any)
//    {
//        print(dataStore.fetch(NTSpend.self, whereQuery: "id == \(self.index)"))
//    }
//    
//    @IBAction func update(_ sender: Any) {
//        let object: NTSpend = dataStore.fetch(NTSpend.self, whereQuery: "id == \(self.index)")?.first! as! NTSpend
//        object.spend = 50000000
//        
//    }
//    
//    @IBAction func fetchList(_ sender: Any) {
//        print(dataStore.fetch(NTSpend.self, whereQuery: "id > 0 order by id desc")?.count)
//    }
}


