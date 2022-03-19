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
    // Displays given route on the map.
    func displayRoute(route: YMKDrivingRoute, boundingBox: YMKBoundingBox, distance: String, requestId: UUID)
}

class YMapKitViewController: UIViewController {
    public var interactor: YMapKitBusinessLogic!
    
    private var currentRouteId: UUID?
    private var toolBar: YMapKitDistanceDisplayLogic?
    
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
        configureTapGestureRecognizer()
    }
    
    
    // MARK: - layout functions
    private func layoutMap() {
        view.addSubview(mapView)
        mapView.pin(to: view, .top, .right, .bottom, .left)
    }
    
    private func layoutToolbar() {
        let toolbar = YMapKitToolBar(delegate: self)
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
    
    // MARK: - other functions
    @objc private func dismissAnyKeyboard() {
        view.endEditing(true)
    }
    
    private func clearMap() {
        mapView.mapWindow.map.mapObjects.clear()
    }
}



// MARK: - MapKitDisplayLogic implementation
extension YMapKitViewController: YMapKitDisplayLogic {
    func displayRoute(route: YMKDrivingRoute, boundingBox: YMKBoundingBox, distance: String, requestId: UUID) {
        guard requestId == currentRouteId else { return }
        let jamsPolyline = mapView.mapWindow.map.mapObjects.addColoredPolyline()
        YMKRouteHelper.updatePolyline(withPolyline: jamsPolyline, route: route,
                                      style: YMKRouteHelper.createDefaultJamStyle())
        var cameraPosition = mapView.mapWindow.map.cameraPosition(with: boundingBox)
        cameraPosition = YMKCameraPosition(target: cameraPosition.target,
                                            zoom: cameraPosition.zoom - 0.8,
                                            azimuth: cameraPosition.azimuth,
                                            tilt: cameraPosition.tilt)
        mapView.mapWindow.map.move(with: cameraPosition, animationType:
                                    YMKAnimation(type: YMKAnimationType.smooth, duration: 1))
        toolBar?.displayDistance(distance: distance)
    }
}

extension YMapKitViewController: YMapKitToolBarDisplayLogic {
    func handleSearchQuery(source: String, destination: String, vehicle: VehicleType) {
        clearMap()
        let currentRouteId = UUID()
        self.currentRouteId = currentRouteId
        self.interactor.fetchRoute(startAddress: source, endAddress: destination, requestId: currentRouteId)
    }
    
    func clearQuery() {
        clearMap()
    }
}

