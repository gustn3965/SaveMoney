//
//  CategoryTableCell.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/25.
//


import UIKit

class CategoryTableCell: UITableViewCell {
    
    var categoryTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
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
        self.contentView.addSubview(categoryTitleLabel)
        NSLayoutConstraint.activate(categoryTitleLabel.fitConstarint(to: self.contentView, padding: 20))
    }
    
    func updateCategory(_ category: NTSpendCategory) {
        self.ntCategory = category
        
        self.categoryTitleLabel.text = category.name
    }

}
