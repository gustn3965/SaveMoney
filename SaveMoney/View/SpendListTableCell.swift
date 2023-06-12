//
//  SpendListTableCell.swift
//  SaveMoney
//
//  Created by vapor on 2022/12/05.
//
import UIKit

class SpendListTableCell: UITableViewCell {
    
    var categoryTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        return label
    }()
    
    var spendLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    var countLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    var ntCategory: NTSpendCategory?
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
       
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        spendLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(categoryTitleLabel)
        NSLayoutConstraint.activate(categoryTitleLabel.fitConstarint(to: self.contentView, padding: 20))
        
        let stackView: UIStackView = UIStackView(arrangedSubviews: [categoryTitleLabel, spendLabel, countLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(stackView)
        NSLayoutConstraint.activate(stackView.fitConstarint(to: self.contentView, padding: 10))
    }
    
    func updateView(spendList: SpendListModel) {
        self.categoryTitleLabel.text = spendList.name
        self.spendLabel.text = "\(spendList.price)"
        self.countLabel.text = "\(spendList.count)"
    }

}
