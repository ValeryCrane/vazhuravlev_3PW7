//
//  YMapKitSearchViewController.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 19.03.2022.
//

import Foundation
import UIKit

protocol YMapKitToolBarDisplayLogic: AnyObject {
    func handleSearchQuery(source: String, destination: String, vehicle: VehicleType)
    func clearQuery()
}

class YMapKitSearchViewController: UIViewController {
    public weak var delegate: YMapKitToolBarDisplayLogic?
    
    let startLocation = YMapSearchTextField(placeholder: "From")
    let endLocation = YMapSearchTextField(placeholder: "To")

    let goButton = YMapToolbarButton(icon: UIImage(named: "goIcon") ?? UIImage(),
                                     backgroundColor: .systemBlue)
    let clearButton = YMapToolbarButton(icon: UIImage(named: "clearIcon") ?? UIImage(),
                                        backgroundColor: .systemRed)
    
    // MARK: - ViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Maps"
        let textStackView = layoutTextFieldsInStack()
        layoutButtons(textFieldStack: textStackView)
        configureTextFields()
        configureButtons()
        configureTapGestureRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.clearQuery()
    }
    
    // MARK: - layout functions
    private func layoutTextFieldsInStack() -> UIView {
        let textFieldStack = UIStackView()
        textFieldStack.axis = .vertical
        textFieldStack.spacing = 8
        view.addSubview(textFieldStack)
        textFieldStack.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 16)
        textFieldStack.pinLeft(to: view.leadingAnchor, 16)
        
        textFieldStack.addArrangedSubview(startLocation)
        textFieldStack.addArrangedSubview(endLocation)
        startLocation.pinWidth(to: textFieldStack.widthAnchor)
        startLocation.setHeight(to: 48)
        endLocation.pinWidth(to: textFieldStack.widthAnchor)
        endLocation.setHeight(to: 48)
        return textFieldStack
    }
    
    private func layoutButtons(textFieldStack: UIView) {
        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.spacing = 8
        view.addSubview(buttonStack)
        buttonStack.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 16)
        buttonStack.pinLeft(to: textFieldStack.trailingAnchor, 8)
        buttonStack.pinRight(to: view.trailingAnchor, 16)
        
        buttonStack.addArrangedSubview(clearButton)
        buttonStack.addArrangedSubview(goButton)
        goButton.setWidth(to: 48)
        goButton.setHeight(to: 48)
        clearButton.setWidth(to: 48)
        clearButton.setHeight(to: 48)
    }
    
    // MARK: - congig functions
    private func configureTextFields() {
        startLocation.delegate = self
        endLocation.delegate = self
        startLocation.addTarget(self, action: #selector(self.changedTextFieldAction), for: .editingChanged)
        endLocation.addTarget(self, action: #selector(self.changedTextFieldAction), for: .editingChanged)
    }
    
    private func configureTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(self.dismissAnyKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func configureButtons() {
        goButton.addTarget(self, action: #selector(goButtonAction), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearButtonAction), for: .touchUpInside)
        goButton.disable()
        clearButton.disable()
    }
    
    // MARK: - action functions
    @objc private func goButtonAction() {
        let routeViewController = YMapKitRouteViewController()
        routeViewController.delegate = self
        self.navigationController?.pushViewController(routeViewController, animated: true)
    }
    
    @objc private func clearButtonAction() {
        startLocation.text = ""
        endLocation.text = ""
        goButton.disable()
        clearButton.disable()
    }
    
    @objc private func dismissAnyKeyboard() {
        startLocation.resignFirstResponder()
        endLocation.resignFirstResponder()
    }
    
    @objc private func changedTextFieldAction() {
        if !(startLocation.text ?? "").isEmpty && !(endLocation.text ?? "").isEmpty {
            goButton.enable()
            clearButton.enable()
        } else if !(startLocation.text ?? "").isEmpty || !(endLocation.text ?? "").isEmpty {
            goButton.disable()
            clearButton.enable()
        } else {
            goButton.disable()
            clearButton.disable()
        }
    }
}

// MARK: - UITextFieldDelegate implementation
extension YMapKitSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == startLocation && !(startLocation.text ?? "").isEmpty {
            endLocation.becomeFirstResponder()
        }
        if textField == endLocation &&
            !(startLocation.text ?? "").isEmpty && !(endLocation.text ?? "").isEmpty {
            goButtonAction()
        }
        return true
    }
}


// MARK: - YMapKitVehicleQueryDelegate implementation
extension YMapKitSearchViewController: YMapKitVehicleQueryDelegate {
    func vehicleQuery(vehicle: VehicleType) {
        if let start = startLocation.text, let end = endLocation.text {
            self.delegate?.handleSearchQuery(source: start, destination: end, vehicle: vehicle)
        }
    }
}


