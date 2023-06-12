//
//  GroupTableCell.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import UIKit

class GroupTableCell: UITableViewCell {
    
    var groupTitleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        return label
    }()
    
    var ntGroup: NTGroup?
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
       
        groupTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(groupTitleLabel)
        NSLayoutConstraint.activate(groupTitleLabel.fitConstarint(to: self.contentView, padding: 10))
    }
    
    func updateGroup(_ group: NTGroup) {
        self.ntGroup = group
        
        self.groupTitleLabel.text = group.name
    }

}
