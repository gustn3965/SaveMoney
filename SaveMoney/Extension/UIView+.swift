//
//  UIView+.swift
//  SaveMoney
//
//  Created by vapor on 2022/11/18.
//

import UIKit

extension UIView {
    func fitConstarint(to view: UIView, padding: CGFloat) -> [NSLayoutConstraint]{
        return [self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)]
    }
    
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}
