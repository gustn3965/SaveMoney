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
    
    class IconView: UIView {
        let roundView: UIView = {
            let view = UIView()
            view.backgroundColor = .orange
            view.layer.cornerRadius = 7.0
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        var label: UILabel = {
            let textField = UILabel()
            textField.font = UIFont.preferredFont(forTextStyle: .caption1)
            textField.textColor = .white
            textField.layer.cornerRadius = 5.0
            textField.text = "오늘"
            textField.backgroundColor = .clear
            textField.translatesAutoresizingMaskIntoConstraints = false
            return textField
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.addSubview(roundView)
            roundView.addSubview(label)
            NSLayoutConstraint.activate(
                label.fitConstarint(to: roundView, padding: 3)
            )
            NSLayoutConstraint.activate(
                roundView.fitConstarint(to: self, padding: 0)
            )
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func updateView(text: String, textColor: UIColor, backgroundColor: UIColor) {
            roundView.backgroundColor = backgroundColor
            label.textColor = textColor
            label.text = text
        }
    }
    
    var todayIconView: IconView = {
        let iconView = IconView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        return iconView
    }()
    
    var dayLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var iconStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .trailing
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
//    var expectedSpendLabel: SpendDayTableLabel = SpendDayTableLabel()
    var spendLabel: SpendDayTableLabel = {
        let label = SpendDayTableLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
       
    }()
    
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
//        let spendStackView: UIStackView = UIStackView(arrangedSubviews: [expectedSpendLabel, spendLabel])
        let spendStackView: UIStackView = UIStackView(arrangedSubviews: [spendLabel])
        spendStackView.alignment = .trailing
        spendStackView.axis = .vertical
        spendStackView.distribution = .fill
        let topStackView: UIStackView = UIStackView(arrangedSubviews: [dayLabel, iconStackView, spendStackView])
        topStackView.alignment = .center
        topStackView.axis = .horizontal
        topStackView.distribution = .fill
        topStackView.spacing = 5
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView: UIStackView = UIStackView(arrangedSubviews: [topStackView, spendListView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stackView)
        self.contentView.addSubview(todayIconView)
        self.spendLabel.updatePrice(0, description: "지출금액")
        
        NSLayoutConstraint.activate([
            todayIconView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            todayIconView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: todayIconView.trailingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),

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
        
        self.updateDayLabel("\(self.ntMonth.month)/\(self.day)")
        self.updateView()
    }
    
    // MARK: - Update
    private func updateView() {
        self.updateDayLabel("\(self.day)일")
        self.updatePriceAndIconStackView()
        self.removeSpendListView()
    }
    
    private func updatePriceAndIconStackView() {
        for subView in self.iconStackView.arrangedSubviews {
            subView.removeFromSuperview()
        }
        
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
            
            if (totalSpendPrice >= self.ntMonth.everyExpectedSpend * 2) {
                let goodIconView = IconView()
                goodIconView.translatesAutoresizingMaskIntoConstraints = false
                goodIconView.updateView(text:"💩", textColor: .label, backgroundColor: .systemBrown)
                self.iconStackView.addArrangedSubview(goodIconView)
            }
            
            
        } else {
            self.spendLabel.updatePrice(totalSpendPrice, description: "지출금액", color: .systemBlue)
            
            
            let goodIconView = IconView()
            goodIconView.translatesAutoresizingMaskIntoConstraints = false
            goodIconView.updateView(text:"👍", textColor: .label, backgroundColor: .systemBlue)
            self.iconStackView.addArrangedSubview(goodIconView)
            
            if (totalSpendPrice == 0) {
                let goodIconView = IconView()
                goodIconView.translatesAutoresizingMaskIntoConstraints = false
                goodIconView.updateView(text:"🌟", textColor: .label, backgroundColor: .systemPink)
                self.iconStackView.addArrangedSubview(goodIconView)
            }
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
            stackView.setCustomSpacing(10, after: leftLabel)
            stackView.setCustomSpacing(15, after: spendLabel)
            
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

    private func updateDayLabel(_ dateString: String) {
        let date = Date.dateFrom(day: self.day, month: ntMonth.month, year: ntMonth.year)
        let weekDay: WeekDay = date.weekDay
        let text: String = "(\(weekDay.name)) \(dateString)"
        
        if (date.isToday) {
            self.todayIconView.isHidden = false
        } else {
            self.todayIconView.isHidden = true
        }

        let weekDayColor: UIColor = weekDay.isSuday ? .systemRed : weekDay.isSaturday ? .systemBlue : .label
        let mutableAttr = NSMutableAttributedString(string: text)
        mutableAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.label, range: NSMakeRange(text.count-dateString.count, dateString.count))
        mutableAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: weekDayColor, range: NSMakeRange(0, text.count-dateString.count))
        self.dayLabel.attributedText = mutableAttr
    }
}
