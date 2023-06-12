//
//  SpendDayTableAddCell.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/25.
//

import UIKit

protocol SpendDayTableAddCellDelegate: AnyObject {
    func spendDayTableAddCellClickAdd()
}
class SpendDayTableAddCell: UITableViewCell {
    
    var addButton: UIButton = {
        let button: UIButton = UIButton()
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        button.configuration = config
        button.setTitle("이번달 예상 지출 추가", for: .normal)
        return button
    }()
    
    weak var delegate: SpendDayTableAddCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupView() {
        self.addButton.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.addButton)
        self.addButton.addTarget(self, action: #selector(clickAddButton(_:)), for: .touchDown)
        NSLayoutConstraint.activate(self.addButton.fitConstarint(to: self.contentView, padding: 20))
    }
    
    @objc func clickAddButton(_ sender: UIButton) {
        self.delegate?.spendDayTableAddCellClickAdd()
    }
}
