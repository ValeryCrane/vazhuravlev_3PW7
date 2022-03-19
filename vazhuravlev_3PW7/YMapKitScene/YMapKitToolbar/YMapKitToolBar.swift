//
//  YMapKitToolBar.swift
//  vazhuravlev_3PW7
//
//  Created by Валерий Журавлев on 19.03.2022.
//

import Foundation
import UIKit


protocol YMapKitDistanceDisplayLogic: AnyObject {
    func displayDistance(distance: String)
}

class YMapKitToolBar: UINavigationController {
    init(delegate: YMapKitToolBarDisplayLogic) {
        let searchView = YMapKitSearchViewController()
        searchView.delegate = delegate
        super.init(rootViewController: searchView)
        self.navigationBar.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - YMapKitDistanceDisplayLogic impementation
extension YMapKitToolBar: YMapKitDistanceDisplayLogic {
    func displayDistance(distance: String) {
        if let top = topViewController as? YMapKitRouteViewController {
            top.displayDistance(distance: distance)
        }
    }
}

