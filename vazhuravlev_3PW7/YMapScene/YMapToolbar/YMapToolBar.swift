//
//  YMapToolBar.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 19.03.2022.
//

import Foundation
import UIKit


protocol YMapDistanceDisplayLogic: AnyObject {
    func displayDistance(distance: String)
}

class YMapToolBar: UINavigationController {
    init(delegate: YMapToolBarDisplayLogic) {
        let searchView = YMapSearchViewController()
        searchView.delegate = delegate
        super.init(rootViewController: searchView)
        self.navigationBar.backgroundColor = .white
        self.view.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - YMapDistanceDisplayLogic impementation
extension YMapToolBar: YMapDistanceDisplayLogic {
    func displayDistance(distance: String) {
        if let top = topViewController as? YMapRouteViewController {
            top.displayDistance(distance: distance)
        }
    }
}

