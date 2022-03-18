//
//  MapKitInteractor.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import Foundation
import CoreLocation
import MapKit

protocol MapKitBusinessLogic: AnyObject {
    // Fetches route for addresses and passes it to presenter.
    func fetchRoute(startAddress: String, endAddress: String)
}

class MapKitInteractor {
    public var presenter: MapKitPresentationLogic!
    
    // Fetches coordinate from address and passes it to coordinates array.
    private func getCoordinateFrom(
        address: String,
        completion: @escaping (_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            CLGeocoder().geocodeAddressString(address) {
                completion($0?.first?.location?.coordinate, $1)
            }
        }
    }
    
    // Builds path from coordinates
    private func buildPath(start: CLLocationCoordinate2D, finish: CLLocationCoordinate2D) {
        let startMapItem = mapItemFrom(coordinate: start)
        let endMapItem = mapItemFrom(coordinate: finish)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = startMapItem
        directionsRequest.destination = endMapItem
        directionsRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate { [weak self] responce, error in
            if let error = error {
                print(error)
                return
            }
            if let responce = responce {
                self?.presenter.presentRoute(route: responce.routes[0].polyline)
            }
        }
    }
    
    private func mapItemFrom(coordinate: CLLocationCoordinate2D) -> MKMapItem {
        return MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
    }
}


// MARK: - MapKitBusinessLogic implementation
extension MapKitInteractor: MapKitBusinessLogic {
    func fetchRoute(startAddress: String, endAddress: String) {
        guard startAddress != endAddress else { return }
        
        var coordinates: [CLLocationCoordinate2D] = []
        
        let group = DispatchGroup()
        
        group.enter()
        getCoordinateFrom(address: startAddress) { coords, _ in
            if let coords = coords {
                coordinates.append(coords)
            }
            group.leave()
        }
        
        group.enter()
        getCoordinateFrom(address: endAddress) { coords, _ in
            if let coords = coords {
                coordinates.append(coords)
            }
            group.leave()
        }
        
        group.notify(queue: .global()) {
            self.buildPath(start: coordinates[0], finish: coordinates[1])
        }
    }
}
