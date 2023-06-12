//
//  MonthYearPickerView.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import UIKit

enum MonthYearPickerViewComponents: Int, CaseIterable {
    case year = 0
    case month = 1
}

protocol MonthYearPickerViewDelegate: AnyObject {
    func monthYearPickerViewDidChange(date: Date)
    func monthYearPickerViewDidClickDoneButton()
}


class MonthYearPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    var doneButton: UIButton = {
        let button: UIButton = UIButton()
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        
        button.configuration = config
        button.setTitle("    확인    ", for: .normal)
        return button
    }()
    
    private let pickerView: UIPickerView = UIPickerView()
    
    private var minYear: Int = 1900
    private var maxYear: Int = 2200
    
    weak var delegate: MonthYearPickerViewDelegate?
    
    var targetDate: Date = Date.nowForMonth()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.backgroundColor = UIColor.systemGray6
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.addSubview(pickerView)
        self.addSubview(doneButton)
        self.doneButton.addTarget(self, action: #selector(clickDoneButton(_:)), for: .touchDown)
        self.pickerView.translatesAutoresizingMaskIntoConstraints = false
        self.doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.pickerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.pickerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.pickerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.pickerView.bottomAnchor.constraint(equalTo: self.doneButton.topAnchor),
            self.doneButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.doneButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
        ])
        
        self.layer.cornerRadius = 10.0
        
        self.targetDate = Date.nowForMonth()
        self.updateDatePickerView()
    }
    
    @objc func clickDoneButton(_ view: UIButton) {
        self.delegate?.monthYearPickerViewDidClickDoneButton()
    }
    
    func updateDatePickerView() {
        self.pickerView.selectRow(self.targetDate.year - minYear, inComponent: MonthYearPickerViewComponents.year.rawValue, animated: true)
        self.pickerView.selectRow(self.targetDate.month - 1, inComponent: MonthYearPickerViewComponents.month.rawValue, animated: true)
    }
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return MonthYearPickerViewComponents.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == MonthYearPickerViewComponents.year.rawValue {
            return maxYear - minYear
        } else {
            return 12
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == MonthYearPickerViewComponents.year.rawValue {
            return "\(minYear + row)"
        } else {
            return "\(row + 1)"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var month: Int = self.targetDate.month
        var year: Int = self.targetDate.year
        
        if component == MonthYearPickerViewComponents.year.rawValue {
            year = (row + minYear)
        } else {
            month = row + 1
        }
        let date: Date = Date.dateFrom(month: month, year: year)
        print(date)
        self.targetDate = date
        self.delegate?.monthYearPickerViewDidChange(date: date)
    }
    
}
