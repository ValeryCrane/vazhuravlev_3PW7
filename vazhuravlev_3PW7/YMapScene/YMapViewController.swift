//
//  YMapViewController.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import UIKit
import CoreLocation
import YandexMapsMobile

protocol YMapDisplayLogic: AnyObject {
    // Displays given route on the map.
    func displayDrivingRoute(route: YMKDrivingRoute, boundingBox: YMKBoundingBox, distance: String, requestId: UUID)
    func displayBicycleRoute(route: YMKBicycleRoute, boundingBox: YMKBoundingBox, distance: String, requestId: UUID)
    func displayPedestrianRoute(route: YMKMasstransitRoute, boundingBox: YMKBoundingBox, distance: String, requestId: UUID)
}

class YMapViewController: UIViewController {
    public var interactor: YMapBusinessLogic!
    
    private var currentRouteId: UUID?
    private var toolBar: YMapDistanceDisplayLogic?
    private var plusButton: UIButton?
    private var minusButton: UIButton?
    private var compassView: UIButton?
    
    // MARK: - subviews
    private let mapView: YMKMapView = {
        let mapView = YMKMapView()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 8
        mapView.clipsToBounds = false
        return mapView
    }()

    
    // MARK: - ViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layoutMap()
        layoutToolbar()
        layoutZoomingButtons()
        layoutCompass()
        configureTapGestureRecognizer()
        configureButtons()
        configureMapView()
    }
    
    
    // MARK: - layout functions
    private func layoutMap() {
        view.addSubview(mapView)
        mapView.pin(to: view, .top, .right, .bottom, .left)
    }
    
    private func layoutToolbar() {
        let toolbar = YMapToolBar(delegate: self)
        self.addChild(toolbar)
        view.addSubview(toolbar.view)
        toolbar.view.pin(to: view, .top, .left, .right)
        if let notchSize = UIApplication.shared.windows.first?.safeAreaInsets.top {
            toolbar.view.setHeight(to: Double(notchSize) + 188)
        } else {
            toolbar.view.setHeight(to: 240)
        }
        toolbar.didMove(toParent: self)
        self.toolBar = toolbar
    }
    
    private func layoutZoomingButtons() {
        let plusButton = UIButton()
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = .systemFont(ofSize: 32)
        plusButton.setTitleColor(.black, for: .normal)
        plusButton.backgroundColor = .white
        plusButton.setHeight(to: 48)
        plusButton.setWidth(to: 48)
        self.plusButton = plusButton
        let minusButton = UIButton()
        minusButton.setTitle("-", for: .normal)
        minusButton.titleLabel?.font = .systemFont(ofSize: 32)
        minusButton.setTitleColor(.black, for: .normal)
        minusButton.backgroundColor = .white
        minusButton.setHeight(to: 48)
        minusButton.setWidth(to: 48)
        self.minusButton = minusButton
        
        let buttonStack = UIStackView()
        view.addSubview(buttonStack)
        buttonStack.axis = .vertical
        buttonStack.spacing = 1
        buttonStack.layer.cornerRadius = 8
        buttonStack.layer.shadowRadius = 8
        buttonStack.clipsToBounds = true
        buttonStack.backgroundColor = .systemGray6
        buttonStack.addArrangedSubview(plusButton)
        buttonStack.addArrangedSubview(minusButton)
        buttonStack.pinRight(to: view, 24)
        buttonStack.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 32)
    }
    
    private func layoutCompass() {
        let compassView = UIButton()
        compassView.setImage(UIImage(named: "compass"), for: .normal)
        compassView.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        compassView.backgroundColor = .white
        compassView.layer.cornerRadius = 28
        compassView.layer.shadowRadius = 8
        compassView.clipsToBounds = true
        view.addSubview(compassView)
        compassView.setWidth(to: 56)
        compassView.setHeight(to: 56)
        compassView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 32)
        compassView.pinLeft(to: view, 24)
        self.compassView = compassView
    }
    
    // MARK: - config functions
    private func configureTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(self.dismissAnyKeyboard))
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func configureButtons() {
        plusButton?.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        minusButton?.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        compassView?.addTarget(self, action: #selector(nullifyAzimuth), for: .touchUpInside)
    }
    
    private func configureLocationManager() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    private func configureMapView() {
        self.mapView.mapWindow.map.addCameraListener(with: self)
    }
    
    // MARK: - zoom and compass functions
    private func moveMapTo(boundingBox: YMKBoundingBox) {
        var cameraPosition = mapView.mapWindow.map.cameraPosition(with: boundingBox)
        cameraPosition = YMKCameraPosition(target: cameraPosition.target,
                                            zoom: cameraPosition.zoom - 0.8,
                                            azimuth: cameraPosition.azimuth,
                                            tilt: cameraPosition.tilt)
        mapView.mapWindow.map.move(with: cameraPosition, animationType:
                                    YMKAnimation(type: YMKAnimationType.smooth, duration: 1))
    }
    
    @objc private func zoomIn() {
        print(mapView.mapWindow.map.cameraPosition.zoom)
        let cameraPosition = mapView.mapWindow.map.cameraPosition
        let newCameraPosition = YMKCameraPosition(target: cameraPosition.target,
                                                  zoom: cameraPosition.zoom + 1,
                                                  azimuth: cameraPosition.azimuth,
                                                  tilt: cameraPosition.tilt)
        mapView.mapWindow.map.move(with: newCameraPosition,  animationType:
                                    YMKAnimation(type: YMKAnimationType.smooth, duration: 0.2))
    }
    
    @objc private func zoomOut() {
        let cameraPosition = mapView.mapWindow.map.cameraPosition
        let newCameraPosition = YMKCameraPosition(target: cameraPosition.target,
                                                  zoom: cameraPosition.zoom - 1,
                                                  azimuth: cameraPosition.azimuth,
                                                  tilt: cameraPosition.tilt)
        mapView.mapWindow.map.move(with: newCameraPosition,  animationType:
                                    YMKAnimation(type: YMKAnimationType.smooth, duration: 0.2))
    }
    
    // This thing is not working.
    private func updateZoomButtons() {
        let zoom = mapView.mapWindow.map.cameraPosition.zoom
        if zoom > mapView.mapWindow.map.getMaxZoom() - 0.01 {
            plusButton?.isEnabled = false
            plusButton?.setTitleColor(.systemGray6, for: .normal)
        } else {
            plusButton?.isEnabled = true
            plusButton?.setTitleColor(.black, for: .normal)
        }
        
        if zoom < mapView.mapWindow.map.getMinZoom() + 0.01 {
            minusButton?.isEnabled = false
            minusButton?.setTitleColor(.systemGray6, for: .normal)
        } else {
            minusButton?.isEnabled = true
            minusButton?.setTitleColor(.black, for: .normal)
        }
    }
    
    @objc private func nullifyAzimuth() {
        let cameraPosition = mapView.mapWindow.map.cameraPosition
        let newCameraPosition = YMKCameraPosition(target: cameraPosition.target,
                                                  zoom: cameraPosition.zoom,
                                                  azimuth: 0,
                                                  tilt: cameraPosition.tilt)
        mapView.mapWindow.map.move(with: newCameraPosition,  animationType:
                                    YMKAnimation(type: YMKAnimationType.smooth, duration: 0.2))
    }
    
    // MARK: - other functions
    @objc private func dismissAnyKeyboard() {
        view.endEditing(true)
    }
    
    private func clearMap() {
        mapView.mapWindow.map.mapObjects.clear()
    }
    
    private func updateCompass() {
        let tilt = mapView.mapWindow.map.cameraPosition.tilt
        print(tilt)
    }
}


// MARK: - YMapDisplayLogic implementation
extension YMapViewController: YMapDisplayLogic {
    func displayDrivingRoute(route: YMKDrivingRoute, boundingBox: YMKBoundingBox,
                             distance: String, requestId: UUID) {
        guard requestId == currentRouteId else { return }
        let jamsPolyline = mapView.mapWindow.map.mapObjects.addColoredPolyline()
        YMKRouteHelper.updatePolyline(withPolyline: jamsPolyline, route: route,
                                      style: YMKRouteHelper.createDefaultJamStyle())
        moveMapTo(boundingBox: boundingBox)
        toolBar?.displayDistance(distance: distance)
    }
    
    func displayBicycleRoute(route: YMKBicycleRoute, boundingBox: YMKBoundingBox,
                             distance: String, requestId: UUID) {
        guard requestId == currentRouteId else { return }
        mapView.mapWindow.map.mapObjects.addPolyline(with: route.geometry)
        moveMapTo(boundingBox: boundingBox)
        toolBar?.displayDistance(distance: distance)
    }
    
    func displayPedestrianRoute(route: YMKMasstransitRoute, boundingBox: YMKBoundingBox,
                                distance: String, requestId: UUID) {
        guard requestId == currentRouteId else { return }
        mapView.mapWindow.map.mapObjects.addPolyline(with: route.geometry)
        moveMapTo(boundingBox: boundingBox)
        toolBar?.displayDistance(distance: distance)
    }
}


// MARK: - YMapToolBarDisplayLogic implementation
extension YMapViewController: YMapToolBarDisplayLogic {
    func handleSearchQuery(source: String, destination: String, vehicle: VehicleType) {
        clearMap()
        let currentRouteId = UUID()
        self.currentRouteId = currentRouteId
        self.interactor.fetchRoute(startAddress: source, endAddress: destination,
                                   vehicle: vehicle, requestId: currentRouteId)
    }
    
    func clearQuery() {
        self.currentRouteId = UUID()
        clearMap()
    }
}


// MARK: - YMKMapCameraListener implementation
extension YMapViewController: YMKMapCameraListener {
    func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateReason: YMKCameraUpdateReason, finished: Bool) {
        let azimuth = map.cameraPosition.azimuth
        if let compassView = compassView {
            compassView.transform = CGAffineTransform(rotationAngle: CGFloat(-azimuth / 180 * .pi))
        }
        updateZoomButtons()
    }
}
