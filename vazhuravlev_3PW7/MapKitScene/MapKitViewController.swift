//
//  MapKitViewController.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import UIKit
import CoreLocation
import MapKit

class MapKitViewController: UIViewController {
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 8
        mapView.clipsToBounds = false
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        return mapView
    }()
    
    private let goButton = MapSearchButton(title: "Go", backgroundColor: .systemBlue)
    private let clearButton = MapSearchButton(title: "Clear", backgroundColor: .systemGray2)
    
    let startLocation = MapSearchTextField(placeholder: "From")
    let endLocation = MapSearchTextField(placeholder: "To")

    
    // MARK: - ViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @objc private func dismissAnyKeyboard() {
        startLocation.resignFirstResponder()
        endLocation.resignFirstResponder()
    }
}


// MARK: - UITextFieldDelegate implementation
extension MapKitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
