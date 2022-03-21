//
//  YMapInteractor.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import Foundation
import CoreLocation
import YandexMapsMobile

protocol YMapBusinessLogic: AnyObject {
    // Fetches route for addresses and passes it to presenter.
    func fetchRoute(startAddress: String, endAddress: String, vehicle: VehicleType, requestId: UUID)
}

class YMapInteractor {
    public var presenter: YMapPresentationLogic!
    private var drivingSession: YMKDrivingSession?
    private var bicycleSession: YMKBicycleSession?
    private var pedestrianSession: YMKMasstransitSession?
    
    // Fetches coordinate from address and passes it to coordinates array.
    private func getYMKPointFrom(
        address: String,
        completion: @escaping (_ coordinate: YMKPoint?, _ error: Error?) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            CLGeocoder().geocodeAddressString(address) { placemarks, error in
                if let coordinate = placemarks?.first?.location?.coordinate {
                    let point = YMKPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    completion(point, error)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    // Builds car path from points
    private func buildCarRoute(start: YMKPoint, finish: YMKPoint, requestId: UUID) {
        let requestPoints: [YMKRequestPoint] = [
            YMKRequestPoint(point: start, type: .waypoint, pointContext: nil),
            YMKRequestPoint(point: finish, type: .waypoint, pointContext: nil)
        ]
        
        let responseHandler = {[weak self] (routes: [YMKDrivingRoute]?, error: Error?) -> Void in
            if let route = routes?.first {
                let distance = route.metadata.weight.distance.value
                self?.presenter.presentDrivingRoute(route: route, distance: distance, requestId: requestId)
            }
        }
        
        DispatchQueue.main.async {
            let drivingRouter = YMKDirections.sharedInstance().createDrivingRouter()
            self.drivingSession = drivingRouter.requestRoutes(
                with: requestPoints,
                drivingOptions: YMKDrivingDrivingOptions(),
                vehicleOptions: YMKDrivingVehicleOptions(),
                routeHandler: responseHandler
            )
        }
    }
    
    // Builds  path from points
    private func buildBicycleRoute(start: YMKPoint, finish: YMKPoint, requestId: UUID) {
        let requestPoints: [YMKRequestPoint] = [
            YMKRequestPoint(point: start, type: .waypoint, pointContext: nil),
            YMKRequestPoint(point: finish, type: .waypoint, pointContext: nil)
        ]
        
        let responseHandler = {[weak self] (routes: [YMKBicycleRoute]?, error: Error?) -> Void in
            if let route = routes?.first {
                let distance = route.weight.distance.value
                self?.presenter.presentBicycleRoute(route: route, distance: distance, requestId: requestId)
            }
        }
        
        DispatchQueue.main.async {
            let bicycleRouter = YMKTransport.sharedInstance().createBicycleRouter()
            self.bicycleSession = bicycleRouter.requestRoutes(
                with: requestPoints,
                routeListener: responseHandler
            )
        }
    }
    
    
    private func buildPedestrianRoute(start: YMKPoint, finish: YMKPoint, requestId: UUID) {
        let requestPoints: [YMKRequestPoint] = [
            YMKRequestPoint(point: start, type: .waypoint, pointContext: nil),
            YMKRequestPoint(point: finish, type: .waypoint, pointContext: nil)
        ]
        
        let responseHandler = {[weak self] (routes: [YMKMasstransitRoute]?, error: Error?) -> Void in
            if let route = routes?.first {
                let distance = route.metadata.weight.walkingDistance.value
                self?.presenter.presentPedestrianRoute(route: route, distance: distance, requestId: requestId)
            }
        }
        
        DispatchQueue.main.async {
            let pedestrianRouter = YMKTransport.sharedInstance().createPedestrianRouter()
            self.pedestrianSession = pedestrianRouter.requestRoutes(
                with: requestPoints,
                timeOptions: YMKTimeOptions(),
                routeHandler: responseHandler)
        }
    }
}


// MARK: - YMapBusinessLogic implementation
extension YMapInteractor: YMapBusinessLogic {
    func fetchRoute(startAddress: String, endAddress: String, vehicle: VehicleType, requestId: UUID) {
        guard startAddress != endAddress else { return }
         
        var coordinates: [YMKPoint] = []
        let group = DispatchGroup()
        
        group.enter()
        getYMKPointFrom(address: startAddress) { coords, _ in
            if let coords = coords {
                coordinates.append(coords)
            }
            group.leave()
        }
        
        group.enter()
        getYMKPointFrom(address: endAddress) { coords, _ in
            if let coords = coords {
                coordinates.append(coords)
            }
            group.leave()
        }
        
        group.notify(queue: .global()) { [weak self] in
            guard coordinates.count == 2 else { return }
            switch vehicle {
            case .Car:
                self?.buildCarRoute(start: coordinates[0], finish: coordinates[1], requestId: requestId)
            case .Bicycle:
                self?.buildBicycleRoute(start: coordinates[0], finish: coordinates[1], requestId: requestId)
            case .Pedestrian:
                self?.buildPedestrianRoute(start: coordinates[0], finish: coordinates[1], requestId: requestId)
            }
        }
    }
}

