//
//  YMapKitInteractor.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import Foundation
import CoreLocation
import YandexMapsMobile

protocol YMapKitBusinessLogic: AnyObject {
    // Fetches route for addresses and passes it to presenter.
    func fetchRoute(startAddress: String, endAddress: String, requestId: UUID)
}

class YMapKitInteractor {
    public var presenter: YMapKitPresentationLogic!
    private var drivingSession: YMKDrivingSession?
    
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
    
    // Builds path from points
    private func buildRoute(start: YMKPoint, finish: YMKPoint, requestId: UUID) {
        let requestPoints: [YMKRequestPoint] = [
            YMKRequestPoint(point: start, type: .waypoint, pointContext: nil),
            YMKRequestPoint(point: finish, type: .waypoint, pointContext: nil)
        ]
        
        let responseHandler = {[weak self] (routes: [YMKDrivingRoute]?, error: Error?) -> Void in
            if let route = routes?.first {
                let distance = route.metadata.weight.distance.value
                self?.presenter.presentRoute(route: route, distance: distance, requestId: requestId)
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

}


// MARK: - MapKitBusinessLogic implementation
extension YMapKitInteractor: YMapKitBusinessLogic {
    func fetchRoute(startAddress: String, endAddress: String, requestId: UUID) {
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
            self?.buildRoute(start: coordinates[0], finish: coordinates[1], requestId: requestId)
        }
    }
}

