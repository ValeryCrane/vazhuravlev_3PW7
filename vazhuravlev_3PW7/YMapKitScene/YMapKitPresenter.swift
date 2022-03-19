//
//  YMapKitPresenter.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import Foundation
import MapKit
import YandexMapsMobile

protocol YMapKitPresentationLogic: AnyObject {
    func presentRoute(route: YMKDrivingRoute, distance: Double, requestId: UUID)
}

class YMapKitPresenter {
    public weak var view: YMapKitDisplayLogic!
    
    // Presents distance as string.
    private func presentDistance(distance: Double) -> String {
        if Int(distance) > 999 {
            return "\(Int(distance) / 1000).\(Int(distance) / 100 % 10) km"
        }
        return "\(Int(distance)) m"
    }
    
    // Gets most west and most east longitude
    private func getLongitudeBounds(first: YMKPoint, last: YMKPoint) -> (Double, Double) {
        var firstLongitude = first.longitude
        var lastLongitude = last.longitude
        if firstLongitude > lastLongitude {
            swap(&firstLongitude, &lastLongitude)
        }
        let frontDistance = lastLongitude - firstLongitude
        let backDistance = 360 - lastLongitude + firstLongitude
        if frontDistance < backDistance {
            return (firstLongitude, lastLongitude)
        }
        return (lastLongitude, firstLongitude)
    }
    
    // Gets most north and most south latitude
    private func getLatitudeBounds(first: YMKPoint, last: YMKPoint) -> (Double, Double) {
        var firstLatitude = first.latitude
        var lastLatitude = last.latitude
        if firstLatitude > lastLatitude {
            swap(&firstLatitude, &lastLatitude)
        }
        let frontDistance = lastLatitude - firstLatitude
        let backDistance = 180 - lastLatitude + firstLatitude
        if frontDistance < backDistance {
            return (firstLatitude, lastLatitude)
        }
        return (lastLatitude, firstLatitude)
    }
    
    // Gets bounding box of two points.
    private func getBoundingBox(source: YMKPoint, destination: YMKPoint) -> YMKBoundingBox {
        let latitudeBounds = getLatitudeBounds(first: source, last: destination)
        let longtitudeBounds = getLongitudeBounds(first: source, last: destination)
        let southWest = YMKPoint(latitude: latitudeBounds.0, longitude: longtitudeBounds.0)
        let northEast = YMKPoint(latitude: latitudeBounds.1, longitude: longtitudeBounds.1)
        return YMKBoundingBox(southWest: southWest, northEast: northEast)
    }
}


// MARK: - MapKitPresentationLogic implementation
extension YMapKitPresenter: YMapKitPresentationLogic {
    func presentRoute(route: YMKDrivingRoute, distance: Double, requestId: UUID) {
        guard let source = route.geometry.points.first,
              let destination = route.geometry.points.last else { return }
        
        let distanceText = presentDistance(distance: distance)
        let boundingBox = getBoundingBox(source: source, destination: destination)
        
        DispatchQueue.main.async { [weak self] in
            self?.view.displayRoute(route: route, boundingBox: boundingBox, distance: distanceText, requestId: requestId)
        }
    }
}

