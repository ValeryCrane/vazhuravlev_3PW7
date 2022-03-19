//
//  YMapKitRouteViewController.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 19.03.2022.
//

import Foundation
import UIKit

protocol YMapKitVehicleQueryDelegate: AnyObject {
    func vehicleQuery(vehicle: VehicleType)         // Handles vehicle type change
}

class YMapKitRouteViewController: UIViewController {
    public weak var delegate: YMapKitVehicleQueryDelegate!
    
    private var transportChoice: UISegmentedControl?
    private var distanceLabel: UILabel?
    private var loadingIndicator: UIActivityIndicatorView?
    
    // MARK: - ViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Route"
        let wrapper = layoutWrapper()
        layoutTransportChoice(wrapper: wrapper)
        layoutDistanceLabel(wrapper: wrapper)
        configureTransportChoice()
    }
    
    // MARK: - layout functions
    private func layoutWrapper() -> UIView {
        let wrapper = UIView()
        wrapper.backgroundColor = .white
        wrapper.clipsToBounds = true
        wrapper.layer.cornerRadius = 16
        wrapper.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        wrapper.layer.shadowRadius = 8
        self.view.addSubview(wrapper)
        wrapper.pin(to: view, .left, .right)
        wrapper.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        return wrapper
    }
    
    private func layoutTransportChoice(wrapper: UIView) {
        let images: [UIImage] = [
            UIImage(named: "car") ?? UIImage(),
            UIImage(named: "bicycle") ?? UIImage(),
            UIImage(named: "pedestrian") ?? UIImage()
        ]
        
        let transportChoice = UISegmentedControl(items: images)
        transportChoice.selectedSegmentIndex = 0
        transportChoice.selectedSegmentTintColor = .init(red: 0.6, green: 0.6, blue: 1, alpha: 1)
        wrapper.addSubview(transportChoice)
        transportChoice.pinTop(to: wrapper.topAnchor, 16)
        transportChoice.pinLeft(to: wrapper.leadingAnchor, 32)
        transportChoice.pinRight(to: wrapper.trailingAnchor, 32)
        transportChoice.setHeight(to: 48)
        transportChoice.isEnabled = false                           // Transport choice is not implemented yet.
        self.transportChoice = transportChoice
    }
    
    private func layoutDistanceLabel(wrapper: UIView) {
        guard let transportChoice = self.transportChoice else { return }
        let distanceLabel = UILabel()
        distanceLabel.text = "Distance isn't available:("
        distanceLabel.font = .systemFont(ofSize: 32, weight: .bold)
        distanceLabel.textAlignment = .right
        wrapper.addSubview(distanceLabel)
        distanceLabel.pinTop(to: transportChoice.bottomAnchor, 16)
        distanceLabel.pinLeft(to: wrapper.leadingAnchor, 32)
        distanceLabel.pinRight(to: wrapper.trailingAnchor, 40)
        distanceLabel.pinBottom(to: wrapper.bottomAnchor, 24)
        distanceLabel.isHidden = true
        self.distanceLabel = distanceLabel
        
        // Creating loading indicator
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.hidesWhenStopped = true
        wrapper.addSubview(loadingIndicator)
        loadingIndicator.pinCenter(to: distanceLabel.centerYAnchor)
        loadingIndicator.pinRight(to: wrapper.trailingAnchor, 56)
        loadingIndicator.startAnimating()
        self.loadingIndicator = loadingIndicator
    }
    
    // MARK: - config functions
    private func configureTransportChoice() {
        transportChoice?.addTarget(self, action: #selector(transportChoiceAction), for: .valueChanged)
        // Making initial call.
        transportChoiceAction()
    }
    
    @objc private func transportChoiceAction() {
        if let selectedIndex = transportChoice?.selectedSegmentIndex,
           let vehicle = VehicleType(rawValue: selectedIndex){
            loadingIndicator?.startAnimating()
            distanceLabel?.isHidden = true
            delegate?.vehicleQuery(vehicle: vehicle)
        }
    }
}


// MARK: - YMapKitDistanceDisplayLogic implementation
extension YMapKitRouteViewController: YMapKitDistanceDisplayLogic {
    func displayDistance(distance: String) {
        loadingIndicator?.stopAnimating()
        distanceLabel?.text = distance
        distanceLabel?.isHidden = false
    }
}
