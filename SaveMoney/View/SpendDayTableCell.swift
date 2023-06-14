//
//  SpendDayTableCell.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import Foundation
import UIKit


class SpendModifyButton: UIButton {
    var ntSpend: NTSpendDay?
}

class SpendDayTableLabel: UIView {
    
    // MARK: View
    private let descriptionLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "소비예상금액 : "
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "10000원"
        label.textColor = UIColor.systemOrange
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        let stackView: UIStackView = UIStackView(arrangedSubviews: [descriptionLabel, priceLabel])
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        NSLayoutConstraint.activate(stackView.fitConstarint(to: self, padding: 0))
    }
    
    func updatePrice(_ price: Int, description: String, color: UIColor? = nil) {
        self.priceLabel.text = price.commaString() + "원"
        self.descriptionLabel.text = "\(description) : "
        self.priceLabel.textColor = color == nil ? .systemOrange : color
    }
    
    func updateText(_ text: String, description: String) {
        self.priceLabel.text = text
        self.descriptionLabel.text = "\(description) : "
    }
}

protocol SpendDayTableCellDelegate: AnyObject {
    func spendDayTableCellDelegateClickAddSpend(day: Int)
    func spendDayTableCellDelegateClickModifySpend(ntSpend: NTSpendDay)
}

class SpendDayTableCell: UITableViewCell {
    
    var dayLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        return label
    }()
    
    var expectedSpendLabel: SpendDayTableLabel = SpendDayTableLabel()
    var spendLabel: SpendDayTableLabel = SpendDayTableLabel()
    
    var spendListView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: Property

    var ntMonth: NTMonth!
    var ntSpendList: [NTSpendDay]?
    var day: Int = 0
    
    weak var delegate: SpendDayTableCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeSpendListView()
        self.ntSpendList = nil
        self.ntMonth = nil
        self.day = 0
        
    }
    
    func setupView() {
        let spendStackView: UIStackView = UIStackView(arrangedSubviews: [expectedSpendLabel, spendLabel])
        spendStackView.alignment = .trailing
        spendStackView.axis = .vertical
        spendStackView.distribution = .fill
        let topStackView: UIStackView = UIStackView(arrangedSubviews: [dayLabel, spendStackView])
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        expectedSpendLabel.translatesAutoresizingMaskIntoConstraints = false
        spendLabel.translatesAutoresizingMaskIntoConstraints = false
        topStackView.alignment = .center
        topStackView.axis = .horizontal
        topStackView.distribution = .fill
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView: UIStackView = UIStackView(arrangedSubviews: [topStackView, spendListView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stackView)
        self.expectedSpendLabel.updatePrice(20000, description: "소비예상금액")
        self.spendLabel.updatePrice(0, description: "지출금액")
        
        NSLayoutConstraint.activate(stackView.fitConstarint(to: self.contentView, padding: 10))
        NSLayoutConstraint.activate([
            dayLabel.widthAnchor.constraint(equalToConstant: 80),
            expectedSpendLabel.widthAnchor.constraint(equalTo: spendLabel.widthAnchor, multiplier: 1.0)
        ])
        
    }
    
    func setMonth(_ ntMonth: NTMonth, atDay day: Int) {
        self.day = day
        self.ntMonth = ntMonth
        self.ntSpendList = ntMonth.spendList(atDay: day)
        
        self.updateView()
    }
    
    func updateView(_ spendList: [NTSpendDay], ntMonth: NTMonth, atDay day: Int) {
        self.day = day
        self.ntSpendList = spendList
        self.ntMonth = ntMonth
        
        self.updateDate("\(self.ntMonth.month)/\(self.day)")
        self.updateView()
    }
    
    // MARK: - Update
    private func updateView() {
        self.updateDate("\(self.ntMonth.month)/\(self.day)")
        self.updatePrice()
        self.removeSpendListView()
    }
    
    private func updatePrice() {
        self.expectedSpendLabel.updatePrice(self.ntMonth.everyExpectedSpend, description: "소비예상금액")
        var totalSpendPrice: Int = 0
        
        if (self.ntSpendList?.isEmpty == true) {
            self.spendLabel.updatePrice(0, description: "지출금액")
            return
        }
        
        // TODO: - (1) 필터 카테고리 지출
        self.ntSpendList?.forEach { ntSpend in
            totalSpendPrice += ntSpend.spend
        }
        
        if totalSpendPrice > self.ntMonth.everyExpectedSpend {
            self.spendLabel.updatePrice(totalSpendPrice, description: "지출금액", color: .systemRed)
        } else {
            self.spendLabel.updatePrice(totalSpendPrice, description: "지출금액", color: .systemBlue)
        }
        
    }
    
    func showSpendListView() {
        for subView in self.spendListView.arrangedSubviews {
            subView.removeFromSuperview()
        }
        
        let addSpendButton: UIButton = UIButton()
        var config = UIButton.Configuration.filled()
        config.buttonSize = .mini
        addSpendButton.configuration = config
        addSpendButton.setTitle("지출 추가", for: .normal)
        self.spendListView.addArrangedSubview(addSpendButton)
        self.spendListView.distribution = .fill
        addSpendButton.addTarget(self, action: #selector(clickAddButton(_:)), for: .touchDown)
        
        self.ntSpendList?.forEach {
            let leftLabel: SpendDayTableLabel = SpendDayTableLabel()
            let spendLabel: SpendDayTableLabel = SpendDayTableLabel()
            let modifyButton: SpendModifyButton = SpendModifyButton()
            var config = UIButton.Configuration.filled()
            config.buttonSize = .mini
            config.baseBackgroundColor = .systemPink
            modifyButton.configuration = config
            modifyButton.setTitle("수정", for: .normal)
            modifyButton.addTarget(self, action: #selector(clickModifyButton(_:)), for: .touchDown)
            modifyButton.ntSpend = $0
            
            let stackView: UIStackView = UIStackView(arrangedSubviews: [leftLabel, spendLabel, modifyButton])
            
            stackView.axis = .horizontal
            stackView.distribution = .fill
            leftLabel.updateText($0.categoryName, description: "카테고리")
            spendLabel.updatePrice($0.spend, description: "지출금액")
            self.spendListView.addArrangedSubview(stackView)
        }
        self.layoutIfNeeded()
    }
    
    func removeSpendListView() {
        for subView in self.spendListView.arrangedSubviews {
            subView.removeFromSuperview()
        }
        self.layoutIfNeeded()
    }
    
    @objc func clickAddButton(_ sender: UIButton) {
        self.delegate?.spendDayTableCellDelegateClickAddSpend(day: self.day)
    }
    
    @objc func clickModifyButton(_ sender: SpendModifyButton) {
        guard let ntSpend: NTSpendDay = sender.ntSpend else {
            return
        }
        self.delegate?.spendDayTableCellDelegateClickModifySpend(ntSpend: ntSpend)
    }

    private func updateDate(_ dateString: String) {
        let weekDay: WeekDay = Date.dateFrom(day: self.day, month: ntMonth.month, year: ntMonth.year).weekDay
        let text: String = dateString + " (\(weekDay.name))"
        let nowMonth = Date.now.month, nowDay = Date.now.day, nowYear = Date.now.year
        
        var dayColor: UIColor = .label
        let weekDayColor: UIColor = weekDay.isSuday ? .systemRed : weekDay.isSaturday ? .systemBlue : .label
        
        if (ntMonth.month == nowMonth &&
            ntMonth.year == nowYear &&
            self.day == nowDay) {
            dayColor = .systemOrange
        } else {
            dayColor = .label
        }
        
        let mutableAttr = NSMutableAttributedString(string: text)
        mutableAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: dayColor, range: NSMakeRange(0, dateString.count))
        mutableAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: weekDayColor, range: NSMakeRange(dateString.count, text.count-dateString.count))
        self.dayLabel.attributedText = mutableAttr
    }
}
