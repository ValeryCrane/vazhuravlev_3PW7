//
//  YMapKitViewController.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import UIKit
import CoreLocation
import YandexMapsMobile

protocol YMapKitDisplayLogic: AnyObject {
    func displayRoute(route: YMKPolyline)        // Displays given route on the map.
}

class YMapKitViewController: UIViewController {
    public var interactor: YMapKitBusinessLogic!
    
    // MARK: - subviews
    private let mapView: YMKMapView = {
        let mapView = YMKMapView()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 8
        mapView.clipsToBounds = false
        return mapView
    }()
    
    private let goButton = YMapSearchButton(title: "Go", backgroundColor: .systemBlue)
    private let clearButton = YMapSearchButton(title: "Clear", backgroundColor: .systemGray2)
    
    let startLocation = YMapSearchTextField(placeholder: "From")
    let endLocation = YMapSearchTextField(placeholder: "To")

    
    // MARK: - ViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layoutUI()
        configureTapGestureRecognizer()
        configureLocationManager()
    }
    
    
    // MARK: - layout functions
    private func layoutUI() {
        view.addSubview(mapView)
        mapView.pin(to: view, .top, .right, .bottom, .left)
        layoutButtons()
        layoutTextFields()
    }
    
    private func layoutButtons() {
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        view.addSubview(buttonStack)
        buttonStack.pinLeft(to: view.leadingAnchor, 24)
        buttonStack.pinRight(to: view.trailingAnchor, 24)
        buttonStack.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        buttonStack.setHeight(to: 64)
        
        buttonStack.addArrangedSubview(goButton)
        buttonStack.addArrangedSubview(clearButton)
        goButton.pinHeight(to: buttonStack.heightAnchor)
        clearButton.pinHeight(to: buttonStack.heightAnchor)
        
        goButton.addTarget(self, action: #selector(goButtonWasPressed), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearButtonWasPressed), for: .touchUpInside)
        
        goButton.isEnabled = false
        clearButton.isEnabled = false
    }
    
    private func layoutTextFields() {
        let textFieldStack = UIStackView()
        textFieldStack.axis = .vertical
        textFieldStack.spacing = 8
        view.addSubview(textFieldStack)
        textFieldStack.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        textFieldStack.pinLeft(to: view.leadingAnchor, 24)
        textFieldStack.pinRight(to: view.trailingAnchor, 24)
        
        textFieldStack.addArrangedSubview(startLocation)
        textFieldStack.addArrangedSubview(endLocation)
        startLocation.pinWidth(to: textFieldStack.widthAnchor)
        startLocation.setHeight(to: 48)
        endLocation.pinWidth(to: textFieldStack.widthAnchor)
        endLocation.setHeight(to: 48)
        
        startLocation.delegate = self
        endLocation.delegate = self
    }
    
    
    // MARK: - config functions
    private func configureTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(self.dismissAnyKeyboard))
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func configureLocationManager() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - button actions
    @objc func clearButtonWasPressed() {
        startLocation.text = ""
        endLocation.text = ""
        goButton.isEnabled = false
        clearButton.isEnabled = false
        clearMap()
    }
    
    @objc private func goButtonWasPressed() {
        if let startLocation = startLocation.text, let endLocation = endLocation.text {
            interactor.fetchRoute(startAddress: startLocation, endAddress: endLocation)
        }
        startLocation.text = ""
        endLocation.text = ""
        goButton.isEnabled = false
        clearButton.isEnabled = false
    }
    
    // MARK: - other functions
    @objc private func dismissAnyKeyboard() {
        startLocation.resignFirstResponder()
        endLocation.resignFirstResponder()
    }
    
    private func clearMap() {
        mapView.mapWindow.map.mapObjects.clear()
    }
}


// MARK: - UITextFieldDelegate implementation
extension YMapKitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == endLocation &&
            !(startLocation.text ?? "").isEmpty && !(endLocation.text ?? "").isEmpty {
            goButtonWasPressed()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !(startLocation.text ?? "").isEmpty && !(endLocation.text ?? "").isEmpty {
            goButton.isEnabled = true
            clearButton.isEnabled = true
        } else if !(startLocation.text ?? "").isEmpty || !(endLocation.text ?? "").isEmpty {
            goButton.isEnabled = false
            clearButton.isEnabled = true
        } else {
            goButton.isEnabled = false
            clearButton.isEnabled = false
        }
    }
}



// MARK: - MapKitDisplayLogic implementation
extension YMapKitViewController: YMapKitDisplayLogic {
    func displayRoute(route: YMKPolyline) {
        mapView.mapWindow.map.mapObjects.addPolyline(with: route)
    }
}

