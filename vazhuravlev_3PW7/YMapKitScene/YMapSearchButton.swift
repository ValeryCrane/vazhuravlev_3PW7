//
//  YMapSearchButton.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import Foundation
import UIKit

// Custom class for button.
class YMapSearchButton: UIButton {
    init(title: String, backgroundColor: UIColor) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.setTitleColor(.gray, for: .disabled)
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

