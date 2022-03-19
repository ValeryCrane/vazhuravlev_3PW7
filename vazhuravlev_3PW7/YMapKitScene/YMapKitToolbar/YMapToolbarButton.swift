//
//  YMapToolbarButton.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 19.03.2022.
//

import Foundation
import UIKit

// Custom class for button.
class YMapToolbarButton: UIButton {
    private let activeBackgroundColor: UIColor
    
    init(icon: UIImage, backgroundColor: UIColor) {
        activeBackgroundColor = backgroundColor
        super.init(frame: .zero)
        self.setImage(icon, for: .normal)
        self.backgroundColor = activeBackgroundColor
        self.layer.cornerRadius = 8
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func disable() {
        self.backgroundColor = .systemGray5
        self.isEnabled = false
    }
    
    func enable() {
        self.backgroundColor = activeBackgroundColor
        self.isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
