//
//  YMapSearchTextField.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import Foundation
import UIKit

// Custom class for text fields.
class YMapSearchTextField: UITextField {
    init(placeholder: String) {
        super.init(frame: .zero)
        self.backgroundColor = .systemGray6
        self.textColor = .black
        self.placeholder = placeholder
        self.layer.cornerRadius = 8
        self.clipsToBounds = false
        self.font = .systemFont(ofSize: 16)
        self.borderStyle = .roundedRect
        self.autocorrectionType = .yes
        self.keyboardType = .default
        self.returnKeyType = .done
        self.clearButtonMode = .whileEditing
        self.contentVerticalAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
