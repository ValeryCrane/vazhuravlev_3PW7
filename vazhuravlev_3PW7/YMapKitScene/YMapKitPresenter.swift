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
    func presentRoute(route: YMKPolyline)        // Presents given route.
}

class YMapKitPresenter {
    public weak var view: YMapKitDisplayLogic!
}


// MARK: - MapKitPresentationLogic implementation
extension YMapKitPresenter: YMapKitPresentationLogic {
    func presentRoute(route: YMKPolyline) {
        DispatchQueue.main.async { [weak self] in
            self?.view.displayRoute(route: route)
        }
    }
}

