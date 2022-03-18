//
//  MapKitPresenter.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 18.03.2022.
//

import Foundation
import MapKit

protocol MapKitPresentationLogic: AnyObject {
    func presentRoute(route: MKPolyline)        // Presents given route.
}

class MapKitPresenter {
    public weak var view: MapKitDisplayLogic!
}


// MARK: - MapKitPresentationLogic implementation
extension MapKitPresenter: MapKitPresentationLogic {
    func presentRoute(route: MKPolyline) {
        view.displayRoute(route: route)
    }
}
